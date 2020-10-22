import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.0

import "../elements"
import "../loadfiles.js" as LoadFiles

Item {

    id: delete_top

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
        sourceItem: PQSettings.fileDeletePopoutElement ? dummyitem : imageitem
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
                    text: em.pty+qsTranslate("filemanagement", "Delete file?")
                }

                Text {
                    id: filename
                    x: (insidecont.width-width)/2
                    color: "grey"
                    font.pointSize: 15
                    text: "this_is_the_filename.jpg"
                }

                Text {
                    id: error
                    x: (insidecont.width-width)/2
                    color: "red"
                    visible: false
                    font.pointSize: 15
                    horizontalAlignment: Qt.AlignHCenter
                    text: em.pty+qsTranslate("filemanagement", "An error occured, file could not be deleted!")
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
                            id: button_trash
                            text: em.pty+qsTranslate("filemanagement", "Move to trash")
                            onClicked: {

                                if(!handlingFileManagement.deleteFile(variables.allImageFilesInOrder[variables.indexOfCurrentImage], false)) {
                                    error.visible = true
                                    return
                                }

                                LoadFiles.removeCurrentFilenameFromList(variables.allImageFilesInOrder[variables.indexOfCurrentImage])
                                thumbnails.reloadThumbnails()

                                delete_top.opacity = 0
                                variables.visibleItem = ""
                            }
                        }
                        PQButton {
                            id: button_permanent
                            text: em.pty+qsTranslate("filemanagement", "Delete permanently")
                            onClicked: {

                                if(!handlingFileManagement.deleteFile(variables.allImageFilesInOrder[variables.indexOfCurrentImage], true)) {
                                    error.visible = true
                                    return
                                }

                                LoadFiles.removeCurrentFilenameFromList(variables.allImageFilesInOrder[variables.indexOfCurrentImage])
                                thumbnails.reloadThumbnails()

                                delete_top.opacity = 0
                                variables.visibleItem = ""
                            }
                        }
                        PQButton {
                            id: button_cancel
                            text: genericStringCancel
                            onClicked: {
                                delete_top.opacity = 0
                                variables.visibleItem = ""
                            }
                        }

                    }

                }

                Item {
                    width: 1
                    height: 1
                }

                Text {
                    x: (parent.width-width)/2
                    font.pointSize: 8
                    font.bold: true
                    color: "white"
                    textFormat: Text.RichText
                    text: "<table><tr><td align=right>" + keymousestrings.translateShortcut("Enter") +
                          "</td><td>=</td><td>" + em.pty+qsTranslate("filemanagement", "Move to Trash") +
                          "</td</tr><tr><td align=right>" + keymousestrings.translateShortcut("Shift+Enter") +
                          "</td><td>=</td><td>" + em.pty+qsTranslate("filemanagement", "Delete permanently") + "</td></tr></table>"
                }

            }

        }

        Connections {
            target: loader
            onFileDeletePassOn: {
                if(what == "show") {
                    if(variables.indexOfCurrentImage == -1)
                        return
                    opacity = 1
                    error.visible = false
                    variables.visibleItem = "filedelete"
                    filename.text = handlingGeneral.getFileNameFromFullPath(variables.allImageFilesInOrder[variables.indexOfCurrentImage])
                } else if(what == "hide") {
                    button_cancel.clicked()
                } else if(what == "keyevent") {
                    if(param[0] == Qt.Key_Escape)
                        button_cancel.clicked()
                    else if(param[0] == Qt.Key_Enter || param[0] == Qt.Key_Return) {
                        if(param[1] & Qt.ShiftModifier)
                            button_permanent.clicked()
                        else
                            button_trash.clicked()
                    }
                }
            }
        }



        Shortcut {
            sequence: "Esc"
            enabled: PQSettings.fileDeletePopoutElement
            onActivated: button_cancel.clicked()
        }

        Shortcut {
            sequences: ["Enter", "Return"]
            enabled: PQSettings.fileDeletePopoutElement
            onActivated: button_trash.clicked()
        }

        Shortcut {
            sequences: ["Shift+Enter", "Shift+Return"]
            enabled: PQSettings.fileDeletePopoutElement
            onActivated: button_permanent.clicked()
        }

    }

}
