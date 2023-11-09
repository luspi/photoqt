import QtQuick

import PQCFileFolderModel
import PQCScriptsFilesPaths
import PQCScriptsFileManagement

import "../other"
import "../elements"

PQTemplateFullscreen {

    id: exist_top

    title: "Existing files"

    property var files: []

    button1.text: "Continue"

    button2.visible: true
    button2.text: genericStringCancel

    button1.onClicked:
        continuePaste()

    button2.onClicked:
        hide()

    property var checkedFiles: []

    content: [

        PQTextXL {
            x: (parent.width-width)/2
            text: qsTranslate("filedialog", "%1 files already exist in the target directory.").arg(files.length)
        },

        PQText {
            x: (parent.width-width)/2
            text: qsTranslate("filedialog", "Check the files below that you want to paste anyways. Files left unchecked will not be pasted.")
        },

        Rectangle {

            x: (parent.width-width)/2

            width: 400
            height: 300

            color: PQCLook.baseColorAccent
            border.color: PQCLook.baseColorActive
            border.width: 1

            ListView {

                id: view

                anchors.fill: parent
                anchors.margins: 1

                model: files.length

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

                        property string filepath: files[index]
                        property string filename: PQCScriptsFilesPaths.getFilename(filepath)

                        width: view.width
                        height: 40
                        color: check.checked ? PQCLook.baseColorActive : (view.currentIndex===index ? PQCLook.baseColorHighlight : PQCLook.baseColorAccent)
                        border.color: PQCLook.baseColor
                        border.width: 1

                        opacity: check.checked ? 1 : 0.6
                        Behavior on opacity{ NumberAnimation { duration: 200 } }

                        Row {

                            x: 5
                            height: parent.height

                            PQCheckBox {
                                id: check
                                y: (parent.height-height)/2
                                checked: exist_top.checkedFiles.indexOf(index)!==-1
                                font.pointSize: PQCLook.fontSizeL
                            }

                            PQTextL {
                                y: (parent.height-height)/2
                                width: deleg.width-check.width-icon.width-20
                                elide: Text.ElideMiddle
                                text: PQCScriptsFilesPaths.getFilename(files[index])
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
                                view.currentIndex = index
                            onExited: {
                                resetCurrentIndex.oldIndex = index
                                resetCurrentIndex.restart()
                            }
                            onClicked: {
                                if(checkedFiles && exist_top.checkedFiles.indexOf(index)===-1) {
                                    exist_top.checkedFiles.push(index)
                                    exist_top.checkedFilesChanged()
                                } else
                                    exist_top.checkedFiles = exist_top.checkedFiles.filter(item => item!==index)
                            }
                        }

                        Component.onCompleted: {
                            exist_top.checkedFiles.push(index)
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

    function pasteExistingFiles(filelist) {
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

}
