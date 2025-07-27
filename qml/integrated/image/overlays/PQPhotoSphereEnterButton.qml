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
import PhotoQt.Integrated
import PhotoQt.Shared

Loader {

    id: ldr_top

    SystemPalette { id: pqtPalette }

    active: PQCConstants.currentImageIsPhotoSphere && !PQCConstants.showingPhotoSphere && PQCSettings.filetypesPhotoSphereBigButton && !PQCConstants.slideshowRunning

    sourceComponent:
        Item {
            parent: ldr_top.parent
            id: spherebut
            x: (parent.width-width)/2
            y: (parent.height-height)/2
            width: 150
            height: 150
            Rectangle {
                anchors.fill: parent
                opacity: 0.8
                color: pqtPalette.base
                radius: width/2
                border.width: 1
                border.color: pqtPalette.text
            }
            opacity: (spheremouse.containsMouse ? 0.8 : 0.4)
            Behavior on opacity { NumberAnimation { duration: 200 } }

            Image {
                anchors.fill: parent
                anchors.margins: 20
                mipmap: true
                fillMode: Image.PreserveAspectFit
                sourceSize: Qt.size(width, height)
                source: "image://svg/:/" + PQCLook.iconShade + "/photosphere.svg"
            }

            PQMouseArea {
                id: spheremouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                text: qsTranslate("image", "Click here to enter photo sphere")
                onClicked: {
                    PQCNotify.enterPhotoSphere()
                }
            }

        }

}
