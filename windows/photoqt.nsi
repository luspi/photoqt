; NSIS Modern User Interface
; PhotoQT Setup

;--------------------------------
; INCLUDES

	; Include Modern UI
	!include MUI2.nsh

	; Include Uninstall Log to keep track of installed files
	!include "UninstallLog.nsh"

	; Include stuff for nsdialog
	!include LogicLib.nsh
	!include nsDialogs.nsh

	; Register app for filetypes
	!include "FileAssociation.nsh"

	; For 32/64-Bit detection
	!include x64.nsh

;--------------------------------
; GENERAL

	; Name and file
	Name "PhotoQt"
	OutFile "photoqt-1.4.exe"

	; Default installation folder
	InstallDir "$PROGRAMFILES\PhotoQt"

	; Get installation folder from registry if available
	InstallDirRegKey HKCU "Software\PhotoQt" ""

	; Request application privileges for Windows Vista
	RequestExecutionLevel admin

;--------------------------------
; INTERFACE SETTINGS

	!define MUI_ABORTWARNING
	!define MUI_ICON "icon_install.ico"

	;Show all languages, despite user's codepage
	!define MUI_LANGDLL_ALLLANGUAGES

	;Remember the installer language
	!define MUI_LANGDLL_REGISTRY_ROOT "HKCU"
	!define MUI_LANGDLL_REGISTRY_KEY "Software\PhotoQt"
	!define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"

;--------------------------------
; PAGES


	; Welcome text
	!define MUI_WELCOMEPAGE_TITLE $(WelcomePage_Title)
	!define MUI_WELCOMEPAGE_TEXT $(WelcomePage_Text_part1)$\r$\n$\r$\n$(WelcomePage_Text_part2)

	; Installer pages
	!insertmacro MUI_PAGE_WELCOME
	!insertmacro MUI_PAGE_LICENSE "license.txt"
	!insertmacro MUI_PAGE_DIRECTORY
	!insertmacro MUI_PAGE_INSTFILES
	Page custom FinalStepsInit FinalStepsLeave
	!insertmacro MUI_PAGE_FINISH

	; UNinstaller pages
	!insertmacro MUI_UNPAGE_CONFIRM
	!insertmacro MUI_UNPAGE_INSTFILES

;--------------------------------
; LOCALISATION

	!insertmacro MUI_LANGUAGE "English"
	;@INSERT_TRANSLATIONS@

	LangString	WelcomePage_Title				${LANG_English} "Welcome to PhotoQt Setup"
	LangString	WelcomePage_Text_part1			${LANG_English} "This installer will guide you through the installation of the PhotoQt."
	LangString	WelcomePage_Text_part2			${LANG_English} "PhotoQt is a simple image viewer, designed to be good looking and highly configurable, yet easy to use and fast."
	LangString	FinishPage_Title				${LANG_English} "Finishing up"
	LangString	FinishPage_Subtitle				${LANG_English} "Just a few final steps"
	LangString	FinishPage_Description			${LANG_English} "We're almost done! Here you can tell PhotoQt to register as default application for (1) none, (2) some or (3) all image formats:"
	LangString	FinishPage_RegisterNone			${LANG_English} "Register for NO image formats"
	LangString	FinishPage_RegisterMostCommon	${LANG_English} "Register for the MOST COMMON image formats"
	LangString	FinishPage_RegisterAll			${LANG_English} "Register for ALL SUPPORTED image formats (including slightly more exotic ones)"
	LangString	FinishPage_RegisterPdfPs		${LANG_English} "Include PDF and PS"
	LangString	FinishPage_RegisterPsdXcf		${LANG_English} "Include PSD and XCF"
	LangString	FinishPage_DesktopIcon			${LANG_English} "Create Desktop Icon"
	LangString	FinishPage_StartMenu			${LANG_English} "Create Start menu entry"

;--------------------------------
;Reserve Files

  ;If you are using solid compression, files that are required before
  ;the actual installation should be stored first in the data block,
  ;because this will make your installer start faster.

  !insertmacro MUI_RESERVEFILE_LANGDLL


