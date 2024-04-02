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

import "../elements"

Item {

    width: toplevel.width
    height: toplevel.height

    property int thickness: 10

    // MOVE with TOP edge
    MouseArea {
        x: statusinfo.item.width
        y: 0
        enabled: loader.visibleItem===""
        visible: enabled
        width: parent.width - statusinfo.item.width-20 - windowbuttons.item.width-10
        height: 3*thickness
        hoverEnabled: true
        cursorShape: Qt.SizeAllCursor
        acceptedButtons: Qt.AllButtons
        onWheel: (wheel) => { wheel.accepted = true }
        onPressed:
            toplevel.startSystemMove()
        onDoubleClicked: {
            if(toplevel.visibility === Window.Maximized)
                toplevel.visibility = Window.Windowed
            else if(toplevel.visibility === Window.Windowed)
                toplevel.visibility = Window.Maximized
        }

    }

    // LEFT edge
    MouseArea {
        x: 0
        y: 0
        width: thickness
        height: parent.height
        hoverEnabled: true
        cursorShape: Qt.SizeHorCursor
        onPressed:
            toplevel.startSystemResize(Qt.LeftEdge)
    }

    // RIGHT edge
    MouseArea {
        x: parent.width-width
        y: 0
        width: thickness
        height: parent.height
        hoverEnabled: true
        cursorShape: Qt.SizeHorCursor
        onPressed:
            toplevel.startSystemResize(Qt.RightEdge)
    }

    // TOP edge
    MouseArea {
        x: 0
        y: 0
        width: parent.width
        height: thickness
        hoverEnabled: true
        cursorShape: Qt.SizeVerCursor
        onPressed:
            toplevel.startSystemResize(Qt.TopEdge)
    }

    // BOTTOM edge
    MouseArea {
        x: 0
        y: parent.height-height
        width: parent.width
        height: thickness
        hoverEnabled: true
        cursorShape: Qt.SizeVerCursor
        onPressed:
            toplevel.startSystemResize(Qt.BottomEdge)
    }

    // TOP LEFT corner
    MouseArea {
        x: 0
        y: 0
        width: 2*thickness
        height: 2*thickness
        hoverEnabled: true
        cursorShape: Qt.SizeFDiagCursor
        onPressed:
            toplevel.startSystemResize(Qt.LeftEdge|Qt.TopEdge)
    }

    // TOP RIGHT corner
    MouseArea {
        x: parent.width-width
        y: 0
        width: 2*thickness
        height: 2*thickness
        hoverEnabled: true
        cursorShape: Qt.SizeBDiagCursor
        onPressed:
            toplevel.startSystemResize(Qt.RightEdge|Qt.TopEdge)
    }

    // BOTTOM LEFT corner
    MouseArea {
        x: 0
        y: parent.height-height
        width: 2*thickness
        height: 2*thickness
        hoverEnabled: true
        cursorShape: Qt.SizeBDiagCursor
        onPressed:
            toplevel.startSystemResize(Qt.LeftEdge|Qt.BottomEdge)
    }

    // BOTTOM RIGHT corner
    MouseArea {
        x: parent.width-width
        y: parent.height-height
        width: 2*thickness
        height: 2*thickness
        hoverEnabled: true
        cursorShape: Qt.SizeFDiagCursor
        onPressed:
            toplevel.startSystemResize(Qt.RightEdge|Qt.BottomEdge)
    }

}
