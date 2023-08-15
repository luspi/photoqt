import QtQuick

import PQCImageFormats
import PQCFileFolderModel
import PQCScriptsConfig
import PQCScriptsFilesPaths
import PQCScriptsImages
import PQCNotify

import "../elements"

Item {

    id: image_top

    x: extraX + PQCSettings.imageviewMargin
    y: extraY + PQCSettings.imageviewMargin
    width: toplevel.width-2*PQCSettings.imageviewMargin - lessW
    height: toplevel.height-2*PQCSettings.imageviewMargin - lessH

    property int extraX: (thumbnails.holdVisible && PQCSettings.interfaceEdgeLeftAction==="thumbnails") ? thumbnails.width : 0
    property int extraY: (thumbnails.holdVisible && PQCSettings.interfaceEdgeTopAction==="thumbnails") ? thumbnails.height : 0
    property int lessW: (thumbnails.holdVisible && PQCSettings.interfaceEdgeRightAction==="thumbnails") ? thumbnails.width : 0
    property int lessH: (thumbnails.holdVisible && PQCSettings.interfaceEdgeBottomAction==="thumbnails") ? thumbnails.height : 0

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
    property real defaultScale: 1
    property real currentScale: 1

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
            // the item is a loader that is only loaded when needed
            Loader {

                id: deleg

                width: image_top.width
                height: image_top.height
                visible: false

                asynchronous: true
                active: shouldBeShown || hasBeenSetup

                property bool shouldBeShown: PQCFileFolderModel.currentIndex===index || (image_top.currentlyVisibleIndex === index)
                property bool hasBeenSetup: false
                onShouldBeShownChanged: {
                    if(shouldBeShown) {
                        if(hasBeenSetup)
                            showImage()
                    } else {
                        hideImage()
                    }
                }

                // the current index
                property int itemIndex: index
                property string imageSource: PQCFileFolderModel.entriesMainView[itemIndex]

                // some image properties
                property int imageRotation: 0
                property bool rotatedUpright: (Math.abs(imageRotation%180)!=90)
                property real imageScale: defaultScale
                property real defaultWidth
                property real defaultHeight
                property real defaultScale: 1

                // some signals
                signal zoomResetWithoutAnimation()
                signal stopVideoAndReset()
                signal restartVideoIfAutoplay()

                // react to user commands
                Connections {
                    target: image_top
                    function onZoomIn() {
                        if(PQCFileFolderModel.currentIndex===index) {
                            if(PQCSettings.imageviewZoomMaxEnabled)
                                deleg.imageScale = Math.min(25, deleg.imageScale/0.9)
                            else
                                deleg.imageScale = Math.min(PQCSettings.imageviewZoomMax/100, deleg.imageScale/0.9)
                        }
                    }
                    function onZoomOut() {
                        if(PQCFileFolderModel.currentIndex===index) {
                            if(PQCSettings.imageviewZoomMinEnabled)
                                deleg.imageScale = Math.max(deleg.defaultScale*(PQCSettings.imageviewZoomMin/100), deleg.imageScale*0.9)
                            else
                                deleg.imageScale = Math.max(0.01, deleg.imageScale*0.9)
                        }
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
                        if(PQCFileFolderModel.currentIndex===index)
                            deleg.imageRotation += 90
                    }
                    function onRotateAntiClock() {
                        if(PQCFileFolderModel.currentIndex===index)
                            deleg.imageRotation -= 90
                    }
                    function onRotateReset() {
                        if(PQCFileFolderModel.currentIndex===index) {
                            // rotate to the nearest (rotation%360==0) degrees
                            var offset = deleg.imageRotation%360
                            if(offset == 180 || offset == 270)
                                deleg.imageRotation += (360-offset)
                            else if(offset == 90)
                                deleg.imageRotation -= 90
                            else if(offset == -90)
                                deleg.imageRotation += 90
                            else if(offset == -180 || offset == -270)
                                deleg.imageRotation -= (360+offset)
                        }
                    }

                }

                // the loader loads a flickable once active
                sourceComponent:
                Item {

                    id: loader_component

                    width: deleg.width
                    height: deleg.height

                    property bool isMpv: PQCImageFormats.getEnabledFormatsLibmpv().indexOf(PQCScriptsFilesPaths.getSuffix(deleg.imageSource))>-1 && PQCSettings.filetypesVideoPreferLibmpv && PQCScriptsConfig.isMPVSupportEnabled()
                    property bool isAnimated: PQCScriptsImages.isItAnimated(deleg.imageSource)

                    property bool videoPlaying: isMpv
                    property real videoDuration: 0.0
                    property real videoPosition: 0.0
                    signal videoTogglePlay()
                    signal videoToPos(var s)
                    signal imageClicked()

                    Flickable {

                        id: flickable

                        width: deleg.width
                        height: deleg.height

                        contentWidth: flickable_content.width
                        contentHeight: flickable_content.height

                        Connections {

                            target: PQCNotify

                            function onMouseWheel(angleDelta, modifiers) {
                                if(PQCSettings.imageviewUseMouseWheelForImageMove)
                                    return
                                flickable.interactive = false
                                reEnableInteractive.restart()
                            }

                        }

                        Timer {
                            id: reEnableInteractive
                            interval: 100
                            repeat: false
                            onTriggered: flickable.interactive = true
                        }

                        // the container for the content
                        Item {
                            id: flickable_content

                            x: Math.max(0, (flickable.width-width)/2)
                            y: Math.max(0, (flickable.height-height)/2)
                            width: (deleg.rotatedUpright ? image_wrapper.width : image_wrapper.height)*image_wrapper.scale
                            height: (deleg.rotatedUpright ? image_wrapper.height : image_wrapper.width)*image_wrapper.scale

                            // wrapper for the image
                            // we need both this and the container to be able to properly hadle
                            // all scaling and rotations while having the flickable properly flick the image
                            Item {

                                id: image_wrapper

                                y: (deleg.rotatedUpright ?
                                        (height*scale-height)/2 :
                                        (-(image_wrapper.height - image_wrapper.width)/2 + (width*scale-width)/2))
                                x: (deleg.rotatedUpright ?
                                        (width*scale-width)/2 :
                                        (-(image_wrapper.width - image_wrapper.height)/2 + (height*scale-height)/2))

                                // some properties
                                property real prevW: deleg.defaultWidth
                                property real prevH: deleg.defaultHeight
                                property real prevScale: scale
                                property bool startupScale: false

                                rotation: 0
                                scale: deleg.defaultScale

                                // update content position
                                onScaleChanged: {

                                    var updContentX = 0
                                    var updContentY = 0

                                    // if the width is larger than the visible width
                                    if(width*scale > flickable.width) {
                                        updContentX = flickable.contentX+(width*scale - prevW)/2
                                    }
                                    // if the height is larger than the visible height
                                    if(height*scale > flickable.height) {
                                        updContentY = flickable.contentY+(height*scale - prevH)/2
                                    }

                                    flickable.contentX = updContentX
                                    flickable.contentY = updContentY

                                    prevW = width*scale
                                    prevH = height*scale
                                    prevScale = scale

                                    if(PQCFileFolderModel.currentIndex === index)
                                        image_top.currentScale = scale

                                }

                                // react to status changes
                                property int status: Image.Null
                                onStatusChanged: {
                                    if(status == Image.Ready) {
                                        if(PQCFileFolderModel.currentIndex === index) {
                                            var tmp = image_wrapper.computeDefaultScale()
                                            if(Math.abs(tmp-1) > 1e-6)
                                                image_wrapper.startupScale = true
                                            deleg.defaultWidth = width*deleg.defaultScale
                                            deleg.defaultHeight = height*deleg.defaultScale
                                            deleg.defaultScale = 0.99999999*tmp
                                            image.defaultScale = deleg.defaultScale
                                            deleg.hasBeenSetup = true
                                            deleg.showImage()
                                        }
                                    }
                                }

                                // the actual image
                                Loader {

                                    source: loader_component.isMpv ? "PQVideoMpv.qml"
                                                                   : (loader_component.isAnimated ? "PQImageAnimated.qml"
                                                                                                  : "PQImageNormal.qml")

                                }

                                // scaling animation
                                PropertyAnimation {
                                    id: scaleAnimation
                                    target: image_wrapper
                                    property: "scale"
                                    from: image_wrapper.scale
                                    to: deleg.imageScale
                                    duration: 200
                                }

                                // rotation animation
                                PropertyAnimation {
                                    id: rotationAnimation
                                    target: image_wrapper
                                    duration: 200
                                    property: "rotation"
                                }

                                // reset default properties when window size changed
                                Timer {
                                    id: resetDefaults
                                    interval: 100
                                    onTriggered: {
                                        var tmp = image_wrapper.computeDefaultScale()
                                        if(Math.abs(image_wrapper.scale-deleg.defaultScale) < 1e-6) {
                                            deleg.defaultScale = 0.99999999*tmp
                                            deleg.zoomResetWithoutAnimation()
                                        } else
                                            deleg.defaultScale = 0.99999999*tmp

                                        if(PQCFileFolderModel.currentIndex === index)
                                            image.defaultScale = deleg.defaultScale
                                    }
                                }

                                Connections {

                                    target: image_top

                                    function onWidthChanged() {
                                        resetDefaults.restart()
                                    }

                                    function onHeightChanged() {
                                        resetDefaults.restart()
                                    }

                                }

                                // connect image wrapper to some of its properties
                                Connections {

                                    target: deleg

                                    function onImageScaleChanged() {
                                        if(image_wrapper.startupScale) {
                                            image_wrapper.startupScale = false
                                            image_wrapper.scale = deleg.imageScale
                                        } else {
                                            scaleAnimation.from = image_wrapper.scale
                                            scaleAnimation.to = deleg.imageScale
                                            scaleAnimation.restart()
                                        }
                                    }

                                    function onZoomResetWithoutAnimation() {
                                        scaleAnimation.stop()
                                        image_wrapper.scale = deleg.defaultScale
                                        deleg.imageScale = image_wrapper.scale
                                    }


                                    function onImageRotationChanged() {
                                        if(PQCFileFolderModel.currentIndex===index) {
                                            rotationAnimation.stop()
                                            rotationAnimation.from = image_wrapper.rotation
                                            rotationAnimation.to = deleg.imageRotation
                                            rotationAnimation.restart()
                                            var oldDefault = deleg.defaultScale
                                            deleg.defaultScale = 0.99999999*image_wrapper.computeDefaultScale()
                                            if(Math.abs(deleg.imageScale-oldDefault) < 1e-6)
                                                deleg.imageScale = deleg.defaultScale
                                            image.defaultScale = deleg.defaultScale
                                        }
                                    }
                                }

                                // calculate the default scale based on the current rotation
                                function computeDefaultScale() {
                                    if(deleg.rotatedUpright)
                                        return Math.min(1, Math.min((flickable.width/width), (flickable.height/height)))
                                    return Math.min(1, Math.min((flickable.width/height), (flickable.height/width)))
                                }

                                MouseArea {
                                    id: imagemouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    propagateComposedEvents: true
                                    onPositionChanged: (mouse) => {
                                        var pos = imagemouse.mapToItem(fullscreenitem, mouse.x, mouse.y)
                                        thumbnails.checkMousePosition(pos.x, pos.y)
                                    }
                                    onWheel: (wheel) => {
                                        wheel.accepted = false
                                        PQCNotify.mouseWheel(wheel.angleDelta, wheel.modifiers)
                                    }
                                    onClicked:
                                        loader_component.imageClicked()
                                }

                                PinchArea {

                                    id: pincharea

                                    anchors.fill: parent

                                    // the actual scale factor from a pinch event is the initial scale multiplied by Pinch.scale
                                    property real initialScale
                                    onPinchStarted: {
                                        initialScale = image_wrapper.scale
                                    }

                                    onPinchUpdated: (pinch) => {

                                        var fact = (initialScale*pinch.scale)/image_wrapper.scale

                                        // update scale factor
                                        deleg.imageScale *= fact


                                    }

                                }

                            }

                        }

                    }

                    PQVideoControls { id: videocontrols}

                }

                // animation to show the image
                PropertyAnimation {
                    id: opacityAnimation
                    target: deleg
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 200
                    onFinished: {
                        if(deleg.opacity < 1e-6) {

                            // stop any possibly running video
                            deleg.stopVideoAndReset()

                            deleg.visible = false

                        }
                    }
                }

                // show the image
                function showImage() {

                    image_top.currentlyVisibleIndex = itemIndex

                    zoomResetWithoutAnimation()

                    opacityAnimation.stop()

                    opacity = 0
                    z = image_top.curZ
                    visible = true

                    // (re-)start any video
                    deleg.restartVideoIfAutoplay()

                    opacityAnimation.from = 0
                    opacityAnimation.to = 1
                    opacityAnimation.restart()

                    image_top.curZ += 1


                }

                // hide the image
                function hideImage() {

                    opacityAnimation.stop()
                    opacityAnimation.from = opacity
                    opacityAnimation.to = 0
                    opacityAnimation.restart()

                }

            }


    }

    // some global handlers
    function showNext() {
        PQCFileFolderModel.currentIndex = Math.min(PQCFileFolderModel.currentIndex+1, PQCFileFolderModel.countMainView-1)
    }

    function showPrev() {
        PQCFileFolderModel.currentIndex = Math.max(PQCFileFolderModel.currentIndex-1, 0)
    }

}
