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

    id: detect_top

    parent: settingsmanager_top

    anchors.fill: parent

    color: "#dd000000"

    visible: (opacity>0)
    opacity: 0
    Behavior on opacity { NumberAnimation { duration: 100 } }

    property string timeoutDone: "2"
    property string timeoutWait: "10"

    property string previouscombo: ""
    property string currentcombo: ""
    onCurrentcomboChanged: {
        canceltime.text = ((currentcombo[currentcombo.length-1] == "+") ? timeoutWait : timeoutDone)
        canceltimer.restart()
    }

    Text {
        id: tit
        x: 0
        y: 20
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        color: "white"
        font.pointSize: 18
        font.bold: true
        text: em.pty+qsTranslate("settingsmanager_shortcuts", "Press any key combination, or perform any mouse gesture.")
    }

    Text {
        x: 0
        y: tit.y+tit.height+20
        width: parent.width
        visible: previouscombo!=""
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        color: "#888888"
        font.pointSize: 15
        font.bold: true
        text: em.pty+qsTranslate("settingsmanager_shortcuts", "Current shortcut:") + " <b>" + keymousestrings.translateShortcut(previouscombo) + "</b>"
    }

    Text {
        id: txt_combo
        x: (parent.width-width)/2
        y: (parent.height-height)/2
        width: (parent.width/2 - 120)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        font.pointSize: 25
        wrapMode: Text.WrapAnywhere
        color: "white"
        text: ""
        Connections {
            target: detect_top
            onCurrentcomboChanged:
                txt_combo.text = keymousestrings.translateShortcut(handlingShortcuts.composeDisplayString(currentcombo))
        }
    }

    Text {
        id: canceltime
        x: parent.width-width-10
        y: parent.height-height-10
        text: ""
        color: "white"
        scale: 1.5
        Timer {
            id: canceltimer
            interval: 1000
            repeat: true
            onTriggered: {
                parent.text = parent.text*1-1
                if(parent.text == "0") {
                    canceltimer.stop()
                    hide()
                }
            }
        }
    }

    Image {
        id: cat_keys
        x: (parent.width/2 - width)/2
        y: (parent.height-height)/2
        width: 100
        height: 100
        opacity: 0.2
        Behavior on opacity { NumberAnimation { duration: 100 } }
        source: "/settingsmanager/shortcuts/categorykeyboard.png"
    }

    Image {
        id: cat_mouse
        x: parent.width/2 + (parent.width/2 - width)/2
        y: (parent.height-height)/2
        width: 100
        height: 100
        opacity: 0.2
        Behavior on opacity { NumberAnimation { duration: 100 } }
        source: "/settingsmanager/shortcuts/categorymouse.png"
    }

    PQMouseArea {

        anchors.fill: parent

        hoverEnabled: true
        acceptedButtons: Qt.LeftButton|Qt.MiddleButton|Qt.RightButton

        property point pressedPosLast: Qt.point(-1,-1)
        property bool pressedEventInProgress: false
        property int buttonId: 0

        onPressed: {
            pressedEventInProgress = true
            pressedPosLast = Qt.point(mouse.x, mouse.y)
            currentcombo = (mouse.button == Qt.LeftButton ? keymousestrings.translateShortcut("Left Button") : (mouse.button == Qt.MiddleButton ? keymousestrings.translateShortcut("Middle Button") : keymousestrings.translateShortcut("Right Button")))
            cat_keys.opacity = 0.2
            cat_mouse.opacity = 0.8
        }

        onPositionChanged: {
            if(pressedEventInProgress) {
                canceltimer.restart()
                var mov = PQAnalyseMouse.analyseMouseGestureUpdate(mouse, pressedPosLast)
                if(mov != "") {
                    if(!currentcombo.endsWith(mov)) {
                        if(!(currentcombo.endsWith("N") || currentcombo.endsWith("S") || currentcombo.endsWith("E") || currentcombo.endsWith("W")))
                            currentcombo += "+"
                        currentcombo += keymousestrings.translateShortcut(mov)
                    }
                    pressedPosLast = Qt.point(mouse.x, mouse.y)
                }

                canceltime.text = timeoutWait
            }
        }

        onReleased: {
            pressedEventInProgress = false
            if(canceltime.text*1 > 2)
                canceltime.text = timeoutDone
        }

       onWheel: {
           var txt = PQAnalyseMouse.analyseMouseWheelAction(currentcombo, wheel.angleDelta, wheel.modifiers)
           currentcombo = txt
           if(txt.endsWith("+")) {
               canceltimer.restart()
               canceltime.text = timeoutWait
           } else {
               if(canceltime.text*1 > 2)
                   canceltime.text = timeoutDone
           }
       }

    }

    PQButton {

        x: (parent.width-width)/2
        y: parent.height-height-20
        scale: 1.5
        text: em.pty+qsTranslate("settingsmanager_shortcuts", "Cancel")
        onClicked: {
            currentcombo = ""
            canceltimer.stop()
            hide()
        }

    }

    Connections {

        target: settingsmanager_top

        onNewModsKeysCombo: {
            cat_keys.opacity = 0.8
            cat_mouse.opacity = 0.2
            currentcombo = handlingShortcuts.composeString(mods, keys)
        }

    }

    function show(curcombo) {
        opacity = 1
        currentcombo = ""
        previouscombo = curcombo
        canceltime.text = timeoutWait
        canceltimer.start()
        settingsmanager_top.modalWindowOpen = true
        settingsmanager_top.detectingShortcutCombo = true
    }

    function hide() {
        opacity = 0
        settingsmanager_top.modalWindowOpen = false
        settingsmanager_top.detectingShortcutCombo = false
    }

}
