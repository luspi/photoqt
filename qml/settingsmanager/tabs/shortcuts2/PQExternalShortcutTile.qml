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

    id: tile_top

    width: avail_top.width-10
    height: avail_top.activeShortcuts[index][0]!=-1 ? dsctxt.height+10 : 0
    Behavior on height { NumberAnimation { duration: 200 } }

    radius: 5
    clip: true

    color: hovered ? "#2a2a2a" : "#222222"
    Behavior on color { ColorAnimation { duration: 200 } }

    visible: height>0

    property bool hovered: false

    signal showNewShortcut()

    Row {

        spacing: 20
        y: 5

        Item {
            width: 1
            height: 1
        }

        PQCheckbox {
            id: close_chk
            y: (parent.height-height)/2
            //: checkbox in shortcuts settings, used as in: quit PhotoQt. Please keep as short as possible!
            text: em.pty+qsTranslate("settingsmanager_shortcuts", "quit")
            checked: (avail_top.activeShortcuts[index][0]*1==1)
        }

        PQLineEdit {
            id: dsctxt
            height: 30
            text: avail_top.activeShortcuts[index][2]
        }

        Rectangle {

            id: shtxt
            height: 30
            width: childrenRect.width
            color: hovered ? "#444444" : "#2a2a2a"
            Behavior on color { ColorAnimation { duration: 200 } }
            radius: 5

            property bool hovered: false

            Text {
                id: shtxt_text
                height: parent.height
                verticalAlignment: Text.AlignVCenter
                color: "#aaaaaa"
                property string sh: avail_top.activeShortcuts[index][1]
                text: "  " + (sh=="" ? "<i>[" + em.pty+qsTranslate("settingsmanager_shortcuts", "no shortcut set") + "]</i>" : keymousestrings.translateShortcut(sh)) + "  "
            }

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                tooltip: em.pty+qsTranslate("settingsmanager_shortcuts", "Click to change shortcut")
                onEntered:
                    parent.hovered = true
                onExited:
                    parent.hovered = false
                onClicked:
                    tile_top.showNewShortcut()
            }

        }

        Rectangle {

            height: 30
            width: 30

            color: hovered ? "#dd661111" : "#66661111"
            Behavior on color { ColorAnimation { duration: 200 } }
            radius: 5

            property bool hovered: false

            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: "x"
                color: "white"
            }

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                tooltip: em.pty+qsTranslate("settingsmanager_shortcuts", "Click to delete shortcut")
                onEntered:
                    parent.hovered = true
                onExited:
                    parent.hovered = false
                onClicked: {
                    avail_top.activeShortcuts[index] = [-1,"",""]
                    avail_top.activeShortcutsChanged()
                }
            }

        }

    }

    PQNewShortcut {}

    Connections {

        target: tab_shortcuts

        onSaveShortcuts: {
            if(avail_top.activeShortcuts[index][0] != -1)
                tab_shortcuts.addToList((close_chk.checked?1:0), [shtxt_text.sh], dsctxt.text)
        }

    }

    function addNewCombo(combo) {
        shtxt_text.sh = combo
    }

}
