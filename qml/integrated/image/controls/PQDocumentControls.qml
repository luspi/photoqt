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

    active: PQCConstants.currentImageIsDocument

    sourceComponent:
    Item {

        id: controlitem

        parent: ldr_top.parent

        x: (parent.width-width)/2
        y: parent.height-height-20
        z: PQCConstants.currentZValue+1

        width: cont_row.width+20
        height: 50

        property bool hovered: bgmouse.containsMouse || leftrightmouse.containsMouse || viewermodemouse.containsMouse ||
                               mouselast.containsMouse || mousenext.containsMouse || mouseprev.containsMouse || mousefirst.containsMouse
        opacity: hovered ? 1 : 0.4
        Behavior on opacity { NumberAnimation { duration: 200 } }

        Rectangle {
            anchors.fill: parent
            color: pqtPalette.base
            opacity: 0.9
            radius: 5
        }

        MouseArea {
            id: bgmouse
            anchors.fill: parent
            hoverEnabled: true
            drag.target: controlitem
        }

        Row {

            id: cont_row

            x: 10
            y: (parent.height-height)/2
            spacing: 5

            Row {
                y: (parent.height-height)/2

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
                                PQCNotify.currentDocumentJump(-PQCConstants.currentFileInsideNum)
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
                                PQCNotify.currentDocumentJump(-1)
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
                                PQCNotify.currentDocumentJump(1)
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
                                PQCNotify.currentDocumentJump(PQCConstants.currentFileInsideTotal-PQCConstants.currentFileInsideNum-1)
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

            PQText {
                y: (parent.height-height)/2
                text: "|"
            }

            Item {
                width: 5
                height: 1
            }

            PQText {
                y: (parent.height-height)/2
                text: qsTranslate("image", "Page %1/%2").arg(PQCConstants.currentFileInsideNum+1).arg(PQCConstants.currentFileInsideTotal)
            }

            Item {
                width: 5
                height: 1
            }

            PQText {
                y: (parent.height-height)/2
                text: "|"
            }

            Item {
                width: 5
                height: 1
            }

            Item {
                y: (parent.height-height)/2

                width: controlitem.height/2.5 + 10
                height: width

                opacity: viewermodemouse.containsMouse ? 1 : 0.5
                Behavior on opacity { NumberAnimation { duration: 200 } }

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

            Item {

                id: leftrightlock

                y: (parent.height-height)/2

                width: lockrow.width+6
                height: lockrow.height+6

                opacity: PQCSettings.filetypesDocumentLeftRight ? 1 : 0.3
                Behavior on opacity { NumberAnimation { duration: 200 } }

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

    }

}
