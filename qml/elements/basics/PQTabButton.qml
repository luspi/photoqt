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
import PhotoQt

TabButton {

    id: control

    implicitHeight: 40

    property bool isCurrentTab: false
    property bool lineBelow: false
    property bool lineAbove: false

    property bool settingsManagerMainTab: false
    font.weight: settingsManagerMainTab ? PQCLook.fontWeightBold : PQCLook.fontWeightNormal

    font.pointSize: settingsManagerMainTab ? PQCLook.fontSize : PQCLook.fontSize-2

    contentItem: Text {
        leftPadding: 20
        text: control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        color: palette.text
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    }

    background: Rectangle {
        opacity: enabled ? 1 : 0.3
        color: palette.base

        Rectangle {
            y: 0
            width: parent.width
            height: 1
            color: palette.text
            visible: control.lineAbove
            opacity: 0.2
        }

        PQHighlightMarker {
            opacity: !control.isCurrentTab ? 0.5 : 1
            visible: control.isCurrentTab||control.hovered
        }

        Rectangle {
            y: (parent.height-height)
            width: parent.width
            height: 1
            color: palette.text
            visible: control.lineBelow
            opacity: 0.2
        }
    }
}
