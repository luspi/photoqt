import QtQuick 2.9

Image {

    id: elem

    source: "image://full/" + src

    x: PQSettings.marginAroundImage
    y: PQSettings.marginAroundImage
    width: container.width-2*PQSettings.marginAroundImage
    height: container.height-2*PQSettings.marginAroundImage

    fillMode: ((sourceSize.width<width&&sourceSize.height<height&&!PQSettings.fitInWindow) ? Image.Pad : Image.PreserveAspectFit)

    onStatusChanged: {
        theimage.imageStatus = status
        if(status == Image.Ready)
            variables.currentZoomLevel = (elem.paintedWidth/elem.sourceSize.width)*elem.scale*100
    }

    Behavior on scale { NumberAnimation { id: scaleAni; duration: PQSettings.animations ? PQSettings.animationDuration*150 : 0 } }
    onScaleChanged:
        variables.currentZoomLevel = (elem.paintedWidth/elem.sourceSize.width)*elem.scale*100

    Behavior on x { NumberAnimation { id: xAni; duration: PQSettings.animationDuration*150 } }
    Behavior on y { NumberAnimation { id: yAni; duration: PQSettings.animationDuration*150 } }

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
    Behavior on rotation { NumberAnimation { id: rotationAni; duration: (PQSettings.animations ? PQSettings.animationDuration*150 : 0) } }
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
        enabled: PQSettings.leftButtonMouseClickAndMove
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
            xAni.duration = PQSettings.animationDuration*150
            yAni.duration = PQSettings.animationDuration*150
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
            if(PQSettings.animations)
                rotationAni.duration = PQSettings.animationDuration*150
        }
        onMirrorReset: {
            elem.mirror = false
        }
    }

}
