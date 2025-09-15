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
import QtQuick.Controls
import PhotoQt.CPlusPlus
import PhotoQt.Integrated

ApplicationWindow {

    id: rename_top

    width: 400
    minimumWidth: width
    maximumWidth: width
    height: contcol.height+20
    minimumHeight: contcol.height+20
    maximumHeight: contcol.height+20

    modality: Qt.ApplicationModal

    property string cacheDir: ""
    property string cacheFileName: ""

    Column {

        id: contcol

        y: 10
        width: parent.width

        spacing: 10

        PQTextL {
            x: (parent.width-width)/2
            text: qsTranslate("filemanagement", "Rename file")
            font.weight: PQCLook.fontWeightBold
        }

        Row {
            x: 10
            spacing: 5
            PQLineEdit {
                id: filenameedit
                width: rename_top.width-filesuffix.width-20

            }
            PQTextL {
                id: filesuffix
                y: (filenameedit.height-height)/2
                text: "." + PQCScriptsFilesPaths.getSuffix(PQCFileFolderModel.currentFile)
            }
        }

        Row {
            x: (parent.width-width)/2
            spacing: 5
            PQButton {
                text: qsTranslate("filemanagement", "Rename")
                smallerVersion: true
                onClicked:
                    rename_top.renameFile()
            }
            PQButton {
                text: genericStringCancel
                smallerVersion: true
                onClicked: rename_top.close()
            }
        }

    }

    onVisibleChanged: {
        if(visible) {
            filenameedit.enabled = true
            cacheDir = PQCScriptsFilesPaths.getDir(PQCFileFolderModel.currentFile)
            cacheFileName = PQCScriptsFilesPaths.getFilename(PQCFileFolderModel.currentFile)
            filenameedit.placeholderText = PQCScriptsFilesPaths.getBasename(cacheFileName)
            filenameedit.text = filenameedit.placeholderText
            filenameedit.setFocus()
        } else {
            filenameedit.enabled = false
            PQCConstants.idOfVisibleItem = ""
            PQCNotify.resetActiveFocus()
        }
    }

    Component.onCompleted: {
        show()
    }

    Connections {

        target: PQCNotify

        function onLoaderPassOn(what : string, args : list<var>) {

            console.log("args: what =", what)
            console.log("args: args =", args)

            if(what === "show" && args[0] === "FileRename") {

                rename_top.show()

            } else if(what === "hide" && args[0] === "FileRename") {

                rename_top.close()

            } else if(rename_top.opacity > 0) {

                if(what === "keyEvent") {

                    if(args[0] === Qt.Key_Escape)
                        rename_top.close()

                    else if(args[0] === Qt.Key_Enter || args[0] === Qt.Key_Return)
                        rename_top.renameFile()

                }
            }
        }

    }

    function renameFile() {

        if(filenameedit.text === "")
            return

        if(filenameedit.text+filesuffix.text !== cacheFileName &&
                PQCScriptsFilesPaths.doesItExist(cacheDir + "/" + filenameedit.text + filesuffix.text)) {
            PQCScriptsConfig.inform(qsTranslate("filemanagement", "Error"),
                                    qsTranslate("filemanagement", "Unable to continue, a file with the target filename already exists."))
            PQCConstants.ignoreFileFolderChangesTemporary = false
            return
        }

        PQCConstants.ignoreFileFolderChangesTemporary = true

        if(!PQCScriptsFileManagement.renameFile(cacheDir, cacheFileName, filenameedit.text+filesuffix.text)) {
            PQCScriptsConfig.inform(qsTranslate("filemanagement", "Error"),
                                    qsTranslate("filemanagement", "An error occured, file could not be renamed."))
            PQCConstants.ignoreFileFolderChangesTemporary = false
            return
        }

        PQCFileFolderModel.removeEntryMainView(PQCFileFolderModel.currentIndex)
        PQCConstants.ignoreFileFolderChangesTemporary = false
        PQCFileFolderModel.fileInFolderMainView = cacheDir + "/" + filenameedit.text+filesuffix.text

        close()

    }

}
