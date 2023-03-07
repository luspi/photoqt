/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

    id: avail_top

    width: cont.width-2*col.x-scroll.width
    height: col.height

    radius: 10
    color: "#333333"

    property string category: ""
    property string subtitle: ""
    property var activeShortcuts: []

    signal saveExternalShortcuts()

    PQButton {
        x: 10
        y: 10
        backgroundColor: "#222222"
        //: Used on button as in 'add new external shortcut'. Please keep short!
        text: em.pty+qsTranslate("settingsmanager_shortcuts", "Add new")
        onClicked: {
            activeShortcuts.push([":://:://::", "0", ""])
            activeShortcutsChanged()
        }
    }

    Column {
        id: col
        x: 5
        y: 5
        width: avail_top.width-10
        spacing: 10

        Item {
            width: 1
            height: 1
        }

        PQText {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            font.weight: baselook.boldweight
            text: category
        }

        PQText {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: subtitle
            wrapMode: Text.WordWrap
        }

        Repeater {

            model: activeShortcuts.length

            delegate: PQExternalShortcutTile {}
        }

        Item {
            width: 1
            height: activeShortcuts.length==0 ? 50 : 1
        }

    }

    Component.onCompleted:
        load()

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQShortcuts.deleteAllExternalShortcuts()
            avail_top.saveExternalShortcuts()
        }

    }

    function load() {
        activeShortcuts = PQShortcuts.getAllExternalShortcuts()
    }

}
