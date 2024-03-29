/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

import QtQuick

import PQCNotify
import PQCScriptsShortcuts
import PQCFileFolderModel

Item {

    id: entrytop

    property int smallestWidth: 0
    property bool alignCenter: false

    width: smallestWidth==0 ? Math.max(mainmenu_top.colwidth, row.width+10) : Math.max(smallestWidth, row.width+10)
    height: row.height+10

    property alias font: entry.font

    property string img: ""
    property string img_end: ""
    property string txt: ""
    property string cmd: ""
    property bool closeMenu: false
    property bool active: true
    property string tooltip: txt

    property bool customEntry: false
    property string custom_args: ""
    property string custom_close: ""

    property bool hovered: false

    signal clicked()

    Rectangle {
        anchors.fill: parent
        color: PQCLook.baseColorHighlight
        radius: 5
        opacity: entrytop.hovered ? 0.4 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    Row {

        id: row

        x: alignCenter ? (parent.width-width)/2 : 5
        y: 5
        spacing: 10

        Image {
            visible: img!=""
            sourceSize: Qt.size(entry.height, entry.height)
            source: img.startsWith("data:image/png;base64") ? img : (img!="" ? ("image://svg/:/white/" + img) : "")
            opacity: active ? (entrytop.hovered ? 1 : 0.8) : 0.4
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

        PQText {
            id: entry
            text: txt
            opacity: active ? (entrytop.hovered ? 1 : 0.8) : 0.4
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

        Image {
            visible: img_end!=""
            sourceSize: Qt.size(entry.height, entry.height)
            source: (img_end!="") ? ("image://svg/:/white/" + img_end) : ""
            opacity: active ? (entrytop.hovered ? 1 : 0.8) : 0.4
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

    }

    PQMouseArea {
        enabled: parent.active
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        text: entrytop.tooltip
        onEntered:
            entrytop.hovered = true
        onExited:
            entrytop.hovered = false
        onClicked: {
            if(cmd == "") {
                entrytop.clicked()
            } else if(!customEntry || cmd.startsWith("__")) {
                PQCNotify.executeInternalCommand(cmd)
            } else {
                PQCScriptsShortcuts.executeExternal(cmd, custom_args, PQCFileFolderModel.currentFile);
                if(custom_close == "1")
                    toplevel.close()
            }

            if(closeMenu && !PQCSettings.interfacePopoutMainMenu)
                mainmenu_top.hideMainMenu()
        }
    }

}
