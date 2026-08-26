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
; This will create a new file in the application directory
; called photoqt-portable-%version%.exe.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Unicode True

SilentInstall silent

; we don't need any administrator privileges
RequestExecutionLevel user

; this is supposed to be the fastest to uncompress
SetCompressor ZLIB

; ------------------------------------------------------------
; VERSION NUMBER
; This should be the only thing that ever needs to be adjusted
; ------------------------------------------------------------

!define VERSION         "5.4.1"

; ------------------------------------------------------------
; SIGN EXE AUTOMATICALLY
; When defined, this calls `signtool sign` 3 times during compilation:
; - photoqt.exe,
; - final portable exe
; ------------------------------------------------------------

!define SIGN_EXE_AUTOMATICALLY

; ------------------------------------------------------------
; ------------------------------------------------------------

Icon "assets\photoqt_portable.ico"
OutFile "photoqt-portable-${VERSION}.exe"

; only one (invisible) page
Page instfiles

Section

    ; all files are uncompressed into a temporary directory and run
    InitPluginsDir

    SetOutPath $pluginsdir

    ; Sign executable
    !ifdef SIGN_EXE_AUTOMATICALLY
        !system "signtool sign -v -tr http://time.certum.pl -fd SHA256 -td SHA256 app\files\photoqt.exe" = 0
    !endif

    File /r "app\files\"

    !ifdef SIGN_EXE_AUTOMATICALLY
        !finalize 'signtool sign -v -tr http://time.certum.pl -fd SHA256 -td SHA256 "%1"' = 0
    !endif

    ; the directory of the executable is passed on as we store config/cache data there
    ExecWait '"$pluginsdir\photoqt.exe" "$exedir" $CMDLINE'

    SetOutPath $temp

SectionEnd
