/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
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
import "../../elements"

PQMenu {

    property bool isFolder: false
    property bool isFile: false
    property string path: ""

    model: [
        (isFolder ? qsTranslate("filedialog", "Load this folder") : qsTranslate("filedialog", "Load this file")),
        (em.pty+qsTranslate("filedialog", "Add to Favorites")),
        (PQSettings.openShowHiddenFilesFolders ? qsTranslate("filedialog", "Hide hidden files") : qsTranslate("filedialog", "Show hidden files")),
        (PQSettings.openThumbnails ? qsTranslate("filedialog", "Hide thumbnails") : qsTranslate("filedialog", "Show thumbnails")),
        (PQSettings.openPreview ? qsTranslate("filedialog", "Hide preview") : qsTranslate("filedialog", "Show preview"))
    ]

    hideIndices: [
        ((!isFile&&!isFolder) ? 0 : -1),
        (!isFolder ? 1 : -1)
    ]

    lineBelowIndices: [
        ((isFile&&!isFolder) ? 0 : -1),
        (isFolder ? 1 : -1)
    ]

    onTriggered: {
        if(index == 0) {
            if(fileIsDir)
                filedialog_top.setCurrentDirectory(filePath)
            else {
                hideFileDialog()
                // FIXME
//                foldermodel.setFolderAndImages(ffilePath, files_model.getCopyOfAllFiles())
            }
        } else if(index == 1)
            handlingFileDialog.addNewUserPlacesEntry(filePath, upl.model.count)
        else if(index == 2)
            PQSettings.openShowHiddenFilesFolders = !PQSettings.openShowHiddenFilesFolders
        else if(index == 3)
            PQSettings.openThumbnails = !PQSettings.openThumbnails
        else if(index == 4)
            PQSettings.openPreview = !PQSettings.openPreview

    }

}
