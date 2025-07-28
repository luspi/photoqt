/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

import QtQuick
import PhotoQt.Modern
import PhotoQt.Shared

Rectangle {

    id: edit_top

    width: 300
    height: 40
    color: warning ? "red" : (enabled ? pqtPalette.alternateBase : pqtPalette.base)
    Behavior on color { ColorAnimation { duration: 200 } }
    border.width: 1
    border.color: PQCLook.baseBorder
    z: -1

    SystemPalette { id: pqtPalette }

    property bool highlightBG: false
    property bool fontBold: false
    property bool warning: false

    property alias text: control.text
    property alias controlFocus: control.focus
    property alias controlActiveFocus: control.activeFocus

    property alias lineedit: control

    property bool keepPlaceholderTextVisible: false
    property alias placeholderText: placeholder.text

    property var separators: [" ", "/", "\\", ".", "-", "+", "*", "(", ")", "&", "$", "#", "@", "!", ":", ";", "?", "<", ">", "[", "]", "{", "}", "=", "_", "\"", "'", "^", "%"]

    signal leftPressed()
    signal rightPressed()
    signal endPressed()
    signal pressed(var key, var modifiers)
    signal rightClicked()

    PQText {
        id: placeholder
        anchors.fill: parent
        color: pqtPalette.text
        opacity: edit_top.highlightBG ? 0.3 : 0.6
        elide: Text.ElideRight
        font.weight: edit_top.fontBold ? PQCLook.fontWeightBold : PQCLook.fontWeightNormal
        anchors.leftMargin: control.leftPadding
        verticalAlignment: Text.AlignVCenter
        visible: control.text===""||edit_top.keepPlaceholderTextVisible
    }

    TextInput {

        id: control

        width: edit_top.width
        height: edit_top.height

        clip: true

        leftPadding: 5
        rightPadding: 5

        color: pqtPalette.text
        selectedTextColor: PQCLook.highlightedText
        selectionColor: PQCLook.highlight

        font.pointSize: PQCLook.fontSize
        font.weight: edit_top.fontBold ? PQCLook.fontWeightBold : PQCLook.fontWeightNormal

        verticalAlignment: TextInput.AlignVCenter

        focus: true

        enabled: opacity>0 && visible

        Keys.onPressed: (event) => {
            if(event.key === Qt.Key_Left)
                edit_top.leftPressed()
            else if(event.key === Qt.Key_Right)
                edit_top.rightPressed()
            else if(event.key === Qt.Key_End)
                edit_top.endPressed()
            edit_top.pressed(event.key, event.modifiers)
            event.accepted = false
        }

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            acceptedButtons: Qt.RightButton
            onClicked:
                edit_top.rightClicked()
        }

    }

    function moveToEnd() {
        control.cursorPosition = control.text.length
    }

    function removeToLeftSeperatorList() {
        var txt = control.text
        var pos = 0
        for(var i = control.cursorPosition-1; i >= 0; --i) {
            if(separators.indexOf(txt[i]) !== -1) {
                pos = i
                break
            }
        }
        control.remove(pos, control.cursorPosition)
    }

    function removeToRightSeperatorList() {
        var txt = control.text
        var pos = control.text.length
        for(var i = control.cursorPosition+1; i < control.text.length; ++i) {
            if(separators.indexOf(txt[i]) !== -1) {
                pos = i
                break
            }
        }
        control.remove(control.cursorPosition, pos)
    }

    function moveToLeftSeperatorList(alsoselect : bool) {
        var txt = control.text
        var pos = 0
        for(var i = Math.max(0, control.cursorPosition-1); i >= 0; --i) {
            if(separators.indexOf(txt[i]) !== -1) {
                pos = i
                break
            }
        }
        pos = Math.min(pos, control.text.length)
        var oldpos = control.cursorPosition

        if(alsoselect) {
            if(control.selectionStart === control.selectionEnd) {
                control.select(oldpos, pos)
            } else if(control.selectionEnd == oldpos) {
                control.select(control.selectionStart, pos)
            } else
                control.select(control.selectionEnd, pos)
        } else
            control.cursorPosition = pos
    }

    function moveToRightSeperatorList(alsoselect : bool) {
        var txt = control.text
        var pos = control.text.length
        for(var i = control.cursorPosition+1; i < control.text.length; ++i) {
            if(separators.indexOf(txt[i]) !== -1) {
                pos = i
                break
            }
        }

        pos = Math.min(pos, control.text.length)
        var oldpos = control.cursorPosition

        if(alsoselect) {
            if(control.selectionStart === control.selectionEnd) {
                control.select(oldpos, pos)
            } else if(control.selectionEnd == oldpos) {
                control.select(control.selectionStart, pos)
            } else
                control.select(control.selectionEnd, pos)
        } else
            control.cursorPosition = pos
    }

    function setFocus() {
        control.forceActiveFocus()
        control.selectAll()
    }

    function getSelectedText() : string {
        return control.selectedText
    }

    function handleKeyEvents(key : int, mod : int) {

        if(key === Qt.Key_Backspace && mod === Qt.ControlModifier)
            removeToLeftSeperatorList()
        else if(key === Qt.Key_Delete && mod === Qt.ControlModifier)
            removeToRightSeperatorList()

        // move cursor
        else if(key === Qt.Key_Left && mod === Qt.ControlModifier)
            moveToLeftSeperatorList(false)
        else if(key === Qt.Key_Right && mod === Qt.ControlModifier)
            moveToRightSeperatorList(false)

        // move cursor and select
        else if(key === Qt.Key_Left && mod&Qt.ControlModifier && mod&Qt.ShiftModifier)
            moveToLeftSeperatorList(true)
        else if(key === Qt.Key_Right && mod&Qt.ControlModifier && mod&Qt.ShiftModifier)
            moveToRightSeperatorList(true)

        // select all
        else if(key === Qt.Key_A && mod === Qt.ControlModifier)
            setFocus()

        // undo/redo
        else if(key === Qt.Key_Z && mod === Qt.ControlModifier)
            undo()
        else if((key === Qt.Key_Y && mod === Qt.ControlModifier) || (key === Qt.Key_Z && mod&Qt.ControlModifier && mod&Qt.ShiftModifier))
            redo()

        // cut, copy and paste
        else if(key === Qt.Key_X && mod === Qt.ControlModifier) {

            actionCut()

        } else if(key === Qt.Key_C && mod === Qt.ControlModifier) {

            actionCopy()

        } else if(key === Qt.Key_V && mod === Qt.ControlModifier) {

            actionPaste()

        }

    }

    function actionCut() {

        var cuttxt = getSelectedText()
        if(cuttxt === "")
            return
        PQCScriptsClipboard.copyTextToClipboard(cuttxt)
        control.remove(control.selectionStart, control.selectionEnd)

    }

    function actionCopy() {

        var copytxt = getSelectedText()
        if(copytxt === "")
            copytxt = control.text
        PQCScriptsClipboard.copyTextToClipboard(copytxt)

    }

    function actionPaste() {

        var pastetxt = PQCScriptsClipboard.getTextFromClipboard()
        if(pastetxt === "")
            return

        if(control.selectionStart !== control.selectionEnd)
            control.remove(control.selectionStart, control.selectionEnd)
        control.insert(control.cursorPosition, pastetxt)

    }

    function actionDelete() {
        control.remove(control.selectionStart, control.selectionEnd)
    }

    function isCursorAtEnd() : bool {
        return (control.cursorPosition===control.text.length)
    }

    function undo() {
        control.undo()
    }

    function redo() {
        control.redo()
    }

}
