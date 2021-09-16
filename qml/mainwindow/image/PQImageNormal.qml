import QtQuick 2.15

Item {

    id: imgcont

//    x: useStoredData ? variables.zoomRotationMirror[src][4].x : 0
//    y: useStoredData ? variables.zoomRotationMirror[src][4].y : 0
    x: (width - img.sourceSize.width*scale)/2
    y: (height - img.sourceSize.height*scale)/2
    width: container.width
    height: container.height

    Timer {
        interval: 500
        repeat: true
        running: true
        onTriggered:
            console.log(width, img.sourceSize.width, scale)
    }

    transformOrigin: Item.TopLeft
    scale: Math.min(imgcont.width/img.sourceSize.width, imgcont.height/img.sourceSize.height)

    property point mousePos: Qt.point(0,0)

    Item {

        id: imgmousezoom

        // NO anchors/width/height here!!

        transform: Scale {
            id: scaletform
        }

        Flickable {
            id: flick
            anchors.fill: parent
            contentWidth: img.sourceSize.width
            contentHeight: img.sourceSize.height

            PinchArea {
                width: Math.max(flick.contentWidth, flick.width)
                height: Math.max(flick.contentHeight, flick.height)

                property real initialWidth
                property real initialHeight
                property real initialRotation
                onPinchStarted: {
                    initialWidth = flick.contentWidth
                    initialHeight = flick.contentHeight
//                    initialRotation = flick.contentItem.rotation
                }

                onPinchUpdated: {
                    // adjust content pos due to drag
                    flick.contentX += pinch.previousCenter.x - pinch.center.x
                    flick.contentY += pinch.previousCenter.y - pinch.center.y

//                    flick.contentItem.rotation = initialRotation+pinch.rotation

                    // resize content
                    flick.resizeContent(initialWidth * pinch.scale, initialHeight * pinch.scale, pinch.center)
                }

                MouseArea {
                    id: mm
                    anchors.fill: parent
                    hoverEnabled: true
                    drag.target: parent
                    onMouseXChanged:
                        imgcont.mousePos.x = mouseX
                    onMouseYChanged:
                        imgcont.mousePos.y = mouseY
                }

                Item {
                    id: outsideimg
                    width: flick.contentWidth
                    height: flick.contentHeight
                    Image {
                        id: img
                        anchors.fill: parent
                        source: "image://full/" + src
                        smooth: true
                        mipmap: true

                        onStatusChanged: {
                            if(source == "") return
                            imgcont.parent.imageStatus = status
                            if(status == Image.Ready) {
//                                if(reloadingImage) {
//                                    loadingindicator.forceStop()
//                                    reloadingImage = false
//                                } else
//                                    theimage_load.restart()
                            }
                        }

                    }
                }
            }
        }

    }

    Connections {
        target: container
        onZoomIn: {

            // get the local mouse position
            // if wheelDelta is undefined, then the zoom happened, e.g., from a key shortcut
            // in that case we zoom to the screen center
            var localMousePos = imgmousezoom.mapFromGlobal(variables.mousePos)

            // the zoomfactor depends on the settings
            var zoomfactor = 1.2

            // update x/y position of image
            var realX = localMousePos.x * scaletform.xScale
            var realY = localMousePos.y * scaletform.yScale

            var newX = imgmousezoom.x+(1-zoomfactor)*realX
            var newY = imgmousezoom.y+(1-zoomfactor)*realY
            imgmousezoom.x = newX
            imgmousezoom.y = newY

            // update scale factor
            scaletform.xScale *= zoomfactor
            scaletform.yScale *= zoomfactor

        }

        onZoomOut: {

            // get the local mouse position
            // if wheelDelta is undefined, then the zoom happened, e.g., from a key shortcut
            // in that case we zoom to the screen center
            var localMousePos = imgmousezoom.mapFromGlobal(variables.mousePos)

            // the zoomfactor depends on the settings
            var zoomfactor = 1/1.2

            // update x/y position of image
            var realX = localMousePos.x * scaletform.xScale
            var realY = localMousePos.y * scaletform.yScale

            var newX = imgmousezoom.x+(1-zoomfactor)*realX
            var newY = imgmousezoom.y+(1-zoomfactor)*realY
            imgmousezoom.x = newX
            imgmousezoom.y = newY

            // update scale factor
            scaletform.xScale *= zoomfactor
            scaletform.yScale *= zoomfactor

        }

    }

}
