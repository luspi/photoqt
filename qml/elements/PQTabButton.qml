/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

import QtQuick 2.9
import QtQuick.Controls 2.2

TabButton {
    id: control

    text: ""

    implicitHeight: 60
    implicitWidth: 250

    font.pointSize: 12

    property string backgroundColor: "#333333"
    property string backgroundColorHover: "#3a3a3a"
    property string backgroundColorActive: "#444444"
    property string backgroundColorSelected: "#555555"
    property string textColor: "#ffffff"
    property string textColorHover: "#ffffff"
    property string textColorActive: "#ffffff"

    property bool mouseOver: false
    property bool selected: false

    property alias tooltip: mousearea.tooltip
    property alias tooltipFollowsMouse: mousearea.tooltipFollowsMouse

    contentItem: Item {
        implicitWidth: control.implicitWidth-20
        implicitHeight: control.height
        Text {
            id: txt
            text: control.text
            font: control.font
            y: (parent.height-height)/2
            x: 10
            width: control.implicitWidth-20
            wrapMode: Text.WordWrap
            opacity: enabled ? 1.0 : 0.3
            color: control.down ? control.textColorActive : (control.mouseOver ? control.textColorHover : control.textColor)
            Behavior on color { ColorAnimation { duration: 100 } }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            Component.onCompleted: {
                font.bold = true
            }
        }
    }

    background: Rectangle {
        implicitWidth: contentItem.width
        color: selected ? backgroundColorSelected : (control.down ? control.backgroundColorActive : (control.mouseOver ? control.backgroundColorHover : control.backgroundColor))
        Behavior on color { ColorAnimation { duration: 100 } }
        implicitHeight: contentItem.height
        opacity: enabled ? 1 : 0.3

        Rectangle {
            x: 0
            y: 0
            width: parent.width
            height: 1
            color: backgroundColorSelected
        }

        Rectangle {
            x: 0
            y: parent.height-height
            width: parent.width
            height: 1
            color: backgroundColorSelected
        }

        Rectangle {
            x: parent.width-1
            y: 0
            width: 1
            height: parent.height
            color: backgroundColorSelected
        }

    }

    PQMouseArea {
        id: mousearea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        tooltip: control.text
        onEntered:
            control.mouseOver = true
        onExited:
            control.mouseOver = false
        onPressed:
            control.down = true
        onReleased:
            control.down = false
        onClicked:
            control.clicked()
    }

}
