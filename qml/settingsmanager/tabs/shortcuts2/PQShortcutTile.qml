/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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
import "../../../elements"

Rectangle {

    id: deleg

    width: avail_top.width-10
    height: editmode ? (dsctxt.height+row.height+10) : dsctxt.height
    radius: 5
    color: hovered ? "#2a2a2a" : "#222222"
    Behavior on color { ColorAnimation { duration: 200 } }

    property var activeShortcuts: []

    property bool hovered: false
    property bool editmode: false

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
        text: deleg.activeShortcuts.length==0 ? "<i>[" + em.pty+qsTranslate("settingsmanager_shortcuts", "no shortcut set") + "]</i>" : deleg.activeShortcuts.join("    //    ")
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

        visible: editmode

        Repeater {
            model: activeShortcuts.length
            Rectangle {
                width: txt.width+20
                height: txt.height+20
                color: "#333333"
                radius: 5
                Text {
                    id: txt
                    x: 10
                    y: 10
                    color: "white"
                    text: deleg.activeShortcuts[index]
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
                        deleg.hovered = true
                    }
                    onExited:
                        delrect.hovered = false
                    onClicked: {
                            var tmp = deleg.activeShortcuts
                            tmp.splice(index, 1)
                            deleg.activeShortcuts = tmp
                    }
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
                    deleg.hovered = true
                }
                onExited:
                    parent.hovered = false
            }
        }

    }

    Connections {

        target: tab_shortcuts

        onShortcutsChanged: {

            var tmp = []

            for(var iSH in tab_shortcuts.shortcuts) {
                var sh = tab_shortcuts.shortcuts[iSH]
                if(sh[2] == avail_top.available[index][0])
                    tmp.push(sh[1])
            }

            deleg.activeShortcuts = tmp

        }

    }

}
