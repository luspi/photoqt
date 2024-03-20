/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

import QtQuick
import QtCharts

import PQCFileFolderModel
import PQCScriptsImages
import PQCWindowGeometry

import "../elements"

PQTemplateFloating {

    id: histogram_top

    onXChanged: {
        if(!toplevel.startup && dragActive)
            storeSize.restart()
    }
    onYChanged: {
        if(!toplevel.startup && dragActive)
            storeSize.restart()
    }
    onWidthChanged: {
        if(!toplevel.startup && resizeActive)
            storeSize.restart()
    }
    onHeightChanged: {
        if(!toplevel.startup && resizeActive)
            storeSize.restart()
    }

    Timer {
        id: storeSize
        interval: 200
        onTriggered: {
            PQCSettings.histogramPosition.x = histogram_top.x
            PQCSettings.histogramPosition.y = histogram_top.y
            PQCSettings.histogramSize.width = histogram_top.width
            PQCSettings.histogramSize.height = histogram_top.height
        }
    }

    states: [
        State {
            name: "popout"
            PropertyChanges {
                target: histogram_top
                x: 0
                y: 0
                width: histogram_top.parentWidth
                height: histogram_top.parentHeight
            }
        }

    ]

    PQMultiEffect {

        parent: histogram_top.parent

        anchors.fill: histogram_top
        opacity: histogram_top.opacity

        source: histogram_top
        shadowEnabled: true

    }

    popout: PQCSettings.interfacePopoutHistogram
    forcePopout: PQCWindowGeometry.histogramForcePopout
    shortcut: "__histogram"
    tooltip: (popout||forcePopout ? "" : (qsTranslate("histogram", "Click-and-drag to move.")+" ")) + qsTranslate("histogram", "Right click to switch version.")
    blur_thisis: "histogram"

    onPopoutChanged: {
        if(popout !== PQCSettings.interfacePopoutHistogram)
            PQCSettings.interfacePopoutHistogram = popout
    }

    content: [

        ChartView {
            id: chart

            anchors.fill: parent

            antialiasing: true
            legend.visible: false

            margins.left: 0
            margins.right: 0
            margins.top: 0
            margins.bottom: 0

            backgroundColor: "transparent"

            ValuesAxis {
                id: noaxisX
                labelsVisible: false
                gridVisible: true
                gridLineColor: "#33ffffff"
                color: "#66ffffff"
                min: 0
                max: 255
            }
            ValuesAxis {
                id: noaxisY
                labelsVisible: false
                gridVisible: true
                gridLineColor: "#33ffffff"
                color: "#66ffffff"
                min: 0
                max: 1.01
            }

            AreaSeries {
                id: histogramred_cont
                axisX: noaxisX
                axisY: noaxisY
                color: "#88ff0000"
                borderWidth: 1
                borderColor: "#ff0000"
                visible: PQCSettings.histogramVersion==="color"
                upperSeries: LineSeries {
                    id: histogramred
                }
            }

            AreaSeries {
                id: histogramgreen_cont
                axisX: noaxisX
                axisY: noaxisY
                color: "#8800ff00"
                borderWidth: 1
                borderColor: "#00ff00"
                visible: PQCSettings.histogramVersion==="color"
                upperSeries: LineSeries {
                    id: histogramgreen
                }
            }

            AreaSeries {
                id: histogramblue_cont
                axisX: noaxisX
                axisY: noaxisY
                color: "#880000ff"
                borderWidth: 1
                borderColor: "#0000ff"
                visible: PQCSettings.histogramVersion==="color"
                upperSeries: LineSeries {
                    id: histogramblue
                }
            }

            AreaSeries {
                id: histogramgrey_cont
                axisX: noaxisX
                axisY: noaxisY
                color: "#88cccccc"
                borderWidth: 1
                borderColor: "#cccccc"
                visible: PQCSettings.histogramVersion==="grey"
                upperSeries: LineSeries {
                    id: histogramgrey
                }
            }



            Rectangle {
                id: busy
                radius: histogram_top.radius
                anchors.fill: parent
                color: PQCLook.transColor
                opacity: 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
                visible: opacity>0
                PQText {
                    anchors.centerIn: parent
                    text: qsTranslate("histogram", "Loading...")
                }
            }

            Rectangle {
                id: failed
                radius: histogram_top.radius
                anchors.fill: parent
                color: PQCLook.transColor
                opacity: 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
                visible: opacity>0
                PQText {
                    anchors.centerIn: parent
                    text: qsTranslate("histogram", "Error loading histogram")
                }
            }

            Rectangle {
                id: nofileloaded
                radius: histogram_top.radius
                anchors.fill: parent
                color: PQCLook.transColor
                opacity: PQCFileFolderModel.countMainView===0 ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
                visible: opacity>0
                PQText {
                    anchors.centerIn: parent
                    text: qsTranslate("histogram", "Histogram")
                }
            }

        }

    ]

    Component.onCompleted: {
        if(popout || forcePopout) {
            histogram_top.state = "popout"
        } else {
            histogram_top.state = ""
            x = PQCSettings.histogramPosition.x
            y = PQCSettings.histogramPosition.y
            width = PQCSettings.histogramSize.width
            height = PQCSettings.histogramSize.height
        }

        if(PQCSettings.histogramVisible)
            show()
    }

    onRightClicked: (mouse) => {
        PQCSettings.histogramVersion = (PQCSettings.histogramVersion==="color" ? "grey" : "color")
    }

    Timer {
        id: updateHistogram
        interval: 500
        repeat: false
        property int indexTriggered
        onTriggered: {
            if(PQCFileFolderModel.currentIndex === indexTriggered)
                PQCScriptsImages.loadHistogramData(PQCFileFolderModel.currentFile, PQCFileFolderModel.currentIndex)
        }
    }

    Connections {
        target: loader

        function onPassOn(what, param) {

            if(what === "show") {
                if(param === "histogram") {
                    if(histogram_top.visible) {
                        histogram_top.hide()
                    } else {
                        histogram_top.show()
                        if(PQCFileFolderModel.countMainView === 0) {
                            nofileloaded.opacity = 1
                            busy.opacity = 0
                            failed.opacity = 0
                        } else {
                            updateHistogram.indexTriggered = PQCFileFolderModel.currentIndex
                            updateHistogram.restart()
                            failed.opacity = 0
                            nofileloaded.opacity = 0
                            busy.opacity = 1
                        }
                    }
                }
            }

        }

    }

    Connections {

        target: image

        function onImageFinishedLoading(index) {
            updateHistogram.indexTriggered = index
            updateHistogram.restart()
            failed.opacity = 0
            nofileloaded.opacity = 0
            busy.opacity = 1
        }

    }

    Connections {

        target: PQCScriptsImages

        function onHistogramDataLoadedFailed(index) {
            if(index === PQCFileFolderModel.currentIndex) {

                console.warn("FAILED")

                histogramred.clear()
                histogramgreen.clear()
                histogramblue.clear()
                histogramgrey.clear()
                busy.opacity = 0
                nofileloaded.opacity = 0
                failed.opacity = 1

            }
        }

        function onHistogramDataLoaded(data, index) {

            if(index !== PQCFileFolderModel.currentIndex)
                return

            nofileloaded.opacity = 0

            if(data.length === 0) {
                failed.opacity = 1
                return
            }

            failed.opacity = 0

            var red = data[0]
            var green = data[1]
            var blue = data[2]
            var grey = data[3]

            // RED COLOR

            histogramred.clear()
            for(var r = 0; r < 256; ++r)
                histogramred.append(r, red[r])

            // GREEN COLOR

            histogramgreen.clear()
            for(var g = 0; g < 256; ++g)
                histogramgreen.append(g, green[g])

            // BLUE COLOR

            histogramblue.clear()
            for(var b = 0; b < 256; ++b)
                histogramblue.append(b, blue[b])

            // GREY SCALE

            histogramgrey.clear()
            for(var k = 0; k < 256; ++k)
                histogramgrey.append(k, grey[k])

            busy.opacity = 0

        }

    }

    Connections {

        target: PQCSettings

        function onHistogramVisibleChanged() {
            if(PQCSettings.histogramVisible)
                show()
            else
                hide()
        }

    }

    function show() {
        opacity = 1
        PQCSettings.histogramVisible = true
        if(popout)
            histogram_popout.show()
    }

    function hide() {
        opacity = 0
        PQCSettings.histogramVisible = false
    }

}
