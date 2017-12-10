import QtQuick 2.6

Rectangle {

    id: imageContainer

    width: image.width
    height: image.height

    color: "transparent"

    scale: (fitImageInWindow || (image.sourceSize.width > parent.width && image.sourceSize.height > parent.height))
           ? Math.min( defaultWidth / image.sourceSize.width, defaultHeight / image.sourceSize.height )
           : 1

    function resetScale() {
        scale = (fitImageInWindow || (image.sourceSize.width > parent.width && image.sourceSize.height > parent.height))
                ? Math.min( defaultWidth / image.sourceSize.width, defaultHeight / image.sourceSize.height )
                : 1
    }

    function hideMe() {
        image.opacity = 0
    }

    function resetPosition() {
        posXAni.duration = positionDuration
        posYAni.duration = positionDuration
        x = ( parent.width - width ) / 2
        y = ( parent.height - height ) / 2
    }

    property int positionDuration: 200
    property int transitionDuration: 200

    x: ( parent.width - width ) / 2
    y: ( parent.height - height ) / 2

    Behavior on x { NumberAnimation { id: posXAni; duration: 0; onStopped: duration = 0 } }
    Behavior on y { NumberAnimation { id: posYAni; duration: 0; onStopped: duration = 0 } }

    rotation: 0

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
        onStatusChanged: {
            if(status == Image.Ready) {
                setAsCurrentId()
                opacity = 1
                resetScale()
                hideOther()
            }
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
                imageContainer.scale = Math.min(top.width, top.height) / Math.max(image.sourceSize.width, image.sourceSize.height) * 0.85
                imageContainer.x = flick.contentX + (flick.width - imageContainer.width) / 2
                imageContainer.y = flick.contentY + (flick.height - imageContainer.height) / 2
            } else {
                imageContainer.rotation = pinch.previousAngle
                imageContainer.scale = pinch.previousScale
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
                    var scaleBefore = imageContainer.scale;
                    imageContainer.scale += imageContainer.scale * wheel.angleDelta.y / 120 / 10;
                }
            }
        }
    }
}
