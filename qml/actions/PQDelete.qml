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

Item {

    id: delete_top

    function show() {

        var ask = PQCScriptsFileManagement.askForDeletion()

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

            if(what === "show" && args[0] === "FileDelete") {

                if(PQCFileFolderModel.currentFile !== "")
                    delete_top.show()

            } else if(what === "hide" && args[0] === "FileDelete") {

                PQCConstants.idOfVisibleItem = ""
                PQCNotify.resetActiveFocus()

            } else if(delete_top.opacity > 0) {

                if(what === "keyEvent") {

                    if(args[0] === Qt.Key_Escape) {
                        PQCConstants.idOfVisibleItem = ""
                        PQCNotify.resetActiveFocus()
                    }

                }
            }
        }

    }

}
