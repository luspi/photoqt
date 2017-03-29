import QtQuick 2.4

import "../elements"

Rectangle {

    id: rect_top

    x: settings.histogramPosition.x
    y: settings.histogramPosition.y
    width: settings.histogramSize.width
    height: settings.histogramSize.height

    color: "transparent"

    opacity: settings.histogram ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 200; } }

    onOpacityChanged: {
        if(opacity == 0)
            visible = false
        else
            visible = true
        if(opacity == 1) updateHistogram()
    }
    property string settingsHistogramVersion: settings.histogramVersion
    onSettingsHistogramVersionChanged: updateHistogram()


    // half transparent black background
    Rectangle {

        id: bg_rect

        color: "black"
        opacity: 0.3
        radius: 10
        Behavior on opacity { NumberAnimation { duration: 200 } }
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
        sourceSize.width: parent.width
        sourceSize.height: parent.height
        source: ""

    }

    Connections {
        target: thumbnailBar
        onCurrentFileChanged:
            hist_timer.restart()
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
        if(!settings.histogram || thumbnailBar.currentFile == "") return;

        verboseMessage("Histogram::updateHistogram()",settings.histogramVersion)

        if(settings.histogramVersion === "color")
            imghist.source = "image://hist/color" + thumbnailBar.currentFile
        else if(settings.histogramVersion === "grey")
            imghist.source = "image://hist/grey" + thumbnailBar.currentFile

    }

    // a simple text label identifying this element as the histogram as long as no image is loaded
    Rectangle {

        id: infolabel

        opacity: 0.5
        Behavior on opacity { NumberAnimation { duration: 200 } }

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
                text: qsTr("Histogram")
                color: "white"
                font.pixelSize: 18
                font.bold: true
            }

        }

    }

    // move histogram around
    ToolTip {

        text: qsTr("Click-and-drag to move. Right click to switch version.")

        property bool resizing: false
        property int startMouseX: 0
        property int startMouseY: 0

        property int startX: 0
        property int startY: 0

        acceptedButtons: Qt.LeftButton | Qt.RightButton

        anchors.fill: parent
        hoverEnabled: true

        onPressed: {
            if(mouse.button == Qt.LeftButton) {
                cursorShape = Qt.SizeAllCursor
                resizing = true
                startX = parent.x
                startY = parent.y
                startMouseX = localcursorpos.x
                startMouseY = localcursorpos.y
                bg_rect.showMove()
            } else {
                if(settings.histogramVersion == "color")
                    settings.histogramVersion = "grey"
                else
                    settings.histogramVersion = "color"
            }

        }

        onEntered: {
            bg_rect.show()
            infolabel.opacity = 1
        }
        onExited: {
            bg_rect.hide()
            infolabel.opacity = 0.5
        }

        onMouseXChanged: if(resizing) parent.x = startX + (localcursorpos.x-startMouseX)

        onMouseYChanged: if(resizing) parent.y = startY + (localcursorpos.y-startMouseY)

        onReleased: {
            settings.histogramPosition = Qt.point(rect_top.x, rect_top.y)
            cursorShape = Qt.ArrowCursor
            resizing = false
            bg_rect.show()
        }

    }

    // resize histogram
    MouseArea {

        property bool resizing: false
        property int startMouseX: 0
        property int startMouseY: 0

        property int startW: 0
        property int startH: 0
        property int startX: 0
        property int startY: 0

        x: parent.width-30
        y: parent.height-30
        width: 30
        height: 30
        hoverEnabled: true
        cursorShape: Qt.SizeFDiagCursor

        onPressed: {
            resizing = true
            startW = parent.width
            startH = parent.height
            startX = parent.x
            startY = parent.y
            startMouseX = localcursorpos.x
            startMouseY = localcursorpos.y
        }

        onMouseXChanged: {
            if(resizing) {
                var newW = startW + (localcursorpos.x-startMouseX);
                if(newW > 200) parent.width = newW
            }
        }

        onMouseYChanged: {
            if(resizing) {
                var newH = startH + (localcursorpos.y-startMouseY)
                if(newH > 150) parent.height = newH
            }
        }

        onReleased: {
            resizing = false
            settings.histogramSize = Qt.size(rect_top.width, rect_top.height)
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
            text: qsTr("Click to switch between coloured and greyscale histogram. You can also switch by doing a right-click onto the histogram.")
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
            onClicked: {
                if(settings.histogramVersion == "color")
                    settings.histogramVersion = "grey"
                else
                    settings.histogramVersion = "color"
            }
        }
        function show() {
            switchVersion.opacity = 0.75
        }
        function hide() {
            switchVersion.opacity = 0.05
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
            text: qsTr("Click to hide histogram. It can always be shown again from the mainmenu.")
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
            closex.opacity = 0.05
        }
        Component.onCompleted: hide()
    }

}
