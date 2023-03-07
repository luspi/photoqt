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

function analyseMouseGestureUpdate(current, before) {

    var threshold = 50

    var dx = current.x-before.x
    var dy = current.y-before.y
    var distance = Math.sqrt(Math.pow(dx,2)+Math.pow(dy,2));

    var angle = (Math.atan2(dy, dx)/Math.PI)*180
    angle = (angle+360)%360;

    if(distance > threshold) {
        if(angle <= 45 || angle > 315)
            return "E"
        else if(angle > 45 && angle <= 135)
            return "S"
        else if(angle > 135 && angle <= 225)
            return "W"
        else if(angle > 225 && angle <= 315)
            return "N"
    }

    return ""

}

function analyseMouseModifiers(modifiers) {

    var ret = []

    if(modifiers & Qt.ControlModifier)
        ret.push("Ctrl");
    if(modifiers & Qt.AltModifier)
        ret.push("Alt");
    if(modifiers & Qt.ShiftModifier)
        ret.push("Shift");
    if(modifiers & Qt.MetaModifier)
        ret.push("Meta");
    if(modifiers & Qt.KeypadModifier)
        ret.push("Keypad");

    return ret

}

function analyseMouseWheelAction(currentCombo, angleDelta, modifiers, ignoreModifiers) {

    var combo = ""

    if(ignoreModifiers == undefined || ignoreModifiers == false) {
        if(modifiers & Qt.ControlModifier)
            combo += "Ctrl+";
        if(modifiers & Qt.AltModifier)
            combo += "Alt+";
        if(modifiers & Qt.ShiftModifier)
            combo += "Shift+";
        if(modifiers & Qt.MetaModifier)
            combo += "Meta+";
        if(modifiers & Qt.KeypadModifier)
            combo += "Keypad+";
    }

    if(angleDelta.y < 0)
        combo += "Wheel Up"
    else if(angleDelta.y > 0)
        combo += "Wheel Down"
    else
        // at the end of a wheel move there usually is a wheel event with angleDelta being zero
        // we want to ignore that
        return currentCombo

    return combo

}
