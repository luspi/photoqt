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
import PhotoQt.Integrated

Button {

    id: control

    implicitHeight: 40

    font.pointSize: PQCLook.fontSize
    font.weight: PQCLook.fontWeightBold

    opacity: enabled ? 1 : 0.5

    SystemPalette { id: pqtPalette }

    property bool enableContextMenu: true
    property alias contextmenu: menu

    property string tooltip: _text

    property string _text: ""

    //: This is a generic string written on clickable buttons - please keep short!
    property string genericStringOk: qsTranslate("buttongeneric", "Ok")
    //: This is a generic string written on clickable buttons - please keep short!
    property string genericStringCancel: qsTranslate("buttongeneric", "Cancel")
    //: This is a generic string written on clickable buttons - please keep short!
    property string genericStringSave: qsTranslate("buttongeneric", "Save")
    //: This is a generic string written on clickable buttons - please keep short!
    property string genericStringClose: qsTranslate("buttongeneric", "Close")

    Component.onCompleted: {
        if(_text === "" && text !== "")
            _text = text
        text = ""
    }

    contentItem: Text {
        text: "  " + control._text + "  "
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        color: pqtPalette.text
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    PQToolTip {
        id: ttip
        delay: 500
        timeout: 5000
        visible: control.hovered && text !== ""
        text: control.tooltip
    }

    PQMouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        text: control.text
        enabled: control.enableContextMenu
        acceptedButtons: Qt.RightButton
        onPressed: (mouse) => {
            if(control.enableContextMenu && mouse.button === Qt.RightButton)
                menu.popup()
            mouse.accepted = false
        }
    }

    PQMenu {
        id: menu
        PQMenuItem {
            enabled: false
            font.italic: true
            text: control._text
        }
        PQMenuItem {
            text: qsTranslate("buttongeneric", "Activate button")
            onTriggered: {
                control.clicked()
            }
        }
    }

}
