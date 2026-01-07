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
import QtQuick.Dialogs
import PhotoQt

PQMessageBox {

    id: delete_top

    title: "Delete?"
    text: "Are you sure you want to delete this file?"
    informativeText: "You can either move the file to trash (Enter) from where you can restore it again, or you can delete it permanently (Shift+Enter)."

    button1.text: "Move to trash"
    button2.text: "Delete permanently"
    button3.text: "Cancel"
    button2.visible: true
    button3.visible: true
    button1.fontWeight: PQCLook.fontWeightBold

    onButtonClicked: (butId) => {
        handleDeleting(butId)
    }

    onClosing: {
        PQCConstants.idOfVisibleItem = ""
        PQCNotify.resetActiveFocus()
    }

    function handleDeleting(ask : int) {

        // Trash
        if(ask === 1) {

            PQCConstants.ignoreFileFolderChangesTemporary = true

            if(!PQCScriptsFileManagement.moveFileToTrash(PQCFileFolderModel.currentFile)) {
                PQCScriptsConfig.inform(qsTranslate("filemanagement", "Error"),
                                        qsTranslate("filemanagement", "An error occured, file could not be moved to trash."))
                PQCConstants.ignoreFileFolderChangesTemporary = false
                PQCConstants.idOfVisibleItem = ""
                PQCNotify.resetActiveFocus()
                return
            }

            PQCConstants.ignoreFileFolderChangesTemporary = false
            PQCFileFolderModel.removeEntryMainView(PQCFileFolderModel.currentIndex)

        // Permanent
        } else if(ask === 2) {

            PQCConstants.ignoreFileFolderChangesTemporary = true

            if(!PQCScriptsFileManagement.deletePermanent(PQCFileFolderModel.currentFile)) {
                PQCScriptsConfig.inform(qsTranslate("filemanagement", "Error"),
                                        qsTranslate("filemanagement", "An error occured, file could not be deleted permanently."))
                PQCConstants.ignoreFileFolderChangesTemporary = false
                PQCConstants.idOfVisibleItem = ""
                PQCNotify.resetActiveFocus()
                return
            }

            PQCConstants.ignoreFileFolderChangesTemporary = false
            PQCFileFolderModel.removeEntryMainView(PQCFileFolderModel.currentIndex)

        }

        PQCConstants.idOfVisibleItem = ""
        PQCNotify.resetActiveFocus()

    }

    Connections {

        target: PQCNotify

        function onLoaderPassOn(what : string, args : list<var>) {

            console.log("args: what =", what)
            console.log("args: args =", args)

            if(what === "forceCloseEverything") {

                delete_top.close()
                PQCConstants.idOfVisibleItem = ""
                PQCNotify.resetActiveFocus()

            } else if(what === "show" && args[0] === "FileDelete") {

                if(PQCFileFolderModel.currentFile !== "")
                    delete_top.show()

            } else if(what === "hide" && args[0] === "FileDelete") {

                delete_top.close()
                PQCConstants.idOfVisibleItem = ""
                PQCNotify.resetActiveFocus()

            } else if(delete_top.opacity > 0) {

                if(what === "keyEvent") {

                    if(args[0] === Qt.Key_Escape) {
                        delete_top.close()
                        PQCConstants.idOfVisibleItem = ""
                        PQCNotify.resetActiveFocus()
                    } if(args[0] === Qt.Key_Enter || args[0] === Qt.Key_Return) {
                        if(args[1] === Qt.ShiftModifier)
                            delete_top.button2.clicked()
                        else if(args[1] === Qt.NoModifier)
                            delete_top.button1.clicked()
                    }

                }
            }
        }

    }

}
