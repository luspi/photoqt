/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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
import "../../other/PQCommonFunctions.js" as PQF

MenuItem {
    id: control
    implicitWidth: 250
    implicitHeight: h

    property int h: visible ? 30 : 0

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
            y: (parent.height-height)/2
            leftPadding: control.checkable||control.iconSource!=""||control.moveToRightABit ? 30 : 5
            height: control.h

            property string plainTxt: control.text.replace("&","")
            property string modTxt: PQF.parseMenuString(control.text)
            text: PQCConstants.altKeyPressed ? modTxt : plainTxt

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

            anchors.centerIn: parent
            implicitWidth: control.h/2
            implicitHeight: control.h/2

            color: palette.base
            border.width: 1
            border.color: control.checked ? palette.highlight : palette.disabled.text
            radius: control.checkableLikeRadioButton ? width/2 : 4

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                visible: control.checked
                color: palette.highlight
                opacity: 0.3
            }

            Rectangle {

                visible: control.checkableLikeRadioButton && control.checked
                anchors.fill: parent
                anchors.margins: 4
                radius: width/2
                color: palette.text

            }

            // Checkmark
            Canvas {
                anchors.fill: parent
                visible: control.checked && !control.checkableLikeRadioButton
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.strokeStyle = palette.text
                    ctx.lineWidth = 2
                    ctx.beginPath()
                    ctx.moveTo(width * 0.2, height * 0.55)
                    ctx.lineTo(width * 0.45, height * 0.75)
                    ctx.lineTo(width * 0.8, height * 0.25)
                    ctx.stroke()
                }
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
