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
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import PhotoQt

Rectangle {

    id: exist_top

    width: parent.width
    height: parent.height

    property list<string> files: []
    property list<int> checkedFiles: []

    SystemPalette { id: pqtPalette }

    property string title: "Existing files"

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: 200 } }
    visible: opacity>0
    enabled: visible

    onOpacityChanged: {
        if(opacity > 0)
            PQCNotify.windowTitleOverride(title)
        else if(opacity === 0)
            PQCNotify.windowTitleOverride("")
    }

    color: pqtPalette.base

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        onWheel: (wheel) => {
            wheel.accepted = true
        }
        onClicked: (mouse) => {
            mouse.accepted = true
        }
    }


    Rectangle {

        id: toprow

        width: parent.width
        height: parent.height>500 ? 75 : Math.max(75-(500-parent.height), 50)
        color: pqtPalette.base

        PQTextXL {
            anchors.centerIn: parent
            text: exist_top.title
            font.weight: PQCLook.fontWeightBold
        }

        Rectangle {
            x: 0
            y: parent.height-1
            width: parent.width
            height: 1
            color: PQCLook.baseBorder
        }

    }

    Flickable {

        id: flickable

        y: toprow.height + ((parent.height-bottomrow.height-toprow.height-height)/2)

        width: parent.width
        height: Math.min(parent.height-bottomrow.height-toprow.height, contentHeight)

        clip: true

        contentHeight: insidecont.height+20

        ScrollBar.vertical: PQVerticalScrollBar { }

        Column {

            id: insidecont

            x: ((parent.width-width)/2)
            y: 10

            width: parent.width-10

            spacing: 10

            PQTextXL {
                x: (parent.width-width)/2
                text: qsTranslate("filedialog", "%1 files already exist in the target directory.").arg(exist_top.files.length)
            }

            PQText {
                x: (parent.width-width)/2
                text: qsTranslate("filedialog", "Check the files below that you want to paste anyways. Files left unchecked will not be pasted.")
            }

            Rectangle {

                x: (parent.width-width)/2

                width: 400
                height: 300

                color: pqtPalette.alternateBase
                border.color: PQCLook.baseBorder
                border.width: 1

                ListView {

                    id: view

                    anchors.fill: parent
                    anchors.margins: 1

                    model: exist_top.files.length

                    orientation: ListView.Vertical
                    clip: true

                    Timer {
                        id: resetCurrentIndex
                        interval: 200
                        property int oldIndex
                        onTriggered:
                        if(view.currentIndex === oldIndex)
                            view.currentIndex = -1
                    }

                    delegate:
                    Rectangle {

                        id: deleg

                        required property int modelData

                        property string filepath: exist_top.files[modelData]
                        property string filename: PQCScriptsFilesPaths.getFilename(filepath)

                        width: view.width
                        height: 40
                        color: check.checked ? PQCLook.baseBorder : (view.currentIndex===modelData ? pqtPalette.alternateBase : pqtPalette.button)
                        Behavior on color { ColorAnimation { duration: 200 } }
                        border.color: PQCLook.baseBorder
                        border.width: 1

                        opacity: check.checked ? 1 : 0.6
                        Behavior on opacity{ NumberAnimation { duration: 200 } }

                        Row {

                            x: 5
                            height: parent.height

                            PQCheckBox {
                                id: check
                                y: (parent.height-height)/2
                                checked: exist_top.checkedFiles.indexOf(deleg.modelData)!==-1
                                font.pointSize: PQCLook.fontSizeL
                            }

                            PQTextL {
                                y: (parent.height-height)/2
                                width: deleg.width-check.width-icon.width-20
                                elide: Text.ElideMiddle
                                text: PQCScriptsFilesPaths.getFilename(exist_top.files[deleg.modelData])
                            }

                            Item {
                                id: icon
                                width: parent.height
                                height: width

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    source: PQCScriptsFilesPaths.isFolder(deleg.filepath) ? "image://icon/folder"
                                    : "image://thumb/" + deleg.filepath
                                }
                            }

                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered:
                            view.currentIndex = deleg.modelData
                            onExited: {
                                resetCurrentIndex.oldIndex = deleg.modelData
                                resetCurrentIndex.restart()
                            }
                            onClicked: {
                                if(exist_top.checkedFiles && exist_top.checkedFiles.indexOf(deleg.modelData)===-1) {
                                    exist_top.checkedFiles.push(deleg.modelData)
                                    exist_top.checkedFilesChanged()
                                } else
                                    exist_top.checkedFiles = exist_top.checkedFiles.filter(item => item!==deleg.modelData)
                                    exist_top.checkedFilesChanged
                            }
                        }

                        Component.onCompleted: {
                            exist_top.checkedFiles.push(deleg.modelData)
                            exist_top.checkedFilesChanged()
                        }

                    }

                }

            }

            Row {

                x: (parent.width-width)/2
                spacing: 5

                PQButton {
                    text: qsTranslate("filedialog", "Select all")
                    onClicked: {
                        exist_top.checkedFiles = [...Array(view.model).keys()]
                    }
                }

                PQButton {
                    text: qsTranslate("filedialog", "Select none")
                    onClicked:
                    exist_top.checkedFiles = []
                }

            }

        }

    }

    Rectangle {

        id: bottomrow

        y: (parent.height-height)

        width: parent.width
        height: 50
        color: pqtPalette.base

        Rectangle {
            x: 0
            y: 0
            width: parent.width
            height: 1
            color: PQCLook.baseBorder
        }

        Row {

            x: (parent.width-width)/2

            height: parent.height

            spacing: 0

            PQButtonElement {
                id: firstbutton
                text: "Continue"
                font.weight: PQCLook.fontWeightBold
                y: 1
                height: parent.height-1
                onClicked:
                    exist_top.continuePaste()
            }

            PQButtonElement {
                id: secondbutton
                text: "Cancel"
                visible: false
                y: 1
                height: parent.height-1
                onClicked:
                    exist_top.hide()
            }

        }

    }

    function pasteExistingFiles(filelist : list<string>) {
        files = []
        files = filelist
        show()
    }

    function continuePaste() {

        for(var i in exist_top.checkedFiles) {
            var ind = exist_top.checkedFiles[i]
            var fln = files[ind]
            PQCScriptsFileManagement.copyFileToHere(fln, PQCFileFolderModel.folderFileDialog)
            if(fd_fileview.cutFiles.indexOf(fln) !== -1)
                PQCScriptsFileManagement.deletePermanent(fln)
        }

        hide()

    }

    function show() {
        exist_top.opacity = 1
    }

    function hide() {
        exist_top.opacity = 0
    }

    function closeContextMenus() {
        firstbutton.contextmenu.close()
        secondbutton.contextmenu.close()
    }

}
