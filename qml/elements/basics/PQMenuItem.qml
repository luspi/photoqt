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

MenuItem {
    id: control
    implicitWidth: 250
    implicitHeight: h

    property int h: 30

    onImplicitWidthChanged: {
        if(menu !== null && implicitWidth > menu.width+10) {
            menu.implicitWidth = implicitWidth
        }
    }

    property string iconSource: ""
    property bool checkableLikeRadioButton: false
    property bool moveToRightABit: false

    font.weight: PQCLook.fontWeightNormal

    property int elide: Text.ElideMiddle

    // NOTE
    // When entry is checkable then by default clicking on an entry WILL NOT call the triggered() signal
    // Instead the checkedChanged() signal will be emitted and the menu will remain open
    // If the property below is set to false then both signals will be emitted and the menu will close.

    property bool keepOpenWhenCheckedChanges: true

    contentItem:
        Text {
            id: controltxt
            leftPadding: control.checkable||control.iconSource!=""||control.moveToRightABit ? 30 : 5
            height: control.h
            text: control.text
            font: control.font
            color: palette.text
            opacity: control.enabled ? 1 : 0.6
            Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: control.elide
            Timer {
                id: increaseWidth
                running: controltxt.truncated&&control.implicitWidth<400
                interval: 400
                repeat: true
                onTriggered: {
                    if(!controltxt.truncated)
                        stop()
                    control.implicitWidth += 50
                }
            }
        }

    indicator: Item {
        implicitWidth: 30
        implicitHeight: control.h
        visible: control.checkable||control.iconSource!=""
        Image {
            visible: control.iconSource!=""
            x: 5
            y: control.h/4
            width: control.h/2
            height: control.h/2
            opacity: control.enabled ? 1 : 0.6
            Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
            fillMode: Image.Pad
            source: control.iconSource
            sourceSize: Qt.size(width, height)
        }
        Rectangle {
            visible: control.iconSource==""
            width: control.h/2
            height: control.h/2
            anchors.centerIn: parent
            border.color: PQCLook.baseBorder
            color: palette.alternateBase
            radius: control.checkableLikeRadioButton ? 10 : 2
            Rectangle {
                width: control.h/4
                height: control.h/4
                anchors.centerIn: parent
                visible: control.checked
                color: control.enabled ? palette.text : PQCLook.baseBorder
                radius: control.checkableLikeRadioButton ? 5 : 2
            }
        }
    }

    arrow: Canvas {
        x: parent.width - width
        implicitWidth: control.h
        implicitHeight: control.h
        visible: control.subMenu
        onPaint: {
            var ctx = getContext("2d")
            ctx.fillStyle = PQCLook.baseBorder
            ctx.moveTo(control.h/3, control.h/3)
            ctx.lineTo(width - control.h/3, height / 2)
            ctx.lineTo(control.h/3, height - control.h/3)
            ctx.closePath()
            ctx.fill()
        }
    }

    background: PQHighlightMarker {
        visible: control.highlighted
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: false
        acceptedButtons: Qt.LeftButton

        onClicked: function(mouse) {
            if(control.checkable) {
                control.checked = (control.checkableLikeRadioButton || !control.checked)
                if(control.keepOpenWhenCheckedChanges)
                    return
            }
            control.triggered()
        }
    }
 }
