/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

import QtQuick

import PQCFileFolderModel
import PQCNotify
import PQCScriptsImages

import "components"
import "../elements"

Item {

    id: loader_top

    width: deleg.width
    height: deleg.height

    property string imageSource: PQCFileFolderModel.entriesMainView[itemIndex]

    // some image properties
    property int imageRotation: 0
    property bool rotatedUpright: (Math.abs(imageRotation%180)!=90)
    property real imageScale: defaultScale
    property real defaultWidth
    property real defaultHeight
    property real defaultScale: 1
    property size imageResolution: Qt.size(0,0)

    property int imagePosX: 0
    property int imagePosY: 0
    property bool imageMirrorH: false
    property bool imageMirrorV: false
    property bool imageFullyShown: false

    onImageResolutionChanged: {
        if(PQCFileFolderModel.currentIndex===index)
            image_top.currentResolution = imageResolution
    }

    // some signals
    signal zoomInForKenBurns()
    signal zoomActualWithoutAnimation()
    signal zoomResetWithoutAnimation()
    signal rotationResetWithoutAnimation()
    signal rotationZoomResetWithoutAnimation()
    signal loadScaleRotation()
    signal stopVideoAndReset()
    signal restartVideoIfAutoplay()
    signal moveViewToCenter()
    signal resetToDefaults()

    property bool listenToClicksOnImage: false

    property bool videoLoaded: false
    property bool videoPlaying: false
    property real videoDuration: 0.0
    property real videoPosition: 0.0
    property bool videoHasAudio: false
    signal videoTogglePlay()
    signal videoToPos(var s)
    signal imageClicked()

    onVideoPlayingChanged: {
        if(PQCFileFolderModel.currentIndex===index)
            image_top.currentlyShowingVideo = loader_top.videoPlaying
    }
    onVideoHasAudioChanged: {
        if(PQCFileFolderModel.currentIndex===index)
            image_top.currentlyShowingVideoHasAudio = loader_top.videoHasAudio
    }

    Component.onCompleted: {
        image_top.currentlyShowingVideo = loader_top.videoPlaying
        image_top.currentlyShowingVideoHasAudio = loader_top.videoHasAudio
    }

    Connections {

        target: deleg

        function onShouldBeShownChanged() {
            if(shouldBeShown) {
                if(hasBeenSetup) {
                    showImage()
                    resetToDefaults()
                    moveViewToCenter()
                }
            } else {
                hideImage()
            }
        }
        function onHasBeenSetupChanged() {
            if(hasBeenSetup && shouldBeShown) {
                showImage()
                resetToDefaults()
                moveViewToCenter()
            }
        }

    }

    // react to user commands
    Connections {

        target: image_top

        function onZoomIn(wheelDelta) {
            if(PQCFileFolderModel.currentIndex===deleg.itemIndex) {

                if(PQCNotify.faceTagging || PQCNotify.showingPhotoSphere) return

                // compute zoom factor based on wheel movement (if done by mouse)
                var zoomfactor
                if(wheelDelta !== undefined)
                    zoomfactor = Math.max(1.01, Math.min(1.3, 1+Math.abs(Math.min(0.002, (0.3/wheelDelta.y))*PQCSettings.imageviewZoomSpeed)))
                else
                    zoomfactor = Math.max(1.01, Math.min(1.3, 1+PQCSettings.imageviewZoomSpeed*0.01))

                if(PQCSettings.imageviewZoomMaxEnabled)
                    loader_top.imageScale = Math.min(PQCSettings.imageviewZoomMax/100, loader_top.imageScale*zoomfactor)
                else
                    loader_top.imageScale = Math.min(25, loader_top.imageScale*zoomfactor)
            }
        }
        function onZoomOut(wheelDelta) {
            if(PQCFileFolderModel.currentIndex===deleg.itemIndex) {

                if(PQCNotify.faceTagging || PQCNotify.showingPhotoSphere) return

                // compute zoom factor based on wheel movement (if done by mouse)
                var zoomfactor
                if(wheelDelta !== undefined)
                    zoomfactor = Math.max(1.01, Math.min(1.3, 1+Math.abs(Math.min(0.002, (0.3/wheelDelta.y))*PQCSettings.imageviewZoomSpeed)))
                else
                    zoomfactor = Math.max(1.01, Math.min(1.3, 1+PQCSettings.imageviewZoomSpeed*0.01))

                if(PQCSettings.imageviewZoomMinEnabled)
                    loader_top.imageScale = Math.max(loader_top.defaultScale*(PQCSettings.imageviewZoomMin/100), loader_top.imageScale/zoomfactor)
                else
                    loader_top.imageScale = Math.max(0.01, loader_top.imageScale/zoomfactor)
            }
        }
        function onZoomReset() {

            if(PQCNotify.faceTagging || PQCNotify.showingPhotoSphere) return

            if(PQCFileFolderModel.currentIndex===deleg.itemIndex)
                loader_top.imageScale = Qt.binding(function() { return loader_top.defaultScale } )
        }
        function onZoomActual() {

            if(PQCNotify.faceTagging || PQCNotify.showingPhotoSphere) return

            if(PQCFileFolderModel.currentIndex===deleg.itemIndex)
                loader_top.imageScale = 1
        }
        function onRotateClock() {

            if(PQCNotify.faceTagging || PQCNotify.showingPhotoSphere) return

            if(PQCFileFolderModel.currentIndex===deleg.itemIndex)
                loader_top.imageRotation += 90
        }
        function onRotateAntiClock() {

            if(PQCNotify.faceTagging || PQCNotify.showingPhotoSphere) return

            if(PQCFileFolderModel.currentIndex===deleg.itemIndex)
                loader_top.imageRotation -= 90
        }
        function onRotateReset() {

            if(PQCNotify.faceTagging || PQCNotify.showingPhotoSphere) return

            if(PQCFileFolderModel.currentIndex===deleg.itemIndex) {
                // rotate to the nearest (rotation%360==0) degrees
                var offset = loader_top.imageRotation%360
                if(offset == 180 || offset == 270)
                    loader_top.imageRotation += (360-offset)
                else if(offset == 90)
                    loader_top.imageRotation -= 90
                else if(offset == -90)
                    loader_top.imageRotation += 90
                else if(offset == -180 || offset == -270)
                    loader_top.imageRotation -= (360+offset)
            }
        }

        function onReloadImage() {
            if(PQCFileFolderModel.currentIndex===index)
                reloadTheImage()
        }

    }

    Connections {

        target: PQCSettings

        function onImageviewColorSpaceDefaultChanged() {
            if(PQCFileFolderModel.currentIndex===index)
                reloadTheImage()
        }

    }

    function reloadTheImage() {
        image_loader.active = false
        image_loader.active = true
        minimap_loader.active = false
        minimap_loader.active = true
    }

    // this ensures that if the image is no longer visible and more than 2 entries away from the current one
    // then the loader's active property is set to false (and consequently all memory freed)
    // this is done inside the sourceComponent as non-active loaders don't need to check this
    Connections {
        target: PQCFileFolderModel
        function onCurrentIndexChanged() {
            PQCNotify.isMotionPhoto = false
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

        rebound: Transition {
            NumberAnimation {
                properties: "x,y"
                // we set this duration to 0 for slideshows as for certain effects (e.g. ken burns) we rather have an immediate return
                duration: PQCNotify.slideshowRunning ? 0 : 250
                easing.type: Easing.OutQuad
            }
        }

        interactive: !PQCNotify.faceTagging && !PQCNotify.showingPhotoSphere && !PQCNotify.slideshowRunning

        contentX: loader_top.imagePosX
        onContentXChanged: {
            if(loader_top.imagePosX !== contentX)
                loader_top.imagePosX = contentX
        }
        contentY: loader_top.imagePosY
        onContentYChanged: {
            if(loader_top.imagePosY !== contentY)
                loader_top.imagePosY = contentY
        }

        Connections {

            target: PQCNotify

            function onMouseWheel(angleDelta, modifiers) {
                if(PQCSettings.imageviewUseMouseWheelForImageMove || PQCNotify.faceTagging || PQCNotify.showingPhotoSphere)
                    return
                flickable.interactive = false
                reEnableInteractive.restart()
            }

            function onMousePressed(mods, button, pos) {

                if(!PQCSettings.imageviewUseMouseLeftButtonForImageMove && !PQCNotify.faceTagging && !PQCNotify.showingPhotoSphere) {
                    reEnableInteractive.stop()
                    flickable.interactive = false
                }

                if(PQCFileFolderModel.currentIndex !== index)
                    return

                var locpos = flickable_content.mapFromItem(fullscreenitem, pos.x, pos.y)

                if(PQCSettings.interfaceCloseOnEmptyBackground) {
                    if(locpos.x < 0 || locpos.y < 0 || locpos.x > flickable_content.width || locpos.y > flickable_content.height)
                        toplevel.close()
                    return
                }

                if(PQCSettings.interfaceNavigateOnEmptyBackground) {
                    if(locpos.x < 0 || (locpos.x < flickable_content.width/2 && (locpos.y < 0 || locpos.y > flickable_content.height)))
                        image.showPrev()
                    else if(locpos.x > flickable_content.width || (locpos.x > flickable_content.width/2 && (locpos.y < 0 || locpos.y > flickable_content.height)))
                        image.showNext()
                    return
                }

                if(PQCSettings.interfaceWindowDecorationOnEmptyBackground) {
                    if(locpos.x < 0 || locpos.y < 0 || locpos.x > flickable_content.width || locpos.y > flickable_content.height)
                        PQCSettings.interfaceWindowDecoration = !PQCSettings.interfaceWindowDecoration
                    return
                }

            }

            function onMouseReleased() {
                if(!PQCSettings.imageviewUseMouseLeftButtonForImageMove && !PQCNotify.faceTagging && !PQCNotify.showingPhotoSphere) {
                    reEnableInteractive.restart()
                }
            }

        }

        Timer {
            id: reEnableInteractive
            interval: 100
            repeat: false
            onTriggered:
                flickable.interactive = Qt.binding(function() { return !PQCNotify.faceTagging && !PQCNotify.showingPhotoSphere && !PQCNotify.slideshowRunning })
        }

        // the container for the content
        Item {
            id: flickable_content

            x: Math.max(0, (flickable.width-width)/2)
            y: Math.max(0, (flickable.height-height)/2)
            width: (loader_top.rotatedUpright ? image_wrapper.width : image_wrapper.height)*image_wrapper.scale
            height: (loader_top.rotatedUpright ? image_wrapper.height : image_wrapper.width)*image_wrapper.scale

            // wrapper for the image
            // we need both this and the container to be able to properly hadle
            // all scaling and rotations while having the flickable properly flick the image
            Item {

                id: image_wrapper

                y: (loader_top.rotatedUpright ?
                        (height*scale-height)/2 :
                        (-(image_wrapper.height - image_wrapper.width)/2 + (width*scale-width)/2))
                x: (loader_top.rotatedUpright ?
                        (width*scale-width)/2 :
                        (-(image_wrapper.width - image_wrapper.height)/2 + (height*scale-height)/2))

                // some properties
                property real prevW: loader_top.defaultWidth
                property real prevH: loader_top.defaultHeight
                property real prevScale: scale
                property bool startupScale: false

                property real kenBurnsZoomFactor: loader_top.defaultScale

                rotation: 0
                scale: loader_top.defaultScale

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
                            timer_busyloading.stop()
                            busyloading.hide()
                            var tmp = image_wrapper.computeDefaultScale()
                            if(Math.abs(tmp-1) > 1e-6)
                                image_wrapper.startupScale = true
                            loader_top.defaultWidth = width*loader_top.defaultScale
                            loader_top.defaultHeight = height*loader_top.defaultScale
                            loader_top.defaultScale = 0.99999999*tmp
                            image_top.defaultScale = loader_top.defaultScale
                            deleg.hasBeenSetup = true
                        }
                    } else if(PQCFileFolderModel.currentIndex === index)
                        timer_busyloading.restart()
                }

                // the actual image
                Loader {

                    id: image_loader

                    Component.onCompleted: {
                        image_top.currentFileInside = 0
                        loader_top.listenToClicksOnImage = false
                        loader_top.videoPlaying = false
                        loader_top.videoLoaded = false
                        loader_top.videoDuration = 0
                        loader_top.videoPosition = 0
                        loader_top.videoHasAudio = false
                        image_top.currentlyShowingVideo = false
                        if(PQCScriptsImages.isPDFDocument(loader_top.imageSource))
                            source = "imageitems/PQDocument.qml"
                        else if(PQCScriptsImages.isArchive(loader_top.imageSource))
                            source = "imageitems/PQArchive.qml"
                        else if(PQCScriptsImages.isMpvVideo(loader_top.imageSource)) {
                            source = "imageitems/PQVideoMpv.qml"
                            loader_top.listenToClicksOnImage = true
                            loader_top.videoPlaying = true
                            loader_top.videoLoaded = true
                        } else if(PQCScriptsImages.isQtVideo(loader_top.imageSource)) {
                            source = "imageitems/PQVideoQt.qml"
                            loader_top.listenToClicksOnImage = true
                            loader_top.videoLoaded = true
                        } else if(PQCScriptsImages.isItAnimated(loader_top.imageSource)) {
                            source = "imageitems/PQImageAnimated.qml"
                            loader_top.listenToClicksOnImage = true
                        } else if(PQCScriptsImages.isSVG(loader_top.imageSource)) {
                            source = "imageitems/PQSVG.qml"
                        } else if(PQCScriptsImages.isPhotoSphere(loader_top.imageSource)) {
                            source = "imageitems/PQPhotoSphere.qml"
                        } else
                            source = "imageitems/PQImageNormal.qml"
                    }

                }

                PQBarCodes {
                    id: barcodes
                }

                PQFaceTracker {
                    id: facetracker
                }

                PQFaceTagger {
                    id: facetagger
                }

                Loader {
                    id: minimap_loader
                    active: PQCFileFolderModel.currentIndex===index && PQCSettings.imageviewShowMinimap
                    asynchronous: true
                    source: "components/" + (PQCSettings.interfaceMinimapPopout ? "PQMinimapPopout.qml" : "PQMinimap.qml")
                }

                // scaling animation
                PropertyAnimation {
                    id: scaleAnimation
                    target: image_wrapper
                    property: "scale"
                    from: image_wrapper.scale
                    to: loader_top.imageScale
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
                        if(Math.abs(image_wrapper.scale-loader_top.defaultScale) < 1e-6) {

                            loader_top.defaultScale = 0.99999999*tmp
                            loader_top.rotationZoomResetWithoutAnimation()

                        } else

                            loader_top.defaultScale = 0.99999999*tmp

                        if(PQCFileFolderModel.currentIndex === index)
                            image.defaultScale = loader_top.defaultScale
                    }
                }

                PropertyAnimation {
                    id: animateX
                    target: flickable
                    property: "contentX"
                    duration: 200
                }

                PropertyAnimation {
                    id: animateY
                    target: flickable
                    property: "contentY"
                    duration: 200
                }

                Connections {
                    target: fullscreenitem

                    function onWidthChanged() {
                        resetDefaults.restart()
                    }

                    function onHeightChanged() {
                        resetDefaults.restart()
                    }
                }

                Connections {

                    target: image_top

                    function onPlayPauseAnimationVideo() {
                        loader_top.videoTogglePlay()
                    }

                    function onMoveView(direction) {

                        if(PQCNotify.showingPhotoSphere)
                            return

                        if(direction === "left")
                            flickable.flick(1000,0)
                        else if(direction === "right")
                            flickable.flick(-1000,0)
                        else if(direction === "up")
                            flickable.flick(0,1000)
                        else if(direction === "down")
                            flickable.flick(0,-1000)
                        else if(direction === "leftedge") {
                            animateX.stop()
                            animateX.from = flickable.contentX
                            animateX.to = 0
                            animateX.start()
                        } else if(direction === "rightedge") {
                            animateX.stop()
                            animateX.from = flickable.contentX
                            animateX.to = flickable.contentWidth-flickable.width
                            animateX.start()
                        } else if(direction === "topedge") {
                            animateY.stop()
                            animateY.from = flickable.contentY
                            animateY.to = 0
                            animateY.start()
                        } else if(direction === "bottomedge") {
                            animateY.stop()
                            animateY.from = flickable.contentY
                            animateY.to = flickable.contentHeight-flickable.height
                            animateY.start()
                        }

                    }

                }

                // connect image wrapper to some of its properties
                Connections {

                    target: loader_top

                    function onImageScaleChanged() {
                        if(image_wrapper.startupScale) {
                            image_wrapper.startupScale = false
                            image_wrapper.scale = loader_top.imageScale
                        } else {
                            scaleAnimation.from = image_wrapper.scale
                            scaleAnimation.to = loader_top.imageScale
                            scaleAnimation.restart()
                        }
                    }

                    function onRotationZoomResetWithoutAnimation() {

                        if(PQCNotify.showingPhotoSphere)
                            return

                        scaleAnimation.stop()
                        rotationAnimation.stop()

                        image_wrapper.rotation = 0
                        loader_top.imageRotation = 0
                        image_wrapper.scale = loader_top.defaultScale
                        loader_top.imageScale = image_wrapper.scale

                    }

                    function onZoomActualWithoutAnimation() {

                        if(PQCNotify.showingPhotoSphere)
                            return

                        scaleAnimation.stop()

                        image_wrapper.scale = 1
                        loader_top.imageScale = image_wrapper.scale

                    }

                    function onZoomInForKenBurns() {

                        // this function might be called more than once
                        // this check makes sure that we only do this once
                        if(image_top.width < flickable.contentWidth || image_top.height < flickable.contentHeight)
                            return

                        scaleAnimation.stop()

                        // figure out whether the image is much wider or much higher than the other dimension

                        var facW = 1
                        var facH = 1

                        if(flickable.contentWidth > 0)
                            facW = image_top.width/flickable.contentWidth
                        if(flickable.contentHeight > 0)
                            facH = image_top.height/flickable.contentHeight

                        // small images are not scaled as much as larger ones
                        if(loader_top.defaultScale > 0.99)
                            image_wrapper.kenBurnsZoomFactor = loader_top.defaultScale * Math.max(facW, facH)*1.05
                        else
                            image_wrapper.kenBurnsZoomFactor = loader_top.defaultScale * Math.max(facW, facH)*1.2

                        // set scale factors
                        image_wrapper.scale = image_wrapper.kenBurnsZoomFactor
                        loader_top.imageScale = image_wrapper.scale

                    }

                    function onLoadScaleRotation() {

                        if(PQCNotify.showingPhotoSphere)
                            return

                        if((PQCSettings.imageviewRememberZoomRotationMirror && (loader_top.imageSource in image_top.rememberChanges)) ||
                                ((PQCSettings.imageviewPreserveZoom || PQCSettings.imageviewPreserveRotation ||
                                  PQCSettings.imageviewPreserveMirror) && image_top.reuseChanges.length > 1)) {

                            var vals;
                            if(PQCSettings.imageviewRememberZoomRotationMirror && (loader_top.imageSource in image_top.rememberChanges))
                                vals = image_top.rememberChanges[loader_top.imageSource]
                            else
                                vals = image_top.reuseChanges

                            if(PQCSettings.imageviewRememberZoomRotationMirror || PQCSettings.imageviewPreserveZoom) {
                                image_wrapper.scale = vals[2]
                                loader_top.imageScale = vals[2]
                            }

                            if(PQCSettings.imageviewRememberZoomRotationMirror || PQCSettings.imageviewPreserveRotation) {
                                image_wrapper.rotation = vals[3]
                                loader_top.imageRotation = vals[3]
                            } else {
                                image_wrapper.rotation = 0
                                loader_top.imageRotation = 0
                            }

                            if(image_loader.item != null && (PQCSettings.imageviewRememberZoomRotationMirror || PQCSettings.imageviewPreserveMirror))
                                image_loader.item.setMirrorHV(vals[4], vals[5])
                            else
                                image_loader.item.setMirrorHV(false, false)

                            flickable.contentX = vals[0]
                            flickable.contentY = vals[1]
                            flickable.returnToBounds()

                        } else if(!PQCSettings.imageviewAlwaysActualSize) {

                            scaleAnimation.stop()
                            rotationAnimation.stop()

                            image_wrapper.rotation = 0
                            loader_top.imageRotation = 0
                            if(image_loader.item)
                                image_loader.item.setMirrorHV(false, false)
                            image_wrapper.scale = loader_top.defaultScale
                            loader_top.imageScale = image_wrapper.scale

                        }

                    }

                    function onImageRotationChanged() {
                        if(PQCFileFolderModel.currentIndex===index) {
                            rotationAnimation.stop()
                            rotationAnimation.from = image_wrapper.rotation
                            rotationAnimation.to = loader_top.imageRotation
                            rotationAnimation.restart()
                            var oldDefault = loader_top.defaultScale
                            loader_top.defaultScale = 0.99999999*image_wrapper.computeDefaultScale()
                            if(Math.abs(loader_top.imageScale-oldDefault) < 1e-6)
                                loader_top.imageScale = loader_top.defaultScale
                            image.defaultScale = loader_top.defaultScale
                        }
                    }

                    function onMoveViewToCenter() {

                        if(PQCNotify.showingPhotoSphere)
                            return

                        if(PQCSettings.imageviewRememberZoomRotationMirror || PQCSettings.imageviewPreserveZoom ||
                                PQCSettings.imageviewPreserveRotation || PQCSettings.imageviewPreserveMirror)
                            return
                        if(flickable.width < flickable.contentWidth)
                            flickable.contentX = (flickable.contentWidth-flickable.width)/2
                        if(flickable.height < flickable.contentHeight)
                            flickable.contentY = (flickable.contentHeight-flickable.height)/2
                    }

                    function onResetToDefaults() {
                        resetDefaults.triggered()
                    }

                }

                Connections {
                    target: PQCSettings

                    function onThumbnailsVisibilityChanged() {
                        resetDefaults.restart()
                    }

                }

                // calculate the default scale based on the current rotation
                function computeDefaultScale() {
                    if(loader_top.rotatedUpright)
                        return Math.min(1, Math.min((flickable.width/width), (flickable.height/height)))
                    return Math.min(1, Math.min((flickable.width/height), (flickable.height/width)))
                }

                Timer {
                    id: hidecursor
                    interval: PQCSettings.imageviewHideCursorTimeout*1000
                    repeat: false
                    running: true
                    onTriggered: {
                        if(PQCSettings.imageviewHideCursorTimeout === 0)
                            return
                        if(contextmenu.visible)
                            hidecursor.restart()
                        else
                            imagemouse.cursorShape = Qt.BlankCursor
                    }
                }

            }

        }

    }

    PQMouseArea {
        id: imagemouse
        anchors.fill: parent
        anchors.leftMargin: -flickable_content.x
        anchors.rightMargin: -flickable_content.x
        anchors.topMargin: -flickable_content.y
        anchors.bottomMargin: -flickable_content.y
        hoverEnabled: true
        propagateComposedEvents: true
        acceptedButtons: Qt.AllButtons
        doubleClickThreshold: PQCSettings.interfaceDoubleClickThreshold
        onPositionChanged: (mouse) => {
            cursorShape = Qt.ArrowCursor
            hidecursor.restart()
            var pos = imagemouse.mapToItem(fullscreenitem, mouse.x, mouse.y)
            PQCNotify.mouseMove(pos.x, pos.y)
        }
        onWheel: (wheel) => {
            wheel.accepted = !PQCSettings.imageviewUseMouseWheelForImageMove
            PQCNotify.mouseWheel(wheel.angleDelta, wheel.modifiers)
        }
        onPressed: (mouse) => {

            var locpos = flickable_content.mapFromItem(fullscreenitem, mouse.x, mouse.y)

            if(PQCSettings.interfaceCloseOnEmptyBackground &&
                  (locpos.x < flickable_content.x ||
                   locpos.y < flickable_content.y ||
                   locpos.x > flickable_content.x+flickable_content.width ||
                   locpos.y > flickable_content.y+flickable_content.height)) {

                toplevel.close()
                return

            }

            if(PQCSettings.interfaceNavigateOnEmptyBackground) {
                if(locpos.x < flickable_content.x || (locpos.x < flickable_content.x+flickable_content.width/2 &&
                   (locpos.y < flickable_content.y || locpos.y > flickable_content.y+flickable_content.height))) {

                    image.showPrev()
                    return

                } else if(locpos.x > flickable_content.x+flickable_content.width || (locpos.x > flickable_content.x+flickable_content.width/2 &&
                          (locpos.y < flickable_content.y || locpos.y > flickable_content.y+flickable_content.height))) {

                    image.showNext()
                    return

                }
            }

            if(PQCSettings.interfaceWindowDecorationOnEmptyBackground &&
               (locpos.x < flickable_content.x ||
                locpos.y < flickable_content.y ||
                locpos.x > flickable_content.x+flickable_content.width ||
                locpos.y > flickable_content.y+flickable_content.height)) {

                PQCSettings.interfaceWindowDecoration = !PQCSettings.interfaceWindowDecoration
                return

            }

            if(PQCNotify.barcodeDisplayed && mouse.button === Qt.LeftButton)
                image.barcodeClick()
            if(PQCSettings.imageviewUseMouseLeftButtonForImageMove && mouse.button === Qt.LeftButton && !PQCNotify.faceTagging) {
                mouse.accepted = false
                return
            }
            var pos = imagemouse.mapToItem(fullscreenitem, mouse.x, mouse.y)
            PQCNotify.mousePressed(mouse.modifiers, mouse.button, pos)
        }
        onMouseDoubleClicked: (mouse) => {
            var pos = imagemouse.mapToItem(fullscreenitem, mouse.x, mouse.y)
            PQCNotify.mouseDoubleClicked(mouse.modifiers, mouse.button, pos)
        }

        onReleased: (mouse) => {
            if(mouse.button === Qt.LeftButton && loader_top.listenToClicksOnImage)
                loader_top.imageClicked()
            else {
                var pos = imagemouse.mapToItem(fullscreenitem, mouse.x, mouse.y)
                PQCNotify.mouseReleased(mouse.modifiers, mouse.button, pos)
            }
        }
    }

    // we don't use a pinch area as we want to pass through flick events, something a pincharea cannot do
    MultiPointTouchArea {

        anchors.fill: parent

        mouseEnabled: false

        enabled: !PQCNotify.faceTagging && !PQCNotify.showingPhotoSphere && !PQCNotify.slideshowRunning

        property var initialPts: []
        property real initialScale

        onPressed: (points) => {

            pressAndHoldTimeout.touchPos = points[0]

            if(points.length === 2)
                initialPts = [Qt.point(points[0].x, points[0].y), Qt.point(points[1].x, points[1].y)]
            else {
                initialPts.push(Qt.point(points[0].x, points[0].y))
                if(points.length === 1)
                    pressAndHoldTimeout.restart()
            }

            initialScale = image_wrapper.scale

        }
        onUpdated: (points) => {

            if(points.length === 1) {

                if(Math.abs(points[0].x - pressAndHoldTimeout.touchPos.x) > 20 || Math.abs(points[0].y - pressAndHoldTimeout.touchPos.y) > 20)
                    pressAndHoldTimeout.stop()

                flickable.flick(points[0].velocity.x*1.5, points[0].velocity.y*1.5)

            } else if(points.length === 2 && initialPts.length == 2) {

                pressAndHoldTimeout.stop()

                // compute the rate of change initiated by this pinch
                var startLength = Math.sqrt(Math.pow(initialPts[0].x-initialPts[1].x, 2) + Math.pow(initialPts[0].y-initialPts[1].y, 2))
                var curLength = Math.sqrt(Math.pow(points[0].x-points[1].x, 2) + Math.pow(points[0].y-points[1].y, 2))

                if(startLength > 0 && curLength > 0) {

                    var val = initialScale * (curLength / startLength)

                    if(PQCSettings.imageviewZoomMaxEnabled) {
                        var max = PQCSettings.imageviewZoomMax/100
                        if(val > max)
                            val = max
                        else if(val > 25)
                            val = 25
                    }

                    if(PQCSettings.imageviewZoomMinEnabled) {
                        var min = loader_top.defaultScale*(PQCSettings.imageviewZoomMin/100)
                        if(val < min)
                            val = min
                        else if(val < 0.01)
                            val = 0.01
                    }

                    image_wrapper.scale = val
                    loader_top.imageScale = val

                }

            } else
                pressAndHoldTimeout.stop()

        }

        onReleased: (points) => {
            pressAndHoldTimeout.stop()
            initialPts = []
        }

        Timer {
            id: pressAndHoldTimeout
            interval: 1000
            property point touchPos
            onTriggered: {
                shortcuts.item.executeInternalFunction("__contextMenuTouch", touchPos)
            }
        }

    }

    // animation to show the image
    PropertyAnimation {
        id: opacityAnimation
        target: deleg
        property: "opacity"
        from: 0
        to: 1
        duration: PQCSettings.imageviewAnimationDuration*100 + (PQCNotify.slideshowRunning&&PQCSettings.slideshowTypeAnimation==="kenburns" ? 500 : 0)
        onFinished: {
            if(deleg.opacity < 1e-6) {

                // stop any possibly running video
                loader_top.stopVideoAndReset()

                // stop any ken burns animations if running
                if(loader_kenburns.item != null)
                    loader_kenburns.item.stopAni()

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
                loader_top.stopVideoAndReset()

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
                loader_top.stopVideoAndReset()

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
                loader_top.stopVideoAndReset()

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
                loader_top.stopVideoAndReset()

                deleg.visible = false
                deleg.scale = 1

                deleg.z = image_top.curZ-5

            }
        }
    }

    Loader {
        id: loader_kenburns
        active: PQCNotify.slideshowRunning && PQCSettings.slideshowTypeAnimation === "kenburns"
        sourceComponent:
            PQKenBurnsSlideshowEffect { }
    }

    Timer {
        id: selectNewRandomAnimation
        interval: 50
        onTriggered: {
            var animValues = ["opacity","x","y","explosion","implosion","rotation"]
            image_top.randomAnimation = animValues[Math.floor(Math.random()*animValues.length)]
        }
    }

    // show the image
    function showImage() {

        // this needs to be checked for early as we set currentlyVisibleIndex in a few lines
        var noPreviousImage = (image_top.currentlyVisibleIndex===-1)

        PQCNotify.barcodeDisplayed = false

        loader_top.imageFullyShown = false

        image_top.currentlyVisibleIndex = deleg.itemIndex
        image_top.imageFinishedLoading(deleg.itemIndex)

        PQCNotify.showingPhotoSphere = PQCScriptsImages.isPhotoSphere(loader_top.imageSource)

        // if a slideshow is running with the ken burns effect
        // then we need to do some special handling
        if(PQCNotify.slideshowRunning && PQCSettings.slideshowTypeAnimation === "kenburns") {

            zoomInForKenBurns()
            flickable.returnToBounds()

            opacityAnimation.stop()

            deleg.opacity = 0
            opacityAnimation.from = 0
            opacityAnimation.to = 1

            opacityAnimation.restart()

        } else {

            // don't pipe showing animation through the property animators
            // when no animation is set or no previous image has been shown
            if(PQCSettings.imageviewAnimationDuration === 0 || noPreviousImage) {

                deleg.opacity = 1

            } else {

                var anim = PQCSettings.imageviewAnimationType
                if(anim === "random")
                    anim = image_top.randomAnimation

                if(anim === "opacity" || anim === "explosion" || anim === "implosion") {

                    opacityAnimation.stop()

                    deleg.opacity = 0
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

            }

        }


        z = image_top.curZ
        deleg.visible = true

        // (re-)start any video
        loader_top.restartVideoIfAutoplay()

        image_top.curZ += 1

        image_top.currentScale = loader_top.imageScale
        image_top.currentRotation = loader_top.imageRotation
        image_top.currentResolution = loader_top.imageResolution

        // these are only done if we are not in a slideshow with the ken burns effect
        if(!PQCNotify.slideshowRunning || !PQCSettings.slideshowTypeAnimation === "kenburns") {

            if(PQCSettings.imageviewAnimationType === "random")
                selectNewRandomAnimation.restart()

            if(PQCSettings.imageviewAlwaysActualSize)
                image_top.zoomActual()

            loader_top.loadScaleRotation()

        }

        loader_top.imageFullyShown = true
        image_top.initialLoadingFinished = true

    }

    // hide the image
    function hideImage() {

        // ignore anything that happened during a slideshow
        if(!PQCNotify.slideshowRunning) {

            if(loader_top.imageFullyShown && (PQCSettings.imageviewRememberZoomRotationMirror || PQCSettings.imageviewPreserveZoom ||
                                         PQCSettings.imageviewPreserveRotation || PQCSettings.imageviewPreserveMirror)) {
                var vals = [loader_top.imagePosX,
                            loader_top.imagePosY,
                            loader_top.imageScale,
                            loader_top.imageRotation,
                            loader_top.imageMirrorH,
                            loader_top.imageMirrorV]
                if(PQCSettings.imageviewRememberZoomRotationMirror)
                    image_top.rememberChanges[loader_top.imageSource] = vals
                if(PQCSettings.imageviewPreserveZoom || PQCSettings.imageviewPreserveRotation || PQCSettings.imageviewPreserveMirror)
                    image_top.reuseChanges = vals
            } else
                // don't delete reuseChanges here, we want to keep those
                delete image_top.rememberChanges[loader_top.imageSource]

        }

        loader_top.imageFullyShown = false

        var anim = PQCSettings.imageviewAnimationType
        if(anim === "random")
            anim = image_top.randomAnimation

        if(anim === "opacity") {

            opacityAnimation.stop()

            opacityAnimation.from = opacity
            opacityAnimation.to = 0

            opacityAnimation.restart()

        } else if(anim === "x") {

            xAnimation.stop()

            xAnimation.from = 0
            // the to value depends on whether we go forwards or backwards in the folder
            xAnimation.to = width*(loader_top.imageScale/loader_top.defaultScale)
            if(visibleIndexPrevCur[1] === -1 || visibleIndexPrevCur[0] > visibleIndexPrevCur[1])
                xAnimation.to *= -1

            xAnimation.restart()

        } else if(anim === "y") {

            yAnimation.stop()

            yAnimation.from = 0
            // the to value depends on whether we go forwards or backwards in the folder
            yAnimation.to = height*(loader_top.imageScale/loader_top.defaultScale)
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
