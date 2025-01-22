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
; In addition the EnVar plugin needs to be installed for NSIS:
; https://nsis.sourceforge.io/EnVar_plug-in
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
!include AdvUninstLog2.nsh

!define PHOTOQT_VERSION "4.7"

; name of project and installer filename
Name "PhotoQt"
OutFile "photoqt-${PHOTOQT_VERSION}.exe"

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
!insertmacro UNATTENDED_UNINSTALL

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

    ;The output path for where to install files to.
    SetOutPath "$INSTDIR"
    
    ;We start by removing existing files.
    !insertmacro UNINSTALL.NEW_PREUNINSTALL "$INSTDIR"

    ;Open the uninstall log file.
    !insertmacro UNINSTALL.LOG_OPEN_INSTALL

    ;Recursively add all the files.
    File /r /x *nsh /x *nsi /x *qmlc /x photoqt-setup.exe ".\"

    ;Close the uninstall log.
    !insertmacro UNINSTALL.LOG_CLOSE_INSTALL

    WriteRegStr ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}" "InstallDir" "$INSTDIR"
    WriteRegStr ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}" "DisplayName" "PhotoQt"
    ;Same as create shortcut you need to use ${UNINST_EXE} instead of anything else.
    WriteRegStr ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}" "UninstallString" "${UNINST_EXE} /S"
    WriteRegStr ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}" "QuietUninstallString" "${UNINST_EXE} /S"
    WriteRegStr ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}" "DisplayVersion" "${PHOTOQT_VERSION}"
    WriteRegStr ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}" "Publisher" "Lukas Spies"

    IfSilent 0 +2
    Call FinalStepsLeave

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

    IfSilent 0 +3
    StrCpy $RadioButtonAll_State ${BST_CHECKED}
    StrCpy $CheckboxStartMenu_State ${BST_CHECKED}

    ; We need to make sure that the updated file associations are registered
    ; That's why we unregister the old ones first
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
    ${UnRegisterExtension} ".eps" "pqt.epsfile"
    ${UnRegisterExtension} ".epsf" "pqt.epsfile"
    ${UnRegisterExtension} ".epsi" "pqt.epsfile"
    ${UnRegisterExtension} ".pdf" "pqt.pdffile"
    ${UnRegisterExtension} ".ps" "pqt.psfile"
    ${UnRegisterExtension} ".ps2" "pqt.psfile"
    ${UnRegisterExtension} ".ps3" "pqt.psfile"
    ${UnRegisterExtension} ".psd" "pqt.psdfile"
    ${UnRegisterExtension} ".psb" "pqt.psdfile"
    ${UnRegisterExtension} ".xcf" "pqt.xcffile"

    ; These might have gotten registered like this, but we don't want to register them at all
    ${UnRegisterExtension} ".7z" "7z file format"
    ${UnRegisterExtension} ".rar" "RAR file format"
    ${UnRegisterExtension} ".zip" "ZIP file format"


    ; The supported file formats can change between installs
    ; Thus we need to unregister all previous formats and re-register them below
    ${UnRegisterExtension} ".3fr" "Hasselblad Raw Image Format"
    ${UnRegisterExtension} ".aai" "AAI Dune image"
    ${UnRegisterExtension} ".ani" "Animated Windows cursors"
    ${UnRegisterExtension} ".apng" "Animated Portable Network Graphics"
    ${UnRegisterExtension} ".ari" "ARRIFLEX Raw Image Format"
    ${UnRegisterExtension} ".art" "1st Publisher"
    ${UnRegisterExtension} ".arw" "Sony Digital Camera Alpha Raw Image Format"
    ${UnRegisterExtension} ".asf" "Advanced Systems Format"
    ${UnRegisterExtension} ".avif" "AV1 Image File Format"
    ${UnRegisterExtension} ".avifs" "AV1 Image File Format"
    ${UnRegisterExtension} ".avs" "AVS X image"
    ${UnRegisterExtension} ".x" "AVS X image"
    ${UnRegisterExtension} ".mbfavs" "AVS X image"
    ${UnRegisterExtension} ".bay" "Casio Raw Image Format"
    ${UnRegisterExtension} ".bmp" "Microsoft Windows bitmap"
    ${UnRegisterExtension} ".dib" "Microsoft Windows bitmap"
    ${UnRegisterExtension} ".bpg" "Better Portable Graphics"
    ${UnRegisterExtension} ".cals" "Continuous Acquisition and Life-cycle Support Type 1 image"
    ${UnRegisterExtension} ".ct1" "Continuous Acquisition and Life-cycle Support Type 1 image"
    ${UnRegisterExtension} ".ct2" "Continuous Acquisition and Life-cycle Support Type 1 image"
    ${UnRegisterExtension} ".ct3" "Continuous Acquisition and Life-cycle Support Type 1 image"
    ${UnRegisterExtension} ".ct4" "Continuous Acquisition and Life-cycle Support Type 1 image"
    ${UnRegisterExtension} ".c4" "Continuous Acquisition and Life-cycle Support Type 1 image"
    ${UnRegisterExtension} ".cal" "Continuous Acquisition and Life-cycle Support Type 1 image"
    ${UnRegisterExtension} ".nif" "Continuous Acquisition and Life-cycle Support Type 1 image"
    ${UnRegisterExtension} ".ras" "Continuous Acquisition and Life-cycle Support Type 1 image"
    ${UnRegisterExtension} ".cap" "Phase One Raw Image Format"
    ${UnRegisterExtension} ".eip" "Phase One Raw Image Format"
    ${UnRegisterExtension} ".liq" "Phase One Raw Image Format"
    ${UnRegisterExtension} ".cb7" "Comic book archive"
    ${UnRegisterExtension} ".cbr" "Comic book archive"
    ${UnRegisterExtension} ".cbt" "Comic book archive"
    ${UnRegisterExtension} ".cbz" "Comic book archive"
    ${UnRegisterExtension} ".cg3" "CCITT Group 3"
    ${UnRegisterExtension} ".g3" "CCITT Group 3"
    ${UnRegisterExtension} ".crw" "Canon Digital Camera Raw Image Format"
    ${UnRegisterExtension} ".crr" "Canon Digital Camera Raw Image Format"
    ${UnRegisterExtension} ".cr2" "Canon Digital Camera Raw Image Format"
    ${UnRegisterExtension} ".cr3" "Canon Digital Camera Raw Image Format"
    ${UnRegisterExtension} ".cube" "Cube Color lookup table converted to a HALD image"
    ${UnRegisterExtension} ".cur" "Microsoft Windows cursor format"
    ${UnRegisterExtension} ".cut" "Dr. Halo"
    ${UnRegisterExtension} ".pal" "Dr. Halo"
    ${UnRegisterExtension} ".dcr" "Kodak Cineon Raw Image Format"
    ${UnRegisterExtension} ".kdc" "Kodak Cineon Raw Image Format"
    ${UnRegisterExtension} ".drf" "Kodak Cineon Raw Image Format"
    ${UnRegisterExtension} ".k25" "Kodak Cineon Raw Image Format"
    ${UnRegisterExtension} ".dcs" "Kodak Cineon Raw Image Format"
    ${UnRegisterExtension} ".dcx" "ZSoft IBM PC multi-page Paintbrush image"
    ${UnRegisterExtension} ".dds" "DirectDraw Surface"
    ${UnRegisterExtension} ".dfont" "Multi-face font package"
    ${UnRegisterExtension} ".dic" "Digital Imaging and Communications in Medicine (DICOM) image"
    ${UnRegisterExtension} ".dcm" "Digital Imaging and Communications in Medicine (DICOM) image"
    ${UnRegisterExtension} ".djvu" "DjVu digital document format "
    ${UnRegisterExtension} ".djv" "DjVu digital document format "
    ${UnRegisterExtension} ".dng" "Adobe Digital Negative Raw Image Format"
    ${UnRegisterExtension} ".dpx" "Digital Moving Picture Exchange"
    ${UnRegisterExtension} ".erf" "Epson Raw Image Format"
    ${UnRegisterExtension} ".exr" "OpenEXR"
    ${UnRegisterExtension} ".ff" "farbfeld"
    ${UnRegisterExtension} ".fits" "Flexible Image Transport System"
    ${UnRegisterExtension} ".fit" "Flexible Image Transport System"
    ${UnRegisterExtension} ".fts" "Flexible Image Transport System"
    ${UnRegisterExtension} ".fl32" "FilmLight floating point image format"
    ${UnRegisterExtension} ".ftx" "FAKK 2"
    ${UnRegisterExtension} ".gif" "Graphics Interchange Format"
    ${UnRegisterExtension} ".gpr" "GoPro GPR Raw Image Format"
    ${UnRegisterExtension} ".heif" "High Efficiency Image Format"
    ${UnRegisterExtension} ".heic" "High Efficiency Image Format"
    ${UnRegisterExtension} ".hrz" "Slow-scan television"
    ${UnRegisterExtension} ".icns" "Apple Icon Image"
    ${UnRegisterExtension} ".ico" "Microsoft Windows icon format"
    ${UnRegisterExtension} ".iff" "Interchange File Format"
    ${UnRegisterExtension} ".jbig" "Joint Bi-level Image experts Group file interchange format (JBIG)"
    ${UnRegisterExtension} ".jbg" "Joint Bi-level Image experts Group file interchange format (JBIG)"
    ${UnRegisterExtension} ".bie" "Joint Bi-level Image experts Group file interchange format (JBIG)"
    ${UnRegisterExtension} ".jng" "JPEG Network Graphics"
    ${UnRegisterExtension} ".jpeg" "Joint Photographic Experts Group JFIF format"
    ${UnRegisterExtension} ".jpg" "Joint Photographic Experts Group JFIF format"
    ${UnRegisterExtension} ".jpe" "Joint Photographic Experts Group JFIF format"
    ${UnRegisterExtension} ".jif" "Joint Photographic Experts Group JFIF format"
    ${UnRegisterExtension} ".jpeg2000" "JPEG-2000"
    ${UnRegisterExtension} ".j2k" "JPEG-2000"
    ${UnRegisterExtension} ".jp2" "JPEG-2000"
    ${UnRegisterExtension} ".jpc" "JPEG-2000"
    ${UnRegisterExtension} ".jpx" "JPEG-2000"
    ${UnRegisterExtension} ".jxl" "JPEG XL"
    ${UnRegisterExtension} ".jxr" "JPEG-XR"
    ${UnRegisterExtension} ".hdp" "JPEG-XR"
    ${UnRegisterExtension} ".wdp" "JPEG-XR"
    ${UnRegisterExtension} ".koa" "KOALA files"
    ${UnRegisterExtension} ".gg" "KOALA files"
    ${UnRegisterExtension} ".gig" "KOALA files"
    ${UnRegisterExtension} ".kla" "KOALA files"
    ${UnRegisterExtension} ".kra" "Krita Document"
    ${UnRegisterExtension} ".lbm" "Interlaced Bitmap"
    ${UnRegisterExtension} ".mat" "MATLAB image format"
    ${UnRegisterExtension} ".mdc" "Minolta/Agfa Raw Image Format"
    ${UnRegisterExtension} ".mef" "Mamiya Raw Image Format"
    ${UnRegisterExtension} ".miff" "Magick image file format"
    ${UnRegisterExtension} ".mif" "Magick image file format"
    ${UnRegisterExtension} ".mng" "Multiple-image Network Graphics"
    ${UnRegisterExtension} ".mos" "Leaf Raw Image Format"
    ${UnRegisterExtension} ".mpc" "Magick Persistent Cache image file format"
    ${UnRegisterExtension} ".mtv" "MTV ray tracer bitmap"
    ${UnRegisterExtension} ".pic" "MTV ray tracer bitmap"
    ${UnRegisterExtension} ".mvg" "Magick Vector Graphics"
    ${UnRegisterExtension} ".nef" "Nikon Digital SLR Camera Raw Image Format"
    ${UnRegisterExtension} ".nrw" "Nikon Digital SLR Camera Raw Image Format"
    ${UnRegisterExtension} ".ora" "OpenRaster"
    ${UnRegisterExtension} ".orf" "Olympus Digital Camera Raw Image Format"
    ${UnRegisterExtension} ".otb" "On-the-air Bitmap"
    ${UnRegisterExtension} ".otf" "OpenType font file"
    ${UnRegisterExtension} ".otc" "OpenType font file"
    ${UnRegisterExtension} ".ttf" "OpenType font file"
    ${UnRegisterExtension} ".ttc" "OpenType font file"
    ${UnRegisterExtension} ".p7" "Xv Visual Schnauzer thumbnail format"
    ${UnRegisterExtension} ".palm" "Palm pixmap"
    ${UnRegisterExtension} ".pam" "Portable Arbitrary Map format"
    ${UnRegisterExtension} ".pbm" "Portable bitmap format (black and white)"
    ${UnRegisterExtension} ".pcd" "Photo CD"
    ${UnRegisterExtension} ".pcds" "Photo CD"
    ${UnRegisterExtension} ".pcx" "ZSoft PiCture eXchange"
    ${UnRegisterExtension} ".pdb" "Palm Database ImageViewer Format"
    ${UnRegisterExtension} ".pef" "Pentax Raw Image Format"
    ${UnRegisterExtension} ".ptx" "Pentax Raw Image Format"
    ${UnRegisterExtension} ".pes" "Embrid Embroidery Format"
    ${UnRegisterExtension} ".pfb" "Postscript Type 1 font "
    ${UnRegisterExtension} ".pfm" "Postscript Type 1 font "
    ${UnRegisterExtension} ".afm" "Postscript Type 1 font "
    ${UnRegisterExtension} ".inf" "Postscript Type 1 font "
    ${UnRegisterExtension} ".pfa" "Postscript Type 1 font "
    ${UnRegisterExtension} ".ofm" "Postscript Type 1 font "
    ${UnRegisterExtension} ".pfm" "Portable Float Map"
    ${UnRegisterExtension} ".pgm" "Portable graymap format (gray scale)"
    ${UnRegisterExtension} ".pgx" "JPEG 2000 uncompressed format"
    ${UnRegisterExtension} ".phm" "Portable float map format 16-bit half"
    ${UnRegisterExtension} ".pic" "Softimage PIC"
    ${UnRegisterExtension} ".picon" "Personal Icon"
    ${UnRegisterExtension} ".pict" "QuickDraw/PICT"
    ${UnRegisterExtension} ".pct" "QuickDraw/PICT"
    ${UnRegisterExtension} ".pic" "QuickDraw/PICT"
    ${UnRegisterExtension} ".pix" "Alias/Wavefront RLE image format"
    ${UnRegisterExtension} ".als" "Alias/Wavefront RLE image format"
    ${UnRegisterExtension} ".alias" "Alias/Wavefront RLE image format"
    ${UnRegisterExtension} ".png" "Portable Network Graphics"
    ${UnRegisterExtension} ".ppm" "Portable pixmap format (color)"
    ${UnRegisterExtension} ".pnm" "Portable pixmap format (color)"
    ${UnRegisterExtension} ".ptiff" "Pyramid encoded TIFF"
    ${UnRegisterExtension} ".ptif" "Pyramid encoded TIFF"
    ${UnRegisterExtension} ".pxn" "Logitech Raw Image Format"
    ${UnRegisterExtension} ".qoi" "Quite OK image format"
    ${UnRegisterExtension} ".raf" "Fuji CCD Raw Image Format"
    ${UnRegisterExtension} ".raw" "Leica Raw Image Format"
    ${UnRegisterExtension} ".rwl" "Leica Raw Image Format"
    ${UnRegisterExtension} ".rgba" "SGI images"
    ${UnRegisterExtension} ".rgb" "SGI images"
    ${UnRegisterExtension} ".sgi" "SGI images"
    ${UnRegisterExtension} ".bw" "SGI images"
    ${UnRegisterExtension} ".rgbe" "Radiance RGBE image format"
    ${UnRegisterExtension} ".hdr" "Radiance RGBE image format"
    ${UnRegisterExtension} ".rad" "Radiance RGBE image format"
    ${UnRegisterExtension} ".rgf" "LEGO Mindstorms EV3 Robot Graphics File"
    ${UnRegisterExtension} ".rla" "Wavefront RLA File Format"
    ${UnRegisterExtension} ".rle" "Utah Run length encoded image file"
    ${UnRegisterExtension} ".rw2" "Panasonic Raw Image Format"
    ${UnRegisterExtension} ".scr" "ZX-Spectrum SCREEN"
    ${UnRegisterExtension} ".sct" "Scitex Continuous Tone Picture"
    ${UnRegisterExtension} ".ch" "Scitex Continuous Tone Picture"
    ${UnRegisterExtension} ".ct" "Scitex Continuous Tone Picture"
    ${UnRegisterExtension} ".sfw" "Seattle File Works image"
    ${UnRegisterExtension} ".alb" "Seattle File Works image"
    ${UnRegisterExtension} ".pwm" "Seattle File Works image"
    ${UnRegisterExtension} ".pwp" "Seattle File Works image"
    ${UnRegisterExtension} ".sixel" "DEC SIXEL Graphics Format"
    ${UnRegisterExtension} ".srf" "Sony (Minolta) Raw Image Format"
    ${UnRegisterExtension} ".mrw" "Sony (Minolta) Raw Image Format"
    ${UnRegisterExtension} ".sr2" "Sony (Minolta) Raw Image Format"
    ${UnRegisterExtension} ".srw" "Samsung Raw Image Format"
    ${UnRegisterExtension} ".sun" "SUN Rasterfile"
    ${UnRegisterExtension} ".ras" "SUN Rasterfile"
    ${UnRegisterExtension} ".sr" "SUN Rasterfile"
    ${UnRegisterExtension} ".im1" "SUN Rasterfile"
    ${UnRegisterExtension} ".im24" "SUN Rasterfile"
    ${UnRegisterExtension} ".im32" "SUN Rasterfile"
    ${UnRegisterExtension} ".im8" "SUN Rasterfile"
    ${UnRegisterExtension} ".rast" "SUN Rasterfile"
    ${UnRegisterExtension} ".rs" "SUN Rasterfile"
    ${UnRegisterExtension} ".scr" "SUN Rasterfile"
    ${UnRegisterExtension} ".svg" "Scalable Vector Graphics"
    ${UnRegisterExtension} ".svgz" "Scalable Vector Graphics"
    ${UnRegisterExtension} ".tar" "TAR file format"
    ${UnRegisterExtension} ".tga" "Truevision Targa image"
    ${UnRegisterExtension} ".icb" "Truevision Targa image"
    ${UnRegisterExtension} ".vda" "Truevision Targa image"
    ${UnRegisterExtension} ".vst" "Truevision Targa image"
    ${UnRegisterExtension} ".tiff" "Tagged Image File Format"
    ${UnRegisterExtension} ".tif" "Tagged Image File Format"
    ${UnRegisterExtension} ".tim" "PSX TIM (PlayStation Graphics)"
    ${UnRegisterExtension} ".ttf" "TrueType font file"
    ${UnRegisterExtension} ".vicar" "VICAR rasterfile format"
    ${UnRegisterExtension} ".vic" "VICAR rasterfile format"
    ${UnRegisterExtension} ".img" "VICAR rasterfile format"
    ${UnRegisterExtension} ".viff" "Khoros Visualization Image File Format"
    ${UnRegisterExtension} ".xv" "Khoros Visualization Image File Format"
    ${UnRegisterExtension} ".vtf" "Valve Texture Format"
    ${UnRegisterExtension} ".wbmp" "Wireless Bitmap"
    ${UnRegisterExtension} ".webp" "Google web image format"
    ${UnRegisterExtension} ".wmf" "Windows Metafile"
    ${UnRegisterExtension} ".wmz" "Windows Metafile"
    ${UnRegisterExtension} ".apm" "Windows Metafile"
    ${UnRegisterExtension} ".wpg" "Word Perfect Graphics File"
    ${UnRegisterExtension} ".xbm" "X BitMap"
    ${UnRegisterExtension} ".bm" "X BitMap"
    ${UnRegisterExtension} ".xpm" "X PixMap"
    ${UnRegisterExtension} ".pm" "X PixMap"
    ${UnRegisterExtension} ".xwd" "X Windows system window dump"
    ${UnRegisterExtension} ".eps" "Encapsulated PostScript"
    ${UnRegisterExtension} ".epsf" "Encapsulated PostScript"
    ${UnRegisterExtension} ".epsi" "Encapsulated PostScript"
    ${UnRegisterExtension} ".pdf" "Adobe Portable Document Format"
    ${UnRegisterExtension} ".ps" "Adobe Level III PostScript file"
    ${UnRegisterExtension} ".ps2" "Adobe Level III PostScript file"
    ${UnRegisterExtension} ".ps3" "Adobe Level III PostScript file"
    ${UnRegisterExtension} ".psd" "Adobe PhotoShop"
    ${UnRegisterExtension} ".psb" "Adobe PhotoShop"
    ${UnRegisterExtension} ".xcf" "Gimp XCF"


    ${If} $RadioButtonAll_State == ${BST_CHECKED}

        WriteRegStr HKCU "Software\PhotoQt" "fileformats" "all"

        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".3fr" "Hasselblad Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".aai" "AAI Dune image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ai" "Adobe Illustrator (PDF compatible)"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ani" "Animated Windows cursors"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".apng" "Animated Portable Network Graphics"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ari" "ARRIFLEX Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".art" "1st Publisher"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".arw" "Sony Digital Camera Alpha Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".asf" "Advanced Systems Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".avif" "AV1 Image File Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".avifs" "AV1 Image File Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".avs" "AVS X image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".x" "AVS X image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mbfavs" "AVS X image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".bay" "Casio Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".bmp" "Microsoft Windows bitmap"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dib" "Microsoft Windows bitmap"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".bpg" "Better Portable Graphics"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cals" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ct1" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ct2" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ct3" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ct4" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".c4" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cal" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".nif" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ras" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cap" "Phase One Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".eip" "Phase One Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".liq" "Phase One Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cb7" "Comic book archive"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cbr" "Comic book archive"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cbt" "Comic book archive"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cbz" "Comic book archive"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cg3" "CCITT Group 3"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".g3" "CCITT Group 3"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".crw" "Canon Digital Camera Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".crr" "Canon Digital Camera Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cr2" "Canon Digital Camera Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cr3" "Canon Digital Camera Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cube" "Cube Color lookup table converted to a HALD image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cur" "Microsoft Windows cursor format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cut" "Dr. Halo"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pal" "Dr. Halo"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dcr" "Kodak Cineon Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".kdc" "Kodak Cineon Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".drf" "Kodak Cineon Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".k25" "Kodak Cineon Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dcs" "Kodak Cineon Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dcx" "ZSoft IBM PC multi-page Paintbrush image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dds" "DirectDraw Surface"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dfont" "Multi-face font package"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dic" "Digital Imaging and Communications in Medicine (DICOM) image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dcm" "Digital Imaging and Communications in Medicine (DICOM) image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".djvu" "DjVu digital document format "
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".djv" "DjVu digital document format "
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dng" "Adobe Digital Negative Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dpx" "Digital Moving Picture Exchange"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".erf" "Epson Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".exr" "OpenEXR"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ff" "farbfeld"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".fits" "Flexible Image Transport System"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".fit" "Flexible Image Transport System"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".fts" "Flexible Image Transport System"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".fl32" "FilmLight floating point image format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ftx" "FAKK 2"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".gif" "Graphics Interchange Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".gpr" "GoPro GPR Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".heif" "High Efficiency Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".heic" "High Efficiency Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".hrz" "Slow-scan television"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".icns" "Apple Icon Image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ico" "Microsoft Windows icon format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".iff" "Interchange File Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jbig" "Joint Bi-level Image experts Group file interchange format (JBIG)"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jbg" "Joint Bi-level Image experts Group file interchange format (JBIG)"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".bie" "Joint Bi-level Image experts Group file interchange format (JBIG)"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jng" "JPEG Network Graphics"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jpeg" "Joint Photographic Experts Group JFIF format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jpg" "Joint Photographic Experts Group JFIF format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jpe" "Joint Photographic Experts Group JFIF format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jif" "Joint Photographic Experts Group JFIF format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jpeg2000" "JPEG-2000"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".j2k" "JPEG-2000"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jp2" "JPEG-2000"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jpc" "JPEG-2000"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jpx" "JPEG-2000"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jxl" "JPEG XL"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jxr" "JPEG-XR"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".hdp" "JPEG-XR"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".wdp" "JPEG-XR"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".koa" "KOALA files"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".gg" "KOALA files"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".gig" "KOALA files"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".kla" "KOALA files"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".kra" "Krita Document"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".lbm" "Interlaced Bitmap"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mat" "MATLAB image format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mdc" "Minolta/Agfa Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mef" "Mamiya Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".miff" "Magick image file format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mif" "Magick image file format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mng" "Multiple-image Network Graphics"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mos" "Leaf Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mpc" "Magick Persistent Cache image file format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mtv" "MTV ray tracer bitmap"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pic" "MTV ray tracer bitmap"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mvg" "Magick Vector Graphics"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".nef" "Nikon Digital SLR Camera Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".nrw" "Nikon Digital SLR Camera Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ora" "OpenRaster"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".orf" "Olympus Digital Camera Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".otb" "On-the-air Bitmap"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".otf" "OpenType font file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".otc" "OpenType font file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ttf" "OpenType font file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ttc" "OpenType font file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".p7" "Xv Visual Schnauzer thumbnail format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".palm" "Palm pixmap"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pam" "Portable Arbitrary Map format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pbm" "Portable bitmap format (black and white)"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pcd" "Photo CD"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pcds" "Photo CD"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pcx" "ZSoft PiCture eXchange"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pdb" "Palm Database ImageViewer Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pef" "Pentax Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ptx" "Pentax Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pes" "Embrid Embroidery Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pfb" "Postscript Type 1 font "
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pfm" "Postscript Type 1 font "
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".afm" "Postscript Type 1 font "
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".inf" "Postscript Type 1 font "
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pfa" "Postscript Type 1 font "
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ofm" "Postscript Type 1 font "
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pfm" "Portable Float Map"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pgm" "Portable graymap format (gray scale)"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pgx" "JPEG 2000 uncompressed format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".phm" "Portable float map format 16-bit half"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pic" "Softimage PIC"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".picon" "Personal Icon"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pict" "QuickDraw/PICT"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pct" "QuickDraw/PICT"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pic" "QuickDraw/PICT"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pix" "Alias/Wavefront RLE image format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".als" "Alias/Wavefront RLE image format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".alias" "Alias/Wavefront RLE image format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".png" "Portable Network Graphics"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ppm" "Portable pixmap format (color)"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pnm" "Portable pixmap format (color)"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ptiff" "Pyramid encoded TIFF"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ptif" "Pyramid encoded TIFF"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pxn" "Logitech Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".qoi" "Quite OK image format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".raf" "Fuji CCD Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".raw" "Leica Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rwl" "Leica Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rgba" "SGI images"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rgb" "SGI images"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".sgi" "SGI images"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".bw" "SGI images"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rgbe" "Radiance RGBE image format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".hdr" "Radiance RGBE image format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rad" "Radiance RGBE image format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rgf" "LEGO Mindstorms EV3 Robot Graphics File"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rla" "Wavefront RLA File Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rle" "Utah Run length encoded image file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rw2" "Panasonic Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".scr" "ZX-Spectrum SCREEN"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".sct" "Scitex Continuous Tone Picture"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ch" "Scitex Continuous Tone Picture"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ct" "Scitex Continuous Tone Picture"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".sfw" "Seattle File Works image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".alb" "Seattle File Works image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pwm" "Seattle File Works image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pwp" "Seattle File Works image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".sixel" "DEC SIXEL Graphics Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".srf" "Sony (Minolta) Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mrw" "Sony (Minolta) Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".sr2" "Sony (Minolta) Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".srw" "Samsung Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".sun" "SUN Rasterfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ras" "SUN Rasterfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".sr" "SUN Rasterfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".im1" "SUN Rasterfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".im24" "SUN Rasterfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".im32" "SUN Rasterfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".im8" "SUN Rasterfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rast" "SUN Rasterfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rs" "SUN Rasterfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".scr" "SUN Rasterfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".svg" "Scalable Vector Graphics"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".svgz" "Scalable Vector Graphics"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".tar" "TAR file format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".tga" "Truevision Targa image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".icb" "Truevision Targa image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".vda" "Truevision Targa image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".vst" "Truevision Targa image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".tiff" "Tagged Image File Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".tif" "Tagged Image File Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".tim" "PSX TIM (PlayStation Graphics)"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ttf" "TrueType font file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".vicar" "VICAR rasterfile format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".vic" "VICAR rasterfile format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".img" "VICAR rasterfile format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".viff" "Khoros Visualization Image File Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".xv" "Khoros Visualization Image File Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".vtf" "Valve Texture Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".wbmp" "Wireless Bitmap"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".webp" "Google web image format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".wmf" "Windows Metafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".wmz" "Windows Metafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".apm" "Windows Metafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".wpg" "Word Perfect Graphics File"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".xbm" "X BitMap"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".bm" "X BitMap"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".xpm" "X PixMap"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pm" "X PixMap"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".xwd" "X Windows system window dump"

        ${If} $CheckboxPdfPs_State == ${BST_CHECKED}

            WriteRegStr HKCU "Software\PhotoQt" "fileformats_pdfps" "registered"

            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".eps" "Encapsulated PostScript"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".epsf" "Encapsulated PostScript"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".epsi" "Encapsulated PostScript"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pdf" "Adobe Portable Document Format"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ps" "Adobe Level III PostScript file"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ps2" "Adobe Level III PostScript file"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ps3" "Adobe Level III PostScript file"

        ${Else}

            ; if it was registered in a previous install, we need to de-register it here
            Var /GLOBAL fileformats_pdfps
            ReadRegStr $fileformats_pdfps HKCU "Software\PhotoQt" "fileformats_pdfps"
            ${If} $fileformats_pdfps == "registered"

                ${UnRegisterExtension} ".eps" "Encapsulated PostScript"
                ${UnRegisterExtension} ".epsf" "Encapsulated PostScript"
                ${UnRegisterExtension} ".epsi" "Encapsulated PostScript"
                ${UnRegisterExtension} ".pdf" "Adobe Portable Document Format"
                ${UnRegisterExtension} ".ps" "Adobe Level III PostScript file"
                ${UnRegisterExtension} ".ps2" "Adobe Level III PostScript file"
                ${UnRegisterExtension} ".ps3" "Adobe Level III PostScript file"

            ${EndIf}

            WriteRegStr HKCU "Software\PhotoQt" "fileformats_pdfps" ""

        ${EndIf}

        ${If} $CheckboxPsdXcf_State == ${BST_CHECKED}

            WriteRegStr HKCU "Software\PhotoQt" "fileformats_psdxcf" "registered"

            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".psd" "Adobe PhotoShop"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".psb" "Adobe PhotoShop"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".xcf" "Gimp XCF"

        ${Else}

            ; if it was registered in a previous install, we need to de-register it here
            Var /GLOBAL fileformats_psdxcf
            ReadRegStr $fileformats_psdxcf HKCU "Software\PhotoQt" "fileformats_psdxcf"
            ${If} $fileformats_psdxcf == "registered"
                ${UnRegisterExtension} ".psd" "Adobe PhotoShop"
                ${UnRegisterExtension} ".psb" "Adobe PhotoShop"
                ${UnRegisterExtension} ".xcf" "Gimp XCF"
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

    WriteRegStr HKLM "${INSTDIR_REG_KEY}" "DisplayIcon" "$INSTDIR\icon.ico"

    System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v (0x08000000, 0, 0, 0)'


    ; Make sure ImageMagick can find all its DLLs
    EnVar::SetHKLM
    EnVar::Delete "PHOTOQT_MAGICK_CODER_MODULE_PATH"
    EnVar::Delete "PHOTOQT_MAGICK_FILTER_MODULE_PATH"
    EnVar::AddValue "PHOTOQT_MAGICK_CODER_MODULE_PATH" "$INSTDIR\imagemagick\coders"
    EnVar::AddValue "PHOTOQT_MAGICK_FILTER_MODULE_PATH" "$INSTDIR\imagemagick\filters"
    ; Make sure that the current process also picks them up (including the 'Open' option at the last installer page)
    System::Call 'Kernel32::SetEnvironmentVariable(t, t) i("PHOTOQT_MAGICK_CODER_MODULE_PATH", "$INSTDIR\imagemagick\coders").r0'
    System::Call 'Kernel32::SetEnvironmentVariable(t, t) i("PHOTOQT_MAGICK_FILTER_MODULE_PATH", "$INSTDIR\imagemagick\filters").r0'

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
        ${UnRegisterExtension} ".3fr" "Hasselblad Raw Image Format"
        ${UnRegisterExtension} ".aai" "AAI Dune image"
        ${UnRegisterExtension} ".ai" "Adobe Illustrator (PDF compatible)"
        ${UnRegisterExtension} ".ani" "Animated Windows cursors"
        ${UnRegisterExtension} ".apng" "Animated Portable Network Graphics"
        ${UnRegisterExtension} ".ari" "ARRIFLEX Raw Image Format"
        ${UnRegisterExtension} ".art" "1st Publisher"
        ${UnRegisterExtension} ".arw" "Sony Digital Camera Alpha Raw Image Format"
        ${UnRegisterExtension} ".asf" "Advanced Systems Format"
        ${UnRegisterExtension} ".avif" "AV1 Image File Format"
        ${UnRegisterExtension} ".avifs" "AV1 Image File Format"
        ${UnRegisterExtension} ".avs" "AVS X image"
        ${UnRegisterExtension} ".x" "AVS X image"
        ${UnRegisterExtension} ".mbfavs" "AVS X image"
        ${UnRegisterExtension} ".bay" "Casio Raw Image Format"
        ${UnRegisterExtension} ".bmp" "Microsoft Windows bitmap"
        ${UnRegisterExtension} ".dib" "Microsoft Windows bitmap"
        ${UnRegisterExtension} ".bpg" "Better Portable Graphics"
        ${UnRegisterExtension} ".cals" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${UnRegisterExtension} ".ct1" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${UnRegisterExtension} ".ct2" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${UnRegisterExtension} ".ct3" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${UnRegisterExtension} ".ct4" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${UnRegisterExtension} ".c4" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${UnRegisterExtension} ".cal" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${UnRegisterExtension} ".nif" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${UnRegisterExtension} ".ras" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${UnRegisterExtension} ".cap" "Phase One Raw Image Format"
        ${UnRegisterExtension} ".eip" "Phase One Raw Image Format"
        ${UnRegisterExtension} ".liq" "Phase One Raw Image Format"
        ${UnRegisterExtension} ".cb7" "Comic book archive"
        ${UnRegisterExtension} ".cbr" "Comic book archive"
        ${UnRegisterExtension} ".cbt" "Comic book archive"
        ${UnRegisterExtension} ".cbz" "Comic book archive"
        ${UnRegisterExtension} ".cg3" "CCITT Group 3"
        ${UnRegisterExtension} ".g3" "CCITT Group 3"
        ${UnRegisterExtension} ".crw" "Canon Digital Camera Raw Image Format"
        ${UnRegisterExtension} ".crr" "Canon Digital Camera Raw Image Format"
        ${UnRegisterExtension} ".cr2" "Canon Digital Camera Raw Image Format"
        ${UnRegisterExtension} ".cr3" "Canon Digital Camera Raw Image Format"
        ${UnRegisterExtension} ".cube" "Cube Color lookup table converted to a HALD image"
        ${UnRegisterExtension} ".cur" "Microsoft Windows cursor format"
        ${UnRegisterExtension} ".cut" "Dr. Halo"
        ${UnRegisterExtension} ".pal" "Dr. Halo"
        ${UnRegisterExtension} ".dcr" "Kodak Cineon Raw Image Format"
        ${UnRegisterExtension} ".kdc" "Kodak Cineon Raw Image Format"
        ${UnRegisterExtension} ".drf" "Kodak Cineon Raw Image Format"
        ${UnRegisterExtension} ".k25" "Kodak Cineon Raw Image Format"
        ${UnRegisterExtension} ".dcs" "Kodak Cineon Raw Image Format"
        ${UnRegisterExtension} ".dcx" "ZSoft IBM PC multi-page Paintbrush image"
        ${UnRegisterExtension} ".dds" "DirectDraw Surface"
        ${UnRegisterExtension} ".dfont" "Multi-face font package"
        ${UnRegisterExtension} ".dic" "Digital Imaging and Communications in Medicine (DICOM) image"
        ${UnRegisterExtension} ".dcm" "Digital Imaging and Communications in Medicine (DICOM) image"
        ${UnRegisterExtension} ".djvu" "DjVu digital document format "
        ${UnRegisterExtension} ".djv" "DjVu digital document format "
        ${UnRegisterExtension} ".dng" "Adobe Digital Negative Raw Image Format"
        ${UnRegisterExtension} ".dpx" "Digital Moving Picture Exchange"
        ${UnRegisterExtension} ".erf" "Epson Raw Image Format"
        ${UnRegisterExtension} ".exr" "OpenEXR"
        ${UnRegisterExtension} ".ff" "farbfeld"
        ${UnRegisterExtension} ".fits" "Flexible Image Transport System"
        ${UnRegisterExtension} ".fit" "Flexible Image Transport System"
        ${UnRegisterExtension} ".fts" "Flexible Image Transport System"
        ${UnRegisterExtension} ".fl32" "FilmLight floating point image format"
        ${UnRegisterExtension} ".ftx" "FAKK 2"
        ${UnRegisterExtension} ".gif" "Graphics Interchange Format"
        ${UnRegisterExtension} ".gpr" "GoPro GPR Raw Image Format"
        ${UnRegisterExtension} ".heif" "High Efficiency Image Format"
        ${UnRegisterExtension} ".heic" "High Efficiency Image Format"
        ${UnRegisterExtension} ".hrz" "Slow-scan television"
        ${UnRegisterExtension} ".icns" "Apple Icon Image"
        ${UnRegisterExtension} ".ico" "Microsoft Windows icon format"
        ${UnRegisterExtension} ".iff" "Interchange File Format"
        ${UnRegisterExtension} ".jbig" "Joint Bi-level Image experts Group file interchange format (JBIG)"
        ${UnRegisterExtension} ".jbg" "Joint Bi-level Image experts Group file interchange format (JBIG)"
        ${UnRegisterExtension} ".bie" "Joint Bi-level Image experts Group file interchange format (JBIG)"
        ${UnRegisterExtension} ".jng" "JPEG Network Graphics"
        ${UnRegisterExtension} ".jpeg" "Joint Photographic Experts Group JFIF format"
        ${UnRegisterExtension} ".jpg" "Joint Photographic Experts Group JFIF format"
        ${UnRegisterExtension} ".jpe" "Joint Photographic Experts Group JFIF format"
        ${UnRegisterExtension} ".jif" "Joint Photographic Experts Group JFIF format"
        ${UnRegisterExtension} ".jpeg2000" "JPEG-2000"
        ${UnRegisterExtension} ".j2k" "JPEG-2000"
        ${UnRegisterExtension} ".jp2" "JPEG-2000"
        ${UnRegisterExtension} ".jpc" "JPEG-2000"
        ${UnRegisterExtension} ".jpx" "JPEG-2000"
        ${UnRegisterExtension} ".jxl" "JPEG XL"
        ${UnRegisterExtension} ".jxr" "JPEG-XR"
        ${UnRegisterExtension} ".hdp" "JPEG-XR"
        ${UnRegisterExtension} ".wdp" "JPEG-XR"
        ${UnRegisterExtension} ".koa" "KOALA files"
        ${UnRegisterExtension} ".gg" "KOALA files"
        ${UnRegisterExtension} ".gig" "KOALA files"
        ${UnRegisterExtension} ".kla" "KOALA files"
        ${UnRegisterExtension} ".kra" "Krita Document"
        ${UnRegisterExtension} ".lbm" "Interlaced Bitmap"
        ${UnRegisterExtension} ".mat" "MATLAB image format"
        ${UnRegisterExtension} ".mdc" "Minolta/Agfa Raw Image Format"
        ${UnRegisterExtension} ".mef" "Mamiya Raw Image Format"
        ${UnRegisterExtension} ".miff" "Magick image file format"
        ${UnRegisterExtension} ".mif" "Magick image file format"
        ${UnRegisterExtension} ".mng" "Multiple-image Network Graphics"
        ${UnRegisterExtension} ".mos" "Leaf Raw Image Format"
        ${UnRegisterExtension} ".mpc" "Magick Persistent Cache image file format"
        ${UnRegisterExtension} ".mtv" "MTV ray tracer bitmap"
        ${UnRegisterExtension} ".pic" "MTV ray tracer bitmap"
        ${UnRegisterExtension} ".mvg" "Magick Vector Graphics"
        ${UnRegisterExtension} ".nef" "Nikon Digital SLR Camera Raw Image Format"
        ${UnRegisterExtension} ".nrw" "Nikon Digital SLR Camera Raw Image Format"
        ${UnRegisterExtension} ".ora" "OpenRaster"
        ${UnRegisterExtension} ".orf" "Olympus Digital Camera Raw Image Format"
        ${UnRegisterExtension} ".otb" "On-the-air Bitmap"
        ${UnRegisterExtension} ".otf" "OpenType font file"
        ${UnRegisterExtension} ".otc" "OpenType font file"
        ${UnRegisterExtension} ".ttf" "OpenType font file"
        ${UnRegisterExtension} ".ttc" "OpenType font file"
        ${UnRegisterExtension} ".p7" "Xv Visual Schnauzer thumbnail format"
        ${UnRegisterExtension} ".palm" "Palm pixmap"
        ${UnRegisterExtension} ".pam" "Portable Arbitrary Map format"
        ${UnRegisterExtension} ".pbm" "Portable bitmap format (black and white)"
        ${UnRegisterExtension} ".pcd" "Photo CD"
        ${UnRegisterExtension} ".pcds" "Photo CD"
        ${UnRegisterExtension} ".pcx" "ZSoft PiCture eXchange"
        ${UnRegisterExtension} ".pdb" "Palm Database ImageViewer Format"
        ${UnRegisterExtension} ".pef" "Pentax Raw Image Format"
        ${UnRegisterExtension} ".ptx" "Pentax Raw Image Format"
        ${UnRegisterExtension} ".pes" "Embrid Embroidery Format"
        ${UnRegisterExtension} ".pfb" "Postscript Type 1 font "
        ${UnRegisterExtension} ".pfm" "Postscript Type 1 font "
        ${UnRegisterExtension} ".afm" "Postscript Type 1 font "
        ${UnRegisterExtension} ".inf" "Postscript Type 1 font "
        ${UnRegisterExtension} ".pfa" "Postscript Type 1 font "
        ${UnRegisterExtension} ".ofm" "Postscript Type 1 font "
        ${UnRegisterExtension} ".pfm" "Portable Float Map"
        ${UnRegisterExtension} ".pgm" "Portable graymap format (gray scale)"
        ${UnRegisterExtension} ".pgx" "JPEG 2000 uncompressed format"
        ${UnRegisterExtension} ".phm" "Portable float map format 16-bit half"
        ${UnRegisterExtension} ".pic" "Softimage PIC"
        ${UnRegisterExtension} ".picon" "Personal Icon"
        ${UnRegisterExtension} ".pict" "QuickDraw/PICT"
        ${UnRegisterExtension} ".pct" "QuickDraw/PICT"
        ${UnRegisterExtension} ".pic" "QuickDraw/PICT"
        ${UnRegisterExtension} ".pix" "Alias/Wavefront RLE image format"
        ${UnRegisterExtension} ".als" "Alias/Wavefront RLE image format"
        ${UnRegisterExtension} ".alias" "Alias/Wavefront RLE image format"
        ${UnRegisterExtension} ".png" "Portable Network Graphics"
        ${UnRegisterExtension} ".ppm" "Portable pixmap format (color)"
        ${UnRegisterExtension} ".pnm" "Portable pixmap format (color)"
        ${UnRegisterExtension} ".ptiff" "Pyramid encoded TIFF"
        ${UnRegisterExtension} ".ptif" "Pyramid encoded TIFF"
        ${UnRegisterExtension} ".pxn" "Logitech Raw Image Format"
        ${UnRegisterExtension} ".qoi" "Quite OK image format"
        ${UnRegisterExtension} ".raf" "Fuji CCD Raw Image Format"
        ${UnRegisterExtension} ".raw" "Leica Raw Image Format"
        ${UnRegisterExtension} ".rwl" "Leica Raw Image Format"
        ${UnRegisterExtension} ".rgba" "SGI images"
        ${UnRegisterExtension} ".rgb" "SGI images"
        ${UnRegisterExtension} ".sgi" "SGI images"
        ${UnRegisterExtension} ".bw" "SGI images"
        ${UnRegisterExtension} ".rgbe" "Radiance RGBE image format"
        ${UnRegisterExtension} ".hdr" "Radiance RGBE image format"
        ${UnRegisterExtension} ".rad" "Radiance RGBE image format"
        ${UnRegisterExtension} ".rgf" "LEGO Mindstorms EV3 Robot Graphics File"
        ${UnRegisterExtension} ".rla" "Wavefront RLA File Format"
        ${UnRegisterExtension} ".rle" "Utah Run length encoded image file"
        ${UnRegisterExtension} ".rw2" "Panasonic Raw Image Format"
        ${UnRegisterExtension} ".scr" "ZX-Spectrum SCREEN"
        ${UnRegisterExtension} ".sct" "Scitex Continuous Tone Picture"
        ${UnRegisterExtension} ".ch" "Scitex Continuous Tone Picture"
        ${UnRegisterExtension} ".ct" "Scitex Continuous Tone Picture"
        ${UnRegisterExtension} ".sfw" "Seattle File Works image"
        ${UnRegisterExtension} ".alb" "Seattle File Works image"
        ${UnRegisterExtension} ".pwm" "Seattle File Works image"
        ${UnRegisterExtension} ".pwp" "Seattle File Works image"
        ${UnRegisterExtension} ".sixel" "DEC SIXEL Graphics Format"
        ${UnRegisterExtension} ".srf" "Sony (Minolta) Raw Image Format"
        ${UnRegisterExtension} ".mrw" "Sony (Minolta) Raw Image Format"
        ${UnRegisterExtension} ".sr2" "Sony (Minolta) Raw Image Format"
        ${UnRegisterExtension} ".srw" "Samsung Raw Image Format"
        ${UnRegisterExtension} ".sun" "SUN Rasterfile"
        ${UnRegisterExtension} ".ras" "SUN Rasterfile"
        ${UnRegisterExtension} ".sr" "SUN Rasterfile"
        ${UnRegisterExtension} ".im1" "SUN Rasterfile"
        ${UnRegisterExtension} ".im24" "SUN Rasterfile"
        ${UnRegisterExtension} ".im32" "SUN Rasterfile"
        ${UnRegisterExtension} ".im8" "SUN Rasterfile"
        ${UnRegisterExtension} ".rast" "SUN Rasterfile"
        ${UnRegisterExtension} ".rs" "SUN Rasterfile"
        ${UnRegisterExtension} ".scr" "SUN Rasterfile"
        ${UnRegisterExtension} ".svg" "Scalable Vector Graphics"
        ${UnRegisterExtension} ".svgz" "Scalable Vector Graphics"
        ${UnRegisterExtension} ".tar" "TAR file format"
        ${UnRegisterExtension} ".tga" "Truevision Targa image"
        ${UnRegisterExtension} ".icb" "Truevision Targa image"
        ${UnRegisterExtension} ".vda" "Truevision Targa image"
        ${UnRegisterExtension} ".vst" "Truevision Targa image"
        ${UnRegisterExtension} ".tiff" "Tagged Image File Format"
        ${UnRegisterExtension} ".tif" "Tagged Image File Format"
        ${UnRegisterExtension} ".tim" "PSX TIM (PlayStation Graphics)"
        ${UnRegisterExtension} ".ttf" "TrueType font file"
        ${UnRegisterExtension} ".vicar" "VICAR rasterfile format"
        ${UnRegisterExtension} ".vic" "VICAR rasterfile format"
        ${UnRegisterExtension} ".img" "VICAR rasterfile format"
        ${UnRegisterExtension} ".viff" "Khoros Visualization Image File Format"
        ${UnRegisterExtension} ".xv" "Khoros Visualization Image File Format"
        ${UnRegisterExtension} ".vtf" "Valve Texture Format"
        ${UnRegisterExtension} ".wbmp" "Wireless Bitmap"
        ${UnRegisterExtension} ".webp" "Google web image format"
        ${UnRegisterExtension} ".wmf" "Windows Metafile"
        ${UnRegisterExtension} ".wmz" "Windows Metafile"
        ${UnRegisterExtension} ".apm" "Windows Metafile"
        ${UnRegisterExtension} ".wpg" "Word Perfect Graphics File"
        ${UnRegisterExtension} ".xbm" "X BitMap"
        ${UnRegisterExtension} ".bm" "X BitMap"
        ${UnRegisterExtension} ".xpm" "X PixMap"
        ${UnRegisterExtension} ".pm" "X PixMap"
        ${UnRegisterExtension} ".xwd" "X Windows system window dump"

        WriteRegStr HKCU "Software\PhotoQt" "fileformats" ""

    ${EndIf}

    ${If} $un_fileformats_pdfps == "registered"

        ${UnRegisterExtension} ".eps" "Encapsulated PostScript"
        ${UnRegisterExtension} ".epsf" "Encapsulated PostScript"
        ${UnRegisterExtension} ".epsi" "Encapsulated PostScript"
        ${UnRegisterExtension} ".pdf" "Adobe Portable Document Format"
        ${UnRegisterExtension} ".ps" "Adobe Level III PostScript file"
        ${UnRegisterExtension} ".ps2" "Adobe Level III PostScript file"
        ${UnRegisterExtension} ".ps3" "Adobe Level III PostScript file"

        WriteRegStr HKCU "Software\PhotoQt" "fileformats_pdfps" ""

    ${EndIf}

    ${If} $un_fileformats_psdxcf == "registered"

        ${UnRegisterExtension} ".psd" "Adobe PhotoShop"
        ${UnRegisterExtension} ".psb" "Adobe PhotoShop"
        ${UnRegisterExtension} ".xcf" "Gimp XCF"

        WriteRegStr HKCU "Software\PhotoQt" "fileformats_psdxcf" ""

    ${EndIf}

    SetShellVarContext all
    Delete "$SMPROGRAMS\PhotoQt.lnk"
    Delete "$desktop\PhotoQt.lnk"

    ;begin uninstall
    !insertmacro UNINSTALL.NEW_UNINSTALL "$OUTDIR"
    
    DeleteRegKey ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}"

    ; Remove environment variables
    EnVar::Delete "PHOTOQT_MAGICK_CODER_MODULE_PATH"
    EnVar::Delete "PHOTOQT_MAGICK_FILTER_MODULE_PATH"

    System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v (0x08000000, 0, 0, 0)'

SectionEnd
