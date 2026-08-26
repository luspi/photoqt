; include the Uninstall log header
Section "Application"

    IfSilent 0 somewhatrecent

    ; in this case we have an install from the older NSIS scripts
    ; since a lot has changed we call the uninstaller silently
    ; and then re-install it with the current installer
    IfFileExists "$INSTDIR\Uninstall.exe" 0 somewhatrecent
    IfFileExists "$INSTDIR\files\*.*" somewhatrecent 0

        ; We can't use ExecWait here as it does not wait properly
        ; and will result in, e.g., the uninstaller to be missing
        Exec '"$INSTDIR\Uninstall.exe" /S'

        !define FILE_WAIT_SECONDS 30

        StrCpy $0 0

        WaitForFileToDisappear:
            IfFileExists "$INSTDIR\Uninstall.exe" 0 FileGone

            IntOp $0 $0 + 1
            ${If} $0 >= ${FILE_WAIT_SECONDS}
                DetailPrint "Timeout waiting for App.exe to disappear"
                Goto FileWaitDone
            ${EndIf}

            DetailPrint "Waiting for old version to be uninstalled... $0/${FILE_WAIT_SECONDS}"
            Sleep 1000
            Goto WaitForFileToDisappear

        FileWaitDone:
            MessageBox MB_OK "The installer was unable to remove the old install. Please do so manually and then restart this installer.$\r$\n$\r$\nIf you need help, please contact the developer: https://photoqt.org/about"
            Quit

        FileGone:
            DetailPrint "Old install successfully removed"

    somewhatrecent:

    ; if there is an existing installation (detected by the presence of the app subfolder)
    IfFileExists "$INSTDIR\files\*.*" 0 +2
        RMDir /r "$INSTDIR\files"

    SetOutPath "$INSTDIR"

    ; Sign executable
    !ifdef SIGN_EXE_AUTOMATICALLY
        !system "signtool sign -v -tr http://time.certum.pl -fd SHA256 -td SHA256 app\files\photoqt.exe" = 0
    !endif

    ; Application files.
    File /r /x *qmlc "app\*exe"

    ; --------------------------------------------------------
    ; Uninstall registry information
    ;
    ; "ShCtx" is supplied by NsisMultiUser and resolves to
    ; HKCU for per-user installations and HKLM for
    ; per-machine installations.
    ; --------------------------------------------------------

    ; These HAVE TO go into the 32 bit view
    ; otherwise things will start to break (e.g., the uninstaller)
    SetRegView 32

    WriteRegStr ShCtx \
        "Software\Microsoft\Windows\CurrentVersion\Uninstall\PhotoQt" \
        "DisplayName" \
        "PhotoQt"

    WriteRegStr ShCtx \
        "Software\Microsoft\Windows\CurrentVersion\Uninstall\PhotoQt" \
        "FriendlyName" \
        "PhotoQt Image Viewer"

    WriteRegStr ShCtx \
        "Software\Microsoft\Windows\CurrentVersion\Uninstall\PhotoQt" \
        "DisplayVersion" \
        "${VERSION}"

    WriteRegStr ShCtx \
        "Software\Microsoft\Windows\CurrentVersion\Uninstall\PhotoQt" \
        "Publisher" \
        "Lukas Spies"

    WriteRegStr ShCtx \
        "Software\Microsoft\Windows\CurrentVersion\Uninstall\PhotoQt" \
        "InstallDir" \
        "$INSTDIR"

    WriteRegStr ShCtx \
        "Software\Microsoft\Windows\CurrentVersion\Uninstall\PhotoQt" \
        "DisplayIcon" \
        "$INSTDIR\photoqt.ico"

    ${If} $MultiUser.InstallMode == "AllUsers"
        WriteRegStr ShCtx \
            "Software\Microsoft\Windows\CurrentVersion\Uninstall\PhotoQt" \
            "UninstallString" \
            "$INSTDIR\Uninstall.exe /allusers /S"
    ${Else}
        WriteRegStr ShCtx \
            "Software\Microsoft\Windows\CurrentVersion\Uninstall\PhotoQt" \
            "UninstallString" \
            "$INSTDIR\Uninstall.exe /currentuser /S"
    ${EndIf}

    ; Remember which installation mode was used.
    WriteRegStr ShCtx \
        "Software\Microsoft\Windows\CurrentVersion\Uninstall\PhotoQt" \
        "MultiUser.InstallMode" \
        "$MultiUser.InstallMode"

    ; Create the appropriate uninstaller.
    WriteUninstaller "$INSTDIR\Uninstall.exe"

    !ifdef SIGN_EXE_AUTOMATICALLY
        !finalize 'signtool sign -v -tr http://time.certum.pl -fd SHA256 -td SHA256 "%1"' = 0
        !uninstfinalize 'signtool sign -v -tr http://time.certum.pl -fd SHA256 -td SHA256 "%1"' = 0
    !endif

    IfSilent 0 +3
        Call FileTypeIconSetSilent
        Call OptionsSilent

SectionEnd
