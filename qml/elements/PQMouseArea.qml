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

MouseArea {

    id: top

    property bool tooltipFollowsMouse: true
    property alias tooltip: control.text
    property alias tooltipWrapMode: control.wrapMode
    property alias tooltipWidth: control.width
    property alias tooltipElide: control.elide
    property alias tooltipDelay: control.delay

    property int doubleClickThreshold: 0

    signal doubleClicked(var mouse)

    PQToolTip {
        id: control
        parent: top.tooltipFollowsMouse ? curmouse : top
        visible: text!=""&&top.containsMouse
    }

    Item {
        id: curmouse
        x: top.mouseX + control.width/2
        y: top.mouseY
        width: 1
        height: 1
    }

    onPressed: {
        if(doubleClickThreshold > 0) {
            if(doubleClickTimer.running) {
                doubleClickTimer.stop()
                if(Math.abs(mouse.x - doubleClickTimer.firstClick.x) < 50 && Math.abs(mouse.y - doubleClickTimer.firstClick.y) < 50)
                    top.doubleClicked(mouse)
                mouse.accepted = false
            } else {
                doubleClickTimer.firstClick = Qt.point(mouse.x, mouse.y)
                doubleClickTimer.mouse = mouse
                doubleClickTimer.restart()
            }
            top.pressed(mouse)
        }
    }
    Timer {
        id: doubleClickTimer
        interval: doubleClickThreshold
        repeat: false
        running: false
        property var mouse: undefined
        property point firstClick: Qt.point(-1,-1)
        onTriggered: {
            top.clicked(mouse)
        }
    }

}
