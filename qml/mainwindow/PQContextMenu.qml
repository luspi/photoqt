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

    width: submenu.width+30
    height: submenu.height+20

    visible: false

    modality: Qt.NonModal
    flags: Qt.FramelessWindowHint|Qt.WindowStaysOnTopHint

    color: "transparent"

    property bool containsMouse: false

    Rectangle {
        anchors.fill: parent
        color: "#dd2f2f2f"
        radius: 5
    }

    onActiveChanged: {
        if(!active)
            hideMenu()
    }

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

        ["rename.svg",
          "",
          //: This is an entry in the main menu on the right. Please keep short!
          ["__rename",em.pty+qsTranslate("MainMenu", "Rename file"), 1, true]],

        ["copy.svg",
          "",
          //: This is an entry in the main menu on the right. Please keep short!
          ["__copy",em.pty+qsTranslate("MainMenu", "Copy file"), 1, true]],

        ["move.svg",
          "",
          //: This is an entry in the main menu on the right. Please keep short!
          ["__move",em.pty+qsTranslate("MainMenu", "Move file"), 1, true]],

        ["delete.svg",
          "",
          //: This is an entry in the main menu on the right. Please keep short!
          ["__delete",em.pty+qsTranslate("MainMenu", "Delete file"), 1, true]],

        ["",
         ""],

        //: This is an entry in the main menu on the right. Please keep short!
        ["clipboard.svg",
         "",
         ["__clipboard", em.pty+qsTranslate("MainMenu", "Copy to clipboard"), 1, true]],

        //: This is an entry in the main menu on the right. Please keep short!
        ["faces.svg",
         "",
         ["__tagFaces", em.pty+qsTranslate("MainMenu", "Tag faces"), 1, true]],

        //: This is an entry in the main menu on the right. Please keep short!
        ["scale.svg",
         "",
         ["__scale", em.pty+qsTranslate("MainMenu", "Scale image"), 1, true]],

        //: This is an entry in the main menu on the right. Please keep short!
        ["wallpaper.svg",
         "",
         ["__wallpaper", em.pty+qsTranslate("MainMenu", "Set as wallpaper"), 1, true]],

        ["",
         ""],

        //: This is an entry in the main menu on the right. Please keep short!
        ["metadata.svg",
         "",
         ["__showMetaData", PQSettings.metadataElementVisible ? (em.pty+qsTranslate("MainMenu", "Hide metadata")) : (em.pty+qsTranslate("MainMenu", "Show metadata")), 1, true]],

        //: This is an entry in the main menu on the right. Please keep short!
        ["histogram.svg",
         "",
         ["__histogram", PQSettings.histogramVisible ? (em.pty+qsTranslate("MainMenu", "Hide histogram")) : (em.pty+qsTranslate("MainMenu", "Show histogram")), 1, true]],

    ]

    property var allitems_external: []

    property var allitems: allitems_external.length > 0 ? (allitems_internal.concat([["",""]]).concat(allitems_external)) : allitems_internal

    Item {

        id: submenu

        x: 10
        y: 10
        width: listview.width
        height: listview.height+10

        ListView {

            id: listview

            x: 5
            y: 5
            width: maxWidth
            height: childrenRect.height

            model: allitems.length

            boundsBehavior: ListView.StopAtBounds

            property int maxWidth: 100

            delegate: Item {

                width: managerow.width
                height: sep.visible ? 12 : (managerow.height+10)

                property int topindex: index

                Item {
                    id: sep
                    y: 6
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

                    onWidthChanged:
                        listview.maxWidth = Math.max(listview.maxWidth, width)

                    spacing: 10
                    visible: !sep.visible
                    clip: true
                    Image {
                        width: 20
                        height: 20
                        source: (allitems[index][0].toString().match("^icn:")=="icn:") ?
                                    (handlingExternal.getIconPathFromTheme(allitems[index][0].slice(4))) :
                                    (allitems[index][0]!="" ? ("/mainmenu/"+allitems[index][0]) : "")
                        sourceSize: Qt.size(width, height)
                        smooth: false
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
                                smooth: false
                                Behavior on opacity { NumberAnimation { duration: 100 } }
                                source: visible ? ("/mainmenu/"+allitems[topindex][2+index][1].slice(4)) : ""
                                sourceSize: Qt.size(width, height)
                            }
                            Text {
                                id: txt
                                y: (parent.parent.height-height)/2
                                visible: !img.visible
                                color: enabled ? (parent.hovered ? "white" : "#cccccc") : "#555555"
                                Behavior on color { ColorAnimation { duration: 100 } }
                                text: visible ? (allitems[topindex][2+index][1] + "  ") : ""
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

                                    HandleShortcuts.executeInternalFunction(allitems[topindex][2+index][0], allitems[topindex][2+index][5])

                                    if(allitems[topindex][2+index].length > 4 && allitems[topindex][2+index][4] == "extern")  {
                                        if(allitems[topindex][2+index][2])
                                            toplevel.closePhotoQt()
                                        else
                                            hideMenu()
                                    } else {
                                        if(allitems[topindex][2+index][2])
                                            hideMenu()
                                    }

                                }
                            }
                        }
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
            entries.push(["icn:"+tmpentries[i][0], "", [tmpentries[i][1], tmpentries[i][2], 1*tmpentries[i][3], true, "extern", tmpentries[i][4]]])
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
