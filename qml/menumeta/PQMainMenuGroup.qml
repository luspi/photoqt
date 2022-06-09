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
import "../elements"
import "../shortcuts/handleshortcuts.js" as HandleShortcuts

Item {

    id: top

    width: parent.width
    height: headingrect.height+submenu.height

    // each entry is of the same form:
    // [icon name,
    //  title text (inactive text) - optional (leave as "" if not wanted),
    //  all options as individual lists: [command, name, hide=1/close=2]
    // ]
    property var allitems: []

    // setting/leaving this property empty hides the header bar and keeps the submenu always visible
    property alias heading: headingtxt.text

    // whether the shortcut is guaranteed to be internal or external
    property bool callExternal: false

    property alias expanded: submenu.showme

    Rectangle {

        id: headingrect

        x: 0
        width: parent.width
        height: visible ? (headingtxt.height+20) : 0
        visible: headingtxt.text!=""

        clip: true

        property bool hovered: false

        color: hovered ? "#282828" : "#181818"
        Behavior on color { ColorAnimation { duration: 100 } }

        Image {
            width: 15
            height: 15
            x: 20
            y: (parent.height-height)/2
            opacity: 0.2
            source: submenu.showme ? "/mainmenu/zoomout.png" : "/mainmenu/zoomin.png"
        }

        Text {
            id: headingtxt
            x: (parent.width-width)/2
            y: 10
            color: "#cccccc"
            font.pointSize: 13
        }

        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: parent.hovered = true
            onExited: parent.hovered = false
            onClicked:
                submenu.showme = !submenu.showme
        }


    }

    Rectangle {

        id: submenu

        property bool showme: (headingtxt.text=="")

        y: headingrect.height
        width: parent.width
        height: showme ? listview.height+10 : 0
        Behavior on height { NumberAnimation { duration: 250 } }

        color: headingtxt.text!="" ? "#111111" : "transparent"

        clip: true

        ListView {

            id: listview

            x: 5
            y: 5
            width: parent.width-10
            height: childrenRect.height

            model: allitems.length

            boundsBehavior: ListView.StopAtBounds

            delegate: Item {

                width: listview.width
                height: managerow.height+10

                property int topindex: index

                Row {
                    id: managerow
                    y: 5
                    height: childrenRect.height
                    width: childrenRect.width
                    spacing: 10
                    Image {
                        width: 20
                        height: 20
                        source: (allitems[index][0].toString().match("^icn:")=="icn:") ? (handlingExternal.getIconPathFromTheme(allitems[index][0].slice(4))) : ("/mainmenu/"+allitems[index][0]+".png")
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

                                    if(callExternal)
                                        handlingExternal.executeExternal(allitems[topindex][2+index][0], filefoldermodel.currentFilePath)
                                    else
                                        HandleShortcuts.executeInternalFunction(allitems[topindex][2+index][0])

                                    if(allitems[topindex][2+index][2] == 1)
                                        mainmenu_top.opacity = 0
                                    else if(allitems[topindex][2+index][2] == 2)
                                        toplevel.closePhotoQt()

                                }
                            }
                        }
                    }

                }

            }

        }

    }

}