;--------------------------------
; Prepare UninstallLog

  ;Set the name of the uninstall log
    !define UninstLog "uninstall.log"
    Var UninstLog
  ;The root registry to write to
    !define REG_ROOT "HKLM"
  ;The registry path to write to
    !define REG_APP_PATH "SOFTWARE\appname"

  ;Uninstall log file missing.
    LangString UninstLogMissing ${LANG_ENGLISH} "${UninstLog} not found!$\r$\nUninstallation cannot proceed!"

  ;AddItem macro
    !define AddItem "!insertmacro AddItem"

  ;BackupFile macro
    !define BackupFile "!insertmacro BackupFile"

  ;BackupFiles macro
    !define BackupFiles "!insertmacro BackupFiles"

  ;Copy files macro
    !define CopyFiles "!insertmacro CopyFiles"

  ;CreateDirectory macro
    !define CreateDirectory "!insertmacro CreateDirectory"

  ;CreateShortcut macro
    !define CreateShortcut "!insertmacro CreateShortcut"

  ;File macro
    !define File "!insertmacro File"

  ;Rename macro
    !define Rename "!insertmacro Rename"

  ;RestoreFile macro
    !define RestoreFile "!insertmacro RestoreFile"

  ;RestoreFiles macro
    !define RestoreFiles "!insertmacro RestoreFiles"

  ;SetOutPath macro
    !define SetOutPath "!insertmacro SetOutPath"

  ;WriteRegDWORD macro
    !define WriteRegDWORD "!insertmacro WriteRegDWORD"

  ;WriteRegStr macro
    !define WriteRegStr "!insertmacro WriteRegStr"

  ;WriteUninstaller macro
    !define WriteUninstaller "!insertmacro WriteUninstaller"

  Section -openlogfile
    CreateDirectory "$INSTDIR"
    IfFileExists "$INSTDIR\${UninstLog}" +3
      FileOpen $UninstLog "$INSTDIR\${UninstLog}" w
    Goto +4
      SetFileAttributes "$INSTDIR\${UninstLog}" NORMAL
      FileOpen $UninstLog "$INSTDIR\${UninstLog}" a
      FileSeek $UninstLog 0 END
  SectionEnd

;--------------------------------
; INSTALLER SECTIONS

