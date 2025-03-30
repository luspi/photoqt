/*
_____________________________________________________________________________

                       File Association
_____________________________________________________________________________

 Based on code taken from http://nsis.sourceforge.net/File_Association

 Adapted for use in PhotoQt only as it includes PhotoQt-specific changes
 that wont work correctly as-is with other applications.

 Website: https://photoqt.org

_____________________________________________________________________________

 ${RegisterExtension} "[executable]" "[extension]" "[description]"

"[executable]"     ; executable which opens the file format
                   ;
"[extension]"      ; extension, which represents the file format to open
                   ;
"[description]"    ; description for the extension. This will be display in Windows Explorer.
                   ;


 ${UnRegisterExtension} "[extension]" "[description]"

"[extension]"      ; extension, which represents the file format to open
                   ;
"[description]"    ; description for the extension. This will be display in Windows Explorer.
                   ; this is currently not used and can be any string (including the empty string)

_____________________________________________________________________________

                         Macros
_____________________________________________________________________________

 Change log window verbosity (default: 3=no script)

 Example:
 !include "FileAssociation.nsh"
 !insertmacro RegisterExtension
 ${FileAssociation_VERBOSE} 4   # all verbosity
 !insertmacro UnRegisterExtension
 ${FileAssociation_VERBOSE} 3   # no script
*/


!ifndef FileAssociation_INCLUDED
!define FileAssociation_INCLUDED

!include Util.nsh
!include LogicLib.nsh

!verbose push
!verbose 3
!ifndef _FileAssociation_VERBOSE
  !define _FileAssociation_VERBOSE 3
!endif
!verbose ${_FileAssociation_VERBOSE}
!define FileAssociation_VERBOSE `!insertmacro FileAssociation_VERBOSE`
!verbose pop

!macro FileAssociation_VERBOSE _VERBOSE
  !verbose push
  !verbose 3
  !undef _FileAssociation_VERBOSE
  !define _FileAssociation_VERBOSE ${_VERBOSE}
  !verbose pop
!macroend



!macro RegisterExtensionCall _EXECUTABLE _EXTENSION _DESCRIPTION
  !verbose push
  !verbose ${_FileAssociation_VERBOSE}
  Push `${_DESCRIPTION}`
  Push `${_EXTENSION}`
  Push `${_EXECUTABLE}`
  ${CallArtificialFunction} RegisterExtension_
  !verbose pop
!macroend

!macro UnRegisterExtensionCall _EXTENSION _DESCRIPTION
  !verbose push
  !verbose ${_FileAssociation_VERBOSE}
  Push `${_EXTENSION}`
  Push `${_DESCRIPTION}`
  ${CallArtificialFunction} UnRegisterExtension_
  !verbose pop
!macroend

!macro UnRegisterExtensionOldCall _EXTENSION _DESCRIPTION
  !verbose push
  !verbose ${_FileAssociation_VERBOSE}
  Push `${_EXTENSION}`
  Push `${_DESCRIPTION}`
  ${CallArtificialFunction} UnRegisterExtensionOld_
  !verbose pop
!macroend

!macro UnRegisterExtensionApostropheCall _EXTENSION _DESCRIPTION
  !verbose push
  !verbose ${_FileAssociation_VERBOSE}
  Push `${_EXTENSION}`
  Push `${_DESCRIPTION}`
  ${CallArtificialFunction} UnRegisterExtensionApostrophe_
  !verbose pop
!macroend



!define RegisterExtension `!insertmacro RegisterExtensionCall`
!define un.RegisterExtension `!insertmacro RegisterExtensionCall`

!macro RegisterExtension
!macroend

!macro un.RegisterExtension
!macroend

!macro RegisterExtension_
  !verbose push
  !verbose ${_FileAssociation_VERBOSE}

  Exch $R2 ;exe
  Exch
  Exch $R1 ;ext
  Exch
  Exch 2
  Exch $R0 ;desc
  Exch 2
  Push $0
  Push $1
  Push $3

  ReadRegStr $1 HKCR ".$R1" ""  ; read current file association
  StrCmp "$1" "" NoBackup  ; is it empty
  StrCmp "$1" "PhotoQt - $R1" NoBackup  ; is it our own
    WriteRegStr HKCR ".$R1" "backup_val" "$1"  ; backup current value
