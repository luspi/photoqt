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

!insertmacro MUI_PAGE_WELCOME
Page custom OldInstallInit OldInstallLeave
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

    File /r /x *nsh /x *nsi /x *qmlc /x photoqt-setup.exe ".\"

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

Var OldInstallDialog
Var OldInstallLabel1
Var OldInstallLabel2
Var OldInstallLabel3
Var OldInstallCheck
Var OldInstallCheckState
Var OldInstallNext

Function OldInstallInit

    IfFileExists "$INSTDIR\photoqt.exe" +2 0
        Abort

    !insertmacro MUI_HEADER_TEXT "Previous Version installed" "Your help is needed with starting this installer."

    nsDialogs::Create 1018
    Pop $OldInstallDialog
    ${If} $OldInstallDialog == error
        Abort
    ${EndIf}
    
    GetDlgItem $OldInstallNext $HWNDPARENT 1 ; This returns a handle to the NEXT button.
    EnableWindow $OldInstallNext 0 ; this should disable the next button.
    
    CreateFont $0 "$(^Font)" "8" "700"; size 8 weight 700 makes it bold 
    
    ${NSD_CreateLabel} 0 0 100% 24u "A previous version of PhotoQt seems to currently be installed. Starting with v2.4, PhotoQt has changed the way it keeps track of installed files."
    Pop $OldInstallLabel1
    
    ${NSD_CreateLabel} 0 28u 100% 24u "It is highlighy recommeded to first uninstall any version prior to v2.4."
    Pop $OldInstallLabel2
;     SendMessage $OldInstallLabel2 ${WM_SETFONT} $0 0
    
    ${NSD_CreateLabel} 0 48u 100% 24u "To uninstall, either let this installer wait here in the meantime, or cancel this installer and restart it after the old version is uninstalled. My apologies for this inconvenience!"
    Pop $OldInstallLabel3
    
    ${NSD_CreateCheckbox} 0 74u 100% 12u "Proceed with the installer"
    Pop $OldInstallCheck
    ${NSD_OnClick} $OldInstallCheck OldInstallerCheckChange

    nsDialogs::Show

FunctionEnd

Function OldInstallerCheckChange

    ${NSD_GetState} $OldInstallCheck $OldInstallCheckState
    ${If} $OldInstallCheckState == ${BST_CHECKED}
        EnableWindow $OldInstallNext 1
    ${Else}
        EnableWindow $OldInstallNext 0
    ${EndIf}
FunctionEnd

