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
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "../../../elements"

PQSetting {
    id: set
    //: A settings title referring to the background of PhotoQt (behind any image/element)
    title: em.pty+qsTranslate("settingsmanager_interface", "background")
    //: The background here refers to the area behind the main image and any element in PhotoQt, the very back.
    helptext: em.pty+qsTranslate("settingsmanager_interface", "What type of background is to be shown.")
    content: [
        Flow {

            spacing: 10
            width: set.contwidth

            PQComboBox {
                id: bg_type
                model: [
                    //: How the background of PhotoQt should be
                    em.pty+qsTranslate("settingsmanager_interface", "(half-)transparent background"),
                    //: How the background of PhotoQt should be
                    em.pty+qsTranslate("settingsmanager_interface", "faked transparency"),
                    //: How the background of PhotoQt should be
                    em.pty+qsTranslate("settingsmanager_interface", "custom background image")
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
                    //: Tooltip for a mouse area, a click on which opens a file dialog for selecting an image
                    tooltip: em.pty+qsTranslate("settingsmanager_interface", "Click to select an image")
                    onClicked:
                        fileDialog.open()
                }
            }

            PQComboBox {
                id: bg_image_type
                visible: bg_type.currentIndex==2
                model: [
                    //: If an image is set as background of PhotoQt this is one way it can be handled.
                    em.pty+qsTranslate("settingsmanager_interface", "scale to fit"),
                    //: If an image is set as background of PhotoQt this is one way it can be handled.
                    em.pty+qsTranslate("settingsmanager_interface", "scale and crop to fit"),
                    //: If an image is set as background of PhotoQt this is one way it can be handled.
                    em.pty+qsTranslate("settingsmanager_interface", "stretch to fit"),
                    //: If an image is set as background of PhotoQt this is one way it can be handled.
                    em.pty+qsTranslate("settingsmanager_interface", "center image"),
                    //: If an image is set as background of PhotoQt this is one way it can be handled.
                    em.pty+qsTranslate("settingsmanager_interface", "tile image")
                ]
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onCloseModalWindow:
            fileDialog.close()

        onLoadAllSettings: {

            if(PQSettings.interfaceBackgroundImageScreenshot)
                bg_type.currentIndex = 1
            else if(PQSettings.interfaceBackgroundImageUse)
                bg_type.currentIndex = 2
            else
                bg_type.currentIndex = 0

            if(PQSettings.interfaceBackgroundImagePath == "")
                bg_image_img.source = ""
            else
                bg_image_img.source = "image://full/" + PQSettings.interfaceBackgroundImagePath

            if(PQSettings.interfaceBackgroundImageScale)
                bg_image_type.currentIndex = 0
            else if(PQSettings.interfaceBackgroundImageScaleCrop)
                bg_image_type.currentIndex = 1
            else if(PQSettings.interfaceBackgroundImageStretch)
                bg_image_type.currentIndex = 2
            else if(PQSettings.interfaceBackgroundImageCenter)
                bg_image_type.currentIndex = 3
            else if(PQSettings.interfaceBackgroundImageTile)
                bg_image_type.currentIndex = 4
            else
                bg_image_type.currentIndex = 0

        }

        onSaveAllSettings: {

            if(bg_type.currentIndex == 0) {
                PQSettings.interfaceBackgroundImageScreenshot = false
                PQSettings.interfaceBackgroundImageUse = false
            } else if(bg_type.currentIndex == 1) {
                PQSettings.interfaceBackgroundImageScreenshot = true
                PQSettings.interfaceBackgroundImageUse = false
            } else if(bg_type.currentIndex == 2) {
                PQSettings.interfaceBackgroundImageScreenshot = false
                PQSettings.interfaceBackgroundImageUse = true
            }

            if(bg_type.currentIndex == 2)
                PQSettings.interfaceBackgroundImagePath = handlingFileDir.cleanPath(bg_image_img.source)
            else
                PQSettings.interfaceBackgroundImagePath = ""

            if(bg_image_type.currentIndex == 0) {
                PQSettings.interfaceBackgroundImageScale = true
                PQSettings.interfaceBackgroundImageScaleCrop = false
                PQSettings.interfaceBackgroundImageStretch = false
                PQSettings.interfaceBackgroundImageCenter = false
                PQSettings.interfaceBackgroundImageTile = false
            } else if(bg_image_type.currentIndex == 1) {
                PQSettings.interfaceBackgroundImageScale = false
                PQSettings.interfaceBackgroundImageScaleCrop = true
                PQSettings.interfaceBackgroundImageStretch = false
                PQSettings.interfaceBackgroundImageCenter = false
                PQSettings.interfaceBackgroundImageTile = false
            } else if(bg_image_type.currentIndex == 2) {
                PQSettings.interfaceBackgroundImageScale = false
                PQSettings.interfaceBackgroundImageScaleCrop = false
                PQSettings.interfaceBackgroundImageStretch = true
                PQSettings.interfaceBackgroundImageCenter = false
                PQSettings.interfaceBackgroundImageTile = false
            } else if(bg_image_type.currentIndex == 3) {
                PQSettings.interfaceBackgroundImageScale = false
                PQSettings.interfaceBackgroundImageScaleCrop = false
                PQSettings.interfaceBackgroundImageStretch = false
                PQSettings.interfaceBackgroundImageCenter = true
                PQSettings.interfaceBackgroundImageTile = false
            } else if(bg_image_type.currentIndex == 4) {
                PQSettings.interfaceBackgroundImageScale = false
                PQSettings.interfaceBackgroundImageScaleCrop = false
                PQSettings.interfaceBackgroundImageStretch = false
                PQSettings.interfaceBackgroundImageCenter = false
                PQSettings.interfaceBackgroundImageTile = true
            }

        }

    }

    FileDialog {
        id: fileDialog
        currentFile: (PQSettings.interfaceBackgroundImagePath == "" ? "" : "file://"+PQSettings.interfaceBackgroundImagePath)
        folder: (PQSettings.interfaceBackgroundImagePath == "" ? "file://"+handlingFileDir.getHomeDir() : "file://"+handlingFileDir.getFilePathFromFullPath(PQSettings.interfaceBackgroundImagePath))
        modality: Qt.ApplicationModal
        Component.onCompleted: {
            //: This is a category in a file dialog for selecting images used as in: All images supported by PhotoQt.
            var str = [em.pty+qsTranslate("settingsmanager_interface", "All Images") + " (*." + PQImageFormats.getEnabledFormats().join(" *.") + ")"]
            str.push("Qt (*." + PQImageFormats.getEnabledFormatsQt().join(" *.") + ")")
            if(handlingGeneral.isImageMagickSupportEnabled())
                str.push("ImageMagick (*." + PQImageFormats.getEnabledFormatsMagick().join(" *.") + ")")
            if(handlingGeneral.isGraphicsMagickSupportEnabled())
                str.push("GraphicsMagick (*." + PQImageFormats.getEnabledFormatsMagick().join(" *.") + ")")
            if(handlingGeneral.isLibRawSupportEnabled())
                str.push("LibRaw (*." + PQImageFormats.getEnabledFormatsLibRaw().join(" *.") + ")")
            if(handlingGeneral.isDevILSupportEnabled())
                str.push("DevIL (*." + PQImageFormats.getEnabledFormatsDevIL().join(" *.") + ")")
            if(handlingGeneral.isFreeImageSupportEnabled())
                str.push("FreeImage (*." + PQImageFormats.getEnabledFormatsFreeImage().join(" *.") + ")")
            if(handlingGeneral.isPopplerSupportEnabled())
                str.push("Poppler (*." + PQImageFormats.getEnabledFormatsPoppler().join(" *.") + ")")
            //: This is a category in a file dialog for selecting images used as in: Video files supported by PhotoQt.
            str.push(em.pty+qsTranslate("settingsmanager_interface", "Video") + " (*." + PQImageFormats.getEnabledFormatsVideo().join(" *.") + ")")
            fileDialog.nameFilters = str
        }
        onAccepted: {
            bg_image_img.source = "image://thumb/" + handlingFileDir.cleanPath(fileDialog.currentFile)
        }
        onVisibleChanged:
            settingsmanager_top.modalWindowOpen = visible
    }

}
