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
import PQCFileFolderModel
import PhotoQt

Item {

    id: top

    Loader {

        active: PQCSettings.filetypesPhotoSphereControls && PQCConstants.showingPhotoSphere // qmllint disable unqualified

        sourceComponent:
        Rectangle {

            id: controlitem

            parent: loader_top // qmllint disable unqualified

            x: (loader_top.width-width)/2
            y: 0.9*loader_top.height
            z: image_top.curZ // qmllint disable unqualified
            width: leftrightlock.width
            height: 30
            radius: 5
            color: PQCLook.transColor // qmllint disable unqualified

            property bool manuallyDragged: false

            Connections {
                target: image_top // qmllint disable unqualified
                enabled: controlitem.manuallyDragged
                function onWidthChanged() {
                    controlitem.x = Math.min(controlitem.x, image_top.width-controlitem.width-5) // qmllint disable unqualified
                }
                function onHeightChanged() {
                    controlitem.y = Math.min(controlitem.y, image_top.height-controlitem.height-5) // qmllint disable unqualified
                }
            }

            onXChanged: {
                if(x !== (parent.width-width)/2) {
                    if(controlitem.manuallyDragged) {
                        image_top.extraControlsLocation.x = x // qmllint disable unqualified
                        x = x
                    }
                }
            }
            onYChanged: {
                if(y !== 0.9*parent.height) {
                    if(controlitem.manuallyDragged) {
                        image_top.extraControlsLocation.y = y // qmllint disable unqualified
                        y = y
                    }
                }
            }

            Component.onCompleted: {
                if(image_top.extraControlsLocation.x !== -1) { // qmllint disable unqualified
                    controlitem.x = image_top.extraControlsLocation.x
                    controlitem.y = image_top.extraControlsLocation.y
                    controlitem.manuallyDragged = true
                }
            }

            // only show when needed
            opacity: (hovered ? 1 : 0.3)
            Behavior on opacity { NumberAnimation { duration: 200 } }

            // the first property is set by PCNotify signals for everything else not caught with the elements below
            property bool emptyAreaHovered: false
            property bool hovered: controldrag.containsMouse||leftrightmouse.containsMouse||
                                   emptyAreaHovered||controlclosemouse.containsMouse||controlresetmouse.containsMouse||
                                   menu.visible

            // drag and catch wheel events
            MouseArea {
                id: controldrag
                anchors.fill: parent
                drag.target: parent
                drag.minimumX: 5
                drag.minimumY: 5
                drag.maximumX: image_top.width-controlitem.width-5 // qmllint disable unqualified
                drag.maximumY: image_top.height-controlitem.height-5 // qmllint disable unqualified
                hoverEnabled: true
                cursorShape: Qt.SizeAllCursor
                propagateComposedEvents: true
                acceptedButtons: Qt.LeftButton|Qt.RightButton
                onWheel: {}
                drag.onActiveChanged: if(active) controlitem.manuallyDragged = true
                onClicked: (mouse) => {
                    if(mouse.button === Qt.RightButton)
                        menu.popup()
                }
            }

            Rectangle {

                id: leftrightlock

                x: 0
                y: (parent.height-height)/2
                width: lockrow.width+10
                height: lockrow.height+10
                radius: 5

                opacity: PQCSettings.filetypesPhotoSphereArrowKeys ? 1 : 0.3 // qmllint disable unqualified
                Behavior on opacity { NumberAnimation { duration: 200 } }

                color: leftrightmouse.containsPress ? PQCLook.baseColorActive : (leftrightmouse.containsMouse ? PQCLook.baseColorAccent : "transparent") // qmllint disable unqualified
                Behavior on color { ColorAnimation { duration: 200 } }

                Row {
                    id: lockrow
                    x: 5
                    y: 5
                    spacing: 5

                    Image {
                        y: (parent.height-height)/2
                        height: leftrighttxt.height/1.2
                        width: height
                        source: "image://svg/:/" + PQCLook.iconShade + "/padlock.svg" // qmllint disable unqualified
                        sourceSize: Qt.size(width, height)
                    }

                    PQText {
                        id: leftrighttxt
                        text: "←/→"
                    }

                }

                PQMouseArea {
                    id: leftrightmouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.RightButton|Qt.LeftButton
                    drag.target: controlitem
                    drag.minimumX: 5
                    drag.minimumY: 5
                    drag.maximumX: image_top.width-controlitem.width-5 // qmllint disable unqualified
                    drag.maximumY: image_top.height-controlitem.height-5 // qmllint disable unqualified
                    drag.onActiveChanged: if(active) controlitem.manuallyDragged = true
                    text: qsTranslate("image", "Lock arrow keys to moving photo sphere")
                    onClicked: (mouse) => {
                        if(mouse.button === Qt.LeftButton)
                            PQCSettings.filetypesPhotoSphereArrowKeys = !PQCSettings.filetypesPhotoSphereArrowKeys // qmllint disable unqualified
                        else
                            menu.popup()
                    }
                }

            }

            // the close button is only visible when hovered
            Image {
                x: parent.width-width+10
                y: -10
                width: 20
                height: 20
                opacity: controlclosemouse.containsMouse ? 0.75 : 0
                Behavior on opacity { NumberAnimation { duration: 300 } }
                source: "image://svg/:/" + PQCLook.iconShade + "/close.svg" // qmllint disable unqualified
                sourceSize: Qt.size(width, height)
                PQMouseArea {
                    id: controlclosemouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    text: qsTranslate("image", "Hide controls")
                    onClicked: (mouse) => {
                        PQCSettings.filetypesPhotoSphereControls = false // qmllint disable unqualified
                    }
                }
            }

            // the reset position button is only visible when hovered
            Image {
                x: -10
                y: -10
                width: 20
                height: 20
                opacity: controlresetmouse.containsMouse ? 0.75 : 0
                Behavior on opacity { NumberAnimation { duration: 300 } }
                source: "image://svg/:/" + PQCLook.iconShade + "/reset.svg" // qmllint disable unqualified
                sourceSize: Qt.size(width, height)
                PQMouseArea {
                    id: controlresetmouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    text: qsTranslate("image", "Reset position")
                    onClicked: (mouse) => {
                        controlitem.manuallyDragged = false
                        controlitem.x = Qt.binding(function() { return (loader_top.width-controlitem.width)/2 })
                        controlitem.y = Qt.binding(function() { return (0.9*loader_top.height) })
                    }
                }
            }

            PQMenu {
                id: menu

                property bool resetPosAfterHide: false

                PQMenuItem {
                    checkable: true
                    checked: PQCSettings.filetypesPhotoSphereArrowKeys
                    text: qsTranslate("image", "Arrow keys")
                    onCheckedChanged: {
                        PQCSettings.filetypesPhotoSphereArrowKeys = checked
                        checked = Qt.binding(function() { return PQCSettings.filetypesPhotoSphereArrowKeys })
                        menu.dismiss()
                    }
                }

                PQMenuSeparator {}

                PQMenuItem {
                    iconSource: "image://svg/:/" + PQCLook.iconShade + "/reset.svg"
                    text: qsTranslate("image", "Reset position")
                    onTriggered: {
                        menu.resetPosAfterHide = true
                    }
                }

                PQMenuItem {
                    iconSource: "image://svg/:/" + PQCLook.iconShade + "/close.svg"
                    text: qsTranslate("image", "Hide controls")
                    onTriggered:
                        PQCSettings.filetypesPhotoSphereControls = false // qmllint disable unqualified
                }

                onVisibleChanged: {
                    if(!visible && resetPosAfterHide) {
                        resetPosAfterHide = false
                        controlitem.manuallyDragged = false
                        controlitem.x = Qt.binding(function() { return (loader_top.width-controlitem.width)/2 })
                        controlitem.y = Qt.binding(function() { return (0.9*loader_top.height) })
                    }
                }

                onAboutToHide:
                    recordAsClosed.restart()
                onAboutToShow:
                    PQCConstants.addToWhichContextMenusOpen("spherecontrols") // qmllint disable unqualified

                Timer {
                    id: recordAsClosed
                    interval: 200
                    onTriggered: {
                        if(!menu.visible)
                            PQCConstants.removeFromWhichContextMenusOpen("spherecontrols") // qmllint disable unqualified
                    }
                }
            }

            Connections {

                target: PQCNotifyQML

                enabled: controlitem.enabled

                function onMouseMove(x : int, y : int) {

                    // check if the control item is hovered anywhere not caught by the elements above
                    var local = controlitem.mapFromItem(fullscreenitem, Qt.point(x,y)) // qmllint disable unqualified
                    controlitem.emptyAreaHovered = (local.x > 0 && local.y > 0 && local.x < controlitem.width && local.y < controlitem.height)

                }

            }

            Connections {

                target: PQCNotifyQML

                function onCloseAllContextMenus() {
                    menu.dismiss()
                }

            }

        }

    }

}
