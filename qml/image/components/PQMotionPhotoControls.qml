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

Loader {

    id: ldr_top

    active: PQCConstants.currentImageIsMotionPhoto && PQCSettings.filetypesMotionPhotoPlayPause

    asynchronous: true

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
                color: palette.base
                border.width: 1
                border.color: PQCLook.baseBorder
                opacity: 0.8
                radius: 5
            }

            Row {

                id: cont_row

                Item {

                    width: 30
                    height: 30

                    opacity: autoplaymouse.containsMouse ? (PQCSettings.filetypesMotionAutoPlay ? 1 : 0.6) : 0.2
                    Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }

                    Image {
                        anchors.fill: parent
                        anchors.margins: 5
                        opacity: PQCSettings.filetypesMotionAutoPlay ? 1 : 0.5
                        Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
                        sourceSize: Qt.size(width, height)
                        source: PQCSettings.filetypesMotionAutoPlay ? ("image://svg/:/" + PQCLook.iconShade + "/autoplay.svg") : ("image://svg/:/" + PQCLook.iconShade + "/autoplay_off.svg")
                    }

                    PQMouseArea {
                        id: autoplaymouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        tooltip: qsTranslate("image", "Toggle autoplay")
                        onClicked: {
                            PQCSettings.filetypesMotionAutoPlay = !PQCSettings.filetypesMotionAutoPlay
                        }
                    }

                }

                Item {

                    width: 30
                    height: 30

                    opacity: playpausemouse.containsMouse ? 1 : 0.2
                    Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }

                    Image {
                        anchors.fill: parent
                        anchors.margins: 5
                        sourceSize: Qt.size(width, height)
                        source: PQCConstants.motionPhotoIsPlaying ? ("image://svg/:/" + PQCLook.iconShade + "/pause.svg") : ("image://svg/:/" + PQCLook.iconShade + "/play.svg")
                    }

                    PQMouseArea {
                        id: playpausemouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        tooltip: qsTranslate("image", "Play/Pause motion photo")
                        onClicked: {
                            PQCNotify.playPauseAnimationVideo()
                        }
                    }

                }

            }

        }

}
