import QtQuick 2.6

Item {

    id: imageContainer

    width: image.width
    height: image.height

    visible: (image.opacity!=0)

    property real scaleMultiplier: 1
    scale: ((fitImageInWindow || image.sourceSize.width > defaultWidth || image.sourceSize.height > defaultHeight)
            ? scaleMultiplier * Math.min( defaultWidth / image.sourceSize.width,
                                          defaultHeight / image.sourceSize.height )
            : scaleMultiplier)

    Behavior on scale { NumberAnimation { id: scaleAni; duration: scaleDuration; onStopped: duration = scaleDuration } }

    function hideMe() {
        image.opacity = 0
    }

    function resetPosition() {
        posXAni.duration = positionDuration
        posYAni.duration = positionDuration
        x = Qt.binding(function() { return ( defaultWidth - width ) / 2 + defaultMargin/2 })
        y = Qt.binding(function() { return ( defaultHeight - height ) / 2 + defaultMargin/2 })
    }

    function resetPositionWithoutAnimation() {
        posXAni.duration = 0
        posYAni.duration = 0
        x = Qt.binding(function() { return ( defaultWidth - width ) / 2 + defaultMargin/2 })
        y = Qt.binding(function() { return ( defaultHeight - height ) / 2 + defaultMargin/2 })
    }

    property int positionDuration: 200
    property int transitionDuration: 200
    property int scaleDuration: 200
    property int rotationDuration: 200

    x: ( defaultWidth - width ) / 2 + defaultMargin/2
    y: ( defaultHeight - height ) / 2 + defaultMargin/2

    Behavior on x { NumberAnimation { id: posXAni; duration: 0; onStopped: duration = 0 } }
    Behavior on y { NumberAnimation { id: posYAni; duration: 0; onStopped: duration = 0 } }

    rotation: 0
    Behavior on rotation { NumberAnimation { id: rotationAni; duration: 0; onStopped: duration = 0 } }
    onRotationChanged: {
        if(scaleMultiplier > image.sourceSize.height/image.sourceSize.width-0.01 && scaleMultiplier < 1.1
                && Math.abs(x-((defaultWidth-width)/2+defaultMargin/2)) < 10 && Math.abs(y-((defaultHeight-height)/2+defaultMargin/2)) < 10)
            resetZoom()
    }

    smooth: true
    antialiasing: true

    property string source: ""

    signal hideOther()
    signal setAsCurrentId()

    Image {
        id: image
        anchors.centerIn: parent
        visible: (opacity!=0)
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: transitionDuration } }
        fillMode: Image.PreserveAspectFit
        source: imageContainer.source
        antialiasing: true
        smooth: true
        mipmap: true
        onStatusChanged: {
            if(status == Image.Ready) {
                setAsCurrentId()
                resetPositionWithoutAnimation()
                resetZoomWithoutAnimation()
                resetRotationWithoutAnimation()
                imageContainer.rotation = 0
                opacity = 1
                hideOther()
            }
        }
        Image {
            smooth: true
            antialiasing: true
            mipmap: true
            anchors.fill: parent
            visible: scaleMultiplier <= 1 && image.sourceSize.width < defaultWidth && image.sourceSize.height < defaultHeight
            onVisibleChanged: console.log("masking available", visible)
            fillMode: Image.PreserveAspectFit
            source: parent.source
            sourceSize: Qt.size(defaultWidth, defaultHeight)
        }
    }

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

        MouseArea {
            id: dragArea
            hoverEnabled: true
            anchors.fill: parent
            drag.target: imageContainer
            scrollGestureEnabled: false  // 2-finger-flick gesture should pass through to the Flickable
            onWheel: {
                if (wheel.modifiers & Qt.ControlModifier) {
                    imageContainer.rotation += wheel.angleDelta.y / 120 * 5;
                    if (Math.abs(imageContainer.rotation) < 4)
                        imageContainer.rotation = 0;
                } else {
                    imageContainer.rotation += wheel.angleDelta.x / 120;
                    if (Math.abs(imageContainer.rotation) < 0.6)
                        imageContainer.rotation = 0;
                    var scaleBefore = imageContainer.scaleMultiplier;
                    imageContainer.scaleMultiplier += imageContainer.scaleMultiplier * wheel.angleDelta.y / 120 / 10;
                }
            }
        }
    }

    function zoomIn() {
        scaleAni.duration = scaleDuration
        imageContainer.scaleMultiplier *= 1.1
    }

    function zoomOut() {
        scaleAni.duration = scaleDuration
        imageContainer.scaleMultiplier /= 1.1
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
        scaleMultiplier = 1
    }

    function rotateLeft45() {
        rotationAni.duration = rotationDuration
        imageContainer.rotation -= 45
    }
    function rotateLeft90() {
        rotationAni.duration = rotationDuration
        imageContainer.rotation -= 90
    }

    function rotateRight45() {
        rotationAni.duration = rotationDuration
        imageContainer.rotation += 45
    }
    function rotateRight90() {
        rotationAni.duration = rotationDuration
        imageContainer.rotation += 90
    }

    function rotate180() {
        rotationAni.duration = rotationDuration
        imageContainer.rotation += 180
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

}
