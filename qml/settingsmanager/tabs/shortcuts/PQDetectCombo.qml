import QtQuick 2.9

import "../../../elements"
import "../../../shortcuts/mouseshortcuts.js" as PQAnalyseMouse

Rectangle {

    id: detect_top

    parent: settingsmanager_top

    anchors.fill: settingsmanager_top
    color: "#dd000000"

    visible: (opacity>0)
    opacity: 0
    Behavior on opacity { NumberAnimation { duration: 100 } }

    property string currentcombo: ""
    onCurrentcomboChanged: {
        canceltime.text = ((currentcombo[currentcombo.length-1] == "+") ? "5" : "2")
        canceltimer.restart()
    }

    Text {
        x: (parent.width-width)/2
        y: 10
        color: "white"
        font.pointSize: 12
        font.bold: true
        text: "Press any key combination, or perform any mouse gesture."
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
                txt_combo.text = handlingShortcuts.composeDisplayString(currentcombo)
        }
    }

    Text {
        id: canceltime
        x: parent.width-width-10
        y: parent.height-height-10
        text: ""
        color: "white"
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
        source: "/settingsmanager/shortcuts/categorykeyboard.png"
    }

    Image {
        id: cat_mouse
        x: parent.width/2 + (parent.width/2 - width)/2
        y: (parent.height-height)/2
        width: 100
        height: 100
        opacity: 0.2
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
            currentcombo = (mouse.button == Qt.LeftButton ? "Left Button" : (mouse.button == Qt.MiddleButton ? "Middle Button" : "Right Button"))
            cat_keys.opacity = 0.2
            cat_mouse.opacity = 0.6
        }

        onPositionChanged: {
            if(pressedEventInProgress) {
                canceltimer.restart()
                var mov = PQAnalyseMouse.analyseMouseGestureUpdate(mouse, pressedPosLast)
                if(mov != "") {
                    if(!currentcombo.endsWith(mov)) {
                        if(!(currentcombo.endsWith("N") || currentcombo.endsWith("S") || currentcombo.endsWith("E") || currentcombo.endsWith("W")))
                            currentcombo += "+"
                        currentcombo += mov
                    }
                    pressedPosLast = Qt.point(mouse.x, mouse.y)
                }

                canceltime.text = "5"
            }
        }

        onReleased: {
            pressedEventInProgress = false
            if(canceltime.text*1 > 2)
                canceltime.text = "2"
        }

    }

    PQButton {

        x: (parent.width-width)/2
        y: parent.height-height-20
        scale: 1.5
        text: "Cancel"
        onClicked: {
            currentcombo = ""
            canceltimer.stop()
            hide()
        }

    }

    Connections {

        target: settingsmanager_top

        onNewModsKeysCombo: {
            cat_keys.opacity = 0.6
            cat_mouse.opacity = 0.2
            currentcombo = handlingShortcuts.composeString(mods, keys)
        }

    }

    function show() {
        opacity = 1
        currentcombo = ""
        canceltime.text = "5"
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
