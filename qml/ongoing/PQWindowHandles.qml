import QtQuick

import "../elements"

Item {

    width: toplevel.width
    height: toplevel.height

    property int thickness: 10

    // MOVE with TOP edge
    MouseArea {
        x: 0
        y: 0
        width: parent.width-windowbuttons.item.width-10
        height: 3*thickness
        hoverEnabled: true
        cursorShape: Qt.SizeAllCursor
        onPressed:
            toplevel.startSystemMove()
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
