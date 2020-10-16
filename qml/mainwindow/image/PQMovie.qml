import QtQuick 2.9
import QtMultimedia 5.9
import "../../elements"

// for better control on fillMode we embed it inside an item
Item {

    id: elem

    x: PQSettings.marginAroundImage
    y: PQSettings.marginAroundImage
    width: container.width-2*PQSettings.marginAroundImage
    height: container.height-2*PQSettings.marginAroundImage

    MouseArea {
        enabled: PQSettings.leftButtonMouseClickAndMove
        anchors.fill: parent
        onPressed: {
            if(PQSettings.closeOnEmptyBackground) {
                var paintedX = (container.width-videoelem.width)/2
                var paintedY = (container.height-videoelem.height)/2
                if(mouse.x < paintedX || mouse.x > paintedX+videoelem.width ||
                   mouse.y < paintedY || mouse.y > paintedY+videoelem.height)
                    toplevel.close()
            }
        }
    }

    // video element
    Video {

        id: videoelem

        source: "file://" + src

        x: (parent.width-width)/2
        y: (parent.height-height)/2
        width: PQSettings.fitInWindow ? parent.width : (metaData.resolution ? Math.min(metaData.resolution.width, parent.width) : 0)
        height: PQSettings.fitInWindow ? parent.height : (metaData.resolution ? Math.min(metaData.resolution.height, parent.height) : 0)

        Behavior on x { NumberAnimation { id: xAni; duration: PQSettings.animationDuration*100 } }
        Behavior on y { NumberAnimation { id: yAni; duration: PQSettings.animationDuration*100 } }

        volume: PQSettings.videoVolume/100

        property int notifyIntervalSHORT: 20
        property int notifyIntervalLONG: 250

        notifyInterval: videoelem.duration>2*notifyIntervalLONG ? notifyIntervalLONG : notifyIntervalSHORT

        onStatusChanged: {
            theimage.imageStatus = (status==MediaPlayer.Loaded ? Image.Ready : Image.Loading)
            if(status == MediaPlayer.Loaded) {
                variables.currentZoomLevel = videoelem.scale*100
                variables.currentPaintedZoomLevel = videoelem.scale
                if(PQSettings.videoAutoplay)
                    videoelem.play()
                else
                    videoelem.pause()
            }
        }

        property bool reachedEnd: (position > videoelem.duration-2*notifyInterval&&notifyInterval==notifyIntervalSHORT)

        onPositionChanged: {
            if(!PQSettings.videoLoop) {
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
            if(PQSettings.videoLoop)
                videoelem.play()
        }

        property bool scaleAdjustedFromRotation: false
        property int rotateTo: 0    // used to know where a rotation will end up before the animation has finished
        rotation: rotateTo
        Behavior on rotation { NumberAnimation { id: rotationAni; duration: PQSettings.animationDuration*100 } }
        onRotateToChanged: {
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

        PinchArea {

            anchors.fill: parent

            pinch.target: videoelem
            pinch.minimumRotation: -360
            pinch.maximumRotation: 360
            pinch.minimumScale: 0.1
            pinch.maximumScale: 10
            pinch.dragAxis: Pinch.XAndYAxis

            MouseArea {
                id: videomouse
                enabled: PQSettings.leftButtonMouseClickAndMove&&!variables.slideShowActive
                anchors.fill: parent
                hoverEnabled: false // important, otherwise the mouse pos will not be caught globally!
                drag.target: PQSettings.leftButtonMouseClickAndMove ? videoelem : undefined
                onClicked: {
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

            opacity: (videoelem.playbackState==MediaPlayer.PausedState || mouseHasBeenMovedRecently || volumecontrol_slider.manipulate) ? 1 : 0
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
                    value: PQSettings.videoVolume
                    onValueChanged:
                        PQSettings.videoVolume = value

                }

                Item {
                    width: 10
                    height: 1
                }

            }

        }

    }

    Behavior on scale { NumberAnimation { id: scaleAni; duration: PQSettings.animationDuration*100 } }
    onScaleChanged:
        variables.currentZoomLevel = (videoelem.width/videoelem.metaData.resolution.width)*elem.scale*100

    Connections {
        target: container
        onZoomIn: {
            elem.scale *= (1+PQSettings.zoomSpeed/100)
            videoelem.scaleAdjustedFromRotation = false
        }
        onZoomOut: {
            elem.scale /= (1+PQSettings.zoomSpeed/100)
            videoelem.scaleAdjustedFromRotation = false
        }
        onZoomReset: {
            xAni.duration = PQSettings.animationDuration*100
            yAni.duration = PQSettings.animationDuration*100
            if(!videoelem.scaleAdjustedFromRotation)
                elem.scale = 1
            videoelem.x = (elem.width-videoelem.width)/2
            videoelem.y = (elem.height-videoelem.height)/2
        }
        onZoomActual: {
            if(variables.currentZoomLevel != 100)
                elem.scale = 100/variables.currentZoomLevel
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
    }

    function restorePosZoomRotationMirror() {
        if(PQSettings.keepZoomRotationMirror && src in variables.zoomRotationMirror) {

            elem.x = variables.zoomRotationMirror[src][0].x
            elem.y = variables.zoomRotationMirror[src][0].y

            elem.scale = variables.zoomRotationMirror[src][1]
            elem.rotation = variables.zoomRotationMirror[src][2]
            elem.mirror = variables.zoomRotationMirror[src][3]

        }
    }


}
