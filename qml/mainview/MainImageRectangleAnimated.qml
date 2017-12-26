import QtQuick 2.6

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

    property bool paused: false

    // The scaleMultiplier takes care of the zooming to keep the binding for scale as is
    property real scaleMultiplier: 1
    // The scale depends on the actual image and the fitInWindow property
    scale: ((fitImageInWindow || image.sourceSize.width > defaultWidth || image.sourceSize.height > defaultHeight)
            ? scaleMultiplier * Math.min( defaultWidth / image.sourceSize.width,
                                          defaultHeight / image.sourceSize.height )
            : scaleMultiplier)
    // Animate the scale property. We reset the duration after it is done as it is sometimes set to zero (e.g. for loading a new image)
    Behavior on scale { NumberAnimation { id: scaleAni; duration: scaleDuration; onStopped: duration = scaleDuration } }

    // The x and y positions depend on the image
    x: ( defaultWidth - width ) / 2 + imageMargin/2
    y: ( defaultHeight - height ) / 2 + imageMargin/2
    // Animate the x/y properties
    Behavior on x { NumberAnimation { id: posXAni; duration: 0; onStopped: duration = 0 } }
    Behavior on y { NumberAnimation { id: posYAni; duration: 0; onStopped: duration = 0 } }

    // The rotation of the current image
    rotation: 0
    // ... animated
    Behavior on rotation { NumberAnimation { id: rotationAni; duration: rotationDuration; onStopped: duration = rotationDuration } }
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
    AnimatedImage {

        id: image

        // Currently, this has to be set to false, otherwise the thumbnails will likely be loaded first
//        asynchronous: true

        // source is tied to imageContainer property
        source: imageContainer.source

        paused: (parent.paused || !parent.visible)

        // Center item in parent
        anchors.centerIn: parent

        // High quality
        antialiasing: true
        smooth: true
        mipmap: true

        // set fill mode
        fillMode: Image.PreserveAspectFit

        // visibility depends on opacity which is animated
        visible: (opacity!=0)
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: transitionDuration } }

        // When imae is loaded, show image and hid the other
        onStatusChanged: {
            if(status == Image.Ready) {
                setAsCurrentId()
                resetPositionWithoutAnimation()
                resetZoomWithoutAnimation()
                resetRotationWithoutAnimation()
                opacity = 1
                hideOther()
            }
        }

        Image {
            anchors.fill: parent
            fillMode: Image.Tile
            visible: settings.showTransparencyMarkerBackground
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

    function returnImageContainer() {
        return imageContainer
    }

    /***************************************************************/
    /***************************************************************/
    // Some system functions

    // hide this element. Currently only transition available is fading out
    function hideMe() {
        image.opacity = 0
    }

    // Reset position to center image on screen, animated.
    function resetPosition() {
        posXAni.duration = positionDuration
        posYAni.duration = positionDuration
        x = Qt.binding(function() { return ( defaultWidth - width ) / 2 + imageMargin/2 })
        y = Qt.binding(function() { return ( defaultHeight - height ) / 2 + imageMargin/2 })
    }

    // Reset position to center image on screen, not animated.
    function resetPositionWithoutAnimation() {
        posXAni.duration = 0
        posYAni.duration = 0
        x = Qt.binding(function() { return ( defaultWidth - width ) / 2 + imageMargin/2 })
        y = Qt.binding(function() { return ( defaultHeight - height ) / 2 + imageMargin/2 })
    }


    /***************************************************************/
    /***************************************************************/
    // API functions for manipulating display of images

    function zoomIn() {
        scaleAni.duration = scaleDuration
        imageContainer.scaleMultiplier *= 1.1
    }

    function zoomOut() {
        scaleAni.duration = scaleDuration
        imageContainer.scaleMultiplier /= 1.1
    }

    function zoomActual() {
        if(image.sourceSize.width < defaultWidth && image.sourceSize.height < defaultHeight)
            return
        scaleAni.duration = scaleDuration
        scaleMultiplier = 1/Math.min( defaultWidth / image.sourceSize.width, defaultHeight / image.sourceSize.height)
    }

    function resetZoom() {
        scaleAni.duration = scaleDuration
        if((imageContainer.rotation%180 +180)%180 == 90)
            scaleMultiplier = image.sourceSize.height/image.sourceSize.width
        else
            scaleMultiplier = 1
    }
    function resetZoomWithoutAnimation() {
        scaleAni.duration = 0
        if((imageContainer.rotation%180 +180)%180 == 90)
            scaleMultiplier = image.sourceSize.height/image.sourceSize.width
        else
            scaleMultiplier = 1
    }

    function rotateImage(angle) {
        rotationAni.duration = rotationDuration
        if(rotationAni.running)
            imageContainer.rotation = rotationAni.to+angle
        else
            imageContainer.rotation += angle
    }

    function resetRotation() {

        rotationAni.duration = rotationDuration

        var angle = (imageContainer.rotation%360 +360)%360

        if(angle <= 180)
            imageContainer.rotation -= angle
        else
            imageContainer.rotation += (360-angle)

    }

    function resetRotationWithoutAnimation() {

        rotationAni.duration = 0

        var angle = (imageContainer.rotation%360 +360)%360

        if(angle <= 180)
            imageContainer.rotation -= angle
        else
            imageContainer.rotation += (360-angle)

    }

    function mirrorHorizontal() {
        image.mirror = !image.mirror
    }

    function mirrorVertical() {
        rotationAni.duration = 0
        imageContainer.rotation += 180
        image.mirror = !image.mirror
    }

    function resetMirror() {
        resetRotationWithoutAnimation()
        image.mirror = false
    }

    function getCurrentSourceSize() {
        return image.sourceSize
    }

}
