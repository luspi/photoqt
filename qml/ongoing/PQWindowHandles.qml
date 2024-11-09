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

import "../"

Item {

    id: handles_top

    width: acces_toplevel.width
    height: acces_toplevel.height

    property int thickness: 10

    property PQMainWindow acces_toplevel: toplevel // qmllint disable unqualified

    // MOVE with TOP edge
    MouseArea {
        x: statusinfo.item.width // qmllint disable unqualified
        y: 0
        enabled: loader.visibleItem==="" // qmllint disable unqualified
        visible: enabled
        width: parent.width - statusinfo.item.width-20 - windowbuttons.item.width-10 // qmllint disable unqualified
        height: 3*handles_top.thickness
        hoverEnabled: true
        cursorShape: Qt.SizeAllCursor
        acceptedButtons: Qt.AllButtons
        onWheel: (wheel) => { wheel.accepted = true }
        onPressed:
            handles_top.acces_toplevel.startSystemMove()
        onDoubleClicked: {
            if(handles_top.acces_toplevel.visibility === Window.Maximized)
                handles_top.acces_toplevel.visibility = Window.Windowed
            else if(handles_top.acces_toplevel.visibility === Window.Windowed)
                handles_top.acces_toplevel.visibility = Window.Maximized
        }

    }

    // LEFT edge
    MouseArea {
        x: 0
        y: 0
        width: handles_top.thickness
        height: parent.height
        hoverEnabled: true
        cursorShape: Qt.SizeHorCursor
        onPressed:
            handles_top.acces_toplevel.startSystemResize(Qt.LeftEdge)
    }

    // RIGHT edge
    MouseArea {
        x: parent.width-width
        y: 0
        width: handles_top.thickness
        height: parent.height
        hoverEnabled: true
        cursorShape: Qt.SizeHorCursor
        onPressed:
            handles_top.acces_toplevel.startSystemResize(Qt.RightEdge)
    }

    // TOP edge
    MouseArea {
        x: 0
        y: 0
        width: parent.width
        height: handles_top.thickness
        hoverEnabled: true
        cursorShape: Qt.SizeVerCursor
        onPressed:
            handles_top.acces_toplevel.startSystemResize(Qt.TopEdge)
    }

    // BOTTOM edge
    MouseArea {
        x: 0
        y: parent.height-height
        width: parent.width
        height: handles_top.thickness
        hoverEnabled: true
        cursorShape: Qt.SizeVerCursor
        onPressed:
            handles_top.acces_toplevel.startSystemResize(Qt.BottomEdge)
    }

    // TOP LEFT corner
    MouseArea {
        x: 0
        y: 0
        width: 2*handles_top.thickness
        height: 2*handles_top.thickness
        hoverEnabled: true
        cursorShape: Qt.SizeFDiagCursor
        onPressed:
            handles_top.acces_toplevel.startSystemResize(Qt.LeftEdge|Qt.TopEdge)
    }

    // TOP RIGHT corner
    MouseArea {
        x: parent.width-width
        y: 0
        width: 2*handles_top.thickness
        height: 2*handles_top.thickness
        hoverEnabled: true
        cursorShape: Qt.SizeBDiagCursor
        onPressed:
            handles_top.acces_toplevel.startSystemResize(Qt.RightEdge|Qt.TopEdge)
    }

    // BOTTOM LEFT corner
    MouseArea {
        x: 0
        y: parent.height-height
        width: 2*handles_top.thickness
        height: 2*handles_top.thickness
        hoverEnabled: true
        cursorShape: Qt.SizeBDiagCursor
        onPressed:
            handles_top.acces_toplevel.startSystemResize(Qt.LeftEdge|Qt.BottomEdge)
    }

    // BOTTOM RIGHT corner
    MouseArea {
        x: parent.width-width
        y: parent.height-height
        width: 2*handles_top.thickness
        height: 2*handles_top.thickness
        hoverEnabled: true
        cursorShape: Qt.SizeFDiagCursor
        onPressed:
            handles_top.acces_toplevel.startSystemResize(Qt.RightEdge|Qt.BottomEdge)
    }

}
