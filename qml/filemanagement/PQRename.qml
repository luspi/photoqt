import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.0

import "../elements"
import "../loadfiles.js" as LoadFiles

Item {

    id: rename_top

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.animationDuration*100 } }
    visible: opacity!=0
    enabled: visible

    Item {
        id: dummyitem
        width: 0
        height: 0
    }

    ShaderEffectSource {
        id: effectSource
        sourceItem: PQSettings.fileRenamePopoutElement ? dummyitem : imageitem
        anchors.fill: parent
        sourceRect: Qt.rect(parent.x,parent.y,parent.width,parent.height)
    }

    FastBlur {
        id: blur
        anchors.fill: effectSource
        source: effectSource
        radius: 32
    }

    Rectangle {

        anchors.fill: parent
        color: "#cc000000"

        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked:
                button_cancel.clicked()
        }

        Item {

            id: insidecont

            x: ((parent.width-width)/2)
            y: ((parent.height-height)/2)
            width: parent.width
            height: childrenRect.height

            clip: true

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
            }

            Column {

                spacing: 10

                Text {
                    id: heading
                    x: (insidecont.width-width)/2
                    color: "white"
                    font.pointSize: 20
                    font.bold: true
                    text: em.pty+qsTranslate("filemanagement", "Rename file")
                }

                Text {
                    id: filename
                    x: (insidecont.width-width)/2
                    color: "grey"
                    font.pointSize: 15
                    text: "this_is_the_old_filename.jpg"
                }

                Text {
                    id: error
                    x: (insidecont.width-width)/2
                    color: "red"
                    visible: false
                    font.pointSize: 15
                    horizontalAlignment: Qt.AlignHCenter
                    text: em.pty+qsTranslate("filemanagement", "An error occured, file could not be renamed!")
                }

                PQLineEdit {

                    id: filenameedit

                    x: (insidecont.width-width)/2
                    width: 300
                    height: 40

                    placeholderText: em.pty+qsTranslate("filemanagement", "Enter new filename")

                }

                Item {

                    id: butcont

                    x: 0
                    width: insidecont.width
                    height: childrenRect.height

                    Row {

                        spacing: 5

                        x: (parent.width-width)/2

                        PQButton {
                            id: button_ok
                            text: em.pty+qsTranslate("filemanagement", "Rename file")
                            enabled: filenameedit.text!=""
                            onClicked: {

                                if(filenameedit.text == "")
                                    return

                                var cur = variables.allImageFilesInOrder[variables.indexOfCurrentImage]
                                var dir = handlingGeneral.getFilePathFromFullPath(cur)
                                var suf = handlingFileDialog.getSuffix(cur)
                                if(!handlingFileManagement.renameFile(dir, filename.text, filenameedit.text+"."+suf)) {
                                    error.visible = true
                                    return
                                }
                                error.visible = false

                                LoadFiles.changeCurrentFilename(dir, filenameedit.text+"."+suf)
                                thumbnails.reloadThumbnails()

                                rename_top.opacity = 0
                                variables.visibleItem = ""

                            }
                        }
                        PQButton {
                            id: button_cancel
                            text: genericStringCancel
                            onClicked: {
                                rename_top.opacity = 0
                                variables.visibleItem = ""
                            }
                        }

                    }

                }

            }

        }

        Connections {
            target: loader
            onFileRenamePassOn: {
                if(what == "show") {
                    if(variables.indexOfCurrentImage == -1)
                        return
                    opacity = 1
                    error.visible = false
                    variables.visibleItem = "filerename"
                    filename.text = handlingGeneral.getFileNameFromFullPath(variables.allImageFilesInOrder[variables.indexOfCurrentImage])
                    filenameedit.text =  handlingFileDialog.getBaseName(variables.allImageFilesInOrder[variables.indexOfCurrentImage])
                    filenameedit.setFocus()
                } else if(what == "hide") {
                    button_cancel.clicked()
                } else if(what == "keyevent") {
                    if(param[0] == Qt.Key_Escape)
                        button_cancel.clicked()
                    else if(param[0] == Qt.Key_Enter || param[0] == Qt.Key_Return)
                        button_ok.clicked()
                }
            }
        }

    }

}
