/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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
import "../../elements"

PQMenu {

    id: top

    property bool isFolder: false
    property bool isFile: false
    property string path: ""

    signal closed()

    model: [
        (isFolder ? qsTranslate("filedialog", "Load this folder") : qsTranslate("filedialog", "Load this file")),
        (em.pty+qsTranslate("filedialog", "Add to Favorites")),
        (PQSettings.openfileShowHiddenFilesFolders ? qsTranslate("filedialog", "Hide hidden files") : qsTranslate("filedialog", "Show hidden files")),
        (PQSettings.openfileThumbnails ? qsTranslate("filedialog", "Hide thumbnails") : qsTranslate("filedialog", "Show thumbnails")),
        (PQSettings.openfilePreview ? qsTranslate("filedialog", "Hide preview") : qsTranslate("filedialog", "Show preview")),
        (PQSettings.openfilePreviewBlur ? qsTranslate("filedialog", "Remove blur from preview") : qsTranslate("filedialog", "Add blur to preview")),
        (PQSettings.openfilePreviewMuted ? qsTranslate("filedialog", "Normal colors in preview") : qsTranslate("filedialog", "Muted colors in preview"))
    ]

    hideIndices: [
        ((!isFile&&!isFolder) ? 0 : -1),
        (!isFolder ? 1 : -1)
    ]

    lineBelowIndices: [
        ((isFile&&!isFolder) ? 0 : -1),
        (isFolder ? 1 : -1),
        4
    ]

    onTriggered: {
        if(index == 0) {
            if(isFolder)
                filedialog_top.setCurrentDirectory(path)
            else {
                filefoldermodel.setFileNameOnceReloaded = path
                filefoldermodel.fileInFolderMainView = path
                filedialog_top.hideFileDialog()
            }
        } else if(index == 1)
            handlingFileDialog.addNewUserPlacesEntry(path, upl.model.count)
        else if(index == 2)
            PQSettings.openfileShowHiddenFilesFolders = !PQSettings.openfileShowHiddenFilesFolders
        else if(index == 3)
            PQSettings.openfileThumbnails = !PQSettings.openfileThumbnails
        else if(index == 4)
            PQSettings.openfilePreview = !PQSettings.openfilePreview
        else if(index == 5)
            PQSettings.openfilePreviewBlur = !PQSettings.openfilePreviewBlur
        else if(index == 6)
            PQSettings.openfilePreviewMuted = !PQSettings.openfilePreviewMuted

        top.closed()

    }

}
