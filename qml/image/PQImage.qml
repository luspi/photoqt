import QtQuick

import PQCImageFormats
import PQCFileFolderModel
import PQCScriptsConfig
import PQCScriptsFilesPaths
import PQCScriptsImages
import PQCNotify
import PQCResolutionCache

import "../elements"

Item {

    id: image_top

    x: extraX + PQCSettings.imageviewMargin
    y: extraY + PQCSettings.imageviewMargin
    width: toplevel.width-2*PQCSettings.imageviewMargin - lessW
    height: toplevel.height-2*PQCSettings.imageviewMargin - lessH

    property bool thumbnailsHoldVisible: (PQCSettings.thumbnailsVisibility===1 || (PQCSettings.thumbnailsVisibility===2 && (imageIsAtDefaultScale || currentScale < defaultScale)))

    property int extraX: (thumbnailsHoldVisible && PQCSettings.interfaceEdgeLeftAction==="thumbnails" && loader_thumbnails.status===Loader.Ready) ? loader_thumbnails.item.width : 0
    property int extraY: (thumbnailsHoldVisible && PQCSettings.interfaceEdgeTopAction==="thumbnails" && loader_thumbnails.status===Loader.Ready) ? loader_thumbnails.item.height : 0
    property int lessW: (thumbnailsHoldVisible && PQCSettings.interfaceEdgeRightAction==="thumbnails" && loader_thumbnails.status===Loader.Ready) ? loader_thumbnails.item.width : 0
    property int lessH: (thumbnailsHoldVisible && PQCSettings.interfaceEdgeBottomAction==="thumbnails" && loader_thumbnails.status===Loader.Ready) ? loader_thumbnails.item.height : 0

    property int currentlyVisibleIndex: -1
    property var visibleIndexPrevCur: [-1,-1]
    onCurrentlyVisibleIndexChanged: {
        visibleIndexPrevCur[1] = visibleIndexPrevCur[0]
        visibleIndexPrevCur[0] = currentlyVisibleIndex
        visibleIndexPrevCurChanged()
    }

    property int curZ: 0
    property real defaultScale: 1
    property real currentScale: 1
    property real currentRotation: 0
    property size currentResolution: Qt.size(0,0)

    property bool imageIsAtDefaultScale: Math.abs(currentScale-defaultScale) < 1e-6

    onCurrentResolutionChanged: {
        if(currentResolution.height > 0 && currentResolution.width > 0)
            PQCResolutionCache.saveResolution(PQCFileFolderModel.currentFile, currentResolution)
    }

    property string randomAnimation: "opacity"

    signal zoomIn(var wheelDelta)
    signal zoomOut(var wheelDelta)
    signal zoomReset()
    signal zoomActual()
    signal rotateClock()
    signal rotateAntiClock()
    signal rotateReset()
    signal mirrorH()
    signal mirrorV()
    signal mirrorReset()

    signal imageFinishedLoading(var index)

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
                property size imageResolution: Qt.size(0,0)

                onImageResolutionChanged: {
                    if(PQCFileFolderModel.currentIndex===index)
                        image_top.currentResolution = imageResolution
                }

                // some signals
                signal zoomResetWithoutAnimation()
                signal rotationResetWithoutAnimation()
                signal rotationZoomResetWithoutAnimation()
                signal stopVideoAndReset()
                signal restartVideoIfAutoplay()

                // react to user commands
                Connections {
                    target: image_top
                    function onZoomIn(wheelDelta) {
                        if(PQCFileFolderModel.currentIndex===index) {

                            // compute zoom factor based on wheel movement (if done by mouse)
                            var zoomfactor
                            if(wheelDelta !== undefined)
                                zoomfactor = Math.max(1.01, Math.min(1.3, 1+Math.abs(wheelDelta.y/(200-PQCSettings.imageviewZoomSpeed))))
                            else
                                zoomfactor = Math.max(1.01, Math.min(1.3, 1+PQCSettings.imageviewZoomSpeed*0.01))

                            if(PQCSettings.imageviewZoomMaxEnabled)
                                deleg.imageScale = Math.min(PQCSettings.imageviewZoomMax/100, deleg.imageScale*zoomfactor)
                            else
                                deleg.imageScale = Math.min(25, deleg.imageScale*zoomfactor)
                        }
                    }
                    function onZoomOut(wheelDelta) {
                        if(PQCFileFolderModel.currentIndex===index) {

                            // compute zoom factor based on wheel movement (if done by mouse)
                            var zoomfactor
                            if(wheelDelta !== undefined)
                                zoomfactor = Math.max(1.01, Math.min(1.3, 1+Math.abs(wheelDelta.y/(200-PQCSettings.imageviewZoomSpeed))))
                            else
                                zoomfactor = Math.max(1.01, Math.min(1.3, 1+PQCSettings.imageviewZoomSpeed*0.01))

                            if(PQCSettings.imageviewZoomMinEnabled)
                                deleg.imageScale = Math.max(deleg.defaultScale*(PQCSettings.imageviewZoomMin/100), deleg.imageScale/zoomfactor)
                            else
                                deleg.imageScale = Math.max(0.01, deleg.imageScale/zoomfactor)
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

                    // this ensures that if the image is no longer visible and more than 2 entries away from the current one
                    // then the loader's active property is set to false (and consequently all memory freed)
                    // this is done inside the sourceComponent as non-active loaders don't need to check this
                    Connections {
                        target: PQCFileFolderModel
                        function onCurrentIndexChanged() {
                            if(!deleg.visible && Math.abs(PQCFileFolderModel.currentIndex-index) > 2)
                                deleg.hasBeenSetup = false
                        }
                    }

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

                                onRotationChanged: {
                                    if(PQCFileFolderModel.currentIndex === index)
                                        image_top.currentRotation = rotation
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
                                            image_top.defaultScale = deleg.defaultScale
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
                                            deleg.rotationZoomResetWithoutAnimation()
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

                                    function onRotationZoomResetWithoutAnimation() {
                                        scaleAnimation.stop()
                                        rotationAnimation.stop()
                                        image_wrapper.rotation = 0
                                        deleg.imageRotation = 0
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
                                    acceptedButtons: Qt.LeftButton|Qt.RightButton
                                    onPositionChanged: (mouse) => {
                                        var pos = imagemouse.mapToItem(fullscreenitem, mouse.x, mouse.y)
                                        PQCNotify.mouseMove(pos.x, pos.y)
                                    }
                                    onWheel: (wheel) => {
                                        wheel.accepted = false
                                        PQCNotify.mouseWheel(wheel.angleDelta, wheel.modifiers)
                                    }
                                    onClicked: (mouse) => {
                                        var pos = imagemouse.mapToItem(fullscreenitem, mouse.x, mouse.y)
                                        if(mouse.button === Qt.LeftButton && (loader_component.isMpv || loader_component.isAnimated))
                                            loader_component.imageClicked()
                                        else
                                            PQCNotify.mouseClick(mouse.modifiers, mouse.button, pos)
                                    }
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

                                        var newscale = deleg.imageScale * ((initialScale*pinch.scale)/image_wrapper.scale)

                                        if(PQCSettings.imageviewZoomMinEnabled) {
                                            var min = deleg.defaultScale*(PQCSettings.imageviewZoomMin/100)
                                            if(newscale < min)
                                                newscale = min
                                            else if(newscale < 0.01)
                                                newscale = 0.01
                                        }

                                        if(PQCSettings.imageviewZoomMaxEnabled) {
                                            var max = PQCSettings.imageviewZoomMax/100
                                            if(newscale > max)
                                                newscale = max
                                            else if(newscale > 25)
                                                newscale = 25
                                        }

                                        // update scale factor
                                        deleg.imageScale = newscale


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
                    duration: PQCSettings.imageviewAnimationDuration*100
                    onFinished: {
                        if(deleg.opacity < 1e-6) {

                            // stop any possibly running video
                            deleg.stopVideoAndReset()

                            deleg.visible = false

                        }
                    }
                }

                // animation to show the image
                PropertyAnimation {
                    id: xAnimation
                    target: deleg
                    property: "x"
                    from: -width
                    to: 0
                    duration: PQCSettings.imageviewAnimationDuration*100
                    onFinished: {
                        if(Math.abs(deleg.x) > 10) {

                            // stop any possibly running video
                            deleg.stopVideoAndReset()

                            deleg.visible = false

                        }
                    }
                }

                // animation to show the image
                PropertyAnimation {
                    id: yAnimation
                    target: deleg
                    property: "y"
                    from: -height
                    to: 0
                    duration: PQCSettings.imageviewAnimationDuration*100
                    onFinished: {
                        if(Math.abs(deleg.y) > 10) {

                            // stop any possibly running video
                            deleg.stopVideoAndReset()

                            deleg.visible = false

                        }
                    }
                }

                // animation to show the image
                ParallelAnimation {
                    id: rotAnimation
                    PropertyAnimation {
                        id: rotAnimation_rotation
                        target: deleg
                        property: "rotation"
                        from: 0
                        to: 180
                        duration: PQCSettings.imageviewAnimationDuration*100
                    }
                    PropertyAnimation {
                        id: rotAnimation_opacity
                        target: deleg
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: PQCSettings.imageviewAnimationDuration*100
                    }
                    onStarted: {
                        deleg.z = image_top.curZ+1
                    }
                    onFinished: {
                        if(Math.abs(deleg.rotation%360) > 1e-6) {

                            // stop any possibly running video
                            deleg.stopVideoAndReset()

                            deleg.visible = false
                            deleg.rotation = 0
                            deleg.z = image_top.curZ-5

                        }
                    }
                }

                // animation to show the image
                ParallelAnimation {
                    id: explosionAnimation
                    PropertyAnimation {
                        id: explosionAnimation_scale
                        target: deleg
                        property: "scale"
                        from: 1
                        to: 2
                        duration: PQCSettings.imageviewAnimationDuration*100
                    }
                    PropertyAnimation {
                        id: explosionAnimation_opacity
                        target: deleg
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: PQCSettings.imageviewAnimationDuration*90
                    }
                    onStarted: {
                        deleg.z = image_top.curZ+1
                    }
                    onFinished: {
                        if(Math.abs(deleg.scale-1) > 1e-6) {

                            // stop any possibly running video
                            deleg.stopVideoAndReset()

                            deleg.visible = false
                            deleg.scale = 1

                            deleg.z = image_top.curZ-5

                        }
                    }
                }

                Timer {
                    id: selectNewRandomAnimation
                    interval: 50
                    onTriggered: {
                        var animValues = ["opacity","x","y","explosion","implosion","rotation"]
                        randomAnimation = animValues[Math.floor(Math.random()*animValues.length)]
                    }
                }

                // show the image
                function showImage() {

                    image_top.currentlyVisibleIndex = itemIndex
                    image_top.imageFinishedLoading(itemIndex)

                    rotationZoomResetWithoutAnimation()

                    var anim = PQCSettings.imageviewAnimationType
                    if(anim === "random")
                        anim = randomAnimation

                    if(anim === "opacity" || anim === "explosion" || anim === "implosion") {

                        opacityAnimation.stop()

                        opacity = 0
                        opacityAnimation.from = 0
                        opacityAnimation.to = 1

                        opacityAnimation.restart()

                    } else if(anim === "x") {

                        xAnimation.stop()

                        // the from value depends on whether we go forwards or backwards in the folder
                        xAnimation.from = -width
                        if(visibleIndexPrevCur[1] === -1 || visibleIndexPrevCur[0] > visibleIndexPrevCur[1])
                            xAnimation.from = width

                        xAnimation.to = 0

                        xAnimation.restart()

                    } else if(anim === "y") {

                        yAnimation.stop()

                        // the from value depends on whether we go forwards or backwards in the folder
                        yAnimation.from = -height
                        if(visibleIndexPrevCur[1] === -1 || visibleIndexPrevCur[0] > visibleIndexPrevCur[1])
                            yAnimation.from = height

                        yAnimation.to = 0

                        yAnimation.restart()

                    } else if(anim === "rotation") {

                        rotAnimation.stop()

                        rotAnimation_rotation.from = -180
                        rotAnimation_rotation.to = 0

                        if(visibleIndexPrevCur[1] === -1 || visibleIndexPrevCur[0] > visibleIndexPrevCur[1]) {
                            rotAnimation_rotation.from = 180
                            rotAnimation_rotation.to = 0
                        }

                        rotAnimation_opacity.from = 0
                        rotAnimation_opacity.to = 1

                        rotAnimation.restart()

                    }


                    z = image_top.curZ
                    visible = true

                    // (re-)start any video
                    deleg.restartVideoIfAutoplay()

                    image_top.curZ += 1

                    image_top.currentScale = deleg.imageScale
                    image_top.currentRotation = deleg.imageRotation
                    image_top.currentResolution = deleg.imageResolution

                    if(PQCSettings.imageviewAnimationType === "random")
                        selectNewRandomAnimation.restart()

                }

                // hide the image
                function hideImage() {

                    var anim = PQCSettings.imageviewAnimationType
                    if(anim === "random")
                        anim = randomAnimation

                    if(anim === "opacity") {

                        opacityAnimation.stop()

                        opacityAnimation.from = opacity
                        opacityAnimation.to = 0

                        opacityAnimation.restart()

                    } else if(anim === "x") {

                        xAnimation.stop()

                        xAnimation.from = 0
                        // the to value depends on whether we go forwards or backwards in the folder
                        xAnimation.to = width*(deleg.imageScale/deleg.defaultScale)
                        if(visibleIndexPrevCur[1] === -1 || visibleIndexPrevCur[0] > visibleIndexPrevCur[1])
                            xAnimation.to *= -1

                        xAnimation.restart()

                    } else if(anim === "y") {

                        yAnimation.stop()

                        yAnimation.from = 0
                        // the to value depends on whether we go forwards or backwards in the folder
                        yAnimation.to = height*(deleg.imageScale/deleg.defaultScale)
                        if(visibleIndexPrevCur[1] === -1 || visibleIndexPrevCur[0] > visibleIndexPrevCur[1])
                            yAnimation.to *= -1

                        yAnimation.restart()

                    } else if(anim === "explosion") {

                        explosionAnimation.stop()

                        explosionAnimation_scale.from = 1
                        explosionAnimation_scale.to = 2

                        explosionAnimation.restart()

                    } else if(anim === "implosion") {

                        explosionAnimation.stop()

                        explosionAnimation_scale.from = 1
                        explosionAnimation_scale.to = 0

                        explosionAnimation.restart()

                    } else if(anim === "rotation") {

                        rotAnimation.stop()

                        rotAnimation_rotation.from = 0
                        rotAnimation_rotation.to = 180

                        if(visibleIndexPrevCur[1] === -1 || visibleIndexPrevCur[0] > visibleIndexPrevCur[1]) {
                            rotAnimation_rotation.from = 0
                            rotAnimation_rotation.to = -180
                        }

                        rotAnimation_opacity.from = 1
                        rotAnimation_opacity.to = 0

                        rotAnimation.restart()

                    }

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

    function showFirst() {
        if(PQCFileFolderModel.countMainView !== 0)
            PQCFileFolderModel.currentIndex = 0
    }

    function showLast() {
        if(PQCFileFolderModel.countMainView !== 0)
            PQCFileFolderModel.currentIndex = PQCFileFolderModel.countMainView-1
    }

}
