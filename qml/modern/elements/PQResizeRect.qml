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

    id: control

    width: parent.width
    height: parent.height

    property int effectiveWidth: masterObject.width
    property int effectiveHeight: masterObject.height
    property int effectiveX: 0
    property int effectiveY: 0

    property Item masterObject

    property point startPos: Qt.point(-1,-1)
    property point endPos: Qt.point(-1,-1)

    // region that is desired

    Rectangle {
        x: control.effectiveX+control.startPos.x*control.effectiveWidth
        y: control.effectiveY+control.startPos.y*control.effectiveHeight
        width: (control.endPos.x-control.startPos.x)*control.effectiveWidth
        height: (control.endPos.y-control.startPos.y)*control.effectiveHeight
        color: "transparent"
        border.width: 2
        border.color: "red"
        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeAllCursor
            property bool pressedDown: false
            property int startX
            property int startY
            onPressed: (mouse) => {
                startX = mouse.x
                startY = mouse.y
                pressedDown = true
            }
            onReleased:
                pressedDown = false
            onMouseXChanged: (mouse) => {
                if(pressedDown) {
                    var w = control.endPos.x - control.startPos.x
                    control.startPos.x = Math.max(0, Math.min(1-w, control.startPos.x+(mouse.x-startX)/control.effectiveWidth))
                    control.endPos.x = startPos.x+w
                }
            }
            onMouseYChanged: (mouse) => {
                if(pressedDown) {
                    var h = control.endPos.y - control.startPos.y
                    control.startPos.y = Math.max(0, Math.min(1-h, control.startPos.y+(mouse.y-startY)/control.effectiveHeight))
                    control.endPos.y = control.startPos.y+h
                }
            }
        }
    }

    /******************************************/
    // markers for resizing highlighted region

    property int markerSize: ((endPos.x-startPos.x)*effectiveWidth < 50 || (endPos.y-startPos.y)*effectiveHeight < 50 ? 10 : 20)
    Behavior on markerSize { NumberAnimation { duration: 200 } }

    // top
    Rectangle {
        x: control.effectiveX + (control.startPos.x +(control.endPos.x-control.startPos.x)/2)*control.effectiveWidth -control.markerSize/2
        y: control.effectiveY + control.startPos.y*control.effectiveHeight - control.markerSize/2
        width: control.markerSize
        height: control.markerSize
        radius: control.markerSize/2
        color: "red"
        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeVerCursor
            property bool pressedDown: false
            onPressed:
                pressedDown = true
            onReleased:
                pressedDown = false
            onMouseYChanged: (mouse) => {
                if(pressedDown) {
                    control.startPos.y = Math.max(0, Math.min(control.endPos.y-0.01, (mapToItem(control.masterObject, mouse.x, mouse.y).y-control.effectiveY)/control.effectiveHeight))
                }
            }
        }
    }

    // left
    Rectangle {
        x: control.effectiveX + control.startPos.x*control.effectiveWidth - control.markerSize/2
        y: control.effectiveY + (control.startPos.y + (control.endPos.y-control.startPos.y)/2)*control.effectiveHeight -control.markerSize/2
        width: control.markerSize
        height: control.markerSize
        radius: control.markerSize/2
        color: "red"
        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeHorCursor
            property bool pressedDown: false
            onPressed:
                pressedDown = true
            onReleased:
                pressedDown = false
            onMouseXChanged: (mouse) => {
                if(pressedDown) {
                    control.startPos.x = Math.max(0, Math.min(control.endPos.x-0.01, (mapToItem(control.masterObject, mouse.x, mouse.y).x-control.effectiveX)/control.effectiveWidth))
                }
            }
        }
    }

    // right
    Rectangle {
        x: control.effectiveX + control.endPos.x*control.effectiveWidth - control.markerSize/2
        y: control.effectiveY + (control.startPos.y + (control.endPos.y-control.startPos.y)/2)*control.effectiveHeight - control.markerSize/2
        width: control.markerSize
        height: control.markerSize
        radius: control.markerSize/2
        color: "red"
        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeHorCursor
            property bool pressedDown: false
            onPressed:
                pressedDown = true
            onReleased:
                pressedDown = false
            onMouseXChanged: (mouse) => {
                if(pressedDown) {
                    control.endPos.x = Math.min(1, Math.max(control.startPos.x+0.01, (mapToItem(control.masterObject, mouse.x, mouse.y).x-control.effectiveX)/control.effectiveWidth))
                }
            }
        }
    }

    // bottom
    Rectangle {
        x: control.effectiveX + (control.startPos.x +(control.endPos.x-control.startPos.x)/2)*control.effectiveWidth -control.markerSize/2
        y: control.effectiveY + control.endPos.y*control.effectiveHeight - control.markerSize/2
        width: control.markerSize
        height: control.markerSize
        radius: control.markerSize/2
        color: "red"
        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeVerCursor
            property bool pressedDown: false
            onPressed:
                pressedDown = true
            onReleased:
                pressedDown = false
            onMouseYChanged: (mouse) => {
                if(pressedDown) {
                    control.endPos.y = Math.min(1, Math.max(control.startPos.y+0.01, (mapToItem(control.masterObject, mouse.x, mouse.y).y-control.effectiveY)/control.effectiveHeight))
                }
            }
        }
    }

    // top left
    Rectangle {
        x: control.effectiveX + control.startPos.x*control.effectiveWidth - control.markerSize/2
        y: control.effectiveY + control.startPos.y*control.effectiveHeight - control.markerSize/2
        width: control.markerSize
        height: control.markerSize
        radius: control.markerSize/2
        color: "red"
        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeFDiagCursor
            property bool pressedDown: false
            onPressed:
                pressedDown = true
            onReleased:
                pressedDown = false
            onMouseYChanged: (mouse) => {
                if(pressedDown) {
                    control.startPos.y = Math.max(0, Math.min(control.endPos.y-0.01, (mapToItem(control.masterObject, mouse.x, mouse.y).y-control.effectiveY)/control.effectiveHeight))
                }
            }
            onMouseXChanged: (mouse) => {
                if(pressedDown) {
                    control.startPos.x = Math.max(0, Math.min(control.endPos.x-0.01, (mapToItem(control.masterObject, mouse.x, mouse.y).x-control.effectiveX)/control.effectiveWidth))
                }
            }
        }
    }

    // top right
    Rectangle {
        x: control.effectiveX + control.endPos.x*control.effectiveWidth - control.markerSize/2
        y: control.effectiveY + control.startPos.y*control.effectiveHeight - control.markerSize/2
        width: control.markerSize
        height: control.markerSize
        radius: control.markerSize/2
        color: "red"
        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeBDiagCursor
            property bool pressedDown: false
            onPressed:
                pressedDown = true
            onReleased:
                pressedDown = false
            onMouseYChanged: (mouse) => {
                if(pressedDown) {
                    control.startPos.y = Math.max(0, Math.min(control.endPos.y-0.01, (mapToItem(control.masterObject, mouse.x, mouse.y).y-control.effectiveY)/control.effectiveHeight))
                }
            }
            onMouseXChanged: (mouse) => {
                if(pressedDown) {
                    control.endPos.x = Math.min(1, Math.max(control.startPos.x+0.01, (mapToItem(control.masterObject, mouse.x, mouse.y).x-control.effectiveX)/control.effectiveWidth))
                }
            }
        }
    }

    // bottom left
    Rectangle {
        x: control.effectiveX + control.startPos.x*control.effectiveWidth - control.markerSize/2
        y: control.effectiveY + control.endPos.y*control.effectiveHeight - control.markerSize/2
        width: control.markerSize
        height: control.markerSize
        radius: control.markerSize/2
        color: "red"
        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeBDiagCursor
            property bool pressedDown: false
            onPressed:
                pressedDown = true
            onReleased:
                pressedDown = false
            onMouseYChanged: (mouse) => {
                if(pressedDown) {
                    control.endPos.y = Math.min(1, Math.max(control.startPos.y+0.01, (mapToItem(control.masterObject, mouse.x, mouse.y).y-control.effectiveY)/control.effectiveHeight))
                }
            }
            onMouseXChanged: (mouse) => {
                if(pressedDown) {
                    control.startPos.x = Math.max(0, Math.min(control.endPos.x-0.01, (mapToItem(control.masterObject, mouse.x, mouse.y).x-control.effectiveX)/control.effectiveWidth))
                }
            }
        }
    }

    // bottom right
    Rectangle {
        x: control.effectiveX + control.endPos.x*control.effectiveWidth - control.markerSize/2
        y: control.effectiveY + control.endPos.y*control.effectiveHeight - control.markerSize/2
        width: control.markerSize
        height: control.markerSize
        radius: control.markerSize/2
        color: "red"
        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeFDiagCursor
            property bool pressedDown: false
            onPressed:
                pressedDown = true
            onReleased:
                pressedDown = false
            onMouseYChanged: (mouse) => {
                if(pressedDown) {
                    control.endPos.y = Math.min(1, Math.max(control.startPos.y+0.01, (mapToItem(control.masterObject, mouse.x, mouse.y).y-control.effectiveY)/control.effectiveHeight))
                }
            }
            onMouseXChanged: (mouse) => {
                if(pressedDown) {
                    control.endPos.x = Math.min(1, Math.max(control.startPos.x+0.01, (mapToItem(control.masterObject, mouse.x, mouse.y).x-control.effectiveX)/control.effectiveWidth))
                }
            }
        }
    }

}
