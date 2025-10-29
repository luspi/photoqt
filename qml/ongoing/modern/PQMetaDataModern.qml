/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import PhotoQt

Rectangle {

    id: metadata_top

    x: (setVisible ? visiblePos[0] : invisiblePos[0])
    y: (PQCSettings.metadataElementHeightDynamic ? statusinfoOffset : 0) + (setVisible ? visiblePos[1] : invisiblePos[1])
    Behavior on x { NumberAnimation { duration: dragrightMouse.enabled&&dragrightMouse.clickStart!=-1&&!animateResize ? 0 : 200 } }

    property bool animateResize: false
    onAnimateResizeChanged: {
        if(animateResize)
            resetAnimateResize.restart()
    }

    SystemPalette { id: pqtPalette }

    Timer {
        id: resetAnimateResize
        interval: 250
        onTriggered: {
            metadata_top.animateResize = false
        }
    }

    onYChanged: {
        if(dragmouse.drag.active)
            saveXY.restart()
    }

    onXChanged: {
        if(dragmouse.drag.active)
            saveXY.restart()
    }

    onOpacityChanged: {
        PQCConstants.metadataOpacity = metadata_top.opacity
    }

    Timer {
        id: saveXY
        interval: 200
        onTriggered:
            PQCSettings.metadataElementPosition = Qt.point(Math.round(metadata_top.x),Math.round(metadata_top.y))
    }

    property int parentWidth
    property int parentHeight
    width: Math.max(300, PQCSettings.metadataElementSize.width)
    height: isPopout ? metadata_popout.height :
                PQCSettings.metadataElementHeightDynamic ?
                            PQCConstants.availableHeight-2*gap-statusinfoOffset :
                            Math.min(PQCConstants.availableHeight, PQCSettings.metadataElementSize.height)

    color: pqtPalette.base

    radius: PQCScriptsConfig.isQtAtLeast6_5() ? 0 : 5

    // visibility status
    opacity: setVisible&&windowSizeOkay ? 1 : 0
    visible: opacity>0
    Behavior on opacity { NumberAnimation { duration: 200 } }

    property bool setVisible: false
    property var visiblePos: [0,0]
    property var invisiblePos: [0, 0]
    property int hotAreaSize: PQCSettings.interfaceHotEdgeSize*5
    property rect hotArea: Qt.rect(0, PQCConstants.availableHeight-hotAreaSize, PQCConstants.availableWidth, hotAreaSize)
    property bool windowSizeOkay: true

    // this is set to true/false by the popout window
    // this is a way to reliably detect whether it is used
    property bool popoutWindowUsed: false

    onSetVisibleChanged: {
        if(!setVisible && menu.item !== null)
            menu.item.dismiss()
    }

    PQShadowEffect { masterItem: metadata_top }

    property bool isPopout: PQCSettings.interfacePopoutMetadata||PQCWindowGeometry.metadataForcePopout
    state: isPopout ?
               "popout" :
               PQCSettings.metadataElementFloating ?
                   "floating" :
                   (PQCSettings.interfaceEdgeLeftAction==="metadata" ?
                        "left" :
                        (PQCSettings.interfaceEdgeRightAction==="metadata" ?
                             "right" :
                             "disabled" ))

    property int gap: 40
    property int statusinfoOffset: PQCConstants.statusinfoIsVisible&&state==="left" ? (PQCConstants.statusInfoCurrentRect.height+PQCConstants.statusInfoCurrentRect.y) : 0

    // the four states corresponding to screen edges
    states: [
        State {
            name: "left"
            PropertyChanges {
                metadata_top.visiblePos: [metadata_top.gap,
                                          (PQCSettings.metadataElementHeightDynamic ? metadata_top.gap : Math.max(0, Math.min(PQCConstants.availableHeight-metadata_top.height, PQCSettings.metadataElementPosition.y)))]
                metadata_top.invisiblePos: [-metadata_top.width,
                                            (PQCSettings.metadataElementHeightDynamic ? metadata_top.gap : Math.max(0, Math.min(PQCConstants.availableHeight-metadata_top.height, PQCSettings.metadataElementPosition.y)))]
                metadata_top.hotArea: Qt.rect(0,0,metadata_top.hotAreaSize,PQCConstants.availableHeight)
                metadata_top.windowSizeOkay: PQCConstants.availableWidth>500 && PQCConstants.availableHeight>500
            }
        },
        State {
            name: "right"
            PropertyChanges {
                metadata_top.visiblePos: [PQCConstants.availableWidth-metadata_top.width-metadata_top.gap,
                                          (PQCSettings.metadataElementHeightDynamic ? metadata_top.gap : Math.max(0, Math.min(PQCConstants.availableHeight-metadata_top.height, PQCSettings.metadataElementPosition.y)))]
                metadata_top.invisiblePos: [PQCConstants.availableWidth,
                                            (PQCSettings.metadataElementHeightDynamic ? metadata_top.gap : Math.max(0, Math.min(PQCConstants.availableHeight-metadata_top.height, PQCSettings.metadataElementPosition.y)))]
                metadata_top.hotArea: Qt.rect(PQCConstants.availableWidth-metadata_top.hotAreaSize,0,metadata_top.hotAreaSize,PQCConstants.availableHeight)
                metadata_top.windowSizeOkay: PQCConstants.availableWidth>500 && PQCConstants.availableHeight>500
            }
        },
        State {
            name: "disabled"
            PropertyChanges {
                metadata_top.setVisible: false
                metadata_top.hotArea: Qt.rect(0,0,0,0)
            }
        },
        State {
            name: "floating"
            PropertyChanges {
                metadata_top.hotArea: Qt.rect(0,0,0,0)
                metadata_top.setVisible: PQCSettings.metadataElementVisible
                metadata_top.visiblePos: [Math.max(0, Math.min(PQCConstants.availableWidth-metadata_top.width, PQCSettings.metadataElementPosition.x)),
                                          Math.max(0, Math.min(PQCConstants.availableHeight-metadata_top.height, PQCSettings.metadataElementPosition.y))]
                metadata_top.invisiblePos: metadata_top.visiblePos
                metadata_top.windowSizeOkay: true
            }
        },
        State {
            name: "popout"
            PropertyChanges {
                metadata_top.setVisible: true
                metadata_top.hotArea: Qt.rect(0,0,0,0)
                metadata_top.width: metadata_top.parentWidth
                metadata_top.height: metadata_top.parentHeight
                metadata_top.windowSizeOkay: true
            }
        }

    ]

    Component.onCompleted: {
        if(PQCSettings.interfacePopoutMetadata) {
            metadata_top.opacity = 1
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.AllButtons
        onWheel: (wheel) =>{
            wheel.accepted = true
        }
        onClicked: (mouse) => {
            if(mouse.button === Qt.RightButton)
                menu.item.popup()
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
        text: qsTranslate("metadata", "No file loaded")
        font.bold: PQCLook.fontWeightBold
        enabled: false
        visible: PQCFileFolderModel.countMainView===0
    }

    Item {

        id: heading

        x: 10
        y: 10
        width: flickable.width
        height: head_txt.height+10
        Rectangle {
            anchors.fill: parent
            color: pqtPalette.alternateBase
            opacity: 0.8
            radius: 5
        }

        PQTextXL {
            id: head_txt
            x: 5
            y: 5
            //: The title of the floating element
            text: qsTranslate("metadata", "Metadata")
            font.weight: PQCLook.fontWeightBold
            opacity: 0.8
        }

        MouseArea {
            id: dragmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: metadata_top.isPopout ? Qt.ArrowCursor : Qt.SizeAllCursor
            onWheel: (wheel) =>{
                wheel.accepted = true
            }
            drag.target: metadata_top.isPopout ? undefined : metadata_top
            drag.axis: metadata_top.state==="floating" ? Drag.XAndYAxis : Drag.YAxis
            drag.minimumY: 0
            drag.maximumY: PQCConstants.availableHeight-metadata_top.height
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
                prop: PQCSettings.metadataFilename
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Dimensions")
                valtxt: PQCFileFolderModel.countMainView>0 ? ("%1 x %2".arg(PQCConstants.currentImageResolution.width).arg(PQCConstants.currentImageResolution.height)) : ""
                prop: PQCSettings.metadataDimensions
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Image")
                valtxt: PQCFileFolderModel.countMainView>0 ? (((PQCFileFolderModel.currentIndex+1)+"/"+PQCFileFolderModel.countMainView)) : ""
                prop: PQCSettings.metadataImageNumber
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "File size")
                valtxt: PQCScriptsFilesPaths.getFileSizeHumanReadable(PQCFileFolderModel.currentFile)
                prop: PQCSettings.metadataFileSize
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "File type")
                valtxt: PQCScriptsFilesPaths.getFileType(PQCFileFolderModel.currentFile)
                prop: PQCSettings.metadataFileType
            }

            Item {
                width: 1
                height: 1
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Make")
                valtxt: PQCMetaData.exifMake
                prop: PQCSettings.metadataMake
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Model")
                valtxt: PQCMetaData.exifModel
                prop: PQCSettings.metadataModel
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Software")
                valtxt: PQCMetaData.exifSoftware
                prop: PQCSettings.metadataSoftware
            }

            Item {
                width: 1
                height: 1
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Time Photo was Taken")
                valtxt: PQCMetaData.exifDateTimeOriginal
                prop: PQCSettings.metadataTime
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Exposure Time")
                valtxt: PQCMetaData.exifExposureTime
                prop: PQCSettings.metadataExposureTime
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Flash")
                valtxt: PQCMetaData.exifFlash
                prop: PQCSettings.metadataFlash
            }

            PQMetaDataEntry {
                whichtxt: "ISO"
                valtxt: PQCMetaData.exifISOSpeedRatings
                prop: PQCSettings.metadataIso
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Scene Type")
                valtxt: PQCMetaData.exifSceneCaptureType
                prop: PQCSettings.metadataSceneType
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Focal Length")
                valtxt: PQCMetaData.exifFocalLength
                prop: PQCSettings.metadataFLength
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "F Number")
                valtxt: PQCMetaData.exifFNumber
                prop: PQCSettings.metadataFNumber
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Light Source")
                valtxt: PQCMetaData.exifLightSource
                prop: PQCSettings.metadataLightSource
            }

            Item {
                width: 1
                height: 1
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Keywords")
                valtxt: PQCMetaData.iptcKeywords
                prop: PQCSettings.metadataKeywords
            }

            PQMetaDataEntry {
                //: The location here is a GPS location
                whichtxt: qsTranslate("metadata", "Location")
                valtxt: PQCMetaData.iptcLocation
                prop: PQCSettings.metadataLocation
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Copyright")
                valtxt: PQCMetaData.iptcCopyright
                prop: PQCSettings.metadataCopyright
            }

            Item {
                width: 1
                height: 1
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "GPS Position")
                valtxt: PQCMetaData.exifGPS
                prop: PQCSettings.metadataGps
                //: The location here is a GPS location
                tooltip: qsTranslate("metadata", "Click to copy value to clipboard, Ctrl+Click to open location in online map service")
                signalClicks: true
                onClicked: (mouse) => {
                    if(mouse.modifiers === Qt.ControlModifier) {
                       if(PQCSettings.metadataGpsMap === "bing.com/maps")
                           Qt.openUrlExternally("http://www.bing.com/maps/?sty=r&q=" + valtxt + "&obox=1")
                       else if(PQCSettings.metadataGpsMap === "maps.google.com")
                           Qt.openUrlExternally("http://maps.google.com/maps?t=h&q=" + valtxt)
                       else
                           Qt.openUrlExternally("https://www.openstreetmap.org/#map=15/" + PQCScriptsMetaData.convertGPSToDecimalForOpenStreetMap(valtxt))
                    } else
                        PQCScriptsClipboard.copyTextToClipboard(valtxt)
                }
            }

        }

    }

    MultiPointTouchArea {

        id: toucharea

        anchors.fill: parent
        anchors.topMargin: 50
        mouseEnabled: false

        maximumTouchPoints: 1

        property point touchPos

        onPressed: (touchPoints) => {
            touchPos = touchPoints[0]
            touchShowMenu.start()
        }

        onUpdated: (touchPoints) => {
            if(Math.sqrt(Math.pow(touchPos.x-touchPoints[0].x, 2) + Math.pow(touchPos.y-touchPoints[0].y, 2)) > 50) {
                touchShowMenu.stop()
            }
        }

        onReleased: {
            touchShowMenu.stop()
        }

        Timer {
            id: touchShowMenu
            interval: 1000
            onTriggered: {
                menu.item.popup(toucharea.mapToItem(metadata_top, toucharea.touchPos))
            }
        }

    }

    MouseArea {
        y: (parent.height-height)
        width: parent.width
        height: 10
        cursorShape: enabled ? Qt.SizeVerCursor : Qt.ArrowCursor
        enabled: parent.state!=="popout"

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
            metadata_top.y = metadata_top.y
            if(!metadata_top.isPopout)
                metadata_top.height = metadata_top.height
            PQCSettings.metadataElementPosition.y = metadata_top.y
            PQCSettings.metadataElementSize.height = metadata_top.height
            PQCSettings.metadataElementSize.height = Math.round(origHeight+diff)
            metadata_top.height = Qt.binding(function() { return PQCSettings.metadataElementSize.height })
            PQCSettings.metadataElementHeightDynamic = false
        }

    }

    MouseArea {
        x: (parent.width-width)
        width: 10
        height: parent.height
        cursorShape: enabled ? Qt.SizeHorCursor : Qt.ArrowCursor
        enabled: parent.state==="left"

        property int clickStart: -1
        property int origWidth: metadata_top.width
        onPressed: (mouse) => {
            clickStart = mouse.x
        }
        onReleased:
            clickStart = -1

        onPositionChanged: (mouse) => {
            if(clickStart == -1)
                return
            var diff = mouse.x-clickStart
            PQCSettings.metadataElementSize.width = Math.round(Math.min(PQCConstants.availableWidth/2, Math.max(200, origWidth+diff)))

        }

    }

    MouseArea {
        id: dragrightMouse
        x: 0
        width: 10
        height: parent.height
        cursorShape: enabled ? Qt.SizeHorCursor : Qt.ArrowCursor
        enabled: parent.state==="right"

        property int clickStart: -1
        property int origWidth: metadata_top.width
        onPressed: (mouse) => {
            clickStart = mouse.x
        }
        onReleased:
            clickStart = -1

        onPositionChanged: (mouse) => {
            if(clickStart == -1)
                return
            var diff = clickStart-mouse.x
            PQCSettings.metadataElementSize.width = Math.round(Math.min(PQCConstants.availableWidth/2, Math.max(200, origWidth+diff)))

        }

    }

    ButtonGroup { id: grp1 }
    ButtonGroup { id: grp2 }

    property list<var> labels: [
        ["Filename", qsTranslate("settingsmanager", "file name")],
        ["Dimensions", qsTranslate("settingsmanager", "dimensions")],
        ["ImageNumber", qsTranslate("settingsmanager", "image #/#")],
        ["FileSize", qsTranslate("settingsmanager", "file size")],
        ["FileType", qsTranslate("settingsmanager", "file type")],
        ["Make", qsTranslate("settingsmanager", "make")],
        ["Model", qsTranslate("settingsmanager", "model")],
        ["Software", qsTranslate("settingsmanager", "software")],
        ["Time", qsTranslate("settingsmanager", "time photo was taken")],
        ["ExposureTime", qsTranslate("settingsmanager", "exposure time")],
        ["Flash", qsTranslate("settingsmanager", "flash")],
        ["Iso", "ISO"],
        ["SceneType", qsTranslate("settingsmanager", "scene type")],
        ["FLength", qsTranslate("settingsmanager", "focal length")],
        ["FNumber", qsTranslate("settingsmanager", "f-number")],
        ["LightSource", qsTranslate("settingsmanager", "light source")],
        ["Keywords", qsTranslate("settingsmanager", "keywords")],
        ["Location", qsTranslate("settingsmanager", "location")],
        ["Copyright", qsTranslate("settingsmanager", "copyright")],
        ["Gps", qsTranslate("settingsmanager", "GPS position")]]

    Loader {

        id: menu
        asynchronous: true

        sourceComponent:
        PQMenu {

            id: themenu

            PQMenuItem {
                enabled: false
                font.italic: true
                moveToRightABit: true
                text: qsTranslate("metadata", "Metadata")
            }

            PQMenuSeparator {}

            PQMenu {
                title: "Visible labels"

                Repeater {

                    model: metadata_top.labels.length

                    PQMenuItem {
                        id: ent
                        required property int modelData
                        checkable: true
                        text: metadata_top.labels[modelData][1]
                        checked: PQCSettings["metadata"+metadata_top.labels[modelData][0]]
                        onCheckedChanged: {
                            PQCSettings["metadata"+metadata_top.labels[modelData][0]] = checked
                        }
                    }

                }

            }

            PQMenu {
                title: "GPS map"
                PQMenuItem {
                    checkable: true
                    checkableLikeRadioButton: true
                    text: "openstreetmap.org"
                    ButtonGroup.group: grp2
                    checked: PQCSettings.metadataGpsMap==="openstreetmap.org"
                    onCheckedChanged:
                        PQCSettings.metadataGpsMap = "openstreetmap.org"
                }
                PQMenuItem {
                    checkable: true
                    checkableLikeRadioButton: true
                    text: "maps.google.com"
                    ButtonGroup.group: grp2
                    checked: PQCSettings.metadataGpsMap==="maps.google.com"
                    onCheckedChanged:
                        PQCSettings.metadataGpsMap = "maps.google.com"
                }
                PQMenuItem {
                    checkable: true
                    checkableLikeRadioButton: true
                    text: "bing.com/maps"
                    ButtonGroup.group: grp2
                    checked: PQCSettings.metadataGpsMap==="bing.com/maps"
                    onCheckedChanged:
                        PQCSettings.metadataGpsMap = "bing.com/maps"
                }
            }

            PQMenuSeparator {}

            PQMenuItem {
                checkable: true
                checkableLikeRadioButton: true
                text: qsTranslate("settingsmanager", "hide behind screen edge")
                ButtonGroup.group: grp1
                checked: !PQCSettings.metadataElementFloating
                onCheckedChanged:
                    PQCSettings.metadataElementFloating = !checked
            }

            PQMenuItem {
                checkable: true
                checkableLikeRadioButton: true
                text: qsTranslate("settingsmanager", "use floating element")
                ButtonGroup.group: grp1
                checked: PQCSettings.metadataElementFloating
                onCheckedChanged: {
                    PQCSettings.metadataElementFloating = checked
                    if(checked)
                        metadata_top.setVisible = true
                }
            }

            PQMenuSeparator { lighterColor: true }

            PQMenuItem {
                checkable: true
                checked: PQCSettings.metadataElementHeightDynamic
                text: qsTranslate("metadata", "Adjust height dynamically")
                onCheckedChanged: {
                    metadata_top.animateResize = true
                    if(checked) {
                        metadata_top.y = Qt.binding(function() { return statusinfoOffset + (setVisible ? visiblePos[1] : invisiblePos[1]) })
                        if(!metadata_top.isPopout)
                            metadata_top.height = Qt.binding(function() { return PQCConstants.availableHeight-2*gap-statusinfoOffset })
                        PQCSettings.metadataElementHeightDynamic = true
                    } else {
                        metadata_top.y = metadata_top.y
                        if(!metadata_top.isPopout)
                            metadata_top.height = metadata_top.height
                        PQCSettings.metadataElementPosition.y = metadata_top.y
                        PQCSettings.metadataElementSize.height = metadata_top.height
                        PQCSettings.metadataElementHeightDynamic = false
                    }
                    checked = Qt.binding(function() { return PQCSettings.metadataElementHeightDynamic })
                }
            }

            PQMenuItem {
                text: qsTranslate("metadata", "Reset size to default")
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/reset.svg"
                onTriggered: {
                    PQCSettings.setDefaultForMetadataElementSize()
                    PQCSettings.setDefaultForMetadataElementPosition()
                    metadata_top.animateResize = true
                    metadata_top.y = Qt.binding(function() { return (PQCSettings.metadataElementHeightDynamic ? statusinfoOffset : 0) + (setVisible ? visiblePos[1] : invisiblePos[1]) })
                    metadata_top.width = Qt.binding(function() { return Math.max(400, PQCSettings.metadataElementSize.width) })
                    if(!metadata_top.isPopout)
                        metadata_top.height = Qt.binding(function() { return PQCConstants.availableHeight-2*gap-statusinfoOffset })
                    PQCSettings.metadataElementHeightDynamic = true
                }
            }

            PQMenuSeparator {}

            PQMenuItem {
                text: qsTranslate("settingsmanager", "Manage in settings manager")
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/settings.svg"
                onTriggered: {
                    PQCNotify.openSettingsManagerAt("showSettings", ["metadata"])
                }
            }

            onAboutToHide:
                recordAsClosed.restart()
            onAboutToShow:
                PQCConstants.addToWhichContextMenusOpen("metadata")

            Timer {
                id: recordAsClosed
                interval: 200
                onTriggered: {
                    if(!themenu.visible)
                        PQCConstants.removeFromWhichContextMenusOpen("metadata")
                }
            }

        }

    }

    Image {
        x: 5
        y: 5
        width: 15
        height: 15
        visible: !PQCWindowGeometry.metadataForcePopout
        enabled: visible
        source: "image://svg/:/" + PQCLook.iconShade + "/popinpopout.svg"
        sourceSize: Qt.size(width, height)
        opacity: popinmouse.containsMouse ? 1 : 0.4
        Behavior on opacity { NumberAnimation { duration: 200 } }
        PQMouseArea {
            id: popinmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            text: PQCSettings.interfacePopoutMetadata ?
                      //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                      qsTranslate("popinpopout", "Merge into main interface") :
                      //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                      qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                PQCSettings.interfacePopoutMetadata = !PQCSettings.interfacePopoutMetadata
            }
        }
    }

    Timer {
        id: hideElementWithDelay
        interval: 1000
        onTriggered: {
            metadata_top.setVisible = false
        }
    }

    property bool ignoreMouseMoveShortly: false

    Connections {

        target: PQCNotify

        function onCloseAllContextMenus() {
            menu.item.dismiss()
        }

    }

    Connections {
        target: PQCConstants
        function onAvailableWidthChanged() {
            metadata_top.setVisible = false
        }
        function onAvailableHeightChanged() {
            metadata_top.setVisible = false
        }
    }

    Connections {

        target: PQCNotify

        function onLoaderPassOn(what : string, param : list<var>) {

            if(what === "show") {
                if(param[0] === "MetaData") {
                    if(!PQCSettings.metadataElementFloating)
                        metadata_top.setVisible = !metadata_top.setVisible

                    if(metadata_top.popoutWindowUsed)
                        metadata_popout.visible = true
                }
            } else if(what === "toggle" && param[0] === "MetaData") {
                metadata_top.toggle()
            } else if(what === "forceshow" && param[0] === "MetaData") {
                metadata_top.ignoreMouseMoveShortly = true
                metadata_top.setVisible = true
                resetIgnoreMouseMoveShortly.restart()
            } else if(what === "forcehide" && param[0] === "MetaData") {
                metadata_top.ignoreMouseMoveShortly = true
                metadata_top.setVisible = false
                resetIgnoreMouseMoveShortly.restart()
            }

        }

        function onMouseMove(posx : int, posy : int) {

            if(ignoreMouseMoveShortly || PQCConstants.modalWindowOpen)
                return

            if(PQCConstants.slideshowRunning || PQCConstants.faceTaggingMode) {
                metadata_top.setVisible = false
                return
            }

            if(PQCSettings.metadataElementFloating)
                return

            if(menu.item != null && menu.item.opened) {
                metadata_top.setVisible = true
                return
            }

            if(metadata_top.setVisible) {
                if(posx < metadata_top.x-50 || posx > metadata_top.x+metadata_top.width+50 || posy < metadata_top.y-50 || posy > metadata_top.y+metadata_top.height+50)
                    metadata_top.setVisible = false
            } else {
                if(metadata_top.hotArea.x <= posx && metadata_top.hotArea.x+metadata_top.hotArea.width > posx && metadata_top.hotArea.y < posy && metadata_top.hotArea.height+metadata_top.hotArea.y > posy)
                    metadata_top.setVisible = true
            }
        }

        function onMouseWindowExit() {
            hideElementWithDelay.restart()
        }

        function onMouseWindowEnter() {
            hideElementWithDelay.stop()
        }

    }

    Timer {
        id: resetIgnoreMouseMoveShortly
        interval: 250
        onTriggered: {
            metadata_top.ignoreMouseMoveShortly = false
        }
    }

    function hideMetaData() {
        if(popoutWindowUsed)
            metadata_popout.visible = false
        metadata_top.setVisible = false
    }

    function toggle() {
        metadata_top.setVisible = !metadata_top.setVisible
    }

}
