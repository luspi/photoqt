/**************************************************************************
 * *                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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
import PhotoQt

Item {

    id: detect_top

    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        opacity: 0.95
        color: palette.alternateBase
    }

    opacity: 0
    visible: opacity>0
    Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }

    property string prevShortcut: ""
    property int toChangeCommandIndex: -1
    property int toChangeComboIndex: -1

    property list<string> mouseComboMods: []
    property string mouseComboButton: ""
    property list<string> mouseComboDirection: []

    property list<string> keyComboMods: []
    property string keyComboKey: ""

    PQTextL {
        x: (parent.width-width)/2
        y: parent.height*0.1
        font.weight: PQCLook.fontWeightBold
        text: qsTranslate("settingsmanager", "Perform any mouse gesture or press any key combo")
    }

    Column {

        y: (parent.height-height)/2
        width: parent.width

        spacing: 10

        Rectangle {
            id: resetmessage
            width: parent.width
            height: resetmessagetxt.height+20
            color: palette.alternateBase
            opacity: 0
            // this needs to be done this way to avoid a binding loop warning
            onOpacityChanged: {
                visible = (opacity > 0)
            }

            visible: opacity>0
            Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
            PQText {
                id: resetmessagetxt
                y: 10
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                color: palette.text
                text: qsTranslate("settingsmanager", "This key combination is reserved.") + "<br>\n" +
                      qsTranslate("settingsmanager", "You can use it to reset PhotoQt to its default state.")
            }
            SequentialAnimation {
                loops: Animation.Infinite
                running: resetmessage.visible
                PropertyAnimation { target: resetmessage; property: "opacity"; from: 1; to: 0.8; duration: 400 }
                PropertyAnimation { target: resetmessage; property: "opacity"; from: 0.8; to: 1; duration: 400 }
            }
        }

        Rectangle {
            id: leftbutmessage
            width: parent.width
            height: leftbutmessagetxt.height+20
            color: palette.alternateBase
            opacity: 0
            // this needs to be done this way to avoid a binding loop warning
            onOpacityChanged: {
                visible = (opacity > 0)
            }

            visible: opacity>0
            Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
            PQText {
                id: leftbutmessagetxt
                y: 10
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                color: palette.text
                text: qsTranslate("settingsmanager", "The left button is used for moving the main image around.") + "<br>\n" +
                      qsTranslate("settingsmanager", "It can be used as part of a shortcut only when combined with modifier buttons (Alt, Ctrl, etc.).")
            }
            SequentialAnimation {
                loops: Animation.Infinite
                running: leftbutmessage.visible
                PropertyAnimation { target: leftbutmessage; property: "opacity"; from: 1; to: 0.8; duration: 400 }
                PropertyAnimation { target: leftbutmessage; property: "opacity"; from: 0.8; to: 1; duration: 400 }
            }
        }

        PQTextXXL {
            id: newsh_txt
            x: (parent.width-width)/2
            horizontalAlignment: Text.AlignHCenter
            font.weight: PQCLook.fontWeightBold
            text: "..."
        }

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

        doubleClickThreshold: PQCSettings.interfaceDoubleClickThreshold

        onPressed: (mouse) => {

            if(ignoreSingleBecauseDouble) {
                ignoreSingleBecauseDouble = false
                return
            }

            pressedEventInProgress = true
            pressedPosLast = Qt.point(mouse.x, mouse.y)

            detect_top.mouseComboMods = PQCScriptsShortcuts.analyzeModifier(mouse.modifiers)
            detect_top.mouseComboButton = PQCScriptsShortcuts.analyzeMouseButton(mouse.button)
            detect_top.mouseComboDirection = []
            detect_top.keyComboKey = ""
            detect_top.keyComboMods = []

            detect_top.assembleMouseCombo()

        }

        onMouseDoubleClicked: (mouse) => {
            ignoreSingleBecauseDouble = true
            pressedEventInProgress = false
            detect_top.keyComboMods = []
            detect_top.keyComboKey = ""

            detect_top.mouseComboMods = PQCScriptsShortcuts.analyzeModifier(mouse.modifiers)
            detect_top.mouseComboButton = "Double Click"
            detect_top.mouseComboDirection = []

            detect_top.assembleMouseCombo()
        }

        onPositionChanged: (mouse) => {
            if(pressedEventInProgress) {
                var mov = PQCScriptsShortcuts.analyzeMouseDirection(Qt.point(mouse.x, mouse.y), pressedPosLast)
                if(mov !== "") {
                    detect_top.mouseComboMods = PQCScriptsShortcuts.analyzeModifier(mouse.modifiers)
                    if(detect_top.mouseComboDirection[detect_top.mouseComboDirection.length-1] !== mov) {
                        detect_top.mouseComboDirection.push(mov)
                    }
                    pressedPosLast = Qt.point(mouse.x, mouse.y)
                }
                detect_top.assembleMouseCombo()
            }
        }

        onReleased: {
            pressedEventInProgress = false
        }

       onWheel: (wheel) => {

           detect_top.keyComboMods = []
           detect_top.keyComboKey = ""

           detect_top.mouseComboMods = PQCScriptsShortcuts.analyzeModifier(wheel.modifiers)
           detect_top.mouseComboButton = PQCScriptsShortcuts.analyzeMouseWheel(wheel.angleDelta)
           detect_top.mouseComboDirection = []

           detect_top.assembleMouseCombo()

       }

    }

    Column {
        y: (parent.height-height)*0.9
        width: parent.width

        spacing: 50

        Row {
            x: (parent.width-width)/2
            spacing: 5
            visible: detect_top.prevShortcut!==""
            PQText {
                text: "Old shortcut:"
            }
            PQText {
                font.weight: PQCLook.fontWeightBold
                text: detect_top.prevShortcut
            }
        }

        Row {
            x: (parent.width-width)/2
            spacing: 5
            PQButton {
                id: savebut
                text: (savetimer.running ? (genericStringSave+" (" + savetimer.countdown + ")") : genericStringSave)
                fontWeight: (savetimer.running ? PQCLook.fontWeightBold : PQCLook.fontWeightNormal)
                onClicked: {

                    var combo = ""
                    if(detect_top.keyComboKey != "") {
                        if(detect_top.keyComboMods.length > 0) {
                            combo += detect_top.keyComboMods.join("+")
                            combo += "+"
                        }
                        combo += detect_top.keyComboKey
                    } else {
                        if(detect_top.mouseComboMods.length > 0)
                            combo += detect_top.mouseComboMods.join("+") + "+"
                        combo += detect_top.mouseComboButton
                        if(detect_top.mouseComboDirection.length > 0) {
                            combo += "+"
                            combo += detect_top.mouseComboDirection.join("")
                        }
                    }

                    PQCNotify.settingsmanagerSendCommand("newShortcut", [detect_top.toChangeCommandIndex, detect_top.toChangeComboIndex, combo])

                    detect_top.hide()

                }
            }

            PQButton {
                id: cancelbut
                text: (canceltimer.running ? genericStringCancel+" (" + canceltimer.countdown + ")" : genericStringCancel)
                fontWeight: (canceltimer.running ? PQCLook.fontWeightBold : PQCLook.fontWeightNormal)
                onClicked: {
                    detect_top.hide()
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

    Connections {

        target: PQCNotify

        function onSettingsmanagerSendCommand(what : string, args : list<var>) {

            if(what === "changeShortcut") {
                detect_top.prevShortcut = args[0]
                detect_top.toChangeCommandIndex = args[1]
                detect_top.toChangeComboIndex = args[2]
                detect_top.show()
            } else if(what === "newShortcut") {
                detect_top.prevShortcut = ""
                detect_top.toChangeCommandIndex = args[0]
                detect_top.toChangeComboIndex = -1
                detect_top.show()
            }

        }

    }

    Connections {

        target: PQCNotify

        enabled: (detect_top.opacity > 0)

        function onLoaderPassOn(what : string, param : list<var>) {

            if(what === "keyEvent") {

                detect_top.mouseComboMods = []
                detect_top.mouseComboButton = ""
                detect_top.mouseComboDirection = []

                detect_top.keyComboMods = PQCScriptsShortcuts.analyzeModifier(param[1])
                detect_top.keyComboKey = PQCScriptsShortcuts.analyzeKeyPress(param[0])

                detect_top.assembleKeyCombo()

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
        savetimer.countdown = 2
        savetimer.start()
    }

    function stopSaveTimer() {
        canceltimer.stop()
        savetimer.stop()
        savetimer.countdown = 1
    }

    function assembleKeyCombo() {

        leftbutmessage.opacity = 0
        resetmessage.opacity = 0
        savebut.enabled = true

        var txt = ""
        var plaintxt = ""

        if(keyComboMods.length > 0) {
            txt += "<b>" + PQCScriptsShortcuts.translateShortcut(keyComboMods.join("+")) + "</b>"
            txt += "<br>+<br>"
            plaintxt += keyComboMods.join("+")+"+"
        }

        if(keyComboKey == "::PLUS::") {
            txt += "<b>+</b>"
            plaintxt += "+"
        } else {
            txt += "<b>" + PQCScriptsShortcuts.translateShortcut(keyComboKey) + "</b>"
            plaintxt += keyComboKey
        }

        newsh_txt.text = txt

        if(plaintxt === "Ctrl+Alt+Shift+R") {
            resetmessage.opacity = 1
            stopSaveTimer()
            savebut.enabled = false
        } else {
            resetmessage.opacity = 0
            leftbutmessage.opacity = 0
            savebut.enabled = true
            if(txt.slice(txt.length-7,txt.length) == "<b></b>" || txt == "")
                restartCancelTimer()
            else
                restartSaveTimer()
        }

    }

    function assembleMouseCombo() {

        var txt = ""

        if(mouseComboMods.length > 0) {
            txt += "<b>" + PQCScriptsShortcuts.translateShortcut(mouseComboMods.join("+")) + "</b>"
            txt += "<br>+<br>"
        }

        txt += "<b>" + PQCScriptsShortcuts.translateShortcut(mouseComboButton) + "</b>"
        if(mouseComboDirection.length > 0) {
            txt += "<br>+<br>"
            txt += "<b>" + PQCScriptsShortcuts.translateMouseDirection(mouseComboDirection) + "</b>"
        }

        newsh_txt.text = txt

        if(mouseComboMods.length == 0 && mouseComboButton == "Left Button" && PQCSettings.imageviewUseMouseLeftButtonForImageMove) {
            leftbutmessage.opacity = 1
            stopSaveTimer()
            savebut.enabled = false
        } else {
            leftbutmessage.opacity = 0
            resetmessage.opacity = 0
            if(txt.slice(txt.length-7,txt.length) == "<b></b>" || txt == "")
                restartCancelTimer()
            else {
                restartSaveTimer()
                savebut.enabled = true
            }
        }

    }

    function show() {

        mouseComboMods = []
        mouseComboButton = ""
        mouseComboDirection = []
        keyComboKey = ""
        keyComboMods = []

        newsh_txt.text = "..."
        leftbutmessage.opacity = 0
        resetmessage.opacity = 0

        restartCancelTimer()
        savebut.enabled = false

        opacity = 1
        detect_top.forceActiveFocus()
    }

    function hide() {
        canceltimer.stop()
        savetimer.stop()
        opacity = 0
        PQCNotify.resetActiveFocus()
    }

}
