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

Button {

    id: but_top

    SystemPalette { id: pqtPalette }
    SystemPalette { id: pqtPaletteDisabled; colorGroup: SystemPalette.Disabled }

    property string tooltip: ""

    signal rightClicked()

    //: This is a generic string written on clickable buttons - please keep short!
    property string genericStringOk: qsTranslate("buttongeneric", "Ok")
    //: This is a generic string written on clickable buttons - please keep short!
    property string genericStringCancel: qsTranslate("buttongeneric", "Cancel")
    //: This is a generic string written on clickable buttons - please keep short!
    property string genericStringSave: qsTranslate("buttongeneric", "Save")
    //: This is a generic string written on clickable buttons - please keep short!
    property string genericStringClose: qsTranslate("buttongeneric", "Close")

    contentItem: Text {
        text: but_top.text
        font: but_top.font
        color: enabled ? pqtPalette.text : pqtPaletteDisabled.text
        horizontalAlignment: but_top.horizontalAlignment
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 100
        implicitHeight: 40
        opacity: enabled ? 1 : 0.3
        color: but_top.down||but_top.forceHovered ? pqtPalette.highlight : pqtPalette.button
        border.color: PQCLook.baseBorder
        border.width: 1
        radius: 2
    }

    property int horizontalAlignment: Text.AlignHCenter
    property bool forceHovered: false
    property bool enableContextMenu: true

    property int forceWidth: 0
    property bool extraWide: false
    property bool extraextraWide: false
    property bool extraSmall: false
    leftPadding: extraSmall ? 10 : (extraextraWide ? 300 : (extraWide ? 100 : 40))
    rightPadding: leftPadding

    property bool smallerVersion: false

    font.pointSize: smallerVersion ? PQCLook.fontSize : PQCLook.fontSizeL
    font.weight: smallerVersion ? PQCLook.fontWeightNormal : PQCLook.fontWeightBold

    onHoveredChanged: {
        if(hovered && tooltip !== "")
            PQCNotify.showToolTip(tooltip, mapToGlobal(0, -15))
        else
            PQCNotify.hideToolTip(tooltip)
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: {
            if(enableContextMenu)
                menu.popup()
            else
                but_top.rightClicked()
        }
    }

    PQToolTip {
        id: ttip
        delay: 500
        timeout: 5000
        visible: but_top.hovered && text !== ""
        text: but_top.tooltip
    }

    PQMenu {
        id: menu
        PQMenuItem {
            enabled: false
            font.italic: true
            text: but_top.text
        }
        PQMenuItem {
            text: qsTranslate("buttongeneric", "Activate button")
            onTriggered: {
                but_top.clicked()
            }
        }
    }

}
