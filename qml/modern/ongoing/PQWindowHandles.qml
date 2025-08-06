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
import PhotoQt.Modern

Item {

    id: handles_top

    width: PQCConstants.windowWidth
    height: PQCConstants.windowHeight

    property int thickness: 10

    // MOVE with TOP edge
    MouseArea {
        x: PQCConstants.statusInfoCurrentRect.width 
        y: 0
        enabled: !PQCConstants.modalWindowOpen 
        visible: enabled
        width: parent.width - PQCConstants.statusInfoCurrentRect.width-20 - PQCConstants.windowButtonsCurrentRect.width-10 
        height: 3*handles_top.thickness
        hoverEnabled: true
        cursorShape: Qt.SizeAllCursor
        acceptedButtons: Qt.AllButtons
        onWheel: (wheel) => { wheel.accepted = true }
        onPressed: {
            PQCNotify.windowStartSystemMove()
        }
        onDoubleClicked: {
            if(PQCConstants.windowState)
            if(PQCConstants.windowState === Window.Maximized)
                PQCNotify.setWindowState(Window.Windowed)
            else if(PQCConstants.windowState === Window.Windowed)
                PQCNotify.setWindowState(Window.Maximized)
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
            PQCNotify.windowStartSystemResize(Qt.LeftEdge)
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
            PQCNotify.windowStartSystemResize(Qt.RightEdge)
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
            PQCNotify.windowStartSystemResize(Qt.TopEdge)
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
            PQCNotify.windowStartSystemResize(Qt.BottomEdge)
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
            PQCNotify.windowStartSystemResize(Qt.LeftEdge|Qt.TopEdge)
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
            PQCNotify.windowStartSystemResize(Qt.RightEdge|Qt.TopEdge)
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
            PQCNotify.windowStartSystemResize(Qt.LeftEdge|Qt.BottomEdge)
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
            PQCNotify.windowStartSystemResize(Qt.RightEdge|Qt.BottomEdge)
    }

}
