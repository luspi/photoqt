import QtQuick 2.6

Item {

    id: top

    visible: !variables.deleteNothingLeft && !variables.filterNoMatch

    // fill out main element
    anchors {
        fill: parent
        leftMargin: settings.borderAroundImg+metadata.nonFloatWidth
        rightMargin: settings.borderAroundImg
        topMargin: settings.borderAroundImg
        bottomMargin: settings.borderAroundImg
    }

    // the source of the current image
    property bool animated: false
    property string source: ""
    onSourceChanged: {
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

    // the currentId holds which one of the two image elements is currently visible
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
            imageMargin: settings.borderAroundImg

            positionDuration: settings.transition*150
            transitionDuration: settings.transition*150
            scaleDuration: settings.transition*150
            rotationDuration: settings.transition*150

            defaultHeight: top.height-settings.borderAroundImg
            defaultWidth: top.width-settings.borderAroundImg

            // Connect to some signals, set this as current or hide the other image
            onHideOther: {
                image2.hideMe()
                imageANIM1.hideMe()
                imageANIM2.hideMe()
            }
            onSetAsCurrentId: currentId = image1

        }

        // The second image
        MainImageRectangle {

            id: image2

            // Pass on some settings

            fitImageInWindow: settings.fitInWindow
            imageMargin: settings.borderAroundImg

            positionDuration: settings.transition*150
            transitionDuration: settings.transition*150
            scaleDuration: settings.transition*150
            rotationDuration: settings.transition*150

            defaultHeight: top.height-settings.borderAroundImg
            defaultWidth: top.width-settings.borderAroundImg

            // Connect to some signals, set this as current or hide the other image
            onHideOther: {
                image1.hideMe()
                imageANIM1.hideMe()
                imageANIM2.hideMe()
            }
            onSetAsCurrentId: currentId = image2

        }

        // The first image
        MainImageRectangleAnimated {

            id: imageANIM1

            // Pass on some settings

            fitImageInWindow: settings.fitInWindow
            imageMargin: settings.borderAroundImg

            positionDuration: settings.transition*150
            transitionDuration: settings.transition*150
            scaleDuration: settings.transition*150
            rotationDuration: settings.transition*150

            defaultHeight: top.height-settings.borderAroundImg
            defaultWidth: top.width-settings.borderAroundImg

            // Connect to some signals, set this as current or hide the other image
            onHideOther: {
                image1.hideMe()
                image2.hideMe()
                imageANIM2.hideMe()
            }
            onSetAsCurrentId: currentId = imageANIM1

        }

        // The second image
        MainImageRectangleAnimated {

            id: imageANIM2

            // Pass on some settings

            fitImageInWindow: settings.fitInWindow
            imageMargin: settings.borderAroundImg

            positionDuration: settings.transition*150
            transitionDuration: settings.transition*150
            scaleDuration: settings.transition*150
            rotationDuration: settings.transition*150

            defaultHeight: top.height-settings.borderAroundImg
            defaultWidth: top.width-settings.borderAroundImg

            // Connect to some signals, set this as current or hide the other image
            onHideOther: {
                image1.hideMe()
                image2.hideMe()
                imageANIM1.hideMe()
            }
            onSetAsCurrentId: currentId = imageANIM2

        }

    }

    /****************************************************/
    /****************************************************/
    // All the API functions

    function loadImage(filename, animated) {
        top.animated = animated
        top.source = filename
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
