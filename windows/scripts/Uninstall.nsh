
Section "Uninstall"

    ; Remove application files.
    RMDir /r "$INSTDIR\files\"
    RMDir /r "$INSTDIR\filetypes\"
    RMDir /r "$INSTDIR\filetypes_default\"
    RMDir /r "$INSTDIR\filetypes_xmha97\"
    Delete "$INSTDIR\photoqt.ico"
    Delete "$INSTDIR\Uninstall.exe"

    ; Remove Start Menu shortcut.
    ${If} $MultiUser.InstallMode == "AllUsers"

        SetShellVarContext all

        Delete "$SMPROGRAMS\PhotoQt\PhotoQt.lnk"
        RMDir "$SMPROGRAMS\PhotoQt"

    ${Else}

        SetShellVarContext current

        Delete "$SMPROGRAMS\PhotoQt\PhotoQt.lnk"
        RMDir "$SMPROGRAMS\PhotoQt"

    ${EndIf}

    ; Remove desktop shortcut
    Delete "$desktop\PhotoQt.lnk"

    ; Remove the installation directory.
    ; We do this NOT recursively, thus if it happens to not be empty we don't proceed
    RMDir "$INSTDIR"

    ; Delete File associations
    !include "scripts\UnRegisterCapabilities.nsh"

    ; Remove uninstall registry information.
    ; This reg key is in the 32 bit view as otherwise things break...
    SetRegView 32
    DeleteRegKey ShCtx "Software\Microsoft\Windows\CurrentVersion\Uninstall\PhotoQt"

SectionEnd