Section "PhotoQt" SecDummy

	SetShellVarContext all

	; Install files

	;Write the installation path into the registry
   ${WriteRegStr} "${REG_ROOT}" "${REG_APP_PATH}" "Install Directory" "$INSTDIR"
 ;Write the Uninstall information into the registry
   ${WriteRegStr} ${REG_ROOT} "${UNINSTALL_PATH}" "UninstallString" "$INSTDIR\uninstall.exe"

	${SetOutPath} "$INSTDIR"
	${File} "libbz2-1.dll"
	${File} "libEGL.dll"
	${File} "libexiv2-14.dll"
	${File} "libfreetype-6.dll"
	${File} "libgcc_s_sjlj-1.dll"
	${File} "libGLESv2.dll"
	${File} "libglib-2.0-0.dll"
	${File} "libgomp-1.dll"
	${File} "libGraphicsMagick-3.dll"
	${File} "libGraphicsMagick++-11.dll"
	${File} "libharfbuzz-0.dll"
	${File} "libiconv-2.dll"
	${File} "libintl-8.dll"
	${File} "liblcms2-2.dll"
	${File} "libltdl-7.dll"
	${File} "libjpeg-62.dll"
	${File} "libpcre-1.dll"
	${File} "libpcre16-0.dll"
	${File} "libpng16-16.dll"
	${File} "libsqlite3-0.dll"
	${File} "libstdc++-6.dll"
	${File} "libwinpthread-1.dll"
	${File} "Qt5Core.dll"
	${File} "Qt5Gui.dll"
	${File} "Qt5Multimedia.dll"
	${File} "Qt5MultimediaQuick_p.dll"
	${File} "Qt5Network.dll"
	${File} "Qt5Qml.dll"
	${File} "Qt5Quick.dll"
	${File} "Qt5Svg.dll"
	${File} "Qt5Sql.dll"
	${File} "Qt5Widgets.dll"
	${File} "zlib1.dll"

	${File} "photoqt.exe"
	${File} "license.txt"
	${File} "icon.ico"

	${AddItem} "$INSTDIR\sqldrivers"
	${SetOutPath} "$INSTDIR\sqldrivers"
	${File} "sqldrivers\qsqlite.dll"

	${AddItem} "$INSTDIR\platforms"
	${SetOutPath} "$INSTDIR\platforms"
	${File} "platforms\qwindows.dll"

	${AddItem} "$INSTDIR\imageformats"
	${SetOutPath} "$INSTDIR\imageformats"
	${File} "imageformats\qdds.dll"
	${File} "imageformats\qgif.dll"
	${File} "imageformats\qicns.dll"
	${File} "imageformats\qico.dll"
	${File} "imageformats\qjp2.dll"
	${File} "imageformats\qjpeg.dll"
	${File} "imageformats\qjpg.dll"
	${File} "imageformats\qmng.dll"
	${File} "imageformats\qsvg.dll"
	${File} "imageformats\qtga.dll"
	${File} "imageformats\qtiff.dll"
	${File} "imageformats\qwbmp.dll"
	${File} "imageformats\qwebp.dll"

	${AddItem} "$INSTDIR\QtMultimedia"
	${SetOutPath} "$INSTDIR\QtMultimedia"
	${File} "QtMultimedia\declarative_multimedia.dll"
	${File} "QtMultimedia\qmldir"

	${AddItem} "$INSTDIR\QtQml"
	${AddItem} "$INSTDIR\QtQml\Models.2"
	${SetOutPath} "$INSTDIR\QtQml\Models.2"
	${File} "QtQml\Models.2\modelsplugin.dll"
	${File} "QtQml\models.2\qmldir"

	${AddItem} "$INSTDIR\QtQuick"
	${AddItem} "$INSTDIR\QtQuick\Controls"
	${SetOutPath} "$INSTDIR\QtQuick\Controls"
	${File} "QtQuick\Controls\plugins.qmltypes"
	${File} "QtQuick\Controls\qmldir"
	${File} "QtQuick\Controls\qtquickcontrolsplugin.dll"

	${AddItem} "$INSTDIR\QtQuick\Dialogs"
	${SetOutPath} "$INSTDIR\QtQuick\Dialogs"
	${File} "QtQuick\Dialogs\dialogplugin.dll"
	${File} "QtQuick\Dialogs\plugins.qmltypes"
	${File} "QtQuick\Dialogs\qmldir"

	${AddItem} "$INSTDIR\QtQuick\Layouts"
	${SetOutPath} "$INSTDIR\QtQuick\Layouts"
	${File} "QtQuick\Layouts\plugins.qmltypes"
	${File} "QtQuick\Layouts\qmldir"
	${File} "QtQuick\Layouts\qquicklayoutsplugin.dll"

	${AddItem} "$INSTDIR\QtQuick\Window.2"
	${SetOutPath} "$INSTDIR\QtQuick\Window.2"
	${File} "QtQuick\Window.2\plugins.qmltypes"
	${File} "QtQuick\Window.2\qmldir"
	${File} "QtQuick\Window.2\windowplugin.dll"

	${AddItem} "$INSTDIR\QtQuick.2"
	${SetOutPath} "$INSTDIR\QtQuick.2"
	${File} "QtQuick.2\plugins.qmltypes"
	${File} "QtQuick.2\qmldir"
	${File} "QtQuick.2\qtquick2plugin.dll"

	; Store installation folder
	${WriteRegStr} HKCU "Software\PhotoQt" "" $INSTDIR

	; Create uninstaller
	${WriteUninstaller} "$INSTDIR\uninstall.exe"

SectionEnd


;--------------------------------
; INSTALLER FUNTIONS

Function .onInit
	!insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd


; Custom page (nsdialog)
Var Dialog

; Description text
Var LabelFiletypeDesc

; Variables for checkboxes and their states
Var RadioButtonNone
Var RadioButtonBasic
Var RadioButtonBasic_State
Var RadioButtonAdvanced
Var RadioButtonAdvanced_State
Var CheckboxPdfPs
Var CheckboxPdfPs_State
Var CheckboxPsdXcf
Var CheckboxPsdXcf_State

Var CheckboxStartMenu
Var CheckboxStartMenu_State
Var CheckboxDesktop
Var CheckboxDesktop_State

