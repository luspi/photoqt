import QtQuick 2.5

Item {

    id: mainimage_top

    visible: !variables.deleteNothingLeft && !variables.filterNoMatch

    // fill out main element
    anchors {
        fill: parent
        leftMargin: settings.marginAroundImage+metadata.nonFloatWidth
        rightMargin: settings.marginAroundImage
        topMargin: settings.marginAroundImage
        bottomMargin: settings.marginAroundImage+(settings.thumbnailKeepVisible||settings.thumbnailKeepVisibleWhenNotZoomedIn ? variables.thumbnailsheight : 0)
    }

    // the source of the current image
    property bool animated: false
    property string source: ""
    onSourceChanged: {
        mainImageFinishedLoading = false
        if(animated) {
            if(currentId == imageANIM1) {
                imageANIM2.paused = false
                imageANIM2.source = ""
                imageANIM2.source = source
            } else {
                imageANIM1.paused = false
                imageANIM1.source = ""
                imageANIM1.source = source
            }
        } else {
            if(currentId == image1) {
                image2.source = ""
                image2.source = source
            } else {
                image1.source = ""
                image1.source = source
            }
        }
    }

    signal zoomChanged()

    // this property os false as long the mainimage has not yet completed loading. It switches to true once the mainimage gets displayed
    property bool mainImageFinishedLoading: false
    // the changed signals of properties don't seem to be globally accessible, thus we need to emit a custom signal to let the world (in particular the Thumbnails) know of a change here
    signal mainImageLoadingChanged()
    onMainImageFinishedLoadingChanged: {
        mainImageLoadingChanged()
        if(mainimage_top.source == "") return
        if(!mainImageFinishedLoading)
            showLoadingImage.start()
        else {
            showLoadingImage.stop()
            loadingimage.opacity = 0
        }
    }

    // the currentId holds which one of the four image elements is currently visible
    property var currentId: undefined

    // This flickable keeps the image element movable
    Flickable {

        id: flick

        anchors.fill: parent

        // The content is the same size as the flickable. The moving is handled by the image elements themselves
        contentWidth: width
        contentHeight: height

        // The first image
        MainImageRectangle {

            id: image1

            // Pass on some settings

            fitImageInWindow: settings.fitInWindow
            imageMargin: settings.marginAroundImage

            positionDuration: 250
            transitionDuration: (variables.slideshowRunning ? settings.slideShowImageTransition*150 : settings.imageTransition*150)
            scaleDuration: 250
            rotationDuration: 250

            defaultHeight: mainimage_top.height-settings.marginAroundImage
            defaultWidth: mainimage_top.width-settings.marginAroundImage

            // Connect to some signals, set this as current or hide the other image
            onHideOther: {
                image2.hideMe()
                imageANIM1.hideMe()
                imageANIM2.hideMe()
            }
            onSetAsCurrentId: currentId = image1

            onZoomChanged:
                mainimage_top.zoomChanged()

        }

        // The second image
        MainImageRectangle {

            id: image2

            // Pass on some settings

            fitImageInWindow: settings.fitInWindow
            imageMargin: settings.marginAroundImage

            positionDuration: 250
            transitionDuration: (variables.slideshowRunning ? settings.slideShowImageTransition*150 : settings.imageTransition*150)
            scaleDuration: 250
            rotationDuration: 250

            defaultHeight: mainimage_top.height-settings.marginAroundImage
            defaultWidth: mainimage_top.width-settings.marginAroundImage

            // Connect to some signals, set this as current or hide the other image
            onHideOther: {
                image1.hideMe()
                imageANIM1.hideMe()
                imageANIM2.hideMe()
            }
            onSetAsCurrentId: currentId = image2

            onZoomChanged:
                mainimage_top.zoomChanged()

        }

        // The first image
        MainImageRectangleAnimated {

            id: imageANIM1

            // Pass on some settings

            fitImageInWindow: settings.fitInWindow
            imageMargin: settings.marginAroundImage

            positionDuration: 250
            transitionDuration: (variables.slideshowRunning ? settings.slideShowImageTransition*150 : settings.imageTransition*150)
            scaleDuration: 250
            rotationDuration: 250

            defaultHeight: mainimage_top.height-settings.marginAroundImage
            defaultWidth: mainimage_top.width-settings.marginAroundImage

            // Connect to some signals, set this as current or hide the other image
            onHideOther: {
                image1.hideMe()
                image2.hideMe()
                imageANIM2.hideMe()
            }
            onSetAsCurrentId: currentId = imageANIM1

            onZoomChanged:
                mainimage_top.zoomChanged()

        }

        // The second image
        MainImageRectangleAnimated {

            id: imageANIM2

            // Pass on some settings

            fitImageInWindow: settings.fitInWindow
            imageMargin: settings.marginAroundImage

            positionDuration: 250
            transitionDuration: (variables.slideshowRunning ? settings.slideShowImageTransition*150 : settings.imageTransition*150)
            scaleDuration: 250
            rotationDuration: 250

            defaultHeight: mainimage_top.height-settings.marginAroundImage
            defaultWidth: mainimage_top.width-settings.marginAroundImage

            // Connect to some signals, set this as current or hide the other image
            onHideOther: {
                image1.hideMe()
                image2.hideMe()
                imageANIM1.hideMe()
            }
            onSetAsCurrentId: currentId = imageANIM2

            onZoomChanged:
                mainimage_top.zoomChanged()

        }

    }

    // This item shows a loading indicator, to give the user some feedback that something is in fact going on
    LoadingIndicator { id: loadingimage }

    // This timer allows for a little timeout before the loading indicator is shown
    // Most 'normal' images are loaded pretty quickly, no need to bother with this indicator for those
    Timer {

        id: showLoadingImage

        // show indicator if the image takes more than 500ms to load
        interval: 1000
        repeat: false
        running: false

        // show indicator only if the mainimage hasn't finished loading in the meantime
        onTriggered:
            if(!mainimage_top.mainImageFinishedLoading)
                loadingimage.opacity = 1

    }

    Connections {
        target: watcher
        onImageUpdated:
            reloadImage()
    }

    /****************************************************/
    /****************************************************/
    // All the API functions

    function isZoomedIn() {
        if(currentId == image1)
            return image1.isZoomedIn()
        else if(currentId == image2)
            return image2.isZoomedIn()
        else if(currentId == imageANIM1)
            return imageANIM1.isZoomedIn()
        else if(currentId == imageANIM2)
            return imageANIM2.isZoomedIn()
    }

    function loadImage(filename, animated) {
        mainimage_top.animated = animated
        mainimage_top.source = filename
    }

    function reloadImage() {
        if(currentId == image1)
            image1.reloadImage()
        else if(currentId == image2)
            image2.reloadImage()
        else if(currentId == imageANIM1)
            imageANIM1.reloadImage()
        else if(currentId == imageANIM2)
            imageANIM2.reloadImage()
    }

    function resetPosition() {
        image1.resetPosition()
        image2.resetPosition()
        imageANIM1.resetPosition()
        imageANIM2.resetPosition()
    }

    function resetZoom() {
        image1.resetZoom()
        image2.resetZoom()
        imageANIM1.resetZoom()
        imageANIM2.resetZoom()
    }

    function zoomIn() {
        if(currentId == image1)
            image1.zoomIn()
        else if(currentId == image2)
            image2.zoomIn()
        else if(currentId == imageANIM1)
            imageANIM1.zoomIn()
        else if(currentId == imageANIM2)
            imageANIM2.zoomIn()
    }
    function zoomOut() {
        if(currentId == image1)
            image1.zoomOut()
        else if(currentId == image2)
            image2.zoomOut()
        else if(currentId == imageANIM1)
            imageANIM1.zoomOut()
        else if(currentId == imageANIM2)
            imageANIM2.zoomOut()
    }
    function zoomActual() {
        if(currentId == image1)
            image1.zoomActual()
        else if(currentId == image2)
            image2.zoomActual()
        else if(currentId == imageANIM1)
            imageANIM1.zoomActual()
        else if(currentId == imageANIM2)
            imageANIM2.zoomActual()
    }

    function rotateImage(angle) {
        if(currentId == image1)
            image1.rotateImage(angle)
        else if(currentId == image2)
            image2.rotateImage(angle)
        else if(currentId == imageANIM1)
            imageANIM1.rotateImage(angle)
        else if(currentId == imageANIM2)
            imageANIM2.rotateImage(angle)
    }

    function resetRotation() {
        if(currentId == image1)
            image1.resetRotation()
        else if(currentId == image2)
            image2.resetRotation()
        else if(currentId == imageANIM1)
            imageANIM1.resetRotation()
        else if(currentId == imageANIM2)
            imageANIM2.resetRotation()
    }

    function playPauseAnimation() {
        if(currentId == imageANIM1)
            imageANIM1.paused = !imageANIM1.paused
        else if(currentId == imageANIM2)
            imageANIM2.paused = !imageANIM2.paused
    }

    function returnImageContainer() {
        if(currentId == image1)
            return image1.returnImageContainer()
        else if(currentId == image2)
            return image2.returnImageContainer()
        else if(currentId == imageANIM1)
            return imageANIM1.returnImageContainer()
        else if(currentId == imageANIM2)
            return imageANIM2.returnImageContainer()

    }

    function mirrorHorizontal() {
        if(currentId == image1)
            image1.mirrorHorizontal()
        else if(currentId == image2)
            image2.mirrorHorizontal()
        else if(currentId == imageANIM1)
            imageANIM1.mirrorHorizontal()
        else if(currentId == imageANIM2)
            imageANIM2.mirrorHorizontal()
    }

    function mirrorVertical() {
        if(currentId == image1)
            image1.mirrorVertical()
        else if(currentId == image2)
            image2.mirrorVertical()
        else if(currentId == imageANIM1)
            imageANIM1.mirrorVertical()
        else if(currentId == imageANIM2)
            imageANIM2.mirrorVertical()
    }

    function resetMirror() {
        if(currentId == image1)
            image1.resetMirror()
        else if(currentId == image2)
            image2.resetMirror()
        else if(currentId == imageANIM1)
            imageANIM1.resetMirror()
        else if(currentId == imageANIM2)
            imageANIM2.resetMirror()
    }

    function getCurrentSourceSize() {
        if(currentId == image1)
            return image1
        else if(currentId == image2)
            return image2
        else if(currentId == imageANIM1)
            return imageANIM1
        else if(currentId == imageANIM2)
            return imageANIM2
    }

}
