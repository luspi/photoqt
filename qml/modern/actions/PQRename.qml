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
import PhotoQt

PQTemplateFullscreen {

    id: rename_top

    thisis: "filerename"
    popout: PQCSettings.interfacePopoutFileRename 
    forcePopout: PQCWindowGeometry.filerenameForcePopout 
    shortcut: "__rename"

    title: qsTranslate("filemanagement", "Rename file")

    button1.enabled: filenameedit.text!==""&&!error_exists.visible
    button1.text: qsTranslate("filemanagement", "Rename file")

    button2.visible: true
    button2.text: genericStringCancel

    onPopoutChanged:
        PQCSettings.interfacePopoutFileRename = popout 

    button1.onClicked:
        renameFile()

    button2.onClicked:
        hide()

    content: [

        PQText {
            x: (parent.width-width)/2
            text: qsTranslate("filemanagement", "old filename:")
        },

        PQTextL {
            id: filename
            x: (parent.width-width)/2
            width: Math.min(600, parent.width-100)
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: "this_is_the_old_filename.jpg"
        },

        Item {
            width: 1
            height: 1
        },

        Item {
            width: 1
            height: 1
        },

        PQText {
            x: (parent.width-width)/2
            text: qsTranslate("filemanagement", "new filename:")
        },

        Row {

            x: (parent.width-width)/2
            spacing: 5

            PQLineEdit {

                id: filenameedit

                width: 400
                height: 40

                onTextChanged: {
                    checkExistence.restart()
                }

            }

            Timer {
                id: checkExistence
                interval: 200
                onTriggered: {
                    error_exists.visible = (filenameedit.text+filesuffix.text!==filename.text && PQCScriptsFilesPaths.doesItExist(PQCScriptsFilesPaths.getDir(PQCFileFolderModel.currentFile) + "/" + filenameedit.text + filesuffix.text)) 
                }
            }

            PQText {

                id: filesuffix

                y: (filenameedit.height-height)/2
                font.weight: PQCLook.fontWeightBold 
                text: ".jpg"
            }
        },

        Item {
            width: 1
            height: 1
        },

        PQTextL {
            id: error
            x: (parent.width-width)/2
            width: Math.min(600, parent.width-100)
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: PQCLook.textColor 
            font.weight: PQCLook.fontWeightBold 
            visible: false
            text: qsTranslate("filemanagement", "An error occured, file could not be renamed")
        },

        PQTextL {
            id: error_exists
            x: (parent.width-width)/2
            width: Math.min(600, parent.width-100)
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: PQCLook.textColor 
            font.weight: PQCLook.fontWeightBold 
            visible: false
            text: qsTranslate("filemanagement", "A file with this filename already exists")
        }

    ]

    Connections {

        target: PQCNotify

        function onLoaderPassOn(what : string, param : list<var>) {

            if(what === "show") {

                if(param[0] === rename_top.thisis)
                    rename_top.show()

            } else if(what === "hide") {

                if(param[0] === rename_top.thisis)
                    rename_top.hide()

            } else if(rename_top.opacity > 0) {

                if(what === "keyEvent") {

                    if(rename_top.contextMenuOpen) {
                        rename_top.closeContextMenus()
                        return
                    }

                    if(param[0] === Qt.Key_Escape)
                        rename_top.hide()

                    else if(param[0] === Qt.Key_Enter || param[0] === Qt.Key_Return)
                        rename_top.renameFile()

                    else
                        filenameedit.handleKeyEvents(param[0], param[1])

                }
            }
        }
    }

    function renameFile() {

        if(filenameedit.text === "" || error_exists.visible)
            return

        PQCConstants.ignoreFileFolderChangesTemporary = true

        var dir = PQCScriptsFilesPaths.getDir(PQCFileFolderModel.currentFile) 
        if(!PQCScriptsFileManagement.renameFile(dir, filename.text, filenameedit.text+filesuffix.text)) {
            error.visible = true
            PQCConstants.ignoreFileFolderChangesTemporary = false
            return
        }
        error.visible = false
        error_exists.visible = false

        PQCFileFolderModel.removeEntryMainView(PQCFileFolderModel.currentIndex)
        PQCConstants.ignoreFileFolderChangesTemporary = false
        PQCFileFolderModel.fileInFolderMainView = dir + "/" + filenameedit.text+filesuffix.text

        hide()

    }

    function show() {

        if(PQCFileFolderModel.currentIndex === -1 || PQCFileFolderModel.countMainView === 0) { 
            hide()
            return
        }
        opacity = 1
        if(popoutWindowUsed)
            filerename_popout.visible = true

        filenameedit.text = PQCScriptsFilesPaths.getBasename(PQCFileFolderModel.currentFile)
        filesuffix.text = "." + PQCScriptsFilesPaths.getSuffix(PQCFileFolderModel.currentFile)
        filenameedit.setFocus()
        error.visible = false
        error_exists.visible = false
        filename.text = PQCScriptsFilesPaths.getFilename(PQCFileFolderModel.currentFile)

    }

    function hide() {

        if(rename_top.contextMenuOpen)
            rename_top.closeContextMenus()

        rename_top.opacity = 0
        if(popoutWindowUsed && filerename_popout.visible)
            filerename_popout.visible = false
        else
            PQCNotify.loaderRegisterClose(thisis)
    }

}
