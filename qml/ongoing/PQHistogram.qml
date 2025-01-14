pragma ComponentBehavior: Bound
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
import QtQuick.Controls
import QtCharts

import PQCFileFolderModel
import PQCScriptsImages
import PQCWindowGeometry
import PQCNotify

import "../elements"
import "../"

PQTemplateFloating {

    id: histogram_top

    property PQMainWindow access_toplevel: toplevel // qmllint disable unqualified

    onXChanged: {
        if(!access_toplevel.startup && dragActive)
            storeSize.restart()
    }
    onYChanged: {
        if(!access_toplevel.startup && dragActive)
            storeSize.restart()
    }
    onWidthChanged: {
        if(!access_toplevel.startup && resizeActive)
            storeSize.restart()
    }
    onHeightChanged: {
        if(!access_toplevel.startup && resizeActive)
            storeSize.restart()
    }

    Timer {
        id: storeSize
        interval: 200
        onTriggered: {
            PQCSettings.histogramPosition.x = histogram_top.x // qmllint disable unqualified
            PQCSettings.histogramPosition.y = histogram_top.y
            PQCSettings.histogramSize.width = histogram_top.width
            PQCSettings.histogramSize.height = histogram_top.height
        }
    }

    states: [
        State {
            name: "popout"
            PropertyChanges {
                histogram_top.x: 0
                histogram_top.y: 0
                histogram_top.width: histogram_top.parentWidth
                histogram_top.height: histogram_top.parentHeight
            }
        }

    ]

    PQShadowEffect { masterItem: histogram_top }

    popout: PQCSettings.interfacePopoutHistogram // qmllint disable unqualified
    forcePopout: PQCWindowGeometry.histogramForcePopout // qmllint disable unqualified
    shortcut: "__histogram"
    tooltip: qsTranslate("histogram", "Click-and-drag to move.")
    blur_thisis: "histogram"

    onPopoutChanged: {
        if(popout !== PQCSettings.interfacePopoutHistogram) // qmllint disable unqualified
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
                visible: PQCSettings.histogramVersion==="color" // qmllint disable unqualified
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
                visible: PQCSettings.histogramVersion==="color" // qmllint disable unqualified
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
                visible: PQCSettings.histogramVersion==="color" // qmllint disable unqualified
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
                visible: PQCSettings.histogramVersion==="grey" // qmllint disable unqualified
                upperSeries: LineSeries {
                    id: histogramgrey
                }
            }



            Rectangle {
                id: busy
                radius: histogram_top.radius
                anchors.fill: parent
                color: PQCLook.transColor // qmllint disable unqualified
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
                color: PQCLook.transColor // qmllint disable unqualified
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
                color: PQCLook.transColor // qmllint disable unqualified
                opacity: PQCFileFolderModel.countMainView===0 ? 1 : 0 // qmllint disable unqualified
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
            x = PQCSettings.histogramPosition.x // qmllint disable unqualified
            y = PQCSettings.histogramPosition.y
            width = PQCSettings.histogramSize.width
            height = PQCSettings.histogramSize.height
        }

        if(PQCSettings.histogramVisible)
            show()
    }

    onRightClicked: (mouse) => {
        menu.item.popup() // qmllint disable missing-property
    }

    Timer {
        id: updateHistogram
        interval: 500
        repeat: false
        property int indexTriggered
        onTriggered: {
            if(PQCFileFolderModel.currentIndex === indexTriggered) // qmllint disable unqualified
                PQCScriptsImages.loadHistogramData(PQCFileFolderModel.currentFile, PQCFileFolderModel.currentIndex)
        }
    }

    ButtonGroup { id: grp }

    Loader {

        id: menu
        asynchronous: true

        sourceComponent:
        PQMenu {
            id: themenu
            PQMenuItem {
                checkable: true
                text: qsTranslate("histogram", "show histogram")
                checked: PQCSettings.histogramVisible // qmllint disable unqualified
                onCheckedChanged: {
                    PQCSettings.histogramVisible = checked // qmllint disable unqualified
                    if(!checked)
                        themenu.dismiss()
                }
            }
            PQMenuSeparator {}
            PQMenuItem {
                checkable: true
                checkableLikeRadioButton: true
                //: used in context menu for histogram
                text: qsTranslate("histogram", "RGB colors")
                ButtonGroup.group: grp
                checked: PQCSettings.histogramVersion==="color" // qmllint disable unqualified
                onCheckedChanged: {
                    if(checked)
                        PQCSettings.histogramVersion = "color" // qmllint disable unqualified
                }
            }
            PQMenuItem {
                checkable: true
                checkableLikeRadioButton: true
                //: used in context menu for histogram
                text: qsTranslate("histogram", "gray scale")
                ButtonGroup.group: grp
                checked: PQCSettings.histogramVersion==="grey" // qmllint disable unqualified
                onCheckedChanged: {
                    if(checked)
                        PQCSettings.histogramVersion = "grey" // qmllint disable unqualified
                }
            }

            PQMenuSeparator {}

            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/close.svg" // qmllint disable unqualified
                text: qsTranslate("histogram", "Hide histogram")
                onTriggered: {
                    PQCSettings.histogramVisible = false // qmllint disable unqualified
                }
            }

            onAboutToHide:
                recordAsClosed.restart()
            onAboutToShow:
                PQCNotify.addToWhichContextMenusOpen("histogram") // qmllint disable unqualified

            Timer {
                id: recordAsClosed
                interval: 200
                onTriggered: {
                    if(!themenu.visible)
                        PQCNotify.removeFromWhichContextMenusOpen("histogram") // qmllint disable unqualified
                }
            }
        }

    }

    Connections {
        target: loader // qmllint disable unqualified

        function onPassOn(what : string, param : string) {

            if(what === "show") {
                if(param === "histogram") {
                    if(histogram_top.visible) {
                        histogram_top.hide()
                    } else {
                        histogram_top.show()
                        if(PQCFileFolderModel.countMainView === 0) { // qmllint disable unqualified
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

        target: image // qmllint disable unqualified

        function onImageFinishedLoading(index : int) {
            updateHistogram.indexTriggered = index
            updateHistogram.restart()
            failed.opacity = 0
            nofileloaded.opacity = 0
            busy.opacity = 1
        }

    }

    Connections {

        target: PQCScriptsImages // qmllint disable unqualified

        function onHistogramDataLoadedFailed(index : int) {
            if(index === PQCFileFolderModel.currentIndex) { // qmllint disable unqualified
                histogramred.clear()
                histogramgreen.clear()
                histogramblue.clear()
                histogramgrey.clear()
                busy.opacity = 0
                nofileloaded.opacity = 0
                failed.opacity = 1

            }
        }

        function onHistogramDataLoaded(data : var, index : int) {

            if(index !== PQCFileFolderModel.currentIndex) // qmllint disable unqualified
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

            // GRAY SCALE

            histogramgrey.clear();
            for(var k = 0; k < 256; ++k)
                histogramgrey.append(k, grey[k])

            busy.opacity = 0

        }

    }

    Connections {

        target: PQCSettings // qmllint disable unqualified

        function onHistogramVisibleChanged() {
            if(PQCSettings.histogramVisible) // qmllint disable unqualified
                histogram_top.show()
            else
                histogram_top.hide()
        }

    }

    Connections {
        target: PQCNotify // qmllint disable unqualified

        function onCloseAllContextMenus() {
            menu.item.dismiss() // qmllint disable missing-property
        }

    }

    function show() {
        opacity = 1
        PQCSettings.histogramVisible = true // qmllint disable unqualified
        if(popoutWindowUsed)
            histogram_popout.visible = true
    }

    function hide() {
        opacity = 0
        if(popoutWindowUsed)
            histogram_popout.visible = false // qmllint disable unqualified
        PQCSettings.histogramVisible = false
    }

}
