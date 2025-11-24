/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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
import PhotoQt

Item {

    id: entrytop

    property int smallestWidth: 0
    property bool alignCenter: false

    property int menuColWidth

    width: smallestWidth==0 ? Math.max(menuColWidth, row.width+10) : Math.max(smallestWidth, row.width+10)
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
        color: PQCLook.baseBorder
        radius: 5
        opacity: entrytop.hovered ? 0.4 : 0
        Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
    }

    Row {

        id: row

        x: entrytop.alignCenter ? (parent.width-width)/2 : 5
        y: 5
        spacing: 10

        Image {
            visible: entrytop.img!=""
            sourceSize: Qt.size(entry.height, entry.height)
            source: entrytop.img.startsWith("data:image/png;base64") ? entrytop.img : (entrytop.img!="" ? ("image://svg/:/" + PQCLook.iconShade + "/" + entrytop.img) : "")
            opacity: entrytop.active ? (entrytop.hovered ? 1 : 0.8) : 0.4
            Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
        }

        PQText {
            id: entry
            text: entrytop.txt
            opacity: entrytop.active ? (entrytop.hovered ? 1 : 0.8) : 0.4
            Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
        }

        Image {
            visible: entrytop.img_end!=""
            sourceSize: Qt.size(entry.height, entry.height)
            source: (entrytop.img_end!="") ? ("image://svg/:/" + PQCLook.iconShade + "/" + entrytop.img_end) : ""
            opacity: entrytop.active ? (entrytop.hovered ? 1 : 0.8) : 0.4
            Behavior on opacity { enabled: !PQCSettings.generalDisableAllAnimations; NumberAnimation { duration: 200 } }
        }

    }

    PQMouseArea {
        id: mousearea
        enabled: entrytop.active
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        text: entrytop.tooltip
        propagateComposedEvents: true
        onEntered:
            entrytop.hovered = true
        onExited:
            entrytop.hovered = false
        onClicked: {
            executeClick()
        }
        function executeClick() {
            if(entrytop.cmd == "") {
                entrytop.clicked()
            } else if(!entrytop.customEntry || entrytop.cmd.startsWith("__")) {
                PQCScriptsShortcuts.executeInternalCommand(entrytop.cmd)
            } else {
                PQCScriptsShortcuts.executeExternal(cmd, custom_args, PQCFileFolderModel.currentFile);
                if(custom_close == "1")
                    PQCNotify.windowClose()
            }

            if(closeMenu && !PQCSettings.interfacePopoutMainMenu)
                mainmenu_top.hideMainMenu()
        }
    }

    MultiPointTouchArea {

        id: toucharea

        anchors.fill: parent
        mouseEnabled: false

        maximumTouchPoints: 1

        property point touchPos

        onPressed: (touchPoints) => {
            touchPos = touchPoints[0]
            touchShowMenu.start()
        }

        onUpdated: (touchPoints) => {
            if(Math.sqrt(Math.pow(touchPos.x-touchPoints[0].x, 2) + Math.pow(touchPos.y-touchPoints[0].y, 2)) > 50) {
                touchShowMenu.stop()
            }
        }

        onReleased: (touchPoints) => {
            touchShowMenu.stop()
            if(!menu.item.opened) {
                mousearea.executeClick()
            }
        }

        Timer {
            id: touchShowMenu
            interval: 1000
            onTriggered: {
                menu.item.popup(toucharea.mapToItem(mainmenu_top, toucharea.touchPos))
            }
        }

    }

}
