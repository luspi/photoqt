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
import PhotoQt.Shared

Loader {

    id: ldr_top

    active: PQCConstants.currentImageIsAnimated && PQCSettings.filetypesAnimatedControls
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
            anchors.margins: -5
            color: pqtPalette.base
            opacity: 0.8
            radius: 5
            border.width: 1
            border.color: PQCLook.baseBorder
        }

        Row {

            id: cont_row

            Item {

                width: 30
                height: 30

                opacity: playpausemouse.containsMouse ? 1 : 0.2
                Behavior on opacity { NumberAnimation { duration: 200 } }

                Image {
                    anchors.fill: parent
                    anchors.margins: 5
                    sourceSize: Qt.size(width, height)
                    source: PQCConstants.animatedImageIsPlaying ? ("image://svg/:/" + PQCLook.iconShade + "/pause.svg") : ("image://svg/:/" + PQCLook.iconShade + "/play.svg")
                }

                PQGenericMouseArea {
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

            // save frame button
            Item {
                y: (parent.height-height)/2
                width: cont_row.height/1.75 + 6
                height: width
                Image {
                    x: 3
                    y: 3
                    width: height
                    height: parent.height-6
                    opacity: enabled ? 0.75 : 0.25
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    source: "image://svg/:/" + PQCLook.iconShade + "/remember.svg"
                    sourceSize: Qt.size(width, height)
                    enabled: !PQCConstants.animatedImageIsPlaying
                    PQGenericMouseArea {
                        id: saveframemouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        //: The frame here refers to one of the images making up an animation of a gif or other animated image
                        tooltip: qsTranslate("image", "Save current frame to new file")
                        onClicked: {
                            PQCNotify.currentAnimatedSaveFrame()
                        }
                    }
                }
            }

            Item {

                id: leftrightlock

                y: (parent.height-height)/2
                width: lockrow.width+6
                height: lockrow.height+6

                opacity: PQCSettings.filetypesAnimatedLeftRight ? 1 : 0.3
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
                        text: "←/→"
                        font.pointSize: PQCLook.fontSize
                    }

                }

                PQGenericMouseArea {
                    id: leftrightmouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    tooltip: qsTranslate("image", "Lock left/right arrow keys to frame navigation")
                    onClicked:
                        PQCSettings.filetypesAnimatedLeftRight = !PQCSettings.filetypesAnimatedLeftRight
                }

            }

        }

    }

}
