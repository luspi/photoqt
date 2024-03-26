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
import PQCScriptsConfig
import PQCNotify
import "../../elements"

Rectangle {

    id: minimap_top

    property int sl: PQCSettings.imageviewMinimapSizeLevel

    Item {
        id: containerItemForAnchors
        x: (parent.width-width)/2
        y: (parent.height-height)/2
        width: Math.max(75, img.width+(PQCScriptsConfig.isQtAtLeast6_5() ? 0 : 6))
        height: Math.max(50, img.height+(PQCScriptsConfig.isQtAtLeast6_5() ? 0 : 6))
    }

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
                target: minimap_top
                x: image_top.width-width-50
                y: image_top.height-height-50
                parent: image_top
                width: Math.max(75, img.width+(PQCScriptsConfig.isQtAtLeast6_5() ? 0 : 6))
                height: Math.max(50, img.height+(PQCScriptsConfig.isQtAtLeast6_5() ? 0 : 6))
                opacity: minimapNeeded ? 1 : 0
            }
            PropertyChanges {
                target: img
                x: PQCScriptsConfig.isQtAtLeast6_5() ? 0 : 3
                y: PQCScriptsConfig.isQtAtLeast6_5() ? 0 : 3
                sourceSize: sl == 0 ?
                                Qt.size(125,125) :
                                (sl == 1 ?
                                     Qt.size(250, 250) :
                                     (sl == 2 ?
                                          Qt.size(450,450) :
                                          Qt.size(650,650)))
            }
        }
    ]

    color: PQCScriptsConfig.isQtAtLeast6_5() ? PQCLook.faintColor : PQCLook.transColor
    border.width: PQCScriptsConfig.isQtAtLeast6_5() ? 1 : 0
    border.color: PQCLook.transColor

    PQShadowEffect {
        masterItem: minimap_top
        z: image_top.curZ
    }

    property bool minimapNeeded: (deleg.imageScale > deleg.defaultScale*1.01 && (flickable_content.width > image_top.width || flickable_content.height > image_top.height))

    state: PQCSettings.interfaceMinimapPopout ? "popout" : "normal"

    z: image_top.curZ


    Behavior on opacity { NumberAnimation { duration: 200 } }
    visible: opacity>0

    PQText {
        anchors.centerIn: containerItemForAnchors
        visible: (img.source===""||img.status!=Image.Ready) && PQCSettings.interfaceMinimapPopout
        text: qsTranslate("image", "Minimap")
    }

    MouseArea {
        id: movemouse
        anchors.fill: containerItemForAnchors
        enabled: !PQCScriptsConfig.isQtAtLeast6_5()
        hoverEnabled: true
        cursorShape: PQCSettings.interfaceMinimapPopout ? Qt.ArrowCursor : Qt.SizeAllCursor
        drag.target: PQCSettings.interfaceMinimapPopout ? undefined : parent
    }

    MouseArea {
        id: minimapmouse
        anchors.fill: containerItemForAnchors
        anchors.margins: PQCScriptsConfig.isQtAtLeast6_5() ? 0 : 5
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
        onWheel: (wheel) => {
            if(!PQCSettings.interfaceMinimapPopout) {
                wheel.accepted = false
                return
            }
            PQCNotify.mouseWheel(wheel.angleDelta, wheel.modifiers)
        }
    }

    Image {
        id: img

        fillMode: Image.PreserveAspectFit
        source: ""

        clip: true

        Rectangle {
            x: parent.width*flickable.visibleArea.xPosition
            y: parent.height*flickable.visibleArea.yPosition
            width: parent.width*flickable.visibleArea.widthRatio
            height: parent.height*flickable.visibleArea.heightRatio
            opacity: 0.7
            color: PQCLook.baseColorAccent
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

    // the pop in/out button
    Image {
        x: PQCSettings.interfaceMinimapPopout ? 4 : -7
        y: PQCSettings.interfaceMinimapPopout ? 4 : -7
        width: 15
        height: 15
        z: 1
        source: "image://svg/:/white/popinpopout.svg"
        sourceSize: Qt.size(width, height)
        opacity: popinmouse.containsMouse ? 1 : 0
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
            radius: 4
            z: -1
            color: PQCLook.transColor
            opacity: parent.opacity
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
