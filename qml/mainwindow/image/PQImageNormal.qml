import QtQuick 2.15

Item {

    id: imgcont

//    x: useStoredData ? variables.zoomRotationMirror[src][4].x : 0
//    y: useStoredData ? variables.zoomRotationMirror[src][4].y : 0
    x: (width - img.sourceSize.width*scale)/2
    y: (height - img.sourceSize.height*scale)/2
    width: container.width
    height: container.height

    transformOrigin: Item.TopLeft
    property real defaultScale: (img.sourceSize.width>imgcont.width||img.sourceSize.height>imgcont.height || PQSettings.fitInWindow) ? Math.min(imgcont.width/img.sourceSize.width, imgcont.height/img.sourceSize.height) : 1.0
    scale: defaultScale

    property point mousePos: Qt.point(0,0)

    Item {

        id: imgmousezoom

        // NO anchors/width/height here!!

        property real toX: 0
        property real toY: 0
        x: toX
        y: toY
        Behavior on x { NumberAnimation { duration: PQSettings.animationDuration*100  } }
        Behavior on y { NumberAnimation { duration: PQSettings.animationDuration*100  } }

        transform: Scale {
            id: scaletform
            property real toXScale: 1
            property real toYScale: 1
            xScale: toXScale
            yScale: toYScale
            Behavior on xScale { NumberAnimation { duration: PQSettings.animationDuration*100  } }
            Behavior on yScale { NumberAnimation { duration: PQSettings.animationDuration*100  } }
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
                onPinchStarted: {
                    initialWidth = flick.contentWidth
                    initialHeight = flick.contentHeight
                }

                onPinchUpdated: {
                    // adjust content pos due to drag
                    flick.contentX += pinch.previousCenter.x - pinch.center.x
                    flick.contentY += pinch.previousCenter.y - pinch.center.y

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
            if(wheelDelta == undefined)
                localMousePos = imgmousezoom.mapFromGlobal(Qt.point(toplevel.width/2, toplevel.height/2))

            // the zoomfactor depends on the settings

            var zoomfactor = Math.max(1.01, Math.min(1.2, Math.abs(wheelDelta.y/(101-PQSettings.zoomSpeed))))

            // update x/y position of image
            var realX = localMousePos.x * scaletform.toXScale
            var realY = localMousePos.y * scaletform.toYScale

            var newX = imgmousezoom.toX+(1-zoomfactor)*realX
            var newY = imgmousezoom.toY+(1-zoomfactor)*realY
            imgmousezoom.toX = newX
            imgmousezoom.toY = newY

            // update scale factor
            scaletform.toXScale *= zoomfactor
            scaletform.toYScale *= zoomfactor

        }

        onZoomOut: {

            // get the local mouse position
            // if wheelDelta is undefined, then the zoom happened, e.g., from a key shortcut
            // in that case we zoom to the screen center
            var localMousePos = imgmousezoom.mapFromGlobal(variables.mousePos)
            if(wheelDelta == undefined)
                localMousePos = imgmousezoom.mapFromGlobal(Qt.point(toplevel.width/2, toplevel.height/2))

            // the zoomfactor depends on the settings
            var zoomfactor = 1/Math.max(1.01, Math.min(1.2, Math.abs(wheelDelta.y/(101-PQSettings.zoomSpeed))))

            // update x/y position of image
            var realX = localMousePos.x * scaletform.toXScale
            var realY = localMousePos.y * scaletform.toYScale

            var newX = imgmousezoom.toX+(1-zoomfactor)*realX
            var newY = imgmousezoom.toY+(1-zoomfactor)*realY
            imgmousezoom.toX = newX
            imgmousezoom.toY = newY

            // update scale factor
            scaletform.toXScale *= zoomfactor
            scaletform.toYScale *= zoomfactor

        }

    }

}
