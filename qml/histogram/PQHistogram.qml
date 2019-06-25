import QtQuick 2.9

import "../elements"

Rectangle {

    id: hist_top

    x: PQSettings.histogramPosition.x
    y: PQSettings.histogramPosition.y
    width: PQSettings.histogramSize.width
    height: PQSettings.histogramSize.height

    onXChanged:
        PQSettings.histogramPosition = Qt.point(x, y)
    onYChanged:
        PQSettings.histogramPosition = Qt.point(x, y)
    onWidthChanged:
        PQSettings.histogramSize = Qt.size(width, height)
    onHeightChanged:
        PQSettings.histogramSize = Qt.size(width, height)

    radius: 5

    opacity: PQSettings.histogram==1 ?
                 ((dragArea.containsMouse||switchmouse.containsMouse||closemouse.containsMouse) ?
                      (dragArea.buttonPressed ? 1 : 0.9) :
                      0.8) :
                 0
    Behavior on opacity { NumberAnimation { duration: 150 } }
    visible: opacity!=0

    color: "#dd000000"

    // This will hold the histogram image
    Image {

        id: imghist

        anchors.fill: parent
        anchors.margins: 10

        fillMode: Image.Stretch

        mipmap: true
        sourceSize.width: 1024
        sourceSize.height: 768
        source: ""

        asynchronous: true

    }

    Connections {
        target: variables
        onIndexOfCurrentImageChanged:
            hist_timer.restart()
    }

    Connections {
        target: PQSettings
        onHistogramVersionChanged:
            updateHistogram()
    }

    Timer {
        id: hist_timer
        repeat: false
        running: false
        interval: 500
        onTriggered: updateHistogram()
    }

    Rectangle {

        opacity: ((imghist.status==Image.Ready || variables.indexOfCurrentImage==-1) ? 0 : 1) || variables.indexOfCurrentImage==-1
        Behavior on opacity { NumberAnimation { duration: 150 } }
        visible: opacity!=0

        width: childrenRect.width+50
        height: childrenRect.height+30
        x: (parent.width-width)/2
        y: (parent.height-height)/2
        radius: 5
        color: "#88000000"

        Text {
            x: 25
            y: 15
            text: variables.indexOfCurrentImage==-1 ?
                      em.pty+qsTr("Histogram...") :
                      //: As in 'Loading the histogram for the current image'
                      em.pty+qsTr("Loading...")
            color: "white"
            font.pixelSize: 15
            font.bold: true
        }

    }

    PinchArea {

        anchors.fill: parent

        pinch.target: hist_top
        pinch.minimumRotation: -360
        pinch.maximumRotation: 360
        pinch.minimumScale: 0.1
        pinch.maximumScale: 10
        pinch.dragAxis: Pinch.XAndYAxis
        onPinchStarted: setFrameColor();

        onSmartZoom: {
            hist_top.x = pinch.previousCenter.x - hist_top.width / 2
            hist_top.y = pinch.previousCenter.y - hist_top.height / 2
        }

        // This mouse area does the same as the pinch area but for the mouse
        PQMouseArea {
            id: dragArea
            hoverEnabled: true
            //: Used for the histogram. The version refers to the type of histogram that is available (colored and greyscale)
            tooltip: em.pty+qsTr("Click-and-drag to move. Right click to switch version.")
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            anchors.fill: parent
            drag.target: hist_top

            onPressed:
                if(mouse.button == Qt.RightButton)
                    PQSettings.histogramVersion = (PQSettings.histogramVersion !== "grey" ? "grey" : "color")

        }
    }

    Image {

        source: "/other/histogramswitch.png"

        x: -5
        y: -5
        width: 25
        height: 25
        mipmap: true

        opacity: switchmouse.containsMouse ? 0.8 : 0.2
        Behavior on opacity { NumberAnimation { duration: 150 } }

        PQMouseArea {
            id: switchmouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked:
                PQSettings.histogramVersion = (PQSettings.histogramVersion !== "grey" ? "grey" : "color")
        }

    }

    Image {

        x: parent.width-width+5
        y: -5
        width: 25
        height: 25

        source: "/other/histogramclose.png"

        opacity: closemouse.containsMouse ? 0.8 : 0.2
        Behavior on opacity { NumberAnimation { duration: 150 } }

        PQMouseArea {
            id: closemouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked:
                PQSettings.histogram = (PQSettings.histogram ? false : true)
        }

    }

    PQMouseArea {

        id: resizeBotRight

        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        width: 10
        height: 10
        cursorShape: Qt.SizeFDiagCursor

        onPositionChanged: {
            if(pressed) {
                hist_top.width += (mouse.x-resizeBotRight.width)
                hist_top.height += (mouse.y-resizeBotRight.height)
                if(hist_top.width < 100)
                    hist_top.width = 100
                if(hist_top.height < 100)
                    hist_top.height = 100

            }
        }

    }

    PQMouseArea {

        id: resizeBotLeft

        anchors {
            left: parent.left
            bottom: parent.bottom
        }
        width: 10
        height: 10
        cursorShape: Qt.SizeBDiagCursor

        onPositionChanged: {

            if(pressed) {

                hist_top.width -= mouse.x
                hist_top.height += (mouse.y-resizeBotRight.height)

                if(hist_top.width < 100)
                    hist_top.width = 100
                else
                    hist_top.x += mouse.x

                if(hist_top.height < 100)
                    hist_top.height = 100

            }

        }

    }

    function updateHistogram() {

        // Don't calculate histogram if disabled
        if(!PQSettings.histogram || variables.indexOfCurrentImage == -1) return;

        if(PQSettings.histogramVersion !== "grey")
            imghist.source = "image://hist/color" + variables.allImageFilesInOrder[variables.indexOfCurrentImage]
        else if(PQSettings.histogramVersion === "grey")
            imghist.source = "image://hist/grey" + variables.allImageFilesInOrder[variables.indexOfCurrentImage]

    }

}
