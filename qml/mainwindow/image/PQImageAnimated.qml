import QtQuick 2.9

AnimatedImage {

    id: elem

    source: "file://" + src

    asynchronous: true
    cache: false

    fillMode: ((sourceSize.width<width&&sourceSize.height<height&&!PQSettings.fitInWindow) ? Image.Pad : Image.PreserveAspectFit)

    Behavior on scale { NumberAnimation { duration: PQSettings.animations ? 250 : 0 } }
    onScaleChanged: {
        variables.currentZoomLevel = (elem.paintedWidth/elem.sourceSize.width)*elem.scale*100
        container.imageScale = elem.scale
    }

    Behavior on x { NumberAnimation { id: xAni; duration: 0 } }
    Behavior on y { NumberAnimation { id: yAni; duration: 0 } }
    x: PQSettings.marginAroundImage
    y: PQSettings.marginAroundImage
    width: container.width-2*PQSettings.marginAroundImage
    height: container.height-2*PQSettings.marginAroundImage

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
        if(forwards) {
            // show in x direction
            if(PQSettings.animationType == "x") {
                hideShowAni.from = container.width
                hideShowAni.to = 0
                hideShowAni.deleteWhenDone = false
                hideShowAni.property = "x"
                hideShowAni.start()
            // show in y direction
            } else if(PQSettings.animationType == "y") {
                hideShowAni.from = container.height
                hideShowAni.to = 0
                hideShowAni.deleteWhenDone = false
                hideShowAni.property = "y"
                hideShowAni.start()
            // fade in image
            } else {
                hideShowAni.from = 0
                hideShowAni.to = 1
                hideShowAni.deleteWhenDone = false
                hideShowAni.property = "opacity"
                hideShowAni.start()
            }
        } else {
            // show in x direction
            if(PQSettings.animationType == "x") {
                hideShowAni.from = -elem.width
                hideShowAni.to = 0
                hideShowAni.deleteWhenDone = false
                hideShowAni.property = "x"
                hideShowAni.start()
            // show in y direction
            } else if(PQSettings.animationType == "y") {
                hideShowAni.from = -elem.height
                hideShowAni.to = 0
                hideShowAni.deleteWhenDone = false
                hideShowAni.property = "y"
                hideShowAni.start()
            // fade in image
            } else {
                hideShowAni.from = 0
                hideShowAni.to = 1
                hideShowAni.deleteWhenDone = false
                hideShowAni.property = "opacity"
                hideShowAni.start()
            }
        }
        update()
    }

    function hideItem() {
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
        target: parent
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
            }
            if(startToHideWhenDone) {
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
            if(hideShowAni.running) {
                if(!hideShowAni.deleteWhenDone)
                    hideShowAni.startToHideWhenDone = true
            } else
                hideItem()
        }
        onZoomIn: {
            elem.scale *= (1+PQSettings.zoomSpeed/100)
        }
        onZoomOut: {
            elem.scale /= (1+PQSettings.zoomSpeed/100)
        }
        onZoomReset: {
            xAni.duration = PQSettings.animationDuration*150
            yAni.duration = PQSettings.animationDuration*150
            elem.scale = 1
            elem.x = 0
            elem.y = 0
        }
    }

}
