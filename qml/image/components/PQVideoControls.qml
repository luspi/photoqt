/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

import PQCScriptsImages
import PQCNotify

import "../../elements"


Item {

    id: top

    Loader {

        active: !PQCNotify.slideshowRunning // qmllint disable unqualified

        sourceComponent:
        Rectangle {

            id: controlitem

            parent: loader_top // qmllint disable unqualified

            x: (parent.width-width)/2
            y: 0.9*parent.height
            z: image_top.curZ // qmllint disable unqualified
            width: controlrow.width+20
            height: 50
            radius: 5
            color: PQCLook.transColor // qmllint disable unqualified

            property bool controlsClosed: false

            opacity: (loader_top.videoLoaded) // qmllint disable unqualified
                            ? ((((controlmouse.containsMouse || playpausemouse.containsMouse ||
                                  volumeiconmouse.containsMouse || volumebg.containsMouse ||
                                  volumeslider.backgroundContainsMouse || volumeslider.handleContainsMouse ||
                                  posslider.backgroundContainsMouse || posslider.handleContainsMouse ||
                                  closemouse.containsMouse) && !controlsClosed) || !loader_top.videoPlaying)
                                    ? 1
                                    : (controlsClosed ? 0 : 0.2))
                            : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 200 } }

            PQMouseArea {
                id: controlmouse
                anchors.fill: parent
                text: "Click and drag to move"
                cursorShape: Qt.SizeAllCursor
                drag.target: parent
            }

            Row {

                id: controlrow

                x: 10
                height: parent.height
                spacing: 5

                Image {
                    id: playpause
                    y: parent.height*0.2
                    height: parent.height*0.6
                    width: height
                    source: loader_top.videoPlaying ? "image://svg/:/white/pause.svg" : "image://svg/:/white/play.svg" // qmllint disable unqualified
                    sourceSize: Qt.size(width, height)
                    PQMouseArea {
                        id: playpausemouse
                        anchors.fill: parent
                        text: "Click to play/pause"
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked:
                            loader_top.videoTogglePlay() // qmllint disable unqualified
                    }
                }

                PQText {
                    id: curtime
                    y: (parent.height-height)/2
                    text: PQCScriptsImages.convertSecondsToPosition(loader_top.videoPosition) // qmllint disable unqualified
                }

                PQSlider {
                    id: posslider
                    y: (parent.height-height)/2
                    // width: totaltime.x-curtime.x-curtime.width-20
                    live: false
                    from: 0
                    to: loader_top.videoDuration // qmllint disable unqualified

                    onPressedChanged: {
                        if(!pressed) {
                            loader_top.videoToPos(value) // qmllint disable unqualified
                        }
                    }

                    onPositionChanged: {
                        if(pressed && loader_top.videoLoaded) { // qmllint disable unqualified
                            loader_top.videoToPos(position*to)
                        }
                    }

                    Connections {
                        target: loader_top // qmllint disable unqualified

                        function onVideoPositionChanged() {
                            if(posslider.pressed)
                                return
                            posslider.value = Math.floor(loader_top.videoPosition) // qmllint disable unqualified
                        }
                    }

                }

                PQText {
                    id: totaltime
                    y: (parent.height-height)/2
                    text: PQCScriptsImages.convertSecondsToPosition(loader_top.videoDuration) // qmllint disable unqualified
                }

                Image {
                    id: volumeicon
                    y: parent.height*0.2
                    height: parent.height*0.6
                    width: height
                    enabled: loader_top.videoHasAudio // qmllint disable unqualified
                    sourceSize: Qt.size(width, height)
                    opacity: enabled ? 1 : 0.3
                    source: !enabled ?
                                "image://svg/:/white/volume_noaudio.svg" :
                                PQCSettings.filetypesVideoVolume===0 ? // qmllint disable unqualified
                                    "image://svg/:/white/volume_mute.svg" :
                                    (PQCSettings.filetypesVideoVolume <= 40 ?
                                         "image://svg/:/white/volume_low.svg" :
                                         (PQCSettings.filetypesVideoVolume <= 80 ?
                                              "image://svg/:/white/volume_medium.svg" :
                                              "image://svg/:/white/volume_high.svg"))

                    PQMouseArea {
                        id: volumeiconmouse
                        anchors {
                            fill: parent
                            topMargin: -volumeicon.y
                            bottomMargin: anchors.topMargin
                            rightMargin: -10
                            leftMargin: -10
                        }
                        enabled: loader_top.videoHasAudio // qmllint disable unqualified
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        text: "Volume: " + PQCSettings.filetypesVideoVolume + "%<br>Click to mute/unmute" // qmllint disable unqualified
                        property int backupVolume: -1
                        onClicked: {
                            if(PQCSettings.filetypesVideoVolume === 0) { // qmllint disable unqualified
                                if(backupVolume == -1 || backupVolume == 0)
                                    PQCSettings.filetypesVideoVolume = 100
                                else
                                    PQCSettings.filetypesVideoVolume = backupVolume
                            } else {
                                backupVolume = PQCSettings.filetypesVideoVolume
                                PQCSettings.filetypesVideoVolume = 0
                            }
                        }
                        onEntered:
                            volumecont.opacity = 1
                        onExited:
                            hideVolume.restart()
                        onWheel: (wheel) => {
                            if(wheel.angleDelta.y > 0)
                                volumeslider.value -= volumeslider.wheelStepSize
                            else
                                volumeslider.value += volumeslider.wheelStepSize
                        }
                    }

                }

                Item {
                    width: 1
                    height: 1
                }

                Rectangle {
                    y: (parent.height-height)/2
                    width: 1
                    height: controlitem.height*0.75
                    color: PQCLook.textColor // qmllint disable unqualified
                }

                Item {
                    width: 1
                    height: 1
                }

                Item {

                    id: leftrightlock

                    y: (parent.height-height)/2
                    width: lockrow.width
                    height: lockrow.height

                    opacity: PQCSettings.filetypesVideoLeftRightJumpVideo ? 1 : 0.3 // qmllint disable unqualified
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    Row {
                        id: lockrow

                        Image {
                            height: lrtxt.height
                            width: height
                            opacity: PQCSettings.filetypesVideoLeftRightJumpVideo ? 1 : 0.4 // qmllint disable unqualified
                            source: "image://svg/:/white/padlock.svg"
                            sourceSize: Qt.size(width, height)
                        }

                        PQText {
                            id: lrtxt
                            text: "←/→"
                        }

                    }

                    PQMouseArea {
                        id: leftrightmouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        text: qsTranslate("image", "Lock left/right arrow keys to jumping forwards/backwards 5 seconds")
                        onClicked:
                            PQCSettings.filetypesVideoLeftRightJumpVideo = !PQCSettings.filetypesVideoLeftRightJumpVideo // qmllint disable unqualified
                    }

                }

            }

            Image {
                x: parent.width-width+10
                y: -10
                width: 20
                height: 20
                sourceSize: Qt.size(width, height)
                source: controlitem.controlsClosed ? "image://svg/:/white/thumbnail.svg" : "image://svg/:/white/close.svg"
                opacity: closemouse.containsMouse ? 1 : 0.1
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
                PQMouseArea {
                    id: closemouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    text: controlitem.controlsClosed ? "Click to always show video controls" : "Click to hide video controls when video is playing"
                    onClicked: controlitem.controlsClosed = !controlitem.controlsClosed
                }
            }

            Rectangle {
                id: volumecont
                x: volumeicon.x-10
                y: -height
                width: volumeicon.width + 20
                radius: 5
                height: 150
                color: PQCLook.transColor // qmllint disable unqualified

                opacity: 0
                visible: opacity>0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                MouseArea {
                    id: volumebg
                    anchors.fill: parent
                    hoverEnabled: true
                    onExited:
                        hideVolume.restart()
                }

                PQSlider {
                    id: volumeslider
                    x: (parent.width-width)/2
                    y: 10
                    rotation: 180
                    from: 0
                    to: 100
                    value: 100-PQCSettings.filetypesVideoVolume // qmllint disable unqualified
                    height: parent.height-20
                    orientation: Qt.Vertical
                    reverseWheelChange: true
                    onValueChanged: {
                        PQCSettings.filetypesVideoVolume = 100-volumeslider.value // qmllint disable unqualified
                    }
                }

                Timer {
                    id: hideVolume
                    interval: 500
                    onTriggered:
                        if(!volumebg.containsMouse &&
                                !volumeiconmouse.containsMouse &&
                                !volumeslider.backgroundContainsMouse &&
                                !volumeslider.handleContainsMouse)
                            volumecont.opacity = 0
                }

            }

        }

    }

}
