import QtQuick 2.6

Item {

    id: top

    // fill out main element
    anchors.fill: parent

    // the source of the current image
    property string source: ""
    onSourceChanged: {
        if(currentId == image1) {
            image2.source = ""
            image2.source = source
        } else {
            image1.source = ""
            image1.source = source
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
            onHideOther: image2.hideMe()
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
            onHideOther: image1.hideMe()
            onSetAsCurrentId: currentId = image2

        }

    }

    /****************************************************/
    /****************************************************/
    // All the API functions

    function loadImage(filename) {
        source = filename
    }

    function resetPosition() {
        image1.resetPosition()
        image2.resetPosition()
    }

    function resetZoom() {
        image1.resetZoom()
        image2.resetZoom()
    }

    function zoomIn() {
        if(currentId == image1)
            image1.zoomIn()
        else if(currentId == image2)
            image2.zoomIn()
    }
    function zoomOut() {
        if(currentId == image1)
            image1.zoomOut()
        else if(currentId == image2)
            image2.zoomOut()
    }

    function rotateImage(angle) {
        if(currentId == image1)
            image1.rotateImage(angle)
        else if(currentId == image2)
            image2.rotateImage(angle)
    }

    function resetRotation() {
        if(currentId == image1)
            image1.resetRotation()
        else if(currentId == image2)
            image2.resetRotation()
    }

}
