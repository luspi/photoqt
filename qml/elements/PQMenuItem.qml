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
import QtQuick.Controls

MenuItem {
    id: menuItem
    implicitWidth: 250
    implicitHeight: 40

    property string iconSource: ""
    property bool checkableLikeRadioButton: false
    property bool moveToRightABit: false

    // NOTE
    // When entry is checkable then by default clicking on an entry WILL NOT call the triggered() signal
    // Instead the checkedChanged() signal will be emitted and the menu will remain open
    // If the property below is set to false then both signals will be emitted and the menu will close.

    property bool keepOpenWhenCheckedChanges: true

    contentItem:
        Text {
            id: controltxt
            leftPadding: menuItem.checkable||iconSource!=""||moveToRightABit ? 30 : 0
            height: 40
            text: menuItem.text
            font: menuItem.font
            color: menuItem.enabled ? PQCLook.textColor : PQCLook.textColorDisabled
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideMiddle
            style: menuItem.highlighted||!menuItem.enabled ? Text.Sunken : Text.Normal
            styleColor: PQCLook.textColorDisabled
        }

    indicator: Item {
        implicitWidth: 30
        implicitHeight: 40
        visible: menuItem.checkable||iconSource!=""
        Image {
            visible: iconSource!=""
            x: 5
            y: 10
            width: 20
            height: 20
            fillMode: Image.Pad
            source: iconSource
            sourceSize: Qt.size(width, height)
        }
        Rectangle {
            visible: iconSource==""
            width: 20
            height: 20
            anchors.centerIn: parent
            border.color: enabled ? PQCLook.inverseColor : PQCLook.baseColorActive
            color: PQCLook.baseColorHighlight
            radius: checkableLikeRadioButton ? 10 : 2
            Rectangle {
                width: 10
                height: 10
                anchors.centerIn: parent
                visible: menuItem.checked
                color: enabled ? PQCLook.inverseColor : PQCLook.baseColorActive
                radius: checkableLikeRadioButton ? 5 : 2
            }
        }
    }

    arrow: Canvas {
        x: parent.width - width
        implicitWidth: 40
        implicitHeight: 40
        visible: menuItem.subMenu
        onPaint: {
            var ctx = getContext("2d")
            ctx.fillStyle = PQCLook.baseColorActive
            ctx.moveTo(15, 15)
            ctx.lineTo(width - 15, height / 2)
            ctx.lineTo(15, height - 15)
            ctx.closePath()
            ctx.fill()
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
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: false
        acceptedButtons: Qt.LeftButton

        onClicked: function(mouse) {
            if(menuItem.checkable) {
                menuItem.checked = (checkableLikeRadioButton || !menuItem.checked)
                if(keepOpenWhenCheckedChanges)
                    return
            }
            menuItem.triggered()
        }
    }
 }
