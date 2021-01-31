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

function loadFile(path, copyOfAllFiles) {


    if(PQImageFormats.getEnabledFormatsPoppler().indexOf(handlingFileDir.getSuffix(path)) > -1 && PQSettings.pdfSingleDocument) {

        variables.allImageFilesInOrder = handlingFileDialog.listPDFPages(path)
        variables.indexOfCurrentImage = 0

        variables.newFileLoaded()

    } else if(PQImageFormats.getEnabledFormatsLibArchive().indexOf(handlingFileDir.getSuffix(path)) > -1 && PQSettings.archiveSingleFile) {

        variables.allImageFilesInOrder = handlingFileDialog.listArchiveContent(path)
        variables.indexOfCurrentImage = 0

        variables.newFileLoaded()

    } else {

        if(copyOfAllFiles !== undefined)

            variables.allImageFilesInOrder = files_model.getCopyOfAllFiles()

        else {

            var sortField = PQSettings.sortby=="name" ?
                                PQFileFolderModel.Name :
                                (PQSettings.sortby == "naturalname" ?
                                    PQFileFolderModel.NaturalName :
                                    (PQSettings.sortby == "time" ?
                                        PQFileFolderModel.Time :
                                        (PQSettings.sortby == "size" ?
                                            PQFileFolderModel.Size :
                                            PQFileFolderModel.Type)))

            variables.allImageFilesInOrder = filefoldermodel.loadFilesInFolder(path,
                                                                               PQSettings.openShowHiddenFilesFolders,
                                                                               PQImageFormats.getEnabledFormats(),
                                                                               PQImageFormats.getEnabledMimeTypes(),
                                                                               sortField,
                                                                               !PQSettings.sortbyAscending)

            if(variables.allImageFilesInOrder.indexOf(path) == -1)
                variables.allImageFilesInOrder.push(path)

        }

        var fp = path
        if(PQImageFormats.getEnabledFormatsPoppler().indexOf("*." + handlingFileDir.getSuffix(fp)) > -1)
            fp = "0::PQT::" + fp

        variables.indexOfCurrentImage = variables.allImageFilesInOrder.indexOf(fp)

        variables.newFileLoaded()

    }


}

function changeCurrentFilename(newfile) {

    variables.allImageFilesInOrder[variables.indexOfCurrentImage] = newfile
    var tmp = variables.indexOfCurrentImage
    variables.indexOfCurrentImage = -1
    variables.indexOfCurrentImage = tmp

}

function removeCurrentFilenameFromList() {

    variables.allImageFilesInOrder.splice(variables.indexOfCurrentImage, 1)
    if(variables.indexOfCurrentImage >= variables.allImageFilesInOrder.length)
        variables.indexOfCurrentImage -= 1

    if(variables.indexOfCurrentImage == -1)
        imageitem.hideAllImages()
    else {
        var tmp = variables.indexOfCurrentImage
        variables.indexOfCurrentImage = -1
        variables.indexOfCurrentImage = tmp
    }

}

function addFilenameToList(file, index) {
    variables.allImageFilesInOrder.splice(index, 0, file)
}
