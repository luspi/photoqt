;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Copyright (C) 2011-2021 Lukas Spies
; Contact: http://photoqt.org
;
; This file is part of PhotoQt.
;
; PhotoQt is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 2 of the License, or
; (at your option) any later version.
;
; PhotoQt is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; In order to use this file, the following files need to be placed in the
; SAME DIRECTORY AS THE APPLICATION FILES:
;
; - AdvUninstLog.nsh
; - FileAssociation.nsh
; - icon_install.ico
; - icon.ico
; - license.txt
; - photoqt-setup.nsi (this file)
;
; This will then create a new file in the application directory
; called photoqt-setup.exe.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Unicode True

; modern ui
!include MUI2.nsh

; more flow control and logic
!include LogicLib.nsh

; allows creation of custom pages
!include nsDialogs.nsh

; macro for registering and unregistering file extensions
!include "FileAssociation.nsh"

; some main registry info, used for many things below
!define INSTDIR_REG_ROOT "HKLM"
!define INSTDIR_REG_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\PhotoQt"

;include the Uninstall log header
!include AdvUninstLog.nsh

; name of project and installer filename
Name "PhotoQt"
OutFile "photoqt-setup.exe"

; this is a 64-bit program, thus install into 64-bit directory
InstallDir "$PROGRAMFILES64\PhotoQt"
InstallDirRegKey ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}" "InstallDir"

; since we want to install into system location, request admin privileges
RequestExecutionLevel admin

; warn user on abort
!define MUI_ABORTWARNING

