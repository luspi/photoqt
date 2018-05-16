/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
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

function analyseMouseGestureUpdate(xPos, yPos, before) {

    verboseMessage("Shortcuts/mouseshortcuts.js", "analyseMouseGestureUpdate(): " + xPos + " / " + yPos + " / " + before.x + " / " + before.y)

    var threshold = 50

    var dx = xPos-before.x
    var dy = yPos-before.y
    var distance = Math.sqrt(Math.pow(dx,2)+Math.pow(dy,2));

    var angle = (Math.atan2(dy, dx)/Math.PI)*180
    angle = (angle+360)%360;

    if(distance > threshold) {

        if(angle <= 45 || angle > 315) {
            if(variables.shortcutsMouseGesture[variables.shortcutsMouseGesture.length-1] !== "E") {
                variables.shortcutsMouseGesture.push("E")
                variables.shorcutsMouseGesturePointIntermediate = Qt.point(xPos, yPos)
                return true
            }
        } else if(angle > 45 && angle <= 135) {
            if(variables.shortcutsMouseGesture[variables.shortcutsMouseGesture.length-1] !== "S") {
                variables.shortcutsMouseGesture.push("S")
                variables.shorcutsMouseGesturePointIntermediate = Qt.point(xPos, yPos)
                return true
            }
        } else if(angle > 135 && angle <= 225) {
            if(variables.shortcutsMouseGesture[variables.shortcutsMouseGesture.length-1] !== "W") {
                variables.shortcutsMouseGesture.push("W")
                variables.shorcutsMouseGesturePointIntermediate = Qt.point(xPos, yPos)
                return true
            }
        } else if(angle > 225 && angle <= 315) {
            if(variables.shortcutsMouseGesture[variables.shortcutsMouseGesture.length-1] !== "N") {
                variables.shortcutsMouseGesture.push("N")
                variables.shorcutsMouseGesturePointIntermediate = Qt.point(xPos, yPos)
                return true
            }
        }

    }

    return false

}

function analyseMouseEvent(startedEventAtPos, event, forceThisButton, dontResetGesture) {

    verboseMessage("Shortcuts/mouseshortcuts.js", "analyseMouseEvent(): " + startedEventAtPos + " / " +
                   event.button + " / " + forceThisButton + " / " + dontResetGesture)

    var combostring = getModifiers(event)

    var button = event.button
    if(forceThisButton !== undefined)
        button = forceThisButton

    if(button === Qt.LeftButton)
        combostring += "Left Button"
    else if(button === Qt.MiddleButton)
            combostring += "Middle Button"
    else if(button === Qt.RightButton)
            combostring += "Right Button"

    var movement = ""
    for(var i = 0; i < variables.shortcutsMouseGesture.length; ++i)
        movement += variables.shortcutsMouseGesture[i]
    if(dontResetGesture === undefined || !dontResetGesture)
    variables.shortcutsMouseGesture = []

    if(movement != "") {
        if(button === Qt.LeftButton && settings.leftButtonMouseClickAndMove && settingsmanager.status!==Loader.Null &&
                !settingsmanager.item.settingsDetectShortcuts.visible)
            return ""
        combostring += "+" + movement
    }

    return combostring

}

function analyseWheelEvent(event, dontResetVariables) {

    verboseMessage("Shortcuts/mouseshortcuts.js", "analyseWheelEvent(): " + event.angleDelta.x + " / " + event.angleDelta.y + " / " + event.inverted)

    var combostring = getModifiers(event)

    var angleX = event.angleDelta.x
    var angleY = event.angleDelta.y

    if(event.inverted) {
        var tmp = angleX
        angleX = angleY
        angleY = tmp
    }

    variables.wheelLeftRight += angleX
    variables.wheelUpDown += angleY

    var threshold = Math.max(30, Math.max(0, Math.min(10, settings.mouseWheelSensitivity*120)))

    // wheel LEFT
    if(variables.wheelLeftRight <= -threshold) {

        // wheel UP
        if(variables.wheelUpDown <= -threshold)
            combostring += "Wheel Up Left"
        // wheel DOWN
        else if(variables.wheelUpDown >= threshold)
            combostring += "Wheel Down Left"
        // neither up nor down
        else
            combostring += "Wheel Left"

    } else if(variables.wheelLeftRight >= threshold) {

        // wheel UP
        if(variables.wheelUpDown <= -threshold)
            combostring += "Wheel Up Right"
        // wheel DOWN
        else if(variables.wheelUpDown >= threshold)
            combostring += "Wheel Down Right"
        // neither up nor down
        else
            combostring += "Wheel Right"

    } else {

        // wheel UP
        if(variables.wheelUpDown <= -threshold)
            combostring += "Wheel Up"
        // wheel DOWN
        else if(variables.wheelUpDown >= threshold)
            combostring += "Wheel Down"

    }

    if(dontResetVariables === undefined || !dontResetVariables) {
        variables.wheelUpDown = 0
        variables.wheelLeftRight = 0
    }

    verboseMessage("Shortcuts/mouseshortcuts.js", "analyseWheelEvent(): combostring = " + combostring)

    return combostring

}

function getModifiers(event) {

    var modstring = ""

    if(event.modifiers & Qt.ControlModifier)
        modstring += "Ctrl+"
    if(event.modifiers & Qt.AltModifier)
        modstring += "Alt+"
    if(event.modifiers & Qt.ShiftModifier)
        modstring += "Shift+"
    if(event.modifiers & Qt.MetaModifier)
        modstring += "Meta+"
    if(event.modifiers & Qt.KeypadModifier)
        modstring += "Keypad+"

    return modstring

}
