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
import PhotoQt.Integrated

Button {

    id: control

    implicitHeight: 40
    implicitWidth: 40

    opacity: enabled ? 1 : 0.5

    property string source: ""
    property alias tooltip: ttip.text

    flat: true

    signal rightClicked()

    Image {
        anchors.fill: parent
        anchors.margins: 5
        sourceSize: Qt.size(width, height)
        source: control.source
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: (mouse) => {
            control.rightClicked()
            mouse.accepted = true
        }
    }

    PQToolTip {

        id: ttip

        x: (parent != null ? (parent.width-width)/2 : 0)
        y: -height-5

    }

}
