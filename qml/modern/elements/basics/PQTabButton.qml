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
import PhotoQt.Modern

TabButton {

    id: control

    SystemPalette { id: pqtPalette }

    property bool isCurrentTab: false
    property bool lineBelow: false
    property bool lineAbove: false

    property bool settingsManagerMainTab: false
    implicitHeight: 50
    font.weight: settingsManagerMainTab ? PQCLook.fontWeightBold : PQCLook.fontWeightNormal

    contentItem: Text {
        leftPadding: 20
        text: control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        color: pqtPalette.text
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: control.implicitWidth
        implicitHeight: control.implicitHeight
        opacity: enabled ? ((control.down||control.isCurrentTab) ? 0.3 : 1) : 0.3
        color: (control.down||control.isCurrentTab) ? PQCLook.baseBorder : (control.hovered ? pqtPalette.alternateBase : pqtPalette.button)
        Rectangle {
            y: 0
            width: parent.width
            height: 1
            color: pqtPalette.text
            opacity: 0.1
            visible: control.lineAbove
        }
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            opacity: (control.down||control.isCurrentTab) ? 0.5 : 0
            border.color: PQCLook.highlight
            border.width: 1
        }
        Rectangle {
            y: (parent.height-height)
            width: parent.width
            height: 1
            color: pqtPalette.text
            opacity: 0.1
            visible: control.lineBelow
        }
    }

}
