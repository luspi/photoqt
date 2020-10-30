import QtQuick 2.9
import "../loadfiles.js" as LoadFiles

Item {


    Connections {
        target: loader
        onCopyMoveFilePassOn: {
            if(what == "move") {
                if(variables.indexOfCurrentImage == -1)
                    return
                if(handlingFileManagement.moveFile(variables.allImageFilesInOrder[variables.indexOfCurrentImage]) != "") {
                    // TODO: if file moved to different name in same folder, treat it as rename
                    LoadFiles.removeCurrentFilenameFromList(variables.allImageFilesInOrder[variables.indexOfCurrentImage])
                    thumbnails.reloadThumbnails()
                    variables.newFileLoaded()
                }
            } else if(what == "copy") {

                if(handlingFileManagement.copyFile(variables.allImageFilesInOrder[variables.indexOfCurrentImage]) != "") {
                    // TODO: if direcotry the same: add to list of images
                    thumbnails.reloadThumbnails()
                    variables.newFileLoaded()
                    // TODO: if in different folder, don't do anything
                }

            }
        }
    }

}
