import QtQuick
import "../elements"

Item {

    id: image_top

    x: PQCSettings.imageviewMargin
    y: PQCSettings.imageviewMargin
    width: toplevel.width-2*PQCSettings.imageviewMargin
    height: toplevel.height-2*PQCSettings.imageviewMargin

    Rectangle {
        color: "red"
        width: 50
        height: 50
        z: 999
        Text {
            anchors.centerIn: parent
            text: PQCFileFolderModel.currentIndex
        }
    }

    property int currentlyVisibleIndex: -1

    property int curZ: 0

    signal zoomIn()
    signal zoomOut()
    signal zoomReset()
    signal zoomActual()
    signal rotateClock()
    signal rotateAntiClock()
    signal rotateReset()
    signal mirrorH()
    signal mirrorV()

    Repeater {

        id: repeater

        model: PQCFileFolderModel.countMainView

        delegate:
            Flickable {
                id: deleg

                width: image_top.width
                height: image_top.height

                visible: false
                clip: true

                property int itemIndex: index
                property real imageScale: defaultScale
                property real defaultScale: 1
                property size imageSize: Qt.size(0,0)

                signal zoomResetWithoutAnimation()
                signal recomputeDefaultScale()

                Connections {
                    target: image_top
                    function onZoomIn() {
                        if(PQCFileFolderModel.currentIndex===index)
                            deleg.imageScale /= 0.9
                    }
                    function onZoomOut() {
                        if(PQCFileFolderModel.currentIndex===index)
                            deleg.imageScale *= 0.9
                    }
                    function onZoomReset() {
                        if(PQCFileFolderModel.currentIndex===index)
                            deleg.imageScale = Qt.binding(function() { return deleg.defaultScale } )
                    }
                    function onZoomActual() {
                        if(PQCFileFolderModel.currentIndex===index)
                            deleg.imageScale = 1
                    }
                    function onRotateClock() {
//                        if(PQCFileFolderModel.currentIndex===index)
//                            deleg.imageRotation += 90
                    }
                    function onRotateAntiClock() {
//                        if(PQCFileFolderModel.currentIndex===index)
//                            deleg.imageRotation -= 90
                    }
                    function onRotateReset() {
//                        if(PQCFileFolderModel.currentIndex===index)
//                            deleg.imageRotation = 0
                    }
                }

                function updateContentSize(x, y, w, h) {
                    contentWidth = w
                    contentHeight = h
                }

                Loader {
                    id: l
                    asynchronous: true
                    active: shouldBeShown || hasBeenSetup
                    property bool shouldBeShown: PQCFileFolderModel.currentIndex===index || (image_top.currentlyVisibleIndex === index)
                    property bool hasBeenSetup: false
                    onShouldBeShownChanged: {
                        if(shouldBeShown) {
                            if(hasBeenSetup)
                                deleg.showImage()
                        } else {
                            deleg.hideImage()
                        }
                    }
                    sourceComponent: Item {

                        id: img

                        x: defaultX
                        y: defaultY
                        clip: false
                        width: theimage.width
                        height: theimage.height
                        scale: deleg.defaultScale

                        Image {
                            id: theimage
                            asynchronous: true
                            mipmap: true
                            source: "image://full/" + PQCFileFolderModel.entriesMainView[deleg.itemIndex]
                            onStatusChanged: {
                                if(status == Image.Ready) {
                                    if(PQCFileFolderModel.currentIndex === index) {
                                        var tmp = img.computeDefaultScale()
                                        if(Math.abs(tmp-1) > 1e-6)
                                            startupScale = true
                                        defaultWidth = width*tmp
                                        defaultHeight = height*tmp
                                        deleg.defaultScale = tmp
                                        l.hasBeenSetup = true
                                        deleg.showImage()
                                    }
                                }
                            }

                        }

                        function onImageSizeChanged() {
                            deleg.imageSize = theimage.sourceSize
                        }

                        property real prevW: defaultWidth
                        property real prevH: defaultHeight

                        onScaleChanged: {
                            // no animation at startup
                            if(!startupScale) {

                                var updX = defaultX
                                var updY = defaultY
                                var updContentX = 0
                                var updContentY = 0

                                var changeWidth
                                var changeHeight

                                // if the width is larger than the visible width
                                if(width*scale > deleg.width) {
                                    changeWidth = (theimage.paintedWidth*scale - prevW)/2
                                    updX = Math.min((theimage.paintedWidth*scale-defaultWidth)/2, Math.max(defaultX, x+changeWidth))
                                    updContentX = Math.min(theimage.paintedWidth*scale-defaultWidth, Math.max(0, deleg.contentX+changeWidth))
                                }
                                // if the height is larger than the visible height
                                if(height*scale > deleg.height) {
                                    changeHeight = (theimage.paintedHeight*scale - prevH)/2
                                    updY = Math.min((theimage.paintedHeight*scale-defaultHeight)/2, Math.max(defaultY, y+changeHeight))
                                    updContentY = Math.min(theimage.paintedHeight*scale-defaultHeight, Math.max(0, deleg.contentY+changeHeight))
                                }

                                x = updX
                                y = updY
                                deleg.contentX = updContentX
                                deleg.contentY = updContentY
                            }
                            deleg.updateContentSize(img.x, img.y, img.width*scale, img.height*scale)
                            prevW = theimage.paintedWidth*scale
                            prevH = theimage.paintedHeight*scale
                        }

                        property real defaultX: (deleg.width-width)/2
                        property real defaultY: (deleg.height-height)/2
                        property real defaultWidth: 0
                        property real defaultHeight: 0

                        property bool startupScale: false

                        Connections {
                            target: deleg
                            function onImageScaleChanged() {
                                if(img.startupScale) {
                                    img.startupScale = false
                                    img.scale = deleg.imageScale
                                } else
                                    scaleAnimation.restart()
                            }
                            function onZoomResetWithoutAnimation() {
                                img.x = img.defaultX
                                img.y = img.defaultY
                                img.scale = deleg.defaultScale
                                deleg.imageScale = img.scale
                            }
                        }

                        Connections {
                            target: image_top
                            function onMirrorH() {
                                theimage.mirror = !theimage.mirror
                            }
                            function onMirrorV() {
                                theimage.mirror = !theimage.mirror
                                theimage.rotation += 180
                            }
                        }

                        Connections {
                            target: toplevel
                            function onWidthChanged() {
                                resetDefault.restart()
                            }
                            function onHeightChanged() {
                                resetDefault.restart()
                            }
                        }

                        Timer {
                            id: resetDefault
                            interval: 50
                            onTriggered: {
                                deleg.defaultScale = img.computeDefaultScale()
                                if(Math.abs(deleg.imageScale-deleg.defaultScale) < 1e-6)
                                    deleg.imageScale = deleg.defaultScale
                                deleg.imageScaleChanged()
                            }
                        }

                        PropertyAnimation {
                            id: scaleAnimation
                            target: img
                            property: "scale"
                            from: img.scale
                            to: deleg.imageScale
                            duration: 200
                            onStarted: deleg.cancelFlick()
                        }

                        function computeDefaultScale() {
                            return Math.min(1, Math.min(deleg.width/theimage.sourceSize.width, deleg.height/theimage.sourceSize.height))
                        }

                    }
                }

                PropertyAnimation {
                    id: opacityAnimation
                    target: deleg
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 200
                    onFinished:
                        if(deleg.opacity < 1e-6)
                            deleg.visible = false
                }

                function showImage() {

                    image_top.currentlyVisibleIndex = deleg.itemIndex

                    deleg.zoomResetWithoutAnimation()

                    opacityAnimation.stop()

                    deleg.opacity = 0
                    deleg.z = image_top.curZ
                    deleg.visible = true

                    opacityAnimation.from = 0
                    opacityAnimation.to = 1
                    opacityAnimation.restart()

                    image_top.curZ += 1
                }

                function hideImage() {

                    opacityAnimation.stop()
                    opacityAnimation.from = deleg.opacity
                    opacityAnimation.to = 0
                    opacityAnimation.restart()

                }

            }

    }

    function showNext() {
        PQCFileFolderModel.currentIndex = Math.min(PQCFileFolderModel.currentIndex+1, PQCFileFolderModel.countMainView-1)
    }

    function showPrev() {
        PQCFileFolderModel.currentIndex = Math.max(PQCFileFolderModel.currentIndex-1, 0)
    }

}
