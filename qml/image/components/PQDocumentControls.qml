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

import "../../elements"

import PQCNotify
import PQCScriptsImages
import PQCFileFolderModel

Item {

    id: top

    property bool pressed: false

    Loader {

        active: PQCSettings.filetypesDocumentControls&&!PQCFileFolderModel.isPDF && !PQCNotify.slideshowRunning

        Rectangle {

            id: controlitem

            parent: deleg

            x: (parent.width-width)/2
            y: 0.9*parent.height
            z: image_top.curZ
            width: controlrow.width+20
            height: 50
            radius: 5
            color: PQCLook.transColor

            Connections {
                target: image_top
                function onWidthChanged() {
                    controlitem.x = Math.min(controlitem.x, image_top.width-controlitem.width-5)
                }
                function onHeightChanged() {
                    controlitem.y = Math.min(controlitem.y, image_top.height-controlitem.height-5)
                }
            }

            onXChanged: {
                if(x !== (parent.width-width)/2) {
                    image_top.extraControlsLocation.x = x
                    x = x
                }
            }
            onYChanged: {
                if(y !== 0.9*parent.height) {
                    image_top.extraControlsLocation.y = y
                    y = y
                }
            }

            Component.onCompleted: {
                if(image_top.extraControlsLocation.x !== -1) {
                    controlitem.x = image_top.extraControlsLocation.x
                    controlitem.y = image_top.extraControlsLocation.y
                }
            }

            // only show when needed
            opacity: (image.pageCount>1 && image.visible && PQCSettings.filetypesDocumentControls && !PQCFileFolderModel.isPDF) ? (hovered ? 1 : 0.3) : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            visible: opacity>0
            enabled: visible

            // the first property is set by PCNotify signals for everything else not caught with the elements below
            property bool emptyAreaHovered: false
            property bool hovered: controldrag.containsMouse||leftrightmouse.containsMouse||viewermodemouse.containsMouse||
                                   emptyAreaHovered||controlclosemouse.containsMouse||mouseprev.containsMouse||mousenext.containsMouse||
                                   mousefirst.containsMouse||mouselast.containsMouse

            // drag and catch wheel events
            MouseArea {
                id: controldrag
                anchors.fill: parent
                drag.target: parent
                drag.minimumX: 5
                drag.minimumY: 5
                drag.maximumX: image_top.width-controlitem.width-5
                drag.maximumY: image_top.height-controlitem.height-5
                hoverEnabled: true
                cursorShape: Qt.SizeAllCursor
                propagateComposedEvents: true
                onWheel: {}
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
                            source: "image://svg/:/white/first.svg"
                        }
                        PQMouseArea {
                            id: mousefirst
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            text: qsTranslate("image", "Go to first page")
                            onClicked: image_top.documentJump(-image.currentPage)
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
                            source: "image://svg/:/white/backwards.svg"
                        }
                        PQMouseArea {
                            id: mouseprev
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            text: qsTranslate("image", "Go to previous page")
                            onClicked: image_top.documentJump(-1)
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
                            source: "image://svg/:/white/forwards.svg"
                        }
                        PQMouseArea {
                            id: mousenext
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            text: qsTranslate("image", "Go to next page")
                            onClicked: image_top.documentJump(1)
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
                            source: "image://svg/:/white/last.svg"
                        }
                        PQMouseArea {
                            id: mouselast
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            text: qsTranslate("image", "Go to last page")
                            onClicked: image_top.documentJump(image.pageCount-image.currentPage-1)
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
                    text: qsTranslate("image", "Page %1/%2").arg(image.currentPage+1).arg(image.pageCount)
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
                        source: "image://svg/:/white/viewermode_on.svg"
                        PQMouseArea {
                            id: viewermodemouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            text: qsTranslate("image", "Click to enter viewer mode")
                            onClicked: PQCFileFolderModel.enableViewerMode(image.currentPage)
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
                            source: "image://svg/:/white/padlock.svg"
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
                        text: qsTranslate("image", "Lock left/right arrow keys to page navigation")
                        onClicked:
                            PQCSettings.filetypesDocumentLeftRight = !PQCSettings.filetypesDocumentLeftRight
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
                source: "image://svg/:/white/close.svg"
                sourceSize: Qt.size(width, height)
                PQMouseArea {
                    id: controlclosemouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    text: qsTranslate("image", "Hide controls")
                    onClicked: {
                        PQCSettings.filetypesDocumentControls = false
                    }
                }
            }

            Connections {

                target: PQCNotify

                enabled: controlitem.enabled

                function onMouseMove(x, y) {

                    // check if the control item is hovered anywhere not caught by the elements above
                    var local = controlitem.mapFromItem(fullscreenitem, Qt.point(x,y))
                    controlitem.emptyAreaHovered = (local.x > 0 && local.y > 0 && local.x < controlitem.width && local.y < controlitem.height)

                }

            }

        }

    }

}
