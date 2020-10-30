import QtQuick 2.9
import "../loadfiles.js" as LoadFiles

Item {


    Connections {
        target: loader
        onCopyMoveFilePassOn: {
            if(variables.indexOfCurrentImage == -1)
                return
            if(what == "move") {
                var movedfile = handlingFileManagement.moveFile(variables.allImageFilesInOrder[variables.indexOfCurrentImage])
                if(movedfile !== "") {
                    var movedpath = handlingGeneral.getFilePathFromFullPath(movedfile)
                    var oldpath = handlingGeneral.getFilePathFromFullPath(variables.allImageFilesInOrder[variables.indexOfCurrentImage])
                    if(movedpath == oldpath) {
                        LoadFiles.changeCurrentFilename(movedfile)
                        thumbnails.reloadThumbnails()
                    } else {
                        LoadFiles.removeCurrentFilenameFromList()
                        thumbnails.reloadThumbnails()
                        variables.newFileLoaded()
                    }
                }
            } else if(what == "copy") {
                var copiedfile = handlingFileManagement.copyFile(variables.allImageFilesInOrder[variables.indexOfCurrentImage])
                if(copiedfile !== "") {
                    var copieddpath = handlingGeneral.getFilePathFromFullPath(copiedfile)
                    var oldpath = handlingGeneral.getFilePathFromFullPath(variables.allImageFilesInOrder[variables.indexOfCurrentImage])
                    if(copieddpath == oldpath) {
                        variables.allImageFilesInOrder.push(copiedfile)
                        var tmp = variables.indexOfCurrentImage
                        variables.indexOfCurrentImage = -1
                        variables.indexOfCurrentImage = tmp
                        thumbnails.reloadThumbnails()
                    }
                }

            }
        }
    }

}
