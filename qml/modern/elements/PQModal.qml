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
import PhotoQt.Modern
import PhotoQt.Shared

Item {

    id: modal_top

    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: pqtPalette.base
        opacity: 0.8
    }

    SystemPalette { id: pqtPalette }

    property string action: ""
    property var payload: []

    property alias button1: acceptButton
    property alias button2: rejectButton

    signal accepted()
    signal rejected()

    opacity: 0
    visible: opacity>0
    Behavior on opacity { NumberAnimation { duration: 200 } }

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

        color: pqtPalette.base

        border.width: 2
        border.color: PQCLook.baseBorder

        radius: 5

        Column {

            id: col

            x: 50
            y: 50

            spacing: 20

            PQTextXXL {
                id: header
                text: "Are you sure?"
                width: Math.min(modal_top.width-200, 600)
                horizontalAlignment: Text.AlignHCenter
                font.weight: PQCLook.fontWeightBold
            }

            PQTextL {
                id: description
                text: "Are you sure you want to do this???"
                width: Math.min(modal_top.width-200, 600)
                horizontalAlignment: Text.AlignHCenter
            }

            Row {

                x: (header.width-width)/2

                spacing: 10

                PQButton {
                    id: acceptButton
                    text: "Yes"
                    onClicked: {
                        modal_top.hide()
                        modal_top.accepted()
                    }
                }

                PQButton {
                    id: rejectButton
                    text: "No"
                    onClicked: {
                        modal_top.hide()
                        modal_top.rejected()
                    }
                }

            }

        }

    }

    function show(headertext : string, desctext : string, action : string, payload : var) {
        modal_top.action = action
        modal_top.payload = payload
        header.text = headertext
        description.text = desctext
        opacity = 1
    }

    function hide() {
        opacity = 0
    }

}
