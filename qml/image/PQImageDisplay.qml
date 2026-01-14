/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Window
import PhotoQt

Loader {
    id: imageloaderitem

    property string containingFolder: ""
    property string lastModified: ""
    property bool imageLoadedAndReady: false
    property bool imageFullyShown: false
    property string imageSource: ""

    property bool thisIsStartupFile: false

    property Item toplevelItem

    signal iAmReady()

    onImageSourceChanged: {
        imageLoadedAndReady = false
        active = false
        active = (imageSource!="")
    }
    active: false
    sourceComponent:
    Item {

        id: loader_top

        width: image_top.width-2*PQCSettings.imageviewMargin
        height: image_top.height-2*PQCSettings.imageviewMargin

        visible: false

        // some image properties
        property int imageRotation: 0
        property bool rotatedUpright: (Math.abs(imageRotation%180)!=90)
        property real imageScale: defaultScale
        property real defaultWidth
        property real defaultHeight
        property real defaultScale: 1
        property size imageResolution: Qt.size(0,0)

        onImageResolutionChanged: {
            if(loader_top.isMainImage)
                PQCConstants.currentImageResolution = imageResolution
        }

        property int imagePosX: 0
        property int imagePosY: 0
        property bool imageMirrorH: false
        property bool imageMirrorV: false

        property bool listenToClicksOnImage: false
        property bool thisIsAPhotoSphere: false
        property bool photoSphereManuallyEntered: false
        property real photoSphereDefaultScaleBackup: 1.0

        property bool videoLoaded: false
        property bool videoHasAudio: false

        // when switching images, either one might be set to the current index, eventually (within milliseconds) both will be
        property bool isMainImage: (PQCConstants.currentImageSource===imageSource || PQCFileFolderModel.currentFile===imageSource || imageloaderitem.thisIsStartupFile)

        onIsMainImageChanged: setGlobalProperties()

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

        signal videoToPos(var s)
        signal imageClicked()
        signal barcodeClick()

        signal finishSetup()

        property bool dontAnimateNextZoom: false

        onVideoHasAudioChanged: {
            if(loader_top.isMainImage)
                PQCConstants.currentlyShowingVideoHasAudio = loader_top.videoHasAudio
        }
        onVideoLoadedChanged: {
            if(loader_top.isMainImage)
                PQCConstants.currentlyShowingVideo = loader_top.videoLoaded
        }

        // keeping the shortcut for rotation pressed triggers it repeatedly very quickly
        // this rate limits the rotation operation to the interval below
        property bool delayImageRotate: false
        Timer {
            id: resetDelayImageRotate
            interval: 250
            onTriggered: {
                loader_top.delayImageRotate = false
            }
        }

        Component.onCompleted: {
            if(imageloaderitem.imageSource != "")
                finishSetup()
        }

        // react to user commands
        Connections {

            target: PQCScriptsShortcuts

            function onSendShortcutZoomIn(mousePos : point, wheelDelta : point) {
                if(loader_top.isMainImage) {

                    if(PQCConstants.faceTaggingMode || PQCConstants.showingPhotoSphere) return

                    if(mousePos.x === -1 || mousePos.y === -1)
                        mousePos = Qt.point(flickable.width/2, flickable.height/2)

                    loader_top.performZoom(mousePos, wheelDelta, true, 0)

                }
            }
            function onSendShortcutZoomOut(mousePos : point, wheelDelta : point) {
                if(loader_top.isMainImage) {

                    if(PQCConstants.faceTaggingMode || PQCConstants.showingPhotoSphere) return

                    if(mousePos.x === -1 || mousePos.y === -1)
                        mousePos = Qt.point(flickable.width/2, flickable.height/2)

                    loader_top.performZoom(mousePos, wheelDelta, false, 0)

                }
            }
            function onSendShortcutZoomReset() {

                if(PQCConstants.faceTaggingMode || PQCConstants.showingPhotoSphere) return

                if(loader_top.isMainImage)
                    loader_top.imageScale = Qt.binding(function() { return loader_top.defaultScale } )

            }
            function onSendShortcutZoomActual() {

                if(PQCConstants.faceTaggingMode || PQCConstants.showingPhotoSphere) return

                if(loader_top.isMainImage) {
                    const fullsize = 1/PQCConstants.devicePixelRatio
                    if(Math.abs(fullsize-loader_top.imageScale) < 1e-6)
                        loader_top.imageScale = loader_top.defaultScale
                    else
                        loader_top.imageScale = fullsize
                }

            }
            function onSendShortcutZoomKenBurns() {

                if(PQCConstants.faceTaggingMode || PQCConstants.showingPhotoSphere) return

                if(loader_top.isMainImage)
                    loader_top.zoomInForKenBurns()

            }
            function onSendShortcutRotateClock() {

                if(PQCConstants.faceTaggingMode || PQCConstants.showingPhotoSphere) return

                // rate limit rotation
                if(loader_top.delayImageRotate) {
                    if(!resetDelayImageRotate.running)
                        resetDelayImageRotate.restart()
                    return
                }
                loader_top.delayImageRotate = true
                resetDelayImageRotate.restart()

                if(loader_top.isMainImage) {
                    loader_top.dontAnimateNextZoom = true
                    loader_top.imageRotation += 90
                }
            }
            function onSendShortcutRotateAntiClock() {

                if(PQCConstants.faceTaggingMode || PQCConstants.showingPhotoSphere) return

                // rate limit rotation
                if(loader_top.delayImageRotate) {
                    if(!resetDelayImageRotate.running)
                        resetDelayImageRotate.restart()
                    return
                }
                loader_top.delayImageRotate = true
                resetDelayImageRotate.restart()

                if(loader_top.isMainImage) {
                    loader_top.dontAnimateNextZoom = true
                    loader_top.imageRotation -= 90
                }
            }
            function onSendShortcutRotateReset() {

                if(PQCConstants.faceTaggingMode || PQCConstants.showingPhotoSphere) return


                if(loader_top.isMainImage) {

                    loader_top.dontAnimateNextZoom = true

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
                    else
                        loader_top.dontAnimateNextZoom = false
                }
            }

        }

        Connections {

            target: PQCNotify

            function onEnterPhotoSphere() {
                if(PQCConstants.showingPhotoSphere || !loader_top.isMainImage || (PQCSettings.filetypesPhotoSphereAutoLoad && loader_top.thisIsAPhotoSphere))
                    return
                loader_top.doEnterPhotoSphere()
            }

            function onExitPhotoSphere() {
                if(!loader_top.isMainImage || (PQCSettings.filetypesPhotoSphereAutoLoad && !loader_top.photoSphereManuallyEntered))
                    return
                loader_top.doExitPhotoSphere()
            }

            function onCurrentImageReload() {
                if(loader_top.isMainImage)
                    loader_top.reloadTheImage()
            }

        }

        function setGlobalProperties() {
            if(loader_top.isMainImage) {
                PQCConstants.currentFileInsideNum = 0
                PQCConstants.currentFileInsideName = ""
                PQCConstants.currentFileInsideTotal = 0
                PQCConstants.currentImageIsPhotoSphere = loader_top.thisIsAPhotoSphere
                PQCConstants.currentlyShowingVideo = loader_top.videoLoaded
                PQCConstants.currentlyShowingVideoHasAudio = loader_top.videoHasAudio
            }
        }

        function doEnterPhotoSphere() {
            loader_top.photoSphereDefaultScaleBackup = loader_top.defaultScale
            loader_top.photoSphereManuallyEntered = true
            loader_top.finishSetup()
            image_wrapper.scale = 1
            loader_top.imageScale = image_wrapper.scale
        }

        function doExitPhotoSphere() {
            loader_top.photoSphereManuallyEntered = false
            loader_top.finishSetup()
            image_wrapper.scale = loader_top.photoSphereDefaultScaleBackup
            loader_top.defaultScale = image_wrapper.scale
            loader_top.imageScale = image_wrapper.scale
        }

        function performZoom(pos : point, wheelDelta : point, zoom_in : bool, forceZoomFactor: real) {

            // stop movement of the image
            flickable.cancelFlick()

            // adjust position from global to image
            // first map to flickable content
            pos = loader_top.mapToItem(flickable_content, pos)
            // then scale to fit actual image item
            pos.x /= image_wrapper.scale
            pos.y /= image_wrapper.scale
            // adjust because of transition origin
            pos.x -= image_wrapper.width/2
            pos.y -= image_wrapper.height/2

            var zoomfactor

            if(Math.abs(forceZoomFactor) > 1e-8) {

                zoomfactor = forceZoomFactor

                if(PQCSettings.imageviewZoomMaxEnabled)
                    zoomfactor = Math.min(loader_top.imageScale*zoomfactor, PQCSettings.imageviewZoomMax/(100*PQCConstants.devicePixelRatio))/loader_top.imageScale

                if(PQCSettings.imageviewZoomMinEnabled)
                    zoomfactor = Math.max(loader_top.imageScale*zoomfactor, loader_top.defaultScale*PQCSettings.imageviewZoomMin/100)/loader_top.imageScale

            } else {

                if(wheelDelta !== undefined) {
                    if(wheelDelta.y > 12)
                        wheelDelta.y = 12
                    else if(wheelDelta.y < -12)
                        wheelDelta.y = -12
                }

                // figure out zoom factor
                var fact

                if(zoom_in) {

                    if(PQCSettings.imageviewZoomSpeedRelative) {

                        // compute zoom factor based on wheel movement (if done by mouse)
                        if(wheelDelta !== undefined && wheelDelta.y !== 0)
                            fact = Math.max(1.01, Math.min(1.3, 1+Math.abs(Math.max(0.002, (0.3/wheelDelta.y))*PQCSettings.imageviewZoomSpeed)))
                        else
                            fact = Math.max(1.01, Math.min(1.3, 1+(PQCSettings.imageviewZoomSpeed*0.01)))

                        if(PQCSettings.imageviewZoomMaxEnabled)
                            zoomfactor = Math.min(PQCSettings.imageviewZoomMax/(100*PQCConstants.devicePixelRatio), loader_top.imageScale*fact)/loader_top.imageScale
                        else
                            zoomfactor = Math.min(25/PQCConstants.devicePixelRatio, loader_top.imageScale*fact)/loader_top.imageScale

                    } else {

                        fact = Math.max(0.01, PQCSettings.imageviewZoomSpeed/(100*PQCConstants.devicePixelRatio))

                        if(PQCSettings.imageviewZoomMaxEnabled)
                            zoomfactor = Math.min(PQCSettings.imageviewZoomMax/(100*PQCConstants.devicePixelRatio), loader_top.imageScale+fact)/loader_top.imageScale
                        else
                            zoomfactor = Math.min(25/PQCConstants.devicePixelRatio, loader_top.imageScale+fact)/loader_top.imageScale

                    }

                } else {

                    if(PQCSettings.imageviewZoomSpeedRelative) {

                        if(wheelDelta !== undefined && wheelDelta.y !== 0)
                            fact = Math.max(1.01, Math.min(1.3, 1+Math.abs(Math.max(0.002, (0.3/Math.abs(wheelDelta.y)))*PQCSettings.imageviewZoomSpeed)))
                        else
                            fact = Math.max(1.01, Math.min(1.3, 1+PQCSettings.imageviewZoomSpeed*0.01))

                        if(PQCSettings.imageviewZoomMinEnabled)
                            zoomfactor = Math.max((loader_top.defaultScale*PQCSettings.imageviewZoomMin)/100, loader_top.imageScale/fact)/loader_top.imageScale
                        else
                            zoomfactor = Math.max(0.01/PQCConstants.devicePixelRatio, loader_top.imageScale/fact)/loader_top.imageScale

                    } else {

                        fact = Math.max(0.01, PQCSettings.imageviewZoomSpeed/(100*PQCConstants.devicePixelRatio))

                        if(PQCSettings.imageviewZoomMinEnabled)
                            zoomfactor = Math.max((loader_top.defaultScale*PQCSettings.imageviewZoomMin)/(100*PQCConstants.devicePixelRatio), loader_top.imageScale-fact)/loader_top.imageScale
                        else
                            zoomfactor = Math.max(0.01/PQCConstants.devicePixelRatio, loader_top.imageScale-fact)/loader_top.imageScale

                    }

                }

            }

            // if we set a custom zoom position, then save that position first
            // reacting to this position and adjusting the position of the image accordingly is
            // done in a Connections located right above the PropertyAnimation with id scaleAnimation
            if(!PQCSettings.imageviewZoomToCenter)
                scaleAnimation.pos = pos

            // update scale factor
            loader_top.imageScale *= zoomfactor

        }

        Connections {

            target: PQCSettings

            function onImageviewColorSpaceDefaultChanged() {
                if(loader_top.isMainImage)
                    loader_top.reloadTheImage()
            }

        }

        function reloadTheImage() {

            if(image_loader_pdf.active) {
                image_loader_pdf.active = false
                image_loader_pdf.active = true
            } else if(image_loader_arc.active) {
                image_loader_arc.active = false
                image_loader_arc.active = true
            } else if(image_loader_mpv.active) {
                image_loader_mpv.active = false
                image_loader_mpv.active = true
            } else if(image_loader_vidqt.active) {
                image_loader_vidqt.active = false
                image_loader_vidqt.active = true
            } else if(image_loader_ani.active) {
                image_loader_ani.active = false
                image_loader_ani.active = true
            } else if(image_loader_svg.active) {
                image_loader_svg.active = false
                image_loader_svg.active = true
            } else if(image_loader_sph.active) {
                image_loader_sph.active = false
                image_loader_sph.active = true
            } else if(image_loader_img.active) {
                image_loader_img.active = false
                image_loader_img.active = true
            }

            minimap_loader.active = false
            minimap_loader.active = true
        }

        Flickable {

            id: flickable

            width: parent.width
            height: parent.height

            contentWidth: flickable_content.width
            contentHeight: flickable_content.height

            boundsMovement: Flickable.DragOverBounds

            visibleArea.onXPositionChanged: {
                if(loader_top.isMainImage)
                    PQCConstants.currentVisibleAreaX = visibleArea.xPosition
            }
            visibleArea.onYPositionChanged: {
                if(loader_top.isMainImage)
                    PQCConstants.currentVisibleAreaY = visibleArea.yPosition
            }
            visibleArea.onWidthRatioChanged: {
                if(loader_top.isMainImage)
                    PQCConstants.currentVisibleAreaWidthRatio = visibleArea.widthRatio
            }
            visibleArea.onHeightRatioChanged: {
                if(loader_top.isMainImage)
                    PQCConstants.currentVisibleAreaHeightRatio = visibleArea.heightRatio
            }

            contentX: loader_top.imagePosX
            contentY: loader_top.imagePosY

            onContentXChanged: {
                if(loader_top.imagePosX !== contentX)
                    loader_top.imagePosX = contentX
                if(loader_top.isMainImage)
                    PQCConstants.currentVisibleContentPos.x = contentX
            }
            onContentYChanged: {
                if(loader_top.imagePosY !== contentY)
                    loader_top.imagePosY = contentY
                if(loader_top.isMainImage)
                    PQCConstants.currentVisibleContentPos.y = contentY
            }

            onContentWidthChanged: {
                if(loader_top.isMainImage)
                    PQCConstants.currentVisibleContentSize.width = contentWidth
            }
            onContentHeightChanged: {
                if(loader_top.isMainImage)
                    PQCConstants.currentVisibleContentSize.height = contentHeight
            }

            // When dragging the image out of bounds and it returning, the visibleArea property of Flickable does not tirgger an update
            // This is causing, e.g., the minimap to not update with the actual position of the view
            // This check here makes sure that we force an update to the position, but only if the image was dragged out of bounds
            // (See the onRunningChanged signal in the rebound animation)
            property bool needToRecheckPosition: false
            onMovementEnded: {
                if(needToRecheckPosition) {
                    flickable.contentX += 1
                    flickable.contentY += 1
                    flickable.contentX -= 1
                    flickable.contentY -= 1
                    needToRecheckPosition = false
                }
            }

            rebound: Transition {
                enabled: !PQCSettings.generalDisableAllAnimations
                NumberAnimation {
                    properties: "x,y"
                    // we set this duration to 0 for slideshows as for certain effects (e.g. ken burns) we rather have an immediate return
                    duration: PQCConstants.slideshowRunning ? 0 : 250
                    easing.type: Easing.OutQuad
                }
                // Signal that the view was dragged out of bounds
                onRunningChanged:
                    flickable.needToRecheckPosition = true
            }

            interactive: !PQCConstants.faceTaggingMode && !PQCConstants.showingPhotoSphere && !PQCConstants.slideshowRunning

            NumberAnimation {
                id: xanim
                target: flickable
                property: "contentX"
                duration: 200
                onStopped:
                    flickable.returnToBounds()
            }
            NumberAnimation {
                id: yanim
                target: flickable
                property: "contentY"
                duration: 200
                onStopped:
                    flickable.returnToBounds()
            }

            Connections {

                target: PQCNotify

                function onMouseWheel(mousePos: point, angleDelta : point, modifiers : int) {
                    if(PQCSettings.imageviewUseMouseWheelForImageMove || PQCConstants.faceTaggingMode || PQCConstants.showingPhotoSphere)
                        return
                    flickable.interactive = false
                    reEnableInteractive.restart()
                }

                function onMousePressed(mods : int, button : string, pos : point) {

                    if(!PQCSettings.imageviewUseMouseLeftButtonForImageMove && !PQCConstants.faceTaggingMode && !PQCConstants.showingPhotoSphere) {
                        reEnableInteractive.stop()
                        flickable.interactive = false
                    }

                    if(!loader_top.isMainImage)
                        return

                    var locpos = flickable_content.mapFromItem(imageloaderitem.toplevelItem, pos.x, pos.y)

                    if(PQCSettings.interfaceCloseOnEmptyBackground) {
                        if(locpos.x < 0 || locpos.y < 0 || locpos.x > flickable_content.width || locpos.y > flickable_content.height)
                            PQCNotify.windowClose()
                        return
                    }

                    if(PQCSettings.interfaceNavigateOnEmptyBackground) {
                        if(locpos.x < 0 || (locpos.x < flickable_content.width/2 && (locpos.y < 0 || locpos.y > flickable_content.height)))
                            image_top.showPrev()
                        else if(locpos.x > flickable_content.width || (locpos.x > flickable_content.width/2 && (locpos.y < 0 || locpos.y > flickable_content.height)))
                            image_top.showNext()
                        return
                    }

                    if(PQCSettings.interfaceWindowDecorationOnEmptyBackground) {
                        if(locpos.x < 0 || locpos.y < 0 || locpos.x > flickable_content.width || locpos.y > flickable_content.height)
                            PQCSettings.interfaceWindowDecoration = !PQCSettings.interfaceWindowDecoration
                        return
                    }

                }

                function onMouseReleased() {
                    if(!PQCSettings.imageviewUseMouseLeftButtonForImageMove && !PQCConstants.faceTaggingMode && !PQCConstants.showingPhotoSphere) {
                        reEnableInteractive.restart()
                    }
                }

                function onCurrentFlickableSetContentX(x : int) {
                    if(loader_top.isMainImage)
                        flickable.contentX = x
                }

                function onCurrentFlickableSetContentY(y : int) {
                    if(loader_top.isMainImage)
                        flickable.contentY = y
                }

                function onCurrentFlickableReturnToBounds() {
                    if(loader_top.isMainImage)
                        flickable.returnToBounds()
                }

                function onCurrentFlickableAnimateContentPosChange(propX : real, propY: real) {

                    if(!loader_top.isMainImage)
                        return

                    xanim.stop()
                    yanim.stop()

                    xanim.from = flickable.contentX
                    yanim.from = flickable.contentY

                    xanim.to = flickable.contentWidth*propX - flickable.width/2
                    yanim.to = flickable.contentHeight*propY - flickable.height/2

                    xanim.restart()
                    yanim.restart()

                }

            }

            Timer {
                id: reEnableInteractive
                interval: 100
                repeat: false
                onTriggered:
                    flickable.interactive = Qt.binding(function() { return !PQCConstants.faceTaggingMode && !PQCConstants.showingPhotoSphere && !PQCConstants.slideshowRunning })
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
                    onStartupScaleChanged: {
                        if(startupScale) resetStartupScale.restart()
                    }

                    Timer {
                        id: resetStartupScale
                        interval: 100
                        onTriggered: {
                            image_wrapper.startupScale = false
                        }
                    }

                    property real kenBurnsZoomFactor: loader_top.defaultScale

                    rotation: 0
                    scale: loader_top.defaultScale

                    signal setMirrorHVToImage(var mirH, var mirV)

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

                        if(loader_top.isMainImage)
                            PQCConstants.currentImageScale = scale

                    }

                    onRotationChanged: {
                        if(PQCSettings.imageviewFitInWindow && Math.abs(image_wrapper.scale-loader_top.defaultScale) < 1e-6) {
                            resetDefaults.resetScale()
                        }
                        if(loader_top.isMainImage)
                            PQCConstants.currentImageRotation = rotation
                    }

                    // react to status changes
                    property int status: Image.Null
                    onStatusChanged: {
                        if(status == Image.Ready) {
                            imageloaderitem.imageLoadedAndReady = true
                            timer_busyloading.stop()
                            busyloading.hide()
                            if(loader_top.isMainImage) {
                                var tmp = image_wrapper.computeDefaultScale()
                                if(Math.abs(tmp-1) > 1e-6)
                                    image_wrapper.startupScale = true
                                loader_top.defaultWidth = width*loader_top.defaultScale
                                loader_top.defaultHeight = height*loader_top.defaultScale
                                loader_top.defaultScale = 0.99999999*tmp
                                PQCConstants.currentImageDefaultScale = loader_top.defaultScale
                                imageloaderitem.iAmReady()
                                loader_top.setUpImageWhenReady()
                            }
                        } else if(loader_top.isMainImage) {
                            timer_busyloading.restart()
                        }
                    }

                    Timer {
                        id: timer_busyloading
                        interval: 500
                        onTriggered: {
                            if(!PQCConstants.slideshowRunning)
                                busyloading.showBusy()
                        }
                    }

                    // BUSY indicator
                    PQWorking {
                        id: busyloading
                        parent: image_top
                        anchors.margins: -PQCSettings.imageviewMargin
                        z: PQCConstants.currentZValue+1
                    }

                    onWidthChanged: {
                        if(imageloaderitem.imageLoadedAndReady) {
                            resetDefaults.triggered()
                        }
                    }
                    onHeightChanged: {
                        if(imageloaderitem.imageLoadedAndReady) {
                            resetDefaults.triggered()
                        }
                    }

                    /**********************************************************/
                    // This loader animates a faded out image in the background for the Ken Burns slideshow effect
                    // when there are empty bars left/right or above/below the image being animated
                    PQKenBurnsSlideshowBackground {
                        id: kenburnsBG
                        loaderTopVisible: loader_top.visible
                        imageWrapperScale: image_wrapper.scale
                        flickableSize: Qt.size(flickable.width, flickable.height)
                        flickableContentSize: Qt.size(flickable.contentWidth, flickable.contentHeight)
                        imageWrapperSize: Qt.size(image_wrapper.width, image_wrapper.height)
                        videoLoaded: loader_top.videoLoaded
                        defaultScale: loader_top.defaultScale

                        Connections {
                            target: loader_top
                            function onVisibleChanged() {
                                kenburnsBG.checkForBG()
                            }
                        }

                    }
                    /**********************************************************/

                    // the actual image

                    Loader {
                        id: image_loader_pdf
                        asynchronous: true
                        active: false
                        sourceComponent:
                            PQDocument {

                                id: document_item

                                imageSource: imageloaderitem.imageSource
                                defaultScale: loader_top.defaultScale
                                currentScale: image_wrapper.scale
                                isMainImage: loader_top.isMainImage
                                loaderTop: loader_top

                                onWidthChanged: {
                                    image_wrapper.width = width
                                    loader_top.resetToDefaults()
                                    image_wrapper.startupScale = false
                                }
                                onHeightChanged: {
                                    image_wrapper.height = height
                                    loader_top.resetToDefaults()
                                    image_wrapper.startupScale = false
                                }

                                onStatusChanged: {
                                    image_wrapper.status = status
                                }

                                onImageMirrorHChanged: {
                                    loader_top.imageMirrorH = imageMirrorH
                                }

                                onImageMirrorVChanged: {
                                    loader_top.imageMirrorV = imageMirrorV
                                }

                                onSourceSizeChanged: {
                                    loader_top.imageResolution = sourceSize
                                    loader_top.resetToDefaults()
                                    image_wrapper.startupScale = false
                                }

                                Connections {
                                    target: image_wrapper
                                    function onSetMirrorHVToImage(mirH : bool, mirV : bool) {
                                        document_item.setMirrorHV(mirH, mirV)
                                    }
                                }

                                // we do not want to have a property binding for this
                                // otherwise we get error messages when the source changes to a different type
                                Component.onCompleted: {
                                    imageSource = imageloaderitem.imageSource
                                    imageSourceChanged()
                                }

                            }
                    }

                    Loader {
                        id: image_loader_arc
                        asynchronous: true
                        active: false
                        sourceComponent:
                            PQArchive {

                                id: archive_item

                                imageSource: imageloaderitem.imageSource
                                defaultScale: loader_top.defaultScale
                                currentScale: image_wrapper.scale
                                isMainImage: loader_top.isMainImage
                                loaderTop: loader_top

                                onWidthChanged: {
                                    image_wrapper.width = width
                                    loader_top.resetToDefaults()
                                    image_wrapper.startupScale = false
                                }
                                onHeightChanged: {
                                    image_wrapper.height = height
                                    loader_top.resetToDefaults()
                                    image_wrapper.startupScale = false
                                }

                                onStatusChanged: {
                                    image_wrapper.status = status
                                }

                                onImageMirrorHChanged: {
                                    loader_top.imageMirrorH = imageMirrorH
                                }

                                onImageMirrorVChanged: {
                                    loader_top.imageMirrorV = imageMirrorV
                                }

                                onSourceSizeChanged: {
                                    loader_top.imageResolution = sourceSize
                                    loader_top.resetToDefaults()
                                    image_wrapper.startupScale = false
                                }

                                Connections {
                                    target: image_wrapper
                                    function onSetMirrorHVToImage(mirH : bool, mirV : bool) {
                                        archive_item.setMirrorHV(mirH, mirV)
                                    }
                                }

                                // we do not want to have a property binding for this
                                // otherwise we get error messages when the source changes to a different type
                                Component.onCompleted: {
                                    imageSource = imageloaderitem.imageSource
                                    imageSourceChanged()
                                }

                            }

                    }

                    Loader {
                        id: image_loader_mpv
                        asynchronous: true
                        active: false
                        sourceComponent:
                            PQVideoMpv {

                                id: mpv_item

                                imageSource: imageloaderitem.imageSource
                                isMainImage: loader_top.isMainImage
                                videoLoaded: loader_top.videoLoaded
                                loaderTop: loader_top

                                onWidthChanged: {
                                    image_wrapper.width = width
                                    loader_top.imageResolution.width = width
                                }
                                onHeightChanged: {
                                    loader_top.imageResolution.height = height
                                    image_wrapper.height = height
                                }

                                onStatusChanged: {
                                    image_wrapper.status = status
                                }

                                onImageMirrorHChanged: {
                                    loader_top.imageMirrorH = imageMirrorH
                                }

                                onImageMirrorVChanged: {
                                    loader_top.imageMirrorV = imageMirrorV
                                }

                                onVisibleChanged: {
                                    if(visible) {
                                        loader_top.videoLoaded = true
                                        loader_top.videoHasAudio = true
                                        loader_top.videoHasAudioChanged()
                                    }
                                }

                                onVideoHasAudioChanged: {
                                    loader_top.videoHasAudio = videoHasAudio
                                }

                                Connections {
                                    target: loader_top

                                    function onVideoToPos(pos : int) {
                                        mpv_item.videoToPos(pos)
                                    }
                                    function onImageClicked() {
                                        mpv_item.videoClicked()
                                    }
                                }

                                Connections {
                                    target: image_wrapper
                                    function onSetMirrorHVToImage(mirH : bool, mirV : bool) {
                                        mpv_item.setMirrorHV(mirH, mirV)
                                    }
                                }

                                // we do not want to have a property binding for this
                                // otherwise we get error messages when the source changes to a different type
                                Component.onCompleted:
                                    imageSource = imageloaderitem.imageSource

                            }
                    }

                    Loader {
                        id: image_loader_vidqt
                        asynchronous: true
                        active: false
                        sourceComponent:
                            PQVideoQt {

                                id: videoqt_item

                                imageSource: imageloaderitem.imageSource
                                isMainImage: loader_top.isMainImage
                                loaderTop: loader_top
                                videoLoaded: loader_top.videoLoaded

                                onWidthChanged: {
                                    image_wrapper.width = width
                                    loader_top.imageResolution.width = width
                                }
                                onHeightChanged: {
                                    loader_top.imageResolution.height = height
                                    image_wrapper.height = height
                                }

                                onStatusChanged: {
                                    image_wrapper.status = status
                                }

                                onImageMirrorHChanged: {
                                    loader_top.imageMirrorH = imageMirrorH
                                }

                                onImageMirrorVChanged: {
                                    loader_top.imageMirrorV = imageMirrorV
                                }

                                onVisibleChanged: {
                                    if(visible) {
                                        loader_top.videoLoaded = true
                                        loader_top.videoHasAudio = Qt.binding(function() { return videoqt_item.videoHasAudio })
                                        loader_top.videoHasAudioChanged()
                                    }
                                }

                                onVideoHasAudioChanged: {
                                    loader_top.videoHasAudio = videoHasAudio
                                }

                                Connections {

                                    target: loader_top

                                    function onVideoToPos(pos : int) {
                                        videoqt_item.videoToPos(pos)
                                    }

                                    function onImageClicked() {
                                        videoqt_item.videoClicked()
                                    }

                                    function onStopVideoAndReset() {
                                        videoqt_item.stopVideoAndReset()
                                    }

                                    function onRestartVideoIfAutoplay() {
                                        videoqt_item.restartVideoIfAutoplay()
                                    }
                                }

                                Connections {
                                    target: image_wrapper
                                    function onSetMirrorHVToImage(mirH : bool, mirV : bool) {
                                        videoqt_item.setMirrorHV(mirH, mirV)
                                    }
                                }

                                // we do not want to have a property binding for this
                                // otherwise we get error messages when the source changes to a different type
                                Component.onCompleted: {
                                    imageSource = imageloaderitem.imageSource
                                    loader_top.videoHasAudio = Qt.binding(function() { return videoqt_item.videoHasAudio })
                                    loader_top.videoHasAudioChanged()
                                }

                            }
                    }

                    Loader {
                        id: image_loader_ani
                        asynchronous: true
                        active: false
                        sourceComponent:
                            PQImageAnimated {

                                id: image_animated

                                imageSource: imageloaderitem.imageSource
                                currentScale: image_wrapper.scale
                                isMainImage: loader_top.isMainImage
                                loaderTop: loader_top

                                onWidthChanged:
                                    image_wrapper.width = width
                                onHeightChanged:
                                    image_wrapper.height = height

                                onStatusChanged: {
                                    image_wrapper.status = status
                                }

                                onImageMirrorHChanged: {
                                    loader_top.imageMirrorH = imageMirrorH
                                }

                                onImageMirrorVChanged: {
                                    loader_top.imageMirrorV = imageMirrorV
                                }

                                onSourceSizeChanged: {
                                    loader_top.imageResolution = sourceSize
                                }

                                onEnsureSourceSizeSet: {
                                    loader_top.imageResolution = sourceSize
                                }

                                Connections {
                                    target: image_wrapper
                                    function onSetMirrorHVToImage(mirH : bool, mirV : bool) {
                                        image_animated.setMirrorHV(mirH, mirV)
                                    }
                                }

                                // we do not want to have a property binding for this
                                // otherwise we get error messages when the source changes to a different type
                                Component.onCompleted:
                                    imageSource = imageloaderitem.imageSource
                            }
                    }

                    Loader {
                        id: image_loader_svg
                        asynchronous: true
                        active: false
                        sourceComponent:
                            PQSVG {

                                id: svg_item

                                imageSource: imageloaderitem.imageSource
                                loaderTopOpacity: loader_top.opacity
                                loaderTopImageScale: loader_top.imageScale

                                onWidthChanged:
                                    image_wrapper.width = width
                                onHeightChanged:
                                    image_wrapper.height = height

                                onStatusChanged: {
                                    image_wrapper.status = status
                                }

                                onImageMirrorHChanged: {
                                    loader_top.imageMirrorH = imageMirrorH
                                }

                                onImageMirrorVChanged: {
                                    loader_top.imageMirrorV = imageMirrorV
                                }

                                onSourceSizeChanged: {
                                    loader_top.imageResolution = sourceSize
                                }

                                onEnsureSourceSizeSet: {
                                    loader_top.imageResolution = sourceSize
                                }

                                Connections {
                                    target: loader_top
                                    function onImageScaleChanged() {
                                        svg_item.restartResetCurrentScale()
                                    }
                                }

                                Connections {
                                    target: image_wrapper
                                    function onSetMirrorHVToImage(mirH : bool, mirV : bool) {
                                        svgtop.setMirrorHV(mirH, mirV)
                                    }
                                }

                                // we do not want to have a property binding for this
                                // otherwise we get error messages when the source changes to a different type
                                Component.onCompleted:
                                    imageSource = imageloaderitem.imageSource

                            }
                    }

                    Loader {
                        id: image_loader_sph
                        asynchronous: true
                        active: false
                        sourceComponent:
                            PQPhotoSphere {

                                id: sphitem

                                imageSource: imageloaderitem.imageSource
                                loaderTop: loader_top

                                width: loader_top.width
                                height: loader_top.height

                                onWidthChanged:
                                    image_wrapper.width = sphitem.width
                                onHeightChanged:
                                    image_wrapper.height = sphitem.height

                                // we do not want to have a property binding for this
                                // otherwise we get error messages when the source changes to a different type
                                Component.onCompleted: {
                                    imageSource = imageloaderitem.imageSource
                                    if(loader_top.isMainImage)
                                        PQCConstants.showingPhotoSphere = true
                                    image_wrapper.status = Image.Ready
                                    image_wrapper.width = width
                                    image_wrapper.height = height
                                }

                            }
                    }

                    Loader {
                        id: image_loader_img
                        asynchronous: true
                        active: false
                        sourceComponent:
                            PQImageNormal {

                                id: image_normal

                                imageSource: imageloaderitem.imageSource
                                defaultScale: loader_top.defaultScale
                                currentScale: image_wrapper.scale
                                isMainImage: loader_top.isMainImage
                                thisIsAPhotoSphere: loader_top.thisIsAPhotoSphere
                                loaderTop: loader_top

                                onWidthChanged: {
                                    if(!ignoreSignals)
                                        image_wrapper.width = width
                                }
                                onHeightChanged: {
                                    if(!ignoreSignals)
                                        image_wrapper.height = height
                                }

                                onStatusChanged: {
                                    if(!ignoreSignals)
                                        image_wrapper.status = status
                                }

                                onImageMirrorHChanged: {
                                    loader_top.imageMirrorH = imageMirrorH
                                }

                                onImageMirrorVChanged: {
                                    loader_top.imageMirrorV = imageMirrorV
                                }

                                onSourceSizeChanged: {
                                    if(!ignoreSignals)
                                        loader_top.imageResolution = sourceSize
                                }

                                onEnsureSourceSizeSet: {
                                    if(!ignoreSignals)
                                        loader_top.imageResolution = sourceSize
                                }

                                Connections {
                                    target: image_wrapper
                                    function onSetMirrorHVToImage(mirH : bool, mirV : bool) {
                                        image_normal.setMirrorHV(mirH, mirV)
                                    }
                                }

                                // we do not want to have a property binding for this
                                // otherwise we get error messages when the source changes to a different type
                                Component.onCompleted:
                                    imageSource = imageloaderitem.imageSource

                            }
                    }

                    Connections {

                        target: loader_top

                        function onFinishSetup() {

                            loader_top.listenToClicksOnImage = false
                            loader_top.videoLoaded = false
                            loader_top.videoHasAudio = false
                            loader_top.thisIsAPhotoSphere = false

                            if(loader_top.isMainImage) {
                                PQCConstants.currentImageIsMotionPhoto = false
                                PQCConstants.animatedImageIsPlaying = false
                            }

                            image_loader_pdf.active = false
                            image_loader_arc.active = false
                            image_loader_mpv.active = false
                            image_loader_vidqt.active = false
                            image_loader_ani.active = false
                            image_loader_svg.active = false
                            image_loader_sph.active = false
                            image_loader_img.active = false

                            if(PQCScriptsImages.isPDFDocument(imageloaderitem.imageSource) && !PQCFileFolderModel.activeViewerMode) {
                                image_loader_pdf.active = true
                            } else if(PQCScriptsImages.isArchive(imageloaderitem.imageSource) && !PQCFileFolderModel.activeViewerMode) {
                                image_loader_arc.active = true
                            } else if(PQCScriptsImages.isMpvVideo(imageloaderitem.imageSource)) {
                                image_loader_mpv.active = true
                                loader_top.listenToClicksOnImage = true
                                loader_top.videoLoaded = true
                            } else if(PQCScriptsImages.isQtVideo(imageloaderitem.imageSource)) {
                                image_loader_vidqt.active = true
                                loader_top.listenToClicksOnImage = true
                                loader_top.videoLoaded = true
                            } else if(PQCScriptsImages.isItAnimated(imageloaderitem.imageSource)) {
                                image_loader_ani.active = true
                                loader_top.listenToClicksOnImage = true
                            } else if(PQCScriptsImages.isSVG(imageloaderitem.imageSource)) {
                                image_loader_svg.active = true
                            } else if(PQCConstants.openGLAvailableForSpheres && (loader_top.photoSphereManuallyEntered || PQCScriptsImages.isPhotoSphere(imageloaderitem.imageSource) && (loader_top.photoSphereManuallyEntered || PQCSettings.filetypesPhotoSphereAutoLoad))) {
                                loader_top.thisIsAPhotoSphere = true
                                image_loader_sph.active = true
                            } else {
                                loader_top.thisIsAPhotoSphere = PQCScriptsImages.isPhotoSphere(imageloaderitem.imageSource)
                                image_loader_img.active = true
                            }

                            loader_top.setGlobalProperties()

                        }

                    }

                    PQBarCodes {
                        id: barcodes
                        isMainImage: loader_top.isMainImage
                        loaderImageScale: loader_top.imageScale
                        imageSource: imageloaderitem.imageSource

                        Connections {

                            target: loader_top

                            function onBarcodeClick() {
                                barcodes.barcodeClicked()
                            }
                        }

                    }

                    PQFaceTracker {
                        isMainImage: loader_top.isMainImage
                        imageSource: imageloaderitem.imageSource
                    }

                    PQFaceTagger {
                        isMainImage: loader_top.isMainImage
                        imageSource: imageloaderitem.imageSource
                    }

                    Connections {

                        // here we adjust the image position (if enabled) as reaction to scale animation
                        target: image_wrapper
                        enabled: !PQCSettings.imageviewZoomToCenter&&!rotationAnimation.running

                        function onScaleChanged() {

                            // calculate the real position
                            var realX = scaleAnimation.pos.x * scaleAnimation.prevScale
                            var realY = scaleAnimation.pos.y * scaleAnimation.prevScale

                            // get the zoom factor to get from the previous scale to this one
                            var zoomfactor = image_wrapper.scale/scaleAnimation.prevScale

                            // adjust position of image
                            if(flickable.contentWidth > flickable.width)
                                flickable.contentX -= (1-zoomfactor)*realX
                            if(flickable.contentHeight > flickable.height)
                                flickable.contentY -= (1-zoomfactor)*realY
                            // make sure it is inside of the bounds
                            flickable.returnToBounds()

                            // cache the new scale factor
                            scaleAnimation.prevScale = image_wrapper.scale

                        }
                    }

                    // scaling animation
                    PropertyAnimation {
                        id: scaleAnimation
                        target: image_wrapper
                        property: "scale"
                        property real prevScale: image_wrapper.scale
                        property point pos: Qt.point(0,0)
                        from: image_wrapper.scale
                        to: loader_top.imageScale
                        duration: loader_top.dontAnimateNextZoom ? 0 : 200

                        onFinished: {
                            loader_top.dontAnimateNextZoom = false
                            prevScale = Qt.binding(function() { return image_wrapper.scale })
                            pos = Qt.point(0,0)
                        }
                    }

                    // rotation animation
                    PropertyAnimation {
                        id: rotationAnimation
                        target: image_wrapper
                        from: 0
                        to: 0
                        duration: 200
                        property: "rotation"
                        onFinished: {
                            loader_top.dontAnimateNextZoom = false
                        }
                    }

                    // reset default properties when window size changed
                    Timer {
                        id: resetDefaults
                        interval: 50
                        onTriggered: {

                            if(Math.abs(image_wrapper.scale-loader_top.defaultScale) < 1e-6) {

                                resetDefaults.resetScale()

                                if(!PQCSettings.imageviewRememberZoomRotationMirror || !(imageloaderitem.imageSource in image_top.rememberChanges)) {
                                    if(!PQCSettings.imageviewPreserveZoom && !PQCSettings.imageviewPreserveRotation)
                                        loader_top.rotationZoomResetWithoutAnimation()
                                    else {
                                        if(!PQCSettings.imageviewPreserveZoom)
                                            loader_top.zoomResetWithoutAnimation()
                                        if(!PQCSettings.imageviewPreserveRotation)
                                            loader_top.rotationResetWithoutAnimation()
                                    }
                                }

                            } else {

                                loader_top.defaultScale = 0.99999999*image_wrapper.computeDefaultScale()

                            }

                            if(loader_top.isMainImage) {
                                PQCConstants.currentImageDefaultScale = loader_top.defaultScale
                            }
                        }
                        function resetScale() {

                            var val = 0.99999999*image_wrapper.computeDefaultScale()

                            if(PQCSettings.imageviewFitInWindow && loader_top.imageResolution.width > 0 && loader_top.imageResolution.height > 0) {
                                var factW, factH
                                if(rotationAnimation.to%180 == 0) {
                                    factW = flickable.width/(loader_top.imageResolution.width*val)
                                    factH = flickable.height/(loader_top.imageResolution.height*val)
                                } else {
                                    factW = flickable.width/(loader_top.imageResolution.height*val)
                                    factH = flickable.height/(loader_top.imageResolution.width*val)
                                }
                                if(factW > 1 && factH > 1)
                                    val *= Math.min(factW, factH)
                            }
                            loader_top.defaultScale = val
                        }

                    }

                    Connections {
                        target: PQCConstants
                        function onAvailableWidthChanged() {
                            resetDefaults.restart()
                        }
                        function onAvailableHeightChanged() {
                            resetDefaults.restart()
                        }
                    }

                    Connections {
                        target: flickable
                        function onWidthChanged() {
                            resetDefaults.restart()
                        }
                        function onHeightChanged() {
                            resetDefaults.restart()
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
                        target: imageloaderitem.toplevelItem

                        function onWidthChanged() {

                            if(Math.abs(loader_top.imageScale - loader_top.defaultScale) < 1e-12)
                                loader_top.dontAnimateNextZoom = true
                            resetDefaults.triggered()

                            // we do both, trigger the resize right away (for smoother scaling)
                            // and start a short timer to do it again in a few ms
                            // sometimes the right width/height is not immediately available
                            // doing both avoids incorrectly sized images

                            resetDefaults.restart()

                        }

                        function onHeightChanged() {

                            if(Math.abs(loader_top.imageScale - loader_top.defaultScale) < 1e-12)
                                loader_top.dontAnimateNextZoom = true
                            resetDefaults.triggered()

                            // we do both, trigger the resize right away (for smoother scaling)
                            // and start a short timer to do it again in a few ms
                            // sometimes the right width/height is not immediately available
                            // doing both avoids incorrectly sized images

                            resetDefaults.restart()
                        }
                    }

                    // when the key shortcut is kept pressed then we animate bouncing beyond the window edge once
                    // after that we block any further bounces
                    // we treat each edge separately, and bouncing beyond one window edge resets the other edges

                    property bool animateShortcutMoveBeyondEdgeLeft: true
                    property bool animateShortcutMoveBeyondEdgeRight: true
                    property bool animateShortcutMoveBeyondEdgeTop: true
                    property bool animateShortcutMoveBeyondEdgeBottom: true

                    Timer {
                        id: resetAnimateShortcutMoveBeyondEdgeLeft
                        interval: 1000
                        onTriggered:
                            image_wrapper.animateShortcutMoveBeyondEdgeLeft = true
                    }
                    Timer {
                        id: resetAnimateShortcutMoveBeyondEdgeRight
                        interval: 1000
                        onTriggered:
                            image_wrapper.animateShortcutMoveBeyondEdgeRight = true
                    }
                    Timer {
                        id: resetAnimateShortcutMoveBeyondEdgeTop
                        interval: 1000
                        onTriggered:
                            image_wrapper.animateShortcutMoveBeyondEdgeTop = true
                    }
                    Timer {
                        id: resetAnimateShortcutMoveBeyondEdgeBottom
                        interval: 1000
                        onTriggered:
                            image_wrapper.animateShortcutMoveBeyondEdgeBottom = true
                    }

                    Connections {

                        target: PQCNotify

                        function onCurrentViewFlick(direction : string) {

                            if(!loader_top.isMainImage)
                                return

                            if(PQCConstants.showingPhotoSphere)
                                return

                            if(direction === "left") {

                                image_wrapper.animateShortcutMoveBeyondEdgeRight = true
                                image_wrapper.animateShortcutMoveBeyondEdgeTop = true
                                image_wrapper.animateShortcutMoveBeyondEdgeBottom = true

                                if(!image_wrapper.animateShortcutMoveBeyondEdgeLeft) {
                                    resetAnimateShortcutMoveBeyondEdgeLeft.restart()
                                    return
                                }

                                if(flickable.contentX < 3) {
                                    resetAnimateShortcutMoveBeyondEdgeLeft.stop()
                                    image_wrapper.animateShortcutMoveBeyondEdgeLeft = false
                                    resetAnimateShortcutMoveBeyondEdgeLeft.restart()
                                }

                                flickable.flick(1000,0)

                            } else if(direction === "right") {

                                image_wrapper.animateShortcutMoveBeyondEdgeLeft = true
                                image_wrapper.animateShortcutMoveBeyondEdgeTop = true
                                image_wrapper.animateShortcutMoveBeyondEdgeBottom = true

                                if(!image_wrapper.animateShortcutMoveBeyondEdgeRight) {
                                    resetAnimateShortcutMoveBeyondEdgeRight.restart()
                                    return
                                }

                                if(flickable.contentX > flickable.contentWidth-flickable.width-3) {
                                    resetAnimateShortcutMoveBeyondEdgeRight.stop()
                                    image_wrapper.animateShortcutMoveBeyondEdgeRight = false
                                    resetAnimateShortcutMoveBeyondEdgeRight.restart()
                                }

                                flickable.flick(-1000,0)

                            } else if(direction === "up") {

                                image_wrapper.animateShortcutMoveBeyondEdgeLeft = true
                                image_wrapper.animateShortcutMoveBeyondEdgeRight = true
                                image_wrapper.animateShortcutMoveBeyondEdgeBottom = true

                                if(!image_wrapper.animateShortcutMoveBeyondEdgeTop) {
                                    resetAnimateShortcutMoveBeyondEdgeTop.restart()
                                    return
                                }

                                if(flickable.contentY < 3) {
                                    resetAnimateShortcutMoveBeyondEdgeTop.stop()
                                    image_wrapper.animateShortcutMoveBeyondEdgeTop = false
                                    resetAnimateShortcutMoveBeyondEdgeTop.restart()
                                }

                                flickable.flick(0,1000)

                            } else if(direction === "down") {

                                image_wrapper.animateShortcutMoveBeyondEdgeLeft = true
                                image_wrapper.animateShortcutMoveBeyondEdgeRight = true
                                image_wrapper.animateShortcutMoveBeyondEdgeTop = true

                                if(!image_wrapper.animateShortcutMoveBeyondEdgeBottom) {
                                    resetAnimateShortcutMoveBeyondEdgeBottom.restart()
                                    return
                                }

                                if(flickable.contentY > flickable.contentHeight-flickable.height-3) {
                                    resetAnimateShortcutMoveBeyondEdgeBottom.stop()
                                    image_wrapper.animateShortcutMoveBeyondEdgeBottom = false
                                    resetAnimateShortcutMoveBeyondEdgeBottom.restart()
                                }

                                flickable.flick(0,-1000)

                            }

                        }

                        function onCurrentViewMove(direction : string) {

                            if(!loader_top.isMainImage)
                                return

                            if(PQCConstants.showingPhotoSphere)
                                return

                            if(direction === "left") {
                                if(flickable.contentWidth > flickable.width)
                                    flickable.contentX = Math.max(0, flickable.contentX-10)
                            } else if(direction === "right") {
                                if(flickable.contentWidth > flickable.width)
                                    flickable.contentX = Math.min(flickable.contentWidth-flickable.width, flickable.contentX+10)
                            } else if(direction === "up") {
                                if(flickable.contentHeight > flickable.height)
                                    flickable.contentY = Math.max(0, flickable.contentY-10)
                            } else if(direction === "down") {
                                if(flickable.contentHeight > flickable.height)
                                    flickable.contentY = Math.min(flickable.contentHeight-flickable.height, flickable.contentY+10)
                            } else if(direction === "leftedge") {
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

                            if(!loader_top.isMainImage)
                                return

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

                            if(!loader_top.isMainImage)
                                return

                            if(PQCConstants.showingPhotoSphere)
                                return

                            scaleAnimation.stop()
                            rotationAnimation.stop()

                            image_wrapper.rotation = 0
                            loader_top.imageRotation = 0
                            image_wrapper.scale = loader_top.defaultScale
                            loader_top.imageScale = Qt.binding(function() { return loader_top.defaultScale } )

                        }

                        function onZoomActualWithoutAnimation() {

                            if(!loader_top.isMainImage)
                                return

                            if(PQCConstants.showingPhotoSphere)
                                return

                            scaleAnimation.stop()

                            image_wrapper.scale = 1/PQCConstants.devicePixelRatio
                            loader_top.imageScale = image_wrapper.scale

                        }

                        function onZoomInForKenBurns() {

                            if(!loader_top.isMainImage)
                                return

                            // this function might be called more than once
                            // this check makes sure that we only do this once
                            if(image_top.width < flickable.contentWidth || image_top.height < flickable.contentHeight)
                                return

                            if(PQCConstants.showingPhotoSphere)
                                return

                            scaleAnimation.stop()

                            // figure out whether the image is much wider or much higher than the other dimension

                            var facW = 1
                            var facH = 1

                            if(flickable.contentWidth > 0)
                                facW = image_top.width/flickable.contentWidth
                            if(flickable.contentHeight > 0)
                                facH = image_top.height/flickable.contentHeight

                            // we zoom images in to fill the full screen
                            // UNLESS the image dimensions are rather different AND differ from the window dimensions
                            var fac = Math.max(facW, facH)
                            var rel = image_wrapper.width/image_wrapper.height
                            if(((image_wrapper.width > image_wrapper.height && image_top.height > image_top.width) ||
                                (image_wrapper.height > image_wrapper.width && image_top.width > image_top.height)) &&
                                    (rel < 0.5 || rel > 1.5))
                                fac = Math.min(facW, facH)

                            // small images are not scaled as much as larger ones
                            if(loader_top.defaultScale > 0.99)
                                image_wrapper.kenBurnsZoomFactor = loader_top.defaultScale * fac*1.05
                            else
                                image_wrapper.kenBurnsZoomFactor = loader_top.defaultScale * fac*1.2

                            // set scale factors
                            image_wrapper.scale = image_wrapper.kenBurnsZoomFactor
                            loader_top.imageScale = image_wrapper.scale

                        }

                        function onLoadScaleRotation() {

                            if(!loader_top.isMainImage)
                                return

                            if(PQCConstants.showingPhotoSphere)
                                return

                            if((PQCSettings.imageviewRememberZoomRotationMirror && (imageloaderitem.imageSource in image_top.rememberChanges)) ||
                                    ((PQCSettings.imageviewPreserveZoom || PQCSettings.imageviewPreserveRotation ||
                                      PQCSettings.imageviewPreserveMirror) && image_top.reuseChanges.length > 1)) {

                                var vals;
                                if(PQCSettings.imageviewRememberZoomRotationMirror && (imageloaderitem.imageSource in image_top.rememberChanges))
                                    vals = image_top.rememberChanges[imageloaderitem.imageSource]
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

                                if(PQCSettings.imageviewRememberZoomRotationMirror || PQCSettings.imageviewPreserveMirror)
                                    image_wrapper.setMirrorHVToImage(vals[4], vals[5])
                                else
                                    image_wrapper.setMirrorHVToImage(false, false)

                                if(!PQCSettings.imageviewAlwaysActualSize || (PQCSettings.imageviewRememberZoomRotationMirror && imageloaderitem.imageSource in image_top.rememberChanges)) {
                                    flickable.contentX = vals[0]
                                    flickable.contentY = vals[1]
                                    flickable.returnToBounds()
                                }

                            } else if(!PQCSettings.imageviewAlwaysActualSize) {

                                scaleAnimation.stop()
                                rotationAnimation.stop()

                                image_wrapper.rotation = 0
                                loader_top.imageRotation = 0
                                image_wrapper.setMirrorHVToImage(false, false)
                                image_wrapper.scale = loader_top.defaultScale
                                loader_top.imageScale = image_wrapper.scale

                            }

                        }

                        function onImageRotationChanged() {
                            if(loader_top.isMainImage) {
                                rotationAnimation.stop()
                                rotationAnimation.from = image_wrapper.rotation
                                rotationAnimation.to = loader_top.imageRotation
                                rotationAnimation.restart()
                                var oldDefault = loader_top.defaultScale
                                resetDefaults.resetScale()
                                if(Math.abs(loader_top.imageScale-oldDefault) < 1e-6)
                                    loader_top.imageScale = Qt.binding(function() { return loader_top.defaultScale })
                                PQCConstants.currentImageDefaultScale = loader_top.defaultScale
                            }
                        }

                        function onMoveViewToCenter() {

                            if(!loader_top.isMainImage)
                                return

                            if(PQCConstants.showingPhotoSphere)
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

                        function onImageviewFitInWindowChanged() {
                            resetDefaults.resetScale()
                            loader_top.imageScale = loader_top.defaultScale
                        }

                        function onImageviewMarginChanged() {
                            resetDefaults.restart()
                        }

                    }

                    // calculate the default scale based on the current rotation
                    function computeDefaultScale() : real {
                        var dpr = (loader_top.thisIsAPhotoSphere ? 1 : PQCConstants.devicePixelRatio)
                        if(loader_top.rotatedUpright)
                            return Math.min(1./dpr, Math.min((flickable.width/width), (flickable.height/height)))
                        return Math.min(1./dpr, Math.min((flickable.width/height), (flickable.height/width)))
                    }

                    Timer {
                        id: hidecursor
                        interval: PQCSettings.imageviewHideCursorTimeout*1000
                        repeat: false
                        running: true
                        onTriggered: {
                            if(PQCSettings.imageviewHideCursorTimeout === 0)
                                return
                            if(PQCConstants.isContextmenuOpen("globalcontextmenu") || PQCConstants.idOfVisibleItem !== "")
                                hidecursor.restart()
                            else
                                imagemouse.cursorShape = Qt.BlankCursor
                        }
                    }

                    Connections {

                        target: PQCConstants

                        function onIdOfVisibleItemChanged() {
                            if(PQCConstants.idOfVisibleItem !== "") {
                                imagemouse.cursorShape = Qt.ArrowCursor
                                hidecursor.restart()
                            }
                        }

                    }

                }

            }

        }

        PQMouseArea {
            id: imagemouse
            anchors.fill: parent
            anchors.leftMargin: -PQCSettings.imageviewMargin
            anchors.rightMargin: -PQCSettings.imageviewMargin
            anchors.topMargin: -PQCSettings.imageviewMargin
            anchors.bottomMargin: -PQCSettings.imageviewMargin
            hoverEnabled: true
            propagateComposedEvents: true
            acceptedButtons: Qt.AllButtons
            doubleClickThreshold: PQCSettings.interfaceDoubleClickThreshold
            enabled: !PQCConstants.touchGestureActive
            onPositionChanged: (mouse) => {
                cursorShape = Qt.ArrowCursor
                hidecursor.restart()
                var pos = imagemouse.mapToItem(imageloaderitem.toplevelItem, mouse.x, mouse.y)
                PQCNotify.mouseMove(pos.x, pos.y)
            }
            onWheel: (wheel) => {
                wheel.accepted = !PQCSettings.imageviewUseMouseWheelForImageMove
                var pos = imagemouse.mapToItem(imageloaderitem.toplevelItem, wheel.x, wheel.y)
                PQCNotify.mouseWheel(pos, wheel.angleDelta, wheel.modifiers)
            }
            onPressed: (mouse) => {

                var locpos = flickable_content.mapFromItem(imageloaderitem.toplevelItem, mouse.x, mouse.y)

                if(PQCSettings.interfaceCloseOnEmptyBackground &&
                      (locpos.x < flickable_content.x ||
                       locpos.y < flickable_content.y ||
                       locpos.x > flickable_content.x+flickable_content.width ||
                       locpos.y > flickable_content.y+flickable_content.height)) {

                    PQCNotify.windowClose()
                    return

                }

                if(PQCSettings.interfaceNavigateOnEmptyBackground) {
                    if(locpos.x < flickable_content.x || (locpos.x < flickable_content.x+flickable_content.width/2 &&
                       (locpos.y < flickable_content.y || locpos.y > flickable_content.y+flickable_content.height))) {

                        image_top.showPrev()
                        return

                    } else if(locpos.x > flickable_content.x+flickable_content.width || (locpos.x > flickable_content.x+flickable_content.width/2 &&
                              (locpos.y < flickable_content.y || locpos.y > flickable_content.y+flickable_content.height))) {

                        image_top.showNext()
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

                if(PQCConstants.barcodeDisplayed && mouse.button === Qt.LeftButton)
                    loader_top.barcodeClick()
                if(PQCSettings.imageviewUseMouseLeftButtonForImageMove && mouse.button === Qt.LeftButton && !PQCConstants.faceTaggingMode) {
                    mouse.accepted = false
                    return
                }
                var pos = imagemouse.mapToItem(imageloaderitem.toplevelItem, mouse.x, mouse.y)
                PQCNotify.mousePressed(mouse.modifiers, mouse.button, pos)
            }
            onMouseDoubleClicked: (mouse) => {
                var pos = imagemouse.mapToItem(imageloaderitem.toplevelItem, mouse.x, mouse.y)
                PQCNotify.mouseDoubleClicked(mouse.modifiers, mouse.button, pos)
            }

            onReleased: (mouse) => {
                if(mouse.button === Qt.LeftButton && loader_top.listenToClicksOnImage)
                    loader_top.imageClicked()
                else {
                    var pos = imagemouse.mapToItem(imageloaderitem.toplevelItem, mouse.x, mouse.y)
                    PQCNotify.mouseReleased(mouse.modifiers, mouse.button, pos)
                }
            }
        }

        // we don't use a pinch area as we want to pass through flick events, something a pincharea cannot do
        PinchHandler {

            id: hdl

            target: null

            enabled: mpta.numPoints==0 && mpta.enabled

            /*1on_Qt65+*/
            rotationAxis.enabled: false
            /*2on_Qt65+*/

            onScaleChanged: (delta) => {
                loader_top.dontAnimateNextZoom = true
                loader_top.performZoom(Qt.point(translation.x, translation.y), Qt.point(0,0), delta>1, delta)
            }

        }

        MultiPointTouchArea {

            id: mpta

            anchors.fill: parent

            mouseEnabled: false

            enabled: !PQCConstants.faceTaggingMode && !PQCConstants.showingPhotoSphere && !PQCConstants.slideshowRunning

            property list<point> initialPts: []
            property real initialScale
            property real previousLength: 0
            property int numPoints: 0

            onPressed: (points) => {

                numPoints += points.length
                pressAndHoldTimeout.touchPos = points[0]

                if(points.length === 2) {
                    initialPts = [Qt.point(points[0].x, points[0].y), Qt.point(points[1].x, points[1].y)]
                    pressAndHoldTimeout.stop()
                } else {
                    initialPts.push(Qt.point(points[0].x, points[0].y))
                    if(points.length === 1)
                        pressAndHoldTimeout.restart()
                    else
                        pressAndHoldTimeout.stop()
                }

                initialScale = image_wrapper.scale

            }

            onUpdated: (points) => {

                if(points.length === 1) {

                    if(Math.abs(points[0].x - pressAndHoldTimeout.touchPos.x) > 20 || Math.abs(points[0].y - pressAndHoldTimeout.touchPos.y) > 20)
                        pressAndHoldTimeout.stop()

                    flickable.flick(points[0].velocity.x*1.5, points[0].velocity.y*1.5)

                } else if(points.length === 2 && initialPts.length === 2) {

                    pressAndHoldTimeout.stop()

                    // compute the rate of change initiated by this pinch
                    if(previousLength == 0)
                        previousLength = Math.sqrt(Math.pow(initialPts[0].x-initialPts[1].x, 2) + Math.pow(initialPts[0].y-initialPts[1].y, 2))
                    var curLength = Math.sqrt(Math.pow(points[0].x-points[1].x, 2) + Math.pow(points[0].y-points[1].y, 2))

                    if(previousLength > 0 && curLength > 0) {

                        var pos

                        // if finger 0 or 1 remained in place, zoom to that finger's position
                        if(Math.abs(points[0].x-initialPts[0].x) < 5 && Math.abs(points[0].y-initialPts[0].y) < 5) {

                            pos = points[0]

                        } else if(Math.abs(points[1].x-initialPts[1].x) < 5 && Math.abs(points[1].y-initialPts[1].y) < 5) {

                            pos = points[1]

                        // else we use the initial midpoint as focus point
                        } else {

                            pos = Qt.point((initialPts[0].x+initialPts[1].x)/2, (initialPts[0].y+initialPts[1].y)/2)

                        }

                        loader_top.dontAnimateNextZoom = true
                        loader_top.performZoom(pos, Qt.point(0,0), undefined, curLength/previousLength)
                        previousLength = curLength

                    }

                } else
                    pressAndHoldTimeout.stop()

            }


            onReleased: (points) => {
                numPoints -= points.length
                pressAndHoldTimeout.stop()
                initialPts = []
                previousLength = 0
            }

            Timer {
                id: pressAndHoldTimeout
                interval: 1000
                property point touchPos: Qt.point(-1,-1)
                onTriggered: {
                    shortcuts.item.executeInternalFunction("__contextMenuTouch", touchPos)
                }
            }

        }

        // animation to show the image
        PropertyAnimation {
            id: opacityAnimation
            target: loader_top
            property: "opacity"
            from: 0
            to: 1
            duration: PQCSettings.generalDisableAllAnimations ? 0 :
                            PQCSettings.imageviewAnimationDuration*100 + (PQCConstants.slideshowRunning&&PQCSettings.slideshowTypeAnimation==="kenburns" ? 500 : 0)

            onStarted: {
                if(loader_top.opacity > 0.9)
                    imageloaderitem.imageFullyShown = false
            }

            onFinished: {
                if(loader_top.opacity < 1e-6) {

                    // stop any possibly running video
                    loader_top.stopVideoAndReset()

                    // stop any ken burns animations if running
                    if(loader_kenburns.item != null)
                        loader_kenburns.item.stopAni()

                    loader_top.visible = false

                    loader_top.handleWhenCompletelyHidden()

                } else
                    imageFullyShown = true

            }
        }

        // animation to show the image
        PropertyAnimation {
            id: xAnimation
            target: loader_top
            property: "x"
            from: -loader_top.width
            to: 0
            duration: PQCSettings.imageviewAnimationDuration*100
            onStarted: {
                if(Math.abs(loader_top.x) < 10)
                    imageloaderitem.imageFullyShown = false
            }

            onFinished: {
                if(Math.abs(loader_top.x) > 10) {

                    // stop any possibly running video
                    loader_top.stopVideoAndReset()

                    loader_top.visible = false

                    loader_top.handleWhenCompletelyHidden()

                } else
                    imageloaderitem.imageFullyShown = true

            }
        }

        // animation to show the image
        PropertyAnimation {
            id: yAnimation
            target: loader_top
            property: "y"
            from: -loader_top.height
            to: 0
            duration: PQCSettings.imageviewAnimationDuration*100
            onStarted: {
                if(Math.abs(loader_top.y) < 10)
                    imageloaderitem.imageFullyShown = false
            }

            onFinished: {
                if(Math.abs(loader_top.y) > 10) {

                    // stop any possibly running video
                    loader_top.stopVideoAndReset()

                    loader_top.visible = false

                    loader_top.handleWhenCompletelyHidden()

                } else
                    imageloaderitem.imageFullyShown = true

            }
        }

        // animation to show the image
        ParallelAnimation {
            id: rotAnimation
            PropertyAnimation {
                id: rotAnimation_rotation
                target: loader_top
                property: "rotation"
                from: 0
                to: 180
                duration: PQCSettings.imageviewAnimationDuration*100
            }
            PropertyAnimation {
                id: rotAnimation_opacity
                target: loader_top
                property: "opacity"
                from: 0
                to: 1
                duration: PQCSettings.imageviewAnimationDuration*100
            }
            onStarted: {
                loader_top.z = PQCConstants.currentZValue+1
                if(loader_top.opacity > 0.9)
                    imageFullyShown = false
            }
            onFinished: {
                if(Math.abs(loader_top.rotation%360) > 1e-6) {

                    // stop any possibly running video
                    loader_top.stopVideoAndReset()

                    loader_top.visible = false
                    loader_top.rotation = 0
                    loader_top.z = PQCConstants.currentZValue-5

                    loader_top.handleWhenCompletelyHidden()

                } else
                    imageFullyShown = true

            }
        }

        // animation to show the image
        ParallelAnimation {
            id: explosionAnimation
            PropertyAnimation {
                id: explosionAnimation_scale
                target: loader_top
                property: "scale"
                from: 1
                to: 2
                duration: PQCSettings.imageviewAnimationDuration*100
            }
            PropertyAnimation {
                id: explosionAnimation_opacity
                target: loader_top
                property: "opacity"
                from: 1
                to: 0
                duration: PQCSettings.imageviewAnimationDuration*90
            }
            onStarted: {
                loader_top.z = PQCConstants.currentZValue+1
                if(loader_top.opacity > 0.9)
                    imageloaderitem.imageFullyShown = false
            }
            onFinished: {
                if(Math.abs(loader_top.scale-1) > 1e-6) {

                    // stop any possibly running video
                    loader_top.stopVideoAndReset()

                    loader_top.visible = false
                    loader_top.scale = 1

                    loader_top.z = PQCConstants.currentZValue-5

                    loader_top.handleWhenCompletelyHidden()

                } else
                    imageloaderitem.imageFullyShown = true

            }
        }

        Loader {
            id: loader_kenburns
            active: PQCConstants.slideshowRunning && PQCSettings.slideshowTypeAnimation === "kenburns"
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

        function shouldEnableViewerMode() : bool {

            if(PQCFileFolderModel.justLeftViewerMode) return false

            var suffix1 = PQCScriptsFilesPaths.getSuffix(PQCFileFolderModel.currentFile)
            var suffix2 = PQCScriptsFilesPaths.getCompleteSuffix(PQCFileFolderModel.currentFile)

            var comicbookSuffix = ["cbt", "cbr", "cbz", "cb7"]
            if((PQCSettings.filetypesComicBookAlwaysEnterAutomatically &&
                    comicbookSuffix.indexOf(suffix1) > -1 &&
                    !PQCFileFolderModel.currentFile.includes("::ARC::")) ||
               (PQCSettings.filetypesArchiveAlwaysEnterAutomatically &&
                    (PQCImageFormats.getEnabledFormatsLibArchive().indexOf(suffix1) > -1 || PQCImageFormats.getEnabledFormatsLibArchive().indexOf(suffix2) > -1) &&
                    !PQCFileFolderModel.currentFile.includes("::ARC::")) ||
               (PQCSettings.filetypesDocumentAlwaysEnterAutomatically &&
                    (PQCImageFormats.getEnabledFormatsPoppler().indexOf(suffix1) > -1 || PQCImageFormats.getEnabledFormatsPoppler().indexOf(suffix2) > -1) &&
                    !PQCFileFolderModel.currentFile.includes("::PDF::"))) {
                return true
            }

            return false

        }

        function showImage() {

            if(imageloaderitem.imageLoadedAndReady) {

                if(shouldEnableViewerMode()) {
                    PQCFileFolderModel.enableViewerMode(PQCFileFolderModel.currentFile)
                } else {
                    imageloaderitem.iAmReady()
                    if(!imageloaderitem.imageFullyShown)
                        setUpImageWhenReady()
                }
            }

        }

        function setUpImageWhenReady() {

            if(shouldEnableViewerMode()) {
                PQCFileFolderModel.enableViewerMode(PQCFileFolderModel.currentFile)
                return
            }

            // this needs to be checked for early as we set PQCConstants.currentImageSource in a few lines
            var noPreviousImage = (PQCConstants.currentImageSource==="")

            PQCConstants.barcodeDisplayed = false

            PQCConstants.currentImageSource = imageloaderitem.imageSource

            PQCConstants.currentlyShowingVideo = loader_top.videoLoaded
            PQCConstants.currentlyShowingVideoHasAudio = loader_top.videoHasAudio

            PQCConstants.showingPhotoSphere = loader_top.thisIsAPhotoSphere && (loader_top.photoSphereManuallyEntered || PQCSettings.filetypesPhotoSphereAutoLoad)
            PQCConstants.currentImageIsAnimated = image_loader_ani.active
            PQCConstants.currentImageIsDocument = image_loader_pdf.active
            PQCConstants.currentImageIsArchive = image_loader_arc.active

            PQCConstants.currentVisibleAreaX = flickable.visibleArea.xPosition
            PQCConstants.currentVisibleAreaY = flickable.visibleArea.yPosition
            PQCConstants.currentVisibleAreaWidthRatio = flickable.visibleArea.widthRatio
            PQCConstants.currentVisibleAreaHeightRatio = flickable.visibleArea.heightRatio

            PQCConstants.currentVisibleContentPos.x = flickable.contentX
            PQCConstants.currentVisibleContentPos.y = flickable.contentY
            PQCConstants.currentVisibleContentSize.width = flickable.contentWidth
            PQCConstants.currentVisibleContentSize.height = flickable.contentHeight

            // if a slideshow is running with the ken burns effect
            // then we need to do some special handling
            if(PQCConstants.slideshowRunning && PQCSettings.slideshowTypeAnimation === "kenburns") {

                if(!PQCConstants.showingPhotoSphere && !loader_top.videoLoaded) {
                    loader_top.resetToDefaults()
                    loader_top.zoomInForKenBurns()
                }
                flickable.returnToBounds()

                opacityAnimation.stop()

                loader_top.opacity = 0
                opacityAnimation.from = 0
                opacityAnimation.to = 1

                opacityAnimation.restart()

            } else {

                // don't pipe showing animation through the property animators
                // when no animation is set or no previous image has been shown
                if(PQCSettings.imageviewAnimationDuration === 0 || noPreviousImage || PQCSettings.generalDisableAllAnimations) {

                    loader_top.opacity = 1
                    imageloaderitem.imageFullyShown = true

                } else {

                    var anim = PQCSettings.imageviewAnimationType
                    if(anim === "random")
                        anim = image_top.randomAnimation

                    var index0 = PQCFileFolderModel.getIndexOfMainView(visibleSourcePrevCur[0])
                    var index1 = PQCFileFolderModel.getIndexOfMainView(visibleSourcePrevCur[1])

                    if(anim === "opacity" || anim === "explosion" || anim === "implosion") {

                        opacityAnimation.stop()

                        loader_top.opacity = 0
                        opacityAnimation.from = 0
                        opacityAnimation.to = 1

                        opacityAnimation.restart()

                    } else if(anim === "x") {

                        xAnimation.stop()

                        // the from value depends on whether we go forwards or backwards in the folder
                        xAnimation.from = -width
                        if(visibleSourcePrevCur[1] === "" || index0 > index1)
                            xAnimation.from = width

                        xAnimation.to = 0

                        xAnimation.restart()

                    } else if(anim === "y") {

                        yAnimation.stop()

                        // the from value depends on whether we go forwards or backwards in the folder
                        yAnimation.from = -height
                        if(visibleSourcePrevCur[1] === "" || index0 > index1)
                            yAnimation.from = height

                        yAnimation.to = 0

                        yAnimation.restart()

                    } else if(anim === "rotation") {

                        rotAnimation.stop()

                        rotAnimation_rotation.from = -180
                        rotAnimation_rotation.to = 0

                        if(visibleSourcePrevCur[1] === "" || index0 > index1) {
                            rotAnimation_rotation.from = 180
                            rotAnimation_rotation.to = 0
                        }

                        rotAnimation_opacity.from = 0
                        rotAnimation_opacity.to = 1

                        rotAnimation.restart()

                    }

                }

            }

            z = PQCConstants.currentZValue
            loader_top.visible = true

            // (re-)start any video
            loader_top.restartVideoIfAutoplay()

            PQCConstants.currentZValue += 1

            PQCConstants.currentImageScale = loader_top.imageScale
            PQCConstants.currentImageRotation = loader_top.imageRotation
            PQCConstants.currentImageResolution = loader_top.imageResolution

            if(PQCSettings.imageviewAnimationType === "random")
                selectNewRandomAnimation.restart()

            // these are only done if we are not in a slideshow with the ken burns effect
            if(!PQCConstants.slideshowRunning || PQCSettings.slideshowTypeAnimation !== "kenburns") {

                loader_top.loadScaleRotation()
                loader_top.resetToDefaults()

                if(PQCSettings.imageviewFitInWindow && flickable.contentWidth < flickable.width && flickable.contentHeight < flickable.height) {

                    resetDefaults.resetScale()

                } else if(PQCSettings.imageviewAlwaysActualSize) {

                    loader_top.zoomActualWithoutAnimation()

                    if(!PQCSettings.imageviewRememberZoomRotationMirror || !(imageloaderitem.imageSource in image_top.rememberChanges)) {
                        if(flickable.contentWidth > flickable.width)
                            flickable.contentX = Qt.binding(function() { return (flickable.contentWidth-flickable.width)/2 })
                        if(flickable.contentHeight > flickable.height)
                            flickable.contentY = Qt.binding(function() { return (flickable.contentHeight-flickable.height)/2 })
                    }

                } else {

                    PQCConstants.imageInitiallyLoaded = true

                    loader_top.resetToDefaults()
                    loader_top.moveViewToCenter()

                }

            } else {
                loader_top.zoomInForKenBurns()
            }

            PQCConstants.imageInitiallyLoaded = true

            PQCNotify.newImageHasBeenDisplayed()

        }

        // This is done with a slight delay IF the image is to be loaded at full scale
        // If done without delay then contentX/Y will be reset to 0
        Timer {
            id: adjustXY
            interval: 10
            onTriggered: {
                if(flickable.contentWidth > flickable.width)
                    flickable.contentX = (flickable.contentWidth-flickable.width)/2
                if(flickable.contentHeight > flickable.height)
                    flickable.contentY = (flickable.contentHeight-flickable.height)/2
            }
        }

        // hide the image
        function hideImage() {

            imageloaderitem.thisIsStartupFile = false

            // ignore anything that happened during a slideshow
            if(!PQCConstants.slideshowRunning) {

                if(loader_top.isMainImage) {

                    if((PQCSettings.imageviewRememberZoomRotationMirror || PQCSettings.imageviewPreserveZoom ||
                                                 PQCSettings.imageviewPreserveRotation || PQCSettings.imageviewPreserveMirror)) {
                        var vals = [loader_top.imagePosX,
                                    loader_top.imagePosY,
                                    loader_top.imageScale,
                                    loader_top.imageRotation,
                                    loader_top.imageMirrorH,
                                    loader_top.imageMirrorV]
                        if(PQCSettings.imageviewRememberZoomRotationMirror)
                            image_top.rememberChanges[imageloaderitem.imageSource] = vals
                        if(PQCSettings.imageviewPreserveZoom || PQCSettings.imageviewPreserveRotation || PQCSettings.imageviewPreserveMirror)
                            image_top.reuseChanges = vals
                    } else
                        // don't delete reuseChanges here, we want to keep those
                        delete image_top.rememberChanges[imageloaderitem.imageSource]

                }

            }

            var anim = PQCSettings.imageviewAnimationType
            if(anim === "random")
                anim = image_top.randomAnimation

            var index0 = PQCFileFolderModel.getIndexOfMainView(visibleSourcePrevCur[0])
            var index1 = PQCFileFolderModel.getIndexOfMainView(visibleSourcePrevCur[1])

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
                if(visibleSourcePrevCur[1] === "" || index0 > index1)
                    xAnimation.to *= -1

                xAnimation.restart()

            } else if(anim === "y") {

                yAnimation.stop()

                yAnimation.from = 0
                // the to value depends on whether we go forwards or backwards in the folder
                yAnimation.to = height*(loader_top.imageScale/loader_top.defaultScale)
                if(visibleSourcePrevCur[1] === "" || index0 > index1)
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

                if(visibleSourcePrevCur[1] === "" || index0 > index1) {
                    rotAnimation_rotation.from = 0
                    rotAnimation_rotation.to = -180
                }

                rotAnimation_opacity.from = 1
                rotAnimation_opacity.to = 0

                rotAnimation.restart()

            }

        }

        // if anything needs to be handled after image is hidden
        function handleWhenCompletelyHidden() {

            // exit photo sphere when manually entered
            if(loader_top.thisIsAPhotoSphere && loader_top.photoSphereManuallyEntered)
                loader_top.doExitPhotoSphere()

            // check if this file has been deleted. If so, then we deactivate this loader
            if(!PQCScriptsFilesPaths.doesItExist(imageloaderitem.imageSource)) {
                imageloaderitem.lastModified = ""
                imageloaderitem.containingFolder = ""
                imageloaderitem.imageLoadedAndReady = false
                imageloaderitem.imageSource = ""
            }

        }

    }

}
