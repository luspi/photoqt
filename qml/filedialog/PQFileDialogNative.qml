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

    id: filedialog_top

    Connections {

        target: PQCNotify

        function onLoaderPassOn(what : string, param : list<var>) {

            console.log("args: what =", what)
            console.log("args: param =", param)

            if(what === "show") {

                if(param[0] === "FileDialog")
                    filedialog_top.show()

            }

        }

    }

    function show() {

        var startname = ""

        if(PQCSettings.filedialogStartupRestorePrevious)
            startname = PQCScriptsFileDialog.getLastLocation()
        else
            startname = PQCScriptsFilesPaths.getHomeDir()


        if(PQCFileFolderModel.currentIndex !== -1 && PQCFileFolderModel.currentFile !== "")
            startname = PQCScriptsFilesPaths.getDir(PQCFileFolderModel.currentFile)

        var fname = PQCScriptsFilesPaths.openFileFromDialog("Open", startname, PQCImageFormats.getEnabledFormats())

        if(fname !== "") {
            PQCScriptsFileDialog.setLastLocation(PQCScriptsFilesPaths.getDir(fname))
            PQCFileFolderModel.extraFoldersToLoad = []
            PQCFileFolderModel.fileInFolderMainView = fname
        }

        PQCConstants.idOfVisibleItem = ""

    }

}
