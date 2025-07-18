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
import PhotoQt

PQTemplateFullscreen {

    id: exist_top

    title: "Existing files"

    property list<string> files: []

    button1.text: "Continue"

    button2.visible: true
    button2.text: genericStringCancel

    button1.onClicked:
        continuePaste()

    button2.onClicked:
        hide()

    property list<string> checkedFiles: []

    content: [

        PQTextXL {
            x: (parent.width-width)/2
            text: qsTranslate("filedialog", "%1 files already exist in the target directory.").arg(exist_top.files.length)
        },

        PQText {
            x: (parent.width-width)/2
            text: qsTranslate("filedialog", "Check the files below that you want to paste anyways. Files left unchecked will not be pasted.")
        },

        Rectangle {

            x: (parent.width-width)/2

            width: 400
            height: 300

            color: PQCLook.baseColorAccent // qmllint disable unqualified
            border.color: PQCLook.baseColorActive // qmllint disable unqualified
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
                        property string filename: PQCScriptsFilesPaths.getFilename(filepath) // qmllint disable unqualified

                        width: view.width
                        height: 40
                        color: check.checked ? PQCLook.baseColorActive : (view.currentIndex===modelData ? PQCLook.baseColorHighlight : PQCLook.baseColorAccent) // qmllint disable unqualified
                        border.color: PQCLook.baseColor // qmllint disable unqualified
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
                                font.pointSize: PQCLook.fontSizeL // qmllint disable unqualified
                            }

                            PQTextL {
                                y: (parent.height-height)/2
                                width: deleg.width-check.width-icon.width-20
                                elide: Text.ElideMiddle
                                text: PQCScriptsFilesPaths.getFilename(exist_top.files[deleg.modelData]) // qmllint disable unqualified
                            }

                            Item {
                                id: icon
                                width: parent.height
                                height: width

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    source: PQCScriptsFilesPaths.isFolder(deleg.filepath) ? "image://icon/folder" // qmllint disable unqualified
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
                            }
                        }

                        Component.onCompleted: {
                            exist_top.checkedFiles.push(deleg.modelData)
                            exist_top.checkedFilesChanged()
                        }

                    }

            }

        },

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

    ]

    function pasteExistingFiles(filelist : list<string>) {
        files = []
        files = filelist
        show()
    }

    function continuePaste() {

        for(var i in exist_top.checkedFiles) {
            var ind = exist_top.checkedFiles[i]
            var fln = files[ind]
            PQCScriptsFileManagement.copyFileToHere(fln, PQCFileFolderModel.folderFileDialog) // qmllint disable unqualified
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

}
