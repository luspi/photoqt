/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

import QtQuick 2.9
import PQMPVObject 1.0
import "../../elements"

// for better control on fillMode we embed it inside an item
Item {

    id: elem

    x: 0 // offset taking care of in container
    y: PQSettings.imageviewMargin
    width: container.width-2*PQSettings.imageviewMargin
    height: container.height-2*PQSettings.imageviewMargin

    Behavior on x { NumberAnimation { id: xAni; duration: PQSettings.imageviewAnimationDuration*100 } }
    Behavior on y { NumberAnimation { id: yAni; duration: PQSettings.imageviewAnimationDuration*100 } }

    MouseArea {
        anchors.fill: parent
        onPressed: {
            if(PQSettings.interfaceCloseOnEmptyBackground || PQSettings.interfaceNavigateOnEmptyBackground) {
                var paintedX = (container.width-renderer.width)/2
                var paintedY = (container.height-renderer.height)/2
                if(mouse.x < paintedX || mouse.x > paintedX+renderer.width ||
                   mouse.y < paintedY || mouse.y > paintedY+renderer.height) {
                    if(PQSettings.interfaceCloseOnEmptyBackground)
                        toplevel.close()
                    else if(PQSettings.interfaceNavigateOnEmptyBackground) {
                        if(mouse.x < width/2)
                            imageitem.loadPrevImage()
                        else
                            imageitem.loadNextImage()
                    }
                }
            }
        }
    }

    // video element
    PQMPVObject {

        id: renderer

        x: (parent.width-width)/2
        y: (parent.height-height)/2
        width: Math.min(mediaInfoWidth, parent.width)
        height: Math.min(mediaInfoHeight, parent.height)

        // this is set to true after 100ms after calling loadFile
        visible: false

        property bool playing: true

        property real currentPosition: 0
        property int volume: PQSettings.filetypesVideoVolume

        property int mediaInfoWidth: 100
        property int mediaInfoHeight: 100
        property real mediaInfoDuration: 0

        property bool scaleAdjustedFromRotation: false
        property int rotateTo: 0    // used to know where a rotation will end up before the animation has finished
        rotation: 0
        Behavior on rotation { RotationAnimation { id: rotationAni; duration: PQSettings.imageviewAnimationDuration*100 } }
        onRotateToChanged: {
            if(pincharea.pinch.active) return // if the update came from a pinch event, don't do anything here
            rotation = rotateTo
            if((rotateTo%180+180)%180 == 90 && elem.scale == 1) {
                var h = renderer.height
                var w = Math.min(mediaInfoWidth, parent.width)
                if(w > elem.height) {
                    elem.scale = Math.min(h/w, 1)
                    scaleAdjustedFromRotation = true
                }
            } else if(scaleAdjustedFromRotation) {
                elem.scale = 1
                scaleAdjustedFromRotation = false
            }
        }
        onRotationChanged:
            variables.currentRotationAngle = renderer.rotation

        Behavior on scale { NumberAnimation { id: scaleAni; duration: PQSettings.imageviewAnimationDuration*100 } }
        onScaleChanged:
            variables.currentZoomLevel = (renderer.width/renderer.mediaInfoWidth)*renderer.scale*100

        PinchArea {

            id: pincharea

            anchors.fill: parent

            pinch.target: renderer
            pinch.minimumRotation: -360
            pinch.maximumRotation: 360
            pinch.minimumScale: 0.1
            pinch.maximumScale: 10
            pinch.dragAxis: Pinch.XAndYAxis

            onPinchStarted:
                contextmenu.hideMenu()

            onPinchUpdated:
                renderer.rotateTo = renderer.rotation

            MouseArea {
                id: videomouse
                enabled: !variables.slideShowActive
                anchors.fill: parent
                hoverEnabled: false // important, otherwise the mouse pos will not be caught globally!
                drag.target: renderer
                cursorShape: controls.mouseHasBeenMovedRecently ? Qt.ArrowCursor : Qt.BlankCursor

                onPressAndHold: {
                    variables.mousePos = mousearea.mapToItem(bgimage, Qt.point(mouse.x, mouse.y))
                    contextmenu.showMenu()
                }

                onClicked: {
                    contextmenu.hideMenu()
                    renderer.command(["cycle", "pause"])
                    renderer.playing = !renderer.playing
                }
            }

        }

        Component.onCompleted: {
            volume = PQSettings.filetypesVideoVolume
            renderer.setProperty("volume", volume)
            cont.parent.imageDimensions = Qt.size(-1,-1)
        }

    }

    Timer {
        id: delayLoad
        interval: 100
        running: true
        repeat: false
        onTriggered: {
            renderer.command(["loadfile", src])
            getProps.start()
        }
    }

    Timer {
        id: getProps
        interval: 100
        repeat: false
        running: false
        onTriggered: {
            if(!PQSettings.filetypesVideoAutoplay) {
                renderer.playing = false
                renderer.command(["cycle", "pause"])
            }
            renderer.mediaInfoWidth = renderer.getProperty("width")
            renderer.mediaInfoHeight = renderer.getProperty("height")
            renderer.mediaInfoDuration = renderer.getProperty("duration")
            renderer.visible = true
            deleg.imageStatus = Image.Ready

        }
    }

    Timer {
        id: getPropsConfirm
        interval: 1000
        repeat: false
        running: false
        onTriggered: {
            renderer.mediaInfoWidth = renderer.getProperty("width")
            renderer.mediaInfoHeight = renderer.getProperty("height")
            renderer.mediaInfoDuration = renderer.getProperty("duration")
        }
    }

    Timer {
        id: getPosition
        interval: 500
        repeat: true
        running: true
        property bool restarting: false
        onTriggered: {
            PQSettings.filetypesVideoVolume = renderer.getProperty("volume")
            renderer.playing = !renderer.getProperty("core-idle")
            if(renderer.getProperty("eof-reached")) {
                if(PQSettings.filetypesVideoLoop && !restarting) {
                    renderer.command(["loadfile", src])
                    restarting = true
                }
            } else {
                renderer.currentPosition = renderer.getProperty("time-pos")
                restarting = false
            }

        }
    }

    Connections {
        target: variables
        onMousePosChanged: {
            controls.mouseHasBeenMovedRecently = true
            resetMouseHasBeenMovedRecently.restart()
        }
    }

    Timer {
        id: resetMouseHasBeenMovedRecently
        interval: 2000
        repeat: false
        onTriggered:
            controls.mouseHasBeenMovedRecently = false
    }

    Rectangle {

        id: controls

        parent: container

        color: "#ee000000"

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 50

        property bool mouseHasBeenMovedRecently: false

        opacity: (!variables.slideShowActive && (!renderer.playing || mouseHasBeenMovedRecently || volumecontrol_slider.manipulate)) ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 250 } }

        onOpacityChanged: {
            variables.videoControlsVisible = opacity>0
        }

        Row {

            spacing: 10

            Item {
                width: 10
                height: 1
            }

            Image {

                id: playpause

                source: renderer.playing ? "/multimedia/pause.svg" : "/multimedia/play.svg"

                y: (controls.height-height)/2
                height: controls.height/2
                width: height
                sourceSize: Qt.size(width, height)

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if(variables.slideShowActive)
                            return
                        renderer.command(["cycle", "pause"])
                        renderer.playing = !renderer.playing
                    }
                }

            }

            PQText {
                id: curpos
                y: (controls.height-height)/2
                font.bold: true
                text: handlingGeneral.convertSecsToProperTime(Math.round(renderer.currentPosition), Math.round(renderer.mediaInfoDuration))
            }

            PQSlider {
                id: videopos_slider
                y: (controls.height-height)/2
                width: controls.width - playpause.width - curpos.width - timeleft.width - volumecontrol.width - volumecontrol_slider.width - 80
                from: 0
                stepSize: 0.1
                to: renderer.mediaInfoDuration
                value: renderer.currentPosition
                divideToolTipValue: 1000
                convertToolTipValueToTimeWithDuration: Math.round(renderer.mediaInfoDuration/1000)
                overrideBackgroundHeight: 10
                onValueChanged: {
                    if(pressed) {
                        sliderAni.duration = 0
                        controls.mouseHasBeenMovedRecently = true
                        resetMouseHasBeenMovedRecently.restart()
                        if(renderer.getProperty("eof-reached"))
                            renderer.command(["loadfile", src])
                        renderer.command(["seek", value, "absolute"])
                        videopos_slider.value = value
                        sliderAni.duration = Qt.binding(function() { return getPosition.interval })
                        resetPropBinding.start()
                    }
                }
                Timer {
                    id: resetPropBinding
                    interval: 250
                    repeat: false
                    running: false
                    onTriggered:
                        videopos_slider.value = Qt.binding(function() { return renderer.currentPosition })
                }

                Behavior on value { NumberAnimation { id: sliderAni; duration: getPosition.interval } }
            }

            PQText {
                id: timeleft
                y: (controls.height-height)/2
                font.bold: true
                text: handlingGeneral.convertSecsToProperTime(Math.round((renderer.mediaInfoDuration-renderer.currentPosition)), Math.round(renderer.mediaInfoDuration))
            }

            Image {

                id: volumecontrol

                source: volumecontrol_slider.value==0 ?
                            "/multimedia/speaker_mute.svg" :
                            (volumecontrol_slider.value <= 40 ?
                                 "/multimedia/speaker_low.svg" :
                                 (volumecontrol_slider.value <= 80 ?
                                      "/multimedia/speaker_medium.svg" :
                                      "/multimedia/speaker_high.svg"))

                y: (controls.height-height)/2
                height: 2*controls.height/3
                width: height
                sourceSize: Qt.size(width, height)

                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    tooltip: volumecontrol_slider.value + "%"
                    onClicked: {
                        var tmp = volumecontrol_slider.manipulate
                        volumecontrol_slider.manipulate = !tmp
                    }
                }

            }

            PQSlider {

                id: volumecontrol_slider

                y: (controls.height-height)/2
                width: manipulate ? 150 : 0

                Behavior on width { NumberAnimation { duration: 150 } }

                visible: width>0

                property bool manipulate: false

                toolTipSuffix: "%"

                from: 0
                to: 100
                value: PQSettings.filetypesVideoVolume
                onValueChanged: {
                    renderer.setProperty("volume", value)
                    PQSettings.filetypesVideoVolume = value
                }

            }

            Item {
                width: 10
                height: 1
            }

        }

    }

    Connections {
        target: container
        onZoomIn: {
            renderer.scale *= (1+PQSettings.imageviewZoomSpeed/100)
            renderer.scaleAdjustedFromRotation = false
        }
        onZoomOut: {
            renderer.scale /= (1+PQSettings.imageviewZoomSpeed/100)
            renderer.scaleAdjustedFromRotation = false
        }
        onZoomReset: {
            xAni.duration = PQSettings.imageviewAnimationDuration*100
            yAni.duration = PQSettings.imageviewAnimationDuration*100
            if(!renderer.scaleAdjustedFromRotation)
                renderer.scale = 1
            renderer.x = (elem.width-renderer.width)/2
            renderer.y = (elem.height-renderer.height)/2
        }
        onZoomActual: {
            if(variables.currentZoomLevel != 100)
                renderer.scale = 100/variables.currentZoomLevel
        }
        onRotate: {
            renderer.rotateTo += deg
        }
        onRotateReset: {
            var old = renderer.rotateTo%360
            if(old > 0) {
                if(old <= 180)
                    renderer.rotateTo -= old
                else
                    renderer.rotateTo += 360-old
            } else if(old < 0) {
                if(old >= -180)
                    renderer.rotateTo -= old
                else
                    renderer.rotateTo -= (old+360)
            }
        }
        onPlayPauseAnim: {
            renderer.command(["cycle", "pause"])
            renderer.playing = !renderer.playing
        }
        onPlayAnim: {
            if(!renderer.playing) {
                renderer.command(["cycle", "pause"])
                renderer.playing = !renderer.playing
            }
        }
        onPauseAnim: {
            if(renderer.playing) {
                renderer.command(["cycle", "pause"])
                renderer.playing = !renderer.playing
            }
        }
        onRestartAnim: {
            if(renderer.getProperty("eof-reached"))
                renderer.command(["loadfile", src])
            else
                renderer.command(["seek", "0", "absolute"])
        }
    }

    function restorePosZoomRotationMirror() {
        if(PQSettings.imageviewRememberZoomRotationMirror && src in variables.zoomRotationMirror) {

            elem.x = variables.zoomRotationMirror[src][0].x
            elem.y = variables.zoomRotationMirror[src][0].y

            elem.scale = variables.zoomRotationMirror[src][1]
            elem.rotation = variables.zoomRotationMirror[src][2]
            elem.mirror = variables.zoomRotationMirror[src][3]

        }
    }

    function storePosRotZoomMirror() {

        variables.zoomRotationMirror[src] = [Qt.point(elem.x, elem.y), elem.rotation, elem.scale, elem.mirror]

    }


}
