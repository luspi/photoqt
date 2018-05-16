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

// This checkbox is a 'normal' checkbox with text either on the left or on the right (default)
Item {

    id: rect

    // Some properties that can be adjusted from parent
    property bool checkedButton: false
    property string text: ""
    property string tooltip: text
    property int fsize: 10
    property string textColour: (enabled ? colour.text : colour.text_disabled)
    Behavior on textColour { ColorAnimation { duration: variables.animationSpeed/2 } }
    property int elide: Text.ElideNone

    property int fixedwidth: -1

    property string indicatorColourEnabled: colour.radio_check_indicator_color
    property string indicatorBackgroundColourEnabled: colour.radio_check_indicator_bg_color

    // Per default the text in on the right
    property bool textOnRight: true

    property int wrapMode: Text.NoWrap

    // Set size
    width: fixedwidth==-1 ? childrenRect.width : fixedwidth
    height: Math.max(txt.height,check.height)

    // 'Copy' functionality of checkedChanged of Button Item
    signal buttonCheckedChanged()

    // If the text is displayed on the left, we have to use a seperate text label for that
    Text {

        id: txt

        visible: !textOnRight

        color: textColour

        text: !textOnRight ? rect.text : ""
        font.pointSize: fsize
        elide: rect.elide
        wrapMode: rect.wrapMode

    }

    // This is the checkbox, with or without text (depending on location of label)
    CheckBox {

        id: check

        anchors.left: txt.right
        anchors.leftMargin: textOnRight ? 0 : 5
        anchors.right: (fixedwidth==-1 ? undefined : rect.right)

        // Checked state is tied to this global property
        checked: rect.checkedButton

        // Styling
        style: CheckBoxStyle {
            indicator: Rectangle {
                implicitWidth: fsize*2
                implicitHeight: fsize*2
                radius: variables.global_item_radius/2
                color: control.enabled ? indicatorBackgroundColourEnabled : colour.radio_check_indicator_bg_color_disabled
                Rectangle {
                    visible: rect.checkedButton
                    color: control.enabled ? indicatorColourEnabled : colour.radio_check_indicator_color_disabled
                    Behavior on color { ColorAnimation { duration: variables.animationSpeed/2 } }
                    radius: variables.global_item_radius/2
                    anchors.margins: 4
                    anchors.fill: parent
                }
            }
            label: Text {
                color: textColour
                visible: textOnRight
                elide: rect.elide
                wrapMode: rect.wrapMode
                text: textOnRight ? rect.text : ""
                font.pointSize: fsize
            }

        }

        onCheckedChanged: buttonCheckedChanged()

    }

    // Change cursor and catch click on whole container
    ToolTip {
        text: parent.tooltip
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: checkedButton = !checkedButton
    }

}
