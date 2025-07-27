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
import PhotoQt.Shared

MouseArea {

    id: mouse_top

    property string tooltip: ""

    hoverEnabled: true

    property int doubleClickThreshold: 0

    // there is also a built-in doubleClicked signal
    // our custom signal allows for control of the threshold
    // and also prevents a normal click from firing WHEN a nonzero threshold is set
    signal mouseDoubleClicked(var mouse)

    onPressed: (mouse) => {
        if(mouse.button === Qt.LeftButton) {
            if(doubleClickThreshold > 0) {
                if(doubleClickTimer.running) {
                    doubleClickTimer.stop()
                    if(Math.abs(mouse.x - doubleClickTimer.firstClick.x) < 50 && Math.abs(mouse.y - doubleClickTimer.firstClick.y) < 50)
                        mouse_top.mouseDoubleClicked(mouse)
                    mouse.accepted = false
                } else {
                    doubleClickTimer.firstClick = Qt.point(mouse.x, mouse.y)
                    doubleClickTimer.mouse = mouse
                    doubleClickTimer.restart()
                }
            }
        }
    }
    Timer {
        id: doubleClickTimer
        interval: mouse_top.doubleClickThreshold
        repeat: false
        running: false
        property var mouse: undefined
        property point firstClick: Qt.point(-1,-1)
        onTriggered: {
            mouse_top.clicked(mouse)
        }
    }

    Timer {
        id: showToolTip
        interval: 250
        onTriggered: {
            if(mouse_top.containsMouse && mouse_top.tooltip !== "")
                PQCNotify.showToolTip(tooltip, mouse_top.mapToGlobal(mouse_top.mouseX, 0))
        }
    }

    onEntered: {
        showToolTip.restart()
    }

    onExited: {
        showToolTip.stop()
        if(mouse_top.tooltip !== "")
            PQCNotify.hideToolTip(mouse_top.tooltip)
    }

}
