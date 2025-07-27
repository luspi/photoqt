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
import PhotoQt.Shared

Rectangle {

    id: minimap_top

    property int sl: PQCSettings.imageviewMinimapSizeLevel

    SystemPalette { id: pqtPalette }

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

    property bool minimapNeeded: (PQCConstants.currentImageScale > PQCConstants.currentImageDefaultScale*1.01 && (PQCConstants.currentVisibleContentSize.width > PQCConstants.imageDisplaySize.width || PQCConstants.currentVisibleContentSize.height > PQCConstants.imageDisplaySize.height)) && !PQCConstants.slideshowRunning && !PQCConstants.showingPhotoSphere
    property bool minimapActive: false
    property bool containsMouse: movemouse.containsMouse||minimapmouse.containsMouse||navmouse.containsMouse

    Connections {
        target: PQCConstants
        function onCurrentImageScaleChanged() {
            minimap_top.minimapActive = true
            minimapMakeDeactive.start()
        }
        function onCurrentVisibleAreaXChanged() {
            minimap_top.minimapActive = true
            minimapMakeDeactive.start()
        }
        function onCurrentVisibleAreaYChanged() {
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

    Text {
        color: pqtPalette.text
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

                PQCNotify.currentFlickableAnimateContentPosChange(propX,propY)

            } else if(mouse.button === Qt.RightButton) {
                PQCNotify.showMinimapContextMenu()
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

    // PQMenu {

    //     id: rightclickmenu

    //     PQMenuItem {
    //         text: qsTranslate("image", "Small minimap")
    //         onTriggered:
    //             PQCSettings.imageviewMinimapSizeLevel = 0
    //     }

    //     PQMenuItem {
    //         text: qsTranslate("image", "Normal minimap")
    //         onTriggered:
    //             PQCSettings.imageviewMinimapSizeLevel = 1
    //     }

    //     PQMenuItem {
    //         text: qsTranslate("image", "Large minimap")
    //         onTriggered:
    //             PQCSettings.imageviewMinimapSizeLevel = 2
    //     }

    //     PQMenuItem {
    //         text: qsTranslate("image", "Very large minimap")
    //         onTriggered:
    //             PQCSettings.imageviewMinimapSizeLevel = 3
    //     }

    //     PQMenuSeparator {}

    //     PQMenuItem {
    //         text: qsTranslate("image", "Hide minimap")
    //         onTriggered:
    //             PQCSettings.imageviewShowMinimap = false
    //     }

    // }

    Image {
        id: img

        fillMode: Image.PreserveAspectFit
        source: ""
        cache: false
        asynchronous: true

        clip: true

        Rectangle {
            x: parent.width*PQCConstants.currentVisibleAreaX
            y: parent.height*PQCConstants.currentVisibleAreaY
            width: parent.width*PQCConstants.currentVisibleAreaWidthRatio
            height: parent.height*PQCConstants.currentVisibleAreaHeightRatio
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
                        x = Qt.binding(function() { return parent.width*PQCConstants.currentVisibleAreaX } )
                        y = Qt.binding(function() { return parent.height*PQCConstants.currentVisibleAreaY } )
                        PQCNotify.currentFlickableReturnToBounds()
                    } else {
                        x = x
                        y = y
                    }
                }
            }
            onXChanged: {
                if(navmouse.drag.active) {
                    PQCNotify.currentFlickableSetContentX(PQCConstants.currentVisibleContentSize.width*(x/img.width))
                }
            }
            onYChanged: {
                if(navmouse.drag.active) {
                    PQCNotify.currentFlickableSetContentY(PQCConstants.currentVisibleContentSize.height*(y/img.height))
                }
            }
        }

        Timer {
            interval: PQCSettings.imageviewAnimationDuration*100
            running: !hasBeenTriggered
            property bool hasBeenTriggered: false
            onTriggered: {
                hasBeenTriggered = true
                var cl = PQCScriptsFilesPaths.cleanPath(PQCFileFolderModel.currentFile)
                if(cl !== "")
                    img.source = encodeURI("image://thumb/" + cl)
            }
        }

    }

    Connections {
        target: PQCFileFolderModel
        function onCurrentFileChanged() {
            var cl = PQCScriptsFilesPaths.cleanPath(PQCFileFolderModel.currentFile)
            if(cl !== "")
                img.source = encodeURI("image://thumb/" + cl)
        }
    }

}
