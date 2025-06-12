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
import QtQuick.Controls.Basic
import org.photoqt.qml

Button {

    id: control

    implicitHeight: 40

    font.pointSize: PQCLook.fontSize    // qmllint disable unqualified
    font.weight: PQCLook.fontWeightBold // qmllint disable unqualified

    flat: true
    opacity: enabled ? 1 : 0.5

    property bool enableContextMenu: true
    property alias contextmenu: menu

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
        text: "  " + control.text + "  "
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        color: PQCLook.textColor // qmllint disable unqualified
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 100
        implicitHeight: 40
        opacity: enabled ? 1 : 0.3
        color: (control.down ? PQCLook.baseColorActive : (control.hovered ? PQCLook.baseColorHighlight : PQCLook.baseColorAccent)) // qmllint disable unqualified
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    Rectangle {
        x: 0
        width: 1
        height: parent.height
        color: PQCLook.baseColorActive // qmllint disable unqualified
    }

    Rectangle {
        x: parent.width-1
        width: 1
        height: parent.height
        color: PQCLook.baseColorActive // qmllint disable unqualified
    }

    PQMouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        text: control.text
        acceptedButtons: control.enableContextMenu ? (Qt.LeftButton|Qt.RightButton) : Qt.LeftButton
        onPressed: (mouse) => {
            if(control.enableContextMenu && mouse.button == Qt.RightButton)
                menu.popup()
            mouse.accepted = false
        }
    }

    PQMenu {
        id: menu
        PQMenuItem {
            enabled: false
            font.italic: true
            text: control.text
        }
        PQMenuItem {
            text: qsTranslate("buttongeneric", "Activate button")
            onTriggered: {
                control.clicked()
            }
        }
    }

}
