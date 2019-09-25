import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2

import "../elements"
import "../loadfiles.js" as LoadFiles

Rectangle {

    id: rename_top

    color: "#dd000000"

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    property string currentNewFileName: ""

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.animationDuration*100 } }
    visible: opacity!=0

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
                text: "Rename"
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
                text: "An error occured,<br>file could not be renamed!"
            }

            // having a text field around messes with the shortcuts engine => only load when actually needed

            Loader {
                id: filenameeditloader
                x: (insidecont.width-width)/2
            }

            Component {

                id: filenameeditcomponent

                PQLineEdit {

                    id: filenameedit

                    width: 300
                    height: 40

                    text: handlingFileDialog.getBaseName(variables.allImageFilesInOrder[variables.indexOfCurrentImage])

                    onAccepted:
                        button_ok.clicked()
                    Keys.onEscapePressed:
                        button_cancel.clicked()

                    Component.onCompleted: {
                        rename_top.currentNewFileName = filenameedit.text
                        setFocus()
                        selectAll()
                    }

                    onTextEdited:
                        rename_top.currentNewFileName = filenameedit.text

                }

            }

            Component {
                id: emptyitem
                Item { }
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
                        text: "Rename file"
                        enabled: rename_top.currentNewFileName!=""
                        onClicked: {

                            if(rename_top.currentNewFileName == "")
                                return

                            var cur = variables.allImageFilesInOrder[variables.indexOfCurrentImage]
                            var dir = handlingGeneral.getFilePathFromFullPath(cur)
                            var suf = handlingFileDialog.getSuffix(cur)
                            if(!handlingFileManagement.renameFile(dir, filename.text, rename_top.currentNewFileName+"."+suf)) {
                                error.visible = true
                                return
                            }
                            error.visible = false

                            LoadFiles.changeCurrentFilename(dir, rename_top.currentNewFileName+"."+suf)
                            thumbnails.reloadThumbnails()

                            rename_top.opacity = 0
                            filenameeditloader.sourceComponent = emptyitem
                            variables.textEditFocused = false
                            variables.visibleItem = ""

                        }
                    }
                    PQButton {
                        id: button_cancel
                        text: "Cancel"
                        onClicked: {
                            rename_top.opacity = 0
                            filenameeditloader.sourceComponent = emptyitem
                            variables.textEditFocused = false
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
                filenameeditloader.sourceComponent = filenameeditcomponent
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