Function OldInstallLeave
    ; nothing needed here
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

    ${If} $RadioButtonAll_State == ${BST_CHECKED}

        WriteRegStr HKCU "Software\PhotoQt" "fileformats" "all"

        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".3fr" "Hasselblad Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".7z" "7z file format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".aai" "AAI Dune image"
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
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pic" "Dr. Halo"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dcr" "Kodak Cineon Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".kdc" "Kodak Cineon Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".drf" "Kodak Cineon Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".k25" "Kodak Cineon Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dcs" "Kodak Cineon Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dcx" "ZSoft IBM PC multi-page Paintbrush image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dds" "DirectDraw Surface"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dib" "Microsoft Windows Device-Independent bitmap"
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
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".heif" "Apple High Efficiency Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".heic" "Apple High Efficiency Image Format"
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
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pfm" "Portable Float Map"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pgm" "Portable graymap format (gray scale)"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".phm" "Portable float map format 16-bit half"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pic" "Softimage PIC"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".picon" "Personal Icon"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pict" "QuickDraw/PICT"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pct" "QuickDraw/PICT"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pic" "QuickDraw/PICT"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pix" "Alias/Wavefront RLE image format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".als" "Alias/Wavefront RLE image format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".png" "Portable Network Graphics"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ppm" "Portable pixmap format (color)"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pnm" "Portable pixmap format (color)"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ptiff" "Pyramid encoded TIFF"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ptif" "Pyramid encoded TIFF"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pxn" "Logitech Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".raf" "Fuji CCD Raw Image Format"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rar" "RAR file format"
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
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".sct" "Scitex Continuous Tone Picture"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ch" "Scitex Continuous Tone Picture"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ct" "Scitex Continuous Tone Picture"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".sfw" "Seattle File Works image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".alb" "Seattle File Works image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pwm" "Seattle File Works image"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pwp" "Seattle File Works image"
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
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".zip" "ZIP file format"

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
        ${UnRegisterExtension} ".7z" "7z file format"
        ${UnRegisterExtension} ".aai" "AAI Dune image"
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
        ${UnRegisterExtension} ".pic" "Dr. Halo"
        ${UnRegisterExtension} ".dcr" "Kodak Cineon Raw Image Format"
        ${UnRegisterExtension} ".kdc" "Kodak Cineon Raw Image Format"
        ${UnRegisterExtension} ".drf" "Kodak Cineon Raw Image Format"
        ${UnRegisterExtension} ".k25" "Kodak Cineon Raw Image Format"
        ${UnRegisterExtension} ".dcs" "Kodak Cineon Raw Image Format"
        ${UnRegisterExtension} ".dcx" "ZSoft IBM PC multi-page Paintbrush image"
        ${UnRegisterExtension} ".dds" "DirectDraw Surface"
        ${UnRegisterExtension} ".dib" "Microsoft Windows Device-Independent bitmap"
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
        ${UnRegisterExtension} ".heif" "Apple High Efficiency Image Format"
        ${UnRegisterExtension} ".heic" "Apple High Efficiency Image Format"
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
        ${UnRegisterExtension} ".pfm" "Portable Float Map"
        ${UnRegisterExtension} ".pgm" "Portable graymap format (gray scale)"
        ${UnRegisterExtension} ".phm" "Portable float map format 16-bit half"
        ${UnRegisterExtension} ".pic" "Softimage PIC"
        ${UnRegisterExtension} ".picon" "Personal Icon"
        ${UnRegisterExtension} ".pict" "QuickDraw/PICT"
        ${UnRegisterExtension} ".pct" "QuickDraw/PICT"
        ${UnRegisterExtension} ".pic" "QuickDraw/PICT"
        ${UnRegisterExtension} ".pix" "Alias/Wavefront RLE image format"
        ${UnRegisterExtension} ".als" "Alias/Wavefront RLE image format"
        ${UnRegisterExtension} ".png" "Portable Network Graphics"
        ${UnRegisterExtension} ".ppm" "Portable pixmap format (color)"
        ${UnRegisterExtension} ".pnm" "Portable pixmap format (color)"
        ${UnRegisterExtension} ".ptiff" "Pyramid encoded TIFF"
        ${UnRegisterExtension} ".ptif" "Pyramid encoded TIFF"
        ${UnRegisterExtension} ".pxn" "Logitech Raw Image Format"
        ${UnRegisterExtension} ".raf" "Fuji CCD Raw Image Format"
        ${UnRegisterExtension} ".rar" "RAR file format"
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
        ${UnRegisterExtension} ".sct" "Scitex Continuous Tone Picture"
        ${UnRegisterExtension} ".ch" "Scitex Continuous Tone Picture"
        ${UnRegisterExtension} ".ct" "Scitex Continuous Tone Picture"
        ${UnRegisterExtension} ".sfw" "Seattle File Works image"
        ${UnRegisterExtension} ".alb" "Seattle File Works image"
        ${UnRegisterExtension} ".pwm" "Seattle File Works image"
        ${UnRegisterExtension} ".pwp" "Seattle File Works image"
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
        ${UnRegisterExtension} ".zip" "ZIP file format"

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
    !insertmacro UNINSTALL.LOG_BEGIN_UNINSTALL

    ;uninstall from path, must be repeated for every install logged path individual
    !insertmacro UNINSTALL.LOG_UNINSTALL "$INSTDIR"

    ;end uninstall, after uninstall from all logged paths has been performed
    !insertmacro UNINSTALL.LOG_END_UNINSTALL
    
    DeleteRegKey ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}"
    
    System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v (0x08000000, 0, 0, 0)'

SectionEnd
