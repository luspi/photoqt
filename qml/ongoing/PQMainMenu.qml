/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

import PQCFileFolderModel
import PQCScriptsConfig

import "../elements"

Rectangle {

    id: mainmenu_top

    x: setVisible ? visiblePos[0] : invisiblePos[0]
    y: setVisible ? visiblePos[1] : invisiblePos[1]
    Behavior on x { NumberAnimation { duration: 200 } }
    Behavior on y { NumberAnimation { duration: 200 } }

    color: "#bb000000"

    radius: 5

    // visibility status
    opacity: setVisible ? 1 : 0
    visible: opacity>0
    Behavior on opacity { NumberAnimation { duration: 200 } }

    property bool setVisible: false
    property var visiblePos: [0,0]
    property var invisiblePos: [0, 0]
    property rect hotArea: Qt.rect(0, toplevel.height-10, toplevel.width, 10)

    state: PQCSettings.interfaceEdgeLeftAction==="mainmenu"
           ? "left"
           : (PQCSettings.interfaceEdgeRightAction==="mainmenu"
               ? "right"
               : "disabled" )

    property int gap: 50

    // the four states corresponding to screen edges
    states: [
        State {
            name: "left"
            PropertyChanges {
                target: mainmenu_top
                visiblePos: [gap,gap]
                invisiblePos: [-width,gap]
                hotArea: Qt.rect(0,0,10,toplevel.height)
                width: PQCSettings.mainmenuElementWidth
                height: toplevel.height-2*gap
            }
        },
        State {
            name: "right"
            PropertyChanges {
                target: mainmenu_top
                visiblePos: [toplevel.width-width-gap,gap]
                invisiblePos: [toplevel.width,gap]
                hotArea: Qt.rect(toplevel.width-10,0,10,toplevel.height)
                width: PQCSettings.mainmenuElementWidth
                height: toplevel.height-2*gap
            }
        },
        State {
            name: "disabled"
            PropertyChanges {
                target: mainmenu_top
                setVisible: false
                hotArea: Qt.rect(0,0,0,0)
            }
        }
    ]

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onWheel: (wheel) =>{
            wheel.accepted = true
        }
    }

    property bool anythingLoaded: PQCFileFolderModel.countMainView>0

    property int colwidth: width-2*flickable.anchors.margins

    property int normalEntryHeight: 20

    Flickable {

        id: flickable

        anchors.fill: parent
        anchors.margins: 10

        contentHeight: flickable_col.height
        contentWidth: flickable_col.width

        clip: true

        ScrollBar.vertical: PQVerticalScrollBar { }

        Column {

            id: flickable_col

            spacing: 20

            /*************************/
            // Navigation

            Rectangle {

                width: flickable.width
                height: nav_txt.height+10
                color: "#11ffffff"
                radius: 5

                PQTextXL {
                    id: nav_txt
                    x: 5
                    y: 5
                    //: This is a category in the main menu.
                    text: qsTranslate("MainMenu", "navigation")
                    font.weight: PQCLook.fontWeightBold
                    opacity: 0.8
                }

            }

            Column {

                id: nav_col

                spacing: 5

                Row {

                    PQMainMenuEntry {
                        id: prevarrow
                        img: "previous.svg"
                        //: as in: PREVIOUS image. Please keep short.
                        txt: qsTranslate("MainMenu", "previous")
                        cmd: "__prev"
                        smallestWidth: colwidth/2
                        font.pointSize: PQCLook.fontSizeL
                        font.weight: PQCLook.fontWeightBold
                        alignCenter: true
                    }

                    PQMainMenuEntry {
                        id: nextarrow
                        img_end: "next.svg"
                        //: as in: NEXT image. Please keep short.
                        txt: qsTranslate("MainMenu", "next")
                        cmd: "__next"
                        smallestWidth: colwidth/2
                        font.pointSize: PQCLook.fontSizeL
                        font.weight: PQCLook.fontWeightBold
                        alignCenter: true
                    }

                }

                Row {

                    PQMainMenuEntry {
                        img: "first.svg"
                        //: as in: FIRST image. Please keep short.
                        txt: qsTranslate("MainMenu", "first")
                        cmd: "__goToFirst"
                        smallestWidth: prevarrow.width
                        alignCenter: true
                    }

                    PQMainMenuEntry {
                        img_end: "last.svg"
                        //: as in: LAST image. Please keep short.
                        txt: qsTranslate("MainMenu", "last")
                        cmd: "__goToLast"
                        smallestWidth: nextarrow.width
                        alignCenter: true
                    }

                }

                PQMainMenuEntry {
                    img: "browse.svg"
                    txt: qsTranslate("MainMenu", "Browse images")
                    cmd: "__open"
                    closeMenu: true
                    onHeightChanged:
                        normalEntryHeight = height
                }

                PQMainMenuEntry {
                    img: "mapmarker.svg"
                    txt: qsTranslate("MainMenu", "Map Explorer")
                    cmd: "__showMapExplorer"
                    closeMenu: true
                }

            }

            /*************************/
            // image view

            Rectangle {

                width: flickable.width
                height: view_txt.height+10
                color: "#11ffffff"
                radius: 5

                PQTextXL {
                    id: view_txt
                    x: 5
                    y: 5
                    //: This is a category in the main menu.
                    text: qsTranslate("MainMenu", "current image")
                    font.weight: PQCLook.fontWeightBold
                    opacity: 0.8
                }

            }

            Column {

                id: view_col

                spacing: 5

                // ZOOM

                Row {

                    spacing: 10

                    Item {
                        width: Math.max(zoom_txt.width, Math.max(rotate_txt.width, flip_txt.width))
                        height: zoom_txt.height
                        PQText {
                            id: zoom_txt
                            x: (parent.width-width)
                            y: (zoomin_icn.height-height)/2
                            //: Entry in main menu. Please keep short.
                            text: qsTranslate("MainMenu", "Zoom") + ":"
                            opacity: 0.6
                            font.weight: PQCLook.fontWeightBold
                        }
                    }

                    PQMainMenuIcon {
                        id: zoomin_icn
                        img: "zoomin.svg"
                        cmd: "__zoomIn"
                        scaleFactor: 1
                        active: anythingLoaded
                    }

                    PQMainMenuIcon {
                        y: (zoomin_icn.height-height)/2
                        img: "zoomout.svg"
                        cmd: "__zoomOut"
                        scaleFactor: 1
                        active: anythingLoaded
                    }

                    PQMainMenuEntry {
                        y: (zoomin_icn.height-height)/2
                        img: "actualsize.svg"
                        txt: "100%"
                        cmd: "__zoomActual"
                        smallestWidth: 10
                        active: anythingLoaded
                    }

                    PQMainMenuEntry {
                        y: (zoomin_icn.height-height)/2
                        img: "reset.svg"
                        //: Used as in RESET zoom.
                        txt: qsTranslate("MainMenu", "reset")
                        cmd: "__zoomReset"
                        smallestWidth: 10
                        active: anythingLoaded
                    }

                }

                // ROTATION

                Row {

                    spacing: 10

                    Item {
                        width: Math.max(zoom_txt.width, Math.max(rotate_txt.width, flip_txt.width))
                        height: rotate_txt.height
                        PQText {
                            id: rotate_txt
                            x: (parent.width-width)
                            y: (rotate_left.height-height)/2
                            //: Entry in main menu. Please keep short.
                            text: qsTranslate("MainMenu", "Rotation")
                            opacity: 0.6
                            font.weight: PQCLook.fontWeightBold
                        }
                    }

                    PQMainMenuIcon {
                        id: rotate_left
                        img: "rotateleft.svg"
                        cmd: "__rotateL"
                        scaleFactor: 1
                        active: anythingLoaded
                    }

                    PQMainMenuIcon {
                        y: (rotate_left.height-height)/2
                        img: "rotateright.svg"
                        cmd: "__rotateR"
                        scaleFactor: 1
                        active: anythingLoaded
                    }

                    PQMainMenuEntry {
                        y: (rotate_left.height-height)/2
                        img: "reset.svg"
                        //: Used as in RESET rotation.
                        txt: qsTranslate("MainMenu", "reset")
                        cmd: "__rotate0"
                        smallestWidth: 10
                        active: anythingLoaded
                    }

                }

                // FLIP

                Row {

                    spacing: 10

                    Item {
                        width: Math.max(zoom_txt.width, Math.max(rotate_txt.width, flip_txt.width))
                        height: flip_txt.height
                        PQText {
                            id: flip_txt
                            x: (parent.width-width)
                            y: (flip_ver.height-height)/2
                            //: Mirroring (or flipping) an image. Please keep short.
                            text: qsTranslate("MainMenu", "Mirror")
                            opacity: 0.6
                            font.weight: PQCLook.fontWeightBold
                        }
                    }

                    PQMainMenuIcon {
                        y: (flip_ver.height-height)/2
                        img: "leftrightarrow.svg"
                        cmd: "__flipH"
                        scaleFactor: 1
                        active: anythingLoaded
                    }

                    PQMainMenuIcon {
                        id: flip_ver
                        img: "updownarrow.svg"
                        cmd: "__flipV"
                        scaleFactor: 1
                        active: anythingLoaded
                    }

                    PQMainMenuEntry {
                        y: (flip_ver.height-height)/2
                        img: "reset.svg"
                        //: Used as in RESET mirroring.
                        txt: qsTranslate("MainMenu", "reset")
                        cmd: "__flipReset"
                        smallestWidth: 10
                        active: anythingLoaded
                    }

                }

                // Histogram/Map

                PQMainMenuEntry {
                    img: "histogram.svg"
                    txt: PQCSettings.histogramVisible ? qsTranslate("MainMenu", "Hide histogram") : qsTranslate("MainMenu", "Show histogram")
                    cmd: "__histogram"
                }

                PQMainMenuEntry {
                    img: "mapmarker.svg"
                    txt: PQCSettings.mapviewCurrentVisible ? qsTranslate("MainMenu", "Hide current location") : qsTranslate("MainMenu", "Show current location")
                    cmd: "__showMapCurrent"
                }

            }



            /*************************/
            // Folder Actions

            Rectangle {

                width: flickable.width
                height: folder_txt.height+10
                color: "#11ffffff"
                radius: 5

                PQTextXL {
                    id: folder_txt
                    x: 5
                    y: 5
                    //: This is a category in the main menu.
                    text: qsTranslate("MainMenu", "all images")
                    font.weight: PQCLook.fontWeightBold
                    opacity: 0.8
                }

            }

            Column {

                id: folder_col

                spacing: 5

                // SLIDESHOW

                Row {

                    spacing: 10

                    PQText {
                        id: slideshow_txt
                        y: (slideshow_start.height-height)/2
                        //: Entry in main menu. Please keep short.
                        text: qsTranslate("MainMenu", "Slideshow") + ":"
                        opacity: 0.6
                        font.weight: PQCLook.fontWeightBold
                    }

                    PQMainMenuEntry {
                        id: slideshow_start
                        img: "slideshow.svg"
                        //: Used as in START slideshow. Please keep short
                        txt: qsTranslate("MainMenu", "Start")
                        cmd: "__slideshowQuick"
                        smallestWidth: 10
                        closeMenu: true
                        active: anythingLoaded
                    }

                    PQMainMenuEntry {
                        img: "setup.svg"
                        //: Used as in SETUP slideshow. Please keep short
                        txt: qsTranslate("MainMenu", "Setup")
                        cmd: "__slideshow"
                        smallestWidth: 10
                        closeMenu: true
                        active: anythingLoaded
                    }

                }

                // ADVANCED SORT

                Row {

                    spacing: 10

                    PQText {
                        id: advanced_txt
                        y: (advanced_start.height-height)/2
                        //: Entry in main menu. Please keep short.
                        text: qsTranslate("MainMenu", "Advanced Sort") + ":"
                        opacity: 0.6
                        font.weight: PQCLook.fontWeightBold
                    }

                    PQMainMenuEntry {
                        id: advanced_start
                        img: "sort.svg"
                        //: Used as in START advanced sort. Please keep short
                        txt: qsTranslate("MainMenu", "Start")
                        cmd: "__advancedSortQuick"
                        smallestWidth: 10
                        closeMenu: true
                        active: anythingLoaded
                    }

                    PQMainMenuEntry {
                        img: "setup.svg"
                        //: Used as in SETUP advanced sort. Please keep short
                        txt: qsTranslate("MainMenu", "Setup")
                        cmd: "__advancedSort"
                        smallestWidth: 10
                        closeMenu: true
                        active: anythingLoaded
                    }

                }

                // FILTER/STREAMING/DEFAULT

                PQMainMenuEntry {
                    img: "filter.svg"
                    txt: qsTranslate("MainMenu", "Filter images")
                    cmd: "__filterImages"
                    closeMenu: true
                    active: anythingLoaded
                }

                PQMainMenuEntry {
                    visible: PQCScriptsConfig.isChromecastEnabled()
                    img: "streaming.svg"
                    txt: qsTranslate("MainMenu", "Streaming (Chromecast)")
                    cmd: "__chromecast"
                    closeMenu: true
                    active: anythingLoaded
                }

                PQMainMenuEntry {
                    img: "browse.svg"
                    txt: qsTranslate("MainMenu", "Open in default file manager")
                    cmd: "__defaultFileManager"
                    closeMenu: true
                    active: anythingLoaded
                }

            }

            /*************************/
            // PhotoQt

            Rectangle {

                width: flickable.width
                height: photoqt_txt.height+10
                color: "#11ffffff"
                radius: 5

                PQTextXL {
                    id: photoqt_txt
                    x: 5
                    y: 5
                    //: This is a category in the main menu.
                    text: qsTranslate("MainMenu", "general")
                    font.weight: PQCLook.fontWeightBold
                    opacity: 0.8
                }

            }

            Column {

                id: photoqt_col

                spacing: 5

                Row {

                    PQMainMenuEntry {
                        img: "setup.svg"
                        txt: qsTranslate("MainMenu", "Settings")
                        cmd: "__settings"
                        smallestWidth: flickable.width/2
                        closeMenu: true
                    }

                    PQMainMenuEntry {
                        img: "about.svg"
                        txt: qsTranslate("MainMenu", "About")
                        cmd: "__about"
                        smallestWidth: flickable.width/2
                        closeMenu: true
                    }

                }

                Row {

                    PQMainMenuEntry {
                        img: "help.svg"
                        txt: qsTranslate("MainMenu", "Online help")
                        cmd: "__onlineHelp"
                        smallestWidth: flickable.width/2
                        closeMenu: true
                    }

                    PQMainMenuEntry {
                        img: "quit.svg"
                        txt: qsTranslate("MainMenu", "Quit")
                        cmd: "__quit"
                        smallestWidth: flickable.width/2
                    }

                }

            }

        }

    }

    function hideMainMenu() {
        mainmenu_top.setVisible = false
    }

    // check whether the thumbnails should be shown or not
    function checkMousePosition(x,y) {
        if(setVisible) {
            if(x < mainmenu_top.x-50 || x > mainmenu_top.x+mainmenu_top.width+50 || y < mainmenu_top.y-50 || y > mainmenu_top.y+mainmenu_top.height+50)
                setVisible = false
        } else {
            if(hotArea.x < x && hotArea.x+hotArea.width>x && hotArea.y < y && hotArea.height+hotArea.y > y)
                setVisible = true
        }
    }

}
