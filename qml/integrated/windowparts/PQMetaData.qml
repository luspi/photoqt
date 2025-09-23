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

import QtQuick
import QtQuick.Controls
import PQCImageFormats
import PhotoQt.CPlusPlus
import PhotoQt.Integrated

Rectangle {

    id: metadata_top

    width: PQCSettings.metadataSideBarWidth
    height: PQCConstants.availableHeight

    onWidthChanged: {
        PQCSettings.metadataSideBarWidth = width
    }

    SystemPalette { id: pqtPalette }
    SystemPalette { id: pqtPaletteDisabled; colorGroup: SystemPalette.Disabled }

    color: pqtPalette.window

    border.width: 1
    border.color: pqtPaletteDisabled.text

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

    PQTextXL {
        anchors.fill: parent
        anchors.margins: 10
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        text: qsTranslate("metadata", "No file loaded")
        font.bold: PQCLook.fontWeightBold
        enabled: false
        visible: PQCFileFolderModel.countMainView===0
    }

    Flickable {

        id: flickable

        anchors.fill: parent
        anchors.margins: 10

        contentHeight: flickable_col.height

        clip: true

        ScrollBar.vertical: PQVerticalScrollBar { id: scroll }

        Column {

            id: flickable_col

            width: parent.width

            spacing: 8

            Item {
                width: 1
                height: 20
            }

            PQTextXL {
                x: 5
                width: parent.width-10
                horizontalAlignment: Text.AlignHCenter
                font.weight: PQCLook.fontWeightBold
                elide: Text.ElideMiddle
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                visible: PQCFileFolderModel.currentFile!==""
                text: PQCScriptsFilesPaths.getFilename(PQCFileFolderModel.currentFile)
            }

            Item {
                width: 1
                height: 10
            }

            Rectangle {
                width: parent.width
                height: 1
                color: pqtPalette.text
                visible: PQCFileFolderModel.currentFile!==""
            }

            Item {
                width: 1
                height: 10
            }

            PQMetaDataEntry {
                //: Type here refers to the file type
                whichtxt: qsTranslate("metadata", "Type")
                property string mimeType: PQCScriptsFilesPaths.getFileType(PQCFileFolderModel.currentFile)
                property string mimeName: PQCScriptsImages.getNameFromMimetype(mimeType, PQCFileFolderModel.currentFile)
                valtxt: mimeName + " (" + mimeType + ")"
                prop: PQCSettings.metadataFileType
            }

            PQMetaDataEntry {
                //: Size here is the filesize (in KB or MB)
                whichtxt: qsTranslate("metadata", "Size")
                valtxt: PQCScriptsFilesPaths.getFileSizeHumanReadable(PQCFileFolderModel.currentFile)
                prop: PQCSettings.metadataFileSize
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Dimensions")
                valtxt: PQCFileFolderModel.countMainView>0 ? ("%1 x %2".arg(PQCConstants.currentImageResolution.width).arg(PQCConstants.currentImageResolution.height)) : ""
                prop: PQCSettings.metadataDimensions
            }

            PQMetaDataEntry {
                whichtxt: qsTranslate("metadata", "Image #")
                valtxt: PQCFileFolderModel.countMainView>0 ? (((PQCFileFolderModel.currentIndex+1)+" / "+PQCFileFolderModel.countMainView)) : ""
                prop: PQCSettings.metadataImageNumber
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

            Item {
                width: 1
                height: 1
            }

            PQMetaDataEntry {
                //: This refers to the time the file was created
                whichtxt: qsTranslate("metadata", "Created")
                valtxt: PQCMetaData.exifDateTimeOriginal
                prop: PQCSettings.metadataTime
            }

            PQMetaDataEntry {
                //: This refers to the time the file was last modified
                whichtxt: qsTranslate("metadata", "Last modified")
                valtxt: PQCMetaData.exifDateTimeOriginal
                prop: PQCSettings.metadataTime
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
                //: The location here is a location stored in the file meta information. This could be a GPS or a named location.
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

    PQMouseArea {
        enabled: PQCSettings.metadataSideBarLocation==="left"
        width: 10
        height: parent.height
        x: (parent.width-width/2)
        hoverEnabled: true
        cursorShape: Qt.SizeHorCursor
        property int origWidth: metadata_top.width
        property int pressStart
        onPressed: (mouse) => {
            pressStart = mouse.x
        }
        onMouseXChanged: {
            if(pressStart != -1) {
                var diff = mouseX-pressStart
                metadata_top.width = Math.round(Math.min(PQCConstants.availableWidth/2, Math.max(200, origWidth+diff)))
            }
        }
        onReleased: {
            pressStart = -1
        }
    }

    PQMouseArea {
        enabled: PQCSettings.metadataSideBarLocation==="right"
        width: 10
        height: parent.height
        x: -width/2
        hoverEnabled: true
        cursorShape: Qt.SizeHorCursor
        property int origWidth: metadata_top.width
        property int pressStart: -1
        onPressed: (mouse) => {
            pressStart = mouse.x
        }
        onMouseXChanged: {
            if(pressStart != -1) {
                var diff = pressStart-mouseX
                metadata_top.width = Math.round(Math.min(PQCConstants.availableWidth/2, Math.max(200, origWidth+diff)))
            }
        }
        onReleased: {
            pressStart = -1
        }
    }

}
