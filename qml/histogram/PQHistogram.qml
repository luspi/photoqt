/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

import QtQuick 2.9

import "../elements"

Rectangle {

    id: hist_top

    x: PQSettings.histogramPopoutElement ? 0 : PQSettings.histogramPosition.x
    y: PQSettings.histogramPopoutElement ? 0 : PQSettings.histogramPosition.y
    width: PQSettings.histogramPopoutElement ? parentWidth : PQSettings.histogramSize.width
    height: PQSettings.histogramPopoutElement ? parentHeight : PQSettings.histogramSize.height

    property int parentWidth: 0
    property int parentHeight: 0

    // at startup toplevel width/height is zero causing the x/y of the histogram to be set to 0
    property bool startupDelay: true

    onXChanged:
        if(!PQSettings.histogramPopoutElement && !startupDelay)
            PQSettings.histogramPosition = Qt.point(Math.max(0, Math.min(x, toplevel.width-width)), Math.max(0, Math.min(y, toplevel.height-height)))
    onYChanged:
        if(!PQSettings.histogramPopoutElement && !startupDelay)
            PQSettings.histogramPosition = Qt.point(Math.max(0, Math.min(x, toplevel.width-width)), Math.max(0, Math.min(y, toplevel.height-height)))
    onWidthChanged:
        if(!PQSettings.histogramPopoutElement && !startupDelay)
            PQSettings.histogramSize = Qt.size(width, height)
    onHeightChanged:
        if(!PQSettings.histogramPopoutElement && !startupDelay)
            PQSettings.histogramSize = Qt.size(width, height)

    radius: 5

    opacity: PQSettings.histogramPopoutElement ?
                 1 : (PQSettings.histogram==1 ?
                     ((dragArea.containsMouse||switchmouse.containsMouse||closemouse.containsMouse) ?
                          (dragArea.buttonPressed ? 1 : 0.9) :
                          0.8) :
                     0)
    Behavior on opacity { NumberAnimation { duration: PQSettings.animationDuration*100 } }
    visible: opacity!=0

    color: "#dd000000"

    Component.onCompleted:
        if(variables.indexOfCurrentImage != -1)
            updateHistogram()

    Timer {
        // at startup toplevel width/height is zero causing the x/y of the histogram to be set to 0
        running: true
        repeat: false
        interval: 1000
        onTriggered:
            startupDelay = false
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
        onHistogramChanged:
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
                      em.pty+qsTranslate("histogram", "Histogram")+"..." :
                      //: As in: Loading the histogram for the current image
                      em.pty+qsTranslate("histogram", "Loading...")
            color: "white"
            font.pixelSize: 15
            font.bold: true
        }

    }

    PinchArea {

        anchors.fill: parent

        pinch.target: PQSettings.histogramPopoutElement ? undefined : hist_top
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
            tooltip: (PQSettings.histogramPopoutElement ? "" : (em.pty+qsTranslate("histogram", "Click-and-drag to move.")+" ")) + em.pty+qsTranslate("histogram", "Right click to switch version.")
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            anchors.fill: parent
            drag.target: PQSettings.histogramPopoutElement ? undefined : hist_top

            onPressed:
                if(mouse.button == Qt.RightButton)
                    PQSettings.histogramVersion = (PQSettings.histogramVersion !== "grey" ? "grey" : "color")

        }
    }

    Image {

        id: histswitch

        source: "/other/histogramswitch.png"

        x: PQSettings.histogramPopoutElement ? 5 : -5
        y: PQSettings.histogramPopoutElement ? 5 : -5
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

        id: histclose

        x: parent.width-width+5
        y: -5
        width: 25
        height: 25

        visible: !PQSettings.histogramPopoutElement

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

        enabled: !PQSettings.histogramPopoutElement

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

        enabled: !PQSettings.histogramPopoutElement

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

    Image {
        x: (PQSettings.histogramPopoutElement ? 5 : histswitch.width)
        y: PQSettings.histogramPopoutElement ? 5 : -5
        width: 15
        height: 15
        source: "/popin.png"
        opacity: popinmouse.containsMouse ? 1 : 0.2
        Behavior on opacity { NumberAnimation { duration: 200 } }
        PQMouseArea {
            id: popinmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            tooltip: PQSettings.aboutPopoutElement ?
                         //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                         em.pty+qsTranslate("popinpopout", "Merge into main interface") :
                         //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                         em.pty+qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                if(PQSettings.histogramPopoutElement)
                    histogram_window.storeGeometry()
                PQSettings.histogramPopoutElement = (PQSettings.histogramPopoutElement+1)%2
                HandleShortcuts.executeInternalFunction("__histogram")
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
