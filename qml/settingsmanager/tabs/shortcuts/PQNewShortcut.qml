/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

import QtQuick 2.9

import "../../../elements"
import "../../../shortcuts/mouseshortcuts.js" as PQAnalyseMouse

Rectangle {

    id: newshortcut_top

    parent: settingsmanager_top

    anchors.fill: parent

    color: "#ee000000"

    opacity: 0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }

    property bool dontResetKeys: false

    property var mouseComboMods: []
    property string mouseComboButton: ""
    property var mouseComboDirection: []

    property var keyComboMods: []
    property string keyComboKey: ""

    signal newCombo(var combo)

    function assembleKeyCombo() {

        var txt = ""

        if(keyComboMods.length > 0) {
            txt += "<b>" + keymousestrings.translateShortcut(keyComboMods.join("+")) + "</b>"
            txt += "<br>+<br>"
        }

        if(keyComboKey == "::PLUS::")
            txt += "<b>+</b>"
        else
            txt += "<b>" + keymousestrings.translateShortcut(keyComboKey) + "</b>"

        combo_txt.text = txt

        if(txt.slice(txt.length-7,txt.length) == "<b></b>" || txt == "")
            restartCancelTimer()
        else
            restartSaveTimer()

    }

    function assembleMouseCombo() {

        var txt = ""

        if(mouseComboMods.length > 0) {
            txt += "<b>" + keymousestrings.translateShortcut(mouseComboMods.join("+")) + "</b>"
            txt += "<br>+<br>"
        }

        txt += "<b>" + keymousestrings.translateShortcut(mouseComboButton) + "</b>"
        if(mouseComboDirection.length > 0) {
            txt += "<br>+<br>"
            txt += "<b>" + keymousestrings.translateShortcut(mouseComboDirection.join(""), true) + "</b>"
        }

        combo_txt.text = txt

        if(txt.slice(txt.length-7,txt.length) == "<b></b>" || txt == "")
            restartCancelTimer()
        else
            restartSaveTimer()

    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

    Text {
        id: titletxt
        y: 10
        width: parent.width
        font.bold: true
        font.pointSize: 15
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        text: em.pty+qsTranslate("settingsmanager_shortcuts", "Add New Shortcut")
    }

    Rectangle {

        x: (parent.width-width)/2
        y: (parent.height-height)/2-10
        width: Math.min(800, parent.width)
        height: Math.min(600, parent.height-titletxt.height-butcont.height-40)

        color: "#220000"
        border.width: 1
        border.color: "#330000"

        Text {
            id: instr_txt
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            color: "white"
            font.bold: true
            text: em.pty+qsTranslate("settingsmanager_shortcuts", "Perform a mouse gesture here or press any key combo")
        }

        Text {
            id: combo_txt
            anchors.fill: parent
            anchors.topMargin: instr_txt.height
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 20
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: "#cccccc"
        }

        PQMouseArea {

            id: mouseShMouse

            anchors.fill: parent

            hoverEnabled: true
            acceptedButtons: Qt.AllButtons

            property point pressedPosLast: Qt.point(-1,-1)
            property bool pressedEventInProgress: false
            property int buttonId: 0

            property bool ignoreSingleBecauseDouble: false

            doubleClickThreshold: PQSettings.interfaceDoubleClickThreshold

            onPressed: {

                if(ignoreSingleBecauseDouble) {
                    ignoreSingleBecauseDouble = false
                    return
                }

                pressedEventInProgress = true
                pressedPosLast = Qt.point(mouse.x, mouse.y)

                mouseComboMods = PQAnalyseMouse.analyseMouseModifiers(mouse.modifiers)
                mouseComboButton = (mouse.button == Qt.LeftButton
                                        ? "Left Button"
                                        : (mouse.button == Qt.MiddleButton
                                           ? "Middle Button"
                                           : (mouse.button == Qt.RightButton
                                              ? "Right Button"
                                              : (mouse.button == Qt.ForwardButton
                                                 ? "Forward Button"
                                                 : (mouse.button == Qt.BackButton
                                                    ? "Back Button"
                                                    : (mouse.button == Qt.TaskButton
                                                       ? "Task Button"
                                                       : (mouse.button == Qt.ExtraButton4
                                                          ? "Button #7"
                                                          : (mouse.button == Qt.ExtraButton5
                                                             ? "Button #8"
                                                             : (mouse.button == Qt.ExtraButton6
                                                                ? "Button #9"
                                                                : (mouse.button == Qt.ExtraButton7
                                                                   ? "Button #10"
                                                                   : "Unknown Button"))))))))))
                mouseComboDirection = []
                keyComboKey = ""
                keyComboMods = []

                assembleMouseCombo()

            }

            onDoubleClicked: {
                ignoreSingleBecauseDouble = true
                pressedEventInProgress = false
                keyComboMods = []
                keyComboKey = ""

                mouseComboMods = PQAnalyseMouse.analyseMouseModifiers(mouse.modifiers)
                mouseComboButton = "Double Click"
                mouseComboDirection = []

                assembleMouseCombo()
            }

            onPositionChanged: {
                if(pressedEventInProgress) {
                    var mov = PQAnalyseMouse.analyseMouseGestureUpdate(mouse, pressedPosLast)
                    if(mov != "") {
                        mouseComboMods = PQAnalyseMouse.analyseMouseModifiers(mouse.modifiers)
                        if(mouseComboDirection[mouseComboDirection.length-1] != mov) {
                            mouseComboDirection.push(mov)
                        }
                        pressedPosLast = Qt.point(mouse.x, mouse.y)
                    }
                    assembleMouseCombo()
                }
            }

            onReleased: {
                pressedEventInProgress = false
            }

           onWheel: {

               keyComboMods = []
               keyComboKey = ""

               mouseComboMods = PQAnalyseMouse.analyseMouseModifiers(wheel.modifiers)
               mouseComboButton = PQAnalyseMouse.analyseMouseWheelAction(mouseComboButton, wheel.angleDelta, wheel.modifiers, true)
               mouseComboDirection = []

               assembleMouseCombo()

           }

        }

    }

    Timer {
        id: canceltimer
        repeat: true
        running: false
        interval: 1000
        property int countdown: 10
        onTriggered: {
            countdown -= 1
            if(countdown == 0) {
                canceltimer.stop()
                cancelbut.clicked()
            }
        }
    }

    Timer {
        id: savetimer
        repeat: true
        running: false
        interval: 1000
        property int countdown: 10
        onTriggered: {
            countdown -= 1
            if(countdown == 0) {
                savetimer.stop()
                savebut.clicked()
            }
        }
    }

    Item {

        id: butcont
        x: (parent.width-width)/2
        y: parent.height-height-20
        width: row.width
        height: row.height

        Row {
            id: row
            spacing: 10
            PQButton {
                id: savebut
                text: (savetimer.running ? (genericStringSave+" (" + savetimer.countdown + ")") : genericStringSave)
                font.bold: savetimer.running
                onClicked: {
                    canceltimer.stop()
                    savetimer.stop()
                    newshortcut_top.opacity = 0
                    settingsmanager_top.modalWindowOpen = false
                    settingsmanager_top.detectingShortcutCombo = false

                    var combo = ""
                    if(keyComboKey != "") {
                        if(keyComboMods.length > 0) {
                            combo += keyComboMods.join("+")
                            combo += "+"
                        }
                        combo += keyComboKey
                    } else {
                        if(mouseComboMods.length > 0)
                            combo += mouseComboMods.join("+")+"+"
                        combo += mouseComboButton
                        if(mouseComboDirection.length > 0) {
                            combo += "+"
                            combo += mouseComboDirection.join("")
                        }
                    }
                    tile_top.addNewCombo(combo)
                }
            }
            PQButton {
                id: cancelbut
                text: (canceltimer.running ? genericStringCancel+" (" + canceltimer.countdown + ")" : genericStringCancel)
                font.bold: canceltimer.running
                onClicked: {
                    canceltimer.stop()
                    savetimer.stop()
                    newshortcut_top.opacity = 0
                    settingsmanager_top.modalWindowOpen = false
                    settingsmanager_top.detectingShortcutCombo = false
                }
            }
        }

    }

    Connections {

        target: settingsmanager_top

        onNewModsKeysCombo: {

            if(!visible) return

            var tmp_keyComboMods = []
            var tmp_keyComboKey = ""

            var combo = handlingShortcuts.composeString(mods, keys)
            combo = combo.replace("++","+::PLUS::")
            var parts = combo.split("+")
            for(var iP in parts) {
                var p = parts[iP]
                if(p == "Ctrl" || p == "Alt" || p == "Shift" || p == "Meta" || p == "Keypad")
                    tmp_keyComboMods.push(p)
                else
                    tmp_keyComboKey = p
            }

            mouseComboMods = []
            mouseComboButton = ""
            mouseComboDirection = []

            keyComboMods = tmp_keyComboMods
            keyComboKey = tmp_keyComboKey

            assembleKeyCombo()

        }

    }

    Connections {
        target: tile_top
        onShowNewShortcut: {

            mouseComboMods = []
            mouseComboButton = ""
            mouseComboDirection = []
            keyComboKey = ""
            keyComboMods = []

            restartCancelTimer()

            newshortcut_top.opacity = 1
            settingsmanager_top.modalWindowOpen = true
            settingsmanager_top.detectingShortcutCombo = true
        }
    }

    function restartCancelTimer() {
        savetimer.stop()
        canceltimer.countdown = 15
        canceltimer.start()
    }

    function restartSaveTimer() {
        canceltimer.stop()
        savetimer.countdown = 5
        savetimer.start()
    }

}
