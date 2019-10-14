import QtQuick 2.9
import "../../elements"
import "../../loadfiles.js" as LoadFiles

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
                LoadFiles.loadFile(filePath,  files_model.getCopyOfAllFiles())
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
