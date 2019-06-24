import QtQuick 2.9
import QtMultimedia 5.9
import "../../elements"

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

    Video {

        id: videoelem

        source: "file://" + src

        x: (parent.width-width)/2
        y: (parent.height-height)/2
        width: PQSettings.fitInWindow ? parent.width : (metaData.resolution ? Math.min(metaData.resolution.width, parent.width) : 0)
        height: PQSettings.fitInWindow ? parent.height : (metaData.resolution ? Math.min(metaData.resolution.height, parent.height) : 0)

        volume: PQSettings.videoVolume/100

        property int notifyIntervalSHORT: 20
        property int notifyIntervalLONG: 250

        notifyInterval: videoelem.duration>2*notifyIntervalLONG ? notifyIntervalLONG : notifyIntervalSHORT

        onStatusChanged: {
            theimage.imageStatus = (status==MediaPlayer.Loaded ? Image.Ready : Image.Loading)
            if(status == MediaPlayer.Loaded) {
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
        Behavior on rotation { NumberAnimation { id: rotationAni; duration: (PQSettings.animations ? PQSettings.animationDuration*150 : 0) } }
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

        MouseArea {
            id: videomouse
            enabled: PQSettings.leftButtonMouseClickAndMove
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

        Connections {
            target: variables
            onMousePosChanged: {
                if(videomouse.contains(Qt.point(variables.mousePos.x-videoelem.x, variables.mousePos.y-videoelem.y))) {
                    controls.mouseHasBeenMovedRecently = true
                    resetMouseHasBeenMovedRecently.restart()
                }
            }
        }

        Timer {
            id: resetMouseHasBeenMovedRecently
            interval: 1000
            repeat: false
            onTriggered:
                controls.mouseHasBeenMovedRecently = false
        }

        Rectangle {

            id: controls

            color: "#88444444"

            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: videoposslider.height

            property bool mouseHasBeenMovedRecently: false

            opacity: (videoelem.playbackState==MediaPlayer.PausedState || mouseHasBeenMovedRecently || volumecontrol_slider.manipulate) ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 250 } }

            Text {
                id: curpos
                anchors {
                    left: parent.left
                    leftMargin: 5
                }
                height: videoposslider.height
                verticalAlignment: Qt.AlignVCenter

                color: "white"
                text: handlingGeneral.convertSecsToProperTime(Math.round(videoelem.position/1000), Math.round(videoelem.duration/1000))
            }

            PQSlider {

                id: videoposslider

                anchors {
                    left: curpos.right
                    leftMargin: 5
                    right: timeleft.left
                    rightMargin: 5
                    bottom: parent.bottom
                }

                from: 0
                to: videoelem.duration
                value: videoelem.position
                onValueChanged: {
                    if(pressed)
                        videoelem.seek(value)
                }

            }

            Text {
                id: timeleft
                anchors {
                    right: volumecontrol.left
                    rightMargin: 10
                }
                height: videoposslider.height
                verticalAlignment: Qt.AlignVCenter

                color: "white"
                text: handlingGeneral.convertSecsToProperTime(Math.round((videoelem.duration-videoelem.position)/1000), Math.round(videoelem.duration/1000))
            }

            Item {

                id: volumecontrol

                anchors.right: parent.right
                anchors.rightMargin: 5

                y: 5
                height: videoposslider.height-10
                width: volumecontrol_image.width+volumecontrol_slider.width

                Image {

                    id: volumecontrol_image

                    anchors.right: volumecontrol_slider.left

                    source: volumecontrol_slider.value==0 ?
                                "/audio/speaker_mute.png" :
                                (volumecontrol_slider.value <= 40 ?
                                     "/audio/speaker_low.png" :
                                     (volumecontrol_slider.value <= 80 ?
                                          "/audio/speaker_medium.png" :
                                          "/audio/speaker_high.png"))

                    height: parent.height
                    width: height
                    sourceSize: Qt.size(height, height)

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if(volumecontrol_slider.manipulate)
                                volumecontrol_slider.value = (volumecontrol_slider.value==0 ? 100 : 0)
                            else
                                volumecontrol_slider.manipulate = true
                        }
                    }

                }

                PQSlider {

                    id: volumecontrol_slider

                    anchors.right: parent.right

                    property bool manipulate: false

                    from: 0
                    to: 100
                    value: PQSettings.videoVolume
                    onValueChanged:
                        PQSettings.videoVolume = value

                    y: (parent.height-height)/2
                    width: manipulate?150:0
                    Behavior on width { NumberAnimation { duration: 150 } }

                    visible: manipulate

                    Connections {
                        target: variables
                        onMousePosChanged: {
                            var loc = volumecontrol_slider.mapFromGlobal(variables.mousePos.x, variables.mousePos.y)
                            if(loc.x < 0 || loc.x > volumecontrol_slider.width ||
                               loc.y < 0 || loc.y > volumecontrol_slider.height)
                                volumecontrol_slider.manipulate = false
                        }
                    }

                }

            }

        }

    }

    Behavior on scale { NumberAnimation { id: scaleAni; duration: PQSettings.animations ? PQSettings.animationDuration*150 : 0 } }
    onScaleChanged:
        variables.currentZoomLevel = (videoelem.width/videoelem.metaData.resolution.width)*elem.scale*100

    Behavior on x { NumberAnimation { id: xAni; duration: PQSettings.animationDuration*150 } }
    Behavior on y { NumberAnimation { id: yAni; duration: PQSettings.animationDuration*150 } }

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
            xAni.duration = PQSettings.animationDuration*150
            yAni.duration = PQSettings.animationDuration*150
            if(!videoelem.scaleAdjustedFromRotation)
                elem.scale = 1
            elem.x = PQSettings.marginAroundImage
            elem.y = PQSettings.marginAroundImage
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


}