Function FinalStepsInit

	; Set header and subtitle
	!insertmacro MUI_HEADER_TEXT $(FinishPage_Title) $(FinishPage_Subtitle)

	; Create dialog
	nsDialogs::Create 1018
	Pop $Dialog
	${If} $Dialog == error
		Abort
	${EndIf}

	; Create description label
	${NSD_CreateLabel} 0 0 100% 24u $(FinishPage_Description)
	Pop $LabelFiletypeDesc


	; Create all the radiobuttons/checkboxes

	${NSD_CreateRadioButton} 0 25u 100% 12u $(FinishPage_RegisterNone)
	Pop $RadioButtonNone
	${NSD_OnClick} $RadioButtonNone FinalStepsDisEnable

	${NSD_CreateRadioButton} 0 38u 100% 12u $(FinishPage_RegisterMostCommon)
	Pop $RadioButtonBasic
	${NSD_OnClick} $RadioButtonBasic FinalStepsDisEnable

	${NSD_CreateRadioButton} 0 51u 100% 12u $(FinishPage_RegisterAll)
	Pop $RadioButtonAdvanced
	${NSD_Check} $RadioButtonBasic
	${NSD_OnClick} $RadioButtonAdvanced FinalStepsDisEnable

	${NSD_CreateCheckbox} 0 64u 100% 12u $(FinishPage_RegisterPdfPs)
	Pop $CheckboxPdfPs

	${NSD_CreateCheckbox} 0 77u 100% 12u $(FinishPage_RegisterPsdXcf)
	Pop $CheckboxPsdXcf

	${NSD_CreateHLine} 0 99u 100% 1u HLineBeforeDesktop

	${NSD_CreateCheckbox} 0 109u 100% 12u $(FinishPage_DesktopIcon)
	Pop $CheckboxDesktop
	${NSD_Check} $CheckboxDesktop

	${NSD_CreateCheckbox} 0 122u 100% 12u $(FinishPage_StartMenu)
	Pop $CheckboxStartMenu
	${NSD_Check} $CheckboxStartMenu


	; Finally, show dialog
	nsDialogs::Show

FunctionEnd

Function FinalStepsDisEnable

	${NSD_GetState} $RadioButtonAdvanced $RadioButtonAdvanced_State
	${If} $RadioButtonAdvanced_State == ${BST_CHECKED}
		EnableWindow $CheckboxPdfPs 1
		EnableWindow $CheckboxPsdXcf 1
	${Else}
		EnableWindow $CheckboxPdfPs 0
		EnableWindow $CheckboxPsdXcf 0
	${EndIf}

FunctionEnd

