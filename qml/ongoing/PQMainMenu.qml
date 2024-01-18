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

import PQCNotify
import PQCFileFolderModel
import PQCScriptsConfig
import PQCScriptsContextMenu
import PQCWindowGeometry

import "../elements"

Rectangle {

    id: mainmenu_top

    x: setVisible ? visiblePos[0] : invisiblePos[0]
    y: setVisible ? visiblePos[1] : invisiblePos[1]
    Behavior on x { NumberAnimation { duration: dragrightMouse.enabled&&dragrightMouse.clickStart!=-1 ? 0 : 200 } }

    color: PQCLook.transColor

    radius: 5

    // visibility status
    opacity: setVisible ? 1 : 0
    visible: opacity>0
    Behavior on opacity { NumberAnimation { duration: 200 } }

    property int parentWidth
    property int parentHeight
    width: PQCSettings.mainmenuElementWidth
    height: toplevel.height-2*gap

    property bool setVisible: false
    property var visiblePos: [0,0]
    property var invisiblePos: [0, 0]
    property int hotAreaSize: PQCSettings.interfaceHotEdgeSize*5
    property rect hotArea: Qt.rect(0, toplevel.height-hotAreaSize, toplevel.width, hotAreaSize)

    property bool isPopout: PQCSettings.interfacePopoutMainMenu||PQCWindowGeometry.mainmenuForcePopout

    state: isPopout
           ? "popout"
           : (PQCSettings.interfaceEdgeLeftAction==="mainmenu"
              ? "left"
              : (PQCSettings.interfaceEdgeRightAction==="mainmenu"
                 ? "right"
                 : "disabled" ))

    property int gap: 40

    PQBlurBackground { thisis: "mainmenu" }

    // the four states corresponding to screen edges
    states: [
        State {
            name: "left"
            PropertyChanges {
                target: mainmenu_top
                visiblePos: [gap, gap]
                invisiblePos: [-width, gap]
                hotArea: Qt.rect(0,0,hotAreaSize,toplevel.height)
            }
        },
        State {
            name: "right"
            PropertyChanges {
                target: mainmenu_top
                visiblePos: [toplevel.width-width-gap, gap]
                invisiblePos: [toplevel.width, gap]
                hotArea: Qt.rect(toplevel.width-hotAreaSize,0,hotAreaSize,toplevel.height)
            }
        },
        State {
            name: "popout"
            PropertyChanges {
                target: mainmenu_top
                setVisible: true
                hotArea: Qt.rect(0,0,0,0)
                width: mainmenu_top.parentWidth
                height: mainmenu_top.parentHeight
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

    Component.onCompleted: {
        if(isPopout) {
            mainmenu_top.opacity = 1
        }
    }

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
                color: PQCLook.transColorHighlight
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
                    visible: PQCScriptsConfig.isLocationSupportEnabled()
                }

            }

            /*************************/
            // image view

            Rectangle {

                width: flickable.width
                height: view_txt.height+10
                color: PQCLook.transColorHighlight
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
                color: PQCLook.transColorHighlight
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

                    Item {
                        width: Math.max(advanced_txt.width, slideshow_txt.width)
                        height: slideshow_txt.height
                        PQText {
                            id: slideshow_txt
                            x: parent.width-width
                            y: (slideshow_start.height-height)/2
                            //: Entry in main menu. Please keep short.
                            text: qsTranslate("MainMenu", "Slideshow") + ":"
                            opacity: 0.6
                            font.weight: PQCLook.fontWeightBold
                        }
                    }

                    PQMainMenuEntry {
                        id: slideshow_start
                        img: "slideshow.svg"
                        //: Used as in START slideshow. Please keep short
                        txt: qsTranslate("MainMenu", "Start")
                        cmd: "__slideshowQuick"
                        smallestWidth: (colwidth-slideshow_txt.parent.width-20)/2
                        closeMenu: true
                        active: anythingLoaded
                    }

                    PQMainMenuEntry {
                        img: "setup.svg"
                        //: Used as in SETUP slideshow. Please keep short
                        txt: qsTranslate("MainMenu", "Setup")
                        cmd: "__slideshow"
                        smallestWidth: slideshow_start.width
                        closeMenu: true
                        active: anythingLoaded
                    }

                }

                // ADVANCED SORT

                Row {

                    spacing: 10

                    Item {
                        width: Math.max(advanced_txt.width, slideshow_txt.width)
                        height: advanced_txt.height
                        PQText {
                            id: advanced_txt
                            x: parent.width-width
                            y: (advanced_start.height-height)/2
                            //: Entry in main menu. Please keep short.
                            text: qsTranslate("MainMenu", "Sort") + ":"
                            opacity: 0.6
                            font.weight: PQCLook.fontWeightBold
                        }
                    }

                    PQMainMenuEntry {
                        id: advanced_start
                        img: "sort.svg"
                        //: Used as in START advanced sort. Please keep short
                        txt: qsTranslate("MainMenu", "Start")
                        cmd: "__advancedSortQuick"
                        smallestWidth: (colwidth-advanced_txt.parent.width-20)/2
                        closeMenu: true
                        active: anythingLoaded
                    }

                    PQMainMenuEntry {
                        img: "setup.svg"
                        //: Used as in SETUP advanced sort. Please keep short
                        txt: qsTranslate("MainMenu", "Setup")
                        cmd: "__advancedSort"
                        smallestWidth: advanced_start.width
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
                color: PQCLook.transColorHighlight
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

            /*************************/
            // Custom

            Rectangle {

                width: flickable.width
                height: custom_txt.height+10
                color: PQCLook.transColorHighlight
                radius: 5

                visible: PQCSettings.mainmenuShowExternal

                PQTextXL {
                    id: custom_txt
                    x: 5
                    y: 5
                    //: This is a category in the main menu.
                    text: qsTranslate("MainMenu", "custom")
                    font.weight: PQCLook.fontWeightBold
                    opacity: 0.8
                }

            }

            Column {

                id: custom_col

                visible: PQCSettings.mainmenuShowExternal

                spacing: 5

                property var entries: []

                Repeater {

                    model: custom_col.entries.length

                    PQMainMenuEntry {

                        id: deleg

                        property var cur: custom_col.entries[index]

                        customEntry: true

                        img: cur[0]==="" ? "application.svg" : ("data:image/png;base64," + cur[0])
                        txt: cur[2]
                        cmd: cur[1]
                        custom_close: cur[3]
                        custom_args: cur[4]

                        smallestWidth: flickable.width
                        closeMenu: true
                    }

                }

                Component.onCompleted: {
                    if(PQCSettings.mainmenuShowExternal)
                        custom_col.entries = PQCScriptsContextMenu.getEntries()
                }

                Connections {
                    target: PQCSettings
                    function onMainmenuShowExternalChanged() {
                        if(PQCSettings.mainmenuShowExternal)
                            custom_col.entries = PQCScriptsContextMenu.getEntries()
                        else
                            custom_col.entries = []
                    }
                }

                Connections {
                    target: PQCScriptsContextMenu
                    function onCustomEntriesChanged() {
                        if(PQCSettings.mainmenuShowExternal)
                            custom_col.entries = PQCScriptsContextMenu.getEntries()
                        else
                            custom_col.entries = []
                    }
                }

            }

        }

    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
    }

    MouseArea {
        x: (parent.width-width)
        width: 10
        height: parent.height
        cursorShape: enabled ? Qt.SizeHorCursor : Qt.ArrowCursor
        enabled: parent.state==="left"

        property int clickStart: -1
        property int origWidth: PQCSettings.mainmenuElementWidth
        onPressed: (mouse) => {
            clickStart = mouse.x
        }
        onReleased:
            clickStart = -1

        onPositionChanged: (mouse) => {
            if(clickStart == -1)
                return
            var diff = mouse.x-clickStart
            PQCSettings.mainmenuElementWidth = Math.min(toplevel.width/2, Math.max(200, origWidth+diff))

        }

    }

    MouseArea {
        id: dragrightMouse
        x: 0
        width: 10
        height: parent.height
        cursorShape: enabled ? Qt.SizeHorCursor : Qt.ArrowCursor
        enabled: parent.state==="right"

        property int clickStart: -1
        property int origWidth: PQCSettings.mainmenuElementWidth
        onPressed: (mouse) => {
            clickStart = mouse.x
        }
        onReleased:
            clickStart = -1

        onPositionChanged: (mouse) => {
            if(clickStart == -1)
                return
            var diff = clickStart-mouse.x
            PQCSettings.mainmenuElementWidth = Math.min(toplevel.width/2, Math.max(200, origWidth+diff))

        }

    }

    Image {
        x: 5
        y: 5
        width: 15
        height: 15
        visible: !PQCWindowGeometry.mainmenuForcePopout
        enabled: visible
        source: "image://svg/:/white/popinpopout.svg"
        sourceSize: Qt.size(width, height)
        opacity: popinmouse.containsMouse ? 1 : 0.4
        Behavior on opacity { NumberAnimation { duration: 200 } }
        PQMouseArea {
            id: popinmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            text: PQCSettings.interfacePopoutMainMenu ?
                      //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                      qsTranslate("popinpopout", "Merge into main interface") :
                      //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                      qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                hideMainMenu()
                if(!PQCSettings.interfacePopoutMainMenu)
                    PQCSettings.interfacePopoutMainMenu = true
                else
                    close()
                PQCNotify.executeInternalCommand("__showMainMenu")
            }
        }
    }

    Connections {
        target: PQCNotify
        function onMouseMove(posx, posy) {

            if(PQCNotify.slideshowRunning || PQCNotify.faceTagging || PQCNotify.insidePhotoSphere) {
                setVisible = false
                return
            }

            if(setVisible) {
                if(posx < mainmenu_top.x-50 || posx > mainmenu_top.x+mainmenu_top.width+50 || posy < mainmenu_top.y-50 || posy > mainmenu_top.y+mainmenu_top.height+50)
                    setVisible = false
            } else {
                if(hotArea.x < posx && hotArea.x+hotArea.width > posx && hotArea.y < posy && hotArea.height+hotArea.y > posy)
                    setVisible = true
            }
        }
    }

    Connections {
        target: loader

        function onPassOn(what, param) {

            if(what === "show") {
                if(param === "mainmenu") {
                    showMainMenu()
                }
            } else if(what === "toggle") {
                if(param === "mainmenu") {
                    toggle()
                }
            }

        }

    }

    function toggle() {
        mainmenu_top.setVisible = !mainmenu_top.setVisible
    }

    function hideMainMenu() {
        mainmenu_top.setVisible = false
    }

    function showMainMenu() {
        mainmenu_top.setVisible = true
        if(isPopout)
            mainmenu_popout.show()
    }

}
