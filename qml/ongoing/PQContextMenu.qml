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

import PQCNotify
import PQCScriptsShortcuts
import PQCFileFolderModel
import PQCScriptsContextMenu
import PQCScriptsConfig
import PQCScriptsImages

import "../elements"

PQMenu {

    id: menutop

    Item {

        id: cont

        property list<string> availableColorProfiles: []

        property var customentries: PQCScriptsContextMenu.getEntries() // qmllint disable unqualified

    }

    PQMenuItem {
        iconSource: "image://svg/:/" + PQCLook.iconShade + "/rename.svg" // qmllint disable unqualified
        text: qsTranslate("contextmenu", "Rename file")
        onTriggered:
            PQCNotify.executeInternalCommand("__rename") // qmllint disable unqualified
    }

    PQMenuItem {
        iconSource: "image://svg/:/" + PQCLook.iconShade + "/copy.svg" // qmllint disable unqualified
        text: qsTranslate("contextmenu", "Copy file")
        onTriggered:
            PQCNotify.executeInternalCommand("__copy") // qmllint disable unqualified
    }

    PQMenuItem {
        iconSource: "image://svg/:/" + PQCLook.iconShade + "/move.svg" // qmllint disable unqualified
        text: qsTranslate("contextmenu", "Move file")
        onTriggered:
            PQCNotify.executeInternalCommand("__move") // qmllint disable unqualified
    }

    PQMenuItem {
        iconSource: "image://svg/:/" + PQCLook.iconShade + "/delete.svg" // qmllint disable unqualified
        text: qsTranslate("contextmenu", "Delete file")
        onTriggered:
            PQCNotify.executeInternalCommand("__deleteTrash") // qmllint disable unqualified
    }

    PQMenuSeparator {}

    PQMenu {

        title: qsTranslate("contextmenu", "Manipulate image")

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/scale.svg" // qmllint disable unqualified
            text: qsTranslate("contextmenu", "Scale image")
            enabled: !PQCNotify.showingPhotoSphere // qmllint disable unqualified
            onTriggered:
                PQCNotify.executeInternalCommand("__scale") // qmllint disable unqualified
        }

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/crop.svg" // qmllint disable unqualified
            text: qsTranslate("contextmenu", "Crop image")
            enabled: !PQCNotify.showingPhotoSphere // qmllint disable unqualified
            onTriggered:
                PQCNotify.executeInternalCommand("__crop") // qmllint disable unqualified
        }

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/faces.svg" // qmllint disable unqualified
            text: qsTranslate("contextmenu", "Tag faces")
            enabled: !PQCNotify.showingPhotoSphere // qmllint disable unqualified
            onTriggered:
                PQCNotify.executeInternalCommand("__tagFaces") // qmllint disable unqualified
        }

    }

    PQMenuItem {
        iconSource: "image://svg/:/" + PQCLook.iconShade + "/clipboard.svg" // qmllint disable unqualified
        text: qsTranslate("contextmenu", "Copy to clipboard")
        onTriggered: {
            PQCNotify.executeInternalCommand("__clipboard") // qmllint disable unqualified
        }
    }

    PQMenuItem {
        iconSource: "image://svg/:/" + PQCLook.iconShade + "/convert.svg" // qmllint disable unqualified
        text: qsTranslate("contextmenu", "Export to different format")
        enabled: !PQCNotify.showingPhotoSphere // qmllint disable unqualified
        onTriggered:
            PQCNotify.executeInternalCommand("__export") // qmllint disable unqualified
    }

    PQMenuItem {
        iconSource: "image://svg/:/" + PQCLook.iconShade + "/wallpaper.svg" // qmllint disable unqualified
        text: qsTranslate("contextmenu", "Set as wallpaper")
        enabled: !PQCNotify.showingPhotoSphere // qmllint disable unqualified
        onTriggered:
            PQCNotify.executeInternalCommand("__wallpaper") // qmllint disable unqualified
    }

    PQMenuSeparator {}

    PQMenu {
        id: iccmenu
        title: qsTranslate("contextmenu", "Select color profile")
        onAboutToShow: {
            cont.availableColorProfiles = PQCScriptsImages.getColorProfileDescriptions() // qmllint disable unqualified
        }
        PQMenuItem {
            text: qsTranslate("contextmenu", "Default color profile")
            font.bold: true
            onTriggered: {
                PQCScriptsImages.setColorProfile(PQCFileFolderModel.currentFile, -1) // qmllint disable unqualified
                image.reloadImage()
                PQCFileFolderModel.currentFileChanged()
            }
        }

        PQMenuSeparator {}

        Repeater{
            model: cont.availableColorProfiles.length
            PQMenuItem {
                id: deleg
                required property int modelData
                text: cont.availableColorProfiles[modelData]
                visible: PQCSettings.imageviewColorSpaceContextMenu.indexOf(PQCScriptsImages.getColorProfileID(modelData))>-1 // qmllint disable unqualified
                height: visible ? 40 : 0
                onTriggered: {
                    PQCScriptsImages.setColorProfile(PQCFileFolderModel.currentFile, deleg.modelData) // qmllint disable unqualified
                    image.reloadImage()
                    PQCFileFolderModel.currentFileChanged()
                }
            }
        }
        Connections {
            target: PQCFileFolderModel // qmllint disable unqualified
            function onCurrentFileChanged() {
                evaluateEnabledStatus.restart()
            }
        }

        Timer {
            id: evaluateEnabledStatus
            interval: 200
            running: true   // this makes sure the status is evaluated at startup
            onTriggered: {
                if(PQCSettings.imageviewColorSpaceEnable) // qmllint disable unqualified
                    iccmenu.enabled = (PQCFileFolderModel.currentFile !== "" &&
                                       !PQCScriptsImages.isItAnimated(PQCFileFolderModel.currentFile) &&
                                       !PQCScriptsImages.isQtVideo(PQCFileFolderModel.currentFile) &&
                                       !PQCScriptsImages.isMpvVideo(PQCFileFolderModel.currentFile) &&
                                       !PQCNotify.showingPhotoSphere)
            }
        }

        Component.onCompleted: {
            // we need to change the visibility of the parent of the menu as that is the respective menuitem
            parent.visible = PQCSettings.imageviewColorSpaceEnable // qmllint disable unqualified
        }

    }

    PQMenuItem {
        iconSource: "image://svg/:/" + PQCLook.iconShade + "/histogram.svg" // qmllint disable unqualified
        text: qsTranslate("contextmenu", "Show histogram")
        onTriggered:
            PQCNotify.executeInternalCommand("__histogram") // qmllint disable unqualified
    }

    Repeater {
        model: PQCScriptsConfig.isLocationSupportEnabled() ? 1 : 0 // qmllint disable unqualified
        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/mapmarker.svg" // qmllint disable unqualified
            text: qsTranslate("contextmenu", "Show on map")
            onTriggered:
                PQCNotify.executeInternalCommand("__showMapCurrent") // qmllint disable unqualified
        }
    }

    Repeater {
        model: PQCScriptsConfig.isZXingSupportEnabled() ? 1 : 0 // qmllint disable unqualified
        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/qrcode.svg" // qmllint disable unqualified
            text: PQCNotify.barcodeDisplayed ? qsTranslate("contextmenu", "Hide QR/barcodes") : qsTranslate("contextmenu", "Detect QR/barcodes") // qmllint disable unqualified
            onTriggered:
                PQCNotify.executeInternalCommand("__detectBarCodes") // qmllint disable unqualified
        }
    }

    PQMenuSeparator { visible: cont.customentries.length>0 }

    Repeater {

        model: cont.customentries.length

        PQMenuItem {
            required property int modelData
            property list<var> entry: cont.customentries[modelData]
            iconSource: entry[0]==="" ? ("image://svg/:/" + PQCLook.iconShade + "/application.svg") : ("data:image/png;base64," + entry[0]) // qmllint disable unqualified
            text: entry[2]+""
            onTriggered: {
                if(entry[1].startsWith("__"))
                    PQCNotify.executeInternalCommand(entry[1]) // qmllint disable unqualified
                else
                    PQCScriptsShortcuts.executeExternal(entry[1], entry[4], PQCFileFolderModel.currentFile)
            }
        }

    }

    onAboutToHide:
        recordAsClosed.restart()
    onAboutToShow:
        PQCNotify.addToWhichContextMenusOpen("contextmenu") // qmllint disable unqualified

    Timer {
        id: recordAsClosed
        interval: 200
        onTriggered:
            PQCNotify.removeFromWhichContextMenusOpen("contextmenu") // qmllint disable unqualified
    }

    Connections {
        target: PQCScriptsContextMenu // qmllint disable unqualified
        function onCustomEntriesChanged() {
            cont.customentries = PQCScriptsContextMenu.getEntries() // qmllint disable unqualified
        }
    }

    Connections {
        target: PQCNotify // qmllint disable unqualified
        function onCloseAllContextMenus() {
            menutop.dismiss()
        }
    }

}
