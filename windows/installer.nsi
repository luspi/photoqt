Unicode True

; ------------------------------------------------------------
; VERSION NUMBER
; This should be the only thing that ever needs to be adjusted
; ------------------------------------------------------------

!define VERSION         "5.4.1"

; ------------------------------------------------------------
; SIGN EXE AUTOMATICALLY
; When defined, this calls `signtool sign` 3 times during compilation:
; - photoqt.exe,
; - final installer
; - Uninstall.exe
; ------------------------------------------------------------

!define SIGN_EXE_AUTOMATICALLY

; ------------------------------------------------------------
; General defines
; ------------------------------------------------------------

!define PRODUCT_NAME    "PhotoQt"
!define APP_PUBLISHER   "Lukas Spies"
!define PROGEXE         "photoqt.exe"

Name "PhotoQt"
OutFile "photoqt-${VERSION}.exe"
InstallDir "$LOCALAPPDATA\Programs\PhotoQt"

; ------------------------------------------------------------
; NsisMultiUser configuration
;
; IMPORTANT:
; These defines must come BEFORE including NsisMultiUser.nsh.
; ------------------------------------------------------------

!define MULTIUSER_EXECUTIONLEVEL Highest

; Enables the MUI2 installation-mode page.
!define MULTIUSER_MUI

; Allow /AllUsers and /CurrentUser on the command line.
!define MULTIUSER_INSTALLMODE_COMMANDLINE

; Store/retrieve the previous installation directory
; separately for each installation mode.
!define MULTIUSER_INSTALLMODE_INSTDIR_REGISTRY_KEY "Software\Lukas Spies\PhotoQt"

!define MULTIUSER_INSTALLMODE_INSTDIR_REGISTRY_VALUENAME "InstallDir"

; Install per-machine applications in Program Files.
!define MULTIUSER_INSTALLMODE_INSTDIR "PhotoQt"

; Use Program Files (x64) for a 64-bit application.
!define MULTIUSER_USE_PROGRAMFILES64

; ------------------------------------------------------------
; Include some header files
; ------------------------------------------------------------

; support selecting whether ton install system wide or for current user only
!include "NsisMultiUser.nsh"
!include "NsisMultiUserLang.nsh"

; modern ui
!include "MUI2.nsh"

; more flow control and logic
!include "LogicLib.nsh"

; to detect whether we're on Win 10 or 11
!include "WinVer.nsh"

; allows creation of custom pages
!include "nsDialogs.nsh"

; ------------------------------------------------------------
; Some strings
; ------------------------------------------------------------

!define MUI_WELCOMEPAGE_TITLE "Welcome to the installer of PhotoQt"

!define MUI_WELCOMEPAGE_TEXT "This installer will guide you through the installation of the PhotoQt. It is recommended that you close all other applications before starting the installer. $\r$\n$\r$\nIf you have any questions or concerns, please contact the developer through their website:$\r$\n$\r$\nhttps://photoqt.org$\r$\n$\r$\n$\r$\n Click Next to continue."

!define MUI_FINISHPAGE_RUN "$INSTDIR/photoqt.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Open PhotoQt"

!define MUI_FINISHPAGE_LINK "PhotoQt website: https://photoqt.org"
!define MUI_FINISHPAGE_LINK_LOCATION "https://photoqt.org"

; ------------------------------------------------------------
; UI
; ------------------------------------------------------------

!include "scripts\Options.nsh"
!include "scripts\FileTypeIconSet.nsh"

!define MUI_ABORTWARNING

!define MUI_ICON "assets\photoqt_install.ico"
!define MUI_UNICON "assets\photoqt_uninstall.ico"

!define MUI_PAGE_CUSTOMFUNCTION_LEAVE WelcomeLeaveNotSilent
!insertmacro MUI_PAGE_WELCOME
!insertmacro MULTIUSER_PAGE_INSTALLMODE
!insertmacro MUI_PAGE_LICENSE "assets\license.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
Page custom FileTypeIconSetPage FileTypeIconSetLeave
Page custom OptionsPage OptionsPageLeave
!insertmacro MUI_PAGE_FINISH

Function WelcomeLeaveNotSilent
    IfSilent doNothing 0
        ; in this case we have an install from the older NSIS scripts
        ; since a lot has changed we call the uninstaller and ask the 
        ; user to restart this installer
        IfFileExists "$INSTDIR\Uninstall.exe" 0 doNothing
        IfFileExists "$INSTDIR\files\*.*" doNothing 0
            MessageBox MB_OK "The installer for PhotoQt was completely reworked with improved file and registry handling. To take advantage of this, the previous installation first needs to be removed.$\r$\n$\r$\nClosing this message box will terminate the installer and launch the uninstaller. After completing the uninstall, simply relaunch this installer."
            ; We can't use ExecWait here as it does not wait properly
            ; and will result in, e.g., the uninstaller to be missing
            Exec '"$INSTDIR\Uninstall.exe"'
            Quit
    doNothing:
FunctionEnd

; ------------------------------------------------------------
; Uninstaller
; ------------------------------------------------------------

ShowUninstDetails show

!define MUI_UNABORTWARNING

!insertmacro MULTIUSER_UNPAGE_INSTALLMODE
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

; Set the language if the installer to English
; This has to come AFTER the list of pages above
!insertmacro MUI_LANGUAGE "English"
!insertmacro MULTIUSER_LANGUAGE_INIT

; ------------------------------------------------------------
; Installer initialization
; ------------------------------------------------------------

Function .onInit

    !insertmacro MULTIUSER_INIT

    ; the default installation dir is the local dir
    ; if we have elevated privileges we change this here to the system dir
    UserInfo::GetAccountType
    Pop $0
    ${If} $0 == "admin"
        StrCpy $INSTDIR "$PROGRAMFILES64\PhotoQt"
    ${EndIf}

    InitPluginsDir
    File "/oname=$PLUGINSDIR\filetypes_default.bmp" "assets\filetypes_default.bmp"
    File "/oname=$PLUGINSDIR\filetypes_xmha97.bmp" "assets\filetypes_xmha97.bmp"

FunctionEnd


; ------------------------------------------------------------
; Uninstaller initialization
; ------------------------------------------------------------

Function un.onInit

    !insertmacro MULTIUSER_UNINIT

FunctionEnd

; ------------------------------------------------------------
; Installation
; ------------------------------------------------------------

!include "scripts\Install.nsh"


; ------------------------------------------------------------
; Uninstaller
; ------------------------------------------------------------

!include "scripts\Uninstall.nsh"

