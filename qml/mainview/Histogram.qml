import QtQuick 2.5

import "../elements"

Rectangle {

    id: rect_top

    x: settings.histogramPosition.x
    y: settings.histogramPosition.y
    width: settings.histogramSize.width
    height: settings.histogramSize.height

    onXChanged:
        settings.histogramPosition = Qt.point(x, y)
    onYChanged:
        settings.histogramPosition = Qt.point(x, y)
    onWidthChanged:
        settings.histogramSize = Qt.size(width, height)
    onHeightChanged:
        settings.histogramSize = Qt.size(width, height)

    color: "transparent"

    visible: (opacity!=0)
    opacity: settings.histogram?1:0
    Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

    onVisibleChanged:
        if(visible) updateHistogram()

    // half transparent black background
    Rectangle {

        id: bg_rect

        color: "black"
        opacity: 0.3
        radius: 10
        Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }
        anchors.fill: parent

        function show() {
            opacity = 0.6
        }
        function showMove() {
            opacity = 0.7
        }
        function hide() {
            opacity = 0.5
        }

    }

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

        onStatusChanged: {
            if(status == Image.Ready)
                loadinglabel.visible = false
            else
                loadinglabel.visible = true
        }

    }

    Connections {
        target: variables
        onCurrentFileChanged:
            hist_timer.restart()
    }

    Connections {
        target: settings
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

    function updateHistogram() {

        // Don't calculate histogram if disabled
        if(!settings.histogram || variables.currentFile == "") return;

        verboseMessage("Histogram::updateHistogram()",settings.histogramVersion)

        if(settings.histogramVersion != "grey")
            imghist.source = "image://hist/color" + variables.currentDir+"/"+variables.currentFile
        else if(settings.histogramVersion == "grey")
            imghist.source = "image://hist/grey" + variables.currentDir+"/"+variables.currentFile

    }

    // a simple text label identifying this element as the histogram as long as no image is loaded
    Rectangle {

        id: infolabel

        opacity: 0.5
        Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

        visible: (imghist.source == "" || imghist.source == "color" || imghist.source == "grey")
        anchors.fill: parent
        color: "transparent"

        Rectangle {

            width: childrenRect.width+50
            height: childrenRect.height+30
            x: (parent.width-width)/2
            y: (parent.height-height)/2
            radius: 10
            color: "#88000000"

            Text {
                x: 25
                y: 15
                //: A histogram visualises the color distribution in an image
                text: em.pty+qsTr("Histogram")
                color: "white"
                font.pixelSize: 18
                font.bold: true
            }

        }

    }

    Rectangle {

        id: loadinglabel

        visible: false
        opacity: 1
        Behavior on opacity { NumberAnimation { duration: variables.animationSpeed } }

        anchors.fill: parent
        color: "transparent"

        Rectangle {

            width: childrenRect.width+50
            height: childrenRect.height+30
            x: (parent.width-width)/2
            y: (parent.height-height)/2
            radius: 10
            color: "#88000000"

            Text {
                x: 25
                y: 15
                //: As in 'Loading the histogram for the current image'
                text: em.pty+qsTr("Loading...")
                color: "white"
                font.pixelSize: 18
                font.bold: true
            }

        }

    }

    // move histogram around
    PinchArea {

        anchors.fill: parent

        pinch.target: rect_top
        pinch.minimumRotation: -360
        pinch.maximumRotation: 360
        pinch.minimumScale: 0.1
        pinch.maximumScale: 10
        pinch.dragAxis: Pinch.XAndYAxis
        onPinchStarted: setFrameColor();

        onSmartZoom: {
            rect_top.x = pinch.previousCenter.x - rect_top.width / 2
            rect_top.y = pinch.previousCenter.y - rect_top.height / 2
        }

        // This mouse area does the same as the pinch area but for the mouse
        ToolTip {
            id: dragArea
            hoverEnabled: true
            text: em.pty+qsTr("Click-and-drag to move. Right click to switch version.")
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            anchors.fill: parent
            drag.target: rect_top

            onPressed: {
                if(mouse.button == Qt.LeftButton)
                    bg_rect.showMove()
                else
                    settings.histogramVersion = (settings.histogramVersion != "grey" ? "grey" : "color")

            }

            onEntered: {
                bg_rect.show()
                infolabel.opacity = 1
            }
            onExited: {
                bg_rect.hide()
                infolabel.opacity = 0.5
            }

            onReleased: {
                cursorShape = Qt.ArrowCursor
                bg_rect.show()
            }
        }
    }

    // resize histogram (bottom right corner)
    MouseArea {

        x: parent.width-10
        y: parent.height-10
        width: 10
        height: 10
        hoverEnabled: true
        cursorShape: Qt.SizeFDiagCursor

        property bool resizing: false

        onPressed: resizing = true
        onReleased: resizing = false

        onMouseXChanged: {
            if(resizing){
                rect_top.width += (mouseX-width)
                if(rect_top.width < 50)
                    rect_top.width = 50
            }
        }

        onMouseYChanged: {
            if(resizing){
                rect_top.height += (mouseY-height)
                if(rect_top.height < 50)
                    rect_top.height = 50
            }
        }
    }

    // resize histogram (bottom left corner)
    MouseArea {

        x: 0
        y: parent.height-10
        width: 10
        height: 10
        hoverEnabled: true
        cursorShape: Qt.SizeBDiagCursor

        property bool resizing: false

        onPressed: resizing = true
        onReleased: resizing = false

        onMouseXChanged: {
            if(resizing){
                rect_top.width -= mouseX
                if(rect_top.width < 50)
                    rect_top.width = 50
                else
                    rect_top.x += mouseX
            }
        }

        onMouseYChanged: {
            if(resizing){
                rect_top.height += (mouseY-height)
                if(rect_top.height < 50)
                    rect_top.height = 50
            }
        }
    }


    Rectangle {
        id: switchVersion
        color: "transparent"
        x: -5
        y: -5
        width: 25
        height: 25
        Behavior on opacity { NumberAnimation { duration:200; } }
        Image {
            anchors.fill: parent
            source: "qrc:/img/switchHistogramVersion.png"
            sourceSize.width: parent.width
            sourceSize.height: parent.height
        }
        ToolTip {
            text: em.pty+qsTr("Click to switch between coloured and greyscale histogram. You can also switch by doing a right-click onto the histogram.")
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: {
                bg_rect.show()
                parent.show()
            }
            onExited: {
                bg_rect.hide()
                parent.hide()
            }
            onClicked:
                settings.histogramVersion = (settings.histogramVersion != "grey" ? "grey" : "color")
        }
        function show() {
            switchVersion.opacity = 0.75
        }
        function hide() {
            switchVersion.opacity = 0.1
        }
        Component.onCompleted: hide()
    }

    // 'x' to hide histogram
    Rectangle {
        id: closex
        color: "transparent"
        x: parent.width-20
        y: -15
        width: 30
        height: 30
        Behavior on opacity { NumberAnimation { duration:200; } }
        Text {
            anchors.fill: parent
            color: "red"
            text: "x"
            font.bold: true
            font.pixelSize: 25
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        ToolTip {
            text: em.pty+qsTr("Click to hide histogram. It can always be shown again from the main menu.")
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: {
                bg_rect.show()
                parent.show()
            }
            onExited: {
                bg_rect.hide()
                parent.hide()
            }
            onClicked: settings.histogram = false
        }
        function show() {
            closex.opacity = 0.75
        }
        function hide() {
            closex.opacity = 0.1
        }
        Component.onCompleted: hide()
    }

}
