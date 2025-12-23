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
; - icon_portable.ico
; - photoqt-portable-setup.nsi (this file)
;
; IN ADDITION THE EXECUTABLE NEEDS TO BE BUILT WITH PORTABLE TWEAKS !!
;
; This will then create a new file in the application directory
; called photoqt-portable-%version%.exe.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Unicode True

SilentInstall silent

; we don't need any administrator privileges
RequestExecutionLevel user

; this is supposed to be the fastest to uncompress
SetCompressor ZLIB

!define PHOTOQT_VERSION "xxx"

Icon "icon_portable.ico"
OutFile "photoqt-portable-${PHOTOQT_VERSION}.exe"

; only one (invisible) page
Page instfiles

Section

	; all files are uncompressed into a temporary directory and run
	InitPluginsDir

	SetOutPath $pluginsdir
	File /r /x *nsh /x *nsi /x *qmlc /x photoqt-setup.exe ".\"

	; the directory of the executable is passed on as we store config/cache data there
	ExecWait '"$pluginsdir\photoqt.exe" "$exedir" $CMDLINE'

	SetOutPath $temp

SectionEnd
