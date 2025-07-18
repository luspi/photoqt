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
import PhotoQt

Loader {

    id: loadertop

    signal popup(var pos)
    signal dismiss()

    property bool opened: false

    sourceComponent:
    PQMenu {

        id: menutop

        Item {

            id: cont

            property list<string> availableColorProfiles: []

            property var customentries: PQCScriptsContextMenu.getEntries() // qmllint disable unqualified

        }

        PQMenuItem {
            id: renitem
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/rename.svg" // qmllint disable unqualified
            text: qsTranslate("contextmenu", "Rename file")
            onTriggered:
                PQCScriptsShortcuts.executeInternalCommand("__rename") // qmllint disable unqualified
        }

        PQMenuItem {
            id: copitem
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/copy.svg" // qmllint disable unqualified
            text: qsTranslate("contextmenu", "Copy file")
            onTriggered:
                PQCScriptsShortcuts.executeInternalCommand("__copy") // qmllint disable unqualified
        }

        PQMenuItem {
            id: movitem
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/move.svg" // qmllint disable unqualified
            text: qsTranslate("contextmenu", "Move file")
            onTriggered:
                PQCScriptsShortcuts.executeInternalCommand("__move") // qmllint disable unqualified
        }

        PQMenuItem {
            id: delitem
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/delete.svg" // qmllint disable unqualified
            text: qsTranslate("contextmenu", "Delete file")
            onTriggered:
                PQCScriptsShortcuts.executeInternalCommand("__deleteTrash") // qmllint disable unqualified
        }

        PQMenuSeparator {}

        PQMenu {

            id: manimenu

            title: qsTranslate("contextmenu", "Manipulate image")

            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/scale.svg" // qmllint disable unqualified
                text: qsTranslate("contextmenu", "Scale image")
                enabled: !PQCConstants.showingPhotoSphere // qmllint disable unqualified
                onTriggered:
                    PQCScriptsShortcuts.executeInternalCommand("__scale") // qmllint disable unqualified
            }

            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/crop.svg" // qmllint disable unqualified
                text: qsTranslate("contextmenu", "Crop image")
                enabled: !PQCConstants.showingPhotoSphere // qmllint disable unqualified
                onTriggered:
                    PQCScriptsShortcuts.executeInternalCommand("__crop") // qmllint disable unqualified
            }

            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/faces.svg" // qmllint disable unqualified
                text: qsTranslate("contextmenu", "Tag faces")
                enabled: !PQCConstants.showingPhotoSphere // qmllint disable unqualified
                onTriggered:
                    PQCScriptsShortcuts.executeInternalCommand("__tagFaces") // qmllint disable unqualified
            }

        }

        PQMenu {

            id: usemenu

            title: qsTranslate("contextmenu", "Use image")

            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/clipboard.svg" // qmllint disable unqualified
                text: qsTranslate("contextmenu", "Copy to clipboard")
                onTriggered: {
                    PQCScriptsShortcuts.executeInternalCommand("__clipboard") // qmllint disable unqualified
                }
            }

            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/convert.svg" // qmllint disable unqualified
                text: qsTranslate("contextmenu", "Export to different format")
                enabled: !PQCConstants.showingPhotoSphere // qmllint disable unqualified
                onTriggered:
                    PQCScriptsShortcuts.executeInternalCommand("__export") // qmllint disable unqualified
            }

            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/wallpaper.svg" // qmllint disable unqualified
                text: qsTranslate("contextmenu", "Set as wallpaper")
                enabled: !PQCConstants.showingPhotoSphere // qmllint disable unqualified
                onTriggered:
                    PQCScriptsShortcuts.executeInternalCommand("__wallpaper") // qmllint disable unqualified
            }

            Repeater {
                model: PQCScriptsConfig.isZXingSupportEnabled() ? 1 : 0 // qmllint disable unqualified
                PQMenuItem {
                    iconSource: "image://svg/:/" + PQCLook.iconShade + "/qrcode.svg" // qmllint disable unqualified
                    text: PQCConstants.barcodeDisplayed ? qsTranslate("contextmenu", "Hide QR/barcodes") : qsTranslate("contextmenu", "Detect QR/barcodes") // qmllint disable unqualified
                    onTriggered:
                        PQCScriptsShortcuts.executeInternalCommand("__detectBarCodes") // qmllint disable unqualified
                }
            }

        }

        PQMenu {

            id: aboutmenu

            title: qsTranslate("contextmenu", "About image")

            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/histogram.svg" // qmllint disable unqualified
                text: qsTranslate("contextmenu", "Show histogram")
                onTriggered:
                    PQCScriptsShortcuts.executeInternalCommand("__histogram") // qmllint disable unqualified
            }

            Repeater {
                model: PQCScriptsConfig.isLocationSupportEnabled() ? 1 : 0 // qmllint disable unqualified
                PQMenuItem {
                    iconSource: "image://svg/:/" + PQCLook.iconShade + "/mapmarker.svg" // qmllint disable unqualified
                    text: qsTranslate("contextmenu", "Show on map")
                    onTriggered:
                        PQCScriptsShortcuts.executeInternalCommand("__showMapCurrent") // qmllint disable unqualified
                }
            }

        }

        // We need to hide this behind an instantiator in order to dynamically add/remove this submenu
        // on some systems/Qt versions not doing it this way results in an emptyspace in the place of the menu item
        Instantiator {
            id: iccloader

            model: PQCSettings.imageviewColorSpaceEnable ? 1 : 0

            PQMenu {
                id: iccmenu
                enabled: menutop.currentFileSupportsColorSpaces
                title: qsTranslate("contextmenu", "Select color profile")
                onAboutToShow: {
                    cont.availableColorProfiles = PQCScriptsColorProfiles.getColorProfileDescriptions() // qmllint disable unqualified
                }
                PQMenuItem {
                    text: qsTranslate("contextmenu", "Default color profile")
                    font.bold: true
                    onTriggered: {
                        PQCScriptsColorProfiles.setColorProfile(PQCFileFolderModel.currentFile, -1) // qmllint disable unqualified
                        PQCNotifyQML.currentImageReload()
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
                        visible: PQCSettings.imageviewColorSpaceContextMenu.indexOf(PQCScriptsColorProfiles.getColorProfileID(modelData))>-1 // qmllint disable unqualified
                        height: visible ? 40 : 0
                        onTriggered: {
                            PQCScriptsColorProfiles.setColorProfile(PQCFileFolderModel.currentFile, deleg.modelData) // qmllint disable unqualified
                            PQCNotifyQML.currentImageReload()
                            PQCFileFolderModel.currentFileChanged()
                        }
                    }
                }

            }

            // add/remove item into/from the correct position in the global menu
            onObjectAdded: (index, object) => {
                menutop.insertMenu(9, object)
            }
            onObjectRemoved: (index, object) => {
                menutop.removeMenu(object)
            }

        }

        PQMenuSeparator { }

        PQMenu {

            title: qsTranslate("contextmenu", "Manage PhotoQt")

            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/browse.svg" // qmllint disable unqualified
                text: qsTranslate("contextmenu", "Browse images")
                onTriggered:
                    PQCScriptsShortcuts.executeInternalCommand("__open") // qmllint disable unqualified
            }

            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/mapmarker.svg" // qmllint disable unqualified
                text: qsTranslate("contextmenu", "Map Explorer")
                onTriggered:
                    PQCScriptsShortcuts.executeInternalCommand("__showMapExplorer") // qmllint disable unqualified
            }

            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/settings.svg" // qmllint disable unqualified
                text: qsTranslate("contextmenu", "Open settings manager")
                onTriggered:
                    PQCScriptsShortcuts.executeInternalCommand("__settings") // qmllint disable unqualified
            }

            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/quit.svg" // qmllint disable unqualified
                text: qsTranslate("contextmenu", "Quit")
                onTriggered:
                    PQCScriptsShortcuts.executeInternalCommand("__quit") // qmllint disable unqualified
            }
        }

        PQMenuSeparator { visible: cont.customentries.length>0 }

        Repeater {

            model: cont.customentries.length

            PQMenuItem {
                required property int modelData
                height: 40
                parent: renitem.parent
                // This needs to be a var and not a list<var> otherwise the entries will not load
                property var entry: cont.customentries[modelData]
                iconSource: entry[0]==="" ? ("image://svg/:/" + PQCLook.iconShade + "/application.svg") : ("data:image/png;base64," + entry[0]) // qmllint disable unqualified
                text: entry[2]+""
                onTriggered: {
                    if(entry[1].startsWith("__"))
                        PQCScriptsShortcuts.executeInternalCommand(entry[1])
                    else
                        PQCScriptsShortcuts.executeExternal(entry[1], entry[4], PQCFileFolderModel.currentFile)
                }
            }
        }

        onAboutToHide: {
            recordAsClosed.restart()
            loadertop.opened = false
        }
        onAboutToShow: {
            PQCConstants.addToWhichContextMenusOpen("globalcontextmenu")
            loadertop.opened = true
        }

        Timer {
            id: recordAsClosed
            interval: 200
            onTriggered: {
                if(!menutop.visible)
                    PQCConstants.removeFromWhichContextMenusOpen("globalcontextmenu")
            }
        }

        property bool currentFileSupportsColorSpaces: false
        Timer {
            id: evaluateEnabledStatus
            interval: 200
            running: true   // this makes sure the status is evaluated at startup
            onTriggered: {

                renitem.enabled = (PQCFileFolderModel.currentFile !== "")
                copitem.enabled = (PQCFileFolderModel.currentFile !== "")
                movitem.enabled = (PQCFileFolderModel.currentFile !== "")
                delitem.enabled = (PQCFileFolderModel.currentFile !== "")

                manimenu.enabled = (PQCFileFolderModel.currentFile !== "")
                usemenu.enabled = (PQCFileFolderModel.currentFile !== "")
                aboutmenu.enabled = (PQCFileFolderModel.currentFile !== "")

                // color spaces submenu
                if(PQCSettings.imageviewColorSpaceEnable)
                    menutop.currentFileSupportsColorSpaces =
                                      (PQCFileFolderModel.currentFile !== "" &&
                                       !PQCScriptsImages.isItAnimated(PQCFileFolderModel.currentFile) &&
                                       !PQCScriptsImages.isQtVideo(PQCFileFolderModel.currentFile) &&
                                       !PQCScriptsImages.isMpvVideo(PQCFileFolderModel.currentFile) &&
                                       !PQCConstants.showingPhotoSphere)
            }
        }

        Connections {
            target: PQCFileFolderModel
            function onCurrentFileChanged() {
                evaluateEnabledStatus.restart()
            }
        }

        Connections {
            target: PQCNotifyQML
            function onCloseAllContextMenus() {
                menutop.dismiss()
            }
        }

        Connections {
            target: loadertop
            function onPopup(pos) {
                menutop.popup(pos)
            }
            function onDismiss() {
                menutop.dismiss()
            }
        }

    }

    Connections {

        target: PQCScriptsContextMenu

        // we set up the contextmenu fresh when the custom entries changed
        // this is necessary as otherwise a change in the custom entries might make them
        // show up in random positions until PhotoQt is restarted.
        function onCustomEntriesChanged() {
            loadertop.active = false
            PQCConstants.removeFromWhichContextMenusOpen("globalcontextmenu")
            loadertop.active = true
        }
    }

    Connections {
        target: PQCScriptsShortcuts

        function onSendShortcutDismissGlobalContextMenu() {
            loadertop.dismiss()
        }

        function onSendShortcutShowGlobalContextMenuAt(pos : point) {
            if(pos.x === -1 || pos.y === -1)
                loadertop.popup(undefined)
            else
                loadertop.popup(pos)
        }
    }

    Connections {

        target: PQCSettings

        function onImageviewColorSpaceEnableChanged() {
            loadertop.active = false
            PQCConstants.removeFromWhichContextMenusOpen("globalcontextmenu")
            loadertop.active = true
        }

    }

}
