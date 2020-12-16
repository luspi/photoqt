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

import "../../../elements"

Rectangle {

    id: shcont

    color: "#333333"
    radius: 10

    width: cont.width-25
    height: col.height+20

    property alias category: cat.text
    property alias subtitle: subcat.text
    property var available: ({})
    property bool thisIsAnExternalCategory: false

    property var active: []

    signal newShortcutCombo(var combo)

    Column {

        id: col

        x: 10
        y: 10

        Text {
            id: cat
            color: "white"
            //: Category here refers to shortcut categories.
            text: em.pty+qsTranslate("settingsmanager_shortcuts", "Category")
            font.bold: true
            font.pointSize: 12
            x: (parent.width-width)/2
        }

        Item {
            width: 1
            height: 5
        }

        Text {
            id: subcat
            color: "#aaaaaa"
            font.pointSize: 10
            x: (parent.width-width)/2
            visible: text != ""
        }

        Item {
            width: 1
            height: 5
        }

        Row {
            width: shcont.width
            Text {
                width: parent.width/2
                horizontalAlignment: Text.AlignHCenter
                color: "white"
                //: As in: enabled shortcuts
                text: em.pty+qsTranslate("settingsmanager_shortcuts", "Active shortcuts")
            }
            Text {
                width: parent.width/2
                horizontalAlignment: Text.AlignHCenter
                color: "white"
                //: Available commands that can be used for shortcuts.
                text: em.pty+qsTranslate("settingsmanager_shortcuts", "Available commands")
            }
        }

        Item {
            width: 1
            height: 5
        }

        Row {

            spacing: 10

            PQActiveShortcuts { id: act; thisIsAnExternalCategory: shcont.thisIsAnExternalCategory }
            PQAvailableCommands { id: ava; thisIsAnExternalCategory: shcont.thisIsAnExternalCategory }

        }

        PQDetectCombo {
            id: detectcombo
            onVisibleChanged: {
                if(!visible)
                    newShortcutCombo(currentcombo)
             }
        }

    }

    function loadTiles() {
        act.loadTiles()
    }
    function addShortcut(cmd) {
        act.addShortcut(cmd)
    }
    function getActiveShortcuts() {
        return act.getActiveShortcuts()
    }

}
