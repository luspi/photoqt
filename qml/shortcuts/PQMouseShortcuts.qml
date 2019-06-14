import QtQuick 2.9

import "./handleshortcuts.js" as HandleShortcuts

Item {

    anchors.fill: parent

    MouseArea {
        enabled: variables.visibleItem==""
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton|Qt.RightButton|Qt.MiddleButton

        hoverEnabled: true

        onWheel: {

            var combo = ""

            if(wheel.modifiers & Qt.ControlModifier)
                combo += "Ctrl+";
            if(wheel.modifiers & Qt.AltModifier)
                combo += "Alt+";
            if(wheel.modifiers & Qt.ShiftModifier)
                combo += "Shift+";
            if(wheel.modifiers & Qt.MetaModifier)
                combo += "Meta+";
            if(wheel.modifiers & Qt.KeypadModifier)
                combo += "Keypad+";

            if(wheel.buttons & Qt.LeftButton)
                combo += "Left Button"
            if(wheel.buttons & Qt.MiddleButton)
                combo += "Middle Button"
            if(wheel.buttons & Qt.RightButton)
                combo += "Right Button"

            var threshold = Math.max(30, Math.max(0, Math.min(10, PQSettings.mouseWheelSensitivity*120)))

            if(wheel.angleDelta.y < -threshold) {
                if(wheel.angleDelta.x < -threshold)
                    combo += "Wheel Up Left"
                else if(wheel.angleDelta.x > threshold)
                    combo += "Wheel Up Right"
                else
                    combo += "Wheel Up"
            } else if(wheel.angleDelta.y > threshold) {
                if(wheel.angleDelta.x < -threshold)
                    combo += "Wheel Down Left"
                else if(wheel.angleDelta.x > threshold)
                    combo += "Wheel Down Right"
                else
                    combo += "Wheel Down"
            } else {
                if(wheel.angleDelta.x < -threshold)
                    combo += "Wheel Left"
                else if(wheel.angleDelta.x > threshold)
                    combo += "Wheel Right"
            }


            for(var i = 0; i < variables.shortcuts.length; ++i) {

                if(variables.shortcuts[i][1] === combo) {
                    HandleShortcuts.whatToDoWithFoundShortcut(variables.shortcuts[i])
                    break;
                }

            }

        }

        property var path: []
        property point prevPos: Qt.point(-1,-1)
        property string lastDirection: ""
        property var modifiers: []
        property var buttons: []
        property bool pressed: false

        onPressed: {
            prevPos = Qt.point(mouse.x, mouse.y)
            lastDirection = ""
            path = []
            modifiers = []
            buttons = []
            pressed = true

            if(mouse.buttons & Qt.LeftButton)
                buttons.push("Left Button")
            if(mouse.buttons & Qt.MiddleButton)
                buttons.push("Middle Button")
            if(mouse.buttons & Qt.RightButton)
                buttons.push("Right Button")

            if(mouse.modifiers & Qt.ControlModifier)
                modifiers.push("Ctrl")
            if(mouse.modifiers & Qt.AltModifier)
                modifiers.push("Alt")
            if(mouse.modifiers & Qt.ShiftModifier)
                modifiers.push("Shift")
            if(mouse.modifiers & Qt.MetaModifier)
                modifiers.push("Meta")
            if(mouse.modifiers & Qt.KeypadModifier)
                modifiers.push("Keypad")

        }

        onPositionChanged: {

            var threshold = 50

            if(pressed) {
                var dx = prevPos.x-mouse.x
                var dy = prevPos.y-mouse.y
                if(dx > threshold) {
                    if(lastDirection != "W") {
                        lastDirection = "W"
                        path.push("W")
                    }
                    prevPos = Qt.point(mouse.x, mouse.y)
                } else if(dx < -threshold) {
                    if(lastDirection != "E") {
                        lastDirection = "E"
                        path.push("E")
                    }
                    prevPos = Qt.point(mouse.x, mouse.y)
                } else if(dy > threshold) {
                    if(lastDirection != "N") {
                        lastDirection = "N"
                        path.push("N")
                    }
                    prevPos = Qt.point(mouse.x, mouse.y)
                } else if(dy < -threshold) {
                    if(lastDirection != "S") {
                        lastDirection = "S"
                        path.push("S")
                    }
                    prevPos = Qt.point(mouse.x, mouse.y)
                }
            }

            variables.mousePos = Qt.point(mouse.x, mouse.y)
        }

        onReleased: {

            var combo = modifiers.join("+")
            if(combo != "")
                combo += "+"
            combo += buttons.join("+")
            if(path.length > 0)
                combo += "+"
            combo += path.join("")

            pressed = false

            // click outside of container
            if(combo == "Left Button" && PQSettings.closeOnEmptyBackground) {
                toplevel.close()
                return
            }

            for(var i = 0; i < variables.shortcuts.length; ++i) {

                if(variables.shortcuts[i][1] === combo) {
                    HandleShortcuts.whatToDoWithFoundShortcut(variables.shortcuts[i])
                    break;
                }

            }

        }

    }

}
