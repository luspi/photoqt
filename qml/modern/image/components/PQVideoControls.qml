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


Rectangle {

    id: control_top

    /*******************************************/
    // these values are READONLY

    property Item loaderTop
    property bool videoLoaded
    property bool videoPlaying
    property int videoPosition
    property int videoDuration
    property bool videoHasAudio

    /*******************************************/

    signal videoToPos(var pos)

    /*******************************************/

    onVideoPositionChanged: {
        if(posslider.pressed)
            return
        posslider.value = Math.floor(control_top.videoPosition)
    }

    parent: control_top.loaderTop

    x: (control_top.loaderTop.width-width)/2
    y: 0.9*control_top.loaderTop.height
    z: PQCConstants.currentZValue
    width: controlrow.width+20
    height: 50
    radius: 5
    color: PQCLook.transColor

    property bool manuallyDragged: false

    property bool controlsClosed: false

    opacity: (control_top.videoLoaded)
                    ? ((((controlmouse.containsMouse || playpausemouse.containsMouse ||
                          volumeiconmouse.containsMouse || volumebg.containsMouse ||
                          volumeslider.backgroundContainsMouse || volumeslider.handleContainsMouse ||
                          posslider.backgroundContainsMouse || posslider.handleContainsMouse ||
                          closemouse.containsMouse) && !controlsClosed) || !control_top.videoPlaying)
                            ? 1
                            : (controlsClosed ? 0 : 0.2))
                    : 0
    visible: !PQCConstants.slideshowRunning && opacity > 0
    Behavior on opacity { NumberAnimation { duration: 200 } }

    Connections {
        target: control_top.loaderTop
        enabled: control_top.manuallyDragged
        function onWidthChanged() {
            control_top.x = Math.min(control_top.x, control_top.loaderTop.width-control_top.width-5)
        }
        function onHeightChanged() {
            control_top.y = Math.min(control_top.y, control_top.loaderTop.height-control_top.height-5)
        }
    }

    onXChanged: {
        if(x !== (parent.width-width)/2 && control_top.manuallyDragged) {
            PQCConstants.extraControlsLocation.x = x
            x = x
        }
    }
    onYChanged: {
        if(y !== 0.9*parent.height && control_top.manuallyDragged) {
            PQCConstants.extraControlsLocation.y = y
            y = y
        }
    }

    Component.onCompleted: {
        if(PQCConstants.extraControlsLocation.x !== -1) {
            control_top.x = PQCConstants.extraControlsLocation.x
            control_top.y = PQCConstants.extraControlsLocation.y
            control_top.manuallyDragged = true
        }
    }

    PQMouseArea {
        id: controlmouse
        anchors.fill: parent
        drag.minimumX: 5
        drag.minimumY: 5
        drag.maximumX: control_top.loaderTop.width-control_top.width-5
        drag.maximumY: control_top.loaderTop.height-control_top.height-5
        hoverEnabled: true
        text: qsTranslate("image", "Click and drag to move")
        cursorShape: Qt.SizeAllCursor
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        drag.target: parent
        drag.onActiveChanged: if(drag.active) control_top.manuallyDragged = true
        onWheel: {}
        onClicked: (mouse) => {
            if(mouse.button === Qt.RightButton)
                menu.popup()
        }
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
            source: control_top.videoPlaying ? ("image://svg/:/" + PQCLook.iconShade + "/pause.svg") : ("image://svg/:/" + PQCLook.iconShade + "/play.svg")
            sourceSize: Qt.size(width, height)
            PQMouseArea {
                id: playpausemouse
                anchors.fill: parent
                text: qsTranslate("image", "Click to play/pause")
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton|Qt.RightButton
                onClicked: (mouse) => {
                    if(mouse.button === Qt.LeftButton)
                        PQCNotify.playPauseAnimationVideo()
                    else
                        menu.popup()
                }
            }
        }

        PQText {
            id: curtime
            y: (parent.height-height)/2
            text: PQCScriptsImages.convertSecondsToPosition(control_top.videoPosition)
        }

        PQSlider {
            id: posslider
            y: (parent.height-height)/2
            // width: totaltime.x-curtime.x-curtime.width-20
            live: false
            from: 0
            to: control_top.videoDuration

            onPressedChanged: {
                if(!pressed) {
                    // console.warn(">>> position1():", value)
                    control_top.videoToPos(value)
                }
            }

            onPositionChanged: {
                // console.warn(">>> position2():", position*to, pressed, control_top.videoLoaded)
                if(pressed && control_top.videoLoaded) {
                    control_top.videoToPos(position*to)
                }
            }

        }

        PQText {
            id: totaltime
            y: (parent.height-height)/2
            text: PQCScriptsImages.convertSecondsToPosition(control_top.videoDuration)
        }

        Image {
            id: volumeicon
            y: parent.height*0.2
            height: parent.height*0.6
            width: height
            enabled: control_top.videoHasAudio
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
                enabled: control_top.videoHasAudio
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton|Qt.RightButton
                      //: The volume here is referring to SOUND volume
                text: qsTranslate("image", "Volume:") + " " +
                      PQCSettings.filetypesVideoVolume + "%<br>" +
                      qsTranslate("image", "Click to mute/unmute")
                onClicked: (mouse) => {
                    if(mouse.button === Qt.RightButton) {
                        menu.popup()
                        return
                    }
                    control_top.muteUnmute()
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
            height: control_top.height*0.75
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

            opacity: PQCSettings.filetypesVideoLeftRightJumpVideo ? 1 : 0.3
            Behavior on opacity { NumberAnimation { duration: 200 } }

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
                text: qsTranslate("image", "Lock left/right arrow keys to jumping forwards/backwards 5 seconds")
                onClicked: (mouse) => {
                    if(mouse.button === Qt.LeftButton)
                        PQCSettings.filetypesVideoLeftRightJumpVideo = !PQCSettings.filetypesVideoLeftRightJumpVideo
                    else
                        menu.popup()
                }
            }

        }

    }

    Image {
        x: parent.width-width+10
        y: -10
        width: 20
        height: 20
        sourceSize: Qt.size(width, height)
        source: control_top.controlsClosed ? ("image://svg/:/" + PQCLook.iconShade + "/thumbnail.svg") : ("image://svg/:/" + PQCLook.iconShade + "/close.svg")
        opacity: closemouse.containsMouse ? 1 : 0.1
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        PQMouseArea {
            id: closemouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            text: control_top.controlsClosed ?
                      qsTranslate("image", "Click to always show video controls") :
                      qsTranslate("image", "Click to hide video controls when video is playing")
            onClicked: control_top.controlsClosed = !control_top.controlsClosed
        }
    }

    // the reset position button is only visible when hovered
    Image {
        x: -10
        y: -10
        width: 20
        height: 20
        opacity: controlresetmouse.containsMouse ? 0.75 : 0
        Behavior on opacity { NumberAnimation { duration: 300 } }
        source: "image://svg/:/" + PQCLook.iconShade + "/reset.svg"
        sourceSize: Qt.size(width, height)
        PQMouseArea {
            id: controlresetmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            text: qsTranslate("image", "Reset position")
            onClicked: (mouse) => {
                control_top.manuallyDragged = false
                control_top.x = Qt.binding(function() { return (control_top.loaderTop.width-control_top.width)/2 })
                control_top.y = Qt.binding(function() { return (0.9*control_top.loaderTop.height) })
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

    PQMenu {
        id: menu

        property bool resetPosAfterHide: false

        PQMenuItem {
            iconSource: control_top.videoPlaying ? ("image://svg/:/" + PQCLook.iconShade + "/pause.svg") : ("image://svg/:/" + PQCLook.iconShade + "/play.svg")
            text: control_top.videoPlaying ? qsTranslate("image", "Pause video") : qsTranslate("image", "Play video")
            onTriggered: {
                PQCNotify.playPauseAnimationVideo()
            }
        }

        PQMenuItem {
            id: volmenuitem
            checkable: true
            checked: PQCSettings.filetypesVideoVolume===0
            keepOpenWhenCheckedChanges: false
            //: refers to muting sound
            text: qsTranslate("image", "Mute")
            onTriggered: {
                control_top.muteUnmute()
                checked = Qt.binding(function() { return PQCSettings.filetypesVideoVolume===0 })
                menu.dismiss()
            }
        }

        PQMenuItem {
            checkable: true
            checked: PQCSettings.filetypesVideoLeftRightJumpVideo
            keepOpenWhenCheckedChanges: false
            text: qsTranslate("image", "Arrow keys")
            onTriggered: {
                PQCSettings.filetypesVideoLeftRightJumpVideo = checked
                checked = Qt.binding(function() { return PQCSettings.filetypesVideoLeftRightJumpVideo })
                menu.dismiss()
            }
        }

        PQMenuSeparator {}

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/reset.svg"
            text: qsTranslate("image", "Reset position")
            onTriggered: {
                menu.resetPosAfterHide = true
            }
        }

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/close.svg"
            text: qsTranslate("image", "Hide controls")
            onTriggered:
                control_top.controlsClosed = false
        }

        onVisibleChanged: {
            if(!visible && resetPosAfterHide) {
                resetPosAfterHide = false
                control_top.manuallyDragged = false
                control_top.x = Qt.binding(function() { return (control_top.loaderTop.width-control_top.width)/2 })
                control_top.y = Qt.binding(function() { return (0.9*control_top.loaderTop.height) })
            }
        }

        onAboutToHide:
            recordAsClosed.restart()
        onAboutToShow:
            PQCConstants.addToWhichContextMenusOpen("videocontrols")

        Timer {
            id: recordAsClosed
            interval: 200
            onTriggered: {
                if(!menu.visible)
                    PQCConstants.removeFromWhichContextMenusOpen("videocontrols")
            }
        }
    }

    Connections {

        target: PQCNotify

        enabled: control_top.enabled

        function onCloseAllContextMenus() {
            menu.dismiss()
        }

    }

    property int backupVolume: -1
    property bool isMuted: (PQCSettings.filetypesVideoVolume===0)
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

