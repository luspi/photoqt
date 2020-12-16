/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
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
import "../elements"
import "../shortcuts/handleshortcuts.js" as HandleShortcuts

Rectangle {

    id: mainmenu_top

    color: "#cc000000"

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height
    width: (PQSettings.mainMenuPopoutElement ? parentWidth : PQSettings.mainMenuWindowWidth)
    height: parentHeight+2
    x: parentWidth-width+1
    y: -1

    border.color: "#55bbbbbb"
    border.width: 1

    opacity: 0
    visible: opacity != 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.mainMenuPopoutElement ? 0 : PQSettings.animationDuration*100 } }

    Connections {
        target: variables
        onMousePosChanged: {
            if(PQSettings.mainMenuPopoutElement)
                return
            if(variables.mousePos.x > toplevel.width-(PQSettings.hotEdgeWidth+5) && !variables.slideShowActive && !variables.faceTaggingActive)
                mainmenu_top.opacity = 1
            else
                mainmenu_top.opacity = 0
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
        if(PQSettings.mainMenuPopoutElement)
                mainmenu_top.opacity = 1
        readExternalContextmenu()
    }

    MouseArea {
        anchors.fill: parent;
        hoverEnabled: true

        PQMouseArea {

            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: 5

            enabled: !PQSettings.mainMenuPopoutElement

            hoverEnabled: true

            cursorShape: Qt.SizeHorCursor

            tooltip: em.pty+qsTranslate("MainMenu", "Click and drag to resize main menu")

            property int oldMouseX

            onPressed:
                oldMouseX = mouse.x

            onReleased:
                PQSettings.mainMenuWindowWidth = mainmenu_top.width

            onPositionChanged: {
                if (pressed) {
                    var w = mainmenu_top.width + (oldMouseX-mouse.x)
                    if(w < 2*toplevel.width/3)
                        mainmenu_top.width = w
                }
            }

        }

    }

    property var allitems_static: [
        //: This is an entry in the main menu on the right. Please keep short!
        [["__open", "open", em.pty+qsTranslate("MainMenu", "Open File"), "hide"]],
        //: This is an entry in the main menu on the right. Please keep short!
        [["__settings", "settings", em.pty+qsTranslate("MainMenu", "Settings"), "hide"]],
        //: This is an entry in the main menu on the right. Please keep short!
        [["__wallpaper", "settings", em.pty+qsTranslate("MainMenu", "Wallpaper"), "hide"]],
        //: This is an entry in the main menu on the right. Please keep short!
        [["slideshow","slideshow",em.pty+qsTranslate("MainMenu", "Slideshow")],
                //: This is an entry in the main menu on the right, used as in: setting up a slideshow. Please keep short!
                ["__slideshow","",em.pty+qsTranslate("MainMenu", "setup"), "hide"],
                //: This is an entry in the main menu on the right, used as in: quickstarting a slideshow. Please keep short!
                ["__slideshowQuick","",em.pty+qsTranslate("MainMenu", "quickstart"), "hide"]],
        //: This is an entry in the main menu on the right. Please keep short!
        [["__filterImages", "filter", em.pty+qsTranslate("MainMenu", "Filter Images in Folder"), "hide"]],
        //: This is an entry in the main menu on the right. Please keep short!
        [["__hideMeta", "metadata", em.pty+qsTranslate("MainMenu", "Show/Hide Metadata"), "donthide"]],
        //: This is an entry in the main menu on the right. Please keep short!
        [["__histogram", "histogram", em.pty+qsTranslate("MainMenu", "Show/Hide Histogram"), "donthide"]],
        //: This is an entry in the main menu on the right. Please keep short!
        [["__tagFaces", "faces", em.pty+qsTranslate("MainMenu", "Face tagging mode"), "hide"]],
        //: This is an entry in the main menu on the right. Please keep short!
        [["__about", "about", em.pty+qsTranslate("MainMenu", "About PhotoQt"), "hide"]],
        //: This is an entry in the main menu on the right. Please keep short!
        [["__quit", "quit", em.pty+qsTranslate("MainMenu", "Quit"), "hide"]],

        [["heading","",""]],

        //: This is an entry in the main menu on the right, used as in: Go To some image. Please keep short!
        [["","goto",em.pty+qsTranslate("MainMenu", "Go to")],
                //: This is an entry in the main menu on the right, used as in: go to previous image. Please keep short!
                ["__prev","",em.pty+qsTranslate("MainMenu", "previous"), "donthide"],
                //: This is an entry in the main menu on the right, used as in: go to next image. Please keep short!
                ["__next","",em.pty+qsTranslate("MainMenu", "next"), "donthide"],
                //: This is an entry in the main menu on the right, used as in: go to first image. Please keep short!
                ["__goToFirst","",em.pty+qsTranslate("MainMenu", "first"), "donthide"],
                //: This is an entry in the main menu on the right, used as in: go to last image. Please keep short!
                ["__goToLast","",em.pty+qsTranslate("MainMenu", "last"), "donthide"]],
        //: This is an entry in the main menu on the right, used as in: Zoom image. Please keep short!
        [["zoom","zoom",em.pty+qsTranslate("MainMenu", "Zoom")],
                ["__zoomIn","","+", "donthide"],
                ["__zoomOut","","-", "donthide"],
                ["__zoomReset","","0", "donthide"],
                ["__zoomActual","","1:1", "donthide"]],
        //: This is an entry in the main menu on the right, used as in: Rotate image. Please keep short!
        [["rotate","rotate",em.pty+qsTranslate("MainMenu", "Rotate")],
                //: This is an entry in the main menu on the right, used as in: Rotate image left. Please keep short!
                ["__rotateL","",em.pty+qsTranslate("MainMenu", "left"), "donthide"],
                //: This is an entry in the main menu on the right, used as in: Rotate image right. Please keep short!
                ["__rotateR","",em.pty+qsTranslate("MainMenu", "right"), "donthide"],
                //: This is an entry in the main menu on the right, used as in: Reset rotation of image. Please keep short!
                ["__rotate0","",em.pty+qsTranslate("MainMenu", "reset"), "donthide"]],
        //: This is an entry in the main menu on the right, used as in: Flip/Mirror image. Please keep short!
        [["flip","flip",em.pty+qsTranslate("MainMenu", "Flip")],
                //: This is an entry in the main menu on the right, used as in: Flip/Mirror image horizontally. Please keep short!
                ["__flipH","",em.pty+qsTranslate("MainMenu", "horizontal"), "donthide"],
                //: This is an entry in the main menu on the right, used as in: Flip/Mirror image vertically. Please keep short!
                ["__flipV","",em.pty+qsTranslate("MainMenu", "vertical"), "donthide"],
                //: This is an entry in the main menu on the right, used as in: Reset flip/mirror of image. Please keep short!
                ["__flipReset","",em.pty+qsTranslate("MainMenu", "reset"), "donthide"]],
        //: This is an entry in the main menu on the right, used to refer to the current file (specifically the file, not directly the image). Please keep short!
        [["","copy",em.pty+qsTranslate("MainMenu", "File")],
                //: This is an entry in the main menu on the right, used as in: rename file. Please keep short!
                ["__rename","",em.pty+qsTranslate("MainMenu", "rename"), "hide"],
                //: This is an entry in the main menu on the right, used as in: copy file. Please keep short!
                ["__copy","",em.pty+qsTranslate("MainMenu", "copy"), "hide"],
                //: This is an entry in the main menu on the right, used as in: move file. Please keep short!
                ["__move","",em.pty+qsTranslate("MainMenu", "move"), "hide"],
                //: This is an entry in the main menu on the right, used as in: delete file. Please keep short!
                ["__delete","",em.pty+qsTranslate("MainMenu", "delete"), "hide"]],

        [["heading","",""]],

        //: This is an entry in the main menu on the right. Please keep short!
        [["__scale","scale",em.pty+qsTranslate("MainMenu", "Scale Image"), "hide"]],
        //: This is an entry in the main menu on the right. Please keep short!
        [["__defaultFileManager","open",em.pty+qsTranslate("MainMenu", "Open in default file manager"), "donthide"]]
    ]
    property var allitems_external: []
    property var allitems: allitems_static.concat(allitems_external)

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

    ListView {

        id: mainlistview
        x: 10
        y: spacingbelowheader.y + spacingbelowheader.height+10
        height: parent.height-y-(helptext.height+5)
        width: parent.width-scroll.width
        model: allitems.length
        delegate: maindeleg
        clip: true

        orientation: ListView.Vertical

        ScrollBar.vertical: PQScrollBar { id: scroll }

    }

    Component {

        id: maindeleg

        ListView {

            id: subview

            property int mainindex: index
            height: 30
            width: childrenRect.width

            interactive: false

            orientation: Qt.Horizontal
            spacing: 5

            model: allitems[mainindex].length
            delegate: Row {

                spacing: 5

                Text {
                    id: sep
                    lineHeight: 1.5

                    color: "#cccccc"
                    visible: allitems[subview.mainindex].length > 1 && index > 1
                    font.bold: true
                    font.pointSize: 11
                    text: "/"
                }

                Image {
                    y: 2.5
                    width: ((source!="" || allitems[subview.mainindex][index][0]==="heading") ? val.height*0.5 : 0)
                    height: val.height*0.5
                    sourceSize.width: width
                    sourceSize.height: height
                    source: allitems[subview.mainindex][index][1]===""
                            ? "" : (allitems[subview.mainindex][index][0].slice(0,8)=="_:_EX_:_"
                                    ? handlingGeneral.getIconPathFromTheme(allitems[subview.mainindex][index][1]) :
                                      "/mainmenu/" + allitems[subview.mainindex][index][1] + ".png")
                    opacity: allitems[subview.mainindex][index][0] !== "hide" ? 1 : 0.5
                    visible: (source!="" || allitems[subview.mainindex][index][0]==="heading")
                }

                Text {

                    id: val;

                    color: (allitems[subview.mainindex][index][0]==="heading") ? "white" : "#cccccc"
                    lineHeight: 1.5

                    font.capitalization: (allitems[subview.mainindex][index][0]==="heading") ? Font.SmallCaps : Font.MixedCase

                    opacity: enabled ? 1 : 0.5

                    font.pointSize: 11
                    font.bold: true

                    enabled: ((allitems[subview.mainindex][index][0] !== "__close" &&
                               allitems[subview.mainindex][index][0] !=="heading" &&
                              (allitems[subview.mainindex].length === 1 || index > 0)))


                    // The spaces guarantee a bit of space betwene icon and text
                    text: allitems[subview.mainindex][index][2] + ((allitems[subview.mainindex].length > 1 && index == 0) ? ":" : "")

                    MouseArea {

                        anchors.fill: parent

                        hoverEnabled: true
                        cursorShape: (allitems[subview.mainindex][index][0]!=="heading" && (allitems[subview.mainindex].length === 1 || index > 0)) ?
                                         Qt.PointingHandCursor :
                                         Qt.ArrowCursor

                        onEntered: {
                            if(allitems[subview.mainindex][index][0]!=="heading" && (allitems[subview.mainindex].length === 1 || index > 0))
                                val.color = "#ffffff"
                        }
                        onExited: {
                            if(allitems[subview.mainindex][index][0]!=="heading" && (allitems[subview.mainindex].length === 1 || index > 0))
                                val.color = "#cccccc"
                        }
                        onClicked: {
                            if(allitems[subview.mainindex][index][0]!=="heading" && (allitems[subview.mainindex].length === 1 || index > 0)) {
                                if(allitems[subview.mainindex][index][3] === "hide" && !PQSettings.mainMenuPopoutElement)
                                    mainmenu_top.opacity = 0
                                var cmd = allitems[subview.mainindex][index][0]
                                var close = 0
                                if(cmd.slice(0,8) === "_:_EX_:_") {
                                    if(variables.indexOfCurrentImage != -1 && variables.allImageFilesInOrder.length > 0) {
                                        handlingExternal.executeExternal(cmd.substring(8), variables.allImageFilesInOrder[variables.indexOfCurrentImage])
                                        if(allitems[subview.mainindex][index][3] === "close")
                                            toplevel.closePhotoQt()
                                    }
                                    return
                                }
                                HandleShortcuts.executeInternalFunction(cmd)
                            }
                        }

                    }

                }

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
            tooltip: "http://photoqt.org/man"
            cursorShape: Qt.PointingHandCursor
            onClicked: Qt.openUrlExternally("http://photoqt.org/man")
        }

    }

    Connections {
        target: filewatcher
        onContextmenuChanged: {
            readExternalContextmenu()
        }
    }

    function readExternalContextmenu() {
        var tmpentries = handlingExternal.getContextMenuEntries()
        var entries = [[["heading","",""]]]
        for(var i = 0; i < tmpentries.length; ++i) {
            entries.push([tmpentries[i]])
        }
        allitems_external = entries

    }

}
