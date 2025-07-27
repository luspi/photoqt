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

Item {

    id: docctrltop

    /*******************************************/
    // these values are READONLY

    property Item loaderTop
    property int pageCount
    property int currentPage

    /*******************************************/

    property bool pressed: false

    Loader {

        active: PQCSettings.filetypesDocumentControls&&!PQCFileFolderModel.isPDF && !PQCConstants.slideshowRunning

        sourceComponent:
        Rectangle {

            id: controlitem

            parent: docctrltop.loaderTop

            x: (docctrltop.loaderTop.width-width)/2
            y: 0.9*docctrltop.loaderTop.height
            z: PQCConstants.currentZValue
            width: controlrow.width+20
            height: 50
            radius: 5
            color: PQCLook.transColor

            property bool manuallyDragged: false

            Connections {
                target: docctrltop.loaderTop
                enabled: controlitem.manuallyDragged
                function onWidthChanged() {
                    controlitem.x = Math.min(controlitem.x, docctrltop.loaderTop.width-controlitem.width-5)
                }
                function onHeightChanged() {
                    controlitem.y = Math.min(controlitem.y, docctrltop.loaderTop.height-controlitem.height-5)
                }
            }

            onXChanged: {
                if(x !== (parent.width-width)/2 && controlitem.manuallyDragged) {
                    PQCConstants.extraControlsLocation.x = x
                    x = x
                }
            }
            onYChanged: {
                if(y !== 0.9*parent.height && controlitem.manuallyDragged) {
                    PQCConstants.extraControlsLocation.y = y
                    y = y
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
            opacity: (docctrltop.pageCount>1 && image.visible && PQCSettings.filetypesDocumentControls && !PQCFileFolderModel.isPDF) ? (hovered ? 1 : 0.3) : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: opacity>0
            enabled: visible

            // the first property is set by PCNotify signals for everything else not caught with the elements below
            property bool emptyAreaHovered: false
            property bool hovered: controldrag.containsMouse||leftrightmouse.containsMouse||viewermodemouse.containsMouse||
                                   emptyAreaHovered||controlclosemouse.containsMouse||mouseprev.containsMouse||mousenext.containsMouse||
                                   mousefirst.containsMouse||mouselast.containsMouse||controlresetmouse.containsMouse||menu.visible

            // drag and catch wheel events
            MouseArea {
                id: controldrag
                anchors.fill: parent
                drag.target: parent
                drag.minimumX: 5
                drag.minimumY: 5
                drag.maximumX: docctrltop.loaderTop.width-controlitem.width-5
                drag.maximumY: docctrltop.loaderTop.height-controlitem.height-5
                hoverEnabled: true
                cursorShape: Qt.SizeAllCursor
                acceptedButtons: Qt.RightButton|Qt.LeftButton
                propagateComposedEvents: true
                onWheel: {}
                drag.onActiveChanged: if(drag.active) controlitem.manuallyDragged = true
                onClicked: (mouse) => {
                    if(mouse.button === Qt.RightButton)
                        menu.popup()
                }
            }

            Row {

                id: controlrow

                x: 10
                y: (parent.height-height)/2
                spacing: 5

                Row {
                    y: (parent.height-height)/2

                    Rectangle {
                        y: (parent.height-height)/2
                        color: mousefirst.containsPress ? PQCLook.baseColorActive : (mousefirst.containsMouse ? PQCLook.baseColorAccent : "transparent")
                        Behavior on color { ColorAnimation { duration: 200 } }
                        width: height
                        height: controlitem.height/2.5 + 10
                        radius: 4
                        Image {
                            x: 5
                            y: 5
                            width: parent.width-10
                            height: parent.height-10
                            sourceSize: Qt.size(width, height)
                            source: "image://svg/:/" + PQCLook.iconShade + "/first.svg"
                        }
                        PQMouseArea {
                            id: mousefirst
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.RightButton|Qt.LeftButton
                            text: qsTranslate("image", "Go to first page")
                            onClicked: (mouse) => {
                                if(mouse.button === Qt.LeftButton)
                                    PQCNotify.currentDocumentJump(-docctrltop.currentPage)
                                else
                                    menu.popup()
                            }
                        }
                    }

                    Rectangle {
                        y: (parent.height-height)/2
                        color: mouseprev.containsPress ? PQCLook.baseColorActive : (mouseprev.containsMouse ? PQCLook.baseColorAccent : "transparent")
                        Behavior on color { ColorAnimation { duration: 200 } }
                        width: height-6
                        height: controlitem.height/1.5 + 6
                        radius: 4
                        Image {
                            y: 3
                            width: parent.width
                            height: parent.height-6
                            sourceSize: Qt.size(width, height)
                            source: "image://svg/:/" + PQCLook.iconShade + "/backwards.svg"
                        }
                        PQMouseArea {
                            id: mouseprev
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.RightButton|Qt.LeftButton
                            text: qsTranslate("image", "Go to previous page")
                            onClicked: (mouse) => {
                                if(mouse.button === Qt.LeftButton)
                                    PQCNotify.currentDocumentJump(-1)
                                else
                                    menu.popup()
                            }
                        }
                    }

                    Rectangle {
                        y: (parent.height-height)/2
                        color: mousenext.containsPress ? PQCLook.baseColorActive : (mousenext.containsMouse ? PQCLook.baseColorAccent : "transparent")
                        Behavior on color { ColorAnimation { duration: 200 } }
                        width: height-6
                        height: controlitem.height/1.5 + 6
                        radius: 4
                        Image {
                            y: 3
                            width: parent.width
                            height: parent.height-6
                            sourceSize: Qt.size(width, height)
                            source: "image://svg/:/" + PQCLook.iconShade + "/forwards.svg"
                        }
                        PQMouseArea {
                            id: mousenext
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.RightButton|Qt.LeftButton
                            text: qsTranslate("image", "Go to next page")
                            onClicked: (mouse) => {
                                if(mouse.button === Qt.LeftButton)
                                    PQCNotify.currentDocumentJump(1)
                                else
                                    menu.popup()
                            }
                        }
                    }

                    Rectangle {
                        y: (parent.height-height)/2
                        color: mouselast.containsPress ? PQCLook.baseColorActive : (mouselast.containsMouse ? PQCLook.baseColorAccent : "transparent")
                        Behavior on color { ColorAnimation { duration: 200 } }
                        width: height
                        height: controlitem.height/2.5 + 10
                        radius: 4
                        Image {
                            x: 5
                            y: 5
                            width: parent.width-10
                            height: parent.height-10
                            sourceSize: Qt.size(width, height)
                            source: "image://svg/:/" + PQCLook.iconShade + "/last.svg"
                        }
                        PQMouseArea {
                            id: mouselast
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.RightButton|Qt.LeftButton
                            text: qsTranslate("image", "Go to last page")
                            onClicked: (mouse) => {
                                if(mouse.button === Qt.LeftButton)
                                    PQCNotify.currentDocumentJump(docctrltop.pageCount-docctrltop.currentPage-1)
                                else
                                    menu.popup()
                            }
                        }
                    }

                }

                Item {
                    width: 5
                    height: 1
                }

                Rectangle {
                    y: (parent.height-height)/2
                    height: controlitem.height*0.75
                    width: 1
                    color: PQCLook.textColor
                }

                Item {
                    width: 5
                    height: 1
                }

                PQText {
                    y: (parent.height-height)/2
                    text: qsTranslate("image", "Page %1/%2").arg(docctrltop.currentPage+1).arg(docctrltop.pageCount)
                }

                Item {
                    width: 5
                    height: 1
                }

                Rectangle {
                    y: (parent.height-height)/2
                    height: controlitem.height*0.75
                    width: 1
                    color: PQCLook.textColor
                }

                Item {
                    width: 5
                    height: 1
                }

                Rectangle {
                    y: (parent.height-height)/2
                    color: viewermodemouse.containsPress ? PQCLook.baseColorActive : (viewermodemouse.containsMouse ? PQCLook.baseColorAccent : "transparent")
                    Behavior on color { ColorAnimation { duration: 200 } }
                    height: width
                    width: controlitem.height/2.5 + 10
                    radius: 5
                    Image {
                        x: 5
                        y: 5
                        width: height
                        height: parent.height-10
                        sourceSize: Qt.size(width, height)
                        source: "image://svg/:/" + PQCLook.iconShade + "/viewermode_on.svg"
                        PQMouseArea {
                            id: viewermodemouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton|Qt.RightButton
                            text: qsTranslate("image", "Click to enter viewer mode")
                            onClicked: (mouse) => {
                                if(mouse.button === Qt.LeftButton)
                                    PQCFileFolderModel.enableViewerMode(docctrltop.currentPage)
                                else
                                    menu.popup()
                            }
                        }
                    }
                }

                Rectangle {

                    id: leftrightlock

                    y: (parent.height-height)/2
                    width: lockrow.width+6
                    height: lockrow.height+6
                    radius: 5

                    opacity: PQCSettings.filetypesDocumentLeftRight ? 1 : 0.3
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    color: leftrightmouse.containsPress ? PQCLook.baseColorActive : (leftrightmouse.containsMouse ? PQCLook.baseColorAccent : "transparent")
                    Behavior on color { ColorAnimation { duration: 200 } }

                    Row {
                        id: lockrow
                        x: 3
                        y: 3

                        Image {
                            height: controlitem.height/2.5
                            width: height
                            source: "image://svg/:/" + PQCLook.iconShade + "/padlock.svg"
                            sourceSize: Qt.size(width, height)
                        }

                        PQText {
                            text: "←/→"
                        }

                    }

                    PQMouseArea {
                        id: leftrightmouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton|Qt.RightButton
                        text: qsTranslate("image", "Lock left/right arrow keys to page navigation")
                        onClicked: (mouse) => {
                            if(mouse.button === Qt.LeftButton)
                                PQCSettings.filetypesDocumentLeftRight = !PQCSettings.filetypesDocumentLeftRight
                            else
                                menu.popup()
                        }
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
                        PQCSettings.filetypesDocumentControls = false
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
                        controlitem.x = Qt.binding(function() { return (docctrltop.loaderTop.width-controlitem.width)/2 })
                        controlitem.y = Qt.binding(function() { return (0.9*docctrltop.loaderTop.height) })
                    }
                }
            }

            PQMenu {
                id: menu

                property bool resetPosAfterHide: false

                PQMenuItem {
                    checkable: true
                    checked: PQCSettings.filetypesDocumentLeftRight
                    text: qsTranslate("image", "Arrow keys")
                    onCheckedChanged: {
                        PQCSettings.filetypesDocumentLeftRight = checked
                        checked = Qt.binding(function() { return PQCSettings.filetypesDocumentLeftRight })
                        menu.dismiss()
                    }
                }

                PQMenuItem {
                    iconSource: "image://svg/:/" + PQCLook.iconShade + "/viewermode_on.svg"
                    text: qsTranslate("image", "Viewer mode")
                    onTriggered: {
                        PQCFileFolderModel.enableViewerMode(docctrltop.currentPage)
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
                        PQCSettings.filetypesDocumentControls = false
                }

                onVisibleChanged: {
                    if(!visible && resetPosAfterHide) {
                        resetPosAfterHide = false
                        controlitem.manuallyDragged = false
                        controlitem.x = Qt.binding(function() { return (docctrltop.loaderTop.width-controlitem.width)/2 })
                        controlitem.y = Qt.binding(function() { return (0.9*docctrltop.loaderTop.height) })
                    }
                }

                onAboutToHide:
                    recordAsClosed.restart()
                onAboutToShow:
                    PQCConstants.addToWhichContextMenusOpen("documentcontrols")

                Timer {
                    id: recordAsClosed
                    interval: 200
                    onTriggered: {
                        if(!menu.visible)
                            PQCConstants.removeFromWhichContextMenusOpen("documentcontrols")
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

                function onCloseAllContextMenus() {
                    menu.dismiss()
                }

            }

        }

    }

}
