import QtQuick 2.6

Item {

    id: top
    anchors.fill: parent
    property real surfaceViewportRatio: 1
    property real defaultSize: 200
    property real defaultWidth: mainwindow.width-10
    property real defaultHeight: mainwindow.height-10
    property var currentFrame: undefined

    property int transitionTime: 300
    property int newloadAdjustTime: 0
    property int zoomTime: 200

    property string filename: "file:///home/luspi/Multimedia/Bilder/2017/June/18.06.-24.06. - Hiking along Superior Hiking Trail, Lake Superior, MN/P1100953.JPG"

    Flickable {

        id: flick

        anchors.fill: parent

        contentWidth: width * surfaceViewportRatio
        contentHeight: height * surfaceViewportRatio




        property var currentId: undefined
        onCurrentIdChanged: {
            if(currentId == image1) {
                width = image1.width
                height = image1.height
            } else if(currentId == image2) {
                width = image2.width
                height = image2.height
            }
        }

        property string source: filename
        onSourceChanged: {
            image1.completeAni()
            image2.completeAni()
            if(currentId == image1) {
                console.log("setting source to 2")
                image2.source = ""
                image2.source = source
            } else {
                console.log("setting source to 1")
                image1.source = ""
                image1.source = source
            }
        }



        ImageItemRectangle {
            id: image1
            onSetAsCurrentId: flick.currentId = image1
            onHideOther: image2.hideMe()
        }

        ImageItemRectangle {
            id: image2
            onSetAsCurrentId: flick.currentId = image2
            onHideOther: image1.hideMe()
        }



    }

}
