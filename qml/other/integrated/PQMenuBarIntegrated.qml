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

MenuBar {

    id: menu_top

    onHeightChanged:
        PQCConstants.menuBarHeight = height

    // This replaces the ambersand (&) with an underline html tag
    function parseMenuString(txt : string) : string {
        var ret = txt
        var i = ret.indexOf("&")
        if(i > -1) {
            ret = txt.replace("&", "")
            ret = ret.slice(0, i) + "<u>" + ret[i] + "</u>" + ret.slice(i+1)
        }
        return ret
    }

    delegate: MenuBarItem {

        id: menuBarItem

        contentItem: Text {
            property string plainTxt: menuBarItem.text.replace("&","")
            property string modTxt: menu_top.parseMenuString(menuBarItem.text)
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

    Menu {

        id: menu_file

        title: qsTranslate("other", "&File")

        MenuItem {
            icon.source: "image://svg/:/" + PQCLook.iconShade + "/browse.svg"
            text: qsTranslate("other", "&Open (browse images)")
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__open")
            }
        }

        MenuItem {
            icon.source: "image://svg/:/" + PQCLook.iconShade + "/settings.svg"
            text: qsTranslate("other", "&Settings manager")
            enabled: PQCConstants.idOfVisibleItem===""
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__settings")
            }
        }

        MenuSeparator {}

        MenuItem {
            icon.source: "image://svg/:/" + PQCLook.iconShade + "/quit.svg"
            text: qsTranslate("other", "&Quit")
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__quit")
            }
        }

    }

    Menu {

        id: menu_navigation

        title: qsTranslate("other", "&Navigation")
        enabled: PQCConstants.idOfVisibleItem===""

        MenuItem {
            icon.source: "image://svg/:/" + PQCLook.iconShade + "/next.svg"
            text: qsTranslate("other", "&Next")
            enabled: PQCFileFolderModel.countMainView>0
            MouseArea{
                anchors.fill: parent
                onClicked:
                    PQCScriptsShortcuts.executeInternalCommand("__next")
            }
        }

        MenuItem {
            icon.source: "image://svg/:/" + PQCLook.iconShade + "/previous.svg"
            text: qsTranslate("other", "&Previous")
            enabled: PQCFileFolderModel.countMainView>0
            MouseArea{
                anchors.fill: parent
                onClicked:
                    PQCScriptsShortcuts.executeInternalCommand("__prev")
            }
        }

        MenuItem {
            icon.source: "image://svg/:/" + PQCLook.iconShade + "/last.svg"
            text: qsTranslate("other", "&Last")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__goToLast")
            }
        }

        MenuItem {
            icon.source: "image://svg/:/" + PQCLook.iconShade + "/first.svg"
            text: qsTranslate("other", "&First")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__goToFirst")
            }
        }

        MenuSeparator {}

        MenuItem {
            icon.source: "image://svg/:/" + PQCLook.iconShade + "/browse.svg"
            text: qsTranslate("other", "&Open (browse images)")
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__open")
            }
        }

        MenuItem {
            icon.source: "image://svg/:/" + PQCLook.iconShade + "/mapmarker.svg"
            text: qsTranslate("other", "&Map explorer")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__showMapExplorer")
            }
        }

    }

    Menu {

        id: menu_image

        title: qsTranslate("other", "&Image")
        enabled: PQCConstants.idOfVisibleItem===""

        MenuItem {
            icon.source: "image://svg/:/" + PQCLook.iconShade + "/rename.svg"
            text: qsTranslate("other", "&Rename")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__rename")
            }
        }

        MenuItem {
            icon.source: "image://svg/:/" + PQCLook.iconShade + "/copy.svg"
            text: qsTranslate("other", "&Copy")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__copy")
            }
        }

        MenuItem {
            icon.source: "image://svg/:/" + PQCLook.iconShade + "/move.svg"
            text: qsTranslate("other", "&Move")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__move")
            }
        }

        MenuItem {
            icon.source: "image://svg/:/" + PQCLook.iconShade + "/delete.svg"
            text: qsTranslate("other", "&Delete")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__delete")
            }
        }

        MenuSeparator {}

        Menu {
            title: qsTranslate("other", "&Zoom")
            enabled: PQCFileFolderModel.countMainView>0
            MenuItem {
                id: zoomin
                icon.source: "image://svg/:/" + PQCLook.iconShade + "/zoomin.svg"
                text: qsTranslate("other", "&In")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__zoomIn")
                }
            }
            MenuItem {
                icon.source: "image://svg/:/" + PQCLook.iconShade + "/zoomout.svg"
                text: qsTranslate("other", "&Out")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__zoomOut")
                }
            }
            MenuItem {
                icon.source: "image://svg/:/" + PQCLook.iconShade + "/actualsize.svg"
                text: qsTranslate("other", "&100%")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__zoomActual")
                }
            }
            MenuItem {
                icon.source: "image://svg/:/" + PQCLook.iconShade + "/reset.svg"
                text: qsTranslate("other", "&Reset")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__zoomReset")
                }
            }
        }

        Menu {
            title: qsTranslate("other", "&Rotate")
            enabled: PQCFileFolderModel.countMainView>0
            MenuItem {
                icon.source: "image://svg/:/" + PQCLook.iconShade + "/rotateright.svg"
                text: qsTranslate("other", "90° &clockwise")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__rotateR")
                }
            }
            MenuItem {
                icon.source: "image://svg/:/" + PQCLook.iconShade + "/rotateleft.svg"
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
            MenuItem {
                icon.source: "image://svg/:/" + PQCLook.iconShade + "/reset.svg"
                text: qsTranslate("other", "&Reset")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__rotate0")
                }
            }
        }

        Menu {
            title: qsTranslate("other", "&Mirror")
            enabled: PQCFileFolderModel.countMainView>0
            MenuItem {
                icon.source: "image://svg/:/" + PQCLook.iconShade + "/leftrightarrow.svg"
                text: qsTranslate("other", "Horizontal")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__flipH")
                }
            }
            MenuItem {
                icon.source: "image://svg/:/" + PQCLook.iconShade + "/updownarrow.svg"
                text: qsTranslate("other", "Vertical")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__flipV")
                }
            }
            MenuItem {
                icon.source: "image://svg/:/" + PQCLook.iconShade + "/reset.svg"
                text: qsTranslate("other", "Reset")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__flipReset")
                }
            }
        }

        MenuSeparator {}

        MenuItem {
            icon.source: "image://svg/:/" + PQCLook.iconShade + "/faces.svg"
            text: qsTranslate("other", "&Tag faces")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__tagFaces")
            }
        }

        MenuItem {
            icon.source: "image://svg/:/" + PQCLook.iconShade + "/clipboard.svg"
            text: qsTranslate("other", "&Copy to clipboard")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__clipboard")
            }
        }

        MenuItem {
            icon.source: "image://svg/:/" + PQCLook.iconShade + "/qrcode.svg"
            text: qsTranslate("other", "&Detect QR/barcodes")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__detectBarCodes")
            }
        }

    }

    Menu {

        id: menu_folder

        title: qsTranslate("other", "&Folder")
        enabled: PQCConstants.idOfVisibleItem===""

        Menu {

            title: "Slideshow"
            enabled: PQCFileFolderModel.countMainView>0

            MenuItem {
                icon.source: "image://svg/:/" + PQCLook.iconShade + "/setup.svg"
                text: qsTranslate("other", "&Setup")
                enabled: PQCFileFolderModel.countMainView>0
                onTriggered: {
                    PQCScriptsShortcuts.executeInternalCommand("__slideshow")
                }
            }

            MenuItem {
                icon.source: "image://svg/:/" + PQCLook.iconShade + "/slideshow.svg"
                text: qsTranslate("other", "&Quickstart")
                enabled: PQCFileFolderModel.countMainView>0
                onTriggered: {
                    PQCScriptsShortcuts.executeInternalCommand("__slideshowQuick")
                }
            }

        }

        Menu {

            title: "Advanced sort"
            enabled: PQCFileFolderModel.countMainView>0

            MenuItem {
                icon.source: "image://svg/:/" + PQCLook.iconShade + "/setup.svg"
                text: qsTranslate("other", "&Setup")
                enabled: PQCFileFolderModel.countMainView>0
                onTriggered: {
                    PQCScriptsShortcuts.executeInternalCommand("__advancedSort")
                }
            }

            MenuItem {
                icon.source: "image://svg/:/" + PQCLook.iconShade + "/sort.svg"
                text: qsTranslate("other", "&Quickstart")
                enabled: PQCFileFolderModel.countMainView>0
                onTriggered: {
                    PQCScriptsShortcuts.executeInternalCommand("__advancedSortQuick")
                }
            }
        }

        MenuItem {
            icon.source: "image://svg/:/" + PQCLook.iconShade + "/filter.svg"
            text: qsTranslate("other", "&Filter images")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__filterImages")
            }
        }

        MenuItem {
            icon.source: "image://svg/:/" + PQCLook.iconShade + "/streaming.svg"
            text: qsTranslate("other", "&Streaming (Chromecast)")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__chromecast")
            }
        }

        MenuItem {
            icon.source: "image://svg/:/" + PQCLook.iconShade + "/browse.svg"
            text: qsTranslate("other", "&Open in default file manager")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__defaultFileManager")
            }
        }

    }

    Menu {

        id: menu_extensions

        title: qsTranslate("other", "&Extensions")
        enabled: PQCConstants.idOfVisibleItem===""

        MenuItem {
            text: qsTranslate("other", "Manage extensions")
            onClicked:
                PQCNotify.openSettingsManagerAt(6, "maex")
        }

        MenuSeparator { visible: PQCExtensionsHandler.numExtensionsAll>0 }

        Instantiator {

            model: PQCExtensionsHandler.numExtensionsAll

            delegate: Menu {

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

                MenuItem {
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

                MenuItem {
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

    Menu {

        id: menu_about

        title: qsTranslate("other", "&Help")
        enabled: PQCConstants.idOfVisibleItem===""

        MenuItem {
            icon.source: "image://svg/:/" + PQCLook.iconShade + "/help.svg"
            text: qsTranslate("other", "&Online help")
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__onlineHelp")
            }
        }

        MenuItem {
            icon.source: "image://svg/:/" + PQCLook.iconShade + "/about.svg"
            text: qsTranslate("other", "&About")
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__about")
            }
        }

    }
}
