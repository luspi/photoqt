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

import QtQuick
import QtQuick.Controls

Rectangle {

    id: edit_top

    width: 300
    height: 40
    color: PQCLook.baseColorAccent
    border.width: 1
    border.color: PQCLook.baseColorHighlight
    z: -1

    property alias text: control.text

    TextInput {

        id: control

        width: edit_top.width
        height: edit_top.height

        clip: true

        leftPadding: 5
        rightPadding: 5

        color: PQCLook.textColor
        selectedTextColor: PQCLook.textColorHighlight
        selectionColor: PQCLook.baseColorHighlight

        font.pointSize: PQCLook.fontSize
        font.weight: PQCLook.fontWeightNormal

        verticalAlignment: TextInput.AlignVCenter

        focus: true

        enabled: opacity>0 && visible

    }

    function setFocus() {
        control.forceActiveFocus()
        control.selectAll()
    }

}
