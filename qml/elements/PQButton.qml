/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

Button {

    id: control

    implicitHeight: 40
    implicitWidth: 200

    font.pointSize: PQCLook.fontSizeL
    font.weight: PQCLook.fontWeightBold

    opacity: enabled ? 1 : 0.3

    property alias tooltip: mouseArea.text

    //: This is a generic string written on clickable buttons - please keep short!
    property string genericStringOk: qsTranslate("buttongeneric", "Ok")
    //: This is a generic string written on clickable buttons - please keep short!
    property string genericStringCancel: qsTranslate("buttongeneric", "Cancel")
    //: This is a generic string written on clickable buttons - please keep short!
    property string genericStringSave: qsTranslate("buttongeneric", "Save")
    //: This is a generic string written on clickable buttons - please keep short!
    property string genericStringClose: qsTranslate("buttongeneric", "Close")

    contentItem: Text {
        text: control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        color: PQCLook.textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 100
        implicitHeight: 40
        opacity: enabled ? 1 : 0.3
        radius: 5

        border.color: PQCLook.baseColorHighlight
        border.width: 1

        color: (down ? PQCLook.baseColorActive : (hovered ? PQCLook.baseColorHighlight : PQCLook.baseColor))
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    PQMouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        text: control.text
        onPressed: (mouse) =>  mouse.accepted = false
    }

}
