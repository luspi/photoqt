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

import "../../elements"

Rectangle {

    id: controls_top

    x: (parent.width-width)/2
    y: parent.height*0.9
    width: controlrow.width+20
    height: 50
    color: PQCLook.transColor
    radius: 5

    property bool controlsClosed: false

    opacity: (loader_component.isMpv || loader_component.isQtVideo)
                    ? ((((controlmouse.containsMouse || playpausemouse.containsMouse ||
                          volumeiconmouse.containsMouse || volumebg.containsMouse ||
                          volumeslider.backgroundContainsMouse || volumeslider.handleContainsMouse ||
                          posslider.backgroundContainsMouse || posslider.handleContainsMouse ||
                          closemouse.containsMouse) && !controlsClosed) || !loader_component.videoPlaying)
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
            source: loader_component.videoPlaying ? "image://svg/:/white/pause.svg" : "image://svg/:/white/play.svg"
            sourceSize: Qt.size(width, height)
            PQMouseArea {
                id: playpausemouse
                anchors.fill: parent
                text: "Click to play/pause"
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked:
                    loader_component.videoTogglePlay()
            }
        }

        PQText {
            id: curtime
            y: (parent.height-height)/2
            text: PQCScriptsImages.convertSecondsToPosition(loader_component.videoPosition)
        }

        PQSlider {
            id: posslider
            y: (parent.height-height)/2
            // width: totaltime.x-curtime.x-curtime.width-20
            live: false
            from: 0
            to: loader_component.videoDuration

            onPressedChanged: {
                if(!pressed) {
                    loader_component.videoToPos(value)
                }
            }

            onPositionChanged: {
                if(pressed && loader_component.isQtVideo) {
                    loader_component.videoToPos(position*to)
                }
            }

            Connections {
                target: loader_component

                function onVideoPositionChanged() {
                    if(posslider.pressed)
                        return
                    posslider.value = Math.floor(loader_component.videoPosition)
                }
            }

        }

        PQText {
            id: totaltime
            y: (parent.height-height)/2
            text: PQCScriptsImages.convertSecondsToPosition(loader_component.videoDuration)
        }

        Image {
            id: volumeicon
            y: parent.height*0.2
            height: parent.height*0.6
            width: height
            sourceSize: Qt.size(width, height)
            source: PQCSettings.filetypesVideoVolume===0
                            ? "image://svg/:/white/volume_mute.svg"
                            : (PQCSettings.filetypesVideoVolume <= 40
                                    ? "image://svg/:/white/volume_low.svg"
                                    : (PQCSettings.filetypesVideoVolume <= 80
                                            ? "image://svg/:/white/volume_medium.svg"
                                            : "image://svg/:/white/volume_high.svg"))

            PQMouseArea {
                id: volumeiconmouse
                anchors {
                    fill: parent
                    topMargin: -volumeicon.y
                    bottomMargin: anchors.topMargin
                    rightMargin: -10
                    leftMargin: -10
                }
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                text: "Volume: " + PQCSettings.filetypesVideoVolume + "%<br>Click to mute/unmute"
                property int backupVolume: -1
                onClicked: {
                    if(PQCSettings.filetypesVideoVolume === 0) {
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
            color: PQCLook.textColor
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

            opacity: PQCSettings.imageviewVideoLeftRightJumpVideo ? 1 : 0.3
            Behavior on opacity { NumberAnimation { duration: 200 } }

            Row {
                id: lockrow

                Image {
                    height: lrtxt.height
                    width: height
                    opacity: PQCSettings.imageviewVideoLeftRightJumpVideo ? 1 : 0.4
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
                    PQCSettings.imageviewVideoLeftRightJumpVideo = !PQCSettings.imageviewVideoLeftRightJumpVideo
            }

        }

    }

    Image {
        x: parent.width-width+10
        y: -10
        width: 20
        height: 20
        sourceSize: Qt.size(width, height)
        source: controls_top.controlsClosed ? "image://svg/:/white/thumbnail.svg" : "image://svg/:/white/close.svg"
        opacity: closemouse.containsMouse ? 1 : 0.1
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        PQMouseArea {
            id: closemouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            text: controls_top.controlsClosed ? "Click to always show video controls" : "Click to hide video controls when video is playing"
            onClicked: controls_top.controlsClosed = !controls_top.controlsClosed
        }
    }

    Rectangle {
        id: volumecont
        x: volumeicon.x-10
        y: -height
        width: volumeicon.width + 20
        radius: 5
        height: 150
        color: PQCLook.transColor

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
            value: 100-PQCSettings.filetypesVideoVolume
            height: parent.height-20
            orientation: Qt.Vertical
            reverseWheelChange: true
            onValueChanged: {
                PQCSettings.filetypesVideoVolume = 100-volumeslider.value
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
