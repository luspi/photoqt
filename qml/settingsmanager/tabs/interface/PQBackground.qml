import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "../../../elements"

PQSetting {
    id: set
    title: "background"
    helptext: "What type of background is to be shown."
    content: [
        Flow {

            spacing: 10
            width: set.contwidth

            PQComboBox {
                id: bg_type
                model: [
                    "(half-)transparent background",
                    "faked transparency",
                    "custom background image"
                ]
            }

            Rectangle {
                id: bg_image
                y: (parent.height-height)/2
                visible: bg_type.currentIndex==2
                width: 50
                height: 35
                color: "#333333"
                border.width: 1
                border.color: "#888888"
                Image {
                    id: bg_image_img
                    anchors.fill: parent
                    anchors.margins: 1
                    fillMode: Image.PreserveAspectFit
                    sourceSize: Qt.size(width, height)
                    source: ""
                }

                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    tooltip: "Click to select an image"
                    onClicked: {
                        settingsmanager_top.modalWindowOpen = true
                        fileDialog.open()
                    }
                }
            }

            PQComboBox {
                id: bg_image_type
                visible: bg_type.currentIndex==2
                model: [
                    "scale to fit",
                    "scale and crop to fit",
                    "stretch to fit",
                    "center image",
                    "tile image"
                ]
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onCloseModalWindow: {
            fileDialog.close()
            settingsmanager_top.modalWindowOpen = false
        }

        onLoadAllSettings: {

            if(PQSettings.backgroundImageScreenshot)
                bg_type.currentIndex = 1
            else if(PQSettings.backgroundImageUse)
                bg_type.currentIndex = 2
            else
                bg_type.currentIndex = 0

            if(PQSettings.backgroundImagePath == "")
                bg_image_img.source = ""
            else
                bg_image_img.source = "image://full/" + PQSettings.backgroundImagePath

            if(PQSettings.backgroundImageScale)
                bg_image_type.currentIndex = 0
            else if(PQSettings.backgroundImageScaleCrop)
                bg_image_type.currentIndex = 1
            else if(PQSettings.backgroundImageStretch)
                bg_image_type.currentIndex = 2
            else if(PQSettings.backgroundImageCenter)
                bg_image_type.currentIndex = 3
            else if(PQSettings.backgroundImageTile)
                bg_image_type.currentIndex = 4
            else
                bg_image_type.currentIndex = 0

        }

        onSaveAllSettings: {

            if(bg_type.currentIndex == 0) {
                PQSettings.backgroundImageScreenshot = false
                PQSettings.backgroundImageUse = false
            } else if(bg_type.currentIndex == 1) {
                PQSettings.backgroundImageScreenshot = true
                PQSettings.backgroundImageUse = false
            } else if(bg_type.currentIndex == 2) {
                PQSettings.backgroundImageScreenshot = false
                PQSettings.backgroundImageUse = true
            }

            if(bg_type.currentIndex == 2)
                PQSettings.backgroundImagePath = handlingFileDialog.cleanPath(bg_image_img.source)
            else
                PQSettings.backgroundImagePath = ""

            if(bg_image_type.currentIndex == 0) {
                PQSettings.backgroundImageScale = true
                PQSettings.backgroundImageScaleCrop = false
                PQSettings.backgroundImageStretch = false
                PQSettings.backgroundImageCenter = false
                PQSettings.backgroundImageTile = false
            } else if(bg_image_type.currentIndex == 1) {
                PQSettings.backgroundImageScale = false
                PQSettings.backgroundImageScaleCrop = true
                PQSettings.backgroundImageStretch = false
                PQSettings.backgroundImageCenter = false
                PQSettings.backgroundImageTile = false
            } else if(bg_image_type.currentIndex == 2) {
                PQSettings.backgroundImageScale = false
                PQSettings.backgroundImageScaleCrop = false
                PQSettings.backgroundImageStretch = true
                PQSettings.backgroundImageCenter = false
                PQSettings.backgroundImageTile = false
            } else if(bg_image_type.currentIndex == 3) {
                PQSettings.backgroundImageScale = false
                PQSettings.backgroundImageScaleCrop = false
                PQSettings.backgroundImageStretch = false
                PQSettings.backgroundImageCenter = true
                PQSettings.backgroundImageTile = false
            } else if(bg_image_type.currentIndex == 4) {
                PQSettings.backgroundImageScale = false
                PQSettings.backgroundImageScaleCrop = false
                PQSettings.backgroundImageStretch = false
                PQSettings.backgroundImageCenter = false
                PQSettings.backgroundImageTile = true
            }

        }

    }

    FileDialog {
        id: fileDialog
        currentFile: (PQSettings.backgroundImagePath == "" ? "" : "file://"+PQSettings.backgroundImagePath)
        folder: (PQSettings.backgroundImagePath == "" ? "file://"+handlingFileDialog.getHomeDir() : "file://"+handlingGeneral.getFilePathFromFullPath(PQSettings.backgroundImagePath))
        modality: Qt.ApplicationModal
        Component.onCompleted: {
            var str = ["All Images (" + PQImageFormats.getAllEnabledFileFormats().join(" ") + ")"]
            str.push("Qt (" + PQImageFormats.getAvailableEndingsQt().join(" ") + ")")
            if(handlingGeneral.isGraphicsMagickSupportEnabled())
                str.push("GraphicsMagick (" + PQImageFormats.getAvailableEndingsGm().join(" ") + ")")
            if(handlingGeneral.isLibRawSupportEnabled())
                str.push("LibRaw (" + PQImageFormats.getAvailableEndingsRAW().join(" ") + ")")
            if(handlingGeneral.isDevILSupportEnabled())
                str.push("DevIL (" + PQImageFormats.getAvailableEndingsDevIL().join(" ") + ")")
            if(handlingGeneral.isFreeImageSupportEnabled())
                str.push("FreeImage (" + PQImageFormats.getAvailableEndingsFreeImage().join(" ") + ")")
            if(handlingGeneral.isPopplerSupportEnabled())
                str.push("Poppler (" + PQImageFormats.getAvailableEndingsPoppler().join(" ") + ")")
            str.push("Video (" + PQImageFormats.getAvailableEndingsVideo().join(" ") + ")")
            fileDialog.nameFilters = str
        }
        onAccepted: {
            bg_image_img.source = fileDialog.currentFile
        }
    }

}
