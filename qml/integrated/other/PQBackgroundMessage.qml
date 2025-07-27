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
import PhotoQt.Integrated
import PhotoQt.Shared

Item {

    id: bgmessage_top

    width: parent.parent.width
    height: parent.parent.height

    opacity: 0
    visible: PQCFileFolderModel.countMainView===0 && opacity>0

    SystemPalette { id: pqtPalette }

    Component.onCompleted: {
        if(PQCConstants.startupFilePath === "")
            bgmessage_top.opacity = 1
    }

    Item {
        id: startmessage
        anchors.fill: parent
        anchors.margins: 160
        Column {
            x: (parent.width-width)/2
            y: (parent.height-height)/2.5

            spacing: 10

            Item {

                id: clickhere
                x: (parent.width-100)/2

                width: 100
                height: 100

                visible: startmessage.visible

                Rectangle {

                    id: clickcircle

                    width: 20
                    x: (parent.width-width)/2
                    y: (parent.height-height)/2
                    height: width
                    radius: width/2
                    color: "transparent"
                    opacity: 1 - (width-20)/40
                    border {
                        width: 5
                        color: pqtPalette.text
                    }

                    NumberAnimation {
                        id: clickani
                        target: clickcircle
                        property: "width"
                        from: 20
                        to: 50
                        duration: 1000
                        loops: Animation.Infinite
                        running: clickhere.visible&&!PQCConstants.modalWindowOpen
                        easing.type: Easing.OutCirc
                    }
                }

                Image {

                    x: parent.width/2
                    y: parent.height/2

                    width: 40*(2/3)
                    height: 40
                    smooth: false
                    sourceSize: Qt.size(width, height)
                    source: "image://svg/:/" + PQCLook.iconShade + "/mouse.svg"

                }

            }

            Item {
                width: 1
                height: 20
            }

            PQText {
                id: openmessage
                width: startmessage.width
                //: Part of the message shown in the main view before any image is loaded
                text: qsTranslate("other", "Open a file")
                font.pointSize: Math.min(40, Math.max(20, (PQCConstants.windowWidth+PQCConstants.windowHeight)/80))
                font.weight: PQCLook.fontWeightBold
                opacity: PQCConstants.windowWidth>750&&PQCConstants.windowHeight>500 ? 0.8 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
                visible: opacity>0
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            PQCScriptsShortcuts.executeInternalCommand("__open")
        }
    }

}
