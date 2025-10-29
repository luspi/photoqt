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

ScrollView {

    id: control

    clip: true

    property alias text: textarea.text
    property alias placeholderText: textarea.placeholderText
    property alias controlFocus: textarea.focus
    property alias controlActiveFocus: textarea.activeFocus
    property alias cursorPosition: textarea.cursorPosition

    implicitWidth: 200
    implicitHeight: 200

    ScrollBar.vertical:
        PQVerticalScrollBar {
            id: scrollver
            x: control.width - width
            height: control.availableHeight
        }

    ScrollBar.horizontal:
        PQHorizontalScrollBar {
            id: scrollhor
            y: parent.height - height
            width: control.availableWidth
        }

    SystemPalette { id: pqtPalette }

    TextArea {

        id: textarea

        color: pqtPalette.text

        font.pointSize: PQCLook.fontSize
        font.weight: PQCLook.fontWeightNormal

        background: Rectangle {
            implicitWidth: control.implicitWidth - scrollver.width
            implicitHeight: control.implicitHeight - scrollhor.height
            color: pqtPalette.base
            border.color: PQCLook.baseBorder
        }
    }

}
