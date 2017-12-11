import QtQuick 2.6

Rectangle {

    id: top

    color: "transparent"
    anchors.fill: parent

    property int defaultMargin: 10
    property real defaultWidth: width-defaultMargin
    property real defaultHeight: height-defaultMargin
    property var currentFrame: undefined
    property bool fitImageInWindow: false
    property int transitionDuration: 200

    property var currentId: undefined
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

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: height

        MainImageRectangle {
            id: image1
            onHideOther: image2.hideMe()
            onSetAsCurrentId: currentId = image1
            transitionDuration: top.transitionDuration
        }

        MainImageRectangle {
            id: image2
            onHideOther: image1.hideMe()
            onSetAsCurrentId: currentId = image2
            transitionDuration: top.transitionDuration
        }

    }

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

    function rotateLeft45() {
        if(currentId == image1)
            image1.rotateLeft45()
        else if(currentId == image2)
            image2.rotateLeft45()
    }
    function rotateLeft90() {
        if(currentId == image1)
            image1.rotateLeft90()
        else if(currentId == image2)
            image2.rotateLeft90()
    }

    function rotateRight45() {
        if(currentId == image1)
            image1.rotateRight45()
        else if(currentId == image2)
            image2.rotateRight45()
    }
    function rotateRight90() {
        if(currentId == image1)
            image1.rotateRight90()
        else if(currentId == image2)
            image2.rotateRight90()
    }

    function rotate180() {
        if(currentId == image1)
            image1.rotate180()
        else if(currentId == image2)
            image2.rotate180()
    }

    function resetRotation() {
        if(currentId == image1)
            image1.resetRotation()
        else if(currentId == image2)
            image2.resetRotation()
    }

}
