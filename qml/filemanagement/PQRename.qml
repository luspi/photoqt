/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

import QtQuick 2.9
import QtQuick.Controls 2.2
import "../templates"
import "../elements"

PQTemplateFullscreen {

    id: rename_top

    popout: PQSettings.interfacePopoutFileRename
    shortcut: "__rename"
    title: em.pty+qsTranslate("filemanagement", "Rename file")

    buttonFirstText: em.pty+qsTranslate("filemanagement", "Rename file")
    buttonSecondShow: true
    buttonSecondText: genericStringCancel

    onPopoutChanged:
        PQSettings.interfacePopoutFileRename = popout

    onButtonFirstClicked:
        performRename()

    onButtonSecondClicked:
        closeElement()


    content: [

//        PQTextXL {
//            id: heading
//            x: (parent.width-width)/2
//            font.weight: baselook.boldweight
//            text: em.pty+qsTranslate("filemanagement", "Rename file")
//        },

        PQText {
            x: (parent.width-width)/2
            color: "grey"
            text: "old filename:"
        },

        PQTextL {
            id: filename
            x: (parent.width-width)/2
            color: "grey"
            font.weight: baselook.boldweight
            text: "this_is_the_old_filename.jpg"
        },

        Item {
            width: 1
            height: 1
        },

        PQTextL {
            id: error
            x: (parent.width-width)/2
            color: "red"
            visible: false
            horizontalAlignment: Qt.AlignHCenter
            text: em.pty+qsTranslate("filemanagement", "An error occured, file could not be renamed!")
        },

        Item {
            width: 1
            height: 1
        },

        PQText {
            x: (parent.width-width)/2
            color: "grey"
            text: "new filename:"
        },

        Row {

            x: (parent.width-width)/2
            spacing: 5

            PQLineEdit {

                id: filenameedit

                width: 300
                height: 40

                placeholderText: em.pty+qsTranslate("filemanagement", "Enter new filename")

            }

            PQText {

                id: filesuffix

                y: (filenameedit.height-height)/2
                color: "grey"
                font.weight: baselook.boldweight
                text: ".jpg"
            }
        }

    ]

    Connections {
        target: loader
        onFileRenamePassOn: {
            if(what == "show") {
                if(filefoldermodel.current == -1)
                    return
                opacity = 1
                error.visible = false
                variables.visibleItem = "filerename"
                filename.text = handlingFileDir.getFileNameFromFullPath(filefoldermodel.currentFilePath)
                filenameedit.text =  handlingFileDir.getBaseName(filefoldermodel.currentFilePath)
                filesuffix.text = "."+handlingFileDir.getSuffix(filefoldermodel.currentFilePath)
                filenameedit.setFocus()
            } else if(what == "hide") {
                closeElement()
            } else if(what == "keyevent") {
                if(param[0] == Qt.Key_Escape)
                    closeElement()
                else if(param[0] == Qt.Key_Enter || param[0] == Qt.Key_Return)
                    button_ok.clicked()
            }
        }
    }

    function performRename() {
        if(filenameedit.text == "")
            return

        var cur = filefoldermodel.currentFilePath
        var dir = handlingFileDir.getFilePathFromFullPath(cur)
        var suf = handlingFileDir.getSuffix(cur)
        if(!handlingFileDir.renameFile(dir, filename.text, filenameedit.text+"."+suf)) {
            error.visible = true
            return
        }
        error.visible = false

        filefoldermodel.setFileNameOnceReloaded = dir + "/" + filenameedit.text+"."+suf

        rename_top.opacity = 0
        variables.visibleItem = ""
    }

    function closeElement() {
        rename_top.opacity = 0
        variables.visibleItem = ""
    }

}
