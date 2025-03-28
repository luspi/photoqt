;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Copyright (C) 2011-2025 Lukas Spies
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

        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".3fr" "3frfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".fff" "ffffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".aai" "aaifile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ai" "aifile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ani" "anifile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".apng" "apngfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ari" "arifile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".art" "artfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".arw" "arwfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".asf" "asffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".avif" "aviffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".avifs" "avifsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".avs" "avsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".x" "xfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mbfavs" "mbfavsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".bay" "bayfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".bmp" "bmpfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dib" "dibfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".bmq" "bmqfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".bpg" "bpgfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cals" "calsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ct1" "ct1file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ct2" "ct2file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ct3" "ct3file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ct4" "ct4file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".c4" "c4file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cal" "calfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".nif" "niffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ras" "rasfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cap" "capfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".eip" "eipfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".liq" "liqfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".iiq" "iiqfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cb7" "cb7file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cbr" "cbrfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cbt" "cbtfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cbz" "cbzfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cg3" "cg3file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".g3" "g3file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cine" "cinefile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".crw" "crwfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".crr" "crrfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cr2" "cr2file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cr3" "cr3file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cs1" "cs1file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cube" "cubefile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cur" "curfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".cut" "cutfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pal" "palfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dcr" "dcrfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".kdc" "kdcfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".drf" "drffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".k25" "k25file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dcs" "dcsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dc2" "dc2file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".kc2" "kc2file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dcx" "dcxfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dds" "ddsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dfont" "dfontfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dic" "dicfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dcm" "dcmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".djvu" "djvufile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".djv" "djvfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dng" "dngfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dpx" "dpxfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".dxo" "dxofile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".erf" "erffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".exr" "exrfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ff" "fffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".fits" "fitsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".fit" "fitfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".fts" "ftsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".fl32" "fl32file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ftx" "ftxfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".gif" "giffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".gpr" "gprfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".heif" "heiffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".heic" "heicfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".hrz" "hrzfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".icns" "icnsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ico" "icofile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".iff" "ifffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jbig" "jbigfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jbg" "jbgfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".bie" "biefile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jfif" "jfiffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jng" "jngfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jpeg" "jpegfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jpg" "jpgfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jpe" "jpefile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jif" "jiffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jpeg2000" "jpeg2000file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".j2k" "j2kfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jp2" "jp2file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jpc" "jpcfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jpx" "jpxfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jxl" "jxlfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".jxr" "jxrfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".hdp" "hdpfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".wdp" "wdpfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".koa" "koafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".gg" "ggfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".gig" "gigfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".kla" "klafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".kra" "krafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".lbm" "lbmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mat" "matfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mdc" "mdcfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mef" "meffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mfw" "mfwfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".miff" "mifffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mif" "miffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mng" "mngfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mos" "mosfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mpc" "mpcfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mtv" "mtvfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pic" "picfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mvg" "mvgfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".nef" "neffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".nrw" "nrwfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".obm" "obmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ora" "orafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".orf" "orffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ori" "orifile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".otb" "otbfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".otf" "otffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".otc" "otcfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ttf" "ttffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ttc" "ttcfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".p7" "p7file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".palm" "palmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pam" "pamfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pbm" "pbmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pcd" "pcdfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pcds" "pcdsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pcx" "pcxfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pdb" "pdbfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pdd" "pddfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pef" "peffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ptx" "ptxfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pes" "pesfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pfb" "pfbfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pfm" "pfmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".afm" "afmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".inf" "inffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pfa" "pfafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ofm" "ofmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pfm" "pfmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pgm" "pgmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pgx" "pgxfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".phm" "phmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pic" "picfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".picon" "piconfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pict" "pictfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pct" "pctfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pic" "picfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pix" "pixfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".als" "alsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".alias" "aliasfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".png" "pngfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ppm" "ppmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pnm" "pnmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ptiff" "ptifffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ptif" "ptiffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pxn" "pxnfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pxr" "pxrfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".qoi" "qoifile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".qtk" "qtkfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".r3d" "r3dfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".raf" "raffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".raw" "rawfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rwl" "rwlfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rdc" "rdcfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rgba" "rgbafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rgb" "rgbfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".sgi" "sgifile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".bw" "bwfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rgbe" "rgbefile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".hdr" "hdrfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rad" "radfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rgf" "rgffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rla" "rlafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rle" "rlefile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rw2" "rw2file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rwz" "rwzfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".scr" "scrfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".sct" "sctfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ch" "chfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ct" "ctfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".sfw" "sfwfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".alb" "albfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pwm" "pwmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pwp" "pwpfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".sixel" "sixelfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".srf" "srffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".mrw" "mrwfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".sr2" "sr2file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".arq" "arqfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".srw" "srwfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".sti" "stifile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".sun" "sunfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ras" "rasfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".sr" "srfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".im1" "im1file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".im24" "im24file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".im32" "im32file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".im8" "im8file"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rast" "rastfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".rs" "rsfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".scr" "scrfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".svg" "svgfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".svgz" "svgzfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".tar" "tarfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".tga" "tgafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".icb" "icbfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".vda" "vdafile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".vst" "vstfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".tiff" "tifffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".tif" "tiffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".tim" "timfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ttf" "ttffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".vicar" "vicarfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".vic" "vicfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".img" "imgfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".viff" "vifffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".xv" "xvfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".vtf" "vtffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".wbmp" "wbmpfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".webp" "webpfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".wmf" "wmffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".wmz" "wmzfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".apm" "apmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".wpg" "wpgfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".x3f" "x3ffile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".xbm" "xbmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".bm" "bmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".xpm" "xpmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pm" "pmfile"
        ${RegisterExtension} "$INSTDIR\photoqt.exe" ".xwd" "xwdfile"


        ${If} $CheckboxPdfPs_State == ${BST_CHECKED}

            WriteRegStr HKCU "Software\PhotoQt" "fileformats_pdfps" "registered"

            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".eps" "epsfile"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".epsf" "epsffile"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".epsi" "epsifile"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".pdf" "pdffile"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ps" "psfile"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ps2" "ps2file"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".ps3" "ps3file"


        ${Else}

            ; if it was registered in a previous install, we need to de-register it here
            Var /GLOBAL fileformats_pdfps
            ReadRegStr $fileformats_pdfps HKCU "Software\PhotoQt" "fileformats_pdfps"
            ${If} $fileformats_pdfps == "registered"

                ${UnRegisterExtension} ".eps" "epsfile"
                ${UnRegisterExtension} ".epsf" "epsffile"
                ${UnRegisterExtension} ".epsi" "epsifile"
                ${UnRegisterExtension} ".pdf" "pdffile"
                ${UnRegisterExtension} ".ps" "psfile"
                ${UnRegisterExtension} ".ps2" "ps2file"
                ${UnRegisterExtension} ".ps3" "ps3file"


            ${EndIf}

            WriteRegStr HKCU "Software\PhotoQt" "fileformats_pdfps" ""

        ${EndIf}

        ${If} $CheckboxPsdXcf_State == ${BST_CHECKED}

            WriteRegStr HKCU "Software\PhotoQt" "fileformats_psdxcf" "registered"

            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".psd" "psdfile"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".psb" "psbfile"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".psdt" "psdtfile"
            ${RegisterExtension} "$INSTDIR\photoqt.exe" ".xcf" "xcffile"


        ${Else}

            ; if it was registered in a previous install, we need to de-register it here
            Var /GLOBAL fileformats_psdxcf
            ReadRegStr $fileformats_psdxcf HKCU "Software\PhotoQt" "fileformats_psdxcf"
            ${If} $fileformats_psdxcf == "registered"

                ${UnRegisterExtension} ".psd" "psdfile"
                ${UnRegisterExtension} ".psb" "psbfile"
                ${UnRegisterExtension} ".psdt" "psdtfile"
                ${UnRegisterExtension} ".xcf" "xcffile"


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

        ${UnRegisterExtension} ".3fr" "3frfile"
        ${UnRegisterExtension} ".fff" "ffffile"
        ${UnRegisterExtension} ".aai" "aaifile"
        ${UnRegisterExtension} ".ai" "aifile"
        ${UnRegisterExtension} ".ani" "anifile"
        ${UnRegisterExtension} ".apng" "apngfile"
        ${UnRegisterExtension} ".ari" "arifile"
        ${UnRegisterExtension} ".art" "artfile"
        ${UnRegisterExtension} ".arw" "arwfile"
        ${UnRegisterExtension} ".asf" "asffile"
        ${UnRegisterExtension} ".avif" "aviffile"
        ${UnRegisterExtension} ".avifs" "avifsfile"
        ${UnRegisterExtension} ".avs" "avsfile"
        ${UnRegisterExtension} ".x" "xfile"
        ${UnRegisterExtension} ".mbfavs" "mbfavsfile"
        ${UnRegisterExtension} ".bay" "bayfile"
        ${UnRegisterExtension} ".bmp" "bmpfile"
        ${UnRegisterExtension} ".dib" "dibfile"
        ${UnRegisterExtension} ".bmq" "bmqfile"
        ${UnRegisterExtension} ".bpg" "bpgfile"
        ${UnRegisterExtension} ".cals" "calsfile"
        ${UnRegisterExtension} ".ct1" "ct1file"
        ${UnRegisterExtension} ".ct2" "ct2file"
        ${UnRegisterExtension} ".ct3" "ct3file"
        ${UnRegisterExtension} ".ct4" "ct4file"
        ${UnRegisterExtension} ".c4" "c4file"
        ${UnRegisterExtension} ".cal" "calfile"
        ${UnRegisterExtension} ".nif" "niffile"
        ${UnRegisterExtension} ".ras" "rasfile"
        ${UnRegisterExtension} ".cap" "capfile"
        ${UnRegisterExtension} ".eip" "eipfile"
        ${UnRegisterExtension} ".liq" "liqfile"
        ${UnRegisterExtension} ".iiq" "iiqfile"
        ${UnRegisterExtension} ".cb7" "cb7file"
        ${UnRegisterExtension} ".cbr" "cbrfile"
        ${UnRegisterExtension} ".cbt" "cbtfile"
        ${UnRegisterExtension} ".cbz" "cbzfile"
        ${UnRegisterExtension} ".cg3" "cg3file"
        ${UnRegisterExtension} ".g3" "g3file"
        ${UnRegisterExtension} ".cine" "cinefile"
        ${UnRegisterExtension} ".crw" "crwfile"
        ${UnRegisterExtension} ".crr" "crrfile"
        ${UnRegisterExtension} ".cr2" "cr2file"
        ${UnRegisterExtension} ".cr3" "cr3file"
        ${UnRegisterExtension} ".cs1" "cs1file"
        ${UnRegisterExtension} ".cube" "cubefile"
        ${UnRegisterExtension} ".cur" "curfile"
        ${UnRegisterExtension} ".cut" "cutfile"
        ${UnRegisterExtension} ".pal" "palfile"
        ${UnRegisterExtension} ".dcr" "dcrfile"
        ${UnRegisterExtension} ".kdc" "kdcfile"
        ${UnRegisterExtension} ".drf" "drffile"
        ${UnRegisterExtension} ".k25" "k25file"
        ${UnRegisterExtension} ".dcs" "dcsfile"
        ${UnRegisterExtension} ".dc2" "dc2file"
        ${UnRegisterExtension} ".kc2" "kc2file"
        ${UnRegisterExtension} ".dcx" "dcxfile"
        ${UnRegisterExtension} ".dds" "ddsfile"
        ${UnRegisterExtension} ".dfont" "dfontfile"
        ${UnRegisterExtension} ".dic" "dicfile"
        ${UnRegisterExtension} ".dcm" "dcmfile"
        ${UnRegisterExtension} ".djvu" "djvufile"
        ${UnRegisterExtension} ".djv" "djvfile"
        ${UnRegisterExtension} ".dng" "dngfile"
        ${UnRegisterExtension} ".dpx" "dpxfile"
        ${UnRegisterExtension} ".dxo" "dxofile"
        ${UnRegisterExtension} ".erf" "erffile"
        ${UnRegisterExtension} ".exr" "exrfile"
        ${UnRegisterExtension} ".ff" "fffile"
        ${UnRegisterExtension} ".fits" "fitsfile"
        ${UnRegisterExtension} ".fit" "fitfile"
        ${UnRegisterExtension} ".fts" "ftsfile"
        ${UnRegisterExtension} ".fl32" "fl32file"
        ${UnRegisterExtension} ".ftx" "ftxfile"
        ${UnRegisterExtension} ".gif" "giffile"
        ${UnRegisterExtension} ".gpr" "gprfile"
        ${UnRegisterExtension} ".heif" "heiffile"
        ${UnRegisterExtension} ".heic" "heicfile"
        ${UnRegisterExtension} ".hrz" "hrzfile"
        ${UnRegisterExtension} ".icns" "icnsfile"
        ${UnRegisterExtension} ".ico" "icofile"
        ${UnRegisterExtension} ".iff" "ifffile"
        ${UnRegisterExtension} ".jbig" "jbigfile"
        ${UnRegisterExtension} ".jbg" "jbgfile"
        ${UnRegisterExtension} ".bie" "biefile"
        ${UnRegisterExtension} ".jfif" "jfiffile"
        ${UnRegisterExtension} ".jng" "jngfile"
        ${UnRegisterExtension} ".jpeg" "jpegfile"
        ${UnRegisterExtension} ".jpg" "jpgfile"
        ${UnRegisterExtension} ".jpe" "jpefile"
        ${UnRegisterExtension} ".jif" "jiffile"
        ${UnRegisterExtension} ".jpeg2000" "jpeg2000file"
        ${UnRegisterExtension} ".j2k" "j2kfile"
        ${UnRegisterExtension} ".jp2" "jp2file"
        ${UnRegisterExtension} ".jpc" "jpcfile"
        ${UnRegisterExtension} ".jpx" "jpxfile"
        ${UnRegisterExtension} ".jxl" "jxlfile"
        ${UnRegisterExtension} ".jxr" "jxrfile"
        ${UnRegisterExtension} ".hdp" "hdpfile"
        ${UnRegisterExtension} ".wdp" "wdpfile"
        ${UnRegisterExtension} ".koa" "koafile"
        ${UnRegisterExtension} ".gg" "ggfile"
        ${UnRegisterExtension} ".gig" "gigfile"
        ${UnRegisterExtension} ".kla" "klafile"
        ${UnRegisterExtension} ".kra" "krafile"
        ${UnRegisterExtension} ".lbm" "lbmfile"
        ${UnRegisterExtension} ".mat" "matfile"
        ${UnRegisterExtension} ".mdc" "mdcfile"
        ${UnRegisterExtension} ".mef" "meffile"
        ${UnRegisterExtension} ".mfw" "mfwfile"
        ${UnRegisterExtension} ".miff" "mifffile"
        ${UnRegisterExtension} ".mif" "miffile"
        ${UnRegisterExtension} ".mng" "mngfile"
        ${UnRegisterExtension} ".mos" "mosfile"
        ${UnRegisterExtension} ".mpc" "mpcfile"
        ${UnRegisterExtension} ".mtv" "mtvfile"
        ${UnRegisterExtension} ".pic" "picfile"
        ${UnRegisterExtension} ".mvg" "mvgfile"
        ${UnRegisterExtension} ".nef" "neffile"
        ${UnRegisterExtension} ".nrw" "nrwfile"
        ${UnRegisterExtension} ".obm" "obmfile"
        ${UnRegisterExtension} ".ora" "orafile"
        ${UnRegisterExtension} ".orf" "orffile"
        ${UnRegisterExtension} ".ori" "orifile"
        ${UnRegisterExtension} ".otb" "otbfile"
        ${UnRegisterExtension} ".otf" "otffile"
        ${UnRegisterExtension} ".otc" "otcfile"
        ${UnRegisterExtension} ".ttf" "ttffile"
        ${UnRegisterExtension} ".ttc" "ttcfile"
        ${UnRegisterExtension} ".p7" "p7file"
        ${UnRegisterExtension} ".palm" "palmfile"
        ${UnRegisterExtension} ".pam" "pamfile"
        ${UnRegisterExtension} ".pbm" "pbmfile"
        ${UnRegisterExtension} ".pcd" "pcdfile"
        ${UnRegisterExtension} ".pcds" "pcdsfile"
        ${UnRegisterExtension} ".pcx" "pcxfile"
        ${UnRegisterExtension} ".pdb" "pdbfile"
        ${UnRegisterExtension} ".pdd" "pddfile"
        ${UnRegisterExtension} ".pef" "peffile"
        ${UnRegisterExtension} ".ptx" "ptxfile"
        ${UnRegisterExtension} ".pes" "pesfile"
        ${UnRegisterExtension} ".pfb" "pfbfile"
        ${UnRegisterExtension} ".pfm" "pfmfile"
        ${UnRegisterExtension} ".afm" "afmfile"
        ${UnRegisterExtension} ".inf" "inffile"
        ${UnRegisterExtension} ".pfa" "pfafile"
        ${UnRegisterExtension} ".ofm" "ofmfile"
        ${UnRegisterExtension} ".pfm" "pfmfile"
        ${UnRegisterExtension} ".pgm" "pgmfile"
        ${UnRegisterExtension} ".pgx" "pgxfile"
        ${UnRegisterExtension} ".phm" "phmfile"
        ${UnRegisterExtension} ".pic" "picfile"
        ${UnRegisterExtension} ".picon" "piconfile"
        ${UnRegisterExtension} ".pict" "pictfile"
        ${UnRegisterExtension} ".pct" "pctfile"
        ${UnRegisterExtension} ".pic" "picfile"
        ${UnRegisterExtension} ".pix" "pixfile"
        ${UnRegisterExtension} ".als" "alsfile"
        ${UnRegisterExtension} ".alias" "aliasfile"
        ${UnRegisterExtension} ".png" "pngfile"
        ${UnRegisterExtension} ".ppm" "ppmfile"
        ${UnRegisterExtension} ".pnm" "pnmfile"
        ${UnRegisterExtension} ".ptiff" "ptifffile"
        ${UnRegisterExtension} ".ptif" "ptiffile"
        ${UnRegisterExtension} ".pxn" "pxnfile"
        ${UnRegisterExtension} ".pxr" "pxrfile"
        ${UnRegisterExtension} ".qoi" "qoifile"
        ${UnRegisterExtension} ".qtk" "qtkfile"
        ${UnRegisterExtension} ".r3d" "r3dfile"
        ${UnRegisterExtension} ".raf" "raffile"
        ${UnRegisterExtension} ".raw" "rawfile"
        ${UnRegisterExtension} ".rwl" "rwlfile"
        ${UnRegisterExtension} ".rdc" "rdcfile"
        ${UnRegisterExtension} ".rgba" "rgbafile"
        ${UnRegisterExtension} ".rgb" "rgbfile"
        ${UnRegisterExtension} ".sgi" "sgifile"
        ${UnRegisterExtension} ".bw" "bwfile"
        ${UnRegisterExtension} ".rgbe" "rgbefile"
        ${UnRegisterExtension} ".hdr" "hdrfile"
        ${UnRegisterExtension} ".rad" "radfile"
        ${UnRegisterExtension} ".rgf" "rgffile"
        ${UnRegisterExtension} ".rla" "rlafile"
        ${UnRegisterExtension} ".rle" "rlefile"
        ${UnRegisterExtension} ".rw2" "rw2file"
        ${UnRegisterExtension} ".rwz" "rwzfile"
        ${UnRegisterExtension} ".scr" "scrfile"
        ${UnRegisterExtension} ".sct" "sctfile"
        ${UnRegisterExtension} ".ch" "chfile"
        ${UnRegisterExtension} ".ct" "ctfile"
        ${UnRegisterExtension} ".sfw" "sfwfile"
        ${UnRegisterExtension} ".alb" "albfile"
        ${UnRegisterExtension} ".pwm" "pwmfile"
        ${UnRegisterExtension} ".pwp" "pwpfile"
        ${UnRegisterExtension} ".sixel" "sixelfile"
        ${UnRegisterExtension} ".srf" "srffile"
        ${UnRegisterExtension} ".mrw" "mrwfile"
        ${UnRegisterExtension} ".sr2" "sr2file"
        ${UnRegisterExtension} ".arq" "arqfile"
        ${UnRegisterExtension} ".srw" "srwfile"
        ${UnRegisterExtension} ".sti" "stifile"
        ${UnRegisterExtension} ".sun" "sunfile"
        ${UnRegisterExtension} ".ras" "rasfile"
        ${UnRegisterExtension} ".sr" "srfile"
        ${UnRegisterExtension} ".im1" "im1file"
        ${UnRegisterExtension} ".im24" "im24file"
        ${UnRegisterExtension} ".im32" "im32file"
        ${UnRegisterExtension} ".im8" "im8file"
        ${UnRegisterExtension} ".rast" "rastfile"
        ${UnRegisterExtension} ".rs" "rsfile"
        ${UnRegisterExtension} ".scr" "scrfile"
        ${UnRegisterExtension} ".svg" "svgfile"
        ${UnRegisterExtension} ".svgz" "svgzfile"
        ${UnRegisterExtension} ".tar" "tarfile"
        ${UnRegisterExtension} ".tga" "tgafile"
        ${UnRegisterExtension} ".icb" "icbfile"
        ${UnRegisterExtension} ".vda" "vdafile"
        ${UnRegisterExtension} ".vst" "vstfile"
        ${UnRegisterExtension} ".tiff" "tifffile"
        ${UnRegisterExtension} ".tif" "tiffile"
        ${UnRegisterExtension} ".tim" "timfile"
        ${UnRegisterExtension} ".ttf" "ttffile"
        ${UnRegisterExtension} ".vicar" "vicarfile"
        ${UnRegisterExtension} ".vic" "vicfile"
        ${UnRegisterExtension} ".img" "imgfile"
        ${UnRegisterExtension} ".viff" "vifffile"
        ${UnRegisterExtension} ".xv" "xvfile"
        ${UnRegisterExtension} ".vtf" "vtffile"
        ${UnRegisterExtension} ".wbmp" "wbmpfile"
        ${UnRegisterExtension} ".webp" "webpfile"
        ${UnRegisterExtension} ".wmf" "wmffile"
        ${UnRegisterExtension} ".wmz" "wmzfile"
        ${UnRegisterExtension} ".apm" "apmfile"
        ${UnRegisterExtension} ".wpg" "wpgfile"
        ${UnRegisterExtension} ".x3f" "x3ffile"
        ${UnRegisterExtension} ".xbm" "xbmfile"
        ${UnRegisterExtension} ".bm" "bmfile"
        ${UnRegisterExtension} ".xpm" "xpmfile"
        ${UnRegisterExtension} ".pm" "pmfile"
        ${UnRegisterExtension} ".xwd" "xwdfile"

        WriteRegStr HKCU "Software\PhotoQt" "fileformats" ""

    ${EndIf}

    ${If} $un_fileformats_pdfps == "registered"

        ${UnRegisterExtension} ".eps" "epsfile"
        ${UnRegisterExtension} ".epsf" "epsffile"
        ${UnRegisterExtension} ".epsi" "epsifile"
        ${UnRegisterExtension} ".pdf" "pdffile"
        ${UnRegisterExtension} ".ps" "psfile"
        ${UnRegisterExtension} ".ps2" "ps2file"
        ${UnRegisterExtension} ".ps3" "ps3file"


        WriteRegStr HKCU "Software\PhotoQt" "fileformats_pdfps" ""

    ${EndIf}

    ${If} $un_fileformats_psdxcf == "registered"

        ${UnRegisterExtension} ".psd" "psdfile"
        ${UnRegisterExtension} ".psb" "psbfile"
        ${UnRegisterExtension} ".psdt" "psdtfile"
        ${UnRegisterExtension} ".xcf" "xcffile"


        WriteRegStr HKCU "Software\PhotoQt" "fileformats_psdxcf" ""

    ${EndIf}

    SetShellVarContext all
    Delete "$SMPROGRAMS\PhotoQt.lnk"
    Delete "$desktop\PhotoQt.lnk"

    ;begin uninstall
    !insertmacro UNINSTALL.NEW_UNINSTALL "$OUTDIR"

    DeleteRegKey ${INSTDIR_REG_ROOT} "${INSTDIR_REG_KEY}"
    DeleteRegKey HKCU "Software\PhotoQt"

    ; Remove environment variables
    EnVar::Delete "PHOTOQT_MAGICK_CODER_MODULE_PATH"
    EnVar::Delete "PHOTOQT_MAGICK_FILTER_MODULE_PATH"

    System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v (0x08000000, 0, 0, 0)'

SectionEnd
