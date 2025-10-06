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
import PhotoQt.CPlusPlus
import PhotoQt.Integrated

MenuBar {

    onHeightChanged:
        PQCConstants.menuBarHeight = height

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

        // MenuItem {
        //     text: qsTranslate("other", "&Scale image")
        //     onTriggered: {
        //          // EXTENSION
        //     }
        // }

        // MenuItem {
        //     text: qsTranslate("other", "&Crop image")
        //     onTriggered: {
        //          // EXTENSION
        //     }
        // }

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

        // MenuItem {
        //     text: qsTranslate("other", "&Export to different format")
        //     onTriggered: {
        //         // EXTENSION
        //     }
        // }

        // MenuItem {
        //     text: qsTranslate("other", "&Set as wallpaper")
        //     onTriggered: {
        //         // EXTENSION
        //     }
        // }

        // MenuItem {
        //     text: qsTranslate("other", "&Histogram")
        //     onTriggered: {
        //         // EXTENSION
        //     }
        // }

        // MenuItem {
        //     text: qsTranslate("other", "&Show on map")
        //     onTriggered: {
        //         // EXTENSION
        //     }
        // }

    }

    Menu {

        id: menu_folder

        title: qsTranslate("other", "&Folder")

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

        id: menu_about

        title: qsTranslate("other", "&Help")

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
