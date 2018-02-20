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

import QtQuick 2.5
import QtQuick.Controls 1.4

import "../../../elements"

Rectangle {

    id: rect

    property string text: ""
    property string author: ""
    property string code: ""

    property bool checked: false
    property bool hovered: false

    property var exclusiveGroup: ExclusiveGroup

    // Size
    width: 200
    height: 30

    // Look
    color: checked ? colour.tiles_active : (hovered ? colour.tiles_inactive : colour.tiles_disabled)
    radius: variables.global_item_radius

    // And the checkbox indicator
    CustomRadioButton {

        id: check

        exclusiveGroup: parent.exclusiveGroup

        objectName: parent.objectName

        checked: parent.checked

        y: (parent.height-height)/2
        x: y
        width: parent.width-2*x

        indicatorColourEnabled: colour.tiles_indicator_col
        indicatorBackgroundColourEnabled: colour.tiles_indicator_bg

        text: rect.text
        textColour: (hovered || checked) ? colour.tiles_text_active : colour.tiles_text_inactive

        onCheckedChanged: parent.checked = checked

    }

    // The mousearea of the Tooltip governs the hover/checked look
    ToolTip {
        text: rect.text
        cursorShape: Qt.PointingHandCursor
        onEntered: hovered = true
        onExited: hovered = false
        onClicked: checked = !checked
    }

}
