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

    property int settingsInterpolationNearestNeighbourThreshold: Math.max(0, settings.interpolationNearestNeighbourThreshold)
    property int settingsInterpolationNearestNeighbourUpscale: settings.interpolationNearestNeighbourUpscale

    // This is called when a click occurs and the closeOnEmptyBackground setting is set to true
    function checkClickOnEmptyArea(posX, posY) {

        verboseMessage("MainView/MainImageRectangle - " + getanddostuff.convertIdIntoString(imageContainer), "checkClickOnEmptyArea(): " + posX + "/" + posY)

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

    // The scaleMultiplier takes care of the zooming to keep the binding for scale as is
    property real scaleMultiplier: 1
    // The scale depends on the actual image and the fitInWindow property
    scale: ((fitImageInWindow || image.sourceSize.width > defaultWidth || image.sourceSize.height > defaultHeight)
            ? scaleMultiplier * Math.min( defaultWidth / image.sourceSize.width,
                                          defaultHeight / image.sourceSize.height )
            : scaleMultiplier)
    // Animate the scale property. We reset the duration after it is done as it is sometimes set to zero (e.g. for loading a new image)
    Behavior on scale { NumberAnimation { id: scaleAni; duration: scaleDuration } }

    // When the image is zoomed in/out we emit a signal
    // this is needed, e.g., for the thumbnail bar in combination with the keepVisibleWhenNotZoomed property
    signal zoomChanged()
    onScaleMultiplierChanged:
        zoomChanged()

    // The x and y positions depend on the image
    x: ( defaultWidth - width ) / 2 + imageMargin/2
    y: ( defaultHeight - height ) / 2 + imageMargin/2

    // The rotation of the current image
    rotation: 0
    // When rotating by 90/270 degrees and with the image essentially not moved/zoomed we reset the zoom to show the whole image
    onRotationChanged: {
        if(scaleMultiplier > image.sourceSize.height/image.sourceSize.width-0.01 && scaleMultiplier < 1.1
                && Math.abs(x-((defaultWidth-width)/2+imageMargin/2)) < 10 && Math.abs(y-((defaultHeight-height)/2+imageMargin/2)) < 10)
            resetZoom()
    }

    // Signal that the other image element is supposed to be hidden
    signal hideOther()

    // After successfully loading an image set it as current image and show it
    signal setAsCurrentId()

    // The main image
    Image {

        id: image

        // Don't block interface while loading...
        asynchronous: true

        // source is tied to imageContainer property
        source: imageContainer.source

        // Center item in parent
        anchors.centerIn: parent

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
            verboseMessage("MainView/MainImageRectangle - " + getanddostuff.convertIdIntoString(imageContainer), "statusChanged: " + status)
            if(status == Image.Ready) {
                var currentIdBefore = currentId
                setAsCurrentId()
                // If we don't keep the properties, reset them all
                if(!settings.keepZoomRotationMirror) {
                    resetPositionWithoutAnimation()
                    resetZoomWithoutAnimation()
                    resetRotationWithoutAnimation()
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
                        imageContainer.scaleMultiplier = image1.scaleMultiplier
                        imageContainer.rotation = image1.rotation
                        // if the aspect ratio of the image has changed or the image dimensions, we reset the position, as this could otherwise lead to odd behavior
                        // (not wrong behavior, just not very userfriendly)
                        if(getImageRatio() != image1.getImageRatio() || getWidthPlusHeight() != image1.getWidthPlusHeight())
                            resetPositionWithoutAnimation()
                    // copy properties of image2 element
                    } else if(currentIdBefore == image2) {
                        imageContainer.x = image2.x
                        imageContainer.y = image2.y
                        imageContainer.scaleMultiplier = image2.scaleMultiplier
                        imageContainer.rotation = image2.rotation
                        // if the aspect ratio of the image has changed or the image dimensions, we reset the position, as this could otherwise lead to odd behavior
                        // (not wrong behavior, just not very userfriendly)
                        if(getImageRatio() != image2.getImageRatio() || getWidthPlusHeight() != image2.getWidthPlusHeight())
                            resetPositionWithoutAnimation()
                    // copy properties of imageANIM1 element
                    } else if(currentIdBefore == imageANIM1) {
                        imageContainer.x = imageANIM1.x
                        imageContainer.y = imageANIM1.y
                        imageContainer.scaleMultiplier = imageANIM1.scaleMultiplier
                        imageContainer.rotation = imageANIM1.rotation
                        // if the aspect ratio of the image has changed or the image dimensions, we reset the position, as this could otherwise lead to odd behavior
                        // (not wrong behavior, just not very userfriendly)
                        if(getImageRatio() != imageANIM1.getImageRatio() || getWidthPlusHeight() != imageANIM1.getWidthPlusHeight())
                            resetPositionWithoutAnimation()
                    // copy properties of imageANIM2 element
                    } else if(currentIdBefore == imageANIM2) {
                        imageContainer.x = imageANIM2.x
                        imageContainer.y = imageANIM2.y
                        imageContainer.scaleMultiplier = imageANIM2.scaleMultiplier
                        imageContainer.rotation = imageANIM2.rotation
                        // if the aspect ratio of the image has changed or the image dimensions, we reset the position, as this could otherwise lead to odd behavior
                        // (not wrong behavior, just not very userfriendly)
                        if(getImageRatio() != imageANIM2.getImageRatio() || getWidthPlusHeight() != imageANIM2.getWidthPlusHeight())
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

        // This is a masking image for when the image is not zoomed. It loads a scaled down version for better quality when not zoomed (or zoomed out)
        Image {

            id: imagemasking

            anchors.fill: parent

            // Don't block interface while loading...
            asynchronous: true

            // same source as main image, but only set after full image is loaded and only if pixmapcache is enabled
            // each image is fully loaded twice otherwise = very bad performance
            source: (image.status==Image.Ready&&settings.pixmapCache>32) ? parent.source : ""

            // this image is loaded scaled down
            sourceSize: Qt.size(defaultWidth, defaultHeight)

            // set fill mode
            fillMode: Image.PreserveAspectFit

            // high quality
            antialiasing: true
            smooth: true
            mipmap: true

            // only visible when image not zoomed or zoomed out
            visible: scaleMultiplier <= 1 && image.sourceSize.width > defaultWidth && image.sourceSize.height > defaultHeight && source != ""

        }

        Image {
            anchors.fill: parent
            visible: settings.showTransparencyMarkerBackground
            fillMode: Image.Tile
            source: "qrc:/img/transparent.png"
            z: -1
        }

    }

    // The pinch area makes the image manipulatable by a touch screen
    PinchArea {

        anchors.fill: parent

        pinch.target: imageContainer
        pinch.minimumRotation: -360
        pinch.maximumRotation: 360
        pinch.minimumScale: 0.1
        pinch.maximumScale: 10
        pinch.dragAxis: Pinch.XAndYAxis
        onPinchStarted: setFrameColor();

        onSmartZoom: {
            if (pinch.scale > 0) {
                imageContainer.rotation = 0;
                imageContainer.scaleMultiplier = Math.min(top.width, top.height) / Math.max(image.sourceSize.width, image.sourceSize.height) * 0.85
                imageContainer.x = flick.contentX + (flick.width - imageContainer.width) / 2
                imageContainer.y = flick.contentY + (flick.height - imageContainer.height) / 2
            } else {
                imageContainer.rotation = pinch.previousAngle
                imageContainer.scaleMultiplier = pinch.previousScale
                imageContainer.x = pinch.previousCenter.x - imageContainer.width / 2
                imageContainer.y = pinch.previousCenter.y - imageContainer.height / 2
            }
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

    /***************************************************************/
    /***************************************************************/
    // Some system functions

    // some info about the currently loaded image
    function getImageRatio() {
        verboseMessage("MainView/MainImageRectangle - " + getanddostuff.convertIdIntoString(imageContainer), "getImageRatio()")
        return image.width/image.height
    }
    function getWidthPlusHeight() {
        verboseMessage("MainView/MainImageRectangle - " + getanddostuff.convertIdIntoString(imageContainer), "getWidthPlusHeight()")
        return image.width+image.height
    }

    function reloadImage() {
        verboseMessage("MainView/MainImageRectangle - " + getanddostuff.convertIdIntoString(imageContainer), "reloadImage()")
        var tmp = image.source
        image.source = ""
        image.source = tmp
    }

    function returnImageContainer() {
        return imageContainer
    }

    // hide this element. Currently only transition available is fading out
    function hideMe() {
        verboseMessage("MainView/MainImageRectangle - " + getanddostuff.convertIdIntoString(imageContainer), "hideMe()")
        image.opacity = 0
    }

    // Reset position to center image on screen, animated.
    function resetPosition() {
        verboseMessage("MainView/MainImageRectangle - " + getanddostuff.convertIdIntoString(imageContainer), "resetPosition()")
        xAni.from = imageContainer.x
        xAni.to = ( defaultWidth - width ) / 2 + imageMargin/2
        yAni.from = imageContainer.y
        yAni.to = ( defaultHeight - height ) / 2 + imageMargin/2
        xAni.running = true
        yAni.running = true
    }

    // Reset position to center image on screen, not animated.
    function resetPositionWithoutAnimation() {
        verboseMessage("MainView/MainImageRectangle - " + getanddostuff.convertIdIntoString(imageContainer), "resetPositionWithoutAnimation()")
        x = Qt.binding(function() { return ( defaultWidth - width ) / 2 + imageMargin/2 })
        y = Qt.binding(function() { return ( defaultHeight - height ) / 2 + imageMargin/2 })
    }

    // Check if image is zoomed in
    function isZoomedIn() {
        verboseMessage("MainView/MainImageRectangle - " + getanddostuff.convertIdIntoString(imageContainer), "isZoomedIn()")
        return (scaleMultiplier>1)
    }


    /***************************************************************/
    /***************************************************************/
    // API functions for manipulating display of images

    function zoomIn() {
        verboseMessage("MainView/MainImageRectangle - " + getanddostuff.convertIdIntoString(imageContainer), "zoomIn()")
        scaleAni.duration = scaleDuration
        imageContainer.scaleMultiplier *= 1.1
    }

    function zoomOut() {
        verboseMessage("MainView/MainImageRectangle - " + getanddostuff.convertIdIntoString(imageContainer), "zoomOut()")
        scaleAni.duration = scaleDuration
        imageContainer.scaleMultiplier /= 1.1
    }

    function zoomActual() {
        verboseMessage("MainView/MainImageRectangle - " + getanddostuff.convertIdIntoString(imageContainer), "zoomActual()")
        if(image.sourceSize.width < defaultWidth && image.sourceSize.height < defaultHeight)
            return
        scaleAni.duration = scaleDuration
        scaleMultiplier = 1/Math.min( defaultWidth / image.sourceSize.width, defaultHeight / image.sourceSize.height)
    }

    function resetZoom() {
        verboseMessage("MainView/MainImageRectangle - " + getanddostuff.convertIdIntoString(imageContainer), "resetZoom()")
        scaleAni.duration = scaleDuration
        if((imageContainer.rotation%180 +180)%180 == 90)
            scaleMultiplier = image.sourceSize.height/image.sourceSize.width
        else
            scaleMultiplier = 1
    }
    function resetZoomWithoutAnimation() {
        verboseMessage("MainView/MainImageRectangle - " + getanddostuff.convertIdIntoString(imageContainer), "resetZoomWithoutAnimation()")
        scaleAni.duration = 0
        if((imageContainer.rotation%180 +180)%180 == 90)
            scaleMultiplier = image.sourceSize.height/image.sourceSize.width
        else
            scaleMultiplier = 1
    }

    function rotateImage(angle) {
        verboseMessage("MainView/MainImageRectangle - " + getanddostuff.convertIdIntoString(imageContainer), "rotateImage(): " + angle)
        rotationAni.from = imageContainer.rotation
        rotationAni.to = imageContainer.rotation+angle
        rotationAni.running = true
    }

    function resetRotation() {

        verboseMessage("MainView/MainImageRectangle - " + getanddostuff.convertIdIntoString(imageContainer), "resetRotation()")

        var angle = (imageContainer.rotation%360 +360)%360

        rotationAni.from = imageContainer.rotation
        rotationAni.to = (angle <= 180 ? imageContainer.rotation-angle : imageContainer.rotation+(360-angle))
        rotationAni.running = true

    }

    function resetRotationWithoutAnimation() {

        verboseMessage("MainView/MainImageRectangle - " + getanddostuff.convertIdIntoString(imageContainer), "resetRotationWithoutAnimation()")

        var angle = (imageContainer.rotation%360 +360)%360

        if(angle <= 180)
            imageContainer.rotation -= angle
        else
            imageContainer.rotation += (360-angle)

    }

    function mirrorHorizontal() {
        verboseMessage("MainView/MainImageRectangle - " + getanddostuff.convertIdIntoString(imageContainer), "mirrorHorizontal()")
        image.mirror = !image.mirror
        imagemasking.mirror = !imagemasking.mirror
    }

    function mirrorVertical() {
        verboseMessage("MainView/MainImageRectangle - " + getanddostuff.convertIdIntoString(imageContainer), "mirrorVertical()")
        imageContainer.rotation += 180
        image.mirror = !image.mirror
        imagemasking.mirror = !imagemasking.mirror
    }

    function resetMirror() {
        verboseMessage("MainView/MainImageRectangle - " + getanddostuff.convertIdIntoString(imageContainer), "resetMirror()")
        resetRotationWithoutAnimation()
        image.mirror = false
        imagemasking.mirror = false
    }

    function getCurrentSourceSize() {
        verboseMessage("MainView/MainImageRectangle - " + getanddostuff.convertIdIntoString(imageContainer), "getCurrentSourceSize()")
        return image.sourceSize
    }

}
