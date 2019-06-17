import QtQuick 2.9

Image {

    id: elem

    source: "image://full/" + src

    asynchronous: true
    sourceSize: undefined
    cache: false

    fillMode: ((sourceSize.width<width&&sourceSize.height<height&&!PQSettings.fitInWindow) ? Image.Pad : Image.PreserveAspectFit)

    Behavior on scale { NumberAnimation { id: scaleAni; duration: PQSettings.animations ? PQSettings.animationDuration*150 : 0 } }
    onScaleChanged: {
        variables.currentZoomLevel = (elem.paintedWidth/elem.sourceSize.width)*elem.scale*100
        container.imageScale = elem.scale
    }

    Behavior on x { NumberAnimation { id: xAni; duration: PQSettings.animationDuration*150 } }
    Behavior on y { NumberAnimation { id: yAni; duration: PQSettings.animationDuration*150 } }
    x: PQSettings.marginAroundImage
    y: PQSettings.marginAroundImage
    width: container.width-2*PQSettings.marginAroundImage
    height: container.height-2*PQSettings.marginAroundImage

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

    antialiasing: true
    smooth: (PQSettings.interpolationNearestNeighbourUpscale &&
             elem.paintedWidth<=PQSettings.interpolationNearestNeighbourThreshold &&
             elem.paintedHeight<=PQSettings.interpolationNearestNeighbourThreshold) ? false : true
    mipmap: (PQSettings.interpolationNearestNeighbourUpscale &&
             elem.paintedWidth<=PQSettings.interpolationNearestNeighbourThreshold &&
             elem.paintedHeight<=PQSettings.interpolationNearestNeighbourThreshold) ? false : true

    opacity: 0
    Component.onCompleted: {
        if(status == Image.Ready)
            showItem()
        else
            creationCheckStatus.start()
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

    Timer {
        id: creationCheckStatus
        interval: 50
        repeat: true
        onTriggered: {
            if(parent.status == Image.Ready) {
                showItem()
                creationCheckStatus.stop()
            }
        }
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

    function showItem() {

        imageitem.hideOldImage(forwards)

        variables.currentZoomLevel = (elem.paintedWidth/elem.sourceSize.width)*elem.scale*100

        // figure out at which x/y/scale/etc to show item
        var toX = PQSettings.marginAroundImage
        var toY = PQSettings.marginAroundImage
        if(src in container.keepZoomRotationMirrorValues && PQSettings.keepZoomRotationMirror) {
            toX = container.keepZoomRotationMirrorValues[src][0]
            toY = container.keepZoomRotationMirrorValues[src][1]
            scaleAni.duration = 0
            rotationAni.duration = 0
            elem.scale = container.keepZoomRotationMirrorValues[src][2]
            elem.rotateTo = container.keepZoomRotationMirrorValues[src][3]
            elem.mirror = container.keepZoomRotationMirrorValues[src][4]
            if(PQSettings.animations) {
                scaleAni.duration = PQSettings.animationDuration*150
                rotationAni.duration = PQSettings.animationDuration*150
            }
        }
        if(forwards) {
            // show in x direction
            if(PQSettings.animationType == "x") {
                hideShowAni.from = container.width
                hideShowAni.to = toX
                hideShowAni.deleteWhenDone = false
                hideShowAni.property = "x"
                hideShowAni.start()
                elem.y = toY
            // show in y direction
            } else if(PQSettings.animationType == "y") {
                hideShowAni.from = container.height
                hideShowAni.to = toY
                hideShowAni.deleteWhenDone = false
                hideShowAni.property = "y"
                hideShowAni.start()
                elem.x = toX
            // fade in image
            } else {
                hideShowAni.from = 0
                hideShowAni.to = 1
                hideShowAni.deleteWhenDone = false
                hideShowAni.property = "opacity"
                hideShowAni.start()
                elem.x = toX
                elem.y = toY
            }
        } else {
            // show in x direction
            if(PQSettings.animationType == "x") {
                hideShowAni.from = -elem.width
                hideShowAni.to = toX
                hideShowAni.deleteWhenDone = false
                hideShowAni.property = "x"
                hideShowAni.start()
                elem.y = toY
            // show in y direction
            } else if(PQSettings.animationType == "y") {
                hideShowAni.from = -elem.height
                hideShowAni.to = toY
                hideShowAni.deleteWhenDone = false
                hideShowAni.property = "y"
                hideShowAni.start()
                elem.x = toX
            // fade in image
            } else {
                hideShowAni.from = 0
                hideShowAni.to = 1
                hideShowAni.deleteWhenDone = false
                hideShowAni.property = "opacity"
                hideShowAni.start()
                elem.x = toX
                elem.y = toY
            }
        }
        update()
    }

    function hideItem() {
        // store info about item
        container.keepZoomRotationMirrorValues[src] = [elem.x, elem.y, elem.scale, elem.rotation, elem.mirror]
        if(forwards) {
            // hide in x direction
            if(PQSettings.animationType == "x") {
                hideShowAni.from = elem.x
                hideShowAni.to = -elem.width
                hideShowAni.deleteWhenDone = true
                hideShowAni.property = "x"
                hideShowAni.start()
            // hide in y direction
            } else if(PQSettings.animationType == "y") {
                hideShowAni.from = elem.y
                hideShowAni.to = -elem.height
                hideShowAni.deleteWhenDone = true
                hideShowAni.property = "y"
                hideShowAni.start()
            // fade out image
            } else {
                hideShowAni.from = elem.opacity
                hideShowAni.to = 0
                hideShowAni.deleteWhenDone = true
                hideShowAni.property = "opacity"
                hideShowAni.start()
            }
        } else {
            // hide in x direction
            if(PQSettings.animationType == "x") {
                hideShowAni.from = elem.x
                hideShowAni.to = container.width
                hideShowAni.deleteWhenDone = true
                hideShowAni.property = "x"
                hideShowAni.start()
            // hide in y direction
            } else if(PQSettings.animationType == "y") {
                hideShowAni.from = elem.y
                hideShowAni.to = container.height
                hideShowAni.deleteWhenDone = true
                hideShowAni.property = "y"
                hideShowAni.start()
            // fade out image
            } else {
                hideShowAni.from = elem.opacity
                hideShowAni.to = 0
                hideShowAni.deleteWhenDone = true
                hideShowAni.property = "opacity"
                hideShowAni.start()
            }
        }
    }

    onStatusChanged:
        theimage.imageStatus = status

    PropertyAnimation {
        id: hideShowAni
        target: elem
        property: opacity
        duration: (PQSettings.animations ? PQSettings.animationDuration*150 : 0)
        property bool deleteWhenDone: false
        property bool startToHideWhenDone: false
        onStarted:
            elem.opacity = 1
        onStopped: {
            if(deleteWhenDone) {
                image_model.remove(index)
                deleteWhenDone = false
            } else if(startToHideWhenDone) {
                startToHideWhenDone = false
                hideItem()
            }
        }
    }

    Connections {
        target: container
        onHideOldImage: {
            if(src == container.imageLatestAdded)
                return
            if(elem.status != Image.Ready) {
                image_model.remove(index)
            } else if(hideShowAni.running) {
                if(!hideShowAni.deleteWhenDone)
                    hideShowAni.startToHideWhenDone = true
            } else
                hideItem()
        }
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
