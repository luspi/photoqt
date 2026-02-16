/**************************************************************************
 **                                                                      **
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
import QtQuick.Controls
import PhotoQt

Slider {

    id: control

    property string suffix: ""
    property string tooltip: ""

    orientation: Qt.Horizontal
    live: true

    property bool _horizontal: (orientation==Qt.Horizontal)

    stepSize: 1.0

    opacity: enabled ? 1 : 0.6

    property bool extraSmall: false
    property bool extraWide: false

    implicitHeight: _horizontal ? 20 : (extraWide ? 300 : (extraSmall ? 150 : 200))
    implicitWidth: _horizontal ? (extraWide ? 300 : (extraSmall ? 150 : 200)) : 20

    property real wheelStepSize: 1.0
    property bool reverseWheelChange: false

    PQToolTip {
        id: ttip
        delay: 500
        timeout: 5000
        visible: control.hovered && text !== ""
        text: (control.tooltip==="" ? control.value : control.tooltip) + control.suffix
    }

    property int _defaultValue
    Component.onCompleted: {
        _defaultValue = value
    }

    function saveDefault() {
        _defaultValue = value
    }

    function setDefault(val : int) {
        _defaultValue = val
    }

    function loadAndSetDefault(val : int) {
        value = val
        _defaultValue = val
    }

    function hasChanged() : bool {
        return _defaultValue!==value
    }

}
