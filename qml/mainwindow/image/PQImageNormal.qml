import QtQuick 2.9

Image {

    id: elem

    source: imageproperties.isAnimated(src) ? "" : ("image://full/" + src)
    visible: !imageproperties.isAnimated(src)

    asynchronous: true

    sourceSize: undefined

    cache: false

    MouseArea {
        anchors.fill: parent
        drag.target: parent
//        onWheel: {
//            if(wheel.angleDelta.y < 0)
//                zoomOut()
//            else
//                zoomIn()
//        }
    }

    fillMode: ((sourceSize.width<width&&sourceSize.height<height) ? Image.Pad : Image.PreserveAspectFit)

    Behavior on scale { NumberAnimation { duration: settings.animations ? 250 : 0 } }
    onScaleChanged:
        redrawAfterScale.restart()

    Timer {
        id: redrawAfterScale
        interval: 250
        repeat: false
        running: false
        onTriggered: {
            elem.update()
        }
    }

    property bool beingDeleted: false
    property bool beingHidden: false

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

    function showItem() {
        if(transitionAnimation == "x") {
            xAnim.duration = 0
            x = -width
            xAnim.duration = settings.imageTransition*150
            x = 0
            opacityAnim.duration = 0
            opacity = 1
        } else if(transitionAnimation == "y") {
            yAnim.duration = 0
            y = -height
            yAnim.duration = settings.imageTransition*150
            y = 0
            opacityAnim.duration = 0
            opacity = 1
        } else {
            opacityAnim.duration = settings.imageTransition*150
            opacity = 1
        }
        update()
    }

    Behavior on opacity { NumberAnimation { id: opacityAnim; duration: settings.imageTransition*150 } }
    Behavior on x { NumberAnimation { id: xAnim; duration: 0 } }
    Behavior on y { NumberAnimation { id: yAnim; duration: 0 } }

    onOpacityChanged: {
        if(beingDeleted && opacity == 0) {
            console.log("delete opacity")
            image_model.remove(index)
        }
    }
    onXChanged: {
        if(beingDeleted && x >= container.width) {
            console.log("delete x")
            image_model.remove(index)
        }
    }
    onYChanged: {
        if(beingDeleted && y >= container.height) {
            console.log("delete y")
            image_model.remove(index)
        }
    }

    Connections {
        target: container
        onHideOldImage: {
            if(elem.beingHidden)
                image_model.remove(index)
            else {
                elem.beingDeleted = true
                // hide in x direction
                if(transitionAnimation == "x") {
                    xAnim.duration = settings.imageTransition*150
                    elem.x = container.width+100
                // hide in y direction
                } else if(transitionAnimation == "y") {
                    yAnim.duration = settings.imageTransition*150
                    elem.y = container.height+100
                // fade out image
                } else
                    elem.opacity = 0
            }
        }
        onHideImageTemporary: {
            elem.beingHidden = true
            // hide in x direction
            if(transitionAnimation == "x") {
                hideTempX = elem.x
                xAnim.duration = settings.imageTransition*150
                elem.x = container.width+100
            // hide in y direction
            } else if(transitionAnimation == "y") {
                hideTempY = elem.y
                yAnim.duration = settings.imageTransition*150
                elem.y = container.height+100
            // fade out image
            } else
                elem.opacity = 0
        }
        onShowImageTemporary: {
            elem.beingHidden = false
            // show in x direction
            if(transitionAnimation == "x") {
                xAnim.duration = settings.imageTransition*150
                elem.x = hideTempX
            // show in y direction
            } else if(transitionAnimation == "y") {
                yAnim.duration = settings.imageTransition*150
                elem.y = hideTempY
            // fade in image
            } else
                elem.opacity = 1
        }
        onZoomIn: {
            elem.scale *= (1+settings.zoomSpeed/100)
        }
        onZoomOut: {
            elem.scale /= (1+settings.zoomSpeed/100)
        }
    }

}
