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
import "../../../elements"

Rectangle {

    id: tile_top

    width: avail_top.width-10
    height: editmode ? (dsctxt.height+row.height+10) : dsctxt.height
    Behavior on height { NumberAnimation { duration: 200 } }
    radius: 5
    clip: true
    color: hovered ? "#2a2a2a" : "#222222"
    Behavior on color { ColorAnimation { duration: 200 } }

    property var activeShortcuts: []

    property bool hovered: false
    property bool editmode: false

    signal showNewShortcut()

    Text {
        id: dsctxt
        x: 5
        height: 30
        verticalAlignment: Text.AlignVCenter
        text: avail_top.available[index][1]
        color: "white"
        font.bold: true
    }

    Text {
        id: shtxt
        x: dsctxt.x+dsctxt.width+20
        height: 30
        verticalAlignment: Text.AlignVCenter
        color: "#aaaaaa"
        text: tile_top.activeShortcuts.length==0 ? "<i>[" + em.pty+qsTranslate("settingsmanager_shortcuts", "no shortcut set") + "]</i>" : keymousestrings.translateShortcutList(tile_top.activeShortcuts).join("    //    ")
    }

    PQMouseArea {

        anchors.fill: parent
        height: 30

        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        tooltip: em.pty+qsTranslate("settingsmanager_shortcuts", "Click to manage shortcut")

        onEntered:
            parent.hovered = true
        onExited:
            parent.hovered = false

        onClicked:
            parent.editmode = !parent.editmode

    }

    Row {

        id: row

        x: 5
        y: dsctxt.height+5

        spacing: 5

        visible: tile_top.height > dsctxt.height

        Repeater {
            model: activeShortcuts.length
            Rectangle {
                width: txt.width+20
                height: txt.height+20
                color: "#333333"
                radius: 5
                clip: true

                // animates deleting element
                // once it reaches virtually zero, we delete the item
                Behavior on width { NumberAnimation { duration: 200 } }
                onWidthChanged: {
                    if(width < 2) {
                        var tmp = tile_top.activeShortcuts
                        tmp.splice(index, 1)
                        tile_top.activeShortcuts = tmp
                    }
                }

                Text {
                    id: txt
                    x: 10
                    y: 10
                    color: "white"
                    text: keymousestrings.translateShortcut(tile_top.activeShortcuts[index])
                }

                Rectangle {
                    id: delrect
                    anchors.fill: parent
                    color: "#dd661111"
                    radius: 5
                    opacity: hovered ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    visible: opacity>0
                    property bool hovered: false
                    Text {
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: "white"
                        font.bold: true
                        text: "x"
                    }
                }
                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    tooltip: em.pty+qsTranslate("settingsmanager_shortcuts", "Click to delete shortcut")
                    onEntered: {
                        delrect.hovered = true
                        tile_top.hovered = true
                    }
                    onExited:
                        delrect.hovered = false
                    onClicked:
                        parent.width = 0    // once this reaches 0 the item will be deleted
                }
            }
        }

        Rectangle {
            width: newtxt.width+20
            height: newtxt.height+20
            color: hovered ? "#444477" : "#333366"
            Behavior on color { ColorAnimation { duration: 200 } }
            radius: 5

            property bool hovered: false

            Text {
                id: newtxt
                x: 10
                y: 10
                color: "white"
                //: Used as in 'add new shortcut'. Please keep short!
                text: "[" + em.pty+qsTranslate("settingsmanager_shortcuts", "add new") + "]"
            }

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    parent.hovered = true
                    tile_top.hovered = true
                }
                onExited:
                    parent.hovered = false
                onClicked:
                    loadAndShowAddNew()
            }
        }

    }

    Loader { id: addnewloader }

    function loadAndShowAddNew() {
        if(addnewloader.source != "PQNewShortcut.qml")
            addnewloader.source = "PQNewShortcut.qml"
        showNewShortcut()
    }

    Component.onCompleted:
        load()

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQShortcuts.setShortcut(avail_top.available[index][0], activeShortcuts)
        }

    }

    function load() {
        activeShortcuts = PQShortcuts.getShortcutsForCommand(avail_top.available[index][0]).slice(1)
    }

    function addNewCombo(combo) {
        activeShortcuts.push(combo)
        activeShortcutsChanged()
    }

}
