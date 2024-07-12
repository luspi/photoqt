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
import PQCScriptsFilesPaths
import PQCImageFormats
import PQCScriptsFileManagement

import "../elements"

PQTemplateFullscreen {

    id: crop_top

    thisis: "crop"
    popout: PQCSettings.interfacePopoutCrop
    forcePopout: PQCWindowGeometry.cropForcePopout
    shortcut: "__crop"

    title: qsTranslate("crop", "Crop image")

    button1.text: qsTranslate("crop", "Crop")
    button1.enabled: !unsupportedlabel.visible

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

                onStatusChanged: (status) => {
                    if(status === Image.Ready) {
                        updateStartEndPosBackupAndStart.restart()
                    }
                }
                // we add a slight delay to make sure the bindings are all properly updated before starting
                Timer {
                    id: updateStartEndPosBackupAndStart
                    interval: 500
                    onTriggered: {
                        animateCropping.startPosBackup = resizerect.startPos
                        animateCropping.endPosBackup = resizerect.endPos
                        animateCropping.restart()
                    }
                }

                /******************************************/
                // shaded region that will be cropped out

                // left region
                Rectangle {
                    color: "#aa000000"
                    x: resizerect.effectiveX
                    y: resizerect.effectiveY
                    width: resizerect.startPos.x
                    height: resizerect.effectiveHeight
                }

                // right region
                Rectangle {
                    color: "#aa000000"
                    x: resizerect.effectiveX+resizerect.endPos.x
                    y: resizerect.effectiveY
                    width: resizerect.effectiveWidth-resizerect.endPos.x
                    height: resizerect.effectiveHeight
                }

                // // top region
                Rectangle {
                    color: "#aa000000"
                    x: resizerect.effectiveX+resizerect.startPos.x
                    y: resizerect.effectiveY
                    width: resizerect.endPos.x-resizerect.startPos.x
                    height: resizerect.startPos.y
                }

                // // bottom region
                Rectangle {
                    color: "#aa000000"
                    x: resizerect.effectiveX+resizerect.startPos.x
                    y: resizerect.effectiveY+resizerect.endPos.y
                    width: resizerect.endPos.x-resizerect.startPos.x
                    height: resizerect.effectiveHeight-resizerect.endPos.y
                }

                /******************************************/

                PQResizeRect {

                    id: resizerect

                    visible: !unsupportedlabel.visible

                    effectiveX: (theimage.width-theimage.paintedWidth)/2
                    effectiveY: (theimage.height-theimage.paintedHeight)/2
                    effectiveWidth: theimage.paintedWidth
                    effectiveHeight: theimage.paintedHeight

                    startPos: Qt.point(200,200)
                    endPos: Qt.point(400,400)

                    masterObject: theimage

                }

            }

            Rectangle {

                id: errorlabel

                x: (parent.width-width)/2
                y: (parent.height-height)/2

                width: errorlabel_txt.width+30
                height: errorlabel_txt.height+30

                opacity: 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
                visible: opacity>0

                color: "#88ff0000"
                radius: 10

                border.width: 1
                border.color: "white"

                PQTextL {

                    id: errorlabel_txt

                    x: 15
                    y: 15

                    width: 300

                    horizontalAlignment: Qt.AlignHCenter
                    font.weight: PQCLook.fontWeightBold
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: qsTranslate("scale", "An error occured, file could not be scaled")
                }

                Timer {
                    interval: 2500
                    running: parent.visible
                    onTriggered:
                        parent.hide()
                }

                function show() {
                    opacity = 1
                }
                function hide() {
                    opacity = 0
                }

            }

            Rectangle {

                id: unsupportedlabel

                x: (parent.width-width)/2
                y: (parent.height-height)/2

                width: unsupportedlabel_txt.width+30
                height: unsupportedlabel_txt.height+30

                visible: false

                color: "#88ff0000"
                radius: 10

                border.width: 1
                border.color: "white"

                PQTextL {

                    id: unsupportedlabel_txt

                    x: 15
                    y: 15

                    width: 300

                    horizontalAlignment: Qt.AlignHCenter
                    font.weight: PQCLook.fontWeightBold
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: qsTranslate("scale", "Cropping this file format is not yet supported")
                }

            }

        }

    ]

    PQWorking {
        id: cropbusy
    }

    ParallelAnimation {
        id: animateCropping

        property point startPosBackup
        property point endPosBackup

        SequentialAnimation {
            NumberAnimation {
                target: resizerect
                property: "startPos.x"
                duration: 400
                from: animateCropping.startPosBackup.x
                to: animateCropping.startPosBackup.x+50
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: resizerect
                property: "startPos.x"
                duration: 400
                from: animateCropping.startPosBackup.x+50
                to: animateCropping.startPosBackup.x
                easing.type: Easing.OutBounce
            }
        }

        SequentialAnimation {
            NumberAnimation {
                target: resizerect
                property: "startPos.y"
                duration: 400
                from: animateCropping.startPosBackup.y
                to: animateCropping.startPosBackup.y+50
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: resizerect
                property: "startPos.y"
                duration: 400
                from: animateCropping.startPosBackup.y+50
                to: animateCropping.startPosBackup.y
                easing.type: Easing.OutBounce
            }
        }

        SequentialAnimation {
            NumberAnimation {
                target: resizerect
                property: "endPos.x"
                duration: 400
                from: animateCropping.endPosBackup.x
                to: animateCropping.endPosBackup.x-50
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: resizerect
                property: "endPos.x"
                duration: 400
                from: animateCropping.endPosBackup.x-50
                to: animateCropping.endPosBackup.x
                easing.type: Easing.OutBounce
            }
        }

        SequentialAnimation {
            NumberAnimation {
                target: resizerect
                property: "endPos.y"
                duration: 400
                from: animateCropping.endPosBackup.y
                to: animateCropping.endPosBackup.y-50
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: resizerect
                property: "endPos.y"
                duration: 400
                from: animateCropping.endPosBackup.y-50
                to: animateCropping.endPosBackup.y
                easing.type: Easing.OutBounce
            }
        }
    }

    Connections {
        target: PQCScriptsFileManagement
        function onCropCompleted(success) {
            if(success) {
                errorlabel.hide()
                cropbusy.showSuccess()
            } else {
                cropbusy.hide()
                errorlabel.show()
            }
        }
    }

    Connections {
        target: cropbusy
        function onSuccessHidden() {
            crop_top.hide()
       }
    }

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

        if(unsupportedlabel.visible)
            return

        errorlabel.hide()
        cropbusy.showBusy()

        var extent = resizerect.getTopLeftBottomRight()
        var topleft = extent[0]
        var botright = extent[1]

        var uniqueId = PQCImageFormats.detectFormatId(PQCFileFolderModel.currentFile)
        var file = PQCScriptsFilesPaths.selectFileFromDialog(qsTranslate("crop", "Crop"), PQCFileFolderModel.currentFile, uniqueId, true);
        if(file !== "") {
            PQCScriptsFileManagement.cropImage(PQCFileFolderModel.currentFile, file, uniqueId, topleft, botright)
        }

    }

    function show() {

        if(PQCFileFolderModel.currentIndex === -1 || PQCFileFolderModel.countMainView === 0) {
            hide()
            return
        }

        cropbusy.hide()
        errorlabel.hide()
        unsupportedlabel.visible = !PQCScriptsFileManagement.canThisBeCropped(PQCFileFolderModel.currentFile)

        // we use bindings here to make sure they are the proper values once the image has been fully loaded
        resizerect.startPos = Qt.binding(function() {
            return Qt.point(theimage.paintedWidth*image.currentFlickableVisibleAreaX,
                            theimage.paintedHeight*image.currentFlickableVisibleAreaY)
        })
        resizerect.endPos = Qt.binding(function() {
            return Qt.point(resizerect.startPos.x + theimage.paintedWidth*image.currentFlickableVisibleAreaWidthRatio,
                            resizerect.startPos.y + theimage.paintedHeight*image.currentFlickableVisibleAreaHeightRatio)
        })

        if(theimage.status === Image.Ready && !updateStartEndPosBackupAndStart.running)
            updateStartEndPosBackupAndStart.restart()

        opacity = 1
        if(popoutWindowUsed)
            crop_popout.visible = true

        resizerect.setup()
    }

    function hide() {
        opacity = 0
        if(popoutWindowUsed)
            crop_popout.visible = false
        loader.elementClosed(thisis)
    }

}
