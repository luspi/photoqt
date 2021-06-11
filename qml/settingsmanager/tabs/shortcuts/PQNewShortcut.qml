/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
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
    Behavior on opacity { NumberAnimation { duration: PQSettings.animationDuration*100 } }

    property bool dontResetKeys: false

    property string mouseComboButton: ""
    property var mouseComboDirection: []
    onMouseComboButtonChanged:
        assembleCombo()
    onMouseComboDirectionChanged:
        assembleCombo()

    property var keyComboMods: []
    property string keyComboKey: ""
    onKeyComboModsChanged:
        assembleCombo()
    onKeyComboKeyChanged:
        assembleCombo()

    signal newCombo(var combo)

    function assembleCombo() {

        var txt = ""

        if(keyComboMods.length > 0) {
            txt += "<b>" + keyComboMods.join("+") + "</b>"
            txt += "<br>+<br>"
        }

        if(keyComboKey != "") {
            if(keyComboKey == "::PLUS::")
                txt += "<b>+</b>"
            else
                txt += "<b>" + keyComboKey + "</b>"
        } else {

            if(mouseComboButton != "") {
                txt += "<b>" + mouseComboButton + "</b>"
                if(mouseComboDirection.length > 0)
                    txt += "<br>+<br>"
            }
            if(mouseComboDirection.length > 0) {
//                var tmp = []
//                for(var iMCD in mouseComboDirection)
//                    tmp.push(keymousestrings.translateShortcut(mouseComboDirection[iMCD]))

                txt += "<b>" + mouseComboDirection.join("") + "</b>"
            }

        }

        combo_txt.text = txt

        if(txt.slice(txt.length-9,txt.length) == "<br>+<br>" || txt == "")
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
        width: Math.min(500, parent.width)
        height: Math.min(500, parent.height-titletxt.height-butcont.height-40)

        color: "#330000"
        border.width: 1
        border.color: "#550000"

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
            acceptedButtons: Qt.LeftButton|Qt.MiddleButton|Qt.RightButton

            property point pressedPosLast: Qt.point(-1,-1)
            property bool pressedEventInProgress: false
            property int buttonId: 0

            onPressed: {
                pressedEventInProgress = true
                pressedPosLast = Qt.point(mouse.x, mouse.y)
                mouseComboButton = (mouse.button == Qt.LeftButton ? "Left Button" : (mouse.button == Qt.MiddleButton ? "Middle Button" : "Right Button"))

                if(!dontResetKeys) {
                    mouseComboDirection = []
                    keyComboKey = ""
                    keyComboMods = []
                }
                dontResetKeys = false
            }

            onPositionChanged: {
                if(pressedEventInProgress) {
                    var mov = PQAnalyseMouse.analyseMouseGestureUpdate(mouse, pressedPosLast)
//                    if(mov == "N") mov = "North"
//                    if(mov == "E") mov = "East"
//                    if(mov == "S") mov = "South"
//                    if(mov == "W") mov = "West"
                    if(mov != "") {
                        if(mouseComboDirection[mouseComboDirection.length-1] != mov) {
                            mouseComboDirection.push(mov)
                            mouseComboDirectionChanged()
                        }
                        pressedPosLast = Qt.point(mouse.x, mouse.y)
                    }
                }
            }

            onReleased: {
                pressedEventInProgress = false
            }

           onWheel: {
               mouseComboDirection = []
               keyComboKey = ""
               var txt = PQAnalyseMouse.analyseMouseWheelAction(mouseComboButton, wheel.angleDelta, wheel.modifiers)
               if(txt.indexOf("+") != -1) {
                   var parts = txt.split("+")
                   console.log(parts)
                   mouseComboButton = parts[parts.length-1]
                   keyComboMods = parts.slice(0, parts.length-1)
               } else {
                   keyComboMods = []
                   mouseComboButton = txt
               }

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
                    var combo = keyComboMods.join("+")+"+"
                    if(mouseComboButton != "") {
                        combo += mouseComboButton
                        if(mouseComboDirection.length > 0) {
                            combo += "+"
                            combo += mouseComboDirection.join("")
                        }
                    } else
                        combo += keyComboKey
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

    Timer {
        id: dontResetKeysTimer
        interval: 1500
        repeat: false
        running: false
        onTriggered:
            dontResetKeys = false
    }

    Connections {

        target: settingsmanager_top

        onNewModsKeysCombo: {
            if(!visible) return
            keyComboMods = []
            keyComboKey = ""
            mouseComboButton = ""
            mouseComboDirection = []
            var tmp = []
            var combo = handlingShortcuts.composeString(mods, keys)
            combo = combo.replace("++","+::PLUS::")
            var parts = combo.split("+")
            for(var iP in parts) {
                var p = parts[iP]
                if(p == "Ctrl" || p == "Alt" || p == "Shift" || p == "Meta" || p == "Keypad")
                    tmp.push(p)
                else
                    keyComboKey = p
            }
            keyComboMods = tmp

            dontResetKeys = true
            dontResetKeysTimer.restart()

        }

    }

    Connections {
        target: tile_top
        onShowNewShortcut: {
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

    Connections {
        target: PQKeyPressChecker
        onReceivedKeyRelease: {
            if(!visible) return
            // reset if current combo ends with '+'
            var tmp = combo_txt.text
            tmp = tmp.slice(tmp.length-9,tmp.length)
            if(tmp == "<br>+<br>") {
                keyComboMods = []
                keyComboKey = ""
            }
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
