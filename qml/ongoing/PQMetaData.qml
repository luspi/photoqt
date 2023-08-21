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

import QtQuick
import QtQuick.Controls

import PQCNotify
import PQCFileFolderModel
import PQCScriptsConfig
import PQCScriptsFilesPaths
import PQCScriptsMetaData
import PQCMetaData

import "../elements"

Rectangle {

    id: metadata_top

    x: setVisible ? visiblePos[0] : invisiblePos[0]
    y: setVisible ? visiblePos[1] : invisiblePos[1]
    Behavior on x { NumberAnimation { duration: dragrightMouse.enabled&&dragrightMouse.clickStart!=-1 ? 0 : 200 } }

    onYChanged: {
        if(!toplevel.startup)
            saveXY.restart()
    }

    onXChanged: {
        if(!toplevel.startup)
            saveXY.restart()
    }

    Timer {
        id: saveXY
        interval: 200
        onTriggered:
            PQCSettings.metadataElementPosition = Qt.point(x,y)
    }

    width: PQCSettings.metadataElementSize.width
    height: Math.min(toplevel.height, PQCSettings.metadataElementSize.height)

    color: PQCLook.transColor

    radius: 5

    // visibility status
    opacity: setVisible ? 1 : 0
    visible: opacity>0
    Behavior on opacity { NumberAnimation { duration: 200 } }

    property bool setVisible: false
    property var visiblePos: [0,0]
    property var invisiblePos: [0, 0]
    property rect hotArea: Qt.rect(0, toplevel.height-10, toplevel.width, 10)

    state: !PQCSettings.metadataElementBehindLeftEdge ?
               "floating" :
                (PQCSettings.interfaceEdgeLeftAction==="metadata"
                   ? "left"
                   : (PQCSettings.interfaceEdgeRightAction==="metadata"
                       ? "right"
                   : "disabled" ))

    property int gap: 40

    // the four states corresponding to screen edges
    states: [
        State {
            name: "left"
            PropertyChanges {
                target: metadata_top
                visiblePos: [gap,
                             Math.max(0, Math.min(toplevel.height-height, PQCSettings.metadataElementPosition.y))]
                invisiblePos: [-width, Math.max(0, Math.min(toplevel.height-height, PQCSettings.metadataElementPosition.y))]
                hotArea: Qt.rect(0,0,10,toplevel.height)
            }
        },
        State {
            name: "right"
            PropertyChanges {
                target: metadata_top
                visiblePos: [toplevel.width-width-gap, Math.max(0, Math.min(toplevel.height-height, PQCSettings.metadataElementPosition.y))]
                invisiblePos: [toplevel.width, Math.max(0, Math.min(toplevel.height-height, PQCSettings.metadataElementPosition.y))]
                hotArea: Qt.rect(toplevel.width-10,0,10,toplevel.height)
            }
        },
        State {
            name: "disabled"
            PropertyChanges {
                target: metadata_top
                setVisible: false
                hotArea: Qt.rect(0,0,0,0)
            }
        },
        State {
            name: "floating"
            PropertyChanges {
                target: metadata_top
                hotArea: Qt.rect(0,0,0,0)
                setVisible: PQCSettings.metadataElementVisible
                visiblePos: [Math.max(0, Math.min(toplevel.width-width, PQCSettings.metadataElementPosition.x)),
                             Math.max(0, Math.min(toplevel.height-height, PQCSettings.metadataElementPosition.y))]
                invisiblePos: visiblePos
            }
        }

    ]

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onWheel: (wheel) =>{
            wheel.accepted = true
        }
    }

    property bool anythingLoaded: PQCFileFolderModel.countMainView>0

    property int colwidth: width-2*flickable.anchors.margins

    property int normalEntryHeight: 20

    PQTextXL {
        anchors.fill: parent
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        text: "No file loaded"
        font.bold: PQCLook.fontWeightBold
        color: PQCLook.textColorHighlight
        visible: PQCFileFolderModel.countMainView===0
    }

    Rectangle {

        id: heading

        x: 10
        y: 10
        width: flickable.width
        height: head_txt.height+10
        color: PQCLook.transColorHighlight
        radius: 5

        PQTextXL {
            id: head_txt
            x: 5
            y: 5
            text: "Metadata"
            font.weight: PQCLook.fontWeightBold
            opacity: 0.8
        }

        MouseArea {
            id: dragmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeAllCursor
            onWheel: (wheel) =>{
                wheel.accepted = true
            }
            drag.target: metadata_top
            drag.axis: metadata_top.state==="floating" ? Drag.XAndYAxis : Drag.YAxis
            drag.minimumY: 0
            drag.maximumY: toplevel.height-metadata_top.height
        }

    }

    Flickable {

        id: flickable

        anchors.fill: parent
        anchors.margins: 10
        anchors.topMargin: heading.height+20

        contentHeight: flickable_col.height

        clip: true

        ScrollBar.vertical: PQVerticalScrollBar { }

        Column {

            id: flickable_col

            spacing: 8

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "File name")
                valtxt: PQCScriptsFilesPaths.getFilename(PQCFileFolderModel.currentFile)
                visible: PQCSettings.metadataFilename
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Dimensions")
                valtxt: PQCFileFolderModel.countMainView>0 ? ("%1 x %2".arg(image.currentResolution.width).arg(image.currentResolution.height)) : ""
                visible: PQCSettings.metadataDimensions
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Image")
                valtxt: PQCFileFolderModel.countMainView>0 ? (((PQCFileFolderModel.currentIndex+1)+"/"+PQCFileFolderModel.countMainView)) : ""
                visible: PQCSettings.metadataImageNumber
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "File size")
                valtxt: PQCScriptsFilesPaths.getFileSizeHumanReadable(PQCFileFolderModel.currentFile)
                visible: PQCSettings.metadataFileSize
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "File type")
                valtxt: PQCScriptsFilesPaths.getFileType(PQCFileFolderModel.currentFile)
                visible: PQCSettings.metadataFileType
            }

            Item {
                width: 1
                height: 1
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Make")
                valtxt: PQCMetaData.exifMake
                visible: PQCSettings.metadataMake
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Model")
                valtxt: PQCMetaData.exifModel
                visible: PQCSettings.metadataModel
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Software")
                valtxt: PQCMetaData.exifSoftware
                visible: PQCSettings.metadataSoftware
            }

            Item {
                width: 1
                height: 1
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Time Photo was Taken")
                valtxt: PQCMetaData.exifDateTimeOriginal
                visible: PQCSettings.metadataTime
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Exposure Time")
                valtxt: PQCMetaData.exifExposureTime
                visible: PQCSettings.metadataExposureTime
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Flash")
                valtxt: PQCMetaData.exifFlash
                visible: PQCSettings.metadataFlash
            }

            PQMetaDataEntry {
                whichtxt: "ISO"
                valtxt: PQCMetaData.exifISOSpeedRatings
                visible: PQCSettings.metadataIso
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Scene Type")
                valtxt: PQCMetaData.exifSceneCaptureType
                visible: PQCSettings.metadataSceneType
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Focal Length")
                valtxt: PQCMetaData.exifFocalLength
                visible: PQCSettings.metadataFLength
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "F Number")
                valtxt: PQCMetaData.exifFNumber
                visible: PQCSettings.metadataFNumber
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Light Source")
                valtxt: PQCMetaData.exifLightSource
                visible: PQCSettings.metadataLightSource
            }

            Item {
                width: 1
                height: 1
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Keywords")
                valtxt: PQCMetaData.iptcKeywords
                visible: PQCSettings.metadataKeywords
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Location")
                valtxt: PQCMetaData.iptcLocation
                visible: PQCSettings.metadataLocation
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Copyright")
                valtxt: PQCMetaData.iptcCopyright
                visible: PQCSettings.metadataCopyright
            }

            Item {
                width: 1
                height: 1
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "GPS Position")
                valtxt: PQCMetaData.exifGPS
                visible: PQCSettings.metadataGps
                tooltip: tooltip
                enableMouse: true
                onClicked: {
                    if(PQCSettings.metadataGpsMap === "bing.com/maps")
                        Qt.openUrlExternally("http://www.bing.com/maps/?sty=r&q=" + valtxt + "&obox=1")
                    else if(PQCSettings.metadataGpsMap === "maps.google.com")
                        Qt.openUrlExternally("http://maps.google.com/maps?t=h&q=" + valtxt)
                    else {
                        Qt.openUrlExternally("https://www.openstreetmap.org/#map=15/" + PQCScriptsMetaData.convertGPSToDecimal(valtxt))
                    }
                }
            }

        }

    }

    MouseArea {
        y: (parent.height-height)
        width: parent.width
        height: 10
        cursorShape: Qt.SizeVerCursor

        property int clickStart: -1
        property int origHeight: PQCSettings.metadataElementSize.height
        onPressed: (mouse) => {
            clickStart = mouse.y
        }
        onReleased:
            clickStart = -1

        onPositionChanged: (mouse) => {
            if(clickStart == -1)
                return
            var diff = mouse.y-clickStart
            PQCSettings.metadataElementSize.height = origHeight+diff

        }

    }

    MouseArea {
        x: (parent.width-width)
        width: 10
        height: parent.height
        cursorShape: enabled ? Qt.SizeHorCursor : Qt.ArrowCursor
        enabled: parent.state=="left"

        property int clickStart: -1
        property int origWidth: PQCSettings.metadataElementSize.width
        onPressed: (mouse) => {
            clickStart = mouse.x
        }
        onReleased:
            clickStart = -1

        onPositionChanged: (mouse) => {
            if(clickStart == -1)
                return
            var diff = mouse.x-clickStart
            PQCSettings.metadataElementSize.width = Math.min(toplevel.width/2, Math.max(200, origWidth+diff))

        }

    }

    MouseArea {
        id: dragrightMouse
        x: 0
        width: 10
        height: parent.height
        cursorShape: enabled ? Qt.SizeHorCursor : Qt.ArrowCursor
        enabled: parent.state=="right"

        property int clickStart: -1
        property int origWidth: PQCSettings.metadataElementSize.width
        onPressed: (mouse) => {
            clickStart = mouse.x
        }
        onReleased:
            clickStart = -1

        onPositionChanged: (mouse) => {
            if(clickStart == -1)
                return
            var diff = clickStart-mouse.x
            PQCSettings.metadataElementSize.width = Math.min(toplevel.width/2, Math.max(200, origWidth+diff))

        }

    }

    Connections {
        target: PQCNotify
        function onMouseMove(posx, posy) {

            if(!PQCSettings.metadataElementBehindLeftEdge)
                return

            if(setVisible) {
                if(posx < metadata_top.x-50 || posx > metadata_top.x+metadata_top.width+50 || posy < metadata_top.y-50 || posy > metadata_top.y+metadata_top.height+50)
                    setVisible = false
            } else {
                if(hotArea.x < posx && hotArea.x+hotArea.width > posx && hotArea.y < posy && hotArea.height+hotArea.y > posy)
                    setVisible = true
            }
        }
    }

    function hideMetaData() {
        metadata_top.setVisible = false
    }

}
