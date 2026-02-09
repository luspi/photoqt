;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Copyright (C) 2011-2026 Lukas Spies
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
; - the windows/filetypes folder from the source tree
;
; In addition the EnVar plugin needs to be installed for NSIS:
; https://nsis.sourceforge.io/EnVar_plug-in
;
; This will then create a new file in the application directory
; called photoqt-xxx.exe where xxx is the version number specified below.
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

!define PHOTOQT_VERSION "xxx"

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

    ; The file associations change over time. First we remove the old ones.
    ${UnRegisterExtension} "3fr" "3frfile"
    ${UnRegisterExtension} "fff" "ffffile"
    ${UnRegisterExtension} "aai" "aaifile"
    ${UnRegisterExtension} "ai" "aifile"
    ${UnRegisterExtension} "ani" "anifile"
    ${UnRegisterExtension} "apng" "apngfile"
    ${UnRegisterExtension} "ari" "arifile"
    ${UnRegisterExtension} "art" "artfile"
    ${UnRegisterExtension} "arw" "arwfile"
    ${UnRegisterExtension} "asf" "asffile"
    ${UnRegisterExtension} "avif" "aviffile"
    ${UnRegisterExtension} "avifs" "avifsfile"
    ${UnRegisterExtension} "avs" "avsfile"
    ${UnRegisterExtension} "x" "xfile"
    ${UnRegisterExtension} "mbfavs" "mbfavsfile"
    ${UnRegisterExtension} "bay" "bayfile"
    ${UnRegisterExtension} "bmp" "bmpfile"
    ${UnRegisterExtension} "dib" "dibfile"
    ${UnRegisterExtension} "bmq" "bmqfile"
    ${UnRegisterExtension} "bpg" "bpgfile"
    ${UnRegisterExtension} "cals" "calsfile"
    ${UnRegisterExtension} "ct1" "ct1file"
    ${UnRegisterExtension} "ct2" "ct2file"
    ${UnRegisterExtension} "ct3" "ct3file"
    ${UnRegisterExtension} "ct4" "ct4file"
    ${UnRegisterExtension} "c4" "c4file"
    ${UnRegisterExtension} "cal" "calfile"
    ${UnRegisterExtension} "nif" "niffile"
    ${UnRegisterExtension} "ras" "rasfile"
    ${UnRegisterExtension} "cap" "capfile"
    ${UnRegisterExtension} "eip" "eipfile"
    ${UnRegisterExtension} "liq" "liqfile"
    ${UnRegisterExtension} "iiq" "iiqfile"
    ${UnRegisterExtension} "cb7" "cb7file"
    ${UnRegisterExtension} "cbr" "cbrfile"
    ${UnRegisterExtension} "cbt" "cbtfile"
    ${UnRegisterExtension} "cbz" "cbzfile"
    ${UnRegisterExtension} "cg3" "cg3file"
    ${UnRegisterExtension} "g3" "g3file"
    ${UnRegisterExtension} "cine" "cinefile"
    ${UnRegisterExtension} "crw" "crwfile"
    ${UnRegisterExtension} "crr" "crrfile"
    ${UnRegisterExtension} "cr2" "cr2file"
    ${UnRegisterExtension} "cr3" "cr3file"
    ${UnRegisterExtension} "cs1" "cs1file"
    ${UnRegisterExtension} "cube" "cubefile"
    ${UnRegisterExtension} "cur" "curfile"
    ${UnRegisterExtension} "cut" "cutfile"
    ${UnRegisterExtension} "pal" "palfile"
    ${UnRegisterExtension} "dcr" "dcrfile"
    ${UnRegisterExtension} "kdc" "kdcfile"
    ${UnRegisterExtension} "drf" "drffile"
    ${UnRegisterExtension} "k25" "k25file"
    ${UnRegisterExtension} "dcs" "dcsfile"
    ${UnRegisterExtension} "dc2" "dc2file"
    ${UnRegisterExtension} "kc2" "kc2file"
    ${UnRegisterExtension} "dcx" "dcxfile"
    ${UnRegisterExtension} "dds" "ddsfile"
    ${UnRegisterExtension} "dfont" "dfontfile"
    ${UnRegisterExtension} "dic" "dicfile"
    ${UnRegisterExtension} "dcm" "dcmfile"
    ${UnRegisterExtension} "djvu" "djvufile"
    ${UnRegisterExtension} "djv" "djvfile"
    ${UnRegisterExtension} "dng" "dngfile"
    ${UnRegisterExtension} "dpx" "dpxfile"
    ${UnRegisterExtension} "dxo" "dxofile"
    ${UnRegisterExtension} "erf" "erffile"
    ${UnRegisterExtension} "exr" "exrfile"
    ${UnRegisterExtension} "ff" "fffile"
    ${UnRegisterExtension} "fits" "fitsfile"
    ${UnRegisterExtension} "fit" "fitfile"
    ${UnRegisterExtension} "fts" "ftsfile"
    ${UnRegisterExtension} "fl32" "fl32file"
    ${UnRegisterExtension} "ftx" "ftxfile"
    ${UnRegisterExtension} "gif" "giffile"
    ${UnRegisterExtension} "gpr" "gprfile"
    ${UnRegisterExtension} "heif" "heiffile"
    ${UnRegisterExtension} "heic" "heicfile"
    ${UnRegisterExtension} "hrz" "hrzfile"
    ${UnRegisterExtension} "icns" "icnsfile"
    ${UnRegisterExtension} "ico" "icofile"
    ${UnRegisterExtension} "iff" "ifffile"
    ${UnRegisterExtension} "jbig" "jbigfile"
    ${UnRegisterExtension} "jbg" "jbgfile"
    ${UnRegisterExtension} "bie" "biefile"
    ${UnRegisterExtension} "jfif" "jfiffile"
    ${UnRegisterExtension} "jng" "jngfile"
    ${UnRegisterExtension} "jpeg" "jpegfile"
    ${UnRegisterExtension} "jpg" "jpgfile"
    ${UnRegisterExtension} "jpe" "jpefile"
    ${UnRegisterExtension} "jif" "jiffile"
    ${UnRegisterExtension} "jpeg2000" "jpeg2000file"
    ${UnRegisterExtension} "j2k" "j2kfile"
    ${UnRegisterExtension} "jp2" "jp2file"
    ${UnRegisterExtension} "jpc" "jpcfile"
    ${UnRegisterExtension} "jpx" "jpxfile"
    ${UnRegisterExtension} "jxl" "jxlfile"
    ${UnRegisterExtension} "jxr" "jxrfile"
    ${UnRegisterExtension} "hdp" "hdpfile"
    ${UnRegisterExtension} "wdp" "wdpfile"
    ${UnRegisterExtension} "koa" "koafile"
    ${UnRegisterExtension} "gg" "ggfile"
    ${UnRegisterExtension} "gig" "gigfile"
    ${UnRegisterExtension} "kla" "klafile"
    ${UnRegisterExtension} "kra" "krafile"
    ${UnRegisterExtension} "lbm" "lbmfile"
    ${UnRegisterExtension} "mat" "matfile"
    ${UnRegisterExtension} "mdc" "mdcfile"
    ${UnRegisterExtension} "mef" "meffile"
    ${UnRegisterExtension} "mfw" "mfwfile"
    ${UnRegisterExtension} "miff" "mifffile"
    ${UnRegisterExtension} "mif" "miffile"
    ${UnRegisterExtension} "mng" "mngfile"
    ${UnRegisterExtension} "mos" "mosfile"
    ${UnRegisterExtension} "mpc" "mpcfile"
    ${UnRegisterExtension} "mtv" "mtvfile"
    ${UnRegisterExtension} "pic" "picfile"
    ${UnRegisterExtension} "mvg" "mvgfile"
    ${UnRegisterExtension} "nef" "neffile"
    ${UnRegisterExtension} "nrw" "nrwfile"
    ${UnRegisterExtension} "obm" "obmfile"
    ${UnRegisterExtension} "ora" "orafile"
    ${UnRegisterExtension} "orf" "orffile"
    ${UnRegisterExtension} "ori" "orifile"
    ${UnRegisterExtension} "otb" "otbfile"
    ${UnRegisterExtension} "otf" "otffile"
    ${UnRegisterExtension} "otc" "otcfile"
    ${UnRegisterExtension} "ttf" "ttffile"
    ${UnRegisterExtension} "ttc" "ttcfile"
    ${UnRegisterExtension} "p7" "p7file"
    ${UnRegisterExtension} "palm" "palmfile"
    ${UnRegisterExtension} "pam" "pamfile"
    ${UnRegisterExtension} "pbm" "pbmfile"
    ${UnRegisterExtension} "pcd" "pcdfile"
    ${UnRegisterExtension} "pcds" "pcdsfile"
    ${UnRegisterExtension} "pcx" "pcxfile"
    ${UnRegisterExtension} "pdb" "pdbfile"
    ${UnRegisterExtension} "pdd" "pddfile"
    ${UnRegisterExtension} "pef" "peffile"
    ${UnRegisterExtension} "ptx" "ptxfile"
    ${UnRegisterExtension} "pes" "pesfile"
    ${UnRegisterExtension} "pfb" "pfbfile"
    ${UnRegisterExtension} "pfm" "pfmfile"
    ${UnRegisterExtension} "afm" "afmfile"
    ${UnRegisterExtension} "inf" "inffile"
    ${UnRegisterExtension} "pfa" "pfafile"
    ${UnRegisterExtension} "ofm" "ofmfile"
    ${UnRegisterExtension} "pfm" "pfmfile"
    ${UnRegisterExtension} "pgm" "pgmfile"
    ${UnRegisterExtension} "pgx" "pgxfile"
    ${UnRegisterExtension} "phm" "phmfile"
    ${UnRegisterExtension} "pic" "picfile"
    ${UnRegisterExtension} "picon" "piconfile"
    ${UnRegisterExtension} "pict" "pictfile"
    ${UnRegisterExtension} "pct" "pctfile"
    ${UnRegisterExtension} "pic" "picfile"
    ${UnRegisterExtension} "pix" "pixfile"
    ${UnRegisterExtension} "als" "alsfile"
    ${UnRegisterExtension} "alias" "aliasfile"
    ${UnRegisterExtension} "png" "pngfile"
    ${UnRegisterExtension} "ppm" "ppmfile"
    ${UnRegisterExtension} "pnm" "pnmfile"
    ${UnRegisterExtension} "ptiff" "ptifffile"
    ${UnRegisterExtension} "ptif" "ptiffile"
    ${UnRegisterExtension} "pxn" "pxnfile"
    ${UnRegisterExtension} "pxr" "pxrfile"
    ${UnRegisterExtension} "qoi" "qoifile"
    ${UnRegisterExtension} "qtk" "qtkfile"
    ${UnRegisterExtension} "r3d" "r3dfile"
    ${UnRegisterExtension} "raf" "raffile"
    ${UnRegisterExtension} "raw" "rawfile"
    ${UnRegisterExtension} "rwl" "rwlfile"
    ${UnRegisterExtension} "rdc" "rdcfile"
    ${UnRegisterExtension} "rgba" "rgbafile"
    ${UnRegisterExtension} "rgb" "rgbfile"
    ${UnRegisterExtension} "sgi" "sgifile"
    ${UnRegisterExtension} "bw" "bwfile"
    ${UnRegisterExtension} "rgbe" "rgbefile"
    ${UnRegisterExtension} "hdr" "hdrfile"
    ${UnRegisterExtension} "rad" "radfile"
    ${UnRegisterExtension} "rgf" "rgffile"
    ${UnRegisterExtension} "rla" "rlafile"
    ${UnRegisterExtension} "rle" "rlefile"
    ${UnRegisterExtension} "rw2" "rw2file"
    ${UnRegisterExtension} "rwz" "rwzfile"
    ${UnRegisterExtension} "scr" "scrfile"
    ${UnRegisterExtension} "sct" "sctfile"
    ${UnRegisterExtension} "ch" "chfile"
    ${UnRegisterExtension} "ct" "ctfile"
    ${UnRegisterExtension} "sfw" "sfwfile"
    ${UnRegisterExtension} "alb" "albfile"
    ${UnRegisterExtension} "pwm" "pwmfile"
    ${UnRegisterExtension} "pwp" "pwpfile"
    ${UnRegisterExtension} "sixel" "sixelfile"
    ${UnRegisterExtension} "srf" "srffile"
    ${UnRegisterExtension} "mrw" "mrwfile"
    ${UnRegisterExtension} "sr2" "sr2file"
    ${UnRegisterExtension} "arq" "arqfile"
    ${UnRegisterExtension} "srw" "srwfile"
    ${UnRegisterExtension} "sti" "stifile"
    ${UnRegisterExtension} "sun" "sunfile"
    ${UnRegisterExtension} "ras" "rasfile"
    ${UnRegisterExtension} "sr" "srfile"
    ${UnRegisterExtension} "im1" "im1file"
    ${UnRegisterExtension} "im24" "im24file"
    ${UnRegisterExtension} "im32" "im32file"
    ${UnRegisterExtension} "im8" "im8file"
    ${UnRegisterExtension} "rast" "rastfile"
    ${UnRegisterExtension} "rs" "rsfile"
    ${UnRegisterExtension} "scr" "scrfile"
    ${UnRegisterExtension} "svg" "svgfile"
    ${UnRegisterExtension} "svgz" "svgzfile"
    ${UnRegisterExtension} "tar" "tarfile"
    ${UnRegisterExtension} "tga" "tgafile"
    ${UnRegisterExtension} "icb" "icbfile"
    ${UnRegisterExtension} "vda" "vdafile"
    ${UnRegisterExtension} "vst" "vstfile"
    ${UnRegisterExtension} "tiff" "tifffile"
    ${UnRegisterExtension} "tif" "tiffile"
    ${UnRegisterExtension} "tim" "timfile"
    ${UnRegisterExtension} "ttf" "ttffile"
    ${UnRegisterExtension} "vicar" "vicarfile"
    ${UnRegisterExtension} "vic" "vicfile"
    ${UnRegisterExtension} "img" "imgfile"
    ${UnRegisterExtension} "viff" "vifffile"
    ${UnRegisterExtension} "xv" "xvfile"
    ${UnRegisterExtension} "vtf" "vtffile"
    ${UnRegisterExtension} "wbmp" "wbmpfile"
    ${UnRegisterExtension} "webp" "webpfile"
    ${UnRegisterExtension} "wmf" "wmffile"
    ${UnRegisterExtension} "wmz" "wmzfile"
    ${UnRegisterExtension} "apm" "apmfile"
    ${UnRegisterExtension} "wpg" "wpgfile"
    ${UnRegisterExtension} "x3f" "x3ffile"
    ${UnRegisterExtension} "xbm" "xbmfile"
    ${UnRegisterExtension} "bm" "bmfile"
    ${UnRegisterExtension} "xpm" "xpmfile"
    ${UnRegisterExtension} "pm" "pmfile"
    ${UnRegisterExtension} "xwd" "xwdfile"
    ${UnRegisterExtension} "eps" "epsfile"
    ${UnRegisterExtension} "epsf" "epsffile"
    ${UnRegisterExtension} "epsi" "epsifile"
    ${UnRegisterExtension} "pdf" "pdffile"
    ${UnRegisterExtension} "ps" "psfile"
    ${UnRegisterExtension} "ps2" "ps2file"
    ${UnRegisterExtension} "ps3" "ps3file"
    ${UnRegisterExtension} "psd" "psdfile"
    ${UnRegisterExtension} "psb" "psbfile"
    ${UnRegisterExtension} "psdt" "psdtfile"
    ${UnRegisterExtension} "xcf" "xcffile"

    ${UnRegisterExtensionOld} "3fr" "3frfile"
    ${UnRegisterExtensionOld} "fff" "ffffile"
    ${UnRegisterExtensionOld} "aai" "aaifile"
    ${UnRegisterExtensionOld} "ai" "aifile"
    ${UnRegisterExtensionOld} "ani" "anifile"
    ${UnRegisterExtensionOld} "apng" "apngfile"
    ${UnRegisterExtensionOld} "ari" "arifile"
    ${UnRegisterExtensionOld} "art" "artfile"
    ${UnRegisterExtensionOld} "arw" "arwfile"
    ${UnRegisterExtensionOld} "asf" "asffile"
    ${UnRegisterExtensionOld} "avif" "aviffile"
    ${UnRegisterExtensionOld} "avifs" "avifsfile"
    ${UnRegisterExtensionOld} "avs" "avsfile"
    ${UnRegisterExtensionOld} "x" "xfile"
    ${UnRegisterExtensionOld} "mbfavs" "mbfavsfile"
    ${UnRegisterExtensionOld} "bay" "bayfile"
    ${UnRegisterExtensionOld} "bmp" "bmpfile"
    ${UnRegisterExtensionOld} "dib" "dibfile"
    ${UnRegisterExtensionOld} "bmq" "bmqfile"
    ${UnRegisterExtensionOld} "bpg" "bpgfile"
    ${UnRegisterExtensionOld} "cals" "calsfile"
    ${UnRegisterExtensionOld} "ct1" "ct1file"
    ${UnRegisterExtensionOld} "ct2" "ct2file"
    ${UnRegisterExtensionOld} "ct3" "ct3file"
    ${UnRegisterExtensionOld} "ct4" "ct4file"
    ${UnRegisterExtensionOld} "c4" "c4file"
    ${UnRegisterExtensionOld} "cal" "calfile"
    ${UnRegisterExtensionOld} "nif" "niffile"
    ${UnRegisterExtensionOld} "ras" "rasfile"
    ${UnRegisterExtensionOld} "cap" "capfile"
    ${UnRegisterExtensionOld} "eip" "eipfile"
    ${UnRegisterExtensionOld} "liq" "liqfile"
    ${UnRegisterExtensionOld} "iiq" "iiqfile"
    ${UnRegisterExtensionOld} "cb7" "cb7file"
    ${UnRegisterExtensionOld} "cbr" "cbrfile"
    ${UnRegisterExtensionOld} "cbt" "cbtfile"
    ${UnRegisterExtensionOld} "cbz" "cbzfile"
    ${UnRegisterExtensionOld} "cg3" "cg3file"
    ${UnRegisterExtensionOld} "g3" "g3file"
    ${UnRegisterExtensionOld} "cine" "cinefile"
    ${UnRegisterExtensionOld} "crw" "crwfile"
    ${UnRegisterExtensionOld} "crr" "crrfile"
    ${UnRegisterExtensionOld} "cr2" "cr2file"
    ${UnRegisterExtensionOld} "cr3" "cr3file"
    ${UnRegisterExtensionOld} "cs1" "cs1file"
    ${UnRegisterExtensionOld} "cube" "cubefile"
    ${UnRegisterExtensionOld} "cur" "curfile"
    ${UnRegisterExtensionOld} "cut" "cutfile"
    ${UnRegisterExtensionOld} "pal" "palfile"
    ${UnRegisterExtensionOld} "dcr" "dcrfile"
    ${UnRegisterExtensionOld} "kdc" "kdcfile"
    ${UnRegisterExtensionOld} "drf" "drffile"
    ${UnRegisterExtensionOld} "k25" "k25file"
    ${UnRegisterExtensionOld} "dcs" "dcsfile"
    ${UnRegisterExtensionOld} "dc2" "dc2file"
    ${UnRegisterExtensionOld} "kc2" "kc2file"
    ${UnRegisterExtensionOld} "dcx" "dcxfile"
    ${UnRegisterExtensionOld} "dds" "ddsfile"
    ${UnRegisterExtensionOld} "dfont" "dfontfile"
    ${UnRegisterExtensionOld} "dic" "dicfile"
    ${UnRegisterExtensionOld} "dcm" "dcmfile"
    ${UnRegisterExtensionOld} "djvu" "djvufile"
    ${UnRegisterExtensionOld} "djv" "djvfile"
    ${UnRegisterExtensionOld} "dng" "dngfile"
    ${UnRegisterExtensionOld} "dpx" "dpxfile"
    ${UnRegisterExtensionOld} "dxo" "dxofile"
    ${UnRegisterExtensionOld} "erf" "erffile"
    ${UnRegisterExtensionOld} "exr" "exrfile"
    ${UnRegisterExtensionOld} "ff" "fffile"
    ${UnRegisterExtensionOld} "fits" "fitsfile"
    ${UnRegisterExtensionOld} "fit" "fitfile"
    ${UnRegisterExtensionOld} "fts" "ftsfile"
    ${UnRegisterExtensionOld} "fl32" "fl32file"
    ${UnRegisterExtensionOld} "ftx" "ftxfile"
    ${UnRegisterExtensionOld} "gif" "giffile"
    ${UnRegisterExtensionOld} "gpr" "gprfile"
    ${UnRegisterExtensionOld} "heif" "heiffile"
    ${UnRegisterExtensionOld} "heic" "heicfile"
    ${UnRegisterExtensionOld} "hrz" "hrzfile"
    ${UnRegisterExtensionOld} "icns" "icnsfile"
    ${UnRegisterExtensionOld} "ico" "icofile"
    ${UnRegisterExtensionOld} "iff" "ifffile"
    ${UnRegisterExtensionOld} "jbig" "jbigfile"
    ${UnRegisterExtensionOld} "jbg" "jbgfile"
    ${UnRegisterExtensionOld} "bie" "biefile"
    ${UnRegisterExtensionOld} "jfif" "jfiffile"
    ${UnRegisterExtensionOld} "jng" "jngfile"
    ${UnRegisterExtensionOld} "jpeg" "jpegfile"
    ${UnRegisterExtensionOld} "jpg" "jpgfile"
    ${UnRegisterExtensionOld} "jpe" "jpefile"
    ${UnRegisterExtensionOld} "jif" "jiffile"
    ${UnRegisterExtensionOld} "jpeg2000" "jpeg2000file"
    ${UnRegisterExtensionOld} "j2k" "j2kfile"
    ${UnRegisterExtensionOld} "jp2" "jp2file"
    ${UnRegisterExtensionOld} "jpc" "jpcfile"
    ${UnRegisterExtensionOld} "jpx" "jpxfile"
    ${UnRegisterExtensionOld} "jxl" "jxlfile"
    ${UnRegisterExtensionOld} "jxr" "jxrfile"
    ${UnRegisterExtensionOld} "hdp" "hdpfile"
    ${UnRegisterExtensionOld} "wdp" "wdpfile"
    ${UnRegisterExtensionOld} "koa" "koafile"
    ${UnRegisterExtensionOld} "gg" "ggfile"
    ${UnRegisterExtensionOld} "gig" "gigfile"
    ${UnRegisterExtensionOld} "kla" "klafile"
    ${UnRegisterExtensionOld} "kra" "krafile"
    ${UnRegisterExtensionOld} "lbm" "lbmfile"
    ${UnRegisterExtensionOld} "mat" "matfile"
    ${UnRegisterExtensionOld} "mdc" "mdcfile"
    ${UnRegisterExtensionOld} "mef" "meffile"
    ${UnRegisterExtensionOld} "mfw" "mfwfile"
    ${UnRegisterExtensionOld} "miff" "mifffile"
    ${UnRegisterExtensionOld} "mif" "miffile"
    ${UnRegisterExtensionOld} "mng" "mngfile"
    ${UnRegisterExtensionOld} "mos" "mosfile"
    ${UnRegisterExtensionOld} "mpc" "mpcfile"
    ${UnRegisterExtensionOld} "mtv" "mtvfile"
    ${UnRegisterExtensionOld} "pic" "picfile"
    ${UnRegisterExtensionOld} "mvg" "mvgfile"
    ${UnRegisterExtensionOld} "nef" "neffile"
    ${UnRegisterExtensionOld} "nrw" "nrwfile"
    ${UnRegisterExtensionOld} "obm" "obmfile"
    ${UnRegisterExtensionOld} "ora" "orafile"
    ${UnRegisterExtensionOld} "orf" "orffile"
    ${UnRegisterExtensionOld} "ori" "orifile"
    ${UnRegisterExtensionOld} "otb" "otbfile"
    ${UnRegisterExtensionOld} "otf" "otffile"
    ${UnRegisterExtensionOld} "otc" "otcfile"
    ${UnRegisterExtensionOld} "ttf" "ttffile"
    ${UnRegisterExtensionOld} "ttc" "ttcfile"
    ${UnRegisterExtensionOld} "p7" "p7file"
    ${UnRegisterExtensionOld} "palm" "palmfile"
    ${UnRegisterExtensionOld} "pam" "pamfile"
    ${UnRegisterExtensionOld} "pbm" "pbmfile"
    ${UnRegisterExtensionOld} "pcd" "pcdfile"
    ${UnRegisterExtensionOld} "pcds" "pcdsfile"
    ${UnRegisterExtensionOld} "pcx" "pcxfile"
    ${UnRegisterExtensionOld} "pdb" "pdbfile"
    ${UnRegisterExtensionOld} "pdd" "pddfile"
    ${UnRegisterExtensionOld} "pef" "peffile"
    ${UnRegisterExtensionOld} "ptx" "ptxfile"
    ${UnRegisterExtensionOld} "pes" "pesfile"
    ${UnRegisterExtensionOld} "pfb" "pfbfile"
    ${UnRegisterExtensionOld} "pfm" "pfmfile"
    ${UnRegisterExtensionOld} "afm" "afmfile"
    ${UnRegisterExtensionOld} "inf" "inffile"
    ${UnRegisterExtensionOld} "pfa" "pfafile"
    ${UnRegisterExtensionOld} "ofm" "ofmfile"
    ${UnRegisterExtensionOld} "pfm" "pfmfile"
    ${UnRegisterExtensionOld} "pgm" "pgmfile"
    ${UnRegisterExtensionOld} "pgx" "pgxfile"
    ${UnRegisterExtensionOld} "phm" "phmfile"
    ${UnRegisterExtensionOld} "pic" "picfile"
    ${UnRegisterExtensionOld} "picon" "piconfile"
    ${UnRegisterExtensionOld} "pict" "pictfile"
    ${UnRegisterExtensionOld} "pct" "pctfile"
    ${UnRegisterExtensionOld} "pic" "picfile"
    ${UnRegisterExtensionOld} "pix" "pixfile"
    ${UnRegisterExtensionOld} "als" "alsfile"
    ${UnRegisterExtensionOld} "alias" "aliasfile"
    ${UnRegisterExtensionOld} "png" "pngfile"
    ${UnRegisterExtensionOld} "ppm" "ppmfile"
    ${UnRegisterExtensionOld} "pnm" "pnmfile"
    ${UnRegisterExtensionOld} "ptiff" "ptifffile"
    ${UnRegisterExtensionOld} "ptif" "ptiffile"
    ${UnRegisterExtensionOld} "pxn" "pxnfile"
    ${UnRegisterExtensionOld} "pxr" "pxrfile"
    ${UnRegisterExtensionOld} "qoi" "qoifile"
    ${UnRegisterExtensionOld} "qtk" "qtkfile"
    ${UnRegisterExtensionOld} "r3d" "r3dfile"
    ${UnRegisterExtensionOld} "raf" "raffile"
    ${UnRegisterExtensionOld} "raw" "rawfile"
    ${UnRegisterExtensionOld} "rwl" "rwlfile"
    ${UnRegisterExtensionOld} "rdc" "rdcfile"
    ${UnRegisterExtensionOld} "rgba" "rgbafile"
    ${UnRegisterExtensionOld} "rgb" "rgbfile"
    ${UnRegisterExtensionOld} "sgi" "sgifile"
    ${UnRegisterExtensionOld} "bw" "bwfile"
    ${UnRegisterExtensionOld} "rgbe" "rgbefile"
    ${UnRegisterExtensionOld} "hdr" "hdrfile"
    ${UnRegisterExtensionOld} "rad" "radfile"
    ${UnRegisterExtensionOld} "rgf" "rgffile"
    ${UnRegisterExtensionOld} "rla" "rlafile"
    ${UnRegisterExtensionOld} "rle" "rlefile"
    ${UnRegisterExtensionOld} "rw2" "rw2file"
    ${UnRegisterExtensionOld} "rwz" "rwzfile"
    ${UnRegisterExtensionOld} "scr" "scrfile"
    ${UnRegisterExtensionOld} "sct" "sctfile"
    ${UnRegisterExtensionOld} "ch" "chfile"
    ${UnRegisterExtensionOld} "ct" "ctfile"
    ${UnRegisterExtensionOld} "sfw" "sfwfile"
    ${UnRegisterExtensionOld} "alb" "albfile"
    ${UnRegisterExtensionOld} "pwm" "pwmfile"
    ${UnRegisterExtensionOld} "pwp" "pwpfile"
    ${UnRegisterExtensionOld} "sixel" "sixelfile"
    ${UnRegisterExtensionOld} "srf" "srffile"
    ${UnRegisterExtensionOld} "mrw" "mrwfile"
    ${UnRegisterExtensionOld} "sr2" "sr2file"
    ${UnRegisterExtensionOld} "arq" "arqfile"
    ${UnRegisterExtensionOld} "srw" "srwfile"
    ${UnRegisterExtensionOld} "sti" "stifile"
    ${UnRegisterExtensionOld} "sun" "sunfile"
    ${UnRegisterExtensionOld} "ras" "rasfile"
    ${UnRegisterExtensionOld} "sr" "srfile"
    ${UnRegisterExtensionOld} "im1" "im1file"
    ${UnRegisterExtensionOld} "im24" "im24file"
    ${UnRegisterExtensionOld} "im32" "im32file"
    ${UnRegisterExtensionOld} "im8" "im8file"
    ${UnRegisterExtensionOld} "rast" "rastfile"
    ${UnRegisterExtensionOld} "rs" "rsfile"
    ${UnRegisterExtensionOld} "scr" "scrfile"
    ${UnRegisterExtensionOld} "svg" "svgfile"
    ${UnRegisterExtensionOld} "svgz" "svgzfile"
    ${UnRegisterExtensionOld} "tar" "tarfile"
    ${UnRegisterExtensionOld} "tga" "tgafile"
    ${UnRegisterExtensionOld} "icb" "icbfile"
    ${UnRegisterExtensionOld} "vda" "vdafile"
    ${UnRegisterExtensionOld} "vst" "vstfile"
    ${UnRegisterExtensionOld} "tiff" "tifffile"
    ${UnRegisterExtensionOld} "tif" "tiffile"
    ${UnRegisterExtensionOld} "tim" "timfile"
    ${UnRegisterExtensionOld} "ttf" "ttffile"
    ${UnRegisterExtensionOld} "vicar" "vicarfile"
    ${UnRegisterExtensionOld} "vic" "vicfile"
    ${UnRegisterExtensionOld} "img" "imgfile"
    ${UnRegisterExtensionOld} "viff" "vifffile"
    ${UnRegisterExtensionOld} "xv" "xvfile"
    ${UnRegisterExtensionOld} "vtf" "vtffile"
    ${UnRegisterExtensionOld} "wbmp" "wbmpfile"
    ${UnRegisterExtensionOld} "webp" "webpfile"
    ${UnRegisterExtensionOld} "wmf" "wmffile"
    ${UnRegisterExtensionOld} "wmz" "wmzfile"
    ${UnRegisterExtensionOld} "apm" "apmfile"
    ${UnRegisterExtensionOld} "wpg" "wpgfile"
    ${UnRegisterExtensionOld} "x3f" "x3ffile"
    ${UnRegisterExtensionOld} "xbm" "xbmfile"
    ${UnRegisterExtensionOld} "bm" "bmfile"
    ${UnRegisterExtensionOld} "xpm" "xpmfile"
    ${UnRegisterExtensionOld} "pm" "pmfile"
    ${UnRegisterExtensionOld} "xwd" "xwdfile"
    ${UnRegisterExtensionOld} "eps" "epsfile"
    ${UnRegisterExtensionOld} "epsf" "epsffile"
    ${UnRegisterExtensionOld} "epsi" "epsifile"
    ${UnRegisterExtensionOld} "pdf" "pdffile"
    ${UnRegisterExtensionOld} "ps" "psfile"
    ${UnRegisterExtensionOld} "ps2" "ps2file"
    ${UnRegisterExtensionOld} "ps3" "ps3file"
    ${UnRegisterExtensionOld} "psd" "psdfile"
    ${UnRegisterExtensionOld} "psb" "psbfile"
    ${UnRegisterExtensionOld} "psdt" "psdtfile"
    ${UnRegisterExtensionOld} "xcf" "xcffile"

    ${UnRegisterExtensionApostrophe} "3fr" "3frfile"
    ${UnRegisterExtensionApostrophe} "fff" "ffffile"
    ${UnRegisterExtensionApostrophe} "aai" "aaifile"
    ${UnRegisterExtensionApostrophe} "ai" "aifile"
    ${UnRegisterExtensionApostrophe} "ani" "anifile"
    ${UnRegisterExtensionApostrophe} "apng" "apngfile"
    ${UnRegisterExtensionApostrophe} "ari" "arifile"
    ${UnRegisterExtensionApostrophe} "art" "artfile"
    ${UnRegisterExtensionApostrophe} "arw" "arwfile"
    ${UnRegisterExtensionApostrophe} "asf" "asffile"
    ${UnRegisterExtensionApostrophe} "avif" "aviffile"
    ${UnRegisterExtensionApostrophe} "avifs" "avifsfile"
    ${UnRegisterExtensionApostrophe} "avs" "avsfile"
    ${UnRegisterExtensionApostrophe} "x" "xfile"
    ${UnRegisterExtensionApostrophe} "mbfavs" "mbfavsfile"
    ${UnRegisterExtensionApostrophe} "bay" "bayfile"
    ${UnRegisterExtensionApostrophe} "bmp" "bmpfile"
    ${UnRegisterExtensionApostrophe} "dib" "dibfile"
    ${UnRegisterExtensionApostrophe} "bmq" "bmqfile"
    ${UnRegisterExtensionApostrophe} "bpg" "bpgfile"
    ${UnRegisterExtensionApostrophe} "cals" "calsfile"
    ${UnRegisterExtensionApostrophe} "ct1" "ct1file"
    ${UnRegisterExtensionApostrophe} "ct2" "ct2file"
    ${UnRegisterExtensionApostrophe} "ct3" "ct3file"
    ${UnRegisterExtensionApostrophe} "ct4" "ct4file"
    ${UnRegisterExtensionApostrophe} "c4" "c4file"
    ${UnRegisterExtensionApostrophe} "cal" "calfile"
    ${UnRegisterExtensionApostrophe} "nif" "niffile"
    ${UnRegisterExtensionApostrophe} "ras" "rasfile"
    ${UnRegisterExtensionApostrophe} "cap" "capfile"
    ${UnRegisterExtensionApostrophe} "eip" "eipfile"
    ${UnRegisterExtensionApostrophe} "liq" "liqfile"
    ${UnRegisterExtensionApostrophe} "iiq" "iiqfile"
    ${UnRegisterExtensionApostrophe} "cb7" "cb7file"
    ${UnRegisterExtensionApostrophe} "cbr" "cbrfile"
    ${UnRegisterExtensionApostrophe} "cbt" "cbtfile"
    ${UnRegisterExtensionApostrophe} "cbz" "cbzfile"
    ${UnRegisterExtensionApostrophe} "cg3" "cg3file"
    ${UnRegisterExtensionApostrophe} "g3" "g3file"
    ${UnRegisterExtensionApostrophe} "cine" "cinefile"
    ${UnRegisterExtensionApostrophe} "crw" "crwfile"
    ${UnRegisterExtensionApostrophe} "crr" "crrfile"
    ${UnRegisterExtensionApostrophe} "cr2" "cr2file"
    ${UnRegisterExtensionApostrophe} "cr3" "cr3file"
    ${UnRegisterExtensionApostrophe} "cs1" "cs1file"
    ${UnRegisterExtensionApostrophe} "cube" "cubefile"
    ${UnRegisterExtensionApostrophe} "cur" "curfile"
    ${UnRegisterExtensionApostrophe} "cut" "cutfile"
    ${UnRegisterExtensionApostrophe} "pal" "palfile"
    ${UnRegisterExtensionApostrophe} "dcr" "dcrfile"
    ${UnRegisterExtensionApostrophe} "kdc" "kdcfile"
    ${UnRegisterExtensionApostrophe} "drf" "drffile"
    ${UnRegisterExtensionApostrophe} "k25" "k25file"
    ${UnRegisterExtensionApostrophe} "dcs" "dcsfile"
    ${UnRegisterExtensionApostrophe} "dc2" "dc2file"
    ${UnRegisterExtensionApostrophe} "kc2" "kc2file"
    ${UnRegisterExtensionApostrophe} "dcx" "dcxfile"
    ${UnRegisterExtensionApostrophe} "dds" "ddsfile"
    ${UnRegisterExtensionApostrophe} "dfont" "dfontfile"
    ${UnRegisterExtensionApostrophe} "dic" "dicfile"
    ${UnRegisterExtensionApostrophe} "dcm" "dcmfile"
    ${UnRegisterExtensionApostrophe} "djvu" "djvufile"
    ${UnRegisterExtensionApostrophe} "djv" "djvfile"
    ${UnRegisterExtensionApostrophe} "dng" "dngfile"
    ${UnRegisterExtensionApostrophe} "dpx" "dpxfile"
    ${UnRegisterExtensionApostrophe} "dxo" "dxofile"
    ${UnRegisterExtensionApostrophe} "erf" "erffile"
    ${UnRegisterExtensionApostrophe} "exr" "exrfile"
    ${UnRegisterExtensionApostrophe} "ff" "fffile"
    ${UnRegisterExtensionApostrophe} "fits" "fitsfile"
    ${UnRegisterExtensionApostrophe} "fit" "fitfile"
    ${UnRegisterExtensionApostrophe} "fts" "ftsfile"
    ${UnRegisterExtensionApostrophe} "fl32" "fl32file"
    ${UnRegisterExtensionApostrophe} "ftx" "ftxfile"
    ${UnRegisterExtensionApostrophe} "gif" "giffile"
    ${UnRegisterExtensionApostrophe} "gpr" "gprfile"
    ${UnRegisterExtensionApostrophe} "heif" "heiffile"
    ${UnRegisterExtensionApostrophe} "heic" "heicfile"
    ${UnRegisterExtensionApostrophe} "hrz" "hrzfile"
    ${UnRegisterExtensionApostrophe} "icns" "icnsfile"
    ${UnRegisterExtensionApostrophe} "ico" "icofile"
    ${UnRegisterExtensionApostrophe} "iff" "ifffile"
    ${UnRegisterExtensionApostrophe} "jbig" "jbigfile"
    ${UnRegisterExtensionApostrophe} "jbg" "jbgfile"
    ${UnRegisterExtensionApostrophe} "bie" "biefile"
    ${UnRegisterExtensionApostrophe} "jfif" "jfiffile"
    ${UnRegisterExtensionApostrophe} "jng" "jngfile"
    ${UnRegisterExtensionApostrophe} "jpeg" "jpegfile"
    ${UnRegisterExtensionApostrophe} "jpg" "jpgfile"
    ${UnRegisterExtensionApostrophe} "jpe" "jpefile"
    ${UnRegisterExtensionApostrophe} "jif" "jiffile"
    ${UnRegisterExtensionApostrophe} "jpeg2000" "jpeg2000file"
    ${UnRegisterExtensionApostrophe} "j2k" "j2kfile"
    ${UnRegisterExtensionApostrophe} "jp2" "jp2file"
    ${UnRegisterExtensionApostrophe} "jpc" "jpcfile"
    ${UnRegisterExtensionApostrophe} "jpx" "jpxfile"
    ${UnRegisterExtensionApostrophe} "jxl" "jxlfile"
    ${UnRegisterExtensionApostrophe} "jxr" "jxrfile"
    ${UnRegisterExtensionApostrophe} "hdp" "hdpfile"
    ${UnRegisterExtensionApostrophe} "wdp" "wdpfile"
    ${UnRegisterExtensionApostrophe} "koa" "koafile"
    ${UnRegisterExtensionApostrophe} "gg" "ggfile"
    ${UnRegisterExtensionApostrophe} "gig" "gigfile"
    ${UnRegisterExtensionApostrophe} "kla" "klafile"
    ${UnRegisterExtensionApostrophe} "kra" "krafile"
    ${UnRegisterExtensionApostrophe} "lbm" "lbmfile"
    ${UnRegisterExtensionApostrophe} "mat" "matfile"
    ${UnRegisterExtensionApostrophe} "mdc" "mdcfile"
    ${UnRegisterExtensionApostrophe} "mef" "meffile"
    ${UnRegisterExtensionApostrophe} "mfw" "mfwfile"
    ${UnRegisterExtensionApostrophe} "miff" "mifffile"
    ${UnRegisterExtensionApostrophe} "mif" "miffile"
    ${UnRegisterExtensionApostrophe} "mng" "mngfile"
    ${UnRegisterExtensionApostrophe} "mos" "mosfile"
    ${UnRegisterExtensionApostrophe} "mpc" "mpcfile"
    ${UnRegisterExtensionApostrophe} "mtv" "mtvfile"
    ${UnRegisterExtensionApostrophe} "pic" "picfile"
    ${UnRegisterExtensionApostrophe} "mvg" "mvgfile"
    ${UnRegisterExtensionApostrophe} "nef" "neffile"
    ${UnRegisterExtensionApostrophe} "nrw" "nrwfile"
    ${UnRegisterExtensionApostrophe} "obm" "obmfile"
    ${UnRegisterExtensionApostrophe} "ora" "orafile"
    ${UnRegisterExtensionApostrophe} "orf" "orffile"
    ${UnRegisterExtensionApostrophe} "ori" "orifile"
    ${UnRegisterExtensionApostrophe} "otb" "otbfile"
    ${UnRegisterExtensionApostrophe} "otf" "otffile"
    ${UnRegisterExtensionApostrophe} "otc" "otcfile"
    ${UnRegisterExtensionApostrophe} "ttf" "ttffile"
    ${UnRegisterExtensionApostrophe} "ttc" "ttcfile"
    ${UnRegisterExtensionApostrophe} "p7" "p7file"
    ${UnRegisterExtensionApostrophe} "palm" "palmfile"
    ${UnRegisterExtensionApostrophe} "pam" "pamfile"
    ${UnRegisterExtensionApostrophe} "pbm" "pbmfile"
    ${UnRegisterExtensionApostrophe} "pcd" "pcdfile"
    ${UnRegisterExtensionApostrophe} "pcds" "pcdsfile"
    ${UnRegisterExtensionApostrophe} "pcx" "pcxfile"
    ${UnRegisterExtensionApostrophe} "pdb" "pdbfile"
    ${UnRegisterExtensionApostrophe} "pdd" "pddfile"
    ${UnRegisterExtensionApostrophe} "pef" "peffile"
    ${UnRegisterExtensionApostrophe} "ptx" "ptxfile"
    ${UnRegisterExtensionApostrophe} "pes" "pesfile"
    ${UnRegisterExtensionApostrophe} "pfb" "pfbfile"
    ${UnRegisterExtensionApostrophe} "pfm" "pfmfile"
    ${UnRegisterExtensionApostrophe} "afm" "afmfile"
    ${UnRegisterExtensionApostrophe} "inf" "inffile"
    ${UnRegisterExtensionApostrophe} "pfa" "pfafile"
    ${UnRegisterExtensionApostrophe} "ofm" "ofmfile"
    ${UnRegisterExtensionApostrophe} "pfm" "pfmfile"
    ${UnRegisterExtensionApostrophe} "pgm" "pgmfile"
    ${UnRegisterExtensionApostrophe} "pgx" "pgxfile"
    ${UnRegisterExtensionApostrophe} "phm" "phmfile"
    ${UnRegisterExtensionApostrophe} "pic" "picfile"
    ${UnRegisterExtensionApostrophe} "picon" "piconfile"
    ${UnRegisterExtensionApostrophe} "pict" "pictfile"
    ${UnRegisterExtensionApostrophe} "pct" "pctfile"
    ${UnRegisterExtensionApostrophe} "pic" "picfile"
    ${UnRegisterExtensionApostrophe} "pix" "pixfile"
    ${UnRegisterExtensionApostrophe} "als" "alsfile"
    ${UnRegisterExtensionApostrophe} "alias" "aliasfile"
    ${UnRegisterExtensionApostrophe} "png" "pngfile"
    ${UnRegisterExtensionApostrophe} "ppm" "ppmfile"
    ${UnRegisterExtensionApostrophe} "pnm" "pnmfile"
    ${UnRegisterExtensionApostrophe} "ptiff" "ptifffile"
    ${UnRegisterExtensionApostrophe} "ptif" "ptiffile"
    ${UnRegisterExtensionApostrophe} "pxn" "pxnfile"
    ${UnRegisterExtensionApostrophe} "pxr" "pxrfile"
    ${UnRegisterExtensionApostrophe} "qoi" "qoifile"
    ${UnRegisterExtensionApostrophe} "qtk" "qtkfile"
    ${UnRegisterExtensionApostrophe} "r3d" "r3dfile"
    ${UnRegisterExtensionApostrophe} "raf" "raffile"
    ${UnRegisterExtensionApostrophe} "raw" "rawfile"
    ${UnRegisterExtensionApostrophe} "rwl" "rwlfile"
    ${UnRegisterExtensionApostrophe} "rdc" "rdcfile"
    ${UnRegisterExtensionApostrophe} "rgba" "rgbafile"
    ${UnRegisterExtensionApostrophe} "rgb" "rgbfile"
    ${UnRegisterExtensionApostrophe} "sgi" "sgifile"
    ${UnRegisterExtensionApostrophe} "bw" "bwfile"
    ${UnRegisterExtensionApostrophe} "rgbe" "rgbefile"
    ${UnRegisterExtensionApostrophe} "hdr" "hdrfile"
    ${UnRegisterExtensionApostrophe} "rad" "radfile"
    ${UnRegisterExtensionApostrophe} "rgf" "rgffile"
    ${UnRegisterExtensionApostrophe} "rla" "rlafile"
    ${UnRegisterExtensionApostrophe} "rle" "rlefile"
    ${UnRegisterExtensionApostrophe} "rw2" "rw2file"
    ${UnRegisterExtensionApostrophe} "rwz" "rwzfile"
    ${UnRegisterExtensionApostrophe} "scr" "scrfile"
    ${UnRegisterExtensionApostrophe} "sct" "sctfile"
    ${UnRegisterExtensionApostrophe} "ch" "chfile"
    ${UnRegisterExtensionApostrophe} "ct" "ctfile"
    ${UnRegisterExtensionApostrophe} "sfw" "sfwfile"
    ${UnRegisterExtensionApostrophe} "alb" "albfile"
    ${UnRegisterExtensionApostrophe} "pwm" "pwmfile"
    ${UnRegisterExtensionApostrophe} "pwp" "pwpfile"
    ${UnRegisterExtensionApostrophe} "sixel" "sixelfile"
    ${UnRegisterExtensionApostrophe} "srf" "srffile"
    ${UnRegisterExtensionApostrophe} "mrw" "mrwfile"
    ${UnRegisterExtensionApostrophe} "sr2" "sr2file"
    ${UnRegisterExtensionApostrophe} "arq" "arqfile"
    ${UnRegisterExtensionApostrophe} "srw" "srwfile"
    ${UnRegisterExtensionApostrophe} "sti" "stifile"
    ${UnRegisterExtensionApostrophe} "sun" "sunfile"
    ${UnRegisterExtensionApostrophe} "ras" "rasfile"
    ${UnRegisterExtensionApostrophe} "sr" "srfile"
    ${UnRegisterExtensionApostrophe} "im1" "im1file"
    ${UnRegisterExtensionApostrophe} "im24" "im24file"
    ${UnRegisterExtensionApostrophe} "im32" "im32file"
    ${UnRegisterExtensionApostrophe} "im8" "im8file"
    ${UnRegisterExtensionApostrophe} "rast" "rastfile"
    ${UnRegisterExtensionApostrophe} "rs" "rsfile"
    ${UnRegisterExtensionApostrophe} "scr" "scrfile"
    ${UnRegisterExtensionApostrophe} "svg" "svgfile"
    ${UnRegisterExtensionApostrophe} "svgz" "svgzfile"
    ${UnRegisterExtensionApostrophe} "tar" "tarfile"
    ${UnRegisterExtensionApostrophe} "tga" "tgafile"
    ${UnRegisterExtensionApostrophe} "icb" "icbfile"
    ${UnRegisterExtensionApostrophe} "vda" "vdafile"
    ${UnRegisterExtensionApostrophe} "vst" "vstfile"
    ${UnRegisterExtensionApostrophe} "tiff" "tifffile"
    ${UnRegisterExtensionApostrophe} "tif" "tiffile"
    ${UnRegisterExtensionApostrophe} "tim" "timfile"
    ${UnRegisterExtensionApostrophe} "ttf" "ttffile"
    ${UnRegisterExtensionApostrophe} "vicar" "vicarfile"
    ${UnRegisterExtensionApostrophe} "vic" "vicfile"
    ${UnRegisterExtensionApostrophe} "img" "imgfile"
    ${UnRegisterExtensionApostrophe} "viff" "vifffile"
    ${UnRegisterExtensionApostrophe} "xv" "xvfile"
    ${UnRegisterExtensionApostrophe} "vtf" "vtffile"
    ${UnRegisterExtensionApostrophe} "wbmp" "wbmpfile"
    ${UnRegisterExtensionApostrophe} "webp" "webpfile"
    ${UnRegisterExtensionApostrophe} "wmf" "wmffile"
    ${UnRegisterExtensionApostrophe} "wmz" "wmzfile"
    ${UnRegisterExtensionApostrophe} "apm" "apmfile"
    ${UnRegisterExtensionApostrophe} "wpg" "wpgfile"
    ${UnRegisterExtensionApostrophe} "x3f" "x3ffile"
    ${UnRegisterExtensionApostrophe} "xbm" "xbmfile"
    ${UnRegisterExtensionApostrophe} "bm" "bmfile"
    ${UnRegisterExtensionApostrophe} "xpm" "xpmfile"
    ${UnRegisterExtensionApostrophe} "pm" "pmfile"
    ${UnRegisterExtensionApostrophe} "xwd" "xwdfile"
    ${UnRegisterExtensionApostrophe} "eps" "epsfile"
    ${UnRegisterExtensionApostrophe} "epsf" "epsffile"
    ${UnRegisterExtensionApostrophe} "epsi" "epsifile"
    ${UnRegisterExtensionApostrophe} "pdf" "pdffile"
    ${UnRegisterExtensionApostrophe} "ps" "psfile"
    ${UnRegisterExtensionApostrophe} "ps2" "ps2file"
    ${UnRegisterExtensionApostrophe} "ps3" "ps3file"
    ${UnRegisterExtensionApostrophe} "psd" "psdfile"
    ${UnRegisterExtensionApostrophe} "psb" "psbfile"
    ${UnRegisterExtensionApostrophe} "psdt" "psdtfile"
    ${UnRegisterExtensionApostrophe} "xcf" "xcffile"


    ${If} $RadioButtonAll_State == ${BST_CHECKED}

        WriteRegStr HKCU "Software\PhotoQt" "fileformats" "all"

        ${RegisterExtension} "$INSTDIR\photoqt.exe" "3fr" "Hasselblad Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "fff" "Hasselblad Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "aai" "AAI Dune image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "ai" "Adobe Illustrator (PDF compatible)"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "ani" "Animated Windows cursors"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "apng" "Animated Portable Network Graphics"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "ari" "ARRIFLEX Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "art" "1st Publisher"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "arw" "Sony Digital Camera Alpha Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "asf" "Advanced Systems Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "avif" "AV1 Image File Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "avifs" "AV1 Image File Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "avs" "AVS X image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "x" "AVS X image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "mbfavs" "AVS X image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "bay" "Casio Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "bmp" "Microsoft Windows bitmap"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "dib" "Microsoft Windows bitmap"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "bmq" "NuCore RAW image file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "bpg" "Better Portable Graphics"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "cals" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "ct1" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "ct2" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "ct3" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "ct4" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "c4" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "cal" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "nif" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "ras" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "cap" "Phase One Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "eip" "Phase One Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "liq" "Phase One Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "iiq" "Phase One Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "cb7" "Comic book archive"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "cbr" "Comic book archive"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "cbt" "Comic book archive"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "cbz" "Comic book archive"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "cg3" "CCITT Group 3"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "g3" "CCITT Group 3"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "cine" "Cine File Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "crw" "Canon Digital Camera Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "crr" "Canon Digital Camera Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "cr2" "Canon Digital Camera Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "cr3" "Canon Digital Camera Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "cs1" "CaptureShop 1-shot Raw Image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "cube" "Cube Color lookup table converted to a HALD image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "cur" "Microsoft Windows cursor format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "cut" "Dr. Halo"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pal" "Dr. Halo"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "dcr" "Kodak Cineon Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "kdc" "Kodak Cineon Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "drf" "Kodak Cineon Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "k25" "Kodak Cineon Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "dcs" "Kodak Cineon Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "dc2" "Kodak Cineon Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "kc2" "Kodak Cineon Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "dcx" "ZSoft IBM PC multi-page Paintbrush image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "dds" "DirectDraw Surface"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "dfont" "Multi-face font package"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "dic" "Digital Imaging and Communications in Medicine (DICOM) image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "dcm" "Digital Imaging and Communications in Medicine (DICOM) image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "djvu" "DjVu digital document format "
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "djv" "DjVu digital document format "
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "dng" "Adobe Digital Negative Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "dpx" "Digital Moving Picture Exchange"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "dxo" "DxO PureRaw"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "erf" "Epson Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "exr" "OpenEXR"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "ff" "farbfeld"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "fits" "Flexible Image Transport System"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "fit" "Flexible Image Transport System"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "fts" "Flexible Image Transport System"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "fl32" "FilmLight floating point image format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "ftx" "FAKK 2"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "gif" "Graphics Interchange Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "gpr" "GoPro GPR Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "heif" "High Efficiency Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "heic" "High Efficiency Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "hrz" "Slow-scan television"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "icns" "Apple Icon Image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "ico" "Microsoft Windows icon format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "iff" "Interchange File Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "jbig" "Joint Bi-level Image experts Group file interchange format (JBIG)"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "jbg" "Joint Bi-level Image experts Group file interchange format (JBIG)"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "bie" "Joint Bi-level Image experts Group file interchange format (JBIG)"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "jfif" "JPEG File Interchange Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "jng" "JPEG Network Graphics"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "jpeg" "Joint Photographic Experts Group JFIF format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "jpg" "Joint Photographic Experts Group JFIF format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "jpe" "Joint Photographic Experts Group JFIF format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "jif" "Joint Photographic Experts Group JFIF format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "jpeg2000" "JPEG-2000"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "j2k" "JPEG-2000"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "jp2" "JPEG-2000"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "jpc" "JPEG-2000"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "jpx" "JPEG-2000"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "jxl" "JPEG XL"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "jxr" "JPEG-XR"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "hdp" "JPEG-XR"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "wdp" "JPEG-XR"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "koa" "KOALA files"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "gg" "KOALA files"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "gig" "KOALA files"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "kla" "KOALA files"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "kra" "Krita Document"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "lbm" "Interlaced Bitmap"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "mat" "MATLAB image format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "mdc" "Minolta/Agfa Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "mef" "Mamiya Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "mfw" "Mamiya Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "miff" "Magick image file format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "mif" "Magick image file format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "mng" "Multiple-image Network Graphics"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "mos" "Leaf Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "mpc" "Magick Persistent Cache image file format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "mtv" "MTV ray tracer bitmap"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pic" "MTV ray tracer bitmap"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "mvg" "Magick Vector Graphics"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "nef" "Nikon Digital SLR Camera Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "nrw" "Nikon Digital SLR Camera Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "obm" "OBM file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "ora" "OpenRaster"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "orf" "Olympus Digital Camera Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "ori" "Olympus Digital Camera Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "otb" "On-the-air Bitmap"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "otf" "OpenType font file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "otc" "OpenType font file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "ttf" "OpenType font file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "ttc" "OpenType font file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "p7" "Xv Visual Schnauzer thumbnail format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "palm" "Palm pixmap"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pam" "Portable Arbitrary Map format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pbm" "Portable bitmap format (black and white)"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pcd" "Photo CD"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pcds" "Photo CD"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pcx" "ZSoft PiCture eXchange"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pdb" "Palm Database ImageViewer Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pdd" "Adobe PhotoDeluxe"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pef" "Pentax Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "ptx" "Pentax Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pes" "Embrid Embroidery Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pfb" "Postscript Type 1 font "
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pfm" "Postscript Type 1 font "
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "afm" "Postscript Type 1 font "
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "inf" "Postscript Type 1 font "
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pfa" "Postscript Type 1 font "
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "ofm" "Postscript Type 1 font "
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pfm" "Portable Float Map"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pgm" "Portable graymap format (gray scale)"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pgx" "JPEG 2000 uncompressed format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "phm" "Portable float map format 16-bit half"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pic" "Softimage PIC"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "picon" "Personal Icon"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pict" "QuickDraw/PICT"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pct" "QuickDraw/PICT"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pic" "QuickDraw/PICT"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pix" "Alias/Wavefront RLE image format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "als" "Alias/Wavefront RLE image format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "alias" "Alias/Wavefront RLE image format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "png" "Portable Network Graphics"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "ppm" "Portable pixmap format (color)"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pnm" "Portable pixmap format (color)"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "ptiff" "Pyramid encoded TIFF"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "ptif" "Pyramid encoded TIFF"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pxn" "Logitech Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pxr" "PIXAR format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "qoi" "Quite OK image format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "qtk" "Apple QuickTake Picture"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "r3d" "RED R3D file format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "raf" "Fuji CCD Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "raw" "Leica Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "rwl" "Leica Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "rdc" "Rollei RAW Image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "rgba" "SGI images"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "rgb" "SGI images"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "sgi" "SGI images"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "bw" "SGI images"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "rgbe" "Radiance RGBE image format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "hdr" "Radiance RGBE image format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "rad" "Radiance RGBE image format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "rgf" "LEGO Mindstorms EV3 Robot Graphics File"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "rla" "Wavefront RLA File Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "rle" "Utah Run length encoded image file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "rw2" "Panasonic Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "rwz" "Rawzor RAW image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "scr" "ZX-Spectrum SCREEN"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "sct" "Scitex Continuous Tone Picture"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "ch" "Scitex Continuous Tone Picture"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "ct" "Scitex Continuous Tone Picture"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "sfw" "Seattle File Works image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "alb" "Seattle File Works image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pwm" "Seattle File Works image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pwp" "Seattle File Works image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "sixel" "DEC SIXEL Graphics Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "srf" "Sony (Minolta) Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "mrw" "Sony (Minolta) Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "sr2" "Sony (Minolta) Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "arq" "Sony (Minolta) Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "srw" "Samsung Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "sti" "Sinar CaptureShop RAW image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "sun" "SUN Rasterfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "ras" "SUN Rasterfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "sr" "SUN Rasterfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "im1" "SUN Rasterfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "im24" "SUN Rasterfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "im32" "SUN Rasterfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "im8" "SUN Rasterfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "rast" "SUN Rasterfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "rs" "SUN Rasterfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "scr" "SUN Rasterfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "svg" "Scalable Vector Graphics"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "svgz" "Scalable Vector Graphics"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "tar" "TAR file format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "tga" "Truevision Targa image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "icb" "Truevision Targa image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "vda" "Truevision Targa image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "vst" "Truevision Targa image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "tiff" "Tagged Image File Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "tif" "Tagged Image File Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "tim" "PSX TIM (PlayStation Graphics)"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "ttf" "TrueType font file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "vicar" "VICAR rasterfile format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "vic" "VICAR rasterfile format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "img" "VICAR rasterfile format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "viff" "Khoros Visualization Image File Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "xv" "Khoros Visualization Image File Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "vtf" "Valve Texture Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "wbmp" "Wireless Bitmap"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "webp" "Google web image format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "wmf" "Windows Metafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "wmz" "Windows Metafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "apm" "Windows Metafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "wpg" "Word Perfect Graphics File"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "x3f" "Sigma Digital Camera Raw Image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "xbm" "X BitMap"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "bm" "X BitMap"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "xpm" "X PixMap"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "pm" "X PixMap"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" "xwd" "X Windows system window dump"


        ${If} $CheckboxPdfPs_State == ${BST_CHECKED}

            WriteRegStr HKCU "Software\PhotoQt" "fileformats_pdfps" "registered"

            ${RegisterExtension} "$INSTDIR\photoqt.exe" "eps" "Encapsulated PostScript"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" "epsf" "Encapsulated PostScript"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" "epsi" "Encapsulated PostScript"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" "pdf" "Adobe Portable Document Format"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" "ps" "Adobe Level III PostScript file"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" "ps2" "Adobe Level III PostScript file"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" "ps3" "Adobe Level III PostScript file"


        ${Else}

            ; if it was registered in a previous install, we need to de-register it here
            Var /GLOBAL fileformats_pdfps
            ReadRegStr $fileformats_pdfps HKCU "Software\PhotoQt" "fileformats_pdfps"
            ${If} $fileformats_pdfps == "registered"

                ${UnRegisterExtension} "eps" "Encapsulated PostScript"
                ${UnRegisterExtension} "epsf" "Encapsulated PostScript"
                ${UnRegisterExtension} "epsi" "Encapsulated PostScript"
                ${UnRegisterExtension} "pdf" "Adobe Portable Document Format"
                ${UnRegisterExtension} "ps" "Adobe Level III PostScript file"
                ${UnRegisterExtension} "ps2" "Adobe Level III PostScript file"
                ${UnRegisterExtension} "ps3" "Adobe Level III PostScript file"


            ${EndIf}

            WriteRegStr HKCU "Software\PhotoQt" "fileformats_pdfps" ""

        ${EndIf}

        ${If} $CheckboxPsdXcf_State == ${BST_CHECKED}

            WriteRegStr HKCU "Software\PhotoQt" "fileformats_psdxcf" "registered"

            ${RegisterExtension} "$INSTDIR\photoqt.exe" "psd" "Adobe PhotoShop"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" "psb" "Adobe PhotoShop"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" "psdt" "Adobe PhotoShop"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" "xcf" "Gimp XCF"


        ${Else}

            ; if it was registered in a previous install, we need to de-register it here
            Var /GLOBAL fileformats_psdxcf
            ReadRegStr $fileformats_psdxcf HKCU "Software\PhotoQt" "fileformats_psdxcf"
            ${If} $fileformats_psdxcf == "registered"

                ${UnRegisterExtension} "psd" "Adobe PhotoShop"
                ${UnRegisterExtension} "psb" "Adobe PhotoShop"
                ${UnRegisterExtension} "psdt" "Adobe PhotoShop"
                ${UnRegisterExtension} "xcf" "Gimp XCF"


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
    WriteRegStr HKCR "Applications\photoqt.exe" "FriendlyAppName" "PhotoQt"

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

    ; ... DE-register file formats ...
    ${If} $un_fileformats == "all"

        ${UnRegisterExtension} "3fr" "Hasselblad Raw Image Format"
        ${UnRegisterExtension} "fff" "Hasselblad Raw Image Format"
        ${UnRegisterExtension} "aai" "AAI Dune image"
        ${UnRegisterExtension} "ai" "Adobe Illustrator (PDF compatible)"
        ${UnRegisterExtension} "ani" "Animated Windows cursors"
        ${UnRegisterExtension} "apng" "Animated Portable Network Graphics"
        ${UnRegisterExtension} "ari" "ARRIFLEX Raw Image Format"
        ${UnRegisterExtension} "art" "1st Publisher"
        ${UnRegisterExtension} "arw" "Sony Digital Camera Alpha Raw Image Format"
        ${UnRegisterExtension} "asf" "Advanced Systems Format"
        ${UnRegisterExtension} "avif" "AV1 Image File Format"
        ${UnRegisterExtension} "avifs" "AV1 Image File Format"
        ${UnRegisterExtension} "avs" "AVS X image"
        ${UnRegisterExtension} "x" "AVS X image"
        ${UnRegisterExtension} "mbfavs" "AVS X image"
        ${UnRegisterExtension} "bay" "Casio Raw Image Format"
        ${UnRegisterExtension} "bmp" "Microsoft Windows bitmap"
        ${UnRegisterExtension} "dib" "Microsoft Windows bitmap"
        ${UnRegisterExtension} "bmq" "NuCore RAW image file"
        ${UnRegisterExtension} "bpg" "Better Portable Graphics"
        ${UnRegisterExtension} "cals" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${UnRegisterExtension} "ct1" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${UnRegisterExtension} "ct2" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${UnRegisterExtension} "ct3" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${UnRegisterExtension} "ct4" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${UnRegisterExtension} "c4" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${UnRegisterExtension} "cal" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${UnRegisterExtension} "nif" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${UnRegisterExtension} "ras" "Continuous Acquisition and Life-cycle Support Type 1 image"
        ${UnRegisterExtension} "cap" "Phase One Raw Image Format"
        ${UnRegisterExtension} "eip" "Phase One Raw Image Format"
        ${UnRegisterExtension} "liq" "Phase One Raw Image Format"
        ${UnRegisterExtension} "iiq" "Phase One Raw Image Format"
        ${UnRegisterExtension} "cb7" "Comic book archive"
        ${UnRegisterExtension} "cbr" "Comic book archive"
        ${UnRegisterExtension} "cbt" "Comic book archive"
        ${UnRegisterExtension} "cbz" "Comic book archive"
        ${UnRegisterExtension} "cg3" "CCITT Group 3"
        ${UnRegisterExtension} "g3" "CCITT Group 3"
        ${UnRegisterExtension} "cine" "Cine File Format"
        ${UnRegisterExtension} "crw" "Canon Digital Camera Raw Image Format"
        ${UnRegisterExtension} "crr" "Canon Digital Camera Raw Image Format"
        ${UnRegisterExtension} "cr2" "Canon Digital Camera Raw Image Format"
        ${UnRegisterExtension} "cr3" "Canon Digital Camera Raw Image Format"
        ${UnRegisterExtension} "cs1" "CaptureShop 1-shot Raw Image"
        ${UnRegisterExtension} "cube" "Cube Color lookup table converted to a HALD image"
        ${UnRegisterExtension} "cur" "Microsoft Windows cursor format"
        ${UnRegisterExtension} "cut" "Dr. Halo"
        ${UnRegisterExtension} "pal" "Dr. Halo"
        ${UnRegisterExtension} "dcr" "Kodak Cineon Raw Image Format"
        ${UnRegisterExtension} "kdc" "Kodak Cineon Raw Image Format"
        ${UnRegisterExtension} "drf" "Kodak Cineon Raw Image Format"
        ${UnRegisterExtension} "k25" "Kodak Cineon Raw Image Format"
        ${UnRegisterExtension} "dcs" "Kodak Cineon Raw Image Format"
        ${UnRegisterExtension} "dc2" "Kodak Cineon Raw Image Format"
        ${UnRegisterExtension} "kc2" "Kodak Cineon Raw Image Format"
        ${UnRegisterExtension} "dcx" "ZSoft IBM PC multi-page Paintbrush image"
        ${UnRegisterExtension} "dds" "DirectDraw Surface"
        ${UnRegisterExtension} "dfont" "Multi-face font package"
        ${UnRegisterExtension} "dic" "Digital Imaging and Communications in Medicine (DICOM) image"
        ${UnRegisterExtension} "dcm" "Digital Imaging and Communications in Medicine (DICOM) image"
        ${UnRegisterExtension} "djvu" "DjVu digital document format "
        ${UnRegisterExtension} "djv" "DjVu digital document format "
        ${UnRegisterExtension} "dng" "Adobe Digital Negative Raw Image Format"
        ${UnRegisterExtension} "dpx" "Digital Moving Picture Exchange"
        ${UnRegisterExtension} "dxo" "DxO PureRaw"
        ${UnRegisterExtension} "erf" "Epson Raw Image Format"
        ${UnRegisterExtension} "exr" "OpenEXR"
        ${UnRegisterExtension} "ff" "farbfeld"
        ${UnRegisterExtension} "fits" "Flexible Image Transport System"
        ${UnRegisterExtension} "fit" "Flexible Image Transport System"
        ${UnRegisterExtension} "fts" "Flexible Image Transport System"
        ${UnRegisterExtension} "fl32" "FilmLight floating point image format"
        ${UnRegisterExtension} "ftx" "FAKK 2"
        ${UnRegisterExtension} "gif" "Graphics Interchange Format"
        ${UnRegisterExtension} "gpr" "GoPro GPR Raw Image Format"
        ${UnRegisterExtension} "heif" "High Efficiency Image Format"
        ${UnRegisterExtension} "heic" "High Efficiency Image Format"
        ${UnRegisterExtension} "hrz" "Slow-scan television"
        ${UnRegisterExtension} "icns" "Apple Icon Image"
        ${UnRegisterExtension} "ico" "Microsoft Windows icon format"
        ${UnRegisterExtension} "iff" "Interchange File Format"
        ${UnRegisterExtension} "jbig" "Joint Bi-level Image experts Group file interchange format (JBIG)"
        ${UnRegisterExtension} "jbg" "Joint Bi-level Image experts Group file interchange format (JBIG)"
        ${UnRegisterExtension} "bie" "Joint Bi-level Image experts Group file interchange format (JBIG)"
        ${UnRegisterExtension} "jfif" "JPEG File Interchange Format"
        ${UnRegisterExtension} "jng" "JPEG Network Graphics"
        ${UnRegisterExtension} "jpeg" "Joint Photographic Experts Group JFIF format"
        ${UnRegisterExtension} "jpg" "Joint Photographic Experts Group JFIF format"
        ${UnRegisterExtension} "jpe" "Joint Photographic Experts Group JFIF format"
        ${UnRegisterExtension} "jif" "Joint Photographic Experts Group JFIF format"
        ${UnRegisterExtension} "jpeg2000" "JPEG-2000"
        ${UnRegisterExtension} "j2k" "JPEG-2000"
        ${UnRegisterExtension} "jp2" "JPEG-2000"
        ${UnRegisterExtension} "jpc" "JPEG-2000"
        ${UnRegisterExtension} "jpx" "JPEG-2000"
        ${UnRegisterExtension} "jxl" "JPEG XL"
        ${UnRegisterExtension} "jxr" "JPEG-XR"
        ${UnRegisterExtension} "hdp" "JPEG-XR"
        ${UnRegisterExtension} "wdp" "JPEG-XR"
        ${UnRegisterExtension} "koa" "KOALA files"
        ${UnRegisterExtension} "gg" "KOALA files"
        ${UnRegisterExtension} "gig" "KOALA files"
        ${UnRegisterExtension} "kla" "KOALA files"
        ${UnRegisterExtension} "kra" "Krita Document"
        ${UnRegisterExtension} "lbm" "Interlaced Bitmap"
        ${UnRegisterExtension} "mat" "MATLAB image format"
        ${UnRegisterExtension} "mdc" "Minolta/Agfa Raw Image Format"
        ${UnRegisterExtension} "mef" "Mamiya Raw Image Format"
        ${UnRegisterExtension} "mfw" "Mamiya Raw Image Format"
        ${UnRegisterExtension} "miff" "Magick image file format"
        ${UnRegisterExtension} "mif" "Magick image file format"
        ${UnRegisterExtension} "mng" "Multiple-image Network Graphics"
        ${UnRegisterExtension} "mos" "Leaf Raw Image Format"
        ${UnRegisterExtension} "mpc" "Magick Persistent Cache image file format"
        ${UnRegisterExtension} "mtv" "MTV ray tracer bitmap"
        ${UnRegisterExtension} "pic" "MTV ray tracer bitmap"
        ${UnRegisterExtension} "mvg" "Magick Vector Graphics"
        ${UnRegisterExtension} "nef" "Nikon Digital SLR Camera Raw Image Format"
        ${UnRegisterExtension} "nrw" "Nikon Digital SLR Camera Raw Image Format"
        ${UnRegisterExtension} "obm" "OBM file"
        ${UnRegisterExtension} "ora" "OpenRaster"
        ${UnRegisterExtension} "orf" "Olympus Digital Camera Raw Image Format"
        ${UnRegisterExtension} "ori" "Olympus Digital Camera Raw Image Format"
        ${UnRegisterExtension} "otb" "On-the-air Bitmap"
        ${UnRegisterExtension} "otf" "OpenType font file"
        ${UnRegisterExtension} "otc" "OpenType font file"
        ${UnRegisterExtension} "ttf" "OpenType font file"
        ${UnRegisterExtension} "ttc" "OpenType font file"
        ${UnRegisterExtension} "p7" "Xv Visual Schnauzer thumbnail format"
        ${UnRegisterExtension} "palm" "Palm pixmap"
        ${UnRegisterExtension} "pam" "Portable Arbitrary Map format"
        ${UnRegisterExtension} "pbm" "Portable bitmap format (black and white)"
        ${UnRegisterExtension} "pcd" "Photo CD"
        ${UnRegisterExtension} "pcds" "Photo CD"
        ${UnRegisterExtension} "pcx" "ZSoft PiCture eXchange"
        ${UnRegisterExtension} "pdb" "Palm Database ImageViewer Format"
        ${UnRegisterExtension} "pdd" "Adobe PhotoDeluxe"
        ${UnRegisterExtension} "pef" "Pentax Raw Image Format"
        ${UnRegisterExtension} "ptx" "Pentax Raw Image Format"
        ${UnRegisterExtension} "pes" "Embrid Embroidery Format"
        ${UnRegisterExtension} "pfb" "Postscript Type 1 font "
        ${UnRegisterExtension} "pfm" "Postscript Type 1 font "
        ${UnRegisterExtension} "afm" "Postscript Type 1 font "
        ${UnRegisterExtension} "inf" "Postscript Type 1 font "
        ${UnRegisterExtension} "pfa" "Postscript Type 1 font "
        ${UnRegisterExtension} "ofm" "Postscript Type 1 font "
        ${UnRegisterExtension} "pfm" "Portable Float Map"
        ${UnRegisterExtension} "pgm" "Portable graymap format (gray scale)"
        ${UnRegisterExtension} "pgx" "JPEG 2000 uncompressed format"
        ${UnRegisterExtension} "phm" "Portable float map format 16-bit half"
        ${UnRegisterExtension} "pic" "Softimage PIC"
        ${UnRegisterExtension} "picon" "Personal Icon"
        ${UnRegisterExtension} "pict" "QuickDraw/PICT"
        ${UnRegisterExtension} "pct" "QuickDraw/PICT"
        ${UnRegisterExtension} "pic" "QuickDraw/PICT"
        ${UnRegisterExtension} "pix" "Alias/Wavefront RLE image format"
        ${UnRegisterExtension} "als" "Alias/Wavefront RLE image format"
        ${UnRegisterExtension} "alias" "Alias/Wavefront RLE image format"
        ${UnRegisterExtension} "png" "Portable Network Graphics"
        ${UnRegisterExtension} "ppm" "Portable pixmap format (color)"
        ${UnRegisterExtension} "pnm" "Portable pixmap format (color)"
        ${UnRegisterExtension} "ptiff" "Pyramid encoded TIFF"
        ${UnRegisterExtension} "ptif" "Pyramid encoded TIFF"
        ${UnRegisterExtension} "pxn" "Logitech Raw Image Format"
        ${UnRegisterExtension} "pxr" "PIXAR format"
        ${UnRegisterExtension} "qoi" "Quite OK image format"
        ${UnRegisterExtension} "qtk" "Apple QuickTake Picture"
        ${UnRegisterExtension} "r3d" "RED R3D file format"
        ${UnRegisterExtension} "raf" "Fuji CCD Raw Image Format"
        ${UnRegisterExtension} "raw" "Leica Raw Image Format"
        ${UnRegisterExtension} "rwl" "Leica Raw Image Format"
        ${UnRegisterExtension} "rdc" "Rollei RAW Image"
        ${UnRegisterExtension} "rgba" "SGI images"
        ${UnRegisterExtension} "rgb" "SGI images"
        ${UnRegisterExtension} "sgi" "SGI images"
        ${UnRegisterExtension} "bw" "SGI images"
        ${UnRegisterExtension} "rgbe" "Radiance RGBE image format"
        ${UnRegisterExtension} "hdr" "Radiance RGBE image format"
        ${UnRegisterExtension} "rad" "Radiance RGBE image format"
        ${UnRegisterExtension} "rgf" "LEGO Mindstorms EV3 Robot Graphics File"
        ${UnRegisterExtension} "rla" "Wavefront RLA File Format"
        ${UnRegisterExtension} "rle" "Utah Run length encoded image file"
        ${UnRegisterExtension} "rw2" "Panasonic Raw Image Format"
        ${UnRegisterExtension} "rwz" "Rawzor RAW image"
        ${UnRegisterExtension} "scr" "ZX-Spectrum SCREEN"
        ${UnRegisterExtension} "sct" "Scitex Continuous Tone Picture"
        ${UnRegisterExtension} "ch" "Scitex Continuous Tone Picture"
        ${UnRegisterExtension} "ct" "Scitex Continuous Tone Picture"
        ${UnRegisterExtension} "sfw" "Seattle File Works image"
        ${UnRegisterExtension} "alb" "Seattle File Works image"
        ${UnRegisterExtension} "pwm" "Seattle File Works image"
        ${UnRegisterExtension} "pwp" "Seattle File Works image"
        ${UnRegisterExtension} "sixel" "DEC SIXEL Graphics Format"
        ${UnRegisterExtension} "srf" "Sony (Minolta) Raw Image Format"
        ${UnRegisterExtension} "mrw" "Sony (Minolta) Raw Image Format"
        ${UnRegisterExtension} "sr2" "Sony (Minolta) Raw Image Format"
        ${UnRegisterExtension} "arq" "Sony (Minolta) Raw Image Format"
        ${UnRegisterExtension} "srw" "Samsung Raw Image Format"
        ${UnRegisterExtension} "sti" "Sinar CaptureShop RAW image"
        ${UnRegisterExtension} "sun" "SUN Rasterfile"
        ${UnRegisterExtension} "ras" "SUN Rasterfile"
        ${UnRegisterExtension} "sr" "SUN Rasterfile"
        ${UnRegisterExtension} "im1" "SUN Rasterfile"
        ${UnRegisterExtension} "im24" "SUN Rasterfile"
        ${UnRegisterExtension} "im32" "SUN Rasterfile"
        ${UnRegisterExtension} "im8" "SUN Rasterfile"
        ${UnRegisterExtension} "rast" "SUN Rasterfile"
        ${UnRegisterExtension} "rs" "SUN Rasterfile"
        ${UnRegisterExtension} "scr" "SUN Rasterfile"
        ${UnRegisterExtension} "svg" "Scalable Vector Graphics"
        ${UnRegisterExtension} "svgz" "Scalable Vector Graphics"
        ${UnRegisterExtension} "tar" "TAR file format"
        ${UnRegisterExtension} "tga" "Truevision Targa image"
        ${UnRegisterExtension} "icb" "Truevision Targa image"
        ${UnRegisterExtension} "vda" "Truevision Targa image"
        ${UnRegisterExtension} "vst" "Truevision Targa image"
        ${UnRegisterExtension} "tiff" "Tagged Image File Format"
        ${UnRegisterExtension} "tif" "Tagged Image File Format"
        ${UnRegisterExtension} "tim" "PSX TIM (PlayStation Graphics)"
        ${UnRegisterExtension} "ttf" "TrueType font file"
        ${UnRegisterExtension} "vicar" "VICAR rasterfile format"
        ${UnRegisterExtension} "vic" "VICAR rasterfile format"
        ${UnRegisterExtension} "img" "VICAR rasterfile format"
        ${UnRegisterExtension} "viff" "Khoros Visualization Image File Format"
        ${UnRegisterExtension} "xv" "Khoros Visualization Image File Format"
        ${UnRegisterExtension} "vtf" "Valve Texture Format"
        ${UnRegisterExtension} "wbmp" "Wireless Bitmap"
        ${UnRegisterExtension} "webp" "Google web image format"
        ${UnRegisterExtension} "wmf" "Windows Metafile"
        ${UnRegisterExtension} "wmz" "Windows Metafile"
        ${UnRegisterExtension} "apm" "Windows Metafile"
        ${UnRegisterExtension} "wpg" "Word Perfect Graphics File"
        ${UnRegisterExtension} "x3f" "Sigma Digital Camera Raw Image"
        ${UnRegisterExtension} "xbm" "X BitMap"
        ${UnRegisterExtension} "bm" "X BitMap"
        ${UnRegisterExtension} "xpm" "X PixMap"
        ${UnRegisterExtension} "pm" "X PixMap"
        ${UnRegisterExtension} "xwd" "X Windows system window dump"

        WriteRegStr HKCU "Software\PhotoQt" "fileformats" ""

    ${EndIf}

    ${If} $un_fileformats_pdfps == "registered"

        ${UnRegisterExtension} "eps" "Encapsulated PostScript"
        ${UnRegisterExtension} "epsf" "Encapsulated PostScript"
        ${UnRegisterExtension} "epsi" "Encapsulated PostScript"
        ${UnRegisterExtension} "pdf" "Adobe Portable Document Format"
        ${UnRegisterExtension} "ps" "Adobe Level III PostScript file"
        ${UnRegisterExtension} "ps2" "Adobe Level III PostScript file"
        ${UnRegisterExtension} "ps3" "Adobe Level III PostScript file"


        WriteRegStr HKCU "Software\PhotoQt" "fileformats_pdfps" ""

    ${EndIf}

    ${If} $un_fileformats_psdxcf == "registered"

        ${UnRegisterExtension} "psd" "Adobe PhotoShop"
        ${UnRegisterExtension} "psb" "Adobe PhotoShop"
        ${UnRegisterExtension} "psdt" "Adobe PhotoShop"
        ${UnRegisterExtension} "xcf" "Gimp XCF"


        WriteRegStr HKCU "Software\PhotoQt" "fileformats_psdxcf" ""

    ${EndIf}

    SetShellVarContext all
    Delete "$SMPROGRAMS\PhotoQt.lnk"
    Delete "$desktop\PhotoQt.lnk"

    ;begin uninstall
    !insertmacro UNINSTALL.NEW_UNINSTALL "$OUTDIR"

    DeleteRegKey ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}"
    DeleteRegKey HKCU "Software\PhotoQt"

    System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v (0x08000000, 0, 0, 0)'

SectionEnd
