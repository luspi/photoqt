import QtQuick 2.9

Image {

    id: elem

    source: "image://full/" + src
    visible: !imageproperties.isAnimated(src)

    asynchronous: true

    sourceSize: undefined

    cache: false

    fillMode: ((sourceSize.width<width&&sourceSize.height<height) ? Image.Pad : Image.PreserveAspectFit)

    Behavior on scale { NumberAnimation { duration: PQSettings.animations ? 250 : 0 } }
    onScaleChanged: {
        variables.currentZoomLevel = (elem.paintedWidth/elem.sourceSize.width)*elem.scale*100
        container.imageScale = elem.scale
    }

    x: 0
    y: 0
    width: container.width
    height: container.height

    opacity: 0
    Component.onCompleted: {
        if(status == Image.Ready)
            showItem()
        else
            creationCheckStatus.start()
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
    }

    function showItem() {
        imageitem.hideOldImage(forwards)
        variables.currentZoomLevel = (elem.paintedWidth/elem.sourceSize.width)*elem.scale*100
        if(forwards) {
            if(PQSettings.animationType == "x") {
                xAnim.duration = 0
                x = width
                xAnim.duration = (PQSettings.animations ? PQSettings.animationDuration*150 : 0)
                x = 0
                opacityAnim.duration = 0
                opacity = 1
            } else if(PQSettings.animationType == "y") {
                yAnim.duration = 0
                y = height
                yAnim.duration = (PQSettings.animations ? PQSettings.animationDuration*150 : 0)
                y = 0
                opacityAnim.duration = 0
                opacity = 1
            } else {
                opacityAnim.duration = (PQSettings.animations ? PQSettings.animationDuration*150 : 0)
                opacity = 1
            }
        } else {
            if(PQSettings.animationType == "x") {
                xAnim.duration = 0
                x = -width
                xAnim.duration = (PQSettings.animations ? PQSettings.animationDuration*150 : 0)
                x = 0
                opacityAnim.duration = 0
                opacity = 1
            } else if(PQSettings.animationType == "y") {
                yAnim.duration = 0
                y = -height
                yAnim.duration = (PQSettings.animations ? PQSettings.animationDuration*150 : 0)
                y = 0
                opacityAnim.duration = 0
                opacity = 1
            } else {
                opacityAnim.duration = (PQSettings.animations ? PQSettings.animationDuration*150 : 0)
                opacity = 1
            }
        }
        update()
    }

    onStatusChanged:
        theimage.imageStatus = status

    Behavior on opacity { NumberAnimation { id: opacityAnim; duration: (PQSettings.animations ? PQSettings.animationDuration*150 : 0) } }
    Behavior on x { NumberAnimation { id: xAnim; duration: 0 } }
    Behavior on y { NumberAnimation { id: yAnim; duration: 0 } }

    onOpacityChanged: {
        if(opacity == 0 && imageitem.imageLatestAdded != src) {
            console.log("delete opacity")
            image_model.remove(index)
        } else {
            xAnim.duration = (PQSettings.animations ? PQSettings.animationDuration*150 : 0)
            yAnim.duration = (PQSettings.animations ? PQSettings.animationDuration*150 : 0)
        }
    }
    Connections {
        target: xAnim
        onRunningChanged: {
            if(!xAnim.running && imageitem.imageLatestAdded != src) {
                console.log("delete x")
                image_model.remove(index)
            } else {
                xAnim.duration = (PQSettings.animations ? PQSettings.animationDuration*150 : 0)
                yAnim.duration = (PQSettings.animations ? PQSettings.animationDuration*150 : 0)
            }
        }
    }
    Connections {
        target: yAnim
        onRunningChanged: {
            if(!yAnim.running && imageitem.imageLatestAdded != src) {
                console.log("delete y")
                image_model.remove(index)
            } else {
                xAnim.duration = (PQSettings.animations ? PQSettings.animationDuration*150 : 0)
                yAnim.duration = (PQSettings.animations ? PQSettings.animationDuration*150 : 0)
            }
        }
    }

    Connections {
        target: container
        onHideOldImage: {
            if(src == container.imageLatestAdded)
                return
            if(forwards) {
                // hide in x direction
                if(PQSettings.animationType == "x") {
                    xAnim.duration = (PQSettings.animations ? PQSettings.animationDuration*150 : 0)
                    elem.x = -elem.width
                // hide in y direction
                } else if(PQSettings.animationType == "y") {
                    yAnim.duration = (PQSettings.animations ? PQSettings.animationDuration*150 : 0)
                    elem.y = -elem.height
                // fade out image
                } else
                    elem.opacity = 0
            } else {
                // hide in x direction
                if(PQSettings.animationType == "x") {
                    xAnim.duration = (PQSettings.animations ? PQSettings.animationDuration*150 : 0)
                    elem.x = container.width
                // hide in y direction
                } else if(PQSettings.animationType == "y") {
                    yAnim.duration = (PQSettings.animations ? PQSettings.animationDuration*150 : 0)
                    elem.y = container.height
                // fade out image
                } else
                    elem.opacity = 0
            }
        }
        onZoomIn: {
            elem.scale *= (1+PQSettings.zoomSpeed/100)
        }
        onZoomOut: {
            elem.scale /= (1+PQSettings.zoomSpeed/100)
        }
        onZoomReset: {
            elem.scale = 1
            elem.x = 0
            elem.y = 0
        }
    }

}
