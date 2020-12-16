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

ComboBox {
    id: control

    property alias tooltip: combomousearea.tooltip
    property alias tooltipFollowsMouse: combomousearea.tooltipFollowsMouse
    property bool firstItemEmphasized: false
    property int lineBelowItem: -1

    property var hideItems: []

    property string prefix: ""

    implicitWidth: 200
    padding: 5

    delegate: ItemDelegate {
        id: controldelegate
        width: control.width
        contentItem: Text {
            text: modelData
            color: controldelegmouse.containsMouse ? "#ffffff" : "#000000"
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            Component.onCompleted: {
                if(index == 0 && firstItemEmphasized)
                    font.bold = true
            }

            PQMouseArea {
                id: controldelegmouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                tooltip: parent.text
                propagateComposedEvents: true
                onClicked: mouse.accepted = false;
                onPressed: mouse.accepted = false;
                onReleased: mouse.accepted = false;
                onDoubleClicked: mouse.accepted = false;
                onPositionChanged: mouse.accepted = false;
                onPressAndHold: mouse.accepted = false;
            }

        }
        highlighted: control.highlightedIndex === index

        background: Rectangle {
            width: parent.width
            height: parent.height
            opacity: enabled ? 1 : 0.3
            color: controldelegmouse.containsMouse ? "#666666" : "#cccccc"
            Rectangle {
                width: parent.width
                height: 1
                x: 0
                y: parent.height-1
                color: "#cccccc"
                visible: (firstItemEmphasized&&index==0)||(lineBelowItem==index)
            }
        }

    }

    indicator: Canvas {
        id: canvas
        x: control.width - width - control.rightPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 12
        height: 8
        contextType: "2d"

        Connections {
            target: control
            onPressedChanged: canvas.requestPaint()
        }

        onPaint: {
            context.reset();
            context.moveTo(0, 0);
            context.lineTo(width, 0);
            context.lineTo(width / 2, height);
            context.closePath();
            context.fillStyle = control.pressed ? "#cccccc" : "#ffffff"
            context.fill();
        }
    }

    contentItem: Text {
        rightPadding: control.indicator.width + control.spacing

        text: control.prefix + control.displayText
        font: control.font
        color: control.pressed ? "#cccccc" : "#ffffff"
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 120
        implicitHeight: 40
        color: control.pressed ? "#cc000000" : "#cc444444"
        border.color: control.pressed ? "#cc222222" : "#cc666666"
        border.width: control.visualFocus ? 2 : 1
        radius: 2
    }

    PQMouseArea {
        id: combomousearea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        propagateComposedEvents: true
        onClicked: mouse.accepted = false
        onPressed: mouse.accepted = false
        onReleased: mouse.accepted = false
        onDoubleClicked: mouse.accepted = false
        onPositionChanged: mouse.accepted = false
        onPressAndHold: mouse.accepted = false
    }

}
