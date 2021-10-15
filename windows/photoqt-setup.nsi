;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; FIXME
; - add icons for different file types
; - add missing file type registry entries
; - add check for previous version incl. info that this wont be necessary in the future
;
;
;
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
        MessageBox MB_OK|MB_ICONEXCLAMATION "It appears that an older version of PhotoQt is currently installed. In order to avoid cluttering your system with old files, please cancel this installer and first uninstall the previous version.$\r$\n$\r$\n This installer handles installed files much better than before, and this step *will not* be necessary for future updates!"
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

        ; ... register file formats ...
        ; !insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".bmp" "Microsoft Windows bitmap"

        ${If} $CheckboxPdfPs_State == ${BST_CHECKED}

            WriteRegStr HKCU "Software\PhotoQt" "fileformats_pdfps" "registered"

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

        ${Else}

            ; if it was registered in a previous install, we need to de-register it here
            Var /GLOBAL fileformats_pdfps
            ReadRegStr $fileformats_pdfps HKCU "Software\PhotoQt" "fileformats_pdfps"
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

            WriteRegStr HKCU "Software\PhotoQt" "fileformats_pdfps" ""

        ${EndIf}

        ${If} $CheckboxPsdXcf_State == ${BST_CHECKED}

            WriteRegStr HKCU "Software\PhotoQt" "fileformats_psdxcf" "registered"

            !insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".psb" "Large Photoshop Document"
            !insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".psd" "Photoshop Document"
            !insertmacro RegisterExtensionCall "$INSTDIR\photoqt.exe" ".xcf" "Gimp image"

        ${Else}

            ; if it was registered in a previous install, we need to de-register it here
            Var /GLOBAL fileformats_psdxcf
            ReadRegStr $fileformats_psdxcf HKCU "Software\PhotoQt" "fileformats_psdxcf"
            ${If} $fileformats_psdxcf == "registered"
                !insertmacro UnRegisterExtensionCall ".psb" "Large Photoshop Document"
                !insertmacro UnRegisterExtensionCall ".psd" "Photoshop Document"
                !insertmacro UnRegisterExtensionCall ".xcf" "Gimp image"
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

    ${EndIf}

    ${If} $un_fileformats_pdfps == "registered"
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

    ${If} $un_fileformats_psdxcf == "registered"
        !insertmacro UnRegisterExtensionCall ".psb" "Large Photoshop Document"
        !insertmacro UnRegisterExtensionCall ".psd" "Photoshop Document"
        !insertmacro UnRegisterExtensionCall ".xcf" "Gimp image"
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
