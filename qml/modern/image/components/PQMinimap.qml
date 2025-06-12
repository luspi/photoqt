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
import PQCScriptsFilesPaths
import PQCFileFolderModel
import PQCScriptsConfig
import PhotoQt

Rectangle {

    id: minimap_top

    property int sl: PQCSettings.imageviewMinimapSizeLevel // qmllint disable unqualified

    Rectangle {
        id: containerItemForAnchors
        x: (parent.width-width)/2
        y: (parent.height-height)/2
        width: img.width+(PQCScriptsConfig.isQtAtLeast6_5() ? 0 : 6) // qmllint disable unqualified
        height: img.height+(PQCScriptsConfig.isQtAtLeast6_5() ? 0 : 6) // qmllint disable unqualified
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

    color: PQCScriptsConfig.isQtAtLeast6_5() ? PQCLook.faintColor : PQCLook.transColor // qmllint disable unqualified
    border.width: PQCScriptsConfig.isQtAtLeast6_5() ? 1 : 0 // qmllint disable unqualified
    border.color: PQCLook.transColor // qmllint disable unqualified

    PQShadowEffect {
        masterItem: minimap_top
        z: image_top.curZ // qmllint disable unqualified
    }

    property bool minimapNeeded: (loader_top.imageScale > loader_top.defaultScale*1.01 && (flickable_content.width > image_top.width || flickable_content.height > image_top.height)) && !PQCConstants.slideshowRunning && !PQCNotify.showingPhotoSphere // qmllint disable unqualified
    property bool minimapActive: false
    property bool containsMouse: movemouse.containsMouse||minimapmouse.containsMouse||navmouse.containsMouse

    Connections {
        target: loader_top // qmllint disable unqualified
        function onImageScaleChanged() {
            minimap_top.minimapActive = true
            minimapMakeDeactive.start()
        }
    }
    Connections {
        target: flickable.visibleArea // qmllint disable unqualified
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

    state: PQCSettings.interfaceMinimapPopout ? "popout" : "normal" // qmllint disable unqualified

    z: image_top.curZ // qmllint disable unqualified


    Behavior on opacity { NumberAnimation { duration: 200 } }
    visible: opacity>0

    PQText {
        anchors.centerIn: containerItemForAnchors
        visible: (img.source===""||img.status!=Image.Ready) && PQCSettings.interfaceMinimapPopout // qmllint disable unqualified
        text: qsTranslate("image", "Minimap")
    }

    MouseArea {
        id: movemouse
        anchors.fill: containerItemForAnchors
        enabled: !PQCScriptsConfig.isQtAtLeast6_5() // qmllint disable unqualified
        hoverEnabled: true
        cursorShape: PQCSettings.interfaceMinimapPopout ? Qt.ArrowCursor : Qt.SizeAllCursor // qmllint disable unqualified
        drag.target: PQCSettings.interfaceMinimapPopout ? undefined : parent // qmllint disable unqualified
    }

    MouseArea {
        id: minimapmouse
        anchors.fill: containerItemForAnchors
        anchors.margins: PQCScriptsConfig.isQtAtLeast6_5() ? 0 : 5 // qmllint disable unqualified
        hoverEnabled: true
        drag.target: PQCSettings.interfaceMinimapPopout ? undefined : parent // qmllint disable unqualified
        acceptedButtons: Qt.AllButtons
        cursorShape: Qt.PointingHandCursor
        onClicked: (mouse) => {

            if(mouse.button === Qt.LeftButton) {

                var propX = mouse.x/img.width
                var propY = mouse.y/img.height

                xanim.stop()
                yanim.stop()

                xanim.from = flickable.contentX // qmllint disable unqualified
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
            if(!PQCSettings.interfaceMinimapPopout) { // qmllint disable unqualified
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
                PQCSettings.imageviewMinimapSizeLevel = 0 // qmllint disable unqualified
        }

        PQMenuItem {
            text: qsTranslate("image", "Normal minimap")
            onTriggered:
                PQCSettings.imageviewMinimapSizeLevel = 1 // qmllint disable unqualified
        }

        PQMenuItem {
            text: qsTranslate("image", "Large minimap")
            onTriggered:
                PQCSettings.imageviewMinimapSizeLevel = 2 // qmllint disable unqualified
        }

        PQMenuItem {
            text: qsTranslate("image", "Very large minimap")
            onTriggered:
                PQCSettings.imageviewMinimapSizeLevel = 3 // qmllint disable unqualified
        }

        PQMenuSeparator {}

        PQMenuItem {
            text: qsTranslate("image", "Hide minimap")
            onTriggered:
                PQCSettings.imageviewShowMinimap = false // qmllint disable unqualified
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
            x: parent.width*flickable.visibleArea.xPosition // qmllint disable unqualified
            y: parent.height*flickable.visibleArea.yPosition // qmllint disable unqualified
            width: parent.width*flickable.visibleArea.widthRatio // qmllint disable unqualified
            height: parent.height*flickable.visibleArea.heightRatio // qmllint disable unqualified
            opacity: 0.7
            color: PQCLook.baseColorAccent // qmllint disable unqualified
            border.width: 2
            border.color: PQCLook.baseColor // qmllint disable unqualified
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
                        flickable.returnToBounds() // qmllint disable unqualified
                    } else {
                        x = x
                        y = y
                    }
                }
            }
            onXChanged: {
                if(navmouse.drag.active) {
                    flickable.contentX = flickable.contentWidth*(x/img.width) // qmllint disable unqualified
                }
            }
            onYChanged: {
                if(navmouse.drag.active) {
                    flickable.contentY = flickable.contentHeight*(y/img.height) // qmllint disable unqualified
                }
            }
        }

        Timer {
            interval: PQCSettings.imageviewAnimationDuration*100 // qmllint disable unqualified
            running: loader_top.visible && !hasBeenTriggered // qmllint disable unqualified
            property bool hasBeenTriggered: false
            onTriggered: {
                hasBeenTriggered = true
                var cl = PQCScriptsFilesPaths.cleanPath(imageloaderitem.imageSource) // qmllint disable unqualified
                if(cl !== "")
                    img.source = encodeURI("image://thumb/" + cl)
            }
        }

    }

    Connections {
        target: imageloaderitem // qmllint disable unqualified
        function onImageSourceChanged(source : string) {
            var cl = PQCScriptsFilesPaths.cleanPath(source) // qmllint disable unqualified
            if(cl !== "")
                img.source = encodeURI("image://thumb/" + cl)
        }
    }

    // the pop in/out button
    Image {
        x: PQCSettings.interfaceMinimapPopout ? 4 : -7 // qmllint disable unqualified
        y: PQCSettings.interfaceMinimapPopout ? 4 : -7 // qmllint disable unqualified
        width: 15
        height: 15
        z: 1
        source: "image://svg/:/" + PQCLook.iconShade + "/popinpopout.svg" // qmllint disable unqualified
        sourceSize: Qt.size(width, height)
        opacity: popinmouse.containsMouse ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        PQMouseArea {
            id: popinmouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            text: PQCSettings.interfaceMinimapPopout ? // qmllint disable unqualified
                      //: Tooltip of small button to merge a popped out element (i.e., one in its own window) into the main interface
                      qsTranslate("popinpopout", "Merge into main interface") :
                      //: Tooltip of small button to show an element in its own window (i.e., not merged into main interface)
                      qsTranslate("popinpopout", "Move to its own window")
            onClicked: {
                PQCSettings.interfaceMinimapPopout = !PQCSettings.interfaceMinimapPopout // qmllint disable unqualified
            }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: 4
            z: -1
            color: PQCLook.transColor // qmllint disable unqualified
            opacity: parent.opacity
        }
    }

    NumberAnimation {
        id: xanim
        target: flickable // qmllint disable unqualified
        property: "contentX"
        duration: 200
        onStopped:
            flickable.returnToBounds() // qmllint disable unqualified
    }
    NumberAnimation {
        id: yanim
        target: flickable // qmllint disable unqualified
        property: "contentY"
        duration: 200
        onStopped:
            flickable.returnToBounds() // qmllint disable unqualified
    }

}
