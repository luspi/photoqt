/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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

import QtQuick
import QtQuick.Controls
import PhotoQt.CPlusPlus

TabButton {

    id: control

    implicitHeight: 40

    property bool isCurrentTab: false
    property bool lineBelow: false

    SystemPalette { id: pqtPalette }

    contentItem: Text {
        leftPadding: 20
        text: control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        color: control.isCurrentTab ? pqtPalette.base : pqtPalette.text
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        opacity: enabled ? 1 : 0.3
        color: pqtPalette.base
        Item {
            anchors.fill: parent
            anchors.margins: 5
            Rectangle {
                anchors.fill: parent
                color: pqtPalette.highlight
                opacity: control.isCurrentTab ? 1 : (control.hovered ? 0.3 : 0)
                radius: 5
            }
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.width: 1
                border.color: pqtPalette.highlight
                radius: 5
                visible: control.isCurrentTab||control.hovered
            }
        }

        Rectangle {
            y: (parent.height-height)
            width: parent.width
            height: 1
            color: pqtPalette.text
            visible: control.lineBelow
            opacity: 0.1
        }
    }
}