Function FinalStepsLeave

	SetShellVarContext all

	; Get checkbox states
	${NSD_GetState} $RadioButtonBasic $RadioButtonBasic_State
	${NSD_GetState} $RadioButtonAdvanced $RadioButtonAdvanced_State
	${NSD_GetState} $CheckboxPdfPs $CheckboxPdfPs_State
	${NSD_GetState} $CheckboxPsdXcf $CheckboxPsdXcf_State
	${NSD_GetState} $CheckboxDesktop $CheckboxDesktop_State
	${NSD_GetState} $CheckboxStartMenu $CheckboxStartMenu_State

	; Register basic file types
	${If} $RadioButtonBasic_State == ${BST_CHECKED}
	${OrIf} $RadioButtonAdvanced_State == ${BST_CHECKED}

		${WriteRegStr} HKCU "Software\PhotoQt" "fileformats" "basic"

		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".bmp" "Microsoft Windows bitmap"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".bitmap" "Microsoft Windows bitmap"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".dds" "Direct Draw Surface"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".gif" "Graphics Interchange Format"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".tif" "Tagged Image File Format"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".tiff" "Tagged Image File Format"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".jpeg2000" "JPEG-2000 image"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".jp2" "JPEG-2000 image"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".jpc" "JPEG-2000 image"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".j2k" "JPEG-2000 image"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".jpf" "JPEG-2000 image"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".jpx" "JPEG-2000 image"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".jpm" "JPEG-2000 image"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".mj2" "JPEG-2000 image"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".mng" "Multiple-image Network Graphics"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".ico" "Microsoft Icon"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".icns" "Microsoft Icon"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".jpeg" "JPEG image"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".jpg" "JPEG image"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".png" "Portable Network Graphics"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".pbm" "Portable bitmap format"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".pgm" "Portable graymap format"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".ppm" "Portable pixmap format"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".svg" "Scalable Vector Graphics"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".svgz" "Scalable Vector Graphics"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".xbm" "X Windows system bitmap"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".wbmp" "Wireless bitmap"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".webp" "Wireless bitmap"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".xpm" "X Windows system pixmap"

	${EndIf}

	; Register advanced file types
	${If} $RadioButtonAdvanced_State == ${BST_CHECKED}

		${WriteRegStr} HKCU "Software\PhotoQt" "fileformats" "advanced"

		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".avs" "AVS X image"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".x" "AVS X image"

		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".cals" "Continuous Acquisition and Life-cycle Support Type 1 image"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".cal" "Continuous Acquisition and Life-cycle Support Type 1 image"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".dcl" "Continuous Acquisition and Life-cycle Support Type 1 image"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".ras" "Continuous Acquisition and Life-cycle Support Type 1 image"

		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".cin" "Kodak Cineon"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".cut" "DR Halo"

		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".acr" "DICOM image"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".dcm" "DICOM image"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".dicom" "DICOM image"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".dic" "DICOM image"

		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".dcx" "ZSoft IBM PC multi-page Paintbrush image"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".dib" "Device Independent Bitmap"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".dpx" "Digital Moving Picture Exchange"

		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".fax" "Group 3 Fax"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".fits" "Flexible Image Transport System"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".fts" "Flexible Image Transport System"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".fit" "Flexible Image Transport System"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".fpx" "FlashPix Format"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".jng" "JPEG Network Graphics"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".mat" "MATLAT image format"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".miff" "Magick image file format"

		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".mono" "Bi-level bitmap in little-endian order"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".mtv" "MTV Raytracing image format"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".otb" "On-the-air bitmap"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".p7" "Xv's Visual Schnauzer thumbnail format"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".palm" "Palm pixmap"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".pam" "Portable Arbitrary Map format"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".pcd" "Photo CD"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".pcds" "Photo CD"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".pcx" "ZSoft IBM PC Paintbrush file"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".pdb" "Palm Database ImageViewer format"

		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".pict" "Apple Macintosh QuickDraw/PICT file"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".pct" "Apple Macintosh QuickDraw/PICT file"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".pic" "Apple Macintosh QuickDraw/PICT file"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".pix" "Alias/Wavefront RLE image format"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".pal" "Alias/Wavefront RLE image format"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".pnm" "Portable anymap"

		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".ptif" "Pyramid encoded TIFF"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".ptiff" "Pyramid encoded TIFF"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".sfw" "Seattle File Works image"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".sgi" "Irix RGB image"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".sun" "SUN Rasterfile"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".tga" "Truevision Targe image"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".vicar" "VICAR rasterfile format"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".viff" "Khoros Visualization image file format"

		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".wpg" "Word Perfect Graphics file"
		!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".xwd" "X Windows system window dump"


		${If} $CheckboxPdfPs_State == ${BST_CHECKED}

			${WriteRegStr} HKCU "Software\PhotoQt" "fileformats_pdfps" "registered"

			!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".epdf" "Encapsulated PDF"
			!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".epi" "Encapsulated PostScript Interchange format"
			!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".epsi" "Encapsulated PostScript Interchange format"
			!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".eps" "Encapsulated PostScript"
			!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".epsf" "Encapsulated PostScript"
			!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".eps2" "Level II Encapsulated PostScript"
			!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".eps3" "Level III Encapsulated PostScript"
			!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".ept" "Encapsulated PostScript Interchange format (TIFF preview)"
			!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".pdf" "Portable Document Format"
			!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".ps" "PostScript"
			!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".ps2" "Level II PostScript"
			!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".ps3" "Level III PostScript"

		${EndIf}

		${If} $CheckboxPsdXcf_State == ${BST_CHECKED}

			${WriteRegStr} HKCU "Software\PhotoQt" "fileformats_psdxcf" "registered"

			!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".psb" "Large Photoshop Document"
			!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".psd" "Photoshop Document"
			!insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".xcf" "Gimp image"

		${EndIf}


	${EndIf}


	; Create desktop icon
	${If} $CheckboxDesktop_State == ${BST_CHECKED}

		${CreateShortcut} "$desktop\PhotoQt.lnk" "$instdir\photoqt.exe" "" "$INSTDIR\icon.ico" 0

	${EndIf}

	; Create startmenu entry
	${If} $CheckboxStartMenu_State == ${BST_CHECKED}

		${CreateDirectory} "$SMPROGRAMS\PhotoQt"
		${CreateShortcut} "$SMPROGRAMS\PhotoQt\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "" 0
		${CreateShortcut} "$SMPROGRAMS\PhotoQt\PhotoQt.lnk" "$INSTDIR\photoqt.exe" "" "" 0

	${EndIf}

	; Update icons
	System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v (0x08000000, 0, 0, 0)'

