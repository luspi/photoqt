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

import QtQuick 2.9

import "./handleshortcuts.js" as HandleShortcuts

Item {

    anchors.fill: parent

    MouseArea {

        id: mousearea

        anchors.fill: parent
        acceptedButtons: Qt.AllButtons

        hoverEnabled: true

        cursorShape: emptymessage.visible ? Qt.PointingHandCursor : Qt.ArrowCursor

        property int angleDeltaX: 0
        property int angleDeltaY: 0

        onWheel: {

            if(variables.visibleItem!="")
                return

            if(PQSettings.imageviewUseMouseWheelForImageMove && wheel.modifiers==Qt.NoModifier) {
                imageitem.moveImageByMouse(wheel.angleDelta)
                return
            }

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

            angleDeltaX += wheel.angleDelta.x
            angleDeltaY += wheel.angleDelta.y

            var threshold = Math.max(10, (PQSettings.interfaceMouseWheelSensitivity-1)*120)

            if(Math.abs(angleDeltaX) <= threshold && Math.abs(angleDeltaY) <= threshold)
                return;

            if(angleDeltaY > threshold) {
                if(angleDeltaX < -threshold)
                    combo += "Wheel Up Left"
                else if(angleDeltaX > threshold)
                    combo += "Wheel Up Right"
                else
                    combo += "Wheel Up"
            } else if(angleDeltaY < -threshold) {
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

            HandleShortcuts.checkComboForShortcut(combo, Qt.point(angleDeltaX, angleDeltaY))

            angleDeltaX = 0
            angleDeltaY = 0

        }

        property var path: []
        property point prevPos: Qt.point(-1,-1)
        property string lastDirection: ""
        property var modifiers: []
        property var buttons: []
        property bool pressed: false

        onPressed: {
            processPressed(mouse)
        }

        onDoubleClicked:
            gotDoubleClick(mouse)

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
        }

        onReleased: {
            processReleased()
        }

    }

    function processPressed(mouse) {

        mousearea.prevPos = Qt.point(mouse.x, mouse.y)
        mousearea.lastDirection = ""
        mousearea.path = []
        mousearea.modifiers = []
        mousearea.buttons = []
        if(variables.visibleItem=="")
            mousearea.pressed = true
        else
            loader.passMouseEvent(variables.visibleItem, mouse.button, mouse.modifiers)

        if(mouse.buttons & Qt.LeftButton)
            mousearea.buttons.push("Left Button")
        if(mouse.buttons & Qt.MiddleButton)
            mousearea.buttons.push("Middle Button")
        if(mouse.buttons & Qt.RightButton)
            mousearea.buttons.push("Right Button")
        if(mouse.buttons & Qt.ForwardButton)
            mousearea.buttons.push("Forward Button")
        if(mouse.buttons & Qt.BackButton)
            mousearea.buttons.push("Back Button")
        if(mouse.buttons & Qt.TaskButton)
            mousearea.buttons.push("Task Button")
        if(mouse.buttons & Qt.ExtraButton4)
            mousearea.buttons.push("Button #7")
        if(mouse.buttons & Qt.ExtraButton5)
            mousearea.buttons.push("Button #8")
        if(mouse.buttons & Qt.ExtraButton6)
            mousearea.buttons.push("Button #9")
        if(mouse.buttons & Qt.ExtraButton7)
            mousearea.buttons.push("Button #10")

        if(mouse.modifiers & Qt.ControlModifier)
            mousearea.modifiers.push("Ctrl")
        if(mouse.modifiers & Qt.AltModifier)
            mousearea.modifiers.push("Alt")
        if(mouse.modifiers & Qt.ShiftModifier)
            mousearea.modifiers.push("Shift")
        if(mouse.modifiers & Qt.MetaModifier)
            mousearea.modifiers.push("Meta")
        if(mouse.modifiers & Qt.KeypadModifier)
            mousearea.modifiers.push("Keypad")

    }

    function processReleased() {

        if(variables.visibleItem!="")
            return

        var combo = mousearea.modifiers.join("+")
        if(combo != "")
            combo += "+"
        combo += mousearea.buttons.join("+")
        if(mousearea.path.length > 0)
            combo += "+"
        combo += mousearea.path.join("")

        mousearea.pressed = false

        // click outside of container
        if(combo == "Left Button") {
            if(PQSettings.interfaceCloseOnEmptyBackground) {
                if(!emptymessage.visible) {
                    toplevel.close()
                    return
                }
            } else if(PQSettings.interfaceWindowDecorationOnEmptyBackground && !emptymessage.visible) {
                PQSettings.interfaceWindowDecoration = !PQSettings.interfaceWindowDecoration
                return
            }
        }

        // a click on the empty background when no image is loaded shows filedialog
        if(emptymessage.visible && combo == "Left Button")
            loader.show("filedialog")
        else
            HandleShortcuts.checkComboForShortcut(combo)

    }

    function gotDoubleClick(mouse) {

        var mods = []

        if(mouse.modifiers & Qt.ControlModifier)
            mods.push("Ctrl")
        if(mouse.modifiers & Qt.AltModifier)
            mods.push("Alt")
        if(mouse.modifiers & Qt.ShiftModifier)
            mods.push("Shift")
        if(mouse.modifiers & Qt.MetaModifier)
            mods.push("Meta")
        if(mouse.modifiers & Qt.KeypadModifier)
            mods.push("Keypad")

        var combo = mods.join("+")
        if(combo != "")
            combo += "+"
        combo += keymousestrings.dictMouse["double click"]

        HandleShortcuts.checkComboForShortcut(combo)

    }

}
