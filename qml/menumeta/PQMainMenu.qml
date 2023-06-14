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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.2
import "../elements"

Item {

    id: mainmenu_top

    PQBlurBackground {
        thisis: mainmenu
        radius: 10
        isPoppedOut: PQSettings.interfacePopoutMainMenu
    }

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    x: PQSettings.interfacePopoutMainMenu ? 0 : (parentWidth-width-40)
    y: PQSettings.interfacePopoutMainMenu ? 0 : ((parentHeight-height)/2)
    width: (PQSettings.interfacePopoutMainMenu ? parentWidth : PQSettings.mainmenuElementWidth)
    height: Math.min(flick.height+20, parentHeight)
    onHeightChanged:
        variables.mainMenuHeight = height

    opacity: 0
    visible: opacity != 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.interfacePopoutMainMenu ? 0 : PQSettings.imageviewAnimationDuration*100 } }
    onOpacityChanged:
        variables.mainMenuVisible = (opacity>0)

    property bool resizePressed: false

    property bool forceShow: false
    property bool forceHide: false

    property bool makeVisible: (!PQSettings.interfacePopoutMainMenu &&
                                toplevel.width>800 &&
                                !mainmenu_top.visible &&
                                !variables.slideShowActive &&
                                !variables.faceTaggingActive &&
                                variables.mousePos.x > toplevel.width-(2*PQSettings.interfaceHotEdgeSize+5) &&
                                variables.mousePos.y > 1.2*windowbuttons.height) ||
                               forceShow
    onMakeVisibleChanged: {
        if(makeVisible)
            mainmenu_top.opacity = 1
    }
    property bool makeHidden: (!PQSettings.interfacePopoutMainMenu &&
                               mainmenu_top.visible &&
                               !resizePressed &&
                               variables.mousePos.x < toplevel.width-width-5-40 &&
                               !forceShow)
                              || variables.slideShowActive
                              || variables.faceTaggingActive
                              || forceHide
    onMakeHiddenChanged: {
        if(makeHidden)
            mainmenu_top.opacity = 0
    }

    Component.onCompleted: {
        if(PQSettings.interfacePopoutMainMenu)
            mainmenu_top.opacity = 1
    }

    Connections {
        target: variables
        onMousePosChanged: {
            forceShow = false
            forceHide = false
        }
    }

    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onWheel: mouse.accepted = false
    }


    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: true

        acceptedButtons: Qt.RightButton|Qt.MiddleButton|Qt.LeftButton

        onWheel: {
        }

        PQMouseArea {

            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: 5

            enabled: !PQSettings.interfacePopoutMainMenu

            hoverEnabled: true

            cursorShape: Qt.SizeHorCursor

            tooltip: em.pty+qsTranslate("MainMenu", "Click and drag to resize main menu")

            property int oldMouseX

            onPressed: {
                mainmenu_top.resizePressed = true
                oldMouseX = mouse.x
            }

            onReleased: {
                mainmenu_top.resizePressed = false
                PQSettings.mainmenuElementWidth = mainmenu_top.width
            }

            onPositionChanged: {
                if (pressed) {
                    var w = mainmenu_top.width + (oldMouseX-mouse.x)
                    if(w < 2*toplevel.width/3)
                        mainmenu_top.width = w
                }
            }

        }


    }

    Flickable {

        id: flick

        x: 20
        y: 0
        width: parent.width-20
        height: Math.min(childrenRect.height, parentHeight)

        contentHeight: col.height+20

        boundsBehavior: Flickable.OvershootBounds
        ScrollBar.vertical: PQScrollBar {}

        Column {

            id: col

            width: parent.width

            PQMainMenuGroup {
                //: Used as heading for a group of entries in the main menu on the right. Please keep short!
                title: em.pty+qsTranslate("MainMenu", "Navigation")
                rightcolCenter: true
                leftcol: [[["img", "open.svg",                                      "__open", true, false],
                                   //: This is an entry in the main menu on the right. Please keep short!
                           ["txt", em.pty+qsTranslate("MainMenu", "Browse images"), "__open", true, false]],

                          [["img", "mapmarker.svg",                                 "__showMapExplorer", true, true],
                                   //: This is an entry in the main menu on the right. Please keep short!
                           ["txt", em.pty+qsTranslate("MainMenu", "Map Explorer"), "__showMapExplorer", true, true]],

                          [["img", "first.svg",                             "__goToFirst", false, true],
                                   //: This is an entry in the main menu on the right. Please keep short!
                           ["txt", em.pty+qsTranslate("MainMenu", "first"), "__goToFirst", false, true],
                           ["txt", " ",                                     "",            false, true],
                                   //: This is an entry in the main menu on the right. Please keep short!
                           ["txt", em.pty+qsTranslate("MainMenu", "last"),  "__goToLast" , false, true],
                           ["img", "last.svg",                              "__goToLast" , false, true]]]

                rightcol: [["img", "leftarrow.svg",  "__prev", false, true],
                           ["img", "rightarrow.svg", "__next", false, true]]
            }

            PQMainMenuGroup {
                //: Used as heading for a group of entries in the main menu on the right. Please keep short!
                title: em.pty+qsTranslate("MainMenu", "Zoom")
                rightcolCenter: true
                leftcol: [[["img", "actualsize.svg",                              "__zoomActual",  false, true],
                           ["txt", "100%", "__zoomActual",  false, true]],

                          [["img", "reset.svg",                                  "__zoomReset", false, true],
                                   //: This is an entry in the main menu on the right, used as in 'FIT image in window (reset zoom)'. Please keep short!
                           ["txt", em.pty+qsTranslate("MainMenu", "Fit"), "__zoomReset", false, true]]]

                rightcol: [["img", "zoomin.svg",  "__zoomIn",  false, true],
                           ["img", "zoomout.svg", "__zoomOut", false, true]]
            }

            PQMainMenuGroup {
                //: Used as heading for a group of entries in the main menu on the right. Please keep short!
                title: em.pty+qsTranslate("MainMenu", "Rotation/Flip")
                rightcolCenter: true
                leftcol: [[["img", "leftrightarrow.svg",                              "__flipH", false, true],
                                   //: This is an entry in the main menu on the right. Please keep short!
                           ["txt", em.pty+qsTranslate("MainMenu", "Horizontal flip"), "__flipH", false, true]],

                          [["img", "updownarrow.svg",                               "__flipV", false, true],
                                   //: This is an entry in the main menu on the right. Please keep short!
                           ["txt", em.pty+qsTranslate("MainMenu", "Vertical flip"), "__flipV", false, true]],

                          [["img", "reset.svg",                                  "__flipReset", false, true],
                                   //: This is an entry in the main menu on the right. Please keep short!
                           ["txt", em.pty+qsTranslate("MainMenu", "Reset flip"), "__flipReset", false, true]],

                          [["img", "reset.svg",                                      "__rotate0", false, true],
                                   //: This is an entry in the main menu on the right. Please keep short!
                           ["txt", em.pty+qsTranslate("MainMenu", "Reset rotation"), "__rotate0", false, true]]]

                rightcol: [["img", "rotateleft.svg",  "__rotateL", false, true],
                           ["img", "rotateright.svg", "__rotateR", false, true]]
            }

            PQMainMenuGroup {
                //: Used as heading for a group of entries in the main menu on the right. Please keep short!
                title: em.pty+qsTranslate("MainMenu", "Slideshow")
                rightcolNormal: true
                leftcol: [[["img", "slideshow.svg",                             "__slideshowQuick", true, true],
                                   //: This is an entry in the main menu on the right, used as in "START slideshow/sorting". Please keep short!
                           ["txt", em.pty+qsTranslate("MainMenu", "Start"),     "__slideshowQuick", true, true]]]

                rightcol: [["img", "setup.svg",                             "__slideshow", true, true],
                                   //: This is an entry in the main menu on the right, used as in "SETUP slideshow/sorting". Please keep short!
                           ["txt", em.pty+qsTranslate("MainMenu", "Setup"), "__slideshow", true, true]]
            }

            PQMainMenuGroup {
                //: Used as heading for a group of entries in the main menu on the right. Please keep short!
                title: em.pty+qsTranslate("MainMenu", "Advanced Sort")
                rightcolNormal: true
                leftcol: [[["img", "sort.svg",                              "__advancedSortQuick", true, true],
                                   //: This is an entry in the main menu on the right, used as in "START slideshow/sorting". Please keep short!
                           ["txt", em.pty+qsTranslate("MainMenu", "Start"), "__advancedSortQuick", true, true]]]

                rightcol: [["img", "setup.svg",                             "__advancedSort", true, true],
                                   //: This is an entry in the main menu on the right, used as in "SETUP slideshow/sorting". Please keep short!
                           ["txt", em.pty+qsTranslate("MainMenu", "Setup"), "__advancedSort", true, true]]
            }

            PQMainMenuGroup {
                //: Used as heading for a group of entries in the main menu on the right. Please keep short!
                title: em.pty+qsTranslate("MainMenu", "Other")
                leftcol: handlingGeneral.isChromecastEnabled() ?

                             [[["img", "filter.svg",                                    "__filterImages", true, true],
                                      //: This is an entry in the main menu on the right. Please keep short!
                              ["txt", em.pty+qsTranslate("MainMenu", "Filter images"), "__filterImages", true, true]],

                             [["img", "streaming.svg",                                          "__chromecast", true, false],
                                      //: This is an entry in the main menu on the right. Please keep short!
                              ["txt", em.pty+qsTranslate("MainMenu", "Streaming (Chromecast)"), "__chromecast", true, false]],

                             [["img", "open.svg",                                                     "__defaultFileManager", true, true],
                                      //: This is an entry in the main menu on the right. Please keep short!
                              ["txt", em.pty+qsTranslate("MainMenu", "Open in default file manager"), "__defaultFileManager", true, true]]]

                           :

                             [[["img", "filter.svg",                                    "__filterImages", true, true],
                                      //: This is an entry in the main menu on the right. Please keep short!
                              ["txt", em.pty+qsTranslate("MainMenu", "Filter images"), "__filterImages", true, true]],

                             [["img", "open.svg",                                                     "__defaultFileManager", true, true],
                                      //: This is an entry in the main menu on the right. Please keep short!
                              ["txt", em.pty+qsTranslate("MainMenu", "Open in default file manager"), "__defaultFileManager", true, true]]]

            }

            PQMainMenuGroup {
                id: ext
                //: Used as heading for a group of entries in the main menu on the right. Please keep short!
                title: em.pty+qsTranslate("MainMenu", "External")
                external: true

                visible: PQSettings.mainmenuShowExternal && leftcol.length>0

                Component.onCompleted:
                    readExternalEntries()

                Connections {
                    target: filewatcher
                    onContextmenuChanged: {
                        ext.readExternalEntries()
                    }
                }

                function readExternalEntries() {
                    var tmpentries = handlingExternal.getContextMenuEntries()
                    var entries = []
                    for(var i = 0; i < tmpentries.length; ++i) {
                        var e = [["img", "icn:"+tmpentries[i][0], tmpentries[i][1], tmpentries[i][3], true],
                                 ["txt", tmpentries[i][2], tmpentries[i][1], tmpentries[i][3], true, tmpentries[i][4]]]
                        entries.push(e)
                    }
                    ext.leftcol = entries

                }
            }

            PQMainMenuGroup {
                title: "PhotoQt"
                rightcolNormal: true
                leftcol: [[["img", "setup.svg",                                "__settings", true, false],
                           ["txt", em.pty+qsTranslate("MainMenu", "Settings"), "__settings", true, false]]]

                rightcol: [["img", "about.svg",                             "__about", true, false],
                           ["txt", em.pty+qsTranslate("MainMenu", "About"), "__about", true, false]]
            }

            PQMainMenuGroup {
                title: ""
                rightcolNormal: true
                noSpacingAtTop: true
                leftcol: [[["img", "help.svg",                                    "__onlineHelp", true, false],
                           ["txt", em.pty+qsTranslate("MainMenu", "Online help"), "__onlineHelp", true, false]]]

                rightcol: [["img", "quit.svg",                             "__quit", true, false],
                           ["txt", em.pty+qsTranslate("MainMenu", "Quit"), "__quit", true, false]]
            }

        }

    }

    PQMouseArea {
        // drag along left edge
        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
        }
        width: 20
        hoverEnabled: true

        enabled: !PQSettings.interfacePopoutMainMenu

        drag.minimumY: 0
        drag.maximumY: toplevel.height-mainmenu_top.height
        drag.target: parent
        drag.axis: Drag.YAxis
        cursorShape: enabled ? Qt.SizeAllCursor : Qt.ArrowCursor
    }

    PQMouseArea {
        // drag along right edge
        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
        }
        width: 20
        hoverEnabled: true

        enabled: !PQSettings.interfacePopoutMainMenu

        drag.minimumY: 0
        drag.maximumY: toplevel.height-mainmenu_top.height
        drag.target: parent
        drag.axis: Drag.YAxis
        cursorShape: enabled ? Qt.SizeAllCursor : Qt.ArrowCursor
    }

    PQMouseArea {
        // drag along top edge
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: 20
        hoverEnabled: true

        enabled: !PQSettings.interfacePopoutMainMenu

        drag.minimumY: 0
        drag.maximumY: toplevel.height-mainmenu_top.height
        drag.target: parent
        drag.axis: Drag.YAxis
        cursorShape: enabled ? Qt.SizeAllCursor : Qt.ArrowCursor
    }

    PQMouseArea {
        // drag along bottom edge
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        height: 20
        hoverEnabled: true

        enabled: !PQSettings.interfacePopoutMainMenu

        drag.minimumY: 0
        drag.maximumY: toplevel.height-mainmenu_top.height
        drag.target: parent
        drag.axis: Drag.YAxis
        cursorShape: enabled ? Qt.SizeAllCursor : Qt.ArrowCursor
    }

    // visible when popped out
    Item {
        x: 5
        y: 5
        width: 25
        height: 25
        Image {
            anchors.fill: parent
            anchors.margins: 5
            source: "/popin.svg"
            sourceSize: Qt.size(width, height)
            opacity: popinmouse.containsMouse ? 1 : 0.4
            Behavior on opacity { NumberAnimation { duration: 200 } }
            PQMouseArea {
                id: popinmouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                tooltip: PQSettings.interfacePopoutMainMenu
                                //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                                ? em.pty+qsTranslate("popinpopout", "Merge into main interface")
                                //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                                : em.pty+qsTranslate("popinpopout", "Move to its own window")
                onClicked: {
                    if(PQSettings.interfacePopoutMainMenu)
                        mainmenu_window.storeGeometry()
                    PQSettings.interfacePopoutMainMenu = !PQSettings.interfacePopoutMainMenu
                }
            }
        }
    }

    Connections {
        target: loader
        onMainmenuPassOn: {
            if(what == "toggle")
                toggle()
        }
    }



    function toggle() {
        if(PQSettings.interfacePopoutMainMenu) return
        if(mainmenu_top.opacity == 1) {
            forceShow = false
            forceHide = true
        } else {
            forceShow = true
            forceHide = false
        }
    }


}
