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

    property string fileEnding: ""
    property string fileType: ""
    property string displayFileEnding: ""
    property string description: ""

    property bool checked: false
    property bool hovered: false

    property var exclusiveGroup: ExclusiveGroup

    // Size
    width: 100
    height: 30

    // Look
    color: checked ? colour.tiles_active : (hovered ? colour.tiles_inactive : colour.tiles_disabled)
    Behavior on color { ColorAnimation { duration: variables.animationSpeed/2 } }
    radius: variables.global_item_radius

    CustomCheckBox {
        y: (parent.height-height)/2
        x: y
        fixedwidth: parent.width-2*x
        elide: Text.ElideRight
        text: displayFileEnding // parent.fileType
        textColour: (hovered || checked) ? colour.tiles_text_active : colour.tiles_text_inactive
        indicatorColourEnabled: colour.tiles_indicator_col
        indicatorBackgroundColourEnabled: colour.tiles_indicator_bg
        fsize: 9
        checkedButton: parent.checked
    }

    ToolTip {
        text: description=="" ? "<b>" + rect.fileType + ":</b><br>" + rect.fileEnding
                              : "<b>" + rect.description + "</b><br>" + rect.fileEnding
        cursorShape: Qt.PointingHandCursor
        onEntered:
            hovered = true
        onExited:
            hovered = false
        onClicked:
            checked = !checked
    }

}
