import QtQuick 2.9

Image {

    id: elem

    source: "image://full/" + src

    x: PQSettings.marginAroundImage
    y: PQSettings.marginAroundImage
    width: container.width-2*PQSettings.marginAroundImage
    height: container.height-2*PQSettings.marginAroundImage

    // set this as default
    // this way larger images will not be reloaded when adjusting fillMode while smaller images will (might) be.
    // As smaller images are very quick to load, especially from cache, this is acceptable.
    // Note: The reason for all this is because a change in fillMode triggers a reload of the image
    fillMode: Image.PreserveAspectFit

    onStatusChanged: {
        theimage.imageStatus = status
        if(status == Image.Ready) {
            variables.currentZoomLevel = (elem.paintedWidth/elem.sourceSize.width)*elem.scale*100
            variables.currentPaintedZoomLevel = elem.scale

            // update fillmode (if change necessary)
            if(sourceSize.width < width && sourceSize.height < height && !PQSettings.fitInWindow && fillMode != Image.Pad) {
                fillMode = Image.Pad
            } else if((sourceSize.width >= width || sourceSize.height >= height || PQSettings.fitInWindow) && fillMode != Image.PreserveAspectFit) {
                fillMode = Image.PreserveAspectFit
            }

        }
    }

    Behavior on scale { NumberAnimation { id: scaleAni; duration: PQSettings.animationDuration*100 } }
    onScaleChanged: {
        variables.currentZoomLevel = (elem.paintedWidth/elem.sourceSize.width)*elem.scale*100
        variables.currentPaintedZoomLevel = elem.scale
    }

    Behavior on x { NumberAnimation { id: xAni; duration: PQSettings.animationDuration*100 } }
    Behavior on y { NumberAnimation { id: yAni; duration: PQSettings.animationDuration*100 } }

    asynchronous: true
    cache: false
    antialiasing: true
    smooth: (PQSettings.interpolationNearestNeighbourUpscale &&
             elem.paintedWidth<=PQSettings.interpolationNearestNeighbourThreshold &&
             elem.paintedHeight<=PQSettings.interpolationNearestNeighbourThreshold) ? false : true
    mipmap: (PQSettings.interpolationNearestNeighbourUpscale &&
             elem.paintedWidth<=PQSettings.interpolationNearestNeighbourThreshold &&
             elem.paintedHeight<=PQSettings.interpolationNearestNeighbourThreshold) ? false : true

    property bool scaleAdjustedFromRotation: false
    property int rotateTo: 0    // used to know where a rotation will end up before the animation has finished
    rotation: rotateTo
    Behavior on rotation { NumberAnimation { id: rotationAni; duration: PQSettings.animationDuration*100 } }
    onRotateToChanged: {
        if((rotateTo%180+180)%180 == 90 && elem.scale == 1) {
            elem.scale = Math.min(elem.height/elem.paintedWidth, 1)
            scaleAdjustedFromRotation = true
        } else if(scaleAdjustedFromRotation) {
            elem.scale = 1
            scaleAdjustedFromRotation = false
        }
    }

    Image {
        width: parent.paintedWidth
        height: parent.paintedHeight
        x: (parent.width-width)/2
        y: (parent.height-height)/2
        z: -1
        fillMode: Image.Tile
        visible: PQSettings.showTransparencyMarkerBackground
        source: PQSettings.showTransparencyMarkerBackground ? "/image/transparent.png" : ""
    }

    MouseArea {
        enabled: PQSettings.leftButtonMouseClickAndMove&&!facetagger.visible&&!variables.slideShowActive
        anchors.fill: parent
        drag.target: parent
        onPressed: {
            if(PQSettings.closeOnEmptyBackground) {
                var paintedX = (container.width-elem.paintedWidth)/2
                var paintedY = (container.height-elem.paintedHeight)/2
                if(mouse.x < paintedX || mouse.x > paintedX+elem.paintedWidth ||
                   mouse.y < paintedY || mouse.y > paintedY+elem.paintedHeight)
                    toplevel.close()
            }
        }
    }

    PQFaceTracker {
        id: facetracker
        x: (elem.width-width)/2
        width: elem.paintedWidth
        height: elem.paintedHeight
        y: (elem.height-height)/2
        filename: src
        visible: !facetagger.visible
        Connections {
            target: facetagger
            onHasBeenUpdated:
                facetracker.updateData()
        }
    }

    PQFaceTagger {
        id: facetagger
        x: (elem.width-width)/2
        width: elem.paintedWidth
        height: elem.paintedHeight
        y: (elem.height-height)/2
        filename: src
    }

    Connections {
        target: container
        onZoomIn: {
            elem.scale *= (1+PQSettings.zoomSpeed/100)
            scaleAdjustedFromRotation = false
        }
        onZoomOut: {
            elem.scale /= (1+PQSettings.zoomSpeed/100)
            scaleAdjustedFromRotation = false
        }
        onZoomReset: {
            xAni.duration = PQSettings.animationDuration*100
            yAni.duration = PQSettings.animationDuration*100
            if(!scaleAdjustedFromRotation)
                elem.scale = 1
            elem.x = PQSettings.marginAroundImage
            elem.y = PQSettings.marginAroundImage
        }
        onZoomActual: {
            if(variables.currentZoomLevel != 100)
                elem.scale = 100/variables.currentZoomLevel
        }
        onRotate: {
            elem.rotateTo += deg
        }
        onRotateReset: {
            var old = elem.rotateTo%360
            if(old > 0) {
                if(old <= 180)
                    elem.rotateTo -= old
                else
                    elem.rotateTo += 360-old
            } else if(old < 0) {
                if(old >= -180)
                    elem.rotateTo -= old
                else
                    elem.rotateTo -= (old+360)
            }
        }
        onMirrorH: {
            var old = elem.mirror
            elem.mirror = !old
        }
        onMirrorV: {
            var old = elem.mirror
            elem.mirror = !old
            rotationAni.duration = 0
            elem.rotateTo += 180
            rotationAni.duration = PQSettings.animationDuration*100
        }
        onMirrorReset: {
            elem.mirror = false
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
