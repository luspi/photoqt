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

RadioButton {

    id: control
    text: "RadioButton"

    indicator: Rectangle {
        implicitWidth: 20
        implicitHeight: 20
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: 13
        color: control.checked ? "#ffffff" : "#aaaaaa"
        Behavior on color { ColorAnimation { duration: 50 } }
        border.color: "#333333"

        Rectangle {
            width: 10
            height: 10
            x: 5
            y: 5
            radius: 5
            color: "#333333"
            opacity: control.checked ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 50 } }
        }
    }

    contentItem: Text {
        text: control.text
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
        onClicked:
            control.checked = !control.checked
    }

}