FunctionEnd

;--------------------------------
; UNINSTALLER SECTION

Section "Uninstall"

	; Can't uninstall if uninstall log is missing!
	IfFileExists "$INSTDIR\${UninstLog}" +3
		MessageBox MB_OK|MB_ICONSTOP "$(UninstLogMissing)"
		Abort

	SetShellVarContext all

	; De-register file types

	Var /GLOBAL fileformats
	Var /GLOBAL fileformats_pdfps
	Var /GLOBAL fileformats_psdxcf
	ReadRegStr $fileformats HKCU "Software\PhotoQt" "fileformats"
	ReadRegStr $fileformats_pdfps HKCU "Software\PhotoQt" "fileformats_pdfps"
	ReadRegStr $fileformats_psdxcf HKCU "Software\PhotoQt" "fileformats_psdxcf"

	${If} $fileformats == "basic"
		!insertmacro UnRegisterExtensionCall ".bmp" "Microsoft Windows bitmap"
		!insertmacro UnRegisterExtensionCall ".bitmap" "Microsoft Windows bitmap"
		!insertmacro UnRegisterExtensionCall ".dds" "Direct Draw Surface"
		!insertmacro UnRegisterExtensionCall ".gif" "Graphics Interchange Format"
		!insertmacro UnRegisterExtensionCall ".tif" "Tagged Image File Format"
		!insertmacro UnRegisterExtensionCall ".tiff" "Tagged Image File Format"
		!insertmacro UnRegisterExtensionCall ".jpeg2000" "JPEG-2000 image"
		!insertmacro UnRegisterExtensionCall ".jp2" "JPEG-2000 image"
		!insertmacro UnRegisterExtensionCall ".jpc" "JPEG-2000 image"
		!insertmacro UnRegisterExtensionCall ".j2k" "JPEG-2000 image"
		!insertmacro UnRegisterExtensionCall ".jpf" "JPEG-2000 image"
		!insertmacro UnRegisterExtensionCall ".jpx" "JPEG-2000 image"
		!insertmacro UnRegisterExtensionCall ".jpm" "JPEG-2000 image"
		!insertmacro UnRegisterExtensionCall ".mj2" "JPEG-2000 image"
		!insertmacro UnRegisterExtensionCall ".mng" "Multiple-image Network Graphics"
		!insertmacro UnRegisterExtensionCall ".ico" "Microsoft Icon"
		!insertmacro UnRegisterExtensionCall ".icns" "Microsoft Icon"
		!insertmacro UnRegisterExtensionCall ".jpeg" "JPEG image"
		!insertmacro UnRegisterExtensionCall ".jpg" "JPEG image"
		!insertmacro UnRegisterExtensionCall ".png" "Portable Network Graphics"
		!insertmacro UnRegisterExtensionCall ".pbm" "Portable bitmap format"
		!insertmacro UnRegisterExtensionCall ".pgm" "Portable graymap format"
		!insertmacro UnRegisterExtensionCall ".ppm" "Portable pixmap format"
		!insertmacro UnRegisterExtensionCall ".svg" "Scalable Vector Graphics"
		!insertmacro UnRegisterExtensionCall ".svgz" "Scalable Vector Graphics"
		!insertmacro UnRegisterExtensionCall ".xbm" "X Windows system bitmap"
		!insertmacro UnRegisterExtensionCall ".wbmp" "Wireless bitmap"
		!insertmacro UnRegisterExtensionCall ".webp" "Wireless bitmap"
		!insertmacro UnRegisterExtensionCall ".xpm" "X Windows system pixmap"
	${EndIf}

	${If} $fileformats == "advanced"
		!insertmacro UnRegisterExtensionCall ".avs" "AVS X image"
		!insertmacro UnRegisterExtensionCall ".x" "AVS X image"

		!insertmacro UnRegisterExtensionCall ".cals" "Continuous Acquisition and Life-cycle Support Type 1 image"
		!insertmacro UnRegisterExtensionCall ".cal" "Continuous Acquisition and Life-cycle Support Type 1 image"
		!insertmacro UnRegisterExtensionCall ".dcl" "Continuous Acquisition and Life-cycle Support Type 1 image"
		!insertmacro UnRegisterExtensionCall ".ras" "Continuous Acquisition and Life-cycle Support Type 1 image"

		!insertmacro UnRegisterExtensionCall ".cin" "Kodak Cineon"
		!insertmacro UnRegisterExtensionCall ".cut" "DR Halo"

		!insertmacro UnRegisterExtensionCall ".acr" "DICOM image"
		!insertmacro UnRegisterExtensionCall ".dcm" "DICOM image"
		!insertmacro UnRegisterExtensionCall ".dicom" "DICOM image"
		!insertmacro UnRegisterExtensionCall ".dic" "DICOM image"

		!insertmacro UnRegisterExtensionCall ".dcx" "ZSoft IBM PC multi-page Paintbrush image"
		!insertmacro UnRegisterExtensionCall ".dib" "Device Independent Bitmap"
		!insertmacro UnRegisterExtensionCall ".dpx" "Digital Moving Picture Exchange"

		!insertmacro UnRegisterExtensionCall ".fax" "Group 3 Fax"
		!insertmacro UnRegisterExtensionCall ".fits" "Flexible Image Transport System"
		!insertmacro UnRegisterExtensionCall ".fts" "Flexible Image Transport System"
		!insertmacro UnRegisterExtensionCall ".fit" "Flexible Image Transport System"
		!insertmacro UnRegisterExtensionCall ".fpx" "FlashPix Format"
		!insertmacro UnRegisterExtensionCall ".jng" "JPEG Network Graphics"
		!insertmacro UnRegisterExtensionCall ".mat" "MATLAT image format"
		!insertmacro UnRegisterExtensionCall ".miff" "Magick image file format"

		!insertmacro UnRegisterExtensionCall ".mono" "Bi-level bitmap in little-endian order"
		!insertmacro UnRegisterExtensionCall ".mtv" "MTV Raytracing image format"
		!insertmacro UnRegisterExtensionCall ".otb" "On-the-air bitmap"
		!insertmacro UnRegisterExtensionCall ".p7" "Xv's Visual Schnauzer thumbnail format"
		!insertmacro UnRegisterExtensionCall ".palm" "Palm pixmap"
		!insertmacro UnRegisterExtensionCall ".pam" "Portable Arbitrary Map format"
		!insertmacro UnRegisterExtensionCall ".pcd" "Photo CD"
		!insertmacro UnRegisterExtensionCall ".pcds" "Photo CD"
		!insertmacro UnRegisterExtensionCall ".pcx" "ZSoft IBM PC Paintbrush file"
		!insertmacro UnRegisterExtensionCall ".pdb" "Palm Database ImageViewer format"

		!insertmacro UnRegisterExtensionCall ".pict" "Apple Macintosh QuickDraw/PICT file"
		!insertmacro UnRegisterExtensionCall ".pct" "Apple Macintosh QuickDraw/PICT file"
		!insertmacro UnRegisterExtensionCall ".pic" "Apple Macintosh QuickDraw/PICT file"
		!insertmacro UnRegisterExtensionCall ".pix" "Alias/Wavefront RLE image format"
		!insertmacro UnRegisterExtensionCall ".pal" "Alias/Wavefront RLE image format"
		!insertmacro UnRegisterExtensionCall ".pnm" "Portable anymap"

		!insertmacro UnRegisterExtensionCall ".ptif" "Pyramid encoded TIFF"
		!insertmacro UnRegisterExtensionCall ".ptiff" "Pyramid encoded TIFF"
		!insertmacro UnRegisterExtensionCall ".sfw" "Seattle File Works image"
		!insertmacro UnRegisterExtensionCall ".sgi" "Irix RGB image"
		!insertmacro UnRegisterExtensionCall ".sun" "SUN Rasterfile"
		!insertmacro UnRegisterExtensionCall ".tga" "Truevision Targe image"
		!insertmacro UnRegisterExtensionCall ".vicar" "VICAR rasterfile format"
		!insertmacro UnRegisterExtensionCall ".viff" "Khoros Visualization image file format"

		!insertmacro UnRegisterExtensionCall ".wpg" "Word Perfect Graphics file"
		!insertmacro UnRegisterExtensionCall ".xwd" "X Windows system window dump"
	${EndIf}

	${If} $fileformats_pdfps == "registered"
		!insertmacro UnRegisterExtensionCall ".epdf" "Encapsulated PDF"
		!insertmacro UnRegisterExtensionCall ".epi" "Encapsulated PostScript Interchange format"
		!insertmacro UnRegisterExtensionCall ".epsi" "Encapsulated PostScript Interchange format"
		!insertmacro UnRegisterExtensionCall ".eps" "Encapsulated PostScript"
		!insertmacro UnRegisterExtensionCall ".epsf" "Encapsulated PostScript"
		!insertmacro UnRegisterExtensionCall ".eps2" "Level II Encapsulated PostScript"
		!insertmacro UnRegisterExtensionCall ".eps3" "Level III Encapsulated PostScript"
		!insertmacro UnRegisterExtensionCall ".ept" "Encapsulated PostScript Interchange format (TIFF preview)"
		!insertmacro UnRegisterExtensionCall ".pdf" "Portable Document Format"
		!insertmacro UnRegisterExtensionCall ".ps" "PostScript"
		!insertmacro UnRegisterExtensionCall ".ps2" "Level II PostScript"
		!insertmacro UnRegisterExtensionCall ".ps3" "Level III PostScript"
	${EndIf}

	${If} $fileformats_psdxcf == "registered"
		!insertmacro UnRegisterExtensionCall ".psb" "Large Photoshop Document"
		!insertmacro UnRegisterExtensionCall ".psd" "Photoshop Document"
		!insertmacro UnRegisterExtensionCall ".xcf" "Gimp image"
	${EndIf}

	; Update icons
	System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v (0x08000000, 0, 0, 0)'




	Push $R0
	Push $R1
	Push $R2
	SetFileAttributes "$INSTDIR\${UninstLog}" NORMAL
	FileOpen $UninstLog "$INSTDIR\${UninstLog}" r
	StrCpy $R1 -1

	GetLineCount:
		ClearErrors
		FileRead $UninstLog $R0
		IntOp $R1 $R1 + 1
		StrCpy $R0 $R0 -2
		Push $R0
		IfErrors 0 GetLineCount

	Pop $R0

	LoopRead:
		StrCmp $R1 0 LoopDone
		Pop $R0

		IfFileExists "$R0\*.*" 0 +3
		RMDir $R0
		Goto +9
		IfFileExists $R0 0 +3
		Delete $R0
		Goto +6
		StrCmp $R0 "${REG_ROOT} ${REG_APP_PATH}" 0 +3
		DeleteRegKey ${REG_ROOT} "${REG_APP_PATH}"
		Goto +3
		StrCmp $R0 "${REG_ROOT} ${UNINSTALL_PATH}" 0 +2
		DeleteRegKey ${REG_ROOT} "${UNINSTALL_PATH}"

		IntOp $R1 $R1 - 1
		Goto LoopRead
	LoopDone:
	FileClose $UninstLog
	Delete "$INSTDIR\${UninstLog}"
	RMDir "$INSTDIR"
	Pop $R2
	Pop $R1
	Pop $R0

  ;Remove registry keys
    ;DeleteRegKey ${REG_ROOT} "${REG_APP_PATH}"
    ;DeleteRegKey ${REG_ROOT} "${UNINSTALL_PATH}"

SectionEnd

;--------------------------------
;Uninstaller Functions

Function un.onInit
  !insertmacro MUI_UNGETLANGUAGE
FunctionEnd
