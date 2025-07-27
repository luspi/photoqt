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
import PhotoQt.Shared

Rectangle {

    id: minimap_top

    property int sl: PQCSettings.imageviewMinimapSizeLevel

    Rectangle {
        id: containerItemForAnchors
        x: (parent.width-width)/2
        y: (parent.height-height)/2
        width: img.width+(PQCScriptsConfig.isQtAtLeast6_5() ? 0 : 6)
        height: img.height+(PQCScriptsConfig.isQtAtLeast6_5() ? 0 : 6)
    }

    states: [
        State {
            name: "popout"
            PropertyChanges {
                minimap_top.x: 0
                minimap_top.y: 0
                minimap_top.width: minimap_popout.width
                minimap_top.height: minimap_popout.height
                minimap_top.opacity: 1
            }
            PropertyChanges {
                img.x: (minimap_top.width-img.width)/2
                img.y: (minimap_top.height-img.height)/2
                img.sourceSize: Qt.size(minimap_top.width, minimap_top.height)
            }
            PropertyChanges {
                containerItemForAnchors.color: PQCLook.baseColorAccent
            }
        },
        State {
            name: "normal"
            PropertyChanges {
                minimap_top.x: image_top.width-minimap_top.width-50
                minimap_top.y: image_top.height-minimap_top.height-50
                minimap_top.parent: image_top
                minimap_top.width: img.width+(PQCScriptsConfig.isQtAtLeast6_5() ? 0 : 6)
                minimap_top.height: img.height+(PQCScriptsConfig.isQtAtLeast6_5() ? 0 : 6)
                minimap_top.opacity: minimap_top.minimapNeeded ? ((minimap_top.minimapActive||minimap_top.containsMouse) ? 1 : 0.2) : 0
            }
            PropertyChanges {
                img.x: PQCScriptsConfig.isQtAtLeast6_5() ? 0 : 3
                img.y: PQCScriptsConfig.isQtAtLeast6_5() ? 0 : 3
                img.sourceSize: minimap_top.sl == 0 ?
                                    Qt.size(125,125) :
                                    (minimap_top.sl == 1 ?
                                         Qt.size(250, 250) :
                                         (minimap_top.sl == 2 ?
                                              Qt.size(450,450) :
                                              Qt.size(650,650)))
            }
            PropertyChanges {
                containerItemForAnchors.color: "transparent"
            }
        }
    ]

    color: PQCLook.transColor
    border.width: PQCScriptsConfig.isQtAtLeast6_5() ? 1 : 0
    border.color: PQCLook.transColor

    PQShadowEffect {
        masterItem: minimap_top
        z: PQCConstants.currentZValue
    }

    property bool minimapNeeded: (loader_top.imageScale > loader_top.defaultScale*1.01 && (flickable_content.width > image_top.width || flickable_content.height > image_top.height)) && !PQCConstants.slideshowRunning && !PQCConstants.showingPhotoSphere
    property bool minimapActive: false
    property bool containsMouse: movemouse.containsMouse||minimapmouse.containsMouse||navmouse.containsMouse

    Connections {
        target: loader_top
        function onImageScaleChanged() {
            minimap_top.minimapActive = true
            minimapMakeDeactive.start()
        }
    }
    Connections {
        target: flickable.visibleArea
        function onXPositionChanged() {
            minimap_top.minimapActive = true
            minimapMakeDeactive.start()
        }
        function onYPositionChanged() {
            minimap_top.minimapActive = true
            minimapMakeDeactive.start()
        }
    }

    Timer {
        id: minimapMakeDeactive
        interval: 2000
        onTriggered: {
            minimap_top.minimapActive = false
        }
    }

    state: PQCSettings.interfaceMinimapPopout ? "popout" : "normal"

    z: PQCConstants.currentZValue


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

            if(mouse.button === Qt.LeftButton) {

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

            } else if(mouse.button === Qt.RightButton) {
                rightclickmenu.popup()
            }
        }
        onWheel: (wheel) => {
            if(!PQCSettings.interfaceMinimapPopout) {
                wheel.accepted = false
                return
            }
            var pos = minimapmouse.mapToItem(toplevel, wheel.x, wheel.y)
            PQCNotify.mouseWheel(pos, wheel.angleDelta, wheel.modifiers)
        }


    }

    PQMenu {

        id: rightclickmenu

        PQMenuItem {
            text: qsTranslate("image", "Small minimap")
            onTriggered:
                PQCSettings.imageviewMinimapSizeLevel = 0
        }

        PQMenuItem {
            text: qsTranslate("image", "Normal minimap")
            onTriggered:
                PQCSettings.imageviewMinimapSizeLevel = 1
        }

        PQMenuItem {
            text: qsTranslate("image", "Large minimap")
            onTriggered:
                PQCSettings.imageviewMinimapSizeLevel = 2
        }

        PQMenuItem {
            text: qsTranslate("image", "Very large minimap")
            onTriggered:
                PQCSettings.imageviewMinimapSizeLevel = 3
        }

        PQMenuSeparator {}

        PQMenuItem {
            text: qsTranslate("image", "Hide minimap")
            onTriggered:
                PQCSettings.imageviewShowMinimap = false
        }

    }

    Image {
        id: img

        fillMode: Image.PreserveAspectFit
        source: ""
        cache: false
        asynchronous: true

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
            visible: minimap_top.minimapNeeded
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
                    flickable.contentX = flickable.contentWidth*(x/img.width)
                }
            }
            onYChanged: {
                if(navmouse.drag.active) {
                    flickable.contentY = flickable.contentHeight*(y/img.height)
                }
            }
        }

        Timer {
            interval: PQCSettings.imageviewAnimationDuration*100
            running: loader_top.visible && !hasBeenTriggered
            property bool hasBeenTriggered: false
            onTriggered: {
                hasBeenTriggered = true
                var cl = PQCScriptsFilesPaths.cleanPath(imageloaderitem.imageSource)
                if(cl !== "")
                    img.source = encodeURI("image://thumb/" + cl)
            }
        }

    }

    Connections {
        target: imageloaderitem
        function onImageSourceChanged(source : string) {
            var cl = PQCScriptsFilesPaths.cleanPath(source)
            if(cl !== "")
                img.source = encodeURI("image://thumb/" + cl)
        }
    }

    // the pop in/out button
    Image {
        x: PQCSettings.interfaceMinimapPopout ? 4 : -7
        y: PQCSettings.interfaceMinimapPopout ? 4 : -7
        width: 15
        height: 15
        z: 1
        source: "image://svg/:/" + PQCLook.iconShade + "/popinpopout.svg"
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
