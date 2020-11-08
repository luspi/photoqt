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
import QtQuick.Controls 2.2

TextField {

    id: control

    placeholderText: "Enter"
    color: "white"
    selectedTextColor: "black"
    selectionColor: "white"

    focus: true

    enabled: opacity>0 && visible

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 40
        color: control.enabled ? "transparent" : "#cccccc"
        border.color: control.enabled ? "#cccccc" : "transparent"
    }

    function setFocus() {
        forceActiveFocus()
        selectAll()
    }

}
