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

        title: qsTr("&File")

        Action {
            text: qsTr("&Open (browse images)")
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__open")
            }
        }

        Action {
            text: qsTr("&Settings manager")
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__settings")
            }
        }

        MenuSeparator {}

        Action {
            text: qsTr("&Quit")
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__quit")
            }
        }

    }

    Menu {

        id: menu_navigation

        title: qsTr("&Navigation")

        MenuItem {
            text: qsTr("&Next")
            enabled: PQCFileFolderModel.countMainView>0
            MouseArea{
                anchors.fill: parent
                onClicked:
                    PQCScriptsShortcuts.executeInternalCommand("__next")
            }
        }

        MenuItem {
            text: qsTr("&Previous")
            enabled: PQCFileFolderModel.countMainView>0
            MouseArea{
                anchors.fill: parent
                onClicked:
                    PQCScriptsShortcuts.executeInternalCommand("__prev")
            }
        }

        MenuItem {
            text: qsTr("&Last")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__goToLast")
            }
        }

        MenuItem {
            text: qsTr("&First")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__goToFirst")
            }
        }

        MenuSeparator {}

        MenuItem {
            text: qsTr("&Open (browse images)")
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__open")
            }
        }

        MenuItem {
            text: qsTr("&Map explorer")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__showMapExplorer")
            }
        }

    }

    Menu {

        id: menu_image

        title: qsTr("&Image")

        MenuItem {
            text: qsTr("&Rename")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__rename")
            }
        }

        MenuItem {
            text: qsTr("&Copy")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__copy")
            }
        }

        MenuItem {
            text: qsTr("&Move")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__move")
            }
        }

        MenuItem {
            text: qsTr("&Delete")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__delete")
            }
        }

        MenuSeparator {}

        Menu {
            title: qsTr("&Zoom")
            enabled: PQCFileFolderModel.countMainView>0
            MenuItem {
                id: zoomin
                text: qsTr("&In")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__zoomIn")
                }
            }
            MenuItem {
                text: qsTr("&Out")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__zoomOut")
                }
            }
            MenuItem {
                text: qsTr("&100%")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__zoomActual")
                }
            }
            MenuItem {
                text: qsTr("&Reset")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__zoomReset")
                }
            }
        }

        Menu {
            title: qsTr("&Rotate")
            enabled: PQCFileFolderModel.countMainView>0
            MenuItem {
                text: qsTr("90° &clockwise")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__rotateR")
                }
            }
            MenuItem {
                text: qsTr("90° &anticlockwise")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__rotateL")
                }
            }
            // MenuItem {
            //     text: qsTr("&180°")
            //     onTriggered: {
            //         PQCScriptsShortcuts.executeInternalCommand("")
            //     }
            // }
            MenuItem {
                text: qsTr("&Reset")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__rotate0")
                }
            }
        }

        Menu {
            title: qsTr("&Mirror")
            enabled: PQCFileFolderModel.countMainView>0
            MenuItem {
                text: qsTr("Horizontal")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__flipH")
                }
            }
            MenuItem {
                text: qsTr("Vertical")
                enabled: PQCFileFolderModel.countMainView>0
                MouseArea{
                    anchors.fill: parent
                    onClicked:
                        PQCScriptsShortcuts.executeInternalCommand("__flipV")
                }
            }
            MenuItem {
                text: qsTr("Reset")
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
        //     text: qsTr("&Scale image")
        //     onTriggered: {
        //          // EXTENSION
        //     }
        // }

        // MenuItem {
        //     text: qsTr("&Crop image")
        //     onTriggered: {
        //          // EXTENSION
        //     }
        // }

        MenuItem {
            text: qsTr("&Tag faces")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__tagFaces")
            }
        }

        MenuItem {
            text: qsTr("&Copy to clipboard")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__clipboard")
            }
        }

        MenuItem {
            text: qsTr("&Detect QR/barcodes")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__detectBarCodes")
            }
        }

        // MenuItem {
        //     text: qsTr("&Export to different format")
        //     onTriggered: {
        //         // EXTENSION
        //     }
        // }

        // MenuItem {
        //     text: qsTr("&Set as wallpaper")
        //     onTriggered: {
        //         // EXTENSION
        //     }
        // }

        // MenuItem {
        //     text: qsTr("&Histogram")
        //     onTriggered: {
        //         // EXTENSION
        //     }
        // }

        // MenuItem {
        //     text: qsTr("&Show on map")
        //     onTriggered: {
        //         // EXTENSION
        //     }
        // }

    }

    Menu {

        id: menu_folder

        title: qsTr("&Folder")

        Menu {

            title: "Slideshow"
            enabled: PQCFileFolderModel.countMainView>0

            MenuItem {
                text: qsTr("&Setup")
                enabled: PQCFileFolderModel.countMainView>0
                onTriggered: {
                    PQCScriptsShortcuts.executeInternalCommand("__slideshow")
                }
            }

            MenuItem {
                text: qsTr("&Quickstart")
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
                text: qsTr("&Setup")
                enabled: PQCFileFolderModel.countMainView>0
                onTriggered: {
                    PQCScriptsShortcuts.executeInternalCommand("__advancedSort")
                }
            }

            MenuItem {
                text: qsTr("&Quickstart")
                enabled: PQCFileFolderModel.countMainView>0
                onTriggered: {
                    PQCScriptsShortcuts.executeInternalCommand("__advancedSortQuick")
                }
            }
        }

        MenuItem {
            text: qsTr("&Filter images")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__filterImages")
            }
        }

        MenuItem {
            text: qsTr("&Streaming (Chromecast)")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__chromecast")
            }
        }

        MenuItem {
            text: qsTr("&Open in default file manager")
            enabled: PQCFileFolderModel.countMainView>0
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__defaultFileManager")
            }
        }

    }

    Menu {

        id: menu_about

        title: qsTr("&Help")

        MenuItem {
            text: qsTr("&Online help")
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__onlineHelp")
            }
        }

        MenuItem {
            text: qsTr("&About")
            onTriggered: {
                PQCScriptsShortcuts.executeInternalCommand("__about")
            }
        }

    }
}