NoBackup:
  WriteRegStr HKCR .$R1 "" "PhotoQt - $R1"  ; set our file association

  ReadRegStr $0 HKCR "PhotoQt - $R1" ""
  StrCmp $0 "" 0 Skip
    WriteRegStr HKCR "PhotoQt - $R1" "" "$R0"
    WriteRegStr HKCR "PhotoQt - $R1\shell" "" "open"
    WriteRegStr HKCR "PhotoQt - $R1\DefaultIcon" "" "$INSTDIR\filetypes\image.$R1.ico"
Skip:
  WriteRegStr HKCR "PhotoQt - $R1\shell\open\command" "" '"$R2" "%1"'

  Pop $3
  Pop $1
  Pop $0
  Pop $R2
  Pop $R1
  Pop $R0

  !verbose pop
!macroend

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!define UnRegisterExtension `!insertmacro UnRegisterExtensionCall`
!define un.UnRegisterExtension `!insertmacro UnRegisterExtensionCall`

!macro UnRegisterExtension
!macroend

!macro un.UnRegisterExtension
!macroend

!macro UnRegisterExtension_
  !verbose push
  !verbose ${_FileAssociation_VERBOSE}

  Exch $R1 ;desc
  Exch
  Exch $R0 ;ext
  Exch
  Push $0
  Push $1

  ReadRegStr $1 HKCR .$R0 ""
  StrCmp $1 "PhotoQt - $R0" 0 NoOwn ; only do this if we own it
  ReadRegStr $1 HKCR .$R0 "backup_val"
  StrCmp $1 "" 0 Restore ; if backup="" then delete the whole key
  DeleteRegKey HKCR .$R0
  Goto NoOwn

Restore:
  WriteRegStr HKCR .$R0 "" $1
  DeleteRegValue HKCR .$R0 "backup_val"
  DeleteRegKey HKCR "PhotoQt - $R0" ;Delete key with association name settings

NoOwn:

  Pop $1
  Pop $0
  Pop $R1
  Pop $R0

  !verbose pop
!macroend

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!define UnRegisterExtensionApostrophe `!insertmacro UnRegisterExtensionApostropheCall`
!define un.UnRegisterExtensionApostrophe `!insertmacro UnRegisterExtensionApostropheCall`

!macro UnRegisterExtensionApostrophe
!macroend

!macro un.UnRegisterExtensionApostrophe
!macroend

!macro UnRegisterExtensionApostrophe_
!verbose push
!verbose ${_FileAssociation_VERBOSE}

Exch $R1 ;desc
Exch
Exch $R0 ;ext
Exch
Push $0
Push $1

ReadRegStr $1 HKCR .$R0 ""
StrCmp $1 "'$R0'file" 0 NoOwnApostrophe ; only do this if we own it
ReadRegStr $1 HKCR .$R0 "backup_val"
StrCmp $1 "" 0 RestoreApostrophe ; if backup="" then delete the whole key
DeleteRegKey HKCR .$R0
Goto NoOwnApostrophe

RestoreApostrophe:
WriteRegStr HKCR .$R0 "" $1
DeleteRegValue HKCR .$R0 "backup_val"
DeleteRegKey HKCR "'$R0'file" ;Delete key with association name settings

NoOwnApostrophe:

Pop $1
Pop $0
Pop $R1
Pop $R0

!verbose pop
!macroend

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!define UnRegisterExtensionOld `!insertmacro UnRegisterExtensionOldCall`
!define un.UnRegisterExtensionOld `!insertmacro UnRegisterExtensionOldCall`

!macro UnRegisterExtensionOld
!macroend

!macro un.UnRegisterExtensionOld
!macroend

!macro UnRegisterExtensionOld_
!verbose push
!verbose ${_FileAssociation_VERBOSE}

Exch $R1 ;desc
Exch
Exch $R0 ;ext
Exch
Push $0
Push $1

ReadRegStr $1 HKCR .$R0 ""
StrCmp $1 "'$R0'file" 0 NoOwnOld ; only do this if we own it
ReadRegStr $1 HKCR .$R0 "backup_val"
StrCmp $1 "" 0 RestoreOld ; if backup="" then delete the whole key
DeleteRegKey HKCR .$R0
Goto NoOwnOld

RestoreOld:
WriteRegStr HKCR .$R0 "" $1
DeleteRegValue HKCR .$R0 "backup_val"
DeleteRegKey HKCR "'$R0'file" ;Delete key with association name settings

NoOwnOld:

Pop $1
Pop $0
Pop $R1
Pop $R0

!verbose pop
!macroend

!endif # !FileAssociation_INCLUDED
