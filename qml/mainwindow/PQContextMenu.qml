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
import "../shortcuts/handleshortcuts.js" as HandleShortcuts

Window {

    id: context_top

    width: submenu.width+20
    height: submenu.height

    visible: false

    modality: Qt.NonModal
    flags: Qt.FramelessWindowHint|Qt.WindowStaysOnTopHint

    color: "#dd000000"

    property bool containsMouse: false

    MouseArea {
        id: backmouse
        anchors.fill: parent
        acceptedButtons: Qt.RightButton|Qt.LeftButton|Qt.MiddleButton
        hoverEnabled: true
        onEntered:
            context_top.containsMouse = true
        onExited:
            context_top.containsMouse = false
    }

    Item {
        id: keycatcher
        anchors.fill: parent
        Keys.onPressed:
            keycatcherhide.start()
    }
    Timer {
        id: keycatcherhide
        interval: 50
        repeat: false
        onTriggered:
            hideMenu()
    }

    property var allitems_internal: [

        ["open",
         "",
         //: This is an entry in the main menu on the right. Please keep short!
         ["__open", em.pty+qsTranslate("MainMenu", "Open file (browse images)"), 1, false]],

        ["",
         ""],

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
         ["__flipReset", "img:reset", 0, true]],

        ["",
         ""],

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
        ["faces",
         "",
         ["__tagFaces", em.pty+qsTranslate("MainMenu", "Face tagging mode"), 1, true]],

        //: This is an entry in the main menu on the right. Please keep short!
        ["clipboard",
         "",
         ["__clipboard", em.pty+qsTranslate("MainMenu", "Copy to clipboard"), 1, true]]

    ]

    property var allitems_external: []

    property var allitems: allitems_internal.concat([["",""]]).concat(allitems_external)

    Item {

        id: submenu

        width: listview.width
        height: listview.height+10

        ListView {

            id: listview

            x: 5
            y: 5
            width: Math.max(allwidths)+20
            height: childrenRect.height

            model: allitems.length

            boundsBehavior: ListView.StopAtBounds

            property var allwidths: []

            delegate: Item {

                width: managerow.width
                height: sep.visible ? 6 : (managerow.height+10)

                property int topindex: index

                Item {
                    id: sep
                    y: 3
                    width: listview.width
                    height: 1
                    visible: allitems[index][0]==""
                    Rectangle {
                        color: "#999999"
                        width: parent.width
                        height: 1
                    }
                }

                Row {
                    id: managerow
                    y: 5
                    height: sep.visible ? 0 : childrenRect.height
                    spacing: 10
                    visible: !sep.visible
                    clip: true
                    Image {
                        width: 20
                        height: 20
                        source: (allitems[index][0].toString().match("^icn:")=="icn:") ? (handlingExternal.getIconPathFromTheme(allitems[index][0].slice(4))) : (allitems[index][0]!="" ? ("/mainmenu/"+allitems[index][0]+".png") : "")
                    }

                    Text {
                        id: nametxt
                        color: "#666666"
                        visible: allitems[topindex][1]!=""
                        text: visible ? (allitems[topindex][1]+":") : ""
                        font.pointSize: 11
                        font.bold: true
                    }

                    Repeater {
                        model: allitems[topindex].length-2
                        Item {
                            width: Math.max(txt.width, img.width)
                            height: Math.max(txt.height, img.height)
                            property bool hovered: false
                            enabled: (!allitems[topindex][2+index][3] || filefoldermodel.current!=-1)
                            Image {
                                id: img
                                y: (parent.parent.height-height)/2
                                width: nametxt.height
                                height: nametxt.height
                                visible: allitems[topindex][2+index][1].toString().match("^img:")=="img:"
                                opacity: enabled ? (parent.hovered ? 1 : 0.8) : 0.2
                                Behavior on opacity { NumberAnimation { duration: 100 } }
                                source: visible ? ("/mainmenu/"+allitems[topindex][2+index][1].slice(4)+".png") : ""
                                mipmap: true
                            }
                            Text {
                                id: txt
                                y: (parent.parent.height-height)/2
                                visible: !img.visible
                                color: enabled ? (parent.hovered ? "white" : "#cccccc") : "#555555"
                                Behavior on color { ColorAnimation { duration: 100 } }
                                text: visible ? allitems[topindex][2+index][1] : ""
                                font.pointSize: 11
                                font.bold: true
                            }
                            PQMouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered:
                                    parent.hovered = true
                                onExited:
                                    parent.hovered = false
                                onClicked: {

                                    HandleShortcuts.executeInternalFunction(allitems[topindex][2+index][0])

                                    if(allitems[topindex][2+index][2] == 1)
                                        hideMenu()
                                    else if(allitems[topindex][2+index][2] == 2)
                                        toplevel.closePhotoQt()

                                }
                            }
                        }
                    }

                    Component.onCompleted: {
                        listview.allwidths.push(managerow.width)
                        listview.allwidthsChanged()
                    }

                }

            }

        }

    }

    Component.onCompleted:
        readExternalContextmenu()

    Connections {
        target: PQKeyPressMouseChecker
        onReceivedMouseButtonPress: {
            if(!context_top.containsMouse)
                hideMenu()
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
        var entries = []
        for(var i = 0; i < tmpentries.length; ++i) {
            entries.push(["icn:"+tmpentries[i][0], "", [tmpentries[i][1], tmpentries[i][2], 1*tmpentries[i][3], true]])
        }
        allitems_external = entries
    }

    function showMenu() {

        if(context_top.visible)
            return

        // this makes sure the context menu is fully visible AND shown on the screen the click appeared on.
        // if we don't enforce the latter, the context menu might appear on another screen if click happened close to the boundary between the screens

        // first we find the current screen geometry
        var curscreenX = toplevel.screen.virtualX
        var curscreenY = toplevel.screen.virtualY
        var curscreenW = toplevel.screen.width
        var curscreenH = toplevel.screen.height

        // compute the x/y for the menu
        x = curscreenX + Math.min(toplevel.x-curscreenX+variables.mousePos.x, curscreenW-width)
        y = curscreenY + Math.min(toplevel.y-curscreenY+variables.mousePos.y, curscreenH-height)

        // show menu
        context_top.show()

        // force active focus to catch any key press
        keycatcher.forceActiveFocus()

    }

    function hideMenu() {
        if(!context_top.visible)
            return
        context_top.hide()
    }

}
