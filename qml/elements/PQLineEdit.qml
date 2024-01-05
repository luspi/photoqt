/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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
import QtQuick.Controls
import PQCScriptsClipboard

Rectangle {

    id: edit_top

    width: 300
    height: 40
    color: warning ? "red" : (enabled ? (highlightBG ? PQCLook.baseColorActive : PQCLook.baseColorAccent) : PQCLook.baseColorHighlight)
    Behavior on color { ColorAnimation { duration: 200 } }
    border.width: 1
    border.color: PQCLook.baseColorHighlight
    z: -1

    property bool highlightBG: false
    property bool fontBold: false
    property bool warning: false

    property alias text: control.text
    property alias controlFocus: control.focus
    property alias controlActiveFocus: control.activeFocus

    property bool keepPlaceholderTextVisible: false
    property alias placeholderText: placeholder.text

    property var separators: [" ", "/", "\\", ".", "-", "+", "*", "(", ")", "&", "$", "#", "@", "!", ":", ";", "?", "<", ">", "[", "]", "{", "}", "=", "_", "\"", "'", "^", "%"]

    signal leftPressed()
    signal rightPressed()

    PQText {
        id: placeholder
        anchors.fill: parent
        color: PQCLook.textColorHighlight
        opacity: highlightBG ? 0.5 : 1
        font.weight: fontBold ? PQCLook.fontWeightBold : PQCLook.fontWeightNormal
        anchors.leftMargin: control.leftPadding
        verticalAlignment: Text.AlignVCenter
        visible: control.text===""||keepPlaceholderTextVisible
    }

    TextInput {

        id: control

        width: edit_top.width
        height: edit_top.height

        clip: true

        leftPadding: 5
        rightPadding: 5

        color: highlightBG ? PQCLook.textColorActive : PQCLook.textColor
        selectedTextColor: highlightBG ? PQCLook.textColor : PQCLook.textColorHighlight
        selectionColor: highlightBG ? PQCLook.baseColorAccent : PQCLook.baseColorHighlight

        font.pointSize: PQCLook.fontSize
        font.weight: fontBold ? PQCLook.fontWeightBold : PQCLook.fontWeightNormal

        verticalAlignment: TextInput.AlignVCenter

        focus: true

        enabled: opacity>0 && visible

        Keys.onLeftPressed: (event) => {
            edit_top.leftPressed()
            event.accepted = false
        }

        Keys.onRightPressed: (event) => {
            edit_top.rightPressed()
            event.accepted = false
        }

    }

    function removeToLeftSeperatorList() {
        var txt = control.text
        var pos = 0
        for(var i = control.cursorPosition-2; i >= 0; --i) {
            if(separators.indexOf(txt[i]) !== -1) {
                pos = i
                break
            }
        }
        control.remove(pos+1, control.cursorPosition)
    }

    function removeToRightSeperatorList() {
        var txt = control.text
        var pos = control.text.length
        for(var i = control.cursorPosition; i < control.text.length; ++i) {
            if(separators.indexOf(txt[i]) !== -1) {
                pos = i
                break
            }
        }
        control.remove(control.cursorPosition, pos+1)
    }

    function moveToLeftSeperatorList(alsoselect=false) {
        var txt = control.text
        var pos = 0
        for(var i = Math.max(0, control.cursorPosition-2); i >= 0; --i) {
            if(separators.indexOf(txt[i]) !== -1) {
                pos = i
                break
            }
        }
        pos = Math.min(pos+1, control.text.length)
        var oldpos = control.cursorPosition

        // this ensures we can reach the very front and then we stay there
        if(oldpos <= 1 && pos == 1)
            pos = 0

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

    function moveToRightSeperatorList(alsoselect=false) {
        var txt = control.text
        var pos = control.text.length
        for(var i = control.cursorPosition; i < control.text.length; ++i) {
            if(separators.indexOf(txt[i]) !== -1) {
                pos = i
                break
            }
        }
        pos = Math.min(pos+1, control.text.length)
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

    function getSelectedText() {
        return control.selectedText
    }

    function handleKeyEvents(key, mod) {

        if(key === Qt.Key_Backspace && mod === Qt.ControlModifier)
            removeToLeftSeperatorList()
        else if(key === Qt.Key_Delete && mod === Qt.ControlModifier)
            removeToRightSeperatorList()

        // move cursor
        else if(key === Qt.Key_Left && mod === Qt.ControlModifier)
            moveToLeftSeperatorList()
        else if(key === Qt.Key_Right && mod === Qt.ControlModifier)
            moveToRightSeperatorList()

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

            var cuttxt = getSelectedText()
            if(cuttxt === "")
                return
            PQCScriptsClipboard.copyTextToClipboard(cuttxt)
            control.remove(control.selectionStart, control.selectionEnd)

        } else if(key === Qt.Key_C && mod === Qt.ControlModifier) {

            var copytxt = getSelectedText()
            if(copytxt === "")
                copytxt = control.text
            PQCScriptsClipboard.copyTextToClipboard(copytxt)

        } else if(key === Qt.Key_V && mod === Qt.ControlModifier) {

            var pastetxt = PQCScriptsClipboard.getTextFromClipboard()
            if(pastetxt === "")
                return

            if(control.selectionStart !== control.selectionEnd)
                control.remove(control.selectionStart, control.selectionEnd)
            control.insert(control.cursorPosition, pastetxt)

        }

    }

    function isCursorAtEnd() {
        return (control.cursorPosition==control.text.length)
    }

    function undo() {
        control.undo()
    }

    function redo() {
        control.redo()
    }

}
