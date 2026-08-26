Var RadioIconDefault
Var RadioIconXmha97
Var ImageIconDefault
Var ImageIconXmha97
Var ImageIconDefaultHandle
Var ImageIconXmha97Handle
Var iconPreviouslySelected
Var iconRegValue

; --------------------------------------------------------------------------
; Custom page
; --------------------------------------------------------------------------

; This function does some default actions for a silent install (called from the Install.nsh page)
Function FileTypeIconSetSilent

    SetRegView 64

    ; Check if a previous install occured
    ReadRegStr $iconRegValue ShCtx "Software\PhotoQt" "FileTypeIconSetSelected"
    IfErrors icon_notset icon_set
    icon_set:
        StrCpy $iconPreviouslySelected 1
        Goto continueIcon
    icon_notset:
        StrCpy $iconPreviouslySelected 0
        StrCpy $iconRegValue "default"
    continueIcon:

    ; If the filetypes\ folder does not exist we recreate it
    IfFileExists "$INSTDIR\filetypes\*.*" nochange change
    change:
        StrCpy $iconPreviouslySelected 0
    nochange:

    ; install filetypes
    ${If} $iconPreviouslySelected == 0
        ${If} $iconRegValue == "xmha97"
            WriteRegStr ShCtx \
                "Software\PhotoQt" \
                "FileTypeIconSetSelected" \
                "default"
            SetOutPath "$INSTDIR\filetypes"
            File /nonfatal /a /r "app\filetypes_xmha97\"
        ${Else}
            WriteRegStr ShCtx \
                "Software\PhotoQt" \
                "FileTypeIconSetSelected" \
                "default"
            SetOutPath "$INSTDIR\filetypes"
            File /nonfatal /a /r "app\filetypes_default\"
        ${EndIf}
    ${EndIf}

FunctionEnd

Function FileTypeIconSetPage

    ; Once the filetpye icons have been selected this page is no longer shown
    ; Updating the file icon set requires a few manual steps to refresh the icon cache
    ; They are outlines in the FAQ on https://photoqt.org

    SetRegView 64

    ; Check if a previous install occured
    ReadRegStr $iconRegValue ShCtx "Software\PhotoQt" "FileTypeIconSetSelected"
    IfErrors icon_notset icon_set
    icon_set:
        StrCpy $iconPreviouslySelected 1
        Goto continueIcon
    icon_notset:
        StrCpy $iconPreviouslySelected 0
        StrCpy $iconRegValue "default"
    continueIcon:

    ; If the filetypes\ folder does not exist we recreate it
    IfFileExists "$INSTDIR\filetypes\*.*" nochange change
    change:
        StrCpy $iconPreviouslySelected 0
        StrCpy $iconRegValue "default"
    nochange:

    ; -----------------------------------------------------------------

    !insertmacro MUI_HEADER_TEXT "Icon set" "Select the file type icon set"

    nsDialogs::Create 1018
    Pop $0
    ${If} $0 == error
        Abort
    ${EndIf}

    ; Show intro text, depending on IF something can be done here or not
    ${If} $iconPreviouslySelected == 0
        ${NSD_CreateLabel} 0 0 100% 30u \
            "PhotoQt provides file type icons for all file types with which it has been associated. Here you can choose between two possible icon sets. To change the file icon set later, please refer to the FAQ on PhotoQt's website."
        Pop $0
    ${Else}
        ${NSD_CreateLabel} 0 0 100% 30u \
            "You already selected a file type icon set in a previous installation. To change the file type icon set now, please refer to the FAQ on PhotoQt's website for instructions."
        Pop $0
    ${EndIf}

    ;--------------------------------------------------------
    ; Default file type icon set
    ;--------------------------------------------------------

    ${NSD_CreateBitmap} 65u 30u 50u 60u ""
    Pop $ImageIconDefault
    ${NSD_SetImage} $ImageIconDefault "$PLUGINSDIR\filetypes_default.bmp" $ImageIconDefaultHandle
    ${NSD_OnClick} $ImageIconDefault SelectDefaultIconSet

    ${NSD_CreateRadioButton} 65u 100u 80u 12u "Default icon set"
    Pop $RadioIconDefault
    ${If} $iconRegValue != "xmha97"
	${NSD_Check} $RadioIconDefault
    ${EndIf}
    ${NSD_AddStyle} $RadioIconDefault ${WS_GROUP}

    ;--------------------------------------------------------
    ; Xmha97 file type icon set
    ;--------------------------------------------------------

    ${NSD_CreateBitmap} 165u 30u 50u 60u ""
    Pop $ImageIconXmha97
    ${NSD_SetImage} $ImageIconXmha97 "$PLUGINSDIR\filetypes_xmha97.bmp" $ImageIconXmha97Handle
    ${NSD_OnClick} $ImageIconXmha97 SelectXmha97IconSet

    ${NSD_CreateRadioButton} 155u 100u 80u 12u "xmha97 (M. Ammari)"
    Pop $RadioIconXmha97
    ${If} $iconRegValue == "xmha97"
        ${NSD_Check} $RadioIconXmha97
    ${EndIf}

    ;--------------------------------------------------------

    ; Disable controls if we don't allow changing them here
    ${If} $iconPreviouslySelected == 1
        EnableWindow $RadioIconDefault 0
        EnableWindow $RadioIconXmha97 0
    ${EndIf}

    ;--------------------------------------------------------
    ;--------------------------------------------------------

    ; Outtro
    ${NSD_CreateLabel} 0 120u 100% 35u \
        "If you want to contribute a file icon set to PhotoQt, please check out this FAQ and if you have any questions don't hesitate to get in touch: https://photoqt.org/about"
    Pop $0

    nsDialogs::Show

FunctionEnd

Function SelectDefaultIconSet
    ${If} $iconPreviouslySelected == 0
        ${NSD_Check} $RadioIconDefault
        ${NSD_Uncheck} $RadioIconXmha97
    ${EndIf}
FunctionEnd

Function SelectXmha97IconSet
    ${If} $iconPreviouslySelected == 0
        ${NSD_Check} $RadioIconXmha97
        ${NSD_Uncheck} $RadioIconDefault
    ${EndIf}
FunctionEnd

Function FileTypeIconSetLeave

    ${NSD_FreeImage} $ImageIconDefaultHandle
    ${NSD_FreeImage} $ImageIconXmha97Handle

    ${If} $iconPreviouslySelected == 0
        RMDir /r "$INSTDIR\filetypes"
        ${NSD_GetState} $RadioIconXmha97 $0
        ${If} $0 == ${BST_CHECKED}
            WriteRegStr ShCtx \
                "Software\PhotoQt" \
                "FileTypeIconSetSelected" \
                "xmha97"
            SetOutPath "$INSTDIR\filetypes"
            File /nonfatal /a /r "app\filetypes_xmha97\"
        ${Else}        
            WriteRegStr ShCtx \
                "Software\PhotoQt" \
                "FileTypeIconSetSelected" \
                "default"
            SetOutPath "$INSTDIR\filetypes"
            File /nonfatal /a /r "app\filetypes_default\"
        ${EndIf}
    ${EndIf}

FunctionEnd
