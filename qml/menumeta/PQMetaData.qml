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
import QtQuick.Controls 2.2

import "../elements"

Item {

    id: metadata_top

    x: PQSettings.interfacePopoutMetadata ? 0 : (PQSettings.metadataElementBehindLeftEdge ? 40 : PQSettings.metadataElementPosition.x)
    y: PQSettings.interfacePopoutMetadata ? 0 : (PQSettings.metadataElementBehindLeftEdge ? (parentHeight-height)/3 : PQSettings.metadataElementPosition.y)
    width: PQSettings.interfacePopoutMetadata ? parentWidth : PQSettings.metadataElementSize.width
    height: PQSettings.interfacePopoutMetadata ? parentHeight : Math.min(parentHeight, PQSettings.metadataElementSize.height)

    onXChanged:
        saveGeometryTimer.restart()
    onYChanged:
        saveGeometryTimer.restart()
    onWidthChanged:
        saveGeometryTimer.restart()
    onHeightChanged:
        saveGeometryTimer.restart()

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    // at startup toplevel width/height is zero causing the x/y of the histogram to be set to 0
    property bool startupDelay: true

    property bool makeVisible: (startupDelay||variables.mousePos.x == -1) ? false : (visible ? (variables.mousePos.x < width+x+20) : (variables.mousePos.x < 20))

    opacity: PQSettings.interfacePopoutMetadata ? 1 : (PQSettings.metadataElementBehindLeftEdge ? (makeVisible ? 1 : 0) : ((PQSettings.metadataElementVisible&&filefoldermodel.current!=-1) ? 1 : 0))
    Behavior on opacity { NumberAnimation { duration: PQSettings.interfacePopoutMainMenu ? 0 : PQSettings.imageviewAnimationDuration*100 } }
    visible: opacity>0

    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton|Qt.RightButton|Qt.MiddleButton
        onWheel:
            wheel.accepted = true
    }

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
            if(!PQSettings.interfacePopoutMetadata && !startupDelay) {
                PQSettings.metadataElementPosition = Qt.point(Math.max(0, Math.min(metadata_top.x, toplevel.width-metadata_top.width)), Math.max(0, Math.min(metadata_top.y, toplevel.height-metadata_top.height)))
                PQSettings.metadataElementSize = Qt.size(metadata_top.width, metadata_top.height)
            }
        }
    }

    property var allMetaData: [
        //: Please keep string short!
        em.pty+qsTranslate("metadata", "File name"), handlingGeneral.escapeHTML(handlingFileDir.getFileNameFromFullPath(filefoldermodel.currentFilePath)), PQSettings.metadataFilename,
        //: The dimensions of the loaded image. Please keep string short!
        em.pty+qsTranslate("metadata", "Dimensions"), "%1 x %2".arg(variables.currentImageResolution.width).arg(variables.currentImageResolution.height), PQSettings.metadataDimensions,
        //: Used as in "Image 3/16". The numbers (position of image in folder) are added on automatically. Please keep string short!
        em.pty+qsTranslate("metadata", "Image"), ((filefoldermodel.current+1)+"/"+filefoldermodel.countMainView), PQSettings.metadataImageNumber,
        //: Please keep string short!
        em.pty+qsTranslate("metadata", "File size"), handlingGeneral.convertBytesToHumanReadable(cppmetadata.fileSize), PQSettings.metadataFileSize,
        //: Please keep string short!
        em.pty+qsTranslate("metadata", "File type"), (filefoldermodel.current==-1 ? "" : handlingFileDir.getFileType(filefoldermodel.entriesMainView[filefoldermodel.current])), PQSettings.metadataFileType,
        "", "", true,
        //: Exif image metadata: the make of the camera used to take the photo. Please keep string short!
        em.pty+qsTranslate("metadata", "Make"), cppmetadata.exifImageMake, PQSettings.metadataMake,
        //: Exif image metadata: the model of the camera used to take the photo. Please keep string short!
        em.pty+qsTranslate("metadata", "Model"), cppmetadata.exifImageModel, PQSettings.metadataModel,
        //: Exif image metadata: the software used to create the photo. Please keep string short!
        em.pty+qsTranslate("metadata", "Software"), cppmetadata.exifImageSoftware, PQSettings.metadataSoftware,
        "", "", true,
        //: Exif image metadata: when the photo was taken. Please keep string short!
        em.pty+qsTranslate("metadata", "Time Photo was Taken"), cppmetadata.exifPhotoDateTimeOriginal, PQSettings.metadataTime,
        //: Exif image metadata: how long the sensor was exposed to the light. Please keep string short!
        em.pty+qsTranslate("metadata", "Exposure Time"), cppmetadata.exifPhotoExposureTime, PQSettings.metadataExposureTime,
        //: Exif image metadata: the flash setting when the photo was taken. Please keep string short!
        em.pty+qsTranslate("metadata", "Flash"), cppmetadata.exifPhotoFlash, PQSettings.metadataFlash,
        "ISO", cppmetadata.exifPhotoISOSpeedRatings, PQSettings.metadataIso,
        //: Exif image metadata: the specific scene type the camera used for the photo. Please keep string short!
        em.pty+qsTranslate("metadata", "Scene Type"), cppmetadata.exifPhotoSceneCaptureType, PQSettings.metadataSceneType,
        //: Exif image metadata: https://en.wikipedia.org/wiki/Focal_length . Please keep string short!
        em.pty+qsTranslate("metadata", "Focal Length"), cppmetadata.exifPhotoFocalLength, PQSettings.metadataFLength,
        //: Exif image metadata: https://en.wikipedia.org/wiki/F-number . Please keep string short!
        em.pty+qsTranslate("metadata", "F Number"), cppmetadata.exifPhotoFNumber, PQSettings.metadataFNumber,
        //: Exif image metadata: What type of light the camera detected. Please keep string short!
        em.pty+qsTranslate("metadata", "Light Source"), cppmetadata.exifPhotoLightSource, PQSettings.metadataLightSource,
        "","", true,
        //: IPTC image metadata: A description of the image by the user/software. Please keep string short!
        em.pty+qsTranslate("metadata", "Keywords"), cppmetadata.iptcApplication2Keywords, PQSettings.metadataKeywords,
        //: IPTC image metadata: The CITY and COUNTRY the imge was taken in. Please keep string short!
        em.pty+qsTranslate("metadata", "Location"), cppmetadata.iptcLocation, PQSettings.metadataLocation,
        //: IPTC image metadata. Please keep string short!
        em.pty+qsTranslate("metadata", "Copyright"), cppmetadata.iptcApplication2Copyright, PQSettings.metadataCopyright,
        "","", true,
        //: Exif image metadata. Please keep string short!
        em.pty+qsTranslate("metadata", "GPS Position"), cppmetadata.exifGPS, PQSettings.metadataGps
    ]

    Rectangle {
        anchors.fill: parent
        color: "#dd2f2f2f"
        radius: 10
    }

    // HEADING OF RECTANGLE
    Text {

        id: heading

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 20
            leftMargin: 20
        }

        horizontalAlignment: Qt.AlignLeft

        color: "#ffffff"
        font.pointSize: 18
        font.bold: true

        //: This is the heading of the metadata element
        text: em.pty+qsTranslate("metadata", "Metadata")

    }

    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: true
        drag.minimumX: 0
        drag.minimumY: 0
        drag.maximumX: toplevel.width-metadata_top.width
        drag.maximumY: toplevel.height-metadata_top.height
        drag.target: parent
        drag.axis: PQSettings.metadataElementBehindLeftEdge ? Drag.YAxis : Drag.XAndYAxis
        cursorShape: enabled ? Qt.SizeAllCursor : Qt.ArrowCursor
        onWheel: wheel.accepted = false
    }

    // Label at first start-up
    Text {

        anchors {
            top: heading.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 10
        }

        visible: filefoldermodel.current==-1

        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        color: "#888888"
        font.bold: true
        font.pointSize: 18
        wrapMode: Text.WordWrap
        text: em.pty+qsTranslate("metadata", "No File Loaded")

    }

    ListView {

        id: view

        anchors {
            top: heading.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: 20
            rightMargin: 20
            topMargin: 20
            bottomMargin: 10
        }

        visible: filefoldermodel.current!==-1

        boundsBehavior: Flickable.OvershootBounds

        ScrollBar.vertical: PQScrollBar { id: scroll; opacity: 0.5 }

        clip: true

        model: allMetaData.length/3
        delegate: Item {

            width: view.width
            height: ((allMetaData[3*index+1] !== "" && allMetaData[3*index+2]) || (allMetaData[3*index]===""&&allMetaData[3*index+1]==="")) ? val.height : 0

            Text {

                id: val;

                visible: (allMetaData[3*index+1] !== "" && allMetaData[3*index+2]) || (allMetaData[3*index]===""&&allMetaData[3*index+1]==="")

                color: "#ffffff"
                lineHeight: ((allMetaData[3*index] == "" ? 0.8 : 1.3))
                textFormat: Text.RichText
                width: parent.width
                wrapMode: Text.WordWrap
                font.pointSize: 11
                text: (allMetaData[3*index] !== "") ? ("<b>" + allMetaData[3*index] + "</b>: " + allMetaData[3*index +1]) : ""

            }

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                tooltip: (index==((allMetaData.length/3) -1)) ?
                             em.pty+qsTranslate("metadata", "Click to open GPS position with online map") :
                             ((visible&&allMetaData[3*index]!="") ? "<b>" + allMetaData[3*index] + "</b><br>" + allMetaData[3*index+1] : "")
                cursorShape: index==(allMetaData.length/3 -1) ? Qt.PointingHandCursor : Qt.ArrowCursor

                onClicked: {
                    if(index == allMetaData.length/3 -1) {

                        if(PQSettings.metadataGpsMap == "bing.com/maps")
                            Qt.openUrlExternally("http://www.bing.com/maps/?sty=r&q=" + allMetaData[3*index+1] + "&obox=1")
                        else if(PQSettings.metadataGpsMap == "maps.google.com")
                            Qt.openUrlExternally("http://maps.google.com/maps?t=h&q=" + allMetaData[3*index+1])
                        else {

                            // For openstreetmap.org, we need to convert the GPS location into decimal format

                            var one = allMetaData[3*index+1].split(", ")[0]
                            var one_dec = 1*one.split("°")[0] + (1*(one.split("°")[1].split("'")[0]))/60 + (1*(one.split("'")[1].split("''")[0]))/3600
                            if(one.indexOf("S") !== -1)
                                one_dec *= -1;

                            var two = allMetaData[3*index+1].split(", ")[1]
                            var two_dec = 1*two.split("°")[0] + (1*(two.split("°")[1].split("'")[0]))/60 + (1*(two.split("'")[1].split("''")[0]))/3600
                            if(two.indexOf("W") !== -1)
                                two_dec *= -1;

                            Qt.openUrlExternally("http://www.openstreetmap.org/#map=15/" + "" + one_dec + "/" + two_dec)
                        }

                    }
                }
            }

        }

    }

    Image {
        x: 5
        y: 5
        width: 15
        height: 15
        source: "/popin.svg"
        sourceSize: Qt.size(width, height)
        opacity: popinmouse.containsMouse ? 1 : 0.4
        Behavior on opacity { NumberAnimation { duration: 200 } }
        PQMouseArea {
            id: popinmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            tooltip: PQSettings.interfacePopoutMetadata ?
                         //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                         em.pty+qsTranslate("popinpopout", "Merge into main interface") :
                         //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                         em.pty+qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                if(PQSettings.interfacePopoutMetadata==1)
                    metadata_window.storeGeometry()
                PQSettings.interfacePopoutMetadata = !PQSettings.interfacePopoutMetadata
            }
        }
    }

    Image {

        x: parent.width-width
        y: 0
        width: 25
        height: 25

        visible: !PQSettings.interfacePopoutMetadata && !PQSettings.metadataElementBehindLeftEdge

        source: "/other/close.svg"
        sourceSize: Qt.size(width, height)

        opacity: closemouse.containsMouse ? 0.8 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }

        PQMouseArea {
            id: closemouse
            enabled: !PQSettings.metadataElementBehindLeftEdge
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked:
                PQSettings.metadataElementVisible = !PQSettings.metadataElementVisible
        }

    }

    PQMouseArea {

        id: resizeWidth

        x: parent.width-width
        y: 0
        width: 5
        height: parent.height

        enabled: !PQSettings.interfacePopoutMetadata && PQSettings.metadataElementBehindLeftEdge

        tooltip: em.pty+qsTranslate("metadata", "Click and drag to resize element")

        cursorShape: enabled ? Qt.SizeHorCursor : Qt.ArrowCursor

        property int oldMouseX

        onPressed: {
            oldMouseX = mouse.x
        }

        onReleased: {
            PQSettings.metadataElementSize.width = metadata_top.width
        }

        onPositionChanged: {
            if (pressed) {
                var w = metadata_top.width + (mouse.x-oldMouseX)
                if(w < 2*toplevel.width/3)
                    metadata_top.width = w
            }
        }

    }

    PQMouseArea {

        id: resizeHeight

        x: 0
        y: parent.height-height
        width: parent.width
        height: 5

        enabled: !PQSettings.interfacePopoutMetadata && PQSettings.metadataElementBehindLeftEdge

        tooltip: em.pty+qsTranslate("metadata", "Click and drag to resize element")

        cursorShape: enabled ? Qt.SizeVerCursor : Qt.ArrowCursor

        property int oldMouseY

        onPressed: {
            oldMouseY = mouse.y
        }

        onReleased: {
            PQSettings.metadataElementSize.height = metadata_top.height
        }

        onPositionChanged: {
            if (pressed) {
                var h = metadata_top.height + (mouse.y-oldMouseY)
                metadata_top.height = h
            }
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
        cursorShape: enabled ? Qt.SizeFDiagCursor : Qt.ArrowCursor

        onPositionChanged: {
            if(pressed) {
                metadata_top.width = Math.max(300, metadata_top.width + (mouse.x-resizeBotRight.width))
                metadata_top.height = Math.max(400, metadata_top.height + (mouse.y-resizeBotRight.height))
            }
        }

    }

    Connections {
        target: loader
        onMetadataPassOn: {
            if(what == "toggleKeepOpen" || what == "toggle")
                toggle()
        }
    }

    function toggle() {
        if(PQSettings.interfacePopoutMetadata) return
        PQSettings.metadataElementVisible = !PQSettings.metadataElementVisible
    }

}
