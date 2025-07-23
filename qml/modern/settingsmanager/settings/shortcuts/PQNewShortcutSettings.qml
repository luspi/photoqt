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

Rectangle {

    id: newshortcut_top

    anchors.fill: parent

    color: PQCLook.transColor 

    opacity: 0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: 200 } }

    property bool dontResetKeys: false

    property list<string> mouseComboMods: []
    property string mouseComboButton: ""
    property list<string> mouseComboDirection: []

    property list<string> keyComboMods: []
    property string keyComboKey: ""

    property int currentIndex: -1
    property int currentSubIndex: -1

    signal newCombo(var index, var subindex, var combo)

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

        combo_txt.text = txt

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

        combo_txt.text = txt

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

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

    PQTextXL {
        id: titletxt
        y: insidecont.y-2*height
        width: parent.width
        font.weight: PQCLook.fontWeightBold 
        horizontalAlignment: Text.AlignHCenter
        text: (newshortcut_top.currentSubIndex==-1 ? qsTranslate("settingsmanager", "Add New Shortcut") : qsTranslate("settingsmanager", "Set new shortcut"))
    }

    Rectangle {

        id: insidecont

        x: (parent.width-width)/2
        y: (parent.height-height)/2-10
        width: Math.min(800, parent.width)
        height: Math.min(600, parent.height-2*titletxt.height-2*butcont.height-40)

        color: PQCLook.baseColor 
        border.width: 1
        border.color: PQCLook.baseColorHighlight 

        PQText {
            id: instr_txt
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.weight: PQCLook.fontWeightBold 
            text: qsTranslate("settingsmanager", "Perform a mouse gesture here or press any key combo")
        }

        PQTextXL {
            id: combo_txt
            anchors.fill: parent
            anchors.topMargin: instr_txt.height
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Rectangle {
            id: resetmessage
            y: parent.height-height
            width: parent.width
            height: resetmessagetxt.height+20
            color: PQCLook.baseColorActive 
            opacity: 0
            // this needs to be done this way to avoid a binding loop warning
            onOpacityChanged: {
                visible = (opacity > 0)
            }

            visible: opacity>0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            PQText {
                id: resetmessagetxt
                y: 10
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                color: PQCLook.textColor 
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
            y: parent.height-height
            width: parent.width
            height: leftbutmessagetxt.height+20
            color: PQCLook.baseColorActive 
            opacity: 0
            // this needs to be done this way to avoid a binding loop warning
            onOpacityChanged: {
                visible = (opacity > 0)
            }

            visible: opacity>0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            PQText {
                id: leftbutmessagetxt
                y: 10
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                color: PQCLook.textColor 
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

                newshortcut_top.mouseComboMods = PQCScriptsShortcuts.analyzeModifier(mouse.modifiers) 
                newshortcut_top.mouseComboButton = PQCScriptsShortcuts.analyzeMouseButton(mouse.button) 
                newshortcut_top.mouseComboDirection = []
                newshortcut_top.keyComboKey = ""
                newshortcut_top.keyComboMods = []

                newshortcut_top.assembleMouseCombo()

            }

            onMouseDoubleClicked: (mouse) => {
                ignoreSingleBecauseDouble = true
                pressedEventInProgress = false
                newshortcut_top.keyComboMods = []
                newshortcut_top.keyComboKey = ""

                newshortcut_top.mouseComboMods = PQCScriptsShortcuts.analyzeModifier(mouse.modifiers) 
                newshortcut_top.mouseComboButton = "Double Click"
                newshortcut_top.mouseComboDirection = []

                newshortcut_top.assembleMouseCombo()
            }

            onPositionChanged: (mouse) => {
                if(pressedEventInProgress) {
                    var mov = PQCScriptsShortcuts.analyzeMouseDirection(Qt.point(mouse.x, mouse.y), pressedPosLast) 
                    if(mov !== "") {
                        newshortcut_top.mouseComboMods = PQCScriptsShortcuts.analyzeModifier(mouse.modifiers)
                        if(newshortcut_top.mouseComboDirection[newshortcut_top.mouseComboDirection.length-1] !== mov) {
                            newshortcut_top.mouseComboDirection.push(mov)
                        }
                        pressedPosLast = Qt.point(mouse.x, mouse.y)
                    }
                    newshortcut_top.assembleMouseCombo()
                }
            }

            onReleased: {
                pressedEventInProgress = false
            }

           onWheel: (wheel) => {

               newshortcut_top.keyComboMods = []
               newshortcut_top.keyComboKey = ""

               newshortcut_top.mouseComboMods = PQCScriptsShortcuts.analyzeModifier(wheel.modifiers) 
               newshortcut_top.mouseComboButton = PQCScriptsShortcuts.analyzeMouseWheel(wheel.angleDelta) 
               newshortcut_top.mouseComboDirection = []

               newshortcut_top.assembleMouseCombo()

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
        y: insidecont.y+insidecont.height+height
        width: row.width
        height: row.height

        Row {
            id: row
            spacing: 10
            PQButton {
                id: savebut
                text: (savetimer.running ? (genericStringSave+" (" + savetimer.countdown + ")") : genericStringSave)
                font.weight: (savetimer.running ? PQCLook.fontWeightBold : PQCLook.fontWeightNormal) 
                onClicked: {
                    newshortcut_top.hide()

                    var combo = ""
                    if(newshortcut_top.keyComboKey != "") {
                        if(newshortcut_top.keyComboMods.length > 0) {
                            combo += newshortcut_top.keyComboMods.join("+")
                            combo += "+"
                        }
                        combo += newshortcut_top.keyComboKey
                    } else {
                        if(newshortcut_top.mouseComboMods.length > 0)
                            combo += newshortcut_top.mouseComboMods.join("+") + "+"
                        combo += newshortcut_top.mouseComboButton
                        if(newshortcut_top.mouseComboDirection.length > 0) {
                            combo += "+"
                            combo += newshortcut_top.mouseComboDirection.join("")
                        }
                    }
                    newshortcut_top.newCombo(newshortcut_top.currentIndex, newshortcut_top.currentSubIndex, combo)
                }
            }
            PQButton {
                id: cancelbut
                text: (canceltimer.running ? genericStringCancel+" (" + canceltimer.countdown + ")" : genericStringCancel)
                font.weight: (canceltimer.running ? PQCLook.fontWeightBold : PQCLook.fontWeightNormal) 
                onClicked: {
                    newshortcut_top.hide()
                }
            }
        }

    }

    Connections {

        target: settingsmanager_top 

        function onPassOnShortcuts(mods: string, keys: string) {

            if(!newshortcut_top.visible) return

            newshortcut_top.mouseComboMods = []
            newshortcut_top.mouseComboButton = ""
            newshortcut_top.mouseComboDirection = []

            newshortcut_top.keyComboMods = PQCScriptsShortcuts.analyzeModifier(mods) 
            newshortcut_top.keyComboKey = PQCScriptsShortcuts.analyzeKeyPress(keys) 

            newshortcut_top.assembleKeyCombo()

        }

    }

    function show(index: int, subindex: int) {

        if(settingsmanager_top.popoutWindowUsed && PQCSettings.interfacePopoutSettingsManagerNonModal) { 
            PQCNotify.loaderOverrideVisibleItem("shortcuts")
        }

        mouseComboMods = []
        mouseComboButton = ""
        mouseComboDirection = []
        keyComboKey = ""
        keyComboMods = []

        combo_txt.text = ""
        leftbutmessage.opacity = 0
        resetmessage.opacity = 0

        restartCancelTimer()

        newshortcut_top.opacity = 1
        settingsmanager_top.passShortcutsToDetector = true

        newshortcut_top.currentIndex = index
        newshortcut_top.currentSubIndex = subindex

    }

    function hide() {

        savebut.contextmenu.close()
        cancelbut.contextmenu.close()

        canceltimer.stop()
        savetimer.stop()
        newshortcut_top.opacity = 0
        settingsmanager_top.passShortcutsToDetector = false 

        if(settingsmanager_top.popoutWindowUsed && PQCSettings.interfacePopoutSettingsManagerNonModal)
            PQCNotify.loaderRestoreVisibleItem()

    }

    function restartCancelTimer() {
        savetimer.stop()
        canceltimer.countdown = 15
        canceltimer.start()
    }

    function restartSaveTimer() {
        canceltimer.stop()
        savetimer.countdown = 1
        savetimer.start()
    }

    function stopSaveTimer() {
        canceltimer.stop()
        savetimer.stop()
        savetimer.countdown = 1
    }

}
