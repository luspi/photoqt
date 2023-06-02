/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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
import "../templates"

PQTemplateIntegrated {

    id: hist_top

    popout: PQSettings.interfacePopoutHistogram
    geometry: Qt.rect(PQSettings.histogramPosition.x,
                      PQSettings.histogramPosition.y,
                      PQSettings.histogramSize.width,
                      PQSettings.histogramSize.height)
    toBeShown: PQSettings.histogramVisible
    itemname: "histogram"

    thisIsBlur: histogram
    tooltip: (PQSettings.interfacePopoutHistogram ? "" : (em.pty+qsTranslate("histogram", "Click-and-drag to move.")+" ")) + em.pty+qsTranslate("histogram", "Right click to switch version.")

    onPopoutChanged:
        PQSettings.interfacePopoutHistogram = popout

    onGeometryChanged: {
        PQSettings.histogramPosition = Qt.point(geometry.x, geometry.y)
        PQSettings.histogramSize = Qt.size(geometry.width, geometry.height)
    }

    onToBeShownChanged:
        PQSettings.histogramVisible = toBeShown

    onUpdateElement:
        updateHistogram()

    onClickedRight: {
        PQSettings.histogramVersion = (PQSettings.histogramVersion !== "grey" ? "grey" : "color")
        updateHistogram()
    }

    content: [

        Item {

            anchors.fill: parent

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

                PQText {
                    x: 25
                    y: 15
                    text: filefoldermodel.current==-1 ?
                              em.pty+qsTranslate("histogram", "Histogram") :
                              //: As in: Loading the histogram for the current image
                              em.pty+qsTranslate("histogram", "Loading...")
                    font.weight: baselook.boldweight
                }

            }

            PinchArea {

                anchors.fill: parent

                pinch.target: PQSettings.interfacePopoutHistogram ? undefined : hist_top
                pinch.minimumRotation: 0
                pinch.maximumRotation: 0
                pinch.minimumScale: 1
                pinch.maximumScale: 1
                pinch.dragAxis: Pinch.XAndYAxis

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

        }

    ]

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

    function updateHistogram() {

        // Don't calculate histogram if disabled
        if(!PQSettings.histogramVisible || filefoldermodel.current == -1) return;

        // we do not want to bind to the currentFilePath below, as we want to preserve a short timeout when that property changes
        var fp = filefoldermodel.currentFilePath

        imghist.source = Qt.binding(function() { return "image://hist/" + (PQSettings.histogramVersion == "color" ? "color" : "grey") + fp; })

    }

}
