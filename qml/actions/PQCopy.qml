/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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

    id: copy_top

    function copyFile() {

        var targetfile = PQCScriptsFilesPaths.selectFileFromDialog(qsTranslate("filemanagement", "Copy here"), PQCFileFolderModel.currentFile, PQCImageFormats.detectFormatId(PQCFileFolderModel.currentFile), true);
        if(targetfile !== "" && targetfile !== PQCFileFolderModel.currentFile) {
            if(!PQCScriptsFileManagement.copyFile(PQCFileFolderModel.currentFile, targetfile)) {
                PQCScriptsConfig.inform(qsTranslate("filemanagement", "Error"),
                                        qsTranslate("filemanagement", "An error occured, file could not be copied."))
            }
        }

    }

    Connections {

        target: PQCNotify

        function onLoaderPassOn(what : string, args : list<var>) {

            console.log("args: what =", what)
            console.log("args: args =", args)

            if(what === "forceCloseEverything") {

                PQCNotify.resetActiveFocus()

            } else if(what === "show" && args[0] === "FileCopy") {

                if(PQCFileFolderModel.currentFile !== "")
                    copy_top.copyFile()

            } else if(what === "hide" && args[0] === "FileCopy") {

                PQCNotify.resetActiveFocus()

            } else if(copy_top.opacity > 0) {

                if(what === "keyEvent") {

                    if(args[0] === Qt.Key_Escape) {
                        PQCNotify.resetActiveFocus()
                    }

                }
            }
        }

    }

}
