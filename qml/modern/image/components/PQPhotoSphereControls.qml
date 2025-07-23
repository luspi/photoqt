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

    id: control_top

    /*******************************************/
    // these values are READONLY

    property Item loaderTop

    /*******************************************/

    signal facetrackerLoadData()

    /*******************************************/

    visible: PQCSettings.filetypesPhotoSphereControls && PQCConstants.showingPhotoSphere

    Rectangle {

        id: controlitem

        parent: control_top.loaderTop

        x: (control_top.loaderTop.width-width)/2
        y: 0.9*control_top.loaderTop.height
        z: PQCConstants.currentZValue
        width: leftrightlock.width
        height: 30
        radius: 5
        color: PQCLook.transColor

        property bool manuallyDragged: false

        Connections {
            target: control_top.loaderTop
            enabled: controlitem.manuallyDragged
            function onWidthChanged() {
                controlitem.x = Math.min(controlitem.x, control_top.loaderTop.width-controlitem.width-5)
            }
            function onHeightChanged() {
                controlitem.y = Math.min(controlitem.y, control_top.loaderTop.height-controlitem.height-5)
            }
        }

        onXChanged: {
            if(x !== (parent.width-width)/2) {
                if(controlitem.manuallyDragged) {
                    PQCConstants.extraControlsLocation.x = x
                    x = x
                }
            }
        }
        onYChanged: {
            if(y !== 0.9*parent.height) {
                if(controlitem.manuallyDragged) {
                    PQCConstants.extraControlsLocation.y = y
                    y = y
                }
            }
        }

        Component.onCompleted: {
            if(PQCConstants.extraControlsLocation.x !== -1) {
                controlitem.x = PQCConstants.extraControlsLocation.x
                controlitem.y = PQCConstants.extraControlsLocation.y
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
            drag.maximumX: control_top.loaderTop.width-controlitem.width-5
            drag.maximumY: control_top.loaderTop.height-controlitem.height-5
            hoverEnabled: true
            cursorShape: Qt.SizeAllCursor
            propagateComposedEvents: true
            acceptedButtons: Qt.LeftButton|Qt.RightButton
            onWheel: {}
            drag.onActiveChanged: if(drag.active) controlitem.manuallyDragged = true
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

            opacity: PQCSettings.filetypesPhotoSphereArrowKeys ? 1 : 0.3
            Behavior on opacity { NumberAnimation { duration: 200 } }

            color: leftrightmouse.containsPress ? PQCLook.baseColorActive : (leftrightmouse.containsMouse ? PQCLook.baseColorAccent : "transparent")
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
                    source: "image://svg/:/" + PQCLook.iconShade + "/padlock.svg"
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
                drag.maximumX: control_top.loaderTop.width-controlitem.width-5
                drag.maximumY: control_top.loaderTop.height-controlitem.height-5
                drag.onActiveChanged: if(drag.active) controlitem.manuallyDragged = true
                text: qsTranslate("image", "Lock arrow keys to moving photo sphere")
                onClicked: (mouse) => {
                    if(mouse.button === Qt.LeftButton)
                        PQCSettings.filetypesPhotoSphereArrowKeys = !PQCSettings.filetypesPhotoSphereArrowKeys
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
            source: "image://svg/:/" + PQCLook.iconShade + "/close.svg"
            sourceSize: Qt.size(width, height)
            PQMouseArea {
                id: controlclosemouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                text: qsTranslate("image", "Hide controls")
                onClicked: (mouse) => {
                    PQCSettings.filetypesPhotoSphereControls = false
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
            source: "image://svg/:/" + PQCLook.iconShade + "/reset.svg"
            sourceSize: Qt.size(width, height)
            PQMouseArea {
                id: controlresetmouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                text: qsTranslate("image", "Reset position")
                onClicked: (mouse) => {
                    controlitem.manuallyDragged = false
                    controlitem.x = Qt.binding(function() { return (control_top.loaderTop.width-controlitem.width)/2 })
                    controlitem.y = Qt.binding(function() { return (0.9*control_top.loaderTop.height) })
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
                    PQCSettings.filetypesPhotoSphereControls = false
            }

            onVisibleChanged: {
                if(!visible && resetPosAfterHide) {
                    resetPosAfterHide = false
                    controlitem.manuallyDragged = false
                    controlitem.x = Qt.binding(function() { return (control_top.loaderTop.width-controlitem.width)/2 })
                    controlitem.y = Qt.binding(function() { return (0.9*control_top.loaderTop.height) })
                }
            }

            onAboutToHide:
                recordAsClosed.restart()
            onAboutToShow:
                PQCConstants.addToWhichContextMenusOpen("spherecontrols")

            Timer {
                id: recordAsClosed
                interval: 200
                onTriggered: {
                    if(!menu.visible)
                        PQCConstants.removeFromWhichContextMenusOpen("spherecontrols")
                }
            }
        }

        Connections {

            target: PQCNotify

            enabled: controlitem.enabled

            function onMouseMove(x : int, y : int) {

                // check if the control item is hovered anywhere not caught by the elements above
                var local = controlitem.mapFromItem(fullscreenitem, Qt.point(x,y))
                controlitem.emptyAreaHovered = (local.x > 0 && local.y > 0 && local.x < controlitem.width && local.y < controlitem.height)

            }

        }

        Connections {

            target: PQCNotify

            function onCloseAllContextMenus() {
                menu.dismiss()
            }

        }

    }

}
