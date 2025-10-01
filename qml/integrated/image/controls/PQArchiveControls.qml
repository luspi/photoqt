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
import PhotoQt.Integrated
import PhotoQt.Shared

Loader {

    id: ldr_top

    SystemPalette { id: pqtPalette }

    active: PQCConstants.currentImageIsArchive&&PQCConstants.currentFileInsideTotal>1

    sourceComponent:
    Item {

        id: controlitem

        parent: ldr_top.parent

        x: (parent.width-width)/2
        y: parent.height-height-20
        z: PQCConstants.currentZValue+1

        width: cont_row.width+20
        height: 50

        property bool isComicBook: PQCScriptsImages.isComicBook(PQCFileFolderModel.currentFile)

        property bool hovered: bgmouse.containsMouse || leftrightmouse.containsMouse || viewermodemouse.containsMouse ||
                               mouselast.containsMouse || mousenext.containsMouse || mouseprev.containsMouse || mousefirst.containsMouse
        opacity: hovered ? 1 : 0.4
        Behavior on opacity { NumberAnimation { duration: 200 } }

        property bool manuallyDragged: false

        Connections {
            target: ldr_top.parent.parent
            enabled: controlitem.manuallyDragged
            function onWidthChanged() {
                controlitem.x = Math.min(controlitem.x, ldr_top.parent.parent.width-controlitem.width-5)
            }
            function onHeightChanged() {
                controlitem.y = Math.min(controlitem.y, ldr_top.parent.parent.height-controlitem.height-5)
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

        Rectangle {
            anchors.fill: parent
            color: pqtPalette.base
            opacity: 0.9
            radius: 5
        }

        MouseArea {
            id: bgmouse
            anchors.fill: parent
            drag.target: parent
            drag.minimumX: 5
            drag.minimumY: 5
            drag.maximumX: ldr_top.parent.parent.width-controlitem.width-5
            drag.maximumY: ldr_top.parent.parent.height-controlitem.height-5
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

            id: cont_row

            x: 10
            y: (parent.height-height)/2
            spacing: 5

            PQComboBox {

                id: fileselect

                y: (parent.height-height)/2
                width: 400

                elide: Text.ElideMiddle
                transparentBackground: true

                visible: !controlitem.isComicBook

                currentIndex: PQCConstants.currentFileInsideNum

                onCurrentIndexChanged: {
                    if(currentIndex !== PQCConstants.currentFileInsideNum) {
                        PQCNotify.currentArchiveJumpTo(currentIndex)
                    }
                }

                model: PQCConstants.currentFileInsideList

                popup.onOpened: {
                    PQCConstants.currentArchiveComboOpen = true
                }
                popup.onClosed: {
                    PQCConstants.currentArchiveComboOpen = false
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

                Item {

                    y: (parent.height-height)/2

                    width: height
                    height: controlitem.height/2.5 + 10

                    opacity: mousefirst.containsMouse ? 1 : 0.2
                    Behavior on opacity { NumberAnimation { duration: 200 } }

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
                                PQCNotify.currentArchiveJump(-PQCConstants.currentFileInsideNum)
                            else
                                menu.popup()
                        }
                    }
                }

                Item {

                    y: (parent.height-height)/2

                    width: height-6
                    height: controlitem.height/1.5 + 6

                    opacity: mouseprev.containsMouse ? 1 : 0.2
                    Behavior on opacity { NumberAnimation { duration: 200 } }

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
                                PQCNotify.currentArchiveJump(-1)
                            else
                                menu.popup()
                        }
                    }
                }

                Item {

                    y: (parent.height-height)/2

                    width: height-6
                    height: controlitem.height/1.5 + 6

                    opacity: mousenext.containsMouse ? 1 : 0.2
                    Behavior on opacity { NumberAnimation { duration: 200 } }

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
                                PQCNotify.currentArchiveJump(1)
                            else
                                menu.popup()
                        }
                    }
                }

                Item {

                    y: (parent.height-height)/2

                    width: height
                    height: controlitem.height/2.5 + 10

                    opacity: mouselast.containsMouse ? 1 : 0.2
                    Behavior on opacity { NumberAnimation { duration: 200 } }

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
                                PQCNotify.currentArchiveJump(PQCConstants.currentFileInsideTotal-PQCConstants.currentFileInsideNum-1)
                            else
                                menu.popup()
                        }
                    }
                }

            }

            Item {
                visible: controlitem.isComicBook
                width: 5
                height: 1
            }

            PQText {
                visible: controlitem.isComicBook
                y: (parent.height-height)/2
                text: "|"
            }

            Item {
                visible: controlitem.isComicBook
                width: 5
                height: 1
            }

            PQText {
                visible: controlitem.isComicBook
                y: (parent.height-height)/2
                text: qsTranslate("image", "Page %1/%2").arg(PQCConstants.currentFileInsideNum+1).arg(PQCConstants.currentFileInsideTotal)
            }

            Item {
                visible: controlitem.isComicBook
                width: 5
                height: 1
            }

            PQText {
                visible: controlitem.isComicBook
                y: (parent.height-height)/2
                text: "|"
            }

            Item {
                visible: controlitem.isComicBook
                width: 5
                height: 1
            }

            Item {
                y: (parent.height-height)/2

                width: controlitem.height/2.5 + 10
                height: width

                opacity: viewermodemouse.containsMouse ? 1 : 0.5
                Behavior on opacity { NumberAnimation { duration: 200 } }

                visible: controlitem.isComicBook

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
                                PQCFileFolderModel.enableViewerMode(PQCConstants.currentFileInsideName)
                            else
                                menu.popup()
                        }
                    }
                }
            }

            Item {

                id: leftrightlock

                y: (parent.height-height)/2

                width: lockrow.width+6
                height: lockrow.height+6

                opacity: PQCSettings.filetypesArchiveLeftRight ? 1 : 0.3
                Behavior on opacity { NumberAnimation { duration: 200 } }

                visible: controlitem.isComicBook

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
                            PQCSettings.filetypesArchiveLeftRight = !PQCSettings.filetypesArchiveLeftRight
                        else
                            menu.popup()
                    }
                }

            }

        }

        PQMenu {
            id: menu

            property bool resetPosAfterHide: false

            PQMenuItem {
                icon.source: "image://svg/:/" + PQCLook.iconShade + "/padlock.svg"
                text: qsTranslate("image", PQCSettings.filetypesArchiveLeftRight ? "Unlock arrow keys" : "Lock arrow keys")
                onTriggered: {
                    PQCSettings.filetypesArchiveLeftRight = !filetypesArchiveLeftRight
                }
            }

            PQMenuItem {
                icon.source: "image://svg/:/" + PQCLook.iconShade + "/viewermode_on.svg"
                text: qsTranslate("image", "Viewer mode")
                onTriggered: {
                    PQCFileFolderModel.enableViewerMode(PQCFileFolderModel.currentFile)
                }
            }

            PQMenuSeparator {}

            PQMenuItem {
                icon.source: "image://svg/:/" + PQCLook.iconShade + "/reset.svg"
                text: qsTranslate("image", "Reset position")
                onTriggered: {
                    menu.resetPosAfterHide = true
                }
            }

            PQMenuItem {
                icon.source: "image://svg/:/" + PQCLook.iconShade + "/close.svg"
                text: qsTranslate("image", "Hide controls")
                onTriggered:
                    PQCSettings.filetypesArchiveControls = false
            }

            onVisibleChanged: {
                if(!visible && resetPosAfterHide) {
                    resetPosAfterHide = false
                    controlitem.manuallyDragged = false
                    controlitem.x = Qt.binding(function() { return (controlitem.parent.width-controlitem.width)/2 })
                    controlitem.y = Qt.binding(function() { return (0.9*ldr_top.parent.parent.height) })
                }
            }

        }

    }

}
