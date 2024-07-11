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

                /******************************************/
                // shaded region that will be cropped out

                // left region
                Rectangle {
                    color: "#88000000"
                    x: resizerect.effectiveX
                    y: resizerect.effectiveY
                    width: resizerect.startPos.x
                    height: resizerect.effectiveHeight
                }

                // right region
                Rectangle {
                    color: "#88000000"
                    x: resizerect.effectiveX+resizerect.endPos.x
                    y: resizerect.effectiveY
                    width: resizerect.effectiveWidth-resizerect.endPos.x
                    height: resizerect.effectiveHeight
                }

                // // top region
                Rectangle {
                    color: "#88000000"
                    x: resizerect.effectiveX+resizerect.startPos.x
                    y: resizerect.effectiveY
                    width: resizerect.endPos.x-resizerect.startPos.x
                    height: resizerect.startPos.y
                }

                // // bottom region
                Rectangle {
                    color: "#88000000"
                    x: resizerect.effectiveX+resizerect.startPos.x
                    y: resizerect.effectiveY+resizerect.endPos.y
                    width: resizerect.endPos.x-resizerect.startPos.x
                    height: resizerect.effectiveHeight-resizerect.endPos.y
                }

                /******************************************/

                PQResizeRect {

                    id: resizerect

                    effectiveX: (theimage.width-theimage.paintedWidth)/2
                    effectiveY: (theimage.height-theimage.paintedHeight)/2
                    effectiveWidth: theimage.paintedWidth
                    effectiveHeight: theimage.paintedHeight

                    startPos: Qt.point(200,200)
                    endPos: Qt.point(400,400)

                    masterObject: theimage

                }

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
