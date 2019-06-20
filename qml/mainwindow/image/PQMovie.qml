import QtQuick 2.9
import QtMultimedia 5.9

Item {

    id: elem

    x: PQSettings.marginAroundImage
    y: PQSettings.marginAroundImage
    width: container.width-2*PQSettings.marginAroundImage
    height: container.height-2*PQSettings.marginAroundImage

    Video {

        id: videoelem

        source: "file://" + src

        x: (parent.width-width)/2
        y: (parent.height-height)/2
        width: PQSettings.fitInWindow ? parent.width : (metaData.resolution ? Math.min(metaData.resolution.width, parent.width) : 0)
        height: PQSettings.fitInWindow ? parent.height : (metaData.resolution ? Math.min(metaData.resolution.height, parent.height) : 0)

        notifyInterval: videoelem.duration>2000 ? 1000 : 50

        onStatusChanged: {
            theimage.imageStatus = (status==MediaPlayer.Loaded ? Image.Ready : Image.Loading)
            if(status == MediaPlayer.Loaded) {
                if(PQSettings.videoAutoplay)
                    videoelem.play()
                else
                    videoelem.pause()
            }
        }

        property bool reachedEnd: (position > videoelem.duration-2*notifyInterval&&notifyInterval==50)

        onPositionChanged: {
            if(!PQSettings.videoLoop) {
                if(position > videoelem.duration-2*notifyInterval) {
                    if(notifyInterval == 1000) {
                        notifyInterval = 50
                    } else if(notifyInterval == 50) {
                        videoelem.pause()
                        notifyInterval = videoelem.duration>2000 ? 1000 : 50
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
                elem.scale = Math.min(h/w, 1)
                scaleAdjustedFromRotation = true
            } else if(scaleAdjustedFromRotation) {
                elem.scale = 1
                scaleAdjustedFromRotation = false
            }
        }

    }

    Behavior on scale { NumberAnimation { id: scaleAni; duration: PQSettings.animations ? PQSettings.animationDuration*150 : 0 } }
    onScaleChanged:
        variables.currentZoomLevel = (videoelem.width/videoelem.metaData.resolution.width)*elem.scale*100

    Behavior on x { NumberAnimation { id: xAni; duration: PQSettings.animationDuration*150 } }
    Behavior on y { NumberAnimation { id: yAni; duration: PQSettings.animationDuration*150 } }

    MouseArea {
        enabled: PQSettings.leftButtonMouseClickAndMove
        anchors.fill: parent
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
