import QtQuick 2.6

Rectangle {

    id: top

    color: "transparent"
    anchors.fill: parent

    property real defaultWidth: width-10
    property real defaultHeight: height-10
    property var currentFrame: undefined
    property bool fitImageInWindow: false
    property int transitionDuration: 200

    property var currentId: undefined
    property string filename: ""
    onFilenameChanged: {
        if(currentId == image1) {
            image2.source = ""
            image2.source = filename
        } else {
            image1.source = ""
            image1.source = filename
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

    function resetPosition() {
        image1.resetPosition()
        image2.resetPosition()
    }

}
