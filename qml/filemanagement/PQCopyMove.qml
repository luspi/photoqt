/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
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