; a custom installer icon`
!define MUI_ICON "icon_install.ico"

; we have an interactive uninstall
!insertmacro INTERACTIVE_UNINSTALL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Welcome page

!define MUI_WELCOMEPAGE_TITLE "Welcome to the installer of PhotoQt"

!define MUI_WELCOMEPAGE_TEXT "This installer will guide you through the installation of the PhotoQt. It is recommended that you close all other applications before starting the installer. $\r$\n$\r$\nIf you have any questions or concerns, please contact the developer through his website:$\r$\n$\r$\nhttps://photoqt.org$\r$\n$\r$\n$\r$\n Click Next to continue."


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Final page

!define MUI_FINISHPAGE_RUN "$INSTDIR/photoqt.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Open PhotoQt"

!define MUI_FINISHPAGE_LINK "PhotoQt website: https://photoqt.org"
!define MUI_FINISHPAGE_LINK_LOCATION "https://photoqt.org"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The order of pages

!define MUI_PAGE_CUSTOMFUNCTION_LEAVE warnUninstPrev
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "license.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
Page custom FinalStepsInit FinalStepsLeave
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES


; Set the language if the installer to English
; This has to come AFTER the list of pages above
!insertmacro MUI_LANGUAGE "English"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; List all the files and store some meta info

Section "PhotoQt" SecDummy

    ;After set the output path open the uninstall log macros block and add files/dirs with File /r
    ;This should be repeated every time the parent output path is changed either within the same
    ;section, or if there are more sections including optional components.
    SetOutPath "$INSTDIR"
    !insertmacro UNINSTALL.LOG_OPEN_INSTALL

    File /r /x *nsh /x *nsi ".\"

    !insertmacro UNINSTALL.LOG_CLOSE_INSTALL

    WriteRegStr ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}" "InstallDir" "$INSTDIR"
    WriteRegStr ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}" "DisplayName" "PhotoQt"
    ;Same as create shortcut you need to use ${UNINST_EXE} instead of anything else.
    WriteRegStr ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}" "UninstallString" "${UNINST_EXE}"

SectionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function .onInit

        ;prepare log always within .onInit function
        !insertmacro UNINSTALL.LOG_PREPARE_INSTALL

FunctionEnd

Function .onInstSuccess

         ;create/update log always within .onInstSuccess function
         !insertmacro UNINSTALL.LOG_UPDATE_INSTALL

FunctionEnd


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Update warning

Function warnUninstPrev
    IfFileExists "$INSTDIR\photoqt.exe" 0 +2
        MessageBox MB_OK|MB_ICONEXCLAMATION "It appears that an older version of PhotoQt is currently installed. Please cancel this installer and first UNINSTALL the previous version.$\r$\n$\r$\nThis step will NOT be necessary for future updates, this is the last time."
FunctionEnd


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Ask the user whether to register for any filetypes

Var Dialog

Var LabelFiletypeDesc

Var RadioButtonNone
Var RadioButtonAll
Var RadioButtonAll_State

Var CheckboxPdfPs
Var CheckboxPdfPs_State
Var CheckboxPsdXcf
Var CheckboxPsdXcf_State

Var CheckboxStartMenu
Var CheckboxStartMenu_State
Var CheckboxDesktop
Var CheckboxDesktop_State

Function FinalStepsInit
    !insertmacro MUI_HEADER_TEXT "Finishing up" "$SMPROGRAMS\$StartMenuFolder"

    nsDialogs::Create 1018
    Pop $Dialog
    ${If} $Dialog == error
        Abort
    ${EndIf}

    ${NSD_CreateLabel} 0 0 100% 18u "Here you can set PhotoQt as default application for all supported image formats. If you decide against this, then you can always still open any image from inside PhotoQt."
    Pop $LabelFiletypeDesc

    ${NSD_CreateRadioButton} 0 20u 100% 12u "Do not set as default for any image formats"
    Pop $RadioButtonNone
    ${NSD_OnClick} $RadioButtonNone FinalStepsDisEnable

    ${NSD_CreateRadioButton} 0 33u 100% 12u "Set as default for all supported image formats"
    Pop $RadioButtonAll
    ${NSD_Check} $RadioButtonAll
    ${NSD_OnClick} $RadioButtonAll FinalStepsDisEnable

    ${NSD_CreateCheckbox} 0 48u 100% 12u "Include PDF and PS"
    Pop $CheckboxPdfPs

    ${NSD_CreateCheckbox} 0 61u 100% 12u "Include PSD and XCF"
    Pop $CheckboxPsdXcf

    ${NSD_CreateHLine} 0 83u 100% 1u HLineBeforeDesktop

    ${NSD_CreateCheckbox} 0 88u 100% 12u "Create Desktop Icon"
    Pop $CheckboxDesktop
    ${NSD_Check} $CheckboxDesktop

    ${NSD_CreateCheckbox} 0 103u 100% 12u "Create Start menu entry"
    Pop $CheckboxStartMenu
    ${NSD_Check} $CheckboxStartMenu

    nsDialogs::Show

FunctionEnd

; pdf/psd/xcf checkboxes are only enabled when PhotoQt is to be set as default
Function FinalStepsDisEnable

    ${NSD_GetState} $RadioButtonAll $RadioButtonAll_State
    ${If} $RadioButtonAll_State == ${BST_CHECKED}
        EnableWindow $CheckboxPdfPs 1
        EnableWindow $CheckboxPsdXcf 1
    ${Else}
        EnableWindow $CheckboxPdfPs 0
        EnableWindow $CheckboxPsdXcf 0
    ${EndIf}

FunctionEnd

; perform actions based on user choices
Function FinalStepsLeave

    SetShellVarContext all

    ${NSD_GetState} $RadioButtonAll $RadioButtonAll_State
    ${NSD_GetState} $CheckboxPdfPs $CheckboxPdfPs_State
    ${NSD_GetState} $CheckboxPsdXcf $CheckboxPsdXcf_State
    ${NSD_GetState} $CheckboxDesktop $CheckboxDesktop_State
    ${NSD_GetState} $CheckboxStartMenu $CheckboxStartMenu_State

    ${If} $RadioButtonAll_State == ${BST_CHECKED}

        WriteRegStr HKCU "Software\PhotoQt" "fileformats" "all"

        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".3fr" "pqt.3frfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".7z" "pqt.7zfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".aai" "pqt.aaifile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".apng" "pqt.apngfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ari" "pqt.arifile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".art" "pqt.artfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".arw" "pqt.arwfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".asf" "pqt.asffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".avif" "pqt.aviffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".avifs" "pqt.aviffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".avs" "pqt.avsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".x" "pqt.avsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mbfavs" "pqt.avsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".bay" "pqt.bayfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".bmp" "pqt.bmpfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".bpg" "pqt.bpgfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cals" "pqt.calsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ct1" "pqt.calsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ct2" "pqt.calsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ct3" "pqt.calsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ct4" "pqt.calsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".c4" "pqt.calsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cal" "pqt.calsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".nif" "pqt.calsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ras" "pqt.calsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cap" "pqt.capfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".eip" "pqt.capfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".liq" "pqt.capfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cb7" "pqt.cb7file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cbr" "pqt.cbrfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cbt" "pqt.cbtfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cbz" "pqt.cbzfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cg3" "pqt.cg3file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".g3" "pqt.cg3file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".crw" "pqt.crwfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".crr" "pqt.crwfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cr2" "pqt.crwfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cr3" "pqt.crwfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cube" "pqt.cubefile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cur" "pqt.curfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cut" "pqt.cutfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pal" "pqt.cutfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pic" "pqt.cutfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dcr" "pqt.dcrfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".kdc" "pqt.dcrfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".drf" "pqt.dcrfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".k25" "pqt.dcrfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dcs" "pqt.dcrfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dcx" "pqt.dcxfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dds" "pqt.ddsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dib" "pqt.dibfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dic" "pqt.dicfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dcm" "pqt.dicfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".djvu" "pqt.djvufile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".djv" "pqt.djvufile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dng" "pqt.dngfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dpx" "pqt.dpxfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".erf" "pqt.erffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".exr" "pqt.exrfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ff" "pqt.fffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".fits" "pqt.fitsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".fit" "pqt.fitsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".fts" "pqt.fitsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".fl32" "pqt.fl32file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ftx" "pqt.ftxfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".gif" "pqt.giffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".gpr" "pqt.gprfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".heif" "pqt.heiffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".heic" "pqt.heiffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".hrz" "pqt.hrzfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".icns" "pqt.icnsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ico" "pqt.icofile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".iff" "pqt.ifffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jbig" "pqt.jbigfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jbg" "pqt.jbigfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".bie" "pqt.jbigfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jng" "pqt.jngfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jpeg" "pqt.jpegfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jpg" "pqt.jpegfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jpe" "pqt.jpegfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jif" "pqt.jpegfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jpeg2000" "pqt.jpeg2000file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".j2k" "pqt.jpeg2000file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jp2" "pqt.jpeg2000file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jpc" "pqt.jpeg2000file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jpx" "pqt.jpeg2000file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jxl" "pqt.jxlfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jxr" "pqt.jxrfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".hdp" "pqt.jxrfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".wdp" "pqt.jxrfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".koa" "pqt.koafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".gg" "pqt.koafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".gig" "pqt.koafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".kla" "pqt.koafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".kra" "pqt.krafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".lbm" "pqt.lbmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mat" "pqt.matfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mdc" "pqt.mdcfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mef" "pqt.meffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".miff" "pqt.mifffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mif" "pqt.mifffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mng" "pqt.mngfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mos" "pqt.mosfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mpc" "pqt.mpcfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mtv" "pqt.mtvfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pic" "pqt.mtvfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mvg" "pqt.mvgfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".nef" "pqt.neffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".nrw" "pqt.neffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ora" "pqt.orafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".orf" "pqt.orffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".otb" "pqt.otbfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".p7" "pqt.p7file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".palm" "pqt.palmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pam" "pqt.pamfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pbm" "pqt.pbmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pcd" "pqt.pcdfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pcds" "pqt.pcdfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pcx" "pqt.pcxfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pdb" "pqt.pdbfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pef" "pqt.peffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ptx" "pqt.peffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pes" "pqt.pesfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pfm" "pqt.pfmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pgm" "pqt.pgmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".phm" "pqt.phmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pic" "pqt.picfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".picon" "pqt.piconfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pict" "pqt.pictfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pct" "pqt.pictfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pic" "pqt.pictfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pix" "pqt.pixfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".als" "pqt.pixfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".png" "pqt.pngfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ppm" "pqt.ppmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pnm" "pqt.ppmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ptiff" "pqt.ptifffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ptif" "pqt.ptifffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pxn" "pqt.pxnfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".raf" "pqt.raffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rar" "pqt.rarfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".raw" "pqt.rawfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rwl" "pqt.rawfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rgba" "pqt.rgbafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rgb" "pqt.rgbafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".sgi" "pqt.rgbafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".bw" "pqt.rgbafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rgbe" "pqt.rgbefile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".hdr" "pqt.rgbefile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rad" "pqt.rgbefile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rgf" "pqt.rgffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rla" "pqt.rlafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rle" "pqt.rlefile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rw2" "pqt.rw2file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".sct" "pqt.sctfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ch" "pqt.sctfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ct" "pqt.sctfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".sfw" "pqt.sfwfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".alb" "pqt.sfwfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pwm" "pqt.sfwfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pwp" "pqt.sfwfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".srf" "pqt.srffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mrw" "pqt.srffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".sr2" "pqt.srffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".srw" "pqt.srwfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".sun" "pqt.sunfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ras" "pqt.sunfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".sr" "pqt.sunfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".im1" "pqt.sunfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".im24" "pqt.sunfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".im32" "pqt.sunfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".im8" "pqt.sunfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rast" "pqt.sunfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rs" "pqt.sunfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".scr" "pqt.sunfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".svg" "pqt.svgfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".svgz" "pqt.svgfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".tar" "pqt.tarfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".tga" "pqt.tgafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".icb" "pqt.tgafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".vda" "pqt.tgafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".vst" "pqt.tgafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".tiff" "pqt.tifffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".tif" "pqt.tifffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".tim" "pqt.timfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ttf" "pqt.ttffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".vicar" "pqt.vicarfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".vic" "pqt.vicarfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".img" "pqt.vicarfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".viff" "pqt.vifffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".xv" "pqt.vifffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".vtf" "pqt.vtffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".wbmp" "pqt.wbmpfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".webp" "pqt.webpfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".wmf" "pqt.wmffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".wmz" "pqt.wmffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".apm" "pqt.wmffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".wpg" "pqt.wpgfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".xbm" "pqt.xbmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".bm" "pqt.xbmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".xpm" "pqt.xpmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pm" "pqt.xpmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".xwd" "pqt.xwdfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".zip" "pqt.zipfile"


        ${If} $CheckboxPdfPs_State == ${BST_CHECKED}

            WriteRegStr HKCU "Software\PhotoQt" "fileformats_pdfps" "registered"

            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".eps" "pqt.epsfile"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".epsf" "pqt.epsfile"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".epsi" "pqt.epsfile"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pdf" "pqt.pdffile"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ps" "pqt.psfile"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ps2" "pqt.psfile"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ps3" "pqt.psfile"


        ${Else}

            ; if it was registered in a previous install, we need to de-register it here
            Var /GLOBAL fileformats_pdfps
            ReadRegStr $fileformats_pdfps HKCU "Software\PhotoQt" "fileformats_pdfps"
            ${If} $fileformats_pdfps == "registered"
                ${UnRegisterExtension} ".eps" "pqt.epsfile"
                ${UnRegisterExtension} ".epsf" "pqt.epsfile"
                ${UnRegisterExtension} ".epsi" "pqt.epsfile"
                ${UnRegisterExtension} ".pdf" "pqt.pdffile"
                ${UnRegisterExtension} ".ps" "pqt.psfile"
                ${UnRegisterExtension} ".ps2" "pqt.psfile"
                ${UnRegisterExtension} ".ps3" "pqt.psfile"
            ${EndIf}

            WriteRegStr HKCU "Software\PhotoQt" "fileformats_pdfps" ""

        ${EndIf}

        ${If} $CheckboxPsdXcf_State == ${BST_CHECKED}

            WriteRegStr HKCU "Software\PhotoQt" "fileformats_psdxcf" "registered"

            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".psd" "pqt.psdfile"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".psb" "pqt.psdfile"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".xcf" "pqt.xcffile"


        ${Else}

            ; if it was registered in a previous install, we need to de-register it here
            Var /GLOBAL fileformats_psdxcf
            ReadRegStr $fileformats_psdxcf HKCU "Software\PhotoQt" "fileformats_psdxcf"
            ${If} $fileformats_psdxcf == "registered"
                ${UnRegisterExtension} ".psd" "pqt.psdfile"
                ${UnRegisterExtension} ".psb" "pqt.psdfile"
                ${UnRegisterExtension} ".xcf" "pqt.xcffile"
            ${EndIf}

            WriteRegStr HKCU "Software\PhotoQt" "fileformats_psdxcf" ""

        ${EndIf}

    ${EndIf}

    ${If} $CheckboxDesktop_State == ${BST_CHECKED}

        ; create desktop shortcut
        CreateShortcut "$desktop\PhotoQt.lnk" "$instdir\photoqt.exe" "" "$INSTDIR\icon.ico" 0

    ${Else}

        Delete "$desktop\PhotoQt.lnk"

    ${EndIf}

    ${If} $CheckboxStartMenu_State == ${BST_CHECKED}

        ; create start menu entry in top level, no need for a subdirectory
        CreateShortcut "$SMPROGRAMS\PhotoQt.lnk" "$INSTDIR\photoqt.exe" "" "" 0

    ${Else}

        Delete "$SMPROGRAMS\PhotoQt.lnk"

    ${EndIf}

    System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v (0x08000000, 0, 0, 0)'

FunctionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The uninstaller

Section "Uninstall"

    Var /GLOBAL un_fileformats
    Var /GLOBAL un_fileformats_pdfps
    Var /GLOBAL un_fileformats_psdxcf
    ReadRegStr $un_fileformats HKCU "Software\PhotoQt" "fileformats"
    ReadRegStr $un_fileformats_pdfps HKCU "Software\PhotoQt" "fileformats_pdfps"
    ReadRegStr $un_fileformats_psdxcf HKCU "Software\PhotoQt" "fileformats_psdxcf"

    ${If} $un_fileformats == "all"

        ; ... DE-register file formats ...
        ${UnRegisterExtension} ".3fr" "pqt.3frfile"
        ${UnRegisterExtension} ".7z" "pqt.7zfile"
        ${UnRegisterExtension} ".aai" "pqt.aaifile"
        ${UnRegisterExtension} ".apng" "pqt.apngfile"
        ${UnRegisterExtension} ".ari" "pqt.arifile"
        ${UnRegisterExtension} ".art" "pqt.artfile"
        ${UnRegisterExtension} ".arw" "pqt.arwfile"
        ${UnRegisterExtension} ".asf" "pqt.asffile"
        ${UnRegisterExtension} ".avif" "pqt.aviffile"
        ${UnRegisterExtension} ".avifs" "pqt.aviffile"
        ${UnRegisterExtension} ".avs" "pqt.avsfile"
        ${UnRegisterExtension} ".x" "pqt.avsfile"
        ${UnRegisterExtension} ".mbfavs" "pqt.avsfile"
        ${UnRegisterExtension} ".bay" "pqt.bayfile"
        ${UnRegisterExtension} ".bmp" "pqt.bmpfile"
        ${UnRegisterExtension} ".bpg" "pqt.bpgfile"
        ${UnRegisterExtension} ".cals" "pqt.calsfile"
        ${UnRegisterExtension} ".ct1" "pqt.calsfile"
        ${UnRegisterExtension} ".ct2" "pqt.calsfile"
        ${UnRegisterExtension} ".ct3" "pqt.calsfile"
        ${UnRegisterExtension} ".ct4" "pqt.calsfile"
        ${UnRegisterExtension} ".c4" "pqt.calsfile"
        ${UnRegisterExtension} ".cal" "pqt.calsfile"
        ${UnRegisterExtension} ".nif" "pqt.calsfile"
        ${UnRegisterExtension} ".ras" "pqt.calsfile"
        ${UnRegisterExtension} ".cap" "pqt.capfile"
        ${UnRegisterExtension} ".eip" "pqt.capfile"
        ${UnRegisterExtension} ".liq" "pqt.capfile"
        ${UnRegisterExtension} ".cb7" "pqt.cb7file"
        ${UnRegisterExtension} ".cbr" "pqt.cb7file"
        ${UnRegisterExtension} ".cbt" "pqt.cb7file"
        ${UnRegisterExtension} ".cbz" "pqt.cb7file"
        ${UnRegisterExtension} ".cg3" "pqt.cg3file"
        ${UnRegisterExtension} ".g3" "pqt.cg3file"
        ${UnRegisterExtension} ".crw" "pqt.crwfile"
        ${UnRegisterExtension} ".crr" "pqt.crwfile"
        ${UnRegisterExtension} ".cr2" "pqt.crwfile"
        ${UnRegisterExtension} ".cr3" "pqt.crwfile"
        ${UnRegisterExtension} ".cube" "pqt.cubefile"
        ${UnRegisterExtension} ".cur" "pqt.curfile"
        ${UnRegisterExtension} ".cut" "pqt.cutfile"
        ${UnRegisterExtension} ".pal" "pqt.cutfile"
        ${UnRegisterExtension} ".pic" "pqt.cutfile"
        ${UnRegisterExtension} ".dcr" "pqt.dcrfile"
        ${UnRegisterExtension} ".kdc" "pqt.dcrfile"
        ${UnRegisterExtension} ".drf" "pqt.dcrfile"
        ${UnRegisterExtension} ".k25" "pqt.dcrfile"
        ${UnRegisterExtension} ".dcs" "pqt.dcrfile"
        ${UnRegisterExtension} ".dcx" "pqt.dcxfile"
        ${UnRegisterExtension} ".dds" "pqt.ddsfile"
        ${UnRegisterExtension} ".dib" "pqt.dibfile"
        ${UnRegisterExtension} ".dic" "pqt.dicfile"
        ${UnRegisterExtension} ".dcm" "pqt.dicfile"
        ${UnRegisterExtension} ".djvu" "pqt.djvufile"
        ${UnRegisterExtension} ".djv" "pqt.djvufile"
        ${UnRegisterExtension} ".dng" "pqt.dngfile"
        ${UnRegisterExtension} ".dpx" "pqt.dpxfile"
        ${UnRegisterExtension} ".erf" "pqt.erffile"
        ${UnRegisterExtension} ".exr" "pqt.exrfile"
        ${UnRegisterExtension} ".ff" "pqt.fffile"
        ${UnRegisterExtension} ".fits" "pqt.fitsfile"
        ${UnRegisterExtension} ".fit" "pqt.fitsfile"
        ${UnRegisterExtension} ".fts" "pqt.fitsfile"
        ${UnRegisterExtension} ".fl32" "pqt.fl32file"
        ${UnRegisterExtension} ".ftx" "pqt.ftxfile"
        ${UnRegisterExtension} ".gif" "pqt.giffile"
        ${UnRegisterExtension} ".gpr" "pqt.gprfile"
        ${UnRegisterExtension} ".heif" "pqt.heiffile"
        ${UnRegisterExtension} ".heic" "pqt.heiffile"
        ${UnRegisterExtension} ".hrz" "pqt.hrzfile"
        ${UnRegisterExtension} ".icns" "pqt.icnsfile"
        ${UnRegisterExtension} ".ico" "pqt.icofile"
        ${UnRegisterExtension} ".iff" "pqt.ifffile"
        ${UnRegisterExtension} ".jbig" "pqt.jbigfile"
        ${UnRegisterExtension} ".jbg" "pqt.jbigfile"
        ${UnRegisterExtension} ".bie" "pqt.jbigfile"
        ${UnRegisterExtension} ".jng" "pqt.jngfile"
        ${UnRegisterExtension} ".jpeg" "pqt.jpegfile"
        ${UnRegisterExtension} ".jpg" "pqt.jpegfile"
        ${UnRegisterExtension} ".jpe" "pqt.jpegfile"
        ${UnRegisterExtension} ".jif" "pqt.jpegfile"
        ${UnRegisterExtension} ".jpeg2000" "pqt.jpeg2000file"
        ${UnRegisterExtension} ".j2k" "pqt.jpeg2000file"
        ${UnRegisterExtension} ".jp2" "pqt.jpeg2000file"
        ${UnRegisterExtension} ".jpc" "pqt.jpeg2000file"
        ${UnRegisterExtension} ".jpx" "pqt.jpeg2000file"
        ${UnRegisterExtension} ".jxl" "pqt.jxlfile"
        ${UnRegisterExtension} ".jxr" "pqt.jxrfile"
        ${UnRegisterExtension} ".hdp" "pqt.jxrfile"
        ${UnRegisterExtension} ".wdp" "pqt.jxrfile"
        ${UnRegisterExtension} ".koa" "pqt.koafile"
        ${UnRegisterExtension} ".gg" "pqt.koafile"
        ${UnRegisterExtension} ".gig" "pqt.koafile"
        ${UnRegisterExtension} ".kla" "pqt.koafile"
        ${UnRegisterExtension} ".kra" "pqt.krafile"
        ${UnRegisterExtension} ".lbm" "pqt.lbmfile"
        ${UnRegisterExtension} ".mat" "pqt.matfile"
        ${UnRegisterExtension} ".mdc" "pqt.mdcfile"
        ${UnRegisterExtension} ".mef" "pqt.meffile"
        ${UnRegisterExtension} ".miff" "pqt.mifffile"
        ${UnRegisterExtension} ".mif" "pqt.mifffile"
        ${UnRegisterExtension} ".mng" "pqt.mngfile"
        ${UnRegisterExtension} ".mos" "pqt.mosfile"
        ${UnRegisterExtension} ".mpc" "pqt.mpcfile"
        ${UnRegisterExtension} ".mtv" "pqt.mtvfile"
        ${UnRegisterExtension} ".pic" "pqt.mtvfile"
        ${UnRegisterExtension} ".mvg" "pqt.mvgfile"
        ${UnRegisterExtension} ".nef" "pqt.neffile"
        ${UnRegisterExtension} ".nrw" "pqt.neffile"
        ${UnRegisterExtension} ".ora" "pqt.orafile"
        ${UnRegisterExtension} ".orf" "pqt.orffile"
        ${UnRegisterExtension} ".otb" "pqt.otbfile"
        ${UnRegisterExtension} ".p7" "pqt.p7file"
        ${UnRegisterExtension} ".palm" "pqt.palmfile"
        ${UnRegisterExtension} ".pam" "pqt.pamfile"
        ${UnRegisterExtension} ".pbm" "pqt.pbmfile"
        ${UnRegisterExtension} ".pcd" "pqt.pcdfile"
        ${UnRegisterExtension} ".pcds" "pqt.pcdfile"
        ${UnRegisterExtension} ".pcx" "pqt.pcxfile"
        ${UnRegisterExtension} ".pdb" "pqt.pdbfile"
        ${UnRegisterExtension} ".pef" "pqt.peffile"
        ${UnRegisterExtension} ".ptx" "pqt.peffile"
        ${UnRegisterExtension} ".pes" "pqt.pesfile"
        ${UnRegisterExtension} ".pfm" "pqt.pfmfile"
        ${UnRegisterExtension} ".pgm" "pqt.pgmfile"
        ${UnRegisterExtension} ".phm" "pqt.phmfile"
        ${UnRegisterExtension} ".pic" "pqt.picfile"
        ${UnRegisterExtension} ".picon" "pqt.piconfile"
        ${UnRegisterExtension} ".pict" "pqt.pictfile"
        ${UnRegisterExtension} ".pct" "pqt.pictfile"
        ${UnRegisterExtension} ".pic" "pqt.pictfile"
        ${UnRegisterExtension} ".pix" "pqt.pixfile"
        ${UnRegisterExtension} ".als" "pqt.pixfile"
        ${UnRegisterExtension} ".png" "pqt.pngfile"
        ${UnRegisterExtension} ".ppm" "pqt.ppmfile"
        ${UnRegisterExtension} ".pnm" "pqt.ppmfile"
        ${UnRegisterExtension} ".ptiff" "pqt.ptifffile"
        ${UnRegisterExtension} ".ptif" "pqt.ptifffile"
        ${UnRegisterExtension} ".pxn" "pqt.pxnfile"
        ${UnRegisterExtension} ".raf" "pqt.raffile"
        ${UnRegisterExtension} ".rar" "pqt.rarfile"
        ${UnRegisterExtension} ".raw" "pqt.rawfile"
        ${UnRegisterExtension} ".rwl" "pqt.rawfile"
        ${UnRegisterExtension} ".rgba" "pqt.rgbafile"
        ${UnRegisterExtension} ".rgb" "pqt.rgbafile"
        ${UnRegisterExtension} ".sgi" "pqt.rgbafile"
        ${UnRegisterExtension} ".bw" "pqt.rgbafile"
        ${UnRegisterExtension} ".rgbe" "pqt.rgbefile"
        ${UnRegisterExtension} ".hdr" "pqt.rgbefile"
        ${UnRegisterExtension} ".rad" "pqt.rgbefile"
        ${UnRegisterExtension} ".rgf" "pqt.rgffile"
        ${UnRegisterExtension} ".rla" "pqt.rlafile"
        ${UnRegisterExtension} ".rle" "pqt.rlefile"
        ${UnRegisterExtension} ".rw2" "pqt.rw2file"
        ${UnRegisterExtension} ".sct" "pqt.sctfile"
        ${UnRegisterExtension} ".ch" "pqt.sctfile"
        ${UnRegisterExtension} ".ct" "pqt.sctfile"
        ${UnRegisterExtension} ".sfw" "pqt.sfwfile"
        ${UnRegisterExtension} ".alb" "pqt.sfwfile"
        ${UnRegisterExtension} ".pwm" "pqt.sfwfile"
        ${UnRegisterExtension} ".pwp" "pqt.sfwfile"
        ${UnRegisterExtension} ".srf" "pqt.srffile"
        ${UnRegisterExtension} ".mrw" "pqt.srffile"
        ${UnRegisterExtension} ".sr2" "pqt.srffile"
        ${UnRegisterExtension} ".srw" "pqt.srwfile"
        ${UnRegisterExtension} ".sun" "pqt.sunfile"
        ${UnRegisterExtension} ".ras" "pqt.sunfile"
        ${UnRegisterExtension} ".sr" "pqt.sunfile"
        ${UnRegisterExtension} ".im1" "pqt.sunfile"
        ${UnRegisterExtension} ".im24" "pqt.sunfile"
        ${UnRegisterExtension} ".im32" "pqt.sunfile"
        ${UnRegisterExtension} ".im8" "pqt.sunfile"
        ${UnRegisterExtension} ".rast" "pqt.sunfile"
        ${UnRegisterExtension} ".rs" "pqt.sunfile"
        ${UnRegisterExtension} ".scr" "pqt.sunfile"
        ${UnRegisterExtension} ".svg" "pqt.svgfile"
        ${UnRegisterExtension} ".svgz" "pqt.svgfile"
        ${UnRegisterExtension} ".tar" "pqt.tarfile"
        ${UnRegisterExtension} ".tga" "pqt.tgafile"
        ${UnRegisterExtension} ".icb" "pqt.tgafile"
        ${UnRegisterExtension} ".vda" "pqt.tgafile"
        ${UnRegisterExtension} ".vst" "pqt.tgafile"
        ${UnRegisterExtension} ".tiff" "pqt.tifffile"
        ${UnRegisterExtension} ".tif" "pqt.tifffile"
        ${UnRegisterExtension} ".tim" "pqt.timfile"
        ${UnRegisterExtension} ".ttf" "pqt.ttffile"
        ${UnRegisterExtension} ".vicar" "pqt.vicarfile"
        ${UnRegisterExtension} ".vic" "pqt.vicarfile"
        ${UnRegisterExtension} ".img" "pqt.vicarfile"
        ${UnRegisterExtension} ".viff" "pqt.vifffile"
        ${UnRegisterExtension} ".xv" "pqt.vifffile"
        ${UnRegisterExtension} ".vtf" "pqt.vtffile"
        ${UnRegisterExtension} ".wbmp" "pqt.wbmpfile"
        ${UnRegisterExtension} ".webp" "pqt.webpfile"
        ${UnRegisterExtension} ".wmf" "pqt.wmffile"
        ${UnRegisterExtension} ".wmz" "pqt.wmffile"
        ${UnRegisterExtension} ".apm" "pqt.wmffile"
        ${UnRegisterExtension} ".wpg" "pqt.wpgfile"
        ${UnRegisterExtension} ".xbm" "pqt.xbmfile"
        ${UnRegisterExtension} ".bm" "pqt.xbmfile"
        ${UnRegisterExtension} ".xpm" "pqt.xpmfile"
        ${UnRegisterExtension} ".pm" "pqt.xpmfile"
        ${UnRegisterExtension} ".xwd" "pqt.xwdfile"
        ${UnRegisterExtension} ".zip" "pqt.zipfile"

        WriteRegStr HKCU "Software\PhotoQt" "fileformats" ""

    ${EndIf}

    ${If} $un_fileformats_pdfps == "registered"
        ${UnRegisterExtension} ".eps" "pqt.epsfile"
        ${UnRegisterExtension} ".epsf" "pqt.epsfile"
        ${UnRegisterExtension} ".epsi" "pqt.epsfile"
        ${UnRegisterExtension} ".pdf" "pqt.pdffile"
        ${UnRegisterExtension} ".ps" "pqt.psfile"
        ${UnRegisterExtension} ".ps2" "pqt.psfile"
        ${UnRegisterExtension} ".ps3" "pqt.psfile"

        WriteRegStr HKCU "Software\PhotoQt" "fileformats_pdfps" ""

    ${EndIf}

    ${If} $un_fileformats_psdxcf == "registered"
        ${UnRegisterExtension} ".psd" "pqt.psdfile"
        ${UnRegisterExtension} ".psb" "pqt.psdfile"
        ${UnRegisterExtension} ".xcf" "pqt.xcffile"

        WriteRegStr HKCU "Software\PhotoQt" "fileformats_psdxcf" ""

    ${EndIf}


    ;begin uninstall
    !insertmacro UNINSTALL.LOG_BEGIN_UNINSTALL

    ;uninstall from path, must be repeated for every install logged path individual
    !insertmacro UNINSTALL.LOG_UNINSTALL "$INSTDIR"

    ;end uninstall, after uninstall from all logged paths has been performed
    !insertmacro UNINSTALL.LOG_END_UNINSTALL

    DeleteRegKey ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}"

    Delete "$SMPROGRAMS\PhotoQt.lnk"
    Delete "$desktop\PhotoQt.lnk"

SectionEnd
