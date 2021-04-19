/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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

CheckBox {

    id: control

    text: ""

    property alias interactive: mousearea.enabled
    property string tooltip: text
    property alias tooltipFollowsMouse: mousearea.tooltipFollowsMouse
    property alias tooltipDelay: mousearea.tooltipDelay

    property bool disableClickToCheck: false
    signal clicked(var mouse)
    signal rightClicked(var mouse)

    indicator: Rectangle {

        implicitWidth: 20
        implicitHeight: 20
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: 3
        color: control.checked ? (control.enabled ? "#ffffff" : "#dddddd" ) : "#aaaaaa"
        Behavior on color { ColorAnimation { duration: 50 } }
        border.color: "#333333"

        // indicator checkmark
        Canvas {
            id: canvas
            anchors {
                fill: parent
                topMargin: 3
                rightMargin: 4
                bottomMargin: 3
                leftMargin: 4
            }
            contextType: "2d"
            opacity: control.checked ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 50 } }

            Connections {
                target: control
                onEnabledChanged:
                    canvas.requestPaint();
            }

            onPaint: {
                var w = 3;
                context.reset()
                context.moveTo(0, height/2);
                context.lineTo(width/2, height-w)
                context.lineTo(width, 0)
                context.lineWidth = w
                context.lineJoint = "round"
                context.strokeStyle = control.enabled ? "#333333" : "#aaaaaa";
                context.stroke()

            }
        }

    }

    contentItem: Text {
        text: " " + control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        color: control.checked ? "#ffffff" : "#aaaaaa"
        Behavior on color { ColorAnimation { duration: 50 } }
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
    }

    PQMouseArea {
        id: mousearea
        anchors.fill: control
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        tooltip: control.tooltip
        tooltipWrapMode: Text.WrapAtWordBoundaryOrAnywhere
        acceptedButtons: Qt.RightButton

        onClicked:
            control.rightClicked(mouse)

    }

}
