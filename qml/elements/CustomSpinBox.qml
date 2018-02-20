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
import QtQuick.Controls.Styles 1.4

SpinBox {

    id: ele_top

    signal ctrlTab()
    signal ctrlShiftTab()

    signal accepted()
    signal rejected()

    font.pixelSize: height/2
    menu: null
    enabled: visible

    style: SpinBoxStyle{
        background: Rectangle {
            implicitWidth: 50
            implicitHeight: 25
            color: control.enabled ? colour.element_bg_color : colour.element_bg_color_disabled
            Behavior on color { ColorAnimation { duration: variables.animationSpeed/2 } }
            border.color: control.enabled ? colour.element_border_color : colour.element_border_color_disabled
            Behavior on border.color { ColorAnimation { duration: variables.animationSpeed/2 } }
            radius: variables.global_item_radius
        }
        textColor: control.enabled ? colour.text : colour.text_disabled
        Behavior on textColor { ColorAnimation { duration: variables.animationSpeed/2 } }

        selectionColor: control.enabled ? colour.text_selection_color : colour.text_selection_color_disabled
        Behavior on selectionColor { ColorAnimation { duration: variables.animationSpeed/2 } }

        selectedTextColor: colour.text_selected
        decrementControl: Text {
            color: control.enabled ? colour.text : colour.text_disabled
            Behavior on color { ColorAnimation { duration: variables.animationSpeed/2 } }
            y: -height/3
            x: -2
            font.pixelSize: control.height*2/3
            text: "-"
        }
        incrementControl: Text {
            color: control.enabled ? colour.text : colour.text_disabled
            Behavior on color { ColorAnimation { duration: variables.animationSpeed/2 } }
            y: -height/3
            x: width/25
            font.pixelSize: control.height*2/3
            text: "+"
        }

    }

    ToolTip {
        hoverEnabled: true
        text: parent.value + "" + parent.suffix
        cursorShape: Qt.IBeamCursor
        propagateComposedEvents: true
        onPressed: mouse.accepted = false
        onReleased: mouse.accepted = false
    }

}
