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

import PQCNotify
import PQCScriptsShortcuts
import PQCFileFolderModel
import PQCScriptsContextMenu
import PQCScriptsConfig
import PQCScriptsImages

import "../elements"

PQMenu {

    id: menutop

    PQMenuItem {
        iconSource: "image://svg/:/white/rename.svg"
        text: qsTranslate("contextmenu", "Rename file")
        onTriggered:
            PQCNotify.executeInternalCommand("__rename")
    }

    PQMenuItem {
        iconSource: "image://svg/:/white/copy.svg"
        text: qsTranslate("contextmenu", "Copy file")
        onTriggered:
            PQCNotify.executeInternalCommand("__copy")
    }

    PQMenuItem {
        iconSource: "image://svg/:/white/move.svg"
        text: qsTranslate("contextmenu", "Move file")
        onTriggered:
            PQCNotify.executeInternalCommand("__move")
    }

    PQMenuItem {
        iconSource: "image://svg/:/white/delete.svg"
        text: qsTranslate("contextmenu", "Delete file")
        onTriggered:
            PQCNotify.executeInternalCommand("__deleteTrash")
    }

    PQMenuSeparator {}

    PQMenuItem {
        iconSource: "image://svg/:/white/clipboard.svg"
        text: qsTranslate("contextmenu", "Copy to clipboard")
        onTriggered: {
            PQCNotify.executeInternalCommand("__clipboard")
        }
    }

    PQMenuItem {
        iconSource: "image://svg/:/white/convert.svg"
        text: qsTranslate("contextmenu", "Export to different format")
        onTriggered:
            PQCNotify.executeInternalCommand("__export")
    }

    PQMenuItem {
        iconSource: "image://svg/:/white/scale.svg"
        text: qsTranslate("contextmenu", "Scale image")
        onTriggered:
            PQCNotify.executeInternalCommand("__scale")
    }

    PQMenuItem {
        iconSource: "image://svg/:/white/faces.svg"
        text: qsTranslate("contextmenu", "Tag faces")
        onTriggered:
            PQCNotify.executeInternalCommand("__tagFaces")
    }

    PQMenuItem {
        iconSource: "image://svg/:/white/wallpaper.svg"
        text: qsTranslate("contextmenu", "Set as wallpaper")
        onTriggered:
            PQCNotify.executeInternalCommand("__wallpaper")
    }

    PQMenuSeparator {}

    PQMenu {
        id: iccmenu
        title: qsTranslate("contextmenu", "Select color profile")
        property var availableColorProfiles: []
        onAboutToShow: {
            availableColorProfiles = PQCScriptsImages.getColorProfileDescriptions()
        }
        PQMenuItem {
            text: "Default color profile"
            font.bold: true
            onTriggered: {
                PQCScriptsImages.setColorProfile(PQCFileFolderModel.currentFile, -1)
                image.reloadImage()
                PQCFileFolderModel.currentFileChanged()
            }
        }

        PQMenuSeparator {}

        Repeater{
            model: iccmenu.availableColorProfiles.length
            PQMenuItem {
                text: iccmenu.availableColorProfiles[index]
                visible: PQCSettings.imageviewColorSpaceContextMenu.indexOf(PQCScriptsImages.getColorProfileID(index))>-1
                onTriggered: {
                    PQCScriptsImages.setColorProfile(PQCFileFolderModel.currentFile, index)
                    image.reloadImage()
                    PQCFileFolderModel.currentFileChanged()
                }
            }
        }
        Connections {
            target: PQCFileFolderModel
            function onCurrentFileChanged() {
                evaluateEnabledStatus.restart()
            }
        }

        Timer {
            id: evaluateEnabledStatus
            interval: 200
            running: true   // this makes sure the status is evaluated at startup
            onTriggered: {
                if(PQCSettings.imageviewColorSpaceEnable)
                    iccmenu.enabled = (PQCFileFolderModel.currentFile !== "" &&
                                       !PQCScriptsImages.isItAnimated(PQCFileFolderModel.currentFile) &&
                                       !PQCScriptsImages.isQtVideo(PQCFileFolderModel.currentFile) &&
                                       !PQCScriptsImages.isMpvVideo(PQCFileFolderModel.currentFile))
            }
        }

        Component.onCompleted: {
            // we need to change the visibility of the parent of the menu as that is the respective menuitem
            parent.visible = PQCSettings.imageviewColorSpaceEnable
        }

    }

    PQMenuItem {
        iconSource: "image://svg/:/white/histogram.svg"
        text: qsTranslate("contextmenu", "Show histogram")
        onTriggered:
            PQCNotify.executeInternalCommand("__histogram")
    }

    Repeater {
        model: PQCScriptsConfig.isLocationSupportEnabled() ? 1 : 0
        PQMenuItem {
            iconSource: "image://svg/:/white/mapmarker.svg"
            text: qsTranslate("contextmenu", "Show on map")
            onTriggered:
                PQCNotify.executeInternalCommand("__showMapCurrent")
        }
    }

    Repeater {
        model: PQCScriptsConfig.isZXingSupportEnabled() ? 1 : 0
        PQMenuItem {
            iconSource: "image://svg/:/white/qrcode.svg"
            text: PQCNotify.barcodeDisplayed ? qsTranslate("contextmenu", "Hide QR/barcodes") : qsTranslate("contextmenu", "Detect QR/barcodes")
            onTriggered:
                PQCNotify.executeInternalCommand("__detectBarCodes")
        }
    }

    PQMenuSeparator { visible: customentries.length>0 }

    property var customentries: PQCScriptsContextMenu.getEntries()

    Repeater {

        model: customentries.length

        PQMenuItem {
            property var entry: customentries[index]
            iconSource: entry[0]==="" ? "image://svg/:/white/application.svg" : ("data:image/png;base64," + entry[0])
            text: entry[2]
            onTriggered: {
                if(entry[1].startsWith("__"))
                    PQCNotify.executeInternalCommand(entry[1])
                else
                    PQCScriptsShortcuts.executeExternal(entry[1], entry[4], PQCFileFolderModel.currentFile)
            }
        }

    }

    onAboutToHide:
        recordAsClosed.restart()
    onAboutToShow:
        PQCNotify.addToWhichContextMenusOpen("contextmenu")

    Timer {
        id: recordAsClosed
        interval: 200
        onTriggered:
            PQCNotify.removeFromWhichContextMenusOpen("contextmenu")
    }

    Connections {
        target: PQCScriptsContextMenu
        function onCustomEntriesChanged() {
            customentries = PQCScriptsContextMenu.getEntries()
        }
    }

    Connections {
        target: PQCNotify
        function onCloseAllContextMenus() {
            menutop.dismiss()
        }
    }

}
