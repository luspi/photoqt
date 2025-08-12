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
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import PhotoQt.CPlusPlus
import PhotoQt.Integrated

ComboBox {

    id: control

    SystemPalette { id: pqtPalette }

    // not used but needed for compatibility
    property string prefix
    property int elide: Text.ElideRight
    property bool transparentBackground: false
    property var lineBelowItem: []

    font.pointSize: PQCLook.fontSize
    font.weight: PQCLook.fontWeightNormal

    // TODO !!!
    property list<int> hideEntries: []

    implicitWidth: extrawide ? 300 : (extrasmall ? 100 : 200)

    property bool extrawide: false
    property bool extrasmall: false

    property int _defaultValue
    Component.onCompleted: {
        _defaultValue = currentIndex
    }

    function saveDefault() {
        _defaultValue = currentIndex
    }

    function setDefault(val : int) {
        _defaultValue = val
    }

    function loadAndSetDefault(val : int) {
        currentIndex = val
        _defaultValue = val
    }

    function hasChanged() : bool {
        return _defaultValue!==currentIndex
    }

}
