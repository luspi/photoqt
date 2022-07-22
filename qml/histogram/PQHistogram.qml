/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
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

Item {

    id: hist_top

    x: PQSettings.interfacePopoutHistogram ? 0 : PQSettings.histogramPosition.x
    y: PQSettings.interfacePopoutHistogram ? 0 : PQSettings.histogramPosition.y
    width: PQSettings.interfacePopoutHistogram ? parentWidth : PQSettings.histogramSize.width
    height: PQSettings.interfacePopoutHistogram ? parentHeight : PQSettings.histogramSize.height

    property int parentWidth: 0
    property int parentHeight: 0

    // at startup toplevel width/height is zero causing the x/y of the histogram to be set to 0
    property bool startupDelay: true

    onXChanged:
        saveGeometryTimer.restart()
    onYChanged:
        saveGeometryTimer.restart()
    onWidthChanged:
        saveGeometryTimer.restart()
    onHeightChanged:
        saveGeometryTimer.restart()

    opacity: PQSettings.interfacePopoutHistogram ?
                 1 : (PQSettings.histogramVisible ?
                     ((dragArea.containsMouse||closemouse.containsMouse) ?
                          (dragArea.buttonPressed ? 1 : 0.9) :
                          0.8) :
                     0)
    Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }
    visible: opacity!=0
    onVisibleChanged:
        updateHistogram()

    Component.onCompleted:
        if(filefoldermodel.current != -1)
            updateHistogram()

    Timer {
        // at startup toplevel width/height is zero causing the x/y of the histogram to be set to 0
        running: true
        repeat: false
        interval: 250
        onTriggered:
            startupDelay = false
    }

    Timer {
        id: saveGeometryTimer
        interval: 500
        repeat: false
        running: false
        onTriggered: {
            if(!PQSettings.interfacePopoutHistogram && !startupDelay) {
                PQSettings.histogramPosition = Qt.point(Math.max(0, Math.min(hist_top.x, toplevel.width-hist_top.width)), Math.max(0, Math.min(hist_top.y, toplevel.height-hist_top.height)))
                PQSettings.histogramSize = Qt.size(hist_top.width, hist_top.height)
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#dd2f2f2f"
        radius: 5
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
        target: filefoldermodel
        onCurrentFilePathChanged:
            hist_timer.restart()
    }

    Timer {
        id: hist_timer
        repeat: false
        running: false
        interval: 500
        onTriggered: updateHistogram()
    }

    Rectangle {

        opacity: ((imghist.status==Image.Ready || filefoldermodel.current==-1) ? 0 : 1) || filefoldermodel.current==-1
        Behavior on opacity { NumberAnimation { duration: 150 } }
        visible: opacity!=0

        width: childrenRect.width+50
        height: childrenRect.height+30
        x: (parent.width-width)/2
        y: (parent.height-height)/2
        radius: 5
        color: "#dd2f2f2f"

        Text {
            x: 25
            y: 15
            text: filefoldermodel.current==-1 ?
                      em.pty+qsTranslate("histogram", "Histogram") :
                      //: As in: Loading the histogram for the current image
                      em.pty+qsTranslate("histogram", "Loading...")
            color: "white"
            font.pixelSize: 15
            font.bold: true
        }

    }

    PinchArea {

        anchors.fill: parent

        pinch.target: PQSettings.interfacePopoutHistogram ? undefined : hist_top
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
            tooltip: (PQSettings.interfacePopoutHistogram ? "" : (em.pty+qsTranslate("histogram", "Click-and-drag to move.")+" ")) + em.pty+qsTranslate("histogram", "Right click to switch version.")
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            anchors.fill: parent
            drag.target: PQSettings.interfacePopoutHistogram ? undefined : hist_top
            drag.minimumX: 0
            drag.minimumY: 0
            drag.maximumX: toplevel.width-hist_top.width
            drag.maximumY: toplevel.height-hist_top.height

            onPressed:
                if(mouse.button == Qt.RightButton)
                    PQSettings.histogramVersion = (PQSettings.histogramVersion !== "grey" ? "grey" : "color")

        }
    }

    Image {

        id: histclose

        x: parent.width-width+5
        y: -5
        width: 25
        height: 25

        visible: !PQSettings.interfacePopoutHistogram

        source: "/other/close.png"
        mipmap: true

        opacity: closemouse.containsMouse ? 0.8 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }

        PQMouseArea {
            id: closemouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked:
                PQSettings.histogramVisible = !PQSettings.histogramVisible
        }

    }

    PQMouseArea {

        id: resizeBotRight

        enabled: !PQSettings.interfacePopoutHistogram

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

        enabled: !PQSettings.interfacePopoutHistogram

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
        x: (PQSettings.interfacePopoutHistogram ? 5 : 0)
        y: PQSettings.interfacePopoutHistogram ? 5 : 0
        width: 15
        height: 15
        source: "/popin.png"
        opacity: popinmouse.containsMouse ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        PQMouseArea {
            id: popinmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            tooltip: PQSettings.interfacePopoutHistogram ?
                         //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                         em.pty+qsTranslate("popinpopout", "Merge into main interface") :
                         //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                         em.pty+qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                if(PQSettings.interfacePopoutHistogram)
                    histogram_window.storeGeometry()
                PQSettings.interfacePopoutHistogram = !PQSettings.interfacePopoutHistogram
                HandleShortcuts.executeInternalFunction("__histogram")
            }
        }
    }

    // this makes sure that a change in the window geometry does not leeds to the element being outside the visible area
    Connections {
        target: toplevel
        onWidthChanged: {
            if(hist_top.x < 0)
                hist_top.x = 0
            else if(hist_top.x > toplevel.width-hist_top.width)
                hist_top.x = toplevel.width-hist_top.width
        }
        onHeightChanged: {
            if(hist_top.y < 0)
                hist_top.y = 0
            else if(hist_top.y > toplevel.height-hist_top.height)
                hist_top.y = toplevel.height-hist_top.height
        }
    }

    function updateHistogram() {

        // Don't calculate histogram if disabled
        if(!PQSettings.histogramVisible || filefoldermodel.current == -1) return;

        // we do not want to bind to the currentFilePath below, as we want to preserve a short timeout when that property changes
        var fp = filefoldermodel.currentFilePath

        imghist.source = Qt.binding(function() { return "image://hist/" + (PQSettings.histogramVersion == "color" ? "color" : "grey") + fp; })

    }

}
