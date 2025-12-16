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
import PhotoQt
import PQCExtensionsHandler
import "../PQCommonFunctions.js" as PQF

MenuBar {

    id: menu_top

    onHeightChanged:
        PQCConstants.menuBarHeight = height

    delegate: MenuBarItem {

        id: menuBarItem

        contentItem: Text {
            property string plainTxt: menuBarItem.text.replace("&","")
            property string modTxt: PQF.parseMenuString(menuBarItem.text)
            text: PQCConstants.altKeyPressed ? modTxt : plainTxt
            font: menuBarItem.font
            opacity: enabled ? 1.0 : 0.3
            color: palette.text
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            implicitWidth: 20
            implicitHeight: 20
            opacity: enabled ? 0.8 : 0.3
            color: menuBarItem.highlighted ? palette.highlight : palette.window
        }
    }

    background: Rectangle {
        implicitWidth: 40
        implicitHeight: 20
        color: palette.window
    }

    PQMenu {

        id: menu_file

        title: qsTranslate("other", "&File")

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/browse.svg"
            text: qsTranslate("other", "&Open (browse images)")
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__open")
            }
        }

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/settings.svg"
            text: qsTranslate("other", "&Settings manager")
            enabled: PQCConstants.idOfVisibleItem===""
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__settings")
            }
        }

        PQMenuSeparator {}

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/quit.svg"
            text: qsTranslate("other", "&Quit")
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__quit")
            }
        }

    }

    PQMenu {

        id: menu_navigation

        title: qsTranslate("other", "&Navigation")
        enabled: PQCConstants.idOfVisibleItem===""

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/next.svg"
            text: qsTranslate("other", "&Next")
            enabled: PQCFileFolderModel.countMainView>0
            MouseArea{
                anchors.fill: parent
                onClicked:
                    PQCScriptsShortcuts.executeInternalCommand("__next")
            }
        }

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/previous.svg"
            text: qsTranslate("other", "&Previous")
            enabled: PQCFileFolderModel.countMainView>0
            MouseArea{
                anchors.fill: parent
                onClicked:
                    PQCScriptsShortcuts.executeInternalCommand("__prev")
            }
        }

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/last.svg"
            text: qsTranslate("other", "&Last")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__goToLast")
            }
        }

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/first.svg"
            text: qsTranslate("other", "&First")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__goToFirst")
            }
        }

        PQMenuSeparator {}

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/browse.svg"
            text: qsTranslate("other", "&Open (browse images)")
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__open")
            }
        }

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/mapmarker.svg"
            text: qsTranslate("other", "&Map explorer")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__showMapExplorer")
            }
        }

    }

    PQMenu {

        id: menu_image

        title: qsTranslate("other", "&Image")
        enabled: PQCConstants.idOfVisibleItem===""

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/rename.svg"
            text: qsTranslate("other", "&Rename")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__rename")
            }
        }

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/copy.svg"
            text: qsTranslate("other", "&Copy")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__copy")
            }
        }

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/move.svg"
            text: qsTranslate("other", "&Move")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__move")
            }
        }

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/delete.svg"
            text: qsTranslate("other", "&Delete")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__delete")
            }
        }

        PQMenuSeparator {}

        PQMenu {
            title: qsTranslate("other", "&Zoom")
            enabled: PQCFileFolderModel.countMainView>0
            PQMenuItem {
                id: zoomin
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/zoomin.svg"
                text: qsTranslate("other", "&In")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__zoomIn")
                }
            }
            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/zoomout.svg"
                text: qsTranslate("other", "&Out")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__zoomOut")
                }
            }
            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/actualsize.svg"
                text: qsTranslate("other", "&100%")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__zoomActual")
                }
            }
            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/reset.svg"
                text: qsTranslate("other", "&Reset")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__zoomReset")
                }
            }
        }

        PQMenu {
            title: qsTranslate("other", "&Rotate")
            enabled: PQCFileFolderModel.countMainView>0
            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/rotateright.svg"
                text: qsTranslate("other", "90° &clockwise")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__rotateR")
                }
            }
            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/rotateleft.svg"
                text: qsTranslate("other", "90° &anticlockwise")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__rotateL")
                }
            }
            // MenuItem {
            //     text: qsTranslate("other", "&180°")
            //     onTriggered: {
            //         PQCScriptsShortcuts.executeInternalCommand("")
            //     }
            // }
            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/reset.svg"
                text: qsTranslate("other", "&Reset")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__rotate0")
                }
            }
        }

        PQMenu {
            title: qsTranslate("other", "&Mirror")
            enabled: PQCFileFolderModel.countMainView>0
            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/leftrightarrow.svg"
                text: qsTranslate("other", "Horizontal")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__flipH")
                }
            }
            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/updownarrow.svg"
                text: qsTranslate("other", "Vertical")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__flipV")
                }
            }
            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/reset.svg"
                text: qsTranslate("other", "Reset")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__flipReset")
                }
            }
        }

        PQMenuSeparator {}

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/faces.svg"
            text: qsTranslate("other", "&Tag faces")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__tagFaces")
            }
        }

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/clipboard.svg"
            text: qsTranslate("other", "&Copy to clipboard")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__clipboard")
            }
        }

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/qrcode.svg"
            text: qsTranslate("other", "&Detect QR/barcodes")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__detectBarCodes")
            }
        }

    }

    PQMenu {

        id: menu_folder

        title: qsTranslate("other", "&Folder")
        enabled: PQCConstants.idOfVisibleItem===""

        PQMenu {

            title: "Slideshow"
            enabled: PQCFileFolderModel.countMainView>0

            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/setup.svg"
                text: qsTranslate("other", "&Setup")
                enabled: PQCFileFolderModel.countMainView>0
                onTriggered: {
                    PQCScriptsShortcuts.executeInternalCommand("__slideshow")
                }
            }

            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/slideshow.svg"
                text: qsTranslate("other", "&Quickstart")
                enabled: PQCFileFolderModel.countMainView>0
                onTriggered: {
                    PQCScriptsShortcuts.executeInternalCommand("__slideshowQuick")
                }
            }

        }

        PQMenu {

            title: "Advanced sort"
            enabled: PQCFileFolderModel.countMainView>0

            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/setup.svg"
                text: qsTranslate("other", "&Setup")
                enabled: PQCFileFolderModel.countMainView>0
                onTriggered: {
                    PQCScriptsShortcuts.executeInternalCommand("__advancedSort")
                }
            }

            PQMenuItem {
                iconSource: "image://svg/:/" + PQCLook.iconShade + "/sort.svg"
                text: qsTranslate("other", "&Quickstart")
                enabled: PQCFileFolderModel.countMainView>0
                onTriggered: {
                    PQCScriptsShortcuts.executeInternalCommand("__advancedSortQuick")
                }
            }
        }

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/filter.svg"
            text: qsTranslate("other", "&Filter images")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__filterImages")
            }
        }

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/streaming.svg"
            text: qsTranslate("other", "&Streaming (Chromecast)")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__chromecast")
            }
        }

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/browse.svg"
            text: qsTranslate("other", "&Open in default file manager")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__defaultFileManager")
            }
        }

    }

    PQMenu {

        id: menu_extensions

        title: qsTranslate("other", "&Extensions")
        enabled: PQCConstants.idOfVisibleItem===""

        PQMenuItem {
            text: qsTranslate("other", "Manage extensions")
            onTriggered:
                PQCNotify.openSettingsManagerAt(6, "maex")
        }

        PQMenuSeparator { visible: PQCExtensionsHandler.numExtensionsAll>0 }

        Instantiator {

            model: PQCExtensionsHandler.numExtensionsAll

            delegate: PQMenu {

                id: deleg
                required property int index
                property string extensionId: PQCExtensionsHandler.getExtensionsEnabledAndDisabld()[index]
                property bool isEnabled: true

                property string sourceSVG: PQCExtensionsHandler.getExtensionLocation(extensionId) + "/img/" + PQCLook.iconShade + "/extension.svg"
                property string sourcePNG: PQCExtensionsHandler.getExtensionLocation(extensionId) + "/img/" + PQCLook.iconShade + "/extension.png"
                property string sourceJPG: PQCExtensionsHandler.getExtensionLocation(extensionId) + "/img/" + PQCLook.iconShade + "/extension.jpg"
                property bool haveSVG: PQCScriptsFilesPaths.doesItExist(sourceSVG)
                property bool havePNG: PQCScriptsFilesPaths.doesItExist(sourcePNG)
                property bool haveJPG: PQCScriptsFilesPaths.doesItExist(sourceJPG)
                icon.source: haveSVG ?
                               "image://svg/" + sourceSVG :
                                (havePNG||haveJPG ? ("file://" + (havePNG ? sourcePNG : sourceJPG)) : "")

                title: (deleg.isEnabled ? "" : "<s>")+PQCExtensionsHandler.getExtensionName(extensionId)+(deleg.isEnabled ? "" : "</s>")

                PQMenuItem {
                    enabled: deleg.isEnabled
                    text: PQCExtensionsHandler.getExtensionModal(extensionId) ? qsTranslate("other", "Show extension") : qsTranslate("other", "Toggle extension")
                    onTriggered:
                        PQCNotify.loaderShowExtension(deleg.extensionId)
                }

                Component.onCompleted: {
                    deleg.isEnabled = PQCExtensionsHandler.getDisabledExtensions().indexOf(deleg.extensionId)===-1
                }

                Connections {
                    target: PQCExtensionsHandler
                    function onNumExtensionsAllChanged() {
                        deleg.isEnabled = PQCExtensionsHandler.getDisabledExtensions().indexOf(deleg.extensionId)===-1
                    }
                }

                PQMenuItem {
                    text: deleg.isEnabled ? qsTranslate("other", "Disable extension") : qsTranslate("other", "Enable extension")
                    onTriggered: {
                        if(deleg.isEnabled) {
                            PQCExtensionsHandler.disableExtension(deleg.extensionId)
                            deleg.isEnabled = false
                        } else {
                            PQCExtensionsHandler.enableExtension(deleg.extensionId)
                            deleg.isEnabled = true
                        }
                        PQCSettings.generalExtensionsEnabled = PQCExtensionsHandler.getExtensions()
                    }
                }

            }

            // add/remove item into/from the correct position in the global menu
            onObjectAdded: (index, object) => {
                menu_extensions.addMenu(object)
            }
            onObjectRemoved: (index, object) => {
                menu_extensions.removeMenu(object)
            }

        }

    }

    PQMenu {

        id: menu_about

        title: qsTranslate("other", "&Help")
        enabled: PQCConstants.idOfVisibleItem===""

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/help.svg"
            text: qsTranslate("other", "&Online help")
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__onlineHelp")
            }
        }

        PQMenuItem {
            iconSource: "image://svg/:/" + PQCLook.iconShade + "/about.svg"
            text: qsTranslate("other", "&About")
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__about")
            }
        }

    }
}
