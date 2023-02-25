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

    id: avail_top

    width: cont.width-2*col.x-scroll.width
    height: col.height

    radius: 10
    color: "#333333"

    property string category: ""
    property var available: []

    Column {
        id: col
        x: 5
        width: avail_top.width-10
        spacing: 10

        Item {
            width: 1
            height: 1
        }

        Text {
            width: parent.width
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            font.bold: true
            text: category
            font.pointSize: baselook.fontsize
        }

        Repeater {
            model: available.length
            delegate: PQShortcutTile {}
        }

        Item {
            width: 1
            height: 1
        }

    }

}
