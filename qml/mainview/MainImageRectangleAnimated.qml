/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
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

import QtQuick 2.5

Item {

    // There are two of these created to allow for animated transitions

    id: imageContainer

    // Dimension always follows the image
    width: image.width
    height: image.height

    // When image is hidden, hide element (allow elements below to be accesible)
    visible: (image.opacity!=0)

    // manipulate the timings of the animations
    property int positionDuration: 200
    property int transitionDuration: 200
    property int scaleDuration: 200
    property int rotationDuration: 200

    // The default maximum width/height of the image
    property int defaultWidth: 600
    property int defaultHeight: 400
    property int imageMargin: 5

    // fit image into the window irrespective of its actual dimensions
    property bool fitImageInWindow: false

    // the source of the current image
    property string source: ""
    onSourceChanged: zoomHasBeenManuallyChanged = false

    // We check whether the image has ever been zoomed. If it hasn't, then we can always ensure image is adjusted inside window
    property bool zoomHasBeenManuallyChanged: false
    // This is the threshold for how close to the original size we need to be before fitting image into window when window is resized
    property int zoomedThreshold: Math.min(mainwindow.width*0.1, mainwindow.height*0.1)

    property int settingsInterpolationNearestNeighbourThreshold: Math.max(0, settings.interpolationNearestNeighbourThreshold)
    property int settingsInterpolationNearestNeighbourUpscale: settings.interpolationNearestNeighbourUpscale

    // This is called when a click occurs and the closeOnEmptyBackground setting is set to true
    function checkClickOnEmptyArea(posX, posY) {

        verboseMessage("MainView/MainImageRectangleAnimated - " + getanddostuff.convertIdIntoString(imageContainer), "checkClickOnEmptyArea(): " + posX + "/" + posY)

        // safety margin, just in case
        var safetyMargin = 5

        // map click to image item
        var pt = image.mapFromItem(mainwindow, posX, posY)

        // if click is outside of image item ...
        if(pt.x < -safetyMargin || pt.x > image.width+safetyMargin || pt.y < -safetyMargin || pt.y > image.height+safetyMargin)
            // ... close window
            mainwindow.closePhotoQt()

    }

    opacity: variables.guiBlocked&&!variables.slideshowRunning ? 0.1 : 1
    Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

    property bool paused: false

    // Scaling of image
    scale: 1
    // Animate the scale property
    Behavior on scale { NumberAnimation { id: scaleAni; duration: scaleDuration } }

    // When the image is zoomed in/out we emit a signal
    // this is needed, e.g., for the thumbnail bar in combination with the keepVisibleWhenNotZoomed property
    signal zoomChanged()
    onScaleChanged:
        zoomChanged()

    // The x and y positions depend on the image
    x: ( defaultWidth - width ) / 2 + imageMargin/2
    y: ( defaultHeight - height ) / 2 + imageMargin/2

    // The rotation of the current image
    rotation: 0
    // When rotating by 90/270 degrees and with the image essentially not moved/zoomed we reset the zoom to show the whole image
    onRotationChanged: {
        if(Math.abs(x-((defaultWidth-width)/2+imageMargin/2)) < 10 && Math.abs(y-((defaultHeight-height)/2+imageMargin/2)) < 10) {
            if(((Math.abs(scale*image.paintedHeight-defaultHeight) < 0.01 && scale*image.paintedWidth < defaultWidth)
                || (scale*image.paintedHeight < defaultHeight && Math.abs(scale*image.paintedWidth-defaultWidth) < 0.01))) {
                resetZoom()
                zoomAdjustedAfterRotation = true
            } else if(zoomAdjustedAfterRotation)
                resetZoom()
        }
    }
    // If this is set to true, then. when rotated, the image is fit into the screen.
    // This happens as long as the user doesn't manually zoom the image (that resets this to false)
    property bool zoomAdjustedAfterRotation: false

    // Signal that the other image element is supposed to be hidden
    signal hideOther()

    // After successfully loading an image set it as current image and show it
    signal setAsCurrentId()

    // The main image
    AnimatedImage {

        id: image

        // Don't block interface while loading...
        asynchronous: true

        // source is tied to imageContainer property
        source: imageContainer.source

        // Center item in parent
        anchors.centerIn: parent

        paused: (parent.paused || !parent.visible)

        // High quality
        antialiasing: true
        smooth: (settingsInterpolationNearestNeighbourUpscale && image.paintedWidth<=settingsInterpolationNearestNeighbourThreshold && image.paintedHeight<=settingsInterpolationNearestNeighbourThreshold) ? false : true
        mipmap: (settingsInterpolationNearestNeighbourUpscale && image.paintedWidth<=settingsInterpolationNearestNeighbourThreshold && image.paintedHeight<=settingsInterpolationNearestNeighbourThreshold) ? false : true

        cache: false

        // set fill mode
        fillMode: Image.PreserveAspectFit

        // visibility depends on opacity which is animated
        visible: (opacity!=0)
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: transitionDuration } }
        onOpacityChanged: {
            if(!settings.keepZoomRotationMirror) {
                if(opacity == 0) {
                    resetPositionWithoutAnimation()
                    resetRotationWithoutAnimation()
                    resetZoomWithoutAnimation()
                // to make sure the scale is properly reset (without animation) when showing a new image
                } else if(opacity < 0.1)
                    scaleAni.complete()
            }
        }

        // When imae is loaded, show image and hid the other
        onStatusChanged: {
            verboseMessage("MainView/MainImageRectangleAnimated - " + getanddostuff.convertIdIntoString(imageContainer), "statusChanged: " + status)
            if(status == Image.Ready) {
                var currentIdBefore = currentId
                setAsCurrentId()
                // If we don't keep the properties, reset them all
                if(!settings.keepZoomRotationMirror) {
                    resetPositionWithoutAnimation()
                    resetZoomWithoutAnimation()
                    resetRotationWithoutAnimation()
                    image.mirror = false
                    // The scale property is the only property animated using 'Behavior on' (due to a complex scale property)
                    // This is to ensure the animation is completed. Its duration should be set to 0, but this does not always work reliably
                    scaleAni.complete()
                // Keep rotation, scale, positionDuration
                } else {
                    // no scale animation wanted
                    scaleAni.duration = 0
                    // copy properties of image1 element
                    if(currentIdBefore == image1) {
                        imageContainer.x = image1.x
                        imageContainer.y = image1.y
                        rotationAni.to = image1.rotation
                        rotationAni.start()
                        rotationAni.complete()
                        resetScale.restoreScale(image1.scale)
                        image.mirror = image1.getMirror()
                        // if the aspect ratio of the image has changed or the image dimensions, we reset the position, as this could otherwise lead to odd behavior
                        // (not wrong behavior, just not very userfriendly)
                        if(getImageRatio() !== image1.getImageRatio() || getWidthPlusHeight() !== image1.getWidthPlusHeight())
                            resetPositionWithoutAnimation()
                    // copy properties of image2 element
                    } else if(currentIdBefore == image2) {
                        imageContainer.x = image2.x
                        imageContainer.y = image2.y
                        rotationAni.to = image2.rotation
                        rotationAni.start()
                        rotationAni.complete()
                        resetScale.restoreScale(image2.scale)
                        image.mirror = image2.getMirror()
                        // if the aspect ratio of the image has changed or the image dimensions, we reset the position, as this could otherwise lead to odd behavior
                        // (not wrong behavior, just not very userfriendly)
                        if(getImageRatio() !== image2.getImageRatio() || getWidthPlusHeight() !== image2.getWidthPlusHeight())
                            resetPositionWithoutAnimation()
                    // copy properties of imageANIM1 element
                    } else if(currentIdBefore == imageANIM1) {
                        imageContainer.x = imageANIM1.x
                        imageContainer.y = imageANIM1.y
                        rotationAni.to = imageANIM1.rotation
                        rotationAni.start()
                        rotationAni.complete()
                        resetScale.restoreScale(imageANIM1.scale)
                        image.mirror = imageANIM1.getMirror()
                        // if the aspect ratio of the image has changed or the image dimensions, we reset the position, as this could otherwise lead to odd behavior
                        // (not wrong behavior, just not very userfriendly)
                        if(getImageRatio() !== imageANIM1.getImageRatio() || getWidthPlusHeight() !== imageANIM1.getWidthPlusHeight())
                            resetPositionWithoutAnimation()
                    // copy properties of imageANIM2 element
                    } else if(currentIdBefore == imageANIM2) {
                        imageContainer.x = imageANIM2.x
                        imageContainer.y = imageANIM2.y
                        rotationAni.to = imageANIM2.rotation
                        rotationAni.start()
                        rotationAni.complete()
                        resetScale.restoreScale(imageANIM2.scale)
                        image.mirror = imageANIM2.getMirror()
                        // if the aspect ratio of the image has changed or the image dimensions, we reset the position, as this could otherwise lead to odd behavior
                        // (not wrong behavior, just not very userfriendly)
                        if(getImageRatio() !== imageANIM2.getImageRatio() || getWidthPlusHeight() !== imageANIM2.getWidthPlusHeight())
                            resetPositionWithoutAnimation()
                    }
                }
                opacity = 1
                mainImageFinishedLoading = true
                hideOther()
                loadingimage.opacity = 0
            } else if(status == Image.Loading)
                showLoadingImage.start()
        }

        // This is necessary as otherwise for some reasom (not sure why) the zoom will always be reset. This ensures the scale property is properly set (if Keep* setting is set)
        Timer {
            id: resetScale
            interval: 0
            repeat: false
            function restoreScale(val) { restore = val; start() }
            property real restore: 1
            onTriggered: imageContainer.scale = restore
        }

        Image {
            anchors.fill: parent
            visible: settings.showTransparencyMarkerBackground
            fillMode: Image.Tile
            source: "qrc:/img/transparent.png"
            z: -1
        }

    }

    // We use this type of animation for resetting the x,y coordinates on user request, as otherwise (when using Behavior on x,y)
    // the image might be weirdly animated when fading in/out
    PropertyAnimation {
        id: xAni
        target: imageContainer
        properties: "x"
        duration: positionDuration
    }
    PropertyAnimation {
        id: yAni
        target: imageContainer
        properties: "y"
        duration: positionDuration
    }
    PropertyAnimation {
        id: rotationAni
        target: imageContainer
        properties: "rotation"
        duration: rotationDuration
    }

    /************************************************************************************************************/
    /************************************************************************************************************/

    // Sometimes an image changes status before the proper sourcesize is set, this ensures it is properly visible
    Connections {
        target: image
        onSourceSizeChanged:
            resetZoomWithoutAnimation()
    }

    // React to a change to fitInWindow setting
    Connections {
        target: settings
        onFitInWindowChanged:
            resetZoomWithoutAnimation()
    }

    // React to changes to window size
    Connections {
        target: mainwindow
        onWidthChanged: {
            var dw = imageContainer.width*imageContainer.scale-imageContainer.defaultWidth
            var dh = imageContainer.height*imageContainer.scale-imageContainer.defaultHeight
            if(!zoomHasBeenManuallyChanged ||
                    (Math.abs(dw) <= imageContainer.zoomedThreshold && dh < imageContainer.defaultHeight+imageContainer.zoomedThreshold) ||
                    (Math.abs(dh) <= imageContainer.zoomedThreshold && dw < imageContainer.defaultWidth+imageContainer.zoomedThreshold))
                resetZoomWithoutAnimation()
        }
        onHeightChanged: {
            var dw = imageContainer.width*imageContainer.scale-imageContainer.defaultWidth
            var dh = imageContainer.height*imageContainer.scale-imageContainer.defaultHeight
            if(!zoomHasBeenManuallyChanged ||
                    (Math.abs(dw) <= imageContainer.zoomedThreshold && dh < imageContainer.defaultHeight+imageContainer.zoomedThreshold) ||
                    (Math.abs(dh) <= imageContainer.zoomedThreshold && dw < imageContainer.defaultWidth+imageContainer.zoomedThreshold))
                resetZoomWithoutAnimation()
        }
    }

    /***************************************************************/
    /***************************************************************/
    // Some system functions

    // some info about the currently loaded image
    function getImageRatio() {
        verboseMessage("MainView/MainImageRectangleAnimated - " + getanddostuff.convertIdIntoString(imageContainer), "getImageRatio()")
        return image.width/image.height
    }
    function getWidthPlusHeight() {
        verboseMessage("MainView/MainImageRectangleAnimated - " + getanddostuff.convertIdIntoString(imageContainer), "getWidthPlusHeight()")
        return image.width+image.height
    }

    function reloadImage() {
        verboseMessage("MainView/MainImageRectangleAnimated - " + getanddostuff.convertIdIntoString(imageContainer), "reloadImage()")
        var tmp = image.source
        image.source = ""
        image.source = tmp
    }

    function returnImageContainer() {
        return imageContainer
    }

    // hide this element. Currently only transition available is fading out
    function hideMe() {
        verboseMessage("MainView/MainImageRectangleAnimated - " + getanddostuff.convertIdIntoString(imageContainer), "hideMe()")
        image.opacity = 0
    }

    // Reset position to center image on screen, animated.
    function resetPosition() {
        verboseMessage("MainView/MainImageRectangleAnimated - " + getanddostuff.convertIdIntoString(imageContainer), "resetPosition()")
        xAni.from = imageContainer.x
        xAni.to = ( defaultWidth - width ) / 2 + imageMargin/2
        yAni.from = imageContainer.y
        yAni.to = ( defaultHeight - height ) / 2 + imageMargin/2
        xAni.running = true
        yAni.running = true
    }

    // Reset position to center image on screen, not animated.
    function resetPositionWithoutAnimation() {
        verboseMessage("MainView/MainImageRectangleAnimated - " + getanddostuff.convertIdIntoString(imageContainer), "resetPositionWithoutAnimation()")
        x = Qt.binding(function() { return ( defaultWidth - width ) / 2 + imageMargin/2 })
        y = Qt.binding(function() { return ( defaultHeight - height ) / 2 + imageMargin/2 })
    }

    // Check if image is zoomed in
    function isZoomedIn() {
        verboseMessage("MainView/MainImageRectangleAnimated - " + getanddostuff.convertIdIntoString(imageContainer), "isZoomedIn()")
        if((rotationAni.to%180 +180)%180 == 90)
            return (height*scale > defaultWidth+zoomedThreshold || width*scale > defaultHeight+zoomedThreshold)
        return (width*scale > defaultWidth+zoomedThreshold || height*scale > defaultHeight+zoomedThreshold)
    }


    /***************************************************************/
    /***************************************************************/
    // API functions for manipulating display of images

    function zoomIn() {
        verboseMessage("MainView/MainImageRectangleAnimated - " + getanddostuff.convertIdIntoString(imageContainer), "zoomIn()")
        scaleAni.duration = scaleDuration
        imageContainer.scale *= 1.1
        zoomAdjustedAfterRotation = false
        zoomHasBeenManuallyChanged = true
    }

    function zoomOut() {
        verboseMessage("MainView/MainImageRectangleAnimated - " + getanddostuff.convertIdIntoString(imageContainer), "zoomOut()")
        scaleAni.duration = scaleDuration
        imageContainer.scale /= 1.1
        zoomAdjustedAfterRotation = false
        zoomHasBeenManuallyChanged = true
    }

    function zoomActual() {
        verboseMessage("MainView/MainImageRectangleAnimated - " + getanddostuff.convertIdIntoString(imageContainer), "zoomActual()")
        if(image.sourceSize.width < defaultWidth && image.sourceSize.height < defaultHeight) {
            resetZoom()
            return
        }
        scaleAni.duration = scaleDuration
        scale = 1/Math.min( defaultWidth / image.sourceSize.width, defaultHeight / image.sourceSize.height)
        zoomAdjustedAfterRotation = false
        zoomHasBeenManuallyChanged = true
    }

    function resetZoom() {

        verboseMessage("MainView/MainImageRectangleAnimated - " + getanddostuff.convertIdIntoString(imageContainer), "resetZoom()")

        _resetZoomWithDuration(scaleDuration)

    }

    function resetZoomWithoutAnimation() {

        verboseMessage("MainView/MainImageRectangleAnimated - " + getanddostuff.convertIdIntoString(imageContainer), "resetZoom()")

        _resetZoomWithDuration(0)

    }

    function _resetZoomWithDuration(duration) {

        scaleAni.duration = duration

        // fit in window for smaller images
        if(settings.fitInWindow && image.sourceSize.width < defaultWidth && image.sourceSize.height < defaultHeight) {
            imageContainer.scale = Math.min(defaultWidth / image.sourceSize.width, defaultHeight / image.sourceSize.height)
            return
        }

        // find the right scale factor to fit image inside window
        var facW = 1
        var facH = 1

        // when image is rotated +/- 90 degrees ...
        if((rotationAni.to%180 +180)%180 == 90) {

            if(image.sourceSize.width > defaultHeight)
                facW = defaultHeight / image.sourceSize.width
            if(image.sourceSize.height > defaultWidth)
                facH = defaultWidth / image.sourceSize.height

        // ... else ...
        } else {

            // find the smallest factor required for proper scaling
            if(image.sourceSize.width > defaultWidth)
                facW = defaultWidth / image.sourceSize.width
            if(image.sourceSize.height > defaultHeight)
                facH = defaultHeight / image.sourceSize.height

        }

        // scale
        imageContainer.scale = Math.min(facH, facW)

        zoomHasBeenManuallyChanged = false

    }

    function rotateImage(angle) {
        verboseMessage("MainView/MainImageRectangleAnimated - " + getanddostuff.convertIdIntoString(imageContainer), "rotateImage(): " + angle)
        rotationAni.from = imageContainer.rotation
        rotationAni.to = imageContainer.rotation+angle
        rotationAni.running = true
    }

    function resetRotation() {

        verboseMessage("MainView/MainImageRectangleAnimated - " + getanddostuff.convertIdIntoString(imageContainer), "resetRotation()")

        var angle = (imageContainer.rotation%360 +360)%360

        rotationAni.from = imageContainer.rotation
        rotationAni.to = (angle <= 180 ? imageContainer.rotation-angle : imageContainer.rotation+(360-angle))
        rotationAni.running = true

    }

    function resetRotationWithoutAnimation() {

        verboseMessage("MainView/MainImageRectangleAnimated - " + getanddostuff.convertIdIntoString(imageContainer), "resetRotationWithoutAnimation()")

        var angle = (imageContainer.rotation%360 +360)%360

        if(angle <= 180)
            imageContainer.rotation -= angle
        else
            imageContainer.rotation += (360-angle)

    }

    function mirrorHorizontal() {
        verboseMessage("MainView/MainImageRectangleAnimated - " + getanddostuff.convertIdIntoString(imageContainer), "mirrorHorizontal()")
        image.mirror = !image.mirror
    }

    function mirrorVertical() {
        verboseMessage("MainView/MainImageRectangleAnimated - " + getanddostuff.convertIdIntoString(imageContainer), "mirrorVertical()")
        imageContainer.rotation += 180
        image.mirror = !image.mirror
    }

    function getMirror() {
        return image.mirror
    }

    function resetMirror() {
        verboseMessage("MainView/MainImageRectangleAnimated - " + getanddostuff.convertIdIntoString(imageContainer), "resetMirror()")
        resetRotationWithoutAnimation()
        image.mirror = false
    }

    function getCurrentSourceSize() {
        verboseMessage("MainView/MainImageRectangleAnimated - " + getanddostuff.convertIdIntoString(imageContainer), "getCurrentSourceSize()")
        return image.sourceSize
    }

}
