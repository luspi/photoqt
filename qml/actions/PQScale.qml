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

import PQCNotify
import PQCFileFolderModel
import PQCScriptsFileManagement
import PQCScriptsFilesPaths
import PQCImageFormats
import PQCWindowGeometry

import "../elements"

PQTemplateFullscreen {

    id: scale_top

    thisis: "scale"
    popout: PQCSettings.interfacePopoutScale
    forcePopout: PQCWindowGeometry.scaleForcePopout
    shortcut: "__scale"

    title: qsTranslate("scale", "Scale image")

    button1.text: qsTranslate("scale", "Scale")
    button1.enabled: (spin_w.value>0 && spin_h.value>0)

    button2.visible: true
    button2.text: genericStringCancel

    onPopoutChanged:
        PQCSettings.interfacePopoutScale = popout

    button1.onClicked:
        scaleImage()

    button2.onClicked:
        hide()

    property bool keepAspectRatio: true
    property real aspectRatio: 1.0

    content: [

        PQTextL {
            id: errorlabel
            width: parent.width
            horizontalAlignment: Qt.AlignHCenter
            font.weight: PQCLook.fontWeightBold
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            visible: false
            text: qsTranslate("scale", "An error occured, file could not be scaled")
        },

        Item {
            width: 1
            height: 10
        },

        Row {

            x: (parent.width-width)/2

            spacing: 10

            Column {
                spacing: 5
                PQText {
                    height: spin_w.height
                    //: The number of horizontal pixels of the image
                    text: qsTranslate("scale", "Width:")
                    verticalAlignment: Qt.AlignVCenter
                }
                PQText {
                    height: spin_h.height
                    //: The number of vertical pixels of the image
                    text: qsTranslate("scale", "Height:")
                    verticalAlignment: Qt.AlignVCenter
                }
            }

            Column {
                id: spincol
                spacing: 5

                PQSliderSpinBox {
                    id: spin_w
                    enabled: scale_top.visible
                    minval: 1
                    maxval: 99999
                    showSlider: false
                    onEditModeChanged: {
                        if(!editMode && spin_h.editMode) {
                            PQCNotify.spinBoxPassKeyEvents = true
                        }
                    }
                    property bool reactToValueChanged: true
                    onValueChanged: {
                        if(scale_top.opacity < 1) return
                        if(keepAspectRatio && reactToValueChanged) {
                            var h = value/aspectRatio
                            if(h !== spin_h.value) {
                                spin_h.reactToValueChanged = false
                                spin_h.value = Math.round(h)
                            }
                        } else
                            reactToValueChanged = true
                    }
                }
                PQSliderSpinBox {
                    id: spin_h
                    enabled: scale_top.visible
                    minval: 1
                    maxval: 99999
                    showSlider: false
                    onEditModeChanged: {
                        if(!editMode && spin_w.editMode) {
                            PQCNotify.spinBoxPassKeyEvents = true
                        }
                    }
                    property bool reactToValueChanged: true
                    onValueChanged: {
                        if(scale_top.opacity < 1) return
                        if(keepAspectRatio && reactToValueChanged) {
                            var w = value*aspectRatio
                            if(w !== spin_w.value) {
                                spin_w.reactToValueChanged = false
                                spin_w.value = Math.round(w)
                            }
                        } else
                            reactToValueChanged = true
                    }
                }

            }

            Image {
                source: keepAspectRatio ? "image://svg/:/white/aspectratiokeep.svg" : "image://svg/:/white/aspectratioignore.svg"
                y: (spincol.height-height)/2
                width: height/3
                height: spincol.height*0.8
                sourceSize: Qt.size(width, height)
                smooth: false
                mipmap: false
                opacity: keepAspectRatio ? 1 : 0.5
                Behavior on opacity { NumberAnimation { duration: 200 } }
                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        keepAspectRatio = !keepAspectRatio
                    }
                }
            }

        },

        PQTextS {

            x: (parent.width-width)/2
            font.weight: PQCLook.fontWeightBold
            text: qsTranslate("scale", "New size:") + " " +
                  spin_w.value + " x " + spin_h.value + " " +
                  //: This is used as in: 100x100 pixels
                  qsTranslate("scale", "pixels")
        },

        Item {
            width: 1
            height: 10
        },

        Row {

            x: (parent.width-width)/2

            spacing: 5

            PQButton {
                text: "0.25x"
                font.pointSize: PQCLook.fontSize
                font.weight: PQCLook.fontWeightNormal
                width: height*1.5
                onClicked: {
                    spin_w.value = image.currentResolution.width*0.25
                    spin_h.value = image.currentResolution.height*0.25
                }
            }

            PQButton {
                text: "0.5x"
                font.pointSize: PQCLook.fontSize
                font.weight: PQCLook.fontWeightNormal
                width: height*1.5
                onClicked: {
                    spin_w.value = image.currentResolution.width*0.5
                    spin_h.value = image.currentResolution.height*0.5
                }
            }

            PQButton {
                text: "0.75x"
                font.pointSize: PQCLook.fontSize
                font.weight: PQCLook.fontWeightNormal
                width: height*1.5
                onClicked: {
                    spin_w.value = image.currentResolution.width*0.75
                    spin_h.value = image.currentResolution.height*0.75
                }
            }

            PQButton {
                text: "1x"
                font.pointSize: PQCLook.fontSize
                font.weight: PQCLook.fontWeightNormal
                width: height*1.5
                onClicked: {
                    spin_w.value = image.currentResolution.width
                    spin_h.value = image.currentResolution.height
                }
            }

            PQButton {
                text: "1.5x"
                font.pointSize: PQCLook.fontSize
                font.weight: PQCLook.fontWeightNormal
                width: height*1.5
                onClicked: {
                    spin_w.value = image.currentResolution.width*1.5
                    spin_h.value = image.currentResolution.height*1.5
                }
            }

        },

        Item {
            width: 1
            height: 10
        },

        Row {

            x: (parent.width-width)/2

            spacing: 10

            PQText {
                text: qsTranslate("scale", "Quality:")
            }

            PQSlider {
                id: quality
                from: 1
                to: 100
                value: 80
            }

            PQText {
                text: quality.value + "%"
            }

        }

    ]

    PQWorking {
        id: scalebusy
    }

    Connections {
        target: PQCScriptsFileManagement
        function onScaleCompleted(success) {
            if(success) {
                errorlabel.visible = false
                scalebusy.showSuccess()
            } else {
                scalebusy.hide()
                errorlabel.visible = true
            }
        }
    }

    Connections {
        target: scalebusy
        function onSuccessHidden() {
            scale_top.hide()
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

            } else if(scale_top.opacity > 0) {

                if(what === "keyEvent") {

                    if(param[0] === Qt.Key_Escape)
                        hide()

                    else if(param[0] === Qt.Key_Plus) {

                        if(spin_w.activeFocus)
                            spin_w.increase()
                        else if(spin_h.activeFocus)
                            spin_h.increase()

                    } else if(param[0] === Qt.Key_Minus) {

                        if(spin_w.activeFocus)
                            spin_w.decrease()
                        else if(spin_h.activeFocus)
                            spin_h.decrease()

                    } else if(param[0] === Qt.Key_Enter || param[0] === Qt.Key_Return) {

                        if(button1.enabled)
                            scaleImage()

                    }

                }

            }

        }

    }

    function scaleImage() {

        if(spin_w.value === 0 || spin_h.value === 0)
            return

        errorlabel.visible = false
        scalebusy.showBusy()

        var uniqueid = PQCImageFormats.detectFormatId(PQCFileFolderModel.currentFile)
        var targetFilename = PQCScriptsFilesPaths.selectFileFromDialog(qsTranslate("scale", "Scale"), PQCFileFolderModel.currentFile, uniqueid, true);

        if(targetFilename === "") {
            scalebusy.hide()
            return
        }

        var success = PQCScriptsFileManagement.scaleImage(PQCFileFolderModel.currentFile, targetFilename, uniqueid, Qt.size(spin_w.value, spin_h.value), quality.value)
        if(!success) {
            errorlabel.visible = true
            return
        }

        if(PQCScriptsFilesPaths.getDir(targetFilename) === PQCScriptsFilesPaths.getDir(PQCFileFolderModel.currentFile))
            PQCFileFolderModel.fileInFolderMainView = targetFilename

        hide()

    }

    function show() {
        if(PQCFileFolderModel.currentIndex === -1 || PQCFileFolderModel.countMainView === 0) {
            hide()
            return
        }

        var canBeScaled = !PQCNotify.showingPhotoSphere && PQCScriptsFileManagement.canThisBeScaled(PQCFileFolderModel.currentFile)

        if(!canBeScaled) {
            loader.show("notification", [qsTranslate("filemanagement", "Action not available"), qsTranslate("filemanagement", "This image can not be scaled.")])
            hide()
            return
        }

        spin_w.loadAndSetDefault(image.currentResolution.width)
        spin_h.loadAndSetDefault(image.currentResolution.height)
        aspectRatio = image.currentResolution.width/image.currentResolution.height

        scalebusy.hide()
        errorlabel.visible = false

        // the opacity should be set at the end of this function
        opacity = 1
        if(popoutWindowUsed)
            scale_popout.visible = true
    }

    function hide() {
        opacity = 0
        if(popoutWindowUsed)
            scale_popout.visible = false
        loader.elementClosed(thisis)

    }

}
