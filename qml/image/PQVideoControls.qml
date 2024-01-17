import QtQuick

import PQCScriptsImages

import "../elements"

Rectangle {

    id: controls_top

    x: (parent.width-width)/2
    y: Math.min(parent.height-height-10, parent.height*0.9)
    width: Math.min(600, parent.width-50)
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

    Image {
        x: -width/2
        y: -height/2
        width: 25
        height: 25
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

    Image {
        id: playpause
        x: 10
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
        x: playpause.x+playpause.width+10
        y: (parent.height-height)/2
        text: PQCScriptsImages.convertSecondsToPosition(loader_component.videoPosition)
    }

    PQSlider {
        id: posslider
        x: curtime.x+curtime.width+10
        y: (parent.height-height)/2
        width: totaltime.x-curtime.x-curtime.width-20
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
        x: volumeicon.x-totaltime.width-10
        y: (parent.height-height)/2
        text: PQCScriptsImages.convertSecondsToPosition(loader_component.videoDuration)
    }

    Image {
        id: volumeicon
        x: parent.width-width-10
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
