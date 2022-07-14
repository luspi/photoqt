/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

Rectangle {

    id: mainmenu_top

    color: "#ee000000"

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height
    width: (PQSettings.interfacePopoutMainMenu ? parentWidth : PQSettings.mainmenuElementWidth)
    height: parentHeight+2
    x: parentWidth-width+1
    y: -1

    border.color: "#55bbbbbb"
    border.width: 1

    opacity: 0
    visible: opacity != 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.interfacePopoutMainMenu ? 0 : PQSettings.imageviewAnimationDuration*100 } }
    onOpacityChanged:
        variables.mainMenuVisible = (opacity>0)

    property bool resizePressed: false

    Connections {
        target: variables
        onMousePosChanged: {
            if(PQSettings.interfacePopoutMainMenu)
                return
            if(mainmenu_top.visible && !resizePressed && variables.mousePos.x < toplevel.width-width-5)
                mainmenu_top.opacity = 0
            else if(!mainmenu_top.visible && !variables.slideShowActive && !variables.faceTaggingActive && variables.mousePos.x > toplevel.width-(2*PQSettings.interfaceHotEdgeSize+5) && variables.mousePos.y > 1.2*windowbuttons.height)
                mainmenu_top.opacity = 1
        }
        onSlideShowActiveChanged: {
            if(variables.slideShowActive)
                mainmenu_top.opacity = 0
        }
        onFaceTaggingActiveChanged: {
            if(variables.faceTaggingActive)
                mainmenu_top.opacity = 0
        }
    }

    Component.onCompleted: {
        if(PQSettings.interfacePopoutMainMenu)
                mainmenu_top.opacity = 1
        readExternalContextmenu()
    }

    MouseArea {

        anchors.fill: parent;
        hoverEnabled: true

        acceptedButtons: Qt.RightButton|Qt.MiddleButton|Qt.LeftButton

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

    property var allitems_external: []

    Text {

        id: heading
        y: 10
        x: (parent.width-width)/2
        font.pointSize: 15
        color: "white"
        font.bold: true
        //: This is the heading of the main menu element
        text: em.pty+qsTranslate("MainMenu", "Main Menu")

    }

    Rectangle {
        id: spacingbelowheader
        x: 5
        y: heading.y+heading.height+10
        height: 1
        width: parent.width-10
        color: "#88ffffff"
    }

    Flickable {

        id: flick

        x: 10
        y: spacingbelowheader.y + spacingbelowheader.height+10
        width: parent.width-20
        height: parent.height-y-helptext.height-10
        contentHeight: col.height

        clip: true

        boundsBehavior: Flickable.OvershootBounds
        ScrollBar.vertical: PQScrollBar {}

        PQMouseArea {
            anchors.fill: parent
            onWheel: {
                var newy = flick.contentY - wheel.angleDelta.y
                // set new contentY, but don't move beyond top/bottom end of view
                flick.contentY = Math.max(0, Math.min(newy, flick.contentHeight-flick.height))
            }
        }

        Column {

            id: col

            width: parent.width

            PQMainMenuGroup {
                heading: ""
                allitems: [

                    ["open",
                     "",
                     //: This is an entry in the main menu on the right. Please keep short!
                     ["__open", em.pty+qsTranslate("MainMenu", "Open file (browse images)"), 1, false]],

                    ["settings",
                     "",
                     //: This is an entry in the main menu on the right. Please keep short!
                     ["__settings", em.pty+qsTranslate("MainMenu", "Settings"), 1, false]],

                    ["about",
                     "",
                     //: This is an entry in the main menu on the right. Please keep short!
                     ["__about", em.pty+qsTranslate("MainMenu", "About PhotoQt"), 1, false]],

                    ["quit",
                     "",
                     //: This is an entry in the main menu on the right. Please keep short!
                     ["__quit", em.pty+qsTranslate("MainMenu", "Quit"), 1, false]]
                ]
            }

            Item { width: parent.width; height: 10 }

            Rectangle {
                width: parent.width
                height: 1
                color: "#555555"
            }

            Item { width: parent.width; height: 10 }

            PQMainMenuGroup {
                heading: ""
                allitems: [
                    ["goto",
                     em.pty+qsTranslate("MainMenu", "Go to"),
                     ["__prev", "img:leftarrow", 0, true],
                     ["__next", "img:rightarrow", 0, true],
                     //: This is an entry in the main menu on the right, used as in: first image in list. Please keep short!
                     ["__goToFirst", em.pty+qsTranslate("MainMenu", "first"), 0, true],
                     //: This is an entry in the main menu on the right, used as in: last image in list. Please keep short!
                     ["__goToLast", em.pty+qsTranslate("MainMenu", "last"), 0, true]],

                    ["zoom",
                     em.pty+qsTranslate("MainMenu", "Zoom"),
                     ["__zoomIn", "img:zoomin", 0, true],
                     ["__zoomOut", "img:zoomout", 0, true],
                     ["__zoomReset", "img:reset", 0, true],
                     ["__zoomActual", "1:1", 0, true]],

                    ["rotate",
                     em.pty+qsTranslate("MainMenu", "Rotate"),
                     ["__rotateL", "img:rotateleft", 0, true],
                     ["__rotateR", "img:rotateright", 0, true],
                     ["__rotate0", "img:reset", 0, true]],

                    ["flip",
                     em.pty+qsTranslate("MainMenu", "Flip"),
                     ["__flipH", "img:leftrightarrow", 0, true],
                     ["__flipV", "img:updownarrow", 0, true],
                     ["__flipReset", "img:reset", 0, true]]

                ]
            }

            Item { width: parent.width; height: 10 }

            Rectangle {
                width: parent.width
                height: 1
                color: "#555555"
            }

            Item { width: parent.width; height: 10 }

            PQMainMenuGroup {

                heading: em.pty+qsTranslate("MainMenu", "current image/file")

                allitems: [
                    ["copy",
                      "",
                     //: This is an entry in the main menu on the right, used as in: rename file. Please keep short!
                      ["__rename",em.pty+qsTranslate("MainMenu", "rename"), 1, true],
                      //: This is an entry in the main menu on the right, used as in: copy file. Please keep short!
                      ["__copy",em.pty+qsTranslate("MainMenu", "copy"), 1, true],
                      //: This is an entry in the main menu on the right, used as in: move file. Please keep short!
                      ["__move",em.pty+qsTranslate("MainMenu", "move"), 1, true],
                      //: This is an entry in the main menu on the right, used as in: delete file. Please keep short!
                      ["__delete",em.pty+qsTranslate("MainMenu", "delete"), 1, true]],

                    //: This is an entry in the main menu on the right. Please keep short!
                    ["metadata",
                     "",
                     ["__showMetaData", em.pty+qsTranslate("MainMenu", "Show/Hide metadata"), 0, true]],

                    //: This is an entry in the main menu on the right. Please keep short!
                    ["histogram",
                     "",
                     ["__histogram", em.pty+qsTranslate("MainMenu", "Show/Hide histogram"), 0, true]],

                    //: This is an entry in the main menu on the right. Please keep short!
                    ["settings",
                     "",
                     ["__wallpaper", em.pty+qsTranslate("MainMenu", "Wallpaper"), 1, true]],

                    //: This is an entry in the main menu on the right. Please keep short!
                    ["faces",
                     "",
                     ["__tagFaces", em.pty+qsTranslate("MainMenu", "Face tagging mode"), 1, true]],

                    //: This is an entry in the main menu on the right. Please keep short!
                    ["clipboard",
                     "",
                     ["__clipboard", em.pty+qsTranslate("MainMenu", "Copy to clipboard"), 1, true]],

                    //: This is an entry in the main menu on the right. Please keep short!
                    ["scale",
                     "",
                     ["__scale", em.pty+qsTranslate("MainMenu", "Scale image"), 1, true]]

                ]

                expanded: PQSettings.mainmenuExpandCurrentImage
                onExpandedChanged:
                    PQSettings.mainmenuExpandCurrentImage = expanded

            }

            PQMainMenuGroup {

                heading: em.pty+qsTranslate("MainMenu", "current folder")
                allitems: [

                    ["sort",
                     //: This is an entry in the main menu on the right. Please keep short!
                     em.pty+qsTranslate("MainMenu", "Advanced sort"),
                     //: This is an entry in the main menu on the right, used as in: setting up a slideshow. Please keep short!
                     ["__advancedSort", em.pty+qsTranslate("MainMenu", "setup"), 1, true],
                     //: This is an entry in the main menu on the right, used as in: quickstarting a slideshow. Please keep short!
                     ["__advancedSortQuick", em.pty+qsTranslate("MainMenu", "quickstart"), 1, true]],

                    //: This is an entry in the main menu on the right. Please keep short!
                    ["slideshow",
                     em.pty+qsTranslate("MainMenu", "Slideshow"),
                     //: This is an entry in the main menu on the right, used as in: setting up a slideshow. Please keep short!
                     ["__slideshow", em.pty+qsTranslate("MainMenu", "setup"), 1, true],
                     //: This is an entry in the main menu on the right, used as in: quickstarting a slideshow. Please keep short!
                     ["__slideshowQuick", em.pty+qsTranslate("MainMenu", "quickstart"), 1, true]],

                    //: This is an entry in the main menu on the right. Please keep short!
                    ["filter",
                     "",
                     ["__filterImages", em.pty+qsTranslate("MainMenu", "Filter images in folder"), 1, true]],

                    //: This is an entry in the main menu on the right, 'streaming' as in stream PhotoQt to Chromecast devices. Please keep short!
                    ["chromecast",
                     "",
                     ["__chromecast", em.pty+qsTranslate("MainMenu", "Streaming (Chromecast)"), 1, true]],

                    //: This is an entry in the main menu on the right. Please keep short!
                    ["open",
                     "",
                     ["__defaultFileManager", em.pty+qsTranslate("MainMenu", "Open in default file manager"), 0, true]]

                ]

                expanded: PQSettings.mainmenuExpandCurrentFolder
                onExpandedChanged:
                    PQSettings.mainmenuExpandCurrentFolder = expanded

            }

            PQMainMenuGroup {

                id: custom

                heading: em.pty+qsTranslate("MainMenu", "custom commands")
                callExternal: true
                visible: allitems.length>0

                expanded: PQSettings.mainmenuExpandCustomCommands
                onExpandedChanged:
                    PQSettings.mainmenuExpandCustomCommands = expanded

            }

        }

    }


    Rectangle {
        anchors {
            bottom: helptext.top
            left: parent.left
            right: parent.right
        }
        height: 1
        color: "#22ffffff"

    }

    Text {

        id: helptext

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        height: 100

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        color: "grey"
        wrapMode: Text.WordWrap

        text: em.pty+qsTranslate("MainMenu", "Click here to go to the online manual for help regarding shortcuts, settings, features, ...")

        PQMouseArea {
            anchors.fill: parent
            tooltip: "https://photoqt.org/man"
            cursorShape: Qt.PointingHandCursor
            onClicked: Qt.openUrlExternally("https://photoqt.org/man")
        }

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
            source: "/popin.png"
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

    Row {
        x: (parent.width-width-10)
        y: 10
        spacing: 10

        Image {
            width: heading.height
            height: heading.height
            source: "/mainwindow/menu.png"
            opacity: mainmenu_mouse.containsMouse ? 0.8 : 0.5
            Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }
            visible: PQSettings.interfaceNavigationTopRight
            PQMouseArea {
                id: mainmenu_mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                tooltip: em.pty+qsTranslate("quickinfo", "Click here to show main menu")
                onClicked:
                    loader.passOn("mainmenu", "toggle", undefined)
            }
        }

        Image {
            width: heading.height
            height: heading.height
            source: PQSettings.interfaceWindowMode ? "/mainwindow/fullscreen_on.png" : "/mainwindow/fullscreen_off.png"
            opacity: fullscreen_mouse.containsMouse ? 0.8 : 0.5
            Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }
            PQMouseArea {
                id: fullscreen_mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                tooltip: (PQSettings.interfaceWindowMode ? em.pty+qsTranslate("quickinfo", "Click here to enter fullscreen mode")
                                                : em.pty+qsTranslate("quickinfo", "Click here to exit fullscreen mode"))
                onClicked:
                    PQSettings.interfaceWindowMode = !PQSettings.interfaceWindowMode
            }
        }

        Image {
            visible: (toplevel.visibility==Window.FullScreen) || (!PQSettings.interfaceWindowDecoration) || PQSettings.interfaceLabelsAlwaysShowX
            width: heading.height
            height: heading.height
            source: "/mainwindow/close.png"
            PQMouseArea {
                anchors.fill: parent
                anchors.rightMargin: -10
                anchors.topMargin: -10
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                tooltip: em.pty+qsTranslate("quickinfo", "Click here to close PhotoQt")
                onClicked:
                    toplevel.close()
            }
        }
    }

    Connections {
        target: filewatcher
        onContextmenuChanged: {
            readExternalContextmenu()
        }
    }

    Connections {
        target: loader
        onMainmenuPassOn: {
            if(what == "toggle")
                toggle()
        }
    }

    function readExternalContextmenu() {
        var tmpentries = handlingExternal.getContextMenuEntries()
        var entries = []
        for(var i = 0; i < tmpentries.length; ++i) {
            var e = ["icn:"+tmpentries[i][0], "", [tmpentries[i][1], tmpentries[i][2], 1*tmpentries[i][3], true]]
            entries.push(e)
        }
        custom.allitems = entries

    }

    function toggle() {
        if(PQSettings.interfacePopoutMainMenu) return
        if(mainmenu_top.opacity == 1)
            mainmenu_top.opacity = 0
        else
            mainmenu_top.opacity = 1
    }

}
