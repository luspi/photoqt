import QtQuick 2.9
import "../../elements"

PQMenu {

    property bool isFolder: false
    property bool isFile: false
    property string path: ""

    PQMenuItem {
        visible: isFile||isFolder
        text: isFolder ? qsTranslate("filedialog", "Load this folder") : qsTranslate("filedialog", "Load this file")
        lineBelowItem: true
        onTriggered: {
            if(fileIsDir)
                filedialog_top.setCurrentDirectory(filePath)
            else {
                hideFileDialog()
                imageitem.loadImage(filePath)
            }
        }
        Component.onCompleted: {
            if(!isFile && !isFolder)
                height = 0
        }
    }

    PQMenuItem {
        visible: isFolder
        text: em.pty+qsTranslate("filedialog", "Add to Favorites")
        lineBelowItem: true
        onTriggered: {
            handlingFileDialog.addNewUserPlacesEntry(filePath, upl.model.count)
        }
    }

    PQMenuItem {
        text: PQSettings.openShowHiddenFilesFolders ? qsTranslate("filedialog", "Hide hidden files") : qsTranslate("filedialog", "Show hidden files")
        onTriggered: {
            var old = PQSettings.openShowHiddenFilesFolders
            PQSettings.openShowHiddenFilesFolders = !old
        }
    }

    PQMenuItem {
        text: PQSettings.openThumbnails ? qsTranslate("filedialog", "Hide thumbnails") : qsTranslate("filedialog", "Show thumbnails")
        onTriggered: {
            var old = PQSettings.openThumbnails
            PQSettings.openThumbnails = !old
        }
    }

    PQMenuItem {
        text: PQSettings.openPreview ? qsTranslate("filedialog", "Hide preview") : qsTranslate("filedialog", "Show preview")
        onTriggered: {
            var old = PQSettings.openPreview
            PQSettings.openPreview = !old
        }
    }

}
