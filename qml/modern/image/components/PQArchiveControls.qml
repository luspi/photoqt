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

    id: arctop

    Loader {

        active: PQCSettings.filetypesArchiveControls && !PQCFileFolderModel.isARC && !PQCConstants.slideshowRunning // qmllint disable unqualified

        sourceComponent:
        Rectangle {

            id: controlitem

            parent: loader_top // qmllint disable unqualified

            x: (loader_top.width-width)/2
            y: 0.9*loader_top.height
            z: image_top.curZ // qmllint disable unqualified
            width: controlrow.width+20
            height: 50
            radius: 5
            color: PQCLook.transColor // qmllint disable unqualified

            property bool manuallyDragged: false

            property bool isComicBook: PQCScriptsImages.isComicBook(imageloaderitem.imageSource) // qmllint disable unqualified

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
                if(x !== (parent.width-width)/2 && controlitem.manuallyDragged) {
                    image_top.extraControlsLocation.x = x // qmllint disable unqualified
                    x = x
                }
            }
            onYChanged: {
                if(y !== 0.9*parent.height && controlitem.manuallyDragged) {
                    image_top.extraControlsLocation.y = y // qmllint disable unqualified
                    y = y
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
            opacity: (image.fileCount>1 && image.visible && PQCSettings.filetypesArchiveControls && !PQCFileFolderModel.isARC) ? (hovered ? 1 : 0.3) : 0 // qmllint disable unqualified
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: opacity>0
            enabled: visible

            // the first property is set by PCNotify signals for everything else not caught with the elements below
            property bool emptyAreaHovered: false
            property bool hovered: controldrag.containsMouse||leftrightmouse.containsMouse||viewermodemouse.containsMouse||
                                   emptyAreaHovered||controlclosemouse.containsMouse||fileselect.hovered||fileselect.popup.visible||
                                   mouseprev.containsMouse||mousenext.containsMouse||mousefirst.containsMouse||mouselast.containsMouse||
                                   controlresetmouse.containsMouse||menu.visible

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
                acceptedButtons: Qt.RightButton|Qt.LeftButton
                propagateComposedEvents: true
                onWheel: {}
                drag.onActiveChanged: if(active) controlitem.manuallyDragged = true
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

                PQComboBox {

                    id: fileselect

                    y: (parent.height-height)/2
                    elide: Text.ElideMiddle
                    transparentBackground: true

                    visible: !controlitem.isComicBook

                    currentIndex: image.currentFile // qmllint disable unqualified

                    onCurrentIndexChanged: {
                        if(currentIndex !== image.currentFile) { // qmllint disable unqualified
                            image.currentFile = currentIndex
                            image.setSource()
                        }
                    }

                    model: image.fileList // qmllint disable unqualified

                    popup.onOpened: {
                        PQCNotify.currentArchiveComboOpen = true
                    }
                    popup.onClosed: {
                        PQCNotify.currentArchiveComboOpen = false
                    }
                    Connections {
                        target: PQCNotify
                        function onCurrentArchiveCloseCombo() {
                            fileselect.popup.close()
                        }
                    }

                }



                Row {

                    y: (parent.height-height)/2
                    visible: controlitem.isComicBook

                    Rectangle {
                        y: (parent.height-height)/2
                        color: mousefirst.containsPress ? PQCLook.baseColorActive : (mousefirst.containsMouse ? PQCLook.baseColorAccent : "transparent") // qmllint disable unqualified
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
                            source: "image://svg/:/" + PQCLook.iconShade + "/first.svg" // qmllint disable unqualified
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
                                    PQCNotify.currentArchiveJump(-image.currentFile)
                                else
                                    menu.popup()
                            }
                        }
                    }

                    Rectangle {
                        y: (parent.height-height)/2
                        color: mouseprev.containsPress ? PQCLook.baseColorActive : (mouseprev.containsMouse ? PQCLook.baseColorAccent : "transparent") // qmllint disable unqualified
                        Behavior on color { ColorAnimation { duration: 200 } }
                        width: height-6
                        height: controlitem.height/1.5 + 6
                        radius: 4
                        Image {
                            y: 3
                            width: parent.width
                            height: parent.height-6
                            sourceSize: Qt.size(width, height)
                            source: "image://svg/:/" + PQCLook.iconShade + "/backwards.svg" // qmllint disable unqualified
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
                                    PQCNotify.currentArchiveJump(-1)
                                else
                                    menu.popup()
                            }
                        }
                    }

                    Rectangle {
                        y: (parent.height-height)/2
                        color: mousenext.containsPress ? PQCLook.baseColorActive : (mousenext.containsMouse ? PQCLook.baseColorAccent : "transparent") // qmllint disable unqualified
                        Behavior on color { ColorAnimation { duration: 200 } }
                        width: height-6
                        height: controlitem.height/1.5 + 6
                        radius: 4
                        Image {
                            y: 3
                            width: parent.width
                            height: parent.height-6
                            sourceSize: Qt.size(width, height)
                            source: "image://svg/:/" + PQCLook.iconShade + "/forwards.svg" // qmllint disable unqualified
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
                                    PQCNotify.currentArchiveJump(1)
                                else
                                    menu.popup()
                            }
                        }
                    }

                    Rectangle {
                        y: (parent.height-height)/2
                        color: mouselast.containsPress ? PQCLook.baseColorActive : (mouselast.containsMouse ? PQCLook.baseColorAccent : "transparent") // qmllint disable unqualified
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
                            source: "image://svg/:/" + PQCLook.iconShade + "/last.svg" // qmllint disable unqualified
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
                                    PQCNotify.currentArchiveJump(image.fileCount-image.currentFile-1)
                                else
                                    menu.popup()
                            }
                        }
                    }

                }

                Item {
                    width: 5
                    height: 1
                    visible: controlitem.isComicBook
                }

                Rectangle {
                    y: (parent.height-height)/2
                    height: controlitem.height*0.75
                    width: 1
                    color: PQCLook.textColor // qmllint disable unqualified
                    visible: controlitem.isComicBook
                }

                Item {
                    width: 5
                    height: 1
                    visible: controlitem.isComicBook
                }

                PQText {
                    y: (parent.height-height)/2
                    visible: controlitem.isComicBook
                    text: visible ? qsTranslate("image", "Page %1/%2").arg(image.currentFile+1).arg(image.fileCount) : "" // qmllint disable unqualified
                }

                Item {
                    width: 5
                    height: 1
                }

                Rectangle {
                    y: (parent.height-height)/2
                    width: 1
                    height: controlitem.height*0.75
                    color: PQCLook.textColor // qmllint disable unqualified
                }

                Item {
                    width: 5
                    height: 1
                }

                Rectangle {
                    y: (parent.height-height)/2
                    color: viewermodemouse.containsPress ? PQCLook.baseColorActive : (viewermodemouse.containsMouse ? PQCLook.baseColorAccent : "transparent") // qmllint disable unqualified
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
                        source: "image://svg/:/" + PQCLook.iconShade + "/viewermode_on.svg" // qmllint disable unqualified
                        PQMouseArea {
                            id: viewermodemouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton|Qt.RightButton
                            text: qsTranslate("image", "Click to enter viewer mode")
                            onClicked: (mouse) => {
                                if(mouse.button === Qt.LeftButton)
                                    PQCFileFolderModel.enableViewerMode(image.currentFile) // qmllint disable unqualified
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

                    opacity: PQCSettings.filetypesArchiveLeftRight ? 1 : 0.3 // qmllint disable unqualified
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    color: leftrightmouse.containsPress ? PQCLook.baseColorActive : (leftrightmouse.containsMouse ? PQCLook.baseColorAccent : "transparent") // qmllint disable unqualified
                    Behavior on color { ColorAnimation { duration: 200 } }

                    Row {
                        id: lockrow
                        x: 3
                        y: 3

                        Image {
                            height: controlitem.height/2.5
                            width: height
                            source: "image://svg/:/" + PQCLook.iconShade + "/padlock.svg" // qmllint disable unqualified
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
                                PQCSettings.filetypesArchiveLeftRight = !PQCSettings.filetypesArchiveLeftRight // qmllint disable unqualified
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
                source: "image://svg/:/" + PQCLook.iconShade + "/close.svg" // qmllint disable unqualified
                sourceSize: Qt.size(width, height)
                PQMouseArea {
                    id: controlclosemouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    text: qsTranslate("image", "Hide controls")
                    onClicked: (mouse) => {
                        PQCSettings.filetypesArchiveControls = false // qmllint disable unqualified
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
                    checked: PQCSettings.filetypesArchiveLeftRight
                    text: qsTranslate("image", "Arrow keys")
                    onCheckedChanged: {
                        PQCSettings.filetypesArchiveLeftRight = checked
                        checked = Qt.binding(function() { return PQCSettings.filetypesArchiveLeftRight })
                        menu.dismiss()
                    }
                }

                PQMenuItem {
                    iconSource: "image://svg/:/" + PQCLook.iconShade + "/viewermode_on.svg"
                    text: qsTranslate("image", "Viewer mode")
                    onTriggered: {
                        PQCFileFolderModel.enableViewerMode(image.currentFile)
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
                        PQCSettings.filetypesArchiveControls = false // qmllint disable unqualified
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
                    PQCConstants.addToWhichContextMenusOpen("archivecontrols") // qmllint disable unqualified

                Timer {
                    id: recordAsClosed
                    interval: 200
                    onTriggered: {
                        if(!menu.visible)
                            PQCConstants.removeFromWhichContextMenusOpen("archivecontrols") // qmllint disable unqualified
                    }
                }
            }

            Connections {

                target: PQCNotify // qmllint disable unqualified

                enabled: controlitem.enabled

                function onMouseMove(x : int, y : int) {

                    // check if the control item is hovered anywhere not caught by the elements above
                    var local = controlitem.mapFromItem(fullscreenitem, Qt.point(x,y)) // qmllint disable unqualified
                    controlitem.emptyAreaHovered = (local.x > 0 && local.y > 0 && local.x < controlitem.width && local.y < controlitem.height)

                }

                function onCloseAllContextMenus() {
                    menu.dismiss()
                }

            }

        }

    }

}
