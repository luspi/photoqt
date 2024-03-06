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
import QtQuick.Controls.Basic

Rectangle {

    id: control

    implicitWidth: forceWidth>0 ? forceWidth : (txt.width + padding)
    implicitHeight: 40
    opacity: enabled ? 1 : 0.6
    Behavior on opacity { NumberAnimation { duration: 200 } }
    radius: 5

    border.color: PQCLook.baseColorHighlight
    border.width: 1

    color: (down ? PQCLook.baseColorActive : ((hovered||forceHovered)&&enabled ? PQCLook.baseColorHighlight : PQCLook.baseColor))
    Behavior on color { ColorAnimation { duration: 150 } }

    property alias text: txt.text
    property alias font: txt.font
    property alias tooltip: mouseArea.text
    property alias cursorShape: mouseArea.cursorShape
    property alias horizontalAlignment: txt.horizontalAlignment

    property bool forceHovered: false

    property int forceWidth: 0
    property bool extraWide: false
    property bool extraextraWide: false
    property int padding: extraextraWide ? 300 : (extraWide ? 100 : 40)

    //: This is a generic string written on clickable buttons - please keep short!
    property string genericStringOk: qsTranslate("buttongeneric", "Ok")
    //: This is a generic string written on clickable buttons - please keep short!
    property string genericStringCancel: qsTranslate("buttongeneric", "Cancel")
    //: This is a generic string written on clickable buttons - please keep short!
    property string genericStringSave: qsTranslate("buttongeneric", "Save")
    //: This is a generic string written on clickable buttons - please keep short!
    property string genericStringClose: qsTranslate("buttongeneric", "Close")

    property bool down: false
    property bool hovered: false

    signal clicked()

    PQText {
        id: txt
        x: (parent.width-width)/2
        y: (parent.height-height)/2
        width: control.forceWidth ? control.forceWidth-20 : childrenRect.width
        elide: control.forceWidth ? Text.ElideRight : Text.ElideNone
        text: ""
        font.pointSize: PQCLook.fontSizeL
        font.weight: PQCLook.fontWeightBold
        opacity: enabled ? 1.0 : 0.6
        Behavior on opacity { NumberAnimation { duration: 200 } }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: parent.down ? PQCLook.textColorActive : PQCLook.textColor
    }

    PQMouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        text: control.text
        onPressed: {
            parent.down = true
        }
        onReleased: {
            parent.down = false
        }
        onEntered: {
            parent.hovered = true
        }
        onExited: {
            parent.hovered = false
            parent.down = false
        }
        onClicked: {
            control.clicked()
        }
    }

}
