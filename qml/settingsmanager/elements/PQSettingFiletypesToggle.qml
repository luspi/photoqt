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
import PhotoQt

Item {

    id: toggle

    property list<string> model: []
    property string title: ""
    property string what: ""

    visible: false

    anchors.fill: parent
    Rectangle {
        anchors.fill: parent
        color: palette.text
        opacity: 0.5
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked:
            toggle.hide()
    }

    Rectangle {

        id: toggleCont

        x: (parent.width-width)/2
        y: (parent.height-height)/2
        width: Math.min(parent.width, 600)
        height: Math.min(parent.height, 600)
        color: palette.alternateBase
        border.width: 1
        border.color: PQCLook.baseBorder
        radius: 10

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }

        Column {

            spacing: 10

            PQTextXL {
                id: txtHeading
                x: (parent.width-width)/2
                font.weight: PQCLook.fontWeightBold
                text: toggle.title
            }

            Row {

                Column {

                    PQTextL{
                        id: txtEnable
                        width: toggleCont.width/2
                        text: "Enable"
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Item {
                        width: 1
                        height: 10
                    }

                    Repeater {

                        model: toggle.model.length

                        PQButton {
                            required property int modelData
                            width: toggleCont.width/2
                            height: (toggleCont.height-txtHeading.height-txtEnable.height-20)/toggle.model.length
                            smallerVersion: true
                            text: toggle.model[modelData]
                            tintButton: "green"
                            onClicked: {
                                PQCNotify.settingsmanagerSendCommand("filetypesToggle", [toggle.what, modelData, true])
                                toggle.hide()
                            }
                        }

                    }

                }

                Column {

                    PQTextL{
                        id: txtDisable
                        width: toggleCont.width/2
                        // font.weight: PQCLook.fontWeightBold
                        text: "Disable"
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Item {
                        width: 1
                        height: 10
                    }

                    Repeater {

                        model: toggle.model.length

                        PQButton {
                            required property int modelData
                            width: toggleCont.width/2
                            height: (toggleCont.height-txtHeading.height-txtDisable.height-20)/toggle.model.length
                            smallerVersion: true
                            text: toggle.model[modelData]
                            tintButton: "red"
                            onClicked: {
                                PQCNotify.settingsmanagerSendCommand("filetypesToggle", [toggle.what, modelData, false])
                                toggle.hide()
                            }
                        }

                    }

                }

            }

        }

    }

    function show() {
        visible = true
    }

    function hide() {
        visible = false
    }

}
