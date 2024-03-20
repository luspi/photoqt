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
import QtQuick.Controls

MouseArea {

    id: tooltip_top

    property alias text: control.text
    property alias delay: control.delay

    property bool hovered : false

    property var tooltipReference: undefined
    property alias tooltipPartialTransparency: control.partialTransparency

    hoverEnabled: true

    property int doubleClickThreshold: 0

    signal doubleClicked(var mouse)

    onPressed: (mouse) => {
        if(mouse.button === Qt.LeftButton) {
            if(doubleClickThreshold > 0) {
                if(doubleClickTimer.running) {
                    doubleClickTimer.stop()
                    if(Math.abs(mouse.x - doubleClickTimer.firstClick.x) < 50 && Math.abs(mouse.y - doubleClickTimer.firstClick.y) < 50)
                        tooltip_top.doubleClicked(mouse)
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
        interval: doubleClickThreshold
        repeat: false
        running: false
        property var mouse: undefined
        property point firstClick: Qt.point(-1,-1)
        onTriggered: {
            tooltip_top.clicked(mouse)
        }
    }

    Timer {
        id: showToolTip
        interval: 250
        onTriggered: {
            if(tooltip_top.containsMouse && tooltip_top.text != "")
                control.visible = true
        }
    }

    onEntered: {
        hovered = true
        showToolTip.restart()
    }

    onExited: {
        hovered = false
        showToolTip.stop()
        control.visible = false
    }

    PQToolTip {

        id: control

        property point globalPos: tooltipReference!==undefined ? mapToItem(tooltipReference, tooltip_top.mouseX, tooltip_top.mouseY) : Qt.point(0,0)

        x: (tooltipReference!==undefined) ? (globalPos.x>tooltipReference.width-width-10 ? tooltipReference.width-5 : tooltip_top.mouseX) : (parent.width-width)/2
        y: -height-5

    }

}
