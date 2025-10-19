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
import PhotoQt.CPlusPlus
import PhotoQt.Integrated

Item {

    id: move_top

    function moveFile() {

        var targetfile = PQCScriptsFilesPaths.selectFileFromDialog(qsTranslate("filemanagement", "Move here"), PQCFileFolderModel.currentFile, true);
        if(targetfile === "" || targetfile === PQCFileFolderModel.currentFile) {
            PQCNotify.loaderRegisterClose("FileMove")
        } else {
            if(!PQCScriptsFileManagement.moveFile(PQCFileFolderModel.currentFile, targetfile)) {
                PQCScriptsConfig.inform(qsTranslate("filemanagement", "Error"),
                                        qsTranslate("filemanagement", "An error occured, file could not be moved."))
            } else {
                PQCFileFolderModel.removeEntryMainView(PQCFileFolderModel.currentIndex)
                PQCNotify.loaderRegisterClose("FileMove")
            }
        }

    }

    Connections {

        target: PQCNotify

        function onLoaderPassOn(what : string, args : list<var>) {

            console.log("args: what =", what)
            console.log("args: args =", args)

            if(what === "show" && args[0] === "FileMove") {

                if(PQCFileFolderModel.currentFile !== "")
                    move_top.moveFile()

            } else if(what === "hide" && args[0] === "FileMove") {

                PQCConstants.idOfVisibleItem = ""
                PQCNotify.resetActiveFocus()

            } else if(move_top.opacity > 0) {

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
