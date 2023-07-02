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

MenuItem {
    id: menuItem
    implicitWidth: 200
    implicitHeight: 40

    contentItem: Text {
        leftPadding: menuItem.checkable ? menuItem.indicator.width : 0
        text: menuItem.text
        font: menuItem.font
        color: menuItem.enabled ? PQCLook.textColor : PQCLook.textColorHighlight
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideMiddle
        style: menuItem.highlighted||!menuItem.enabled ? Text.Sunken : Text.Normal
        styleColor: PQCLook.textColorHighlight
    }

    indicator: Item {
        implicitWidth: 30
        implicitHeight: 40
        Rectangle {
            width: 20
            height: 20
            anchors.centerIn: parent
            visible: menuItem.checkable
            border.color: PQCLook.inverseColor
            color: PQCLook.baseColorHighlight
            radius: 2
            Rectangle {
                width: 10
                height: 10
                anchors.centerIn: parent
                visible: menuItem.checked
                color: PQCLook.inverseColor
                radius: 2
            }
        }
    }

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 40
        color: menuItem.highlighted ? PQCLook.baseColorHighlight : PQCLook.baseColor
        border.color: PQCLook.baseColorAccent
        border.width: 1
        Behavior on color { ColorAnimation { duration: 200 } }
    }
 }
