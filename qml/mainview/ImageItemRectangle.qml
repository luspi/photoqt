import QtQuick 2.6

Rectangle {

    id: rectImage

    color: "transparent"

    signal setAsCurrentId()
    signal hideOther()

    width: image.width
    height: image.height
    x: (top.width-image.sourceSize.width)/2
    y: (top.height-image.sourceSize.height)/2

    onWidthChanged:
        console.log(x,y, '-', width,height, '-', image.sourceSize.width, image.sourceSize.height, '-', defaultWidth, defaultHeight, '-', scale)

    rotation: 0

    scale: Math.min(defaultWidth / image.sourceSize.width, defaultHeight / image.sourceSize.height)

    Behavior on scale { NumberAnimation { duration: zoomTime } }
    Behavior on x { NumberAnimation { duration: newloadAdjustTime } }
    Behavior on y { NumberAnimation { duration: newloadAdjustTime } }

    border.color: "black"
    border.width: 2

    smooth: true
    antialiasing: true

    property string source: ""

    Rectangle {

        color: "transparent"
        width: image.width
        height: image.height

        Image {
            id: image
            visible: opacity!=0
            opacity: 0
            Behavior on opacity { NumberAnimation { id: imageani; duration: transitionTime } }
            anchors.centerIn: parent
            source: rectImage.source
            cache: false
            fillMode: Image.PreserveAspectFit
            antialiasing: true
            onStatusChanged: {
                if(status == Image.Ready) {
                    setAsCurrentId()
//                    rectImage.resetScale()
                    opacity = 1
                    hideOther()
                }
            }
        }

    }


    PinchArea {
        anchors.fill: parent
        pinch.target: rectImage
        pinch.minimumRotation: -360
        pinch.maximumRotation: 360
        pinch.minimumScale: 0.1
        pinch.maximumScale: 10
        pinch.dragAxis: Pinch.XAndYAxis
        property real zRestore: 0
        onSmartZoom: {
            if (pinch.scale > 0) {
                rectImage.rotation = 0;
                rectImage.scale = Math.min(top.width, top.height) / Math.max(image.sourceSize.width, image.sourceSize.height) * 0.85
                rectImage.x = flick.contentX + (flick.width - rectImage.width) / 2
                rectImage.y = flick.contentY + (flick.height - rectImage.height) / 2
                zRestore = rectImage.z
            } else {
                rectImage.rotation = pinch.previousAngle
                rectImage.scale = pinch.previousScale
                rectImage.x = pinch.previousCenter.x - rectImage.width / 2
                rectImage.y = pinch.previousCenter.y - rectImage.height / 2
                rectImage.z = zRestore
            }
        }

        MouseArea {
            hoverEnabled: true
            anchors.fill: parent
            drag.target: rectImage
            scrollGestureEnabled: false  // 2-finger-flick gesture should pass through to the Flickable
            onWheel: {
                if (wheel.modifiers & Qt.ControlModifier) {
                    rectImage.rotation += wheel.angleDelta.y / 120 * 5;
                    if (Math.abs(rectImage.rotation) < 4)
                        rectImage.rotation = 0;
                } else {
                    rectImage.rotation += wheel.angleDelta.x / 120;
                    if (Math.abs(rectImage.rotation) < 0.6)
                        rectImage.rotation = 0;
                    var scaleBefore = rectImage.scale;
                    rectImage.scale += rectImage.scale * wheel.angleDelta.y / 120 / 10;
                }
            }
        }
    }

    function completeAni() {
        imageani.complete()
    }
    function hideMe() {
        image.opacity = 0
    }

}
