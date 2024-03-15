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
import PQCScriptsFilesPaths
import PQCFileFolderModel
import "../../elements"

Rectangle {

    x: parent.width-width-50
    y: parent.height-height-50
    width: img.width+10
    height: img.height+10
    color: PQCLook.transColor
    radius: 5
    z: image_top.curZ

    opacity: (deleg.imageScale > deleg.defaultScale*1.01 && (flickable_content.width > image_top.width || flickable_content.height > image_top.height)) ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 200 } }
    visible: opacity>0

    MouseArea {
        id: movemouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.SizeAllCursor
        drag.target: parent
    }

    MouseArea {
        id: minimapmouse
        anchors.fill: parent
        anchors.margins: 5
        hoverEnabled: true
        drag.target: parent
        acceptedButtons: Qt.AllButtons
        cursorShape: Qt.PointingHandCursor
        onClicked: (mouse) => {
            var propX = mouse.x/img.width
            var propY = mouse.y/img.height

            xanim.stop()
            yanim.stop()

            xanim.from = flickable.contentX
            yanim.from = flickable.contentY

            xanim.to = flickable.contentWidth*propX - flickable.width/2
            yanim.to = flickable.contentHeight*propY - flickable.height/2

            xanim.restart()
            yanim.restart()
        }
    }

    Image {
        id: img
        x: 5
        y: 5
        fillMode: Image.PreserveAspectFit
        sourceSize: Qt.size(200, 200)
        source: ""

        clip: true

        Rectangle {
            x: parent.width*flickable.visibleArea.xPosition
            y: parent.height*flickable.visibleArea.yPosition
            width: parent.width*flickable.visibleArea.widthRatio
            height: parent.height*flickable.visibleArea.heightRatio
            opacity: 0.5
            color: PQCLook.transColorActive
            border.width: 2
            border.color: PQCLook.baseColor
            radius: 2
            MouseArea {
                id: navmouse
                anchors.fill: parent
                hoverEnabled: true
                drag.target: parent
                cursorShape: Qt.SizeAllCursor
                drag.onActiveChanged: {
                    if(!drag.active) {
                        x = Qt.binding(function() { return parent.width*flickable.visibleArea.xPosition } )
                        y = Qt.binding(function() { return parent.height*flickable.visibleArea.yPosition } )
                        flickable.returnToBounds()
                    } else {
                        x = x
                        y = y
                    }
                }
            }
            onXChanged: {
                if(navmouse.drag.active) {
                    flickable.contentX = flickable.contentWidth*(x/img.width) //- flickable.width/2
                }
            }
            onYChanged: {
                if(navmouse.drag.active) {
                    flickable.contentY = flickable.contentHeight*(y/img.height) //- flickable.height/2
                }
            }
        }

        Timer {
            interval: PQCSettings.imageviewAnimationDuration*100
            running: loader_component.visible// && img.source===""
            onTriggered:
                img.source = "image://thumb/" + PQCScriptsFilesPaths.toPercentEncoding(PQCScriptsFilesPaths.cleanPath(deleg.imageSource))
        }

    }

    Connections {
        target: image_loader.item
        function onSourceChanged(source) {
            img.source = "image://thumb/" + PQCScriptsFilesPaths.cleanPath(source)
        }
    }

    // the close button is only visible when hovered
    Rectangle {
        x: parent.width-width+12
        y: -12
        width: 24
        height: 24
        radius: 12
        color: PQCLook.transColor
        opacity: controlclosemouse.containsMouse ? 0.75 : 0
        Behavior on opacity { NumberAnimation { duration: 300 } }
        Image {
            anchors.fill: parent
            anchors.margins: 2
            source: "image://svg/:/white/close.svg"
            sourceSize: Qt.size(width, height)
        }
        PQMouseArea {
            id: controlclosemouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            text: qsTranslate("image", "Hide controls")
            onClicked: {
                PQCSettings.imageviewShowMinimap = false
            }
        }
    }

    NumberAnimation {
        id: xanim
        target: flickable
        property: "contentX"
        duration: 200
        onStopped:
            flickable.returnToBounds()
    }
    NumberAnimation {
        id: yanim
        target: flickable
        property: "contentY"
        duration: 200
        onStopped:
            flickable.returnToBounds()
    }

}
