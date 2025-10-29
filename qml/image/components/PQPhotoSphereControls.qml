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

Loader {

    id: ldr_top

    active: PQCConstants.showingPhotoSphere && PQCSettings.filetypesPhotoSphereControls

    asynchronous: true

    SystemPalette { id: pqtPalette }

    sourceComponent:
    Item {

        parent: ldr_top.parent

        x: parent.width-width-10
        y: parent.height-height-10
        z: PQCConstants.currentZValue+1

        width: cont_row.width
        height: cont_row.height

        Rectangle {
            anchors.fill: parent
            color: pqtPalette.base
            opacity: 0.8
            border.width: 1
            border.color: PQCLook.baseBorder
            radius: 3
        }

        Row {

            id: cont_row

            Item {

                id: leftrightlock

                y: (parent.height-height)/2
                width: lockrow.width+6
                height: lockrow.height+6

                opacity: PQCSettings.filetypesPhotoSphereArrowKeys ? 1 : 0.3
                Behavior on opacity { NumberAnimation { duration: 200 } }

                Row {
                    id: lockrow
                    x: 3
                    y: (parent.height-height)/2

                    Image {
                        y: (parent.height-height)/2
                        height: cont_row.height/2
                        width: height
                        source: "image://svg/:/" + PQCLook.iconShade + "/padlock.svg"
                        sourceSize: Qt.size(width, height)
                    }

                    Label {
                        y: (parent.height-height)/2
                        font.pointSize: PQCLook.fontSize
                        text: "←/→"
                    }

                }

                PQMouseArea {
                    id: leftrightmouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    tooltip: qsTranslate("image", "Lock arrow keys to moving photo sphere")
                    onClicked:
                        PQCSettings.filetypesPhotoSphereArrowKeys = !PQCSettings.filetypesPhotoSphereArrowKeys
                }

            }

        }

    }

}
