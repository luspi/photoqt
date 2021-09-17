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

    property real totalScale: imgcont.scale * scaletform.xScale * pincharea.pinchscale
    onTotalScaleChanged:
        variables.currentZoomLevel = totalScale*100

    function computeTotalScale(scaletformscale, pinchscale) {
        return imgcont.scale * scaletformscale * pinchscale
    }

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
            property real toScale: 1
            xScale: toScale
            yScale: toScale
            Behavior on xScale { NumberAnimation { duration: PQSettings.animationDuration*100  } }
            Behavior on yScale { NumberAnimation { duration: PQSettings.animationDuration*100  } }
            onXScaleChanged:
                imgcont.totalScale = computeTotalScale(scaletform.xScale, pincharea.pinchscale)
        }

        Flickable {
            id: flick
            anchors.fill: parent
            contentWidth: img.sourceSize.width
            contentHeight: img.sourceSize.height

            // we can use the height property in both as we always scale the width/height exactly the same
            onContentHeightChanged:
                pincharea.pinchscale = flick.contentHeight/img.sourceSize.height
            onContentWidthChanged:
                pincharea.pinchscale = flick.contentHeight/img.sourceSize.height

            PinchArea {

                id: pincharea

                width: Math.max(flick.contentWidth, flick.width)
                height: Math.max(flick.contentHeight, flick.height)

                property real pinchscale: 1

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
                    if(computeTotalScale(scaletform.toScale, (initialHeight * pinch.scale)/img.sourceSize.height) >= imgcont.defaultScale || PQSettings.zoomSmallerThanDefault)
                        flick.resizeContent(initialWidth * pinch.scale, initialHeight * pinch.scale, pinch.center)
                    else
                        flick.resizeContent(img.sourceSize.width, img.sourceSize.height, pinch.center)

                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    drag.target: parent
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

            var zoomfactor = 1.2
            if(wheelDelta != undefined)
                zoomfactor = Math.max(1.01, Math.min(1.2, Math.abs(wheelDelta.y/(101-PQSettings.zoomSpeed))))

            var tot = computeTotalScale(scaletform.toScale*zoomfactor, pincharea.pinchscale)
            if(tot < imgcont.defaultScale && !PQSettings.zoomSmallerThanDefault)
                zoomfactor = imgcont.defaultScale/(imgcont.scale*pincharea.pinchscale)

            // update x/y position of image
            var realX = localMousePos.x * scaletform.toScale
            var realY = localMousePos.y * scaletform.toScale

            var newX = imgmousezoom.toX+(1-zoomfactor)*realX
            var newY = imgmousezoom.toY+(1-zoomfactor)*realY
            imgmousezoom.toX = newX
            imgmousezoom.toY = newY

            // update scale factor
            scaletform.toScale *= zoomfactor

        }

        onZoomOut: {

            // get the local mouse position
            // if wheelDelta is undefined, then the zoom happened, e.g., from a key shortcut
            // in that case we zoom to the screen center
            var localMousePos = imgmousezoom.mapFromGlobal(variables.mousePos)
            if(wheelDelta == undefined)
                localMousePos = imgmousezoom.mapFromGlobal(Qt.point(toplevel.width/2, toplevel.height/2))

            // the zoomfactor depends on the settings
            var zoomfactor = 1/1.2
            if(wheelDelta != undefined)
                zoomfactor = 1/Math.max(1.01, Math.min(1.2, Math.abs(wheelDelta.y/(101-PQSettings.zoomSpeed))))

            var tot = computeTotalScale(scaletform.toScale*zoomfactor, pincharea.pinchscale)
            if(tot < imgcont.defaultScale && !PQSettings.zoomSmallerThanDefault)
                zoomfactor = imgcont.defaultScale/(imgcont.scale*pincharea.pinchscale)

            // update x/y position of image
            var realX = localMousePos.x * scaletform.toScale
            var realY = localMousePos.y * scaletform.toScale

            var newX = imgmousezoom.toX+(1-zoomfactor)*realX
            var newY = imgmousezoom.toY+(1-zoomfactor)*realY
            imgmousezoom.toX = newX
            imgmousezoom.toY = newY

            // update scale factor
            scaletform.toScale *= zoomfactor

        }

        onZoomReset: {

            imgmousezoom.toX = 0
            imgmousezoom.toY = 0
            scaletform.toScale = 1

            // reset properties changed through drag.target
            prop_pinchx.from = pincharea.x
            prop_pinchx.to = 0
            prop_pinchy.from = pincharea.y
            prop_pinchy.to = 0
            prop_pinchx.start()
            prop_pinchy.start()

            // setup and start property animations to reset flickarea pinch-to-zoom levels
            prop_contw.from = flick.contentWidth
            prop_contw.to = img.sourceSize.width
            prop_conth.from = flick.contentHeight
            prop_conth.to = img.sourceSize.height
            prop_contx.from = flick.contentX
            prop_contx.to = 0
            prop_conty.from = flick.contentY
            prop_conty.to = 0
            prop_contw.start()
            prop_conth.start()
            prop_contx.start()
            prop_conty.start()

        }

    }

    // we use porperty animations as we only want to animate these properties on reset and at no other time
    PropertyAnimation {
        id: prop_contw
        target: flick
        property: "contentWidth"
        duration: PQSettings.animationDuration*100
    }
    PropertyAnimation {
        id: prop_conth
        target: flick
        property: "contentHeight"
        duration: PQSettings.animationDuration*100
    }
    PropertyAnimation {
        id: prop_contx
        target: flick
        property: "contentX"
        duration: PQSettings.animationDuration*100
    }
    PropertyAnimation {
        id: prop_conty
        target: flick
        property: "contentY"
        duration: PQSettings.animationDuration*100
    }
    PropertyAnimation {
        id: prop_pinchx
        target: pincharea
        property: "x"
        duration: PQSettings.animationDuration*100
    }
    PropertyAnimation {
        id: prop_pinchy
        target: pincharea
        property: "y"
        duration: PQSettings.animationDuration*100
    }

}
