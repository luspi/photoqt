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
import PQCScriptsFilesPaths
import PQCImageFormats

import org.photoqt.qml

import "../../../qml/modern/elements"

PQTemplateFullscreen {

    id: crop_top

    thisis: "cropimage"
    popout: PQCSettings.extensions.CropImagePopout
    forcePopout: PQCWindowGeometry.cropForcePopout
    shortcut: "__crop"

    title: qsTranslate("crop", "Crop image")

    button1.text: qsTranslate("crop", "Crop")

    button2.visible: true
    button2.text: genericStringCancel

    onPopoutChanged:
        PQCSettings.extensions.CropImagePopout = popout

    button1.onClicked: {
        cropImage()
    }

    button2.onClicked: {
        hide()
    }

    // this is needed to not show the animation again when the window is resized
    property bool animShowed: false

    Connections {
        target: PQCSettings
        function onExtensionSettingUpdated(key : string, val : var) : void {
            if(key === "CropImagePopout" && crop_top.popout !== val)
                crop_top.popout = val
        }
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

                fillMode: Image.PreserveAspectFit

                source: PQCFileFolderModel.currentFile==="" ? "" : ("image://full/" + PQCFileFolderModel.currentFile) // qmllint disable unqualified

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
                        if(!crop_top.animShowed) {
                            animateCropping.startPosBackup = resizerect.startPos
                            animateCropping.endPosBackup = resizerect.endPos
                            animateCropping.restart()
                        }
                    }
                }

                /******************************************/
                // shaded region that will be cropped out

                // left region
                Rectangle {
                    color: "#aa000000"
                    x: resizerect.effectiveX
                    y: resizerect.effectiveY
                    width: resizerect.startPos.x*theimage.paintedWidth
                    height: resizerect.effectiveHeight
                }

                // right region
                Rectangle {
                    color: "#aa000000"
                    x: resizerect.effectiveX+resizerect.endPos.x*theimage.paintedWidth
                    y: resizerect.effectiveY
                    width: resizerect.effectiveWidth-resizerect.endPos.x*theimage.paintedWidth
                    height: resizerect.effectiveHeight
                }

                // top region
                Rectangle {
                    color: "#aa000000"
                    x: resizerect.effectiveX+resizerect.startPos.x*theimage.paintedWidth
                    y: resizerect.effectiveY
                    width: (resizerect.endPos.x-resizerect.startPos.x)*theimage.paintedWidth
                    height: resizerect.startPos.y*theimage.paintedHeight
                }

                // bottom region
                Rectangle {
                    color: "#aa000000"
                    x: resizerect.effectiveX+resizerect.startPos.x*theimage.paintedWidth
                    y: resizerect.effectiveY+resizerect.endPos.y*theimage.paintedHeight
                    width: (resizerect.endPos.x-resizerect.startPos.x)*theimage.paintedWidth
                    height: resizerect.effectiveHeight-resizerect.endPos.y*theimage.paintedHeight
                }

                /******************************************/

                PQResizeRect {

                    id: resizerect

                    effectiveX: (theimage.width-theimage.paintedWidth)/2
                    effectiveY: (theimage.height-theimage.paintedHeight)/2
                    effectiveWidth: theimage.paintedWidth
                    effectiveHeight: theimage.paintedHeight

                    startPos: Qt.point(0.2,0.2)
                    endPos: Qt.point(0.4,0.4)

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
                    font.weight: PQCLook.fontWeightBold // qmllint disable unqualified
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: qsTranslate("scale", "An error occured, file could not be scaled")
                }

                Timer {
                    interval: 2500
                    running: errorlabel.visible
                    onTriggered:
                        errorlabel.hide()
                }

                function show() {
                    opacity = 1
                }
                function hide() {
                    opacity = 0
                }

            }

        }

    ]

    PQWorking {
        id: cropbusy
    }

    ParallelAnimation {
        id: animateCropping

        property point startPosBackup: Qt.point(-1,-1)
        property point endPosBackup: Qt.point(-1,-1)

        property real maxW: (endPosBackup.x-startPosBackup.x)/2
        property real maxH: (endPosBackup.y-startPosBackup.y)/2
        property real animExtentW: Math.min(0.02, maxW)
        property real animExtentH: Math.min(0.02, maxH)

        onStarted:
            crop_top.animShowed = true

        SequentialAnimation {
            NumberAnimation {
                target: resizerect
                property: "startPos.x"
                duration: 400
                from: animateCropping.startPosBackup.x
                to: animateCropping.startPosBackup.x + animateCropping.animExtentW
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: resizerect
                property: "startPos.x"
                duration: 400
                from: animateCropping.startPosBackup.x + animateCropping.animExtentW
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
                to: animateCropping.startPosBackup.y + animateCropping.animExtentH
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: resizerect
                property: "startPos.y"
                duration: 400
                from: animateCropping.startPosBackup.y + animateCropping.animExtentH
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
                to: animateCropping.endPosBackup.x - animateCropping.animExtentW
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: resizerect
                property: "endPos.x"
                duration: 400
                from: animateCropping.endPosBackup.x - animateCropping.animExtentW
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
                to: animateCropping.endPosBackup.y - animateCropping.animExtentH
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: resizerect
                property: "endPos.y"
                duration: 400
                from: animateCropping.endPosBackup.y - animateCropping.animExtentH
                to: animateCropping.endPosBackup.y
                easing.type: Easing.OutBounce
            }
        }
    }

    Connections {
        target: PQCScriptsFileManagement // qmllint disable unqualified
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

        target: PQCNotify // qmllint disable unqualified

        function onLoaderPassOn(what : string, param : list<var>) {

            console.log("args: what =", what)
            console.log("args: param =", param)

            if(what === "show" && param[0] === "cropimage") {

                crop_top.show()

            } else if(what === "hide" && param[0] === "cropimage") {

                crop_top.hide()

            } else if(crop_top.opacity > 0) {

                if(what === "keyEvent") {

                    if(crop_top.contextMenuOpen) {
                        crop_top.closeContextMenus()
                        return
                    }

                    if(param[0] === Qt.Key_Escape) {

                        crop_top.hide()

                    } else if(param[0] === Qt.Key_Enter || param[0] === Qt.Key_Return) {

                        crop_top.cropImage()

                    }
                }
            }
        }
    }

    function cropImage() {

        errorlabel.hide()
        cropbusy.showBusy()

        var topleft = resizerect.startPos
        var botright = resizerect.endPos

        var uniqueId = PQCImageFormats.detectFormatId(PQCFileFolderModel.currentFile) // qmllint disable unqualified
        var file = PQCScriptsFilesPaths.selectFileFromDialog(qsTranslate("crop", "Crop"), PQCFileFolderModel.currentFile, uniqueId, true);
        if(file !== "")
            PQCScriptsFileManagement.cropImage(PQCFileFolderModel.currentFile, file, uniqueId, topleft, botright)
        else
            cropbusy.hide()

    }

    function show() {

        if(PQCFileFolderModel.currentIndex === -1 || PQCFileFolderModel.countMainView === 0) { // qmllint disable unqualified
            hide()
            return
        }

        var canBeCropped = !PQCNotify.showingPhotoSphere && PQCScriptsFileManagement.canThisBeCropped(PQCFileFolderModel.currentFile)

        if(!canBeCropped) {
            PQCNotify.showNotificationMessage(qsTranslate("filemanagement", "Action not available"), qsTranslate("filemanagement", "This image can not be cropped."))
            hide()
            return
        }

        cropbusy.hide()
        errorlabel.hide()

        resizerect.startPos = Qt.point(PQCConstants.currentVisibleAreaX,
                                       PQCConstants.currentVisibleAreaY)
        resizerect.endPos = Qt.point(resizerect.startPos.x + PQCConstants.currentVisibleAreaWidthRatio,
                                     resizerect.startPos.y + PQCConstants.currentVisibleAreaHeightRatio)

        animShowed = false

        if(theimage.status === Image.Ready && !updateStartEndPosBackupAndStart.running)
            updateStartEndPosBackupAndStart.restart()

        opacity = 1
        if(popoutWindowUsed)
            crop_popout.visible = true

    }

    function hide() {

        if(crop_top.contextMenuOpen)
            crop_top.closeContextMenus()

        opacity = 0
        if(popoutWindowUsed && crop_popout.visible)
            crop_popout.visible = false // qmllint disable unqualified
        else
            PQCNotify.loaderRegisterClose(thisis)
    }

}
