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

Item {

    id: conf_top

    anchors.fill: parent

    property string action: ""
    property var payload: []

    signal accepted()
    signal rejected()

    opacity: 0
    visible: opacity>0
    Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }

    Rectangle {
        anchors.fill: parent
        color: palette.base
        opacity: 0.8
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        onWheel: (wheel) => {
            wheel.accepted = true
        }
        onClicked: (mouse) => {
            mouse.accepted = true
        }
    }

    Rectangle {

        x: (parent.width-width)/2
        y: (parent.height-height)/2

        width: col.width+100
        height: col.height+100

        color: palette.base

        border.width: 2
        border.color: PQCLook.baseBorder

        radius: 5

        Column {

            id: col

            x: 50
            y: 50

            spacing: 20

            Label {
                id: header
                text: "Are you sure?"
                width: Math.min(conf_top.width-200, 600)
                horizontalAlignment: Text.AlignHCenter
                font.weight: PQCLook.fontWeightBold
                font.pointSize: PQCLook.fontSizeXXL
                color: palette.text
            }

            Label {
                id: description
                text: "Are you sure you want to do this???"
                width: Math.min(conf_top.width-200, 600)
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: PQCLook.fontSizeL
                color: palette.text
            }

            Row {

                x: (header.width-width)/2

                spacing: 10

                Rectangle {
                    id: acceptButton
                    height: 50
                    width: okTxt.width+50
                    color: okMouse.containsPress ? PQCLook.baseBorder : (okMouse.containsMouse ? palette.alternateBase : palette.button)
                    border.color: PQCLook.baseBorder
                    border.width: 1
                    Label {
                        id: okTxt
                        x: 25
                        y: (parent.height-height)/2
                        text: "Ok"
                    }
                    MouseArea {
                        id: okMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            conf_top.hide()
                            conf_top.accepted()
                        }
                    }
                }

                Rectangle {
                    id: rejectButton
                    height: 50
                    width: cancelTxt.width+50
                    color: cancelMouse.containsPress ? PQCLook.baseBorder : (cancelMouse.containsMouse ? palette.alternateBase : palette.button)
                    border.color: PQCLook.baseBorder
                    border.width: 1
                    Label {
                        id: cancelTxt
                        x: 25
                        y: (parent.height-height)/2
                        text: "Cancel"
                    }
                    MouseArea {
                        id: cancelMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            conf_top.hide()
                            conf_top.rejected()()
                        }
                    }
                }

            }

        }

    }

    function show(headertext : string, desctext : string, action : string, payload : var) {
        conf_top.action = action
        conf_top.payload = payload
        header.text = headertext
        description.text = desctext
        opacity = 1
    }

    function hide() {
        opacity = 0
    }

}
