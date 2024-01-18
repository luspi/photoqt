/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

import PQCNotify

Item {

    width: image.width+10
    height: image.height+4

    property string img: ""
    property string cmd: ""
    property real scaleFactor: 1.5
    property bool active: true

    property bool hovered: false

    Rectangle {
        anchors.fill: parent
        color: PQCLook.baseColorHighlight
        radius: 5
        opacity: hovered ? 0.4 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    Image {

        id: image

        x: 5
        y: 2

        opacity: parent.active ? 1 : 0.4

        sourceSize: Qt.size(normalEntryHeight*scaleFactor, normalEntryHeight*scaleFactor)
        source: "image://svg/:/white/" + img

    }
    MouseArea {
        enabled: parent.active
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onEntered: hovered = true
        onExited: hovered = false
        onClicked: PQCNotify.executeInternalCommand(cmd)
    }

}
