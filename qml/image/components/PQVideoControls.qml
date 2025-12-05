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

    SystemPalette { id: pqtPalette }

    active: PQCConstants.currentlyShowingVideo

    asynchronous: true

    sourceComponent:
    Item {

        id: controlitem

        parent: ldr_top.parent

        x: (parent.width-width)/2
        y: parent.height-height-20
        z: PQCConstants.currentZValue+1

        width: cont_row.width+20
        height: 50

        property bool hovered: bgmouse.containsMouse || leftrightmouse.containsMouse || volumeslider.hovered || volumebg.containsMouse ||
                               playpausemouse.containsMouse || volumeiconmouse.containsMouse || posslider.hovered
        opacity: hovered ? 1 : 0.4
        Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }

        property bool manuallyDragged: false

        Connections {
            target: ldr_top.parent.parent
            enabled: controlitem.manuallyDragged
            function onWidthChanged() {
                controlitem.x = Math.min(controlitem.x, ldr_top.parent.parent.width-controlitem.width-5)
            }
            function onHeightChanged() {
                controlitem.y = Math.min(controlitem.y, ldr_top.parent.parent.height-controlitem.height-5)
            }
        }

        Connections {

            target: PQCNotify

            function onCurrentVideoMuteUnmute() {
                controlitem.muteUnmute()
            }

            function onCurrentVideoControlsResetPosition() {
                controlitem.manuallyDragged = false
                controlitem.x = Qt.binding(function() { return (controlitem.parent.width-controlitem.width)/2 })
                controlitem.y = Qt.binding(function() { return (controlitem.parent.height-controlitem.height-20) })
                PQCConstants.extraControlsLocation = Qt.point(-1,-1)
            }

        }

        onXChanged: {
            if(x !== (parent.width-width)/2 && controlitem.manuallyDragged) {
                PQCConstants.extraControlsLocation.x = x
                x = x
            }
        }
        onYChanged: {
            if(y !== 0.9*parent.height && controlitem.manuallyDragged) {
                PQCConstants.extraControlsLocation.y = y
                y = y
            }
        }

        Component.onCompleted: {
            if(PQCConstants.extraControlsLocation.x !== -1) {
                controlitem.x = PQCConstants.extraControlsLocation.x
                controlitem.y = PQCConstants.extraControlsLocation.y
                controlitem.manuallyDragged = true
            }
        }

        Rectangle {
            anchors.fill: parent
            color: pqtPalette.base
            opacity: 0.9
            border.width: 1
            border.color: PQCLook.baseBorder
            radius: 5
        }

        MouseArea {
            id: bgmouse
            anchors.fill: parent
            drag.target: parent
            drag.minimumX: 5
            drag.minimumY: 5
            drag.maximumX: ldr_top.parent.parent.width-controlitem.width-5
            drag.maximumY: ldr_top.parent.parent.height-controlitem.height-5
            hoverEnabled: true
            cursorShape: Qt.SizeAllCursor
            acceptedButtons: Qt.RightButton|Qt.LeftButton
            propagateComposedEvents: true
            onWheel: {}
            drag.onActiveChanged: if(drag.active) controlitem.manuallyDragged = true
            onClicked: (mouse) => {
                if(mouse.button === Qt.RightButton)
                    rightclickmenu.popup()
            }
        }

        Row {

            id: cont_row

            x: 10
            y: (parent.height-height)/2
            spacing: 5

            Image {
                id: playpause
                y: parent.height*0.2
                height: parent.height*0.6
                width: height
                source: "image://svg/:/" + PQCLook.iconShade + "/" + (PQCConstants.currentlyShowingVideoPlaying ? "pause" : "play") + ".svg"
                sourceSize: Qt.size(width, height)
                PQMouseArea {
                    id: playpausemouse
                    anchors.fill: parent
                    tooltip: qsTranslate("image", "Click to play/pause")
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton|Qt.RightButton
                    onClicked: (mouse) => {
                        if(mouse.button === Qt.LeftButton)
                            PQCNotify.playPauseAnimationVideo()
                        else
                            rightclickmenu.popup()
                    }
                }
            }

            PQText {
                id: curtime
                y: (parent.height-height)/2
                text: PQCScriptsImages.convertSecondsToPosition(PQCConstants.currentlyShowingVideoPosition)
            }

            Slider {
                id: posslider
                y: (parent.height-height)/2
                width: 300
                live: false
                from: 0
                to: PQCConstants.currentlyShowingVideoDuration

                onPressedChanged: {
                    if(!pressed) {
                        PQCNotify.currentVideoToPos(value)
                        ldr_top.forceActiveFocus()
                    }
                }

                onPositionChanged: {
                    if(pressed && PQCConstants.currentlyShowingVideo) {
                        PQCNotify.currentVideoToPos(position*to)
                    }
                }

                Connections {
                    target: PQCConstants
                    function onCurrentlyShowingVideoPositionChanged() {
                        if(posslider.pressed)
                            return
                        posslider.value = Math.floor(PQCConstants.currentlyShowingVideoPosition)
                    }
                }

            }

            PQText {
                id: totaltime
                y: (parent.height-height)/2
                text: PQCScriptsImages.convertSecondsToPosition(PQCConstants.currentlyShowingVideoDuration)
            }

            Image {
                id: volumeicon
                y: parent.height*0.2
                height: parent.height*0.6
                width: height
                enabled: PQCConstants.currentlyShowingVideoHasAudio
                sourceSize: Qt.size(width, height)
                opacity: enabled ? 1 : 0.3
                source: !enabled ?
                            ("image://svg/:/" + PQCLook.iconShade + "/volume_noaudio.svg") :
                            PQCSettings.filetypesVideoVolume===0 ?
                                ("image://svg/:/" + PQCLook.iconShade + "/volume_mute.svg") :
                                (PQCSettings.filetypesVideoVolume <= 40 ?
                                     ("image://svg/:/" + PQCLook.iconShade + "/volume_low.svg") :
                                     (PQCSettings.filetypesVideoVolume <= 80 ?
                                          ("image://svg/:/" + PQCLook.iconShade + "/volume_medium.svg") :
                                          ("image://svg/:/" + PQCLook.iconShade + "/volume_high.svg")))

                PQMouseArea {
                    id: volumeiconmouse
                    anchors {
                        fill: parent
                        topMargin: -volumeicon.y
                        bottomMargin: anchors.topMargin
                        rightMargin: -10
                        leftMargin: -10
                    }
                    enabled: PQCConstants.currentlyShowingVideoHasAudio
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton|Qt.RightButton
                             //: The volume here is referring to SOUND volume
                    tooltip: qsTranslate("image", "Volume:") + " " +
                             PQCSettings.filetypesVideoVolume + "%<br>" +
                             qsTranslate("image", "Click to mute/unmute")
                    onClicked: (mouse) => {
                        if(mouse.button === Qt.RightButton) {
                            rightclickmenu.popup()
                            return
                        }
                        controlitem.muteUnmute()
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
                color: pqtPalette.text
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

                opacity: PQCSettings.filetypesVideoLeftRightJumpVideo ? 1 : 0.3
                Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }

                Row {
                    id: lockrow

                    Image {
                        height: lrtxt.height
                        width: height
                        opacity: PQCSettings.filetypesVideoLeftRightJumpVideo ? 1 : 0.4
                        source: "image://svg/:/" + PQCLook.iconShade + "/padlock.svg"
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
                    acceptedButtons: Qt.LeftButton|Qt.RightButton
                    tooltip: qsTranslate("image", "Lock left/right arrow keys to jumping forwards/backwards 5 seconds")
                    onClicked: (mouse) => {
                        if(mouse.button === Qt.LeftButton)
                            PQCSettings.filetypesVideoLeftRightJumpVideo = !PQCSettings.filetypesVideoLeftRightJumpVideo
                        else
                            rightclickmenu.popup()
                    }
                }

            }

        }

        Rectangle {
            id: volumecont
            x: volumeicon.x-10
            y: -height
            width: volumeicon.width + 20
            radius: 5
            height: 150
            color: pqtPalette.base

            opacity: 0
            visible: opacity>0
            Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }

            MouseArea {
                id: volumebg
                anchors.fill: parent
                hoverEnabled: true
                onExited:
                    hideVolume.restart()
            }

            Slider {
                id: volumeslider
                x: (parent.width-width)/2
                y: 10
                rotation: 180
                from: 0
                to: 100
                value: 100-PQCSettings.filetypesVideoVolume
                height: parent.height-20
                orientation: Qt.Vertical
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
                            !volumeslider.hovered)
                        volumecont.opacity = 0
            }

        }

        PQMenu {

            id: rightclickmenu

            property bool resetPosAfterHide: false

            PQMenuItem {
                iconSource: PQCConstants.currentlyShowingVideoPlaying ? ("image://svg/:/" + PQCLook.iconShade + "/pause.svg") : ("image://svg/:/" + PQCLook.iconShade + "/play.svg")
                text: PQCConstants.currentlyShowingVideoPlaying ? qsTranslate("image", "Pause video") : qsTranslate("image", "Play video")
                onTriggered: {
                    PQCNotify.playPauseAnimationVideo()
                }
            }

            PQMenuItem {
                id: volmenuitem
                //: refers to muting sound
                text: PQCSettings.filetypesVideoVolume===0 ?qsTranslate("image", "Unmute") : qsTranslate("image", "Mute")
                onTriggered: {
                    PQCNotify.currentVideoMuteUnmute()
                }
            }

            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/padlock.svg"
                text: PQCSettings.filetypesVideoLeftRightJumpVideo ? qsTranslate("image", "Unlock arrow keys") : qsTranslate("image", "Lock arrow keys")
                onTriggered: {
                    PQCSettings.filetypesVideoLeftRightJumpVideo = !PQCSettings.filetypesVideoLeftRightJumpVideo
                }
            }

            PQMenuSeparator {}

            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/reset.svg"
                text: qsTranslate("image", "Reset position")
                onTriggered: {
                    rightclickmenu.resetPosAfterHide = true
                }
            }

            onVisibleChanged: {
                if(!visible && resetPosAfterHide) {
                    resetPosAfterHide = false
                    controlitem.manuallyDragged = false
                    controlitem.x = Qt.binding(function() { return (controlitem.parent.width-controlitem.width)/2 })
                    controlitem.y = Qt.binding(function() { return (controlitem.parent.height-controlitem.height-20) })
                    PQCConstants.extraControlsLocation = Qt.point(-1,-1)
                }
            }

        }

        property int backupVolume: -1
        function muteUnmute() {
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

    }

}
