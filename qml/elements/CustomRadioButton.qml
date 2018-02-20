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

RadioButton {

    // there can be an icon displayed as part of the label
    property string icon: ""

    property string indicatorColourEnabled: colour.radio_check_indicator_color
    property string indicatorColourDisabled: colour.radio_check_indicator_color_disabled
    property string indicatorBackgroundColourEnabled: colour.radio_check_indicator_bg_color
    property string indicatorBackgroundColourDisabled: colour.radio_check_indicator_bg_color_disabled
    property int fontsize: 10
    property string textColour: colour.text
    property string tooltip: text

    style: RadioButtonStyle {
        indicator: Rectangle {
            implicitWidth: 1.6*fontsize
            implicitHeight: 1.6*fontsize
            radius: 0.9*fontsize
            color: control.enabled ? indicatorBackgroundColourEnabled : indicatorBackgroundColourDisabled
            Behavior on color { ColorAnimation { duration: variables.animationSpeed/2 } }
            Rectangle {
                anchors.fill: parent
                visible: control.checked
                color: control.enabled ? indicatorColourEnabled : indicatorColourDisabled
                Behavior on color { ColorAnimation { duration: variables.animationSpeed/2 } }
                radius: 0.9*fontsize
                anchors.margins: 0.4*fontsize
            }
        }
        label: Rectangle {
            color: "#00000000"
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
            Image {
                id: img
                x: 0
                y: 0
                width: (icon != "") ? 1.6*fontsize : 0
                height: (icon != "") ? 1.6*fontsize : 0
                source: icon
                visible: (icon != "")
            }
            Text {
                id: txt
                x: (icon != "") ? 1.8*fontsize : 0
                y: 0
                color: control.enabled ? textColour : colour.text_disabled
                Behavior on color { ColorAnimation { duration: variables.animationSpeed/2 } }
                height: 1.6*fontsize
                font.pointSize: fontsize
                text: control.text
            }
        }
    }

    ToolTip {
        text: parent.tooltip
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: parent.checked = true
    }

}
