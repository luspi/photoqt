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

Item {

    width: parent.width
    height: parent.height

    property int effectiveWidth: masterObject.width
    property int effectiveHeight: masterObject.height
    property int effectiveX: 0
    property int effectiveY: 0

    property Item masterObject

    property point startPos
    property point endPos

    // region that is desired

    Rectangle {
        x: effectiveX+startPos.x*effectiveWidth
        y: effectiveY+startPos.y*effectiveHeight
        width: (endPos.x-startPos.x)*effectiveWidth
        height: (endPos.y-startPos.y)*effectiveHeight
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
                    var w = endPos.x - startPos.x
                    startPos.x = Math.max(0, Math.min(1-w, startPos.x+(mouse.x-startX)/effectiveWidth))
                    endPos.x = startPos.x+w
                }
            }
            onMouseYChanged: (mouse) => {
                if(pressedDown) {
                    var h = endPos.y - startPos.y
                    startPos.y = Math.max(0, Math.min(1-h, startPos.y+(mouse.y-startY)/effectiveHeight))
                    endPos.y = startPos.y+h
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
        x: effectiveX + (startPos.x +(endPos.x-startPos.x)/2)*effectiveWidth -markerSize/2
        y: effectiveY + startPos.y*effectiveHeight - markerSize/2
        width: markerSize
        height: markerSize
        radius: markerSize/2
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
                    startPos.y = Math.max(0, Math.min(endPos.y-0.01, (mapToItem(masterObject, mouse.x, mouse.y).y-effectiveY)/effectiveHeight))
                }
            }
        }
    }

    // left
    Rectangle {
        x: effectiveX + startPos.x*effectiveWidth - markerSize/2
        y: effectiveY + (startPos.y + (endPos.y-startPos.y)/2)*effectiveHeight -markerSize/2
        width: markerSize
        height: markerSize
        radius: markerSize/2
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
                    startPos.x = Math.max(0, Math.min(endPos.x-0.01, (mapToItem(masterObject, mouse.x, mouse.y).x-effectiveX)/effectiveWidth))
                }
            }
        }
    }

    // right
    Rectangle {
        x: effectiveX + endPos.x*effectiveWidth - markerSize/2
        y: effectiveY + (startPos.y + (endPos.y-startPos.y)/2)*effectiveHeight - markerSize/2
        width: markerSize
        height: markerSize
        radius: markerSize/2
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
                    endPos.x = Math.min(1, Math.max(startPos.x+0.01, (mapToItem(masterObject, mouse.x, mouse.y).x-effectiveX)/effectiveWidth))
                }
            }
        }
    }

    // bottom
    Rectangle {
        x: effectiveX + (startPos.x +(endPos.x-startPos.x)/2)*effectiveWidth -markerSize/2
        y: effectiveY + endPos.y*effectiveHeight - markerSize/2
        width: markerSize
        height: markerSize
        radius: markerSize/2
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
                    endPos.y = Math.min(1, Math.max(startPos.y+0.01, (mapToItem(masterObject, mouse.x, mouse.y).y-effectiveY)/effectiveHeight))
                }
            }
        }
    }

    // top left
    Rectangle {
        x: effectiveX + startPos.x*effectiveWidth - markerSize/2
        y: effectiveY + startPos.y*effectiveHeight - markerSize/2
        width: markerSize
        height: markerSize
        radius: markerSize/2
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
                    startPos.y = Math.max(0, Math.min(endPos.y-0.01, (mapToItem(masterObject, mouse.x, mouse.y).y-effectiveY)/effectiveHeight))
                }
            }
            onMouseXChanged: (mouse) => {
                if(pressedDown) {
                    startPos.x = Math.max(0, Math.min(endPos.x-0.01, (mapToItem(masterObject, mouse.x, mouse.y).x-effectiveX)/effectiveWidth))
                }
            }
        }
    }

    // top right
    Rectangle {
        x: effectiveX + endPos.x*effectiveWidth - markerSize/2
        y: effectiveY + startPos.y*effectiveHeight - markerSize/2
        width: markerSize
        height: markerSize
        radius: markerSize/2
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
                    startPos.y = Math.max(0, Math.min(endPos.y-0.01, (mapToItem(masterObject, mouse.x, mouse.y).y-effectiveY)/effectiveHeight))
                }
            }
            onMouseXChanged: (mouse) => {
                if(pressedDown) {
                    endPos.x = Math.min(1, Math.max(startPos.x+0.01, (mapToItem(masterObject, mouse.x, mouse.y).x-effectiveX)/effectiveWidth))
                }
            }
        }
    }

    // bottom left
    Rectangle {
        x: effectiveX + startPos.x*effectiveWidth - markerSize/2
        y: effectiveY + endPos.y*effectiveHeight - markerSize/2
        width: markerSize
        height: markerSize
        radius: markerSize/2
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
                    endPos.y = Math.min(1, Math.max(startPos.y+0.01, (mapToItem(masterObject, mouse.x, mouse.y).y-effectiveY)/effectiveHeight))
                }
            }
            onMouseXChanged: (mouse) => {
                if(pressedDown) {
                    startPos.x = Math.max(0, Math.min(endPos.x-0.01, (mapToItem(masterObject, mouse.x, mouse.y).x-effectiveX)/effectiveWidth))
                }
            }
        }
    }

    // bottom right
    Rectangle {
        x: effectiveX + endPos.x*effectiveWidth - markerSize/2
        y: effectiveY + endPos.y*effectiveHeight - markerSize/2
        width: markerSize
        height: markerSize
        radius: markerSize/2
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
                    endPos.y = Math.min(1, Math.max(startPos.y+0.01, (mapToItem(masterObject, mouse.x, mouse.y).y-effectiveY)/effectiveHeight))
                }
            }
            onMouseXChanged: (mouse) => {
                if(pressedDown) {
                    endPos.x = Math.min(1, Math.max(startPos.x+0.01, (mapToItem(masterObject, mouse.x, mouse.y).x-effectiveX)/effectiveWidth))
                }
            }
        }
    }

}
