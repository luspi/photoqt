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

    property string displaytext: ""
    property string description: ""
    property string category: ""

    property bool checked: false
    property bool hovered: false

    width: 100
    height: 30

    color: checked ? (hovered ? colour.tiles_active_hovered : colour.tiles_active) : (hovered ? colour.tiles_inactive : colour.tiles_disabled)
    Behavior on color { ColorAnimation { duration: variables.animationSpeed/2 } }
    radius: variables.global_item_radius

    CustomCheckBox {
        y: (parent.height-height)/2
        x: y
        fixedwidth: parent.width-2*x
        elide: Text.ElideRight
        text: displaytext
        textColour: (hovered || checked) ? colour.tiles_text_active : colour.tiles_text_inactive
        indicatorColourEnabled: colour.tiles_indicator_col
        indicatorBackgroundColourEnabled: colour.tiles_indicator_bg
        fsize: 9
        checkedButton: parent.checked
    }

    ToolTip {
        text: "<b>"+description+"</b>" + "<br><br>" + em.pty+qsTr("Left click to check/uncheck. Right click to check/uncheck all endings for this image type.")
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        onEntered:
            hovered = true
        onExited:
            hovered = false
        onClicked: {
            if(mouse.button == Qt.LeftButton)
                checked = !checked
            else
                popuptop.changeAllWithDescription(rect.category, !checked)
        }
    }

    Connections {

        target: formatsPopupEndings

        // Toggle all in this category
        onChangeAllWithDescription: {
            if(category == desc)
                checked = chkd
        }

    }

    Connections {

        target: formatsPopupMimetypes

        // Toggle all in this category
        onChangeAllWithDescription: {
            if(category == desc)
                checked = chkd
        }

    }

}
