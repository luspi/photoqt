/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
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
import QtMultimedia 5.9
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
        enabled: PQSettings.imageviewLeftButtonMoveImage
        anchors.fill: parent
        onPressed: {
            if(PQSettings.interfaceCloseOnEmptyBackground || PQSettings.interfaceNavigateOnEmptyBackground) {
                var paintedX = (container.width-videoelem.width)/2
                var paintedY = (container.height-videoelem.height)/2
                if(mouse.x < paintedX || mouse.x > paintedX+videoelem.width ||
                   mouse.y < paintedY || mouse.y > paintedY+videoelem.height) {
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
    Video {

        id: videoelem

        // Windows complains about missing '/' at the start, we need 3 (!) here for video files to play
        source: "file:///" + src

        x: (parent.width-width)/2
        y: (parent.height-height)/2
        width: PQSettings.imageviewFitInWindow ? parent.width : (metaData.resolution ? Math.min(metaData.resolution.width, parent.width) : 0)
        height: PQSettings.imageviewFitInWindow ? parent.height : (metaData.resolution ? Math.min(metaData.resolution.height, parent.height) : 0)

        volume: PQSettings.filetypesVideoVolume/100

        property int notifyIntervalSHORT: 20
        property int notifyIntervalLONG: 250

        notifyInterval: videoelem.duration>2*notifyIntervalLONG ? notifyIntervalLONG : notifyIntervalSHORT

        onStatusChanged: {
            deleg.imageStatus = ((status==MediaPlayer.Loaded||status==MediaPlayer.Buffered) ? Image.Ready : Image.Loading)
            if(status == MediaPlayer.Loaded) {
                container.currentVideoLength = videoelem.duration
                variables.currentZoomLevel = videoelem.scale*100
                variables.currentPaintedZoomLevel = videoelem.scale
                if(PQSettings.filetypesVideoAutoplay)
                    videoelem.play()
                else
                    videoelem.pause()
            }
        }

        property bool reachedEnd: (position > videoelem.duration-2*notifyInterval&&notifyInterval==notifyIntervalSHORT)

        onPositionChanged: {
            if(!PQSettings.filetypesVideoLoop) {
                if(position > videoelem.duration-2*notifyInterval) {
                    if(notifyInterval == notifyIntervalLONG) {
                        notifyInterval = notifyIntervalSHORT
                    } else if(notifyInterval == notifyIntervalSHORT) {
                        videoelem.pause()
                        notifyInterval = videoelem.duration>2*notifyIntervalLONG ? notifyIntervalLONG : notifyIntervalSHORT
                    }
                }
            }
        }

        onStopped: {
            if(PQSettings.filetypesVideoLoop)
                videoelem.play()
        }

        property bool scaleAdjustedFromRotation: false
        property int rotateTo: 0    // used to know where a rotation will end up before the animation has finished
        rotation: 0
        Behavior on rotation { RotationAnimation { id: rotationAni; duration: PQSettings.imageviewAnimationDuration*100 } }
        onRotateToChanged: {
            if(pincharea.pinch.active) return // if the update came from a pinch event, don't do anything here
            rotation = rotateTo
            if((rotateTo%180+180)%180 == 90 && elem.scale == 1) {
                var h = videoelem.height
                var w = Math.min(metaData.resolution.width, parent.width)
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
            variables.currentRotationAngle = videoelem.rotation

        Behavior on scale { NumberAnimation { id: scaleAni; duration: PQSettings.imageviewAnimationDuration*100 } }
        onScaleChanged:
            variables.currentZoomLevel = (videoelem.width/videoelem.metaData.resolution.width)*videoelem.scale*100

        PinchArea {

            id: pincharea

            anchors.fill: parent

            pinch.target: videoelem
            pinch.minimumRotation: -360
            pinch.maximumRotation: 360
            pinch.minimumScale: 0.1
            pinch.maximumScale: 10
            pinch.dragAxis: Pinch.XAndYAxis

            onPinchStarted:
                contextmenu.hideMenu()

            onPinchUpdated:
                videoelem.rotateTo = videoelem.rotation

            MouseArea {
                id: videomouse
                enabled: PQSettings.imageviewLeftButtonMoveImage&&!variables.slideShowActive
                anchors.fill: parent
                hoverEnabled: false // important, otherwise the mouse pos will not be caught globally!
                drag.target: PQSettings.imageviewLeftButtonMoveImage ? videoelem : undefined
                cursorShape: controls.mouseHasBeenMovedRecently ? Qt.ArrowCursor : Qt.BlankCursor

                onPressAndHold: {
                    variables.mousePos = mousearea.mapToItem(bgimage, Qt.point(mouse.x, mouse.y))
                    contextmenu.showMenu()
                }

                onClicked: {
                    contextmenu.hideMenu()
                    if(videoelem.playbackState == MediaPlayer.PlayingState)
                        videoelem.pause()
                    else {
                        if(videoelem.reachedEnd)
                            videoelem.seek(0)
                        videoelem.play()
                    }
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

            opacity: (!variables.slideShowActive && (videoelem.playbackState==MediaPlayer.PausedState || mouseHasBeenMovedRecently || volumecontrol_slider.manipulate)) ? 1 : 0
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

                    source: videoelem.playbackState==MediaPlayer.PlayingState ? "/multimedia/pause.png" : "/multimedia/play.png"

                    y: (controls.height-height)/2
                    height: controls.height/2
                    width: height
                    sourceSize: Qt.size(height, height)

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if(variables.slideShowActive)
                                return
                            if(videoelem.playbackState == MediaPlayer.PlayingState)
                                videoelem.pause()
                            else
                                videoelem.play()
                        }
                    }

                }

                Text {
                    id: curpos
                    y: (controls.height-height)/2
                    color: "white"
                    font.bold: true
                    text: handlingGeneral.convertSecsToProperTime(Math.round(videoelem.position/1000), Math.round(videoelem.duration/1000))
                }

                PQSlider {
                    id: videopos_slider
                    y: (controls.height-height)/2
                    width: controls.width - playpause.width - curpos.width - timeleft.width - volumecontrol.width - volumecontrol_slider.width - 80
                    from: 0
                    to: videoelem.duration
                    value: videoelem.position
                    divideToolTipValue: 1000
                    convertToolTipValueToTimeWithDuration: Math.round(videoelem.duration/1000)
                    overrideBackgroundHeight: 10
                    onValueChanged: {
                        if(pressed) {
                            controls.mouseHasBeenMovedRecently = true
                            resetMouseHasBeenMovedRecently.restart()
                            videoelem.seek(value)
                        }
                    }
                }

                Text {
                    id: timeleft
                    y: (controls.height-height)/2
                    color: "white"
                    font.bold: true
                    text: handlingGeneral.convertSecsToProperTime(Math.round((videoelem.duration-videoelem.position)/1000), Math.round(videoelem.duration/1000))
                }

                Image {

                    id: volumecontrol

                    source: volumecontrol_slider.value==0 ?
                                "/multimedia/speaker_mute.png" :
                                (volumecontrol_slider.value <= 40 ?
                                     "/multimedia/speaker_low.png" :
                                     (volumecontrol_slider.value <= 80 ?
                                          "/multimedia/speaker_medium.png" :
                                          "/multimedia/speaker_high.png"))

                    y: (controls.height-height)/2
                    height: 2*controls.height/3
                    width: height
                    sourceSize: Qt.size(height, height)

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
                    onValueChanged:
                        PQSettings.filetypesVideoVolume = value

                }

                Item {
                    width: 10
                    height: 1
                }

            }

        }

    }

    Connections {
        target: container
        onZoomIn: {
            videoelem.scale *= (1+PQSettings.imageviewZoomSpeed/100)
            videoelem.scaleAdjustedFromRotation = false
        }
        onZoomOut: {
            videoelem.scale /= (1+PQSettings.imageviewZoomSpeed/100)
            videoelem.scaleAdjustedFromRotation = false
        }
        onZoomReset: {
            xAni.duration = PQSettings.imageviewAnimationDuration*100
            yAni.duration = PQSettings.imageviewAnimationDuration*100
            if(!videoelem.scaleAdjustedFromRotation)
                videoelem.scale = 1
            videoelem.x = (elem.width-videoelem.width)/2
            videoelem.y = (elem.height-videoelem.height)/2
        }
        onZoomActual: {
            if(variables.currentZoomLevel != 100)
                videoelem.scale = 100/variables.currentZoomLevel
        }
        onRotate: {
            videoelem.rotateTo += deg
        }
        onRotateReset: {
            var old = videoelem.rotateTo%360
            if(old > 0) {
                if(old <= 180)
                    videoelem.rotateTo -= old
                else
                    videoelem.rotateTo += 360-old
            } else if(old < 0) {
                if(old >= -180)
                    videoelem.rotateTo -= old
                else
                    videoelem.rotateTo -= (old+360)
            }
        }
        onPlayPauseAnim: {
            if(videoelem.playbackState == MediaPlayer.PlayingState)
                videoelem.pause()
            else
                videoelem.play()
        }
        onPlayAnim: {
            videoelem.play()
        }
        onPauseAnim: {
            videoelem.pause()
        }
        onRestartAnim: {
            videoelem.seek(0)
        }
    }

    Connections {
        target: variables
        property bool pauseStateWhenElementOpens: false
        onVisibleItemChanged: {
            if(variables.visibleItem == "") {
                if(!pauseStateWhenElementOpens && videoelem.playbackState == MediaPlayer.PausedState)
                    videoelem.play()
            } else {
                pauseStateWhenElementOpens = (videoelem.playbackState != MediaPlayer.PlayingState)
                videoelem.pause()
            }
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
