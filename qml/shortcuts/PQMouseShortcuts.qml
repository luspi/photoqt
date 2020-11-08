/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
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

import "./handleshortcuts.js" as HandleShortcuts

Item {

    anchors.fill: parent

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton|Qt.RightButton|Qt.MiddleButton

        hoverEnabled: true

        cursorShape: emptymessage.visible ? Qt.PointingHandCursor : Qt.ArrowCursor

        property int angleDeltaX: 0
        property int angleDeltaY: 0

        onWheel: {

            if(variables.visibleItem!="")
                return

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

            angleDeltaX += wheel.angleDelta.x
            angleDeltaY += wheel.angleDelta.y

            var threshold = Math.max(10, PQSettings.mouseWheelSensitivity*120)

            if(Math.abs(angleDeltaX) <= threshold && Math.abs(angleDeltaY) <= threshold)
                return;

            if(angleDeltaY < -threshold) {
                if(angleDeltaX < -threshold)
                    combo += "Wheel Up Left"
                else if(angleDeltaX > threshold)
                    combo += "Wheel Up Right"
                else
                    combo += "Wheel Up"
            } else if(angleDeltaY > threshold) {
                if(angleDeltaX < -threshold)
                    combo += "Wheel Down Left"
                else if(angleDeltaX > threshold)
                    combo += "Wheel Down Right"
                else
                    combo += "Wheel Down"
            } else {
                if(angleDeltaX < -threshold)
                    combo += "Wheel Left"
                else if(angleDeltaX > threshold)
                    combo += "Wheel Right"
            }

            angleDeltaX = 0
            angleDeltaY = 0

            HandleShortcuts.checkComboForShortcut(combo)

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
            if(variables.visibleItem=="")
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

            if(variables.visibleItem != "")
                loader.passMouseEvent(variables.visibleItem, [buttons, modifiers])

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

            if(variables.visibleItem!="")
                return

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

            // a click on the empty background when no image is loaded shows filedialog
            if(emptymessage.visible && combo == "Left Button")
                loader.show("filedialog")
            else
                HandleShortcuts.checkComboForShortcut(combo)

        }

    }

}
