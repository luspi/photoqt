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
import QtQuick.Controls

import PQCWindowGeometry
import PQCFileFolderModel

import "../elements"

PQTemplateFullscreen {

    id: crop_top

    thisis: "crop"
    popout: PQCSettings.interfacePopoutCrop
    forcePopout: PQCWindowGeometry.cropForcePopout
    shortcut: "__crop"

    title: qsTranslate("crop", "Crop image")

    button1.text: qsTranslate("crop", "Crop")

    button2.visible: true
    button2.text: genericStringCancel

    onPopoutChanged:
        PQCSettings.interfacePopoutCrop = popout

    button1.onClicked: {
        cropImage()
    }

    button2.onClicked: {
        hide()
    }

    content: [

        Item {

            id: thecontent

            width: crop_top.contentWidth
            height: crop_top.contentHeight

            Image {

                id: theimage

                width: parent.width
                height: parent.height

                sourceSize.width: width
                sourceSize.height: height

                fillMode: Image.Pad

                source: "image://full/" + PQCFileFolderModel.currentFile

                property int actX: (theimage.width-theimage.paintedWidth)/2
                property int actY: (theimage.height-theimage.paintedHeight)/2
                property int actW: theimage.paintedWidth
                property int actH: theimage.paintedHeight

                property point startPos: Qt.point(200,200)
                property point endPos: Qt.point(400,400)

                /******************************************/
                // shaded region that will be cropped out

                // left region
                Rectangle {
                    color: "#88000000"
                    x: parent.actX
                    y: parent.actY
                    width: parent.startPos.x
                    height: parent.actH
                }

                // right region
                Rectangle {
                    color: "#88000000"
                    x: parent.actX+parent.endPos.x
                    y: parent.actY
                    width: parent.actW-parent.endPos.x
                    height: parent.actH
                }

                // // top region
                Rectangle {
                    color: "#88000000"
                    x: parent.actX+parent.startPos.x
                    y: parent.actY
                    width: parent.endPos.x-parent.startPos.x
                    height: parent.startPos.y
                }

                // // bottom region
                Rectangle {
                    color: "#88000000"
                    x: parent.actX+parent.startPos.x
                    y: parent.actY+parent.endPos.y
                    width: parent.endPos.x-parent.startPos.x
                    height: parent.actH-parent.endPos.y
                }

                /******************************************/
                // region that is desired

                Rectangle {
                    x: parent.actX+parent.startPos.x
                    y: parent.actY+parent.startPos.y
                    width: parent.endPos.x-parent.startPos.x
                    height: parent.endPos.y-parent.startPos.y
                    color: "transparent"
                    border.width: 2
                    border.color: "#bb000000"
                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.SizeAllCursor
                        property bool pressedDown: false
                        property int startX
                        property int startY
                        onPressed: (mouse) => {
                            startX = mouse.x
                            startY = mouse.y
                            pressedDown = true
                        }
                        onReleased:
                            pressedDown = false
                        onMouseXChanged: (mouse) => {
                            if(pressedDown) {
                                var w = parent.parent.endPos.x - parent.parent.startPos.x
                                parent.parent.startPos.x = Math.max(0, Math.min(parent.parent.actW-w, parent.parent.startPos.x+(mouse.x-startX)))
                                parent.parent.endPos.x = parent.parent.startPos.x+w
                            }
                        }
                        onMouseYChanged: (mouse) => {
                            if(pressedDown) {
                                var h = parent.parent.endPos.y - parent.parent.startPos.y
                                parent.parent.startPos.y = Math.max(0, Math.min(parent.parent.actH-h, parent.parent.startPos.y+(mouse.y-startY)))
                                parent.parent.endPos.y = parent.parent.startPos.y+h
                            }
                        }
                    }
                }

                /******************************************/
                // markers for resizing highlighted region

                property int markerSize: (endPos.x-startPos.x < 100 || endPos.y-startPos.y < 100 ? 10 : 20)
                Behavior on markerSize { NumberAnimation { duration: 200 } }

                // top
                Rectangle {
                    x: parent.actX + parent.startPos.x +(parent.endPos.x-parent.startPos.x)/2 -parent.markerSize/2
                    y: parent.actY + parent.startPos.y-parent.markerSize/2
                    width: parent.markerSize
                    height: parent.markerSize
                    radius: parent.markerSize/2
                    color: "red"
                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.SizeVerCursor
                        property bool pressedDown: false
                        onPressed:
                            pressedDown = true
                        onReleased:
                            pressedDown = false
                        onMouseYChanged: (mouse) => {
                            if(pressedDown) {
                                theimage.startPos.y = Math.max(0, Math.min(theimage.endPos.y-25, mapToItem(theimage, mouse.x, mouse.y).y-parent.parent.actY))
                            }
                        }
                    }
                }

                // left
                Rectangle {
                    x: parent.actX + parent.startPos.x-parent.markerSize/2
                    y: parent.actY + parent.startPos.y + (parent.endPos.y-parent.startPos.y)/2 -parent.markerSize/2
                    width: parent.markerSize
                    height: parent.markerSize
                    radius: parent.markerSize/2
                    color: "red"
                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.SizeHorCursor
                        property bool pressedDown: false
                        onPressed:
                            pressedDown = true
                        onReleased:
                            pressedDown = false
                        onMouseXChanged: (mouse) => {
                            if(pressedDown) {
                                theimage.startPos.x = Math.max(0, Math.min(theimage.endPos.x-25, mapToItem(theimage, mouse.x, mouse.y).x-parent.parent.actX))
                            }
                        }
                    }
                }

                // right
                Rectangle {
                    x: parent.actX + parent.endPos.x-parent.markerSize/2
                    y: parent.actY + parent.startPos.y + (parent.endPos.y-parent.startPos.y)/2 -parent.markerSize/2
                    width: parent.markerSize
                    height: parent.markerSize
                    radius: parent.markerSize/2
                    color: "red"
                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.SizeHorCursor
                        property bool pressedDown: false
                        onPressed:
                            pressedDown = true
                        onReleased:
                            pressedDown = false
                        onMouseXChanged: (mouse) => {
                            if(pressedDown) {
                                theimage.endPos.x = Math.min(parent.parent.actW, Math.max(theimage.startPos.x+25, mapToItem(theimage, mouse.x, mouse.y).x-parent.parent.actX))
                            }
                        }
                    }
                }

                // bottom
                Rectangle {
                    x: parent.actX + parent.startPos.x +(parent.endPos.x-parent.startPos.x)/2 -parent.markerSize/2
                    y: parent.actY + parent.endPos.y-parent.markerSize/2
                    width: parent.markerSize
                    height: parent.markerSize
                    radius: parent.markerSize/2
                    color: "red"
                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.SizeVerCursor
                        property bool pressedDown: false
                        onPressed:
                            pressedDown = true
                        onReleased:
                            pressedDown = false
                        onMouseYChanged: (mouse) => {
                            if(pressedDown) {
                                theimage.endPos.y = Math.min(parent.parent.actH, Math.max(theimage.startPos.y+25, mapToItem(theimage, mouse.x, mouse.y).y-parent.parent.actY))
                            }
                        }
                    }
                }

                // top left
                Rectangle {
                    x: parent.actX + parent.startPos.x-parent.markerSize/2
                    y: parent.actY + parent.startPos.y-parent.markerSize/2
                    width: parent.markerSize
                    height: parent.markerSize
                    radius: parent.markerSize/2
                    color: "red"
                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.SizeFDiagCursor
                        property bool pressedDown: false
                        onPressed:
                            pressedDown = true
                        onReleased:
                            pressedDown = false
                        onMouseYChanged: (mouse) => {
                            if(pressedDown) {
                                theimage.startPos.y = Math.max(0, Math.min(theimage.endPos.y-25, mapToItem(theimage, mouse.x, mouse.y).y-parent.parent.actY))
                            }
                        }
                        onMouseXChanged: (mouse) => {
                            if(pressedDown) {
                                theimage.startPos.x = Math.max(0, Math.min(theimage.endPos.x-25, mapToItem(theimage, mouse.x, mouse.y).x-parent.parent.actX))
                            }
                        }
                    }
                }

                // top right
                Rectangle {
                    x: parent.actX + parent.endPos.x-parent.markerSize/2
                    y: parent.actY + parent.startPos.y-parent.markerSize/2
                    width: parent.markerSize
                    height: parent.markerSize
                    radius: parent.markerSize/2
                    color: "red"
                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.SizeBDiagCursor
                        property bool pressedDown: false
                        onPressed:
                            pressedDown = true
                        onReleased:
                            pressedDown = false
                        onMouseYChanged: (mouse) => {
                            if(pressedDown) {
                                theimage.startPos.y = Math.max(0, Math.min(theimage.endPos.y-25, mapToItem(theimage, mouse.x, mouse.y).y-parent.parent.actY))
                            }
                        }
                        onMouseXChanged: (mouse) => {
                            if(pressedDown) {
                                theimage.endPos.x = Math.min(parent.parent.actW, Math.max(theimage.startPos.x+25, mapToItem(theimage, mouse.x, mouse.y).x-parent.parent.actX))
                            }
                        }
                    }
                }

                // bottom left
                Rectangle {
                    x: parent.actX + parent.startPos.x-parent.markerSize/2
                    y: parent.actY + parent.endPos.y-parent.markerSize/2
                    width: parent.markerSize
                    height: parent.markerSize
                    radius: parent.markerSize/2
                    color: "red"
                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.SizeBDiagCursor
                        property bool pressedDown: false
                        onPressed:
                            pressedDown = true
                        onReleased:
                            pressedDown = false
                        onMouseYChanged: (mouse) => {
                            if(pressedDown) {
                                theimage.endPos.y = Math.min(parent.parent.actH, Math.max(theimage.startPos.y+25, mapToItem(theimage, mouse.x, mouse.y).y-parent.parent.actY))
                            }
                        }
                        onMouseXChanged: (mouse) => {
                            if(pressedDown) {
                                theimage.startPos.x = Math.max(0, Math.min(theimage.endPos.x-25, mapToItem(theimage, mouse.x, mouse.y).x-parent.parent.actX))
                            }
                        }
                    }
                }

                // bottom right
                Rectangle {
                    x: parent.actX + parent.endPos.x-parent.markerSize/2
                    y: parent.actY + parent.endPos.y-parent.markerSize/2
                    width: parent.markerSize
                    height: parent.markerSize
                    radius: parent.markerSize/2
                    color: "red"
                    PQMouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.SizeFDiagCursor
                        property bool pressedDown: false
                        onPressed:
                            pressedDown = true
                        onReleased:
                            pressedDown = false
                        onMouseYChanged: (mouse) => {
                            if(pressedDown) {
                                theimage.endPos.y = Math.min(parent.parent.actH, Math.max(theimage.startPos.y+25, mapToItem(theimage, mouse.x, mouse.y).y-parent.parent.actY))
                            }
                        }
                        onMouseXChanged: (mouse) => {
                            if(pressedDown) {
                                theimage.endPos.x = Math.min(parent.parent.actW, Math.max(theimage.startPos.x+25, mapToItem(theimage, mouse.x, mouse.y).x-parent.parent.actX))
                            }
                        }
                    }
                }

                /******************************************/

            }

        }

    ]

    Connections {

        target: loader

        function onPassOn(what, param) {

            if(what === "show") {

                if(param === thisis)
                    show()

            } else if(what === "hide") {

                if(param === thisis)
                    hide()

            } else if(crop_top.opacity > 0) {

                if(what === "keyEvent") {

                    if(param[0] === Qt.Key_Escape)
                        hide()

                    else if(param[0] === Qt.Key_Enter || param[0] === Qt.Key_Return) {

                        cropImage()

                    }
                }
            }
        }
    }

    function cropImage() {

    }

    function show() {

        if(PQCFileFolderModel.currentIndex === -1 || PQCFileFolderModel.countMainView === 0) {
            hide()
            return
        }
        opacity = 1
        if(popoutWindowUsed)
            crop_popout.visible = true
    }

    function hide() {
        opacity = 0
        if(popoutWindowUsed)
            crop_popout.visible = false
        loader.elementClosed(thisis)
    }

}
