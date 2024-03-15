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

    id: minimap_top

    states: [
        State {
            name: "popout"
            PropertyChanges {
                target: minimap_top
                x: 0
                y: 0
                width: minimap_popout.width
                height: minimap_popout.height
                opacity: 1
            }
        },
        State {
            name: "normal"
            PropertyChanges {
                target: minimap_top
                x: image_top.width-width-50
                y: image_top.height-height-50
                parent: image_top
                width: Math.max(75, img.width+10)
                height: Math.max(50, img.height+10)
                opacity: minimapNeeded ? 1 : 0
            }
        }
    ]

    property bool minimapNeeded: (deleg.imageScale > deleg.defaultScale*1.01 && (flickable_content.width > image_top.width || flickable_content.height > image_top.height))

    state: PQCSettings.interfaceMinimapPopout ? "popout" : "normal"

    color: PQCLook.transColor
    radius: 5
    z: image_top.curZ


    Behavior on opacity { NumberAnimation { duration: 200 } }
    visible: opacity>0

    PQText {
        anchors.centerIn: parent
        visible: (img.source===""||img.status!=Image.Ready) && PQCSettings.interfaceMinimapPopout
        text: "Minimap"
    }

    MouseArea {
        id: movemouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: PQCSettings.interfaceMinimapPopout ? Qt.ArrowCursor : Qt.SizeAllCursor
        drag.target: PQCSettings.interfaceMinimapPopout ? undefined : parent
    }

    MouseArea {
        id: minimapmouse
        anchors.fill: parent
        anchors.margins: 5
        hoverEnabled: true
        drag.target: PQCSettings.interfaceMinimapPopout ? undefined : parent
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

        fillMode: Image.PreserveAspectFit
        source: ""

        states: [
            State {
                name: "popout"
                PropertyChanges {
                    target: img
                    x: (minimap_top.width-width)/2
                    y: (minimap_top.height-height)/2
                    sourceSize: Qt.size(minimap_top.width, minimap_top.height)
                }
            },
            State {
                name: "normal"
                PropertyChanges {
                    target: img
                    x: 5
                    y: 5
                    sourceSize: Qt.size(200, 200)
                }
            }

        ]

        state: PQCSettings.interfaceMinimapPopout ? "popout" : "normal"

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
            visible: minimapNeeded
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
            running: loader_component.visible && !hasBeenTriggered
            property bool hasBeenTriggered: false
            onTriggered: {
                hasBeenTriggered = true
                img.source = "image://full/" + PQCScriptsFilesPaths.toPercentEncoding(PQCScriptsFilesPaths.cleanPath(deleg.imageSource))
            }
        }

    }

    Connections {
        target: image_loader.item
        function onSourceChanged(source) {
            img.source = "image://full/" + PQCScriptsFilesPaths.cleanPath(source)
        }
    }

    Image {
        x: PQCSettings.interfaceMinimapPopout ? 4 : -7
        y: PQCSettings.interfaceMinimapPopout ? 4 : -7
        width: 15
        height: 15
        z: 1
        source: "image://svg/:/white/popinpopout.svg"
        sourceSize: Qt.size(width, height)
        opacity: popinmouse.containsMouse ? 1 : 0.2
        Behavior on opacity { NumberAnimation { duration: 200 } }
        PQMouseArea {
            id: popinmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            text: PQCSettings.interfaceMinimapPopout ?
                      //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                      qsTranslate("popinpopout", "Merge into main interface") :
                      //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                      qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                PQCSettings.interfaceMinimapPopout = !PQCSettings.interfaceMinimapPopout
            }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: 2
            z: -1
            color: PQCLook.transColor
            opacity: parent.opacity
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
        visible: !PQCSettings.interfaceMinimapPopout
        enabled: !PQCSettings.interfaceMinimapPopout
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
