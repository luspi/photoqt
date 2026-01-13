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

SpinBox {

    id: control

    property int liveValue: value
    property string tooltip: liveValue + tooltipSuffix
    property string tooltipSuffix: ""

    PQToolTip {
        id: ttip
        delay: 500
        timeout: 5000
        visible: control.hovered
        text: control.tooltip
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
        liveValue = val
        _defaultValue = val
    }

    function setValue(val : int) {
        value = val
        liveValue = val
    }

    function hasChanged() : bool {
        return _defaultValue!==liveValue
    }

}
