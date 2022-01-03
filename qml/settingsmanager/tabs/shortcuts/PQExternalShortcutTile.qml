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
    height: iHaveBeenDeleted ? 0 : dsctxt.height+10
    Behavior on height { NumberAnimation { duration: 200 } }

    radius: 5
    clip: true

    color: hovered ? "#2a2a2a" : "#222222"
    Behavior on color { ColorAnimation { duration: 200 } }

    visible: height>0

    property bool hovered: false
    property bool iHaveBeenDeleted: false

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
            checked: (avail_top.activeShortcuts[index][1]*1==1)
        }

        PQLineEdit {
            id: dsctxt
            height: 30
            text: avail_top.activeShortcuts[index][0]
        }

        Rectangle {

            id: shtxt
            height: 30
            width: shtxt_text.width+20
            color: hovered ? "#444444" : "#2a2a2a"
            Behavior on color { ColorAnimation { duration: 200 } }
            radius: 5

            property bool hovered: false

            Text {
                id: shtxt_text
                x: 10
                height: parent.height
                verticalAlignment: Text.AlignVCenter
                color: "#aaaaaa"
                property string sh: avail_top.activeShortcuts[index][2]
                text: (sh=="" ? "<i>[" + em.pty+qsTranslate("settingsmanager_shortcuts", "no shortcut set") + "]</i>" : keymousestrings.translateShortcut(sh))
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
                    iHaveBeenDeleted = true
                }
            }

        }

    }

    PQNewShortcut {}

    Connections {

        target: avail_top

        onSaveExternalShortcuts: {
            if(!iHaveBeenDeleted)
                PQShortcuts.setShortcut(dsctxt.text, [(close_chk.checked?"1":"0"), shtxt_text.sh])
        }

    }

    function addNewCombo(combo) {
        shtxt_text.sh = combo
    }

}
