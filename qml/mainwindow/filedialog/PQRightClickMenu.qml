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
        text: settings.openShowHiddenFilesFolders ? qsTranslate("filedialog", "Hide hidden files") : qsTranslate("filedialog", "Show hidden files")
        onTriggered: {
            var old = settings.openShowHiddenFilesFolders
            settings.openShowHiddenFilesFolders = !old
        }
    }

    PQMenuItem {
        text: settings.openThumbnails ? qsTranslate("filedialog", "Hide thumbnails") : qsTranslate("filedialog", "Show thumbnails")
        onTriggered: {
            var old = settings.openThumbnails
            settings.openThumbnails = !old
        }
    }

    PQMenuItem {
        text: settings.openPreview ? qsTranslate("filedialog", "Hide preview") : qsTranslate("filedialog", "Show preview")
        onTriggered: {
            var old = settings.openPreview
            settings.openPreview = !old
        }
    }

}
