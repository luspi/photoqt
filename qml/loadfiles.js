function loadFile(path, copyOfAllFiles) {


    if(PQImageFormats.enabledFileformatsPoppler.indexOf("*." + handlingFileDialog.getSuffix(path)) > -1 && PQSettings.pdfSingleDocument) {

        variables.allImageFilesInOrder = handlingFileDialog.listPDFPages(path)
        variables.indexOfCurrentImage = 0

    } else if(PQImageFormats.enabledFileformatsArchive.indexOf("*." + handlingFileDialog.getSuffix(path)) > -1 && PQSettings.archiveSingleFile) {

        variables.allImageFilesInOrder = handlingFileDialog.listArchiveContent(path)
        variables.indexOfCurrentImage = 0

    } else {

        if(copyOfAllFiles !== undefined)

            variables.allImageFilesInOrder = files_model.getCopyOfAllFiles()

        else {

            var sortField = PQSettings.sortby=="name" ?
                                filefoldermodel.Name :
                                (PQSettings.sortby == "naturalname" ?
                                    filefoldermodel.NaturalName :
                                    (PQSettings.sortby == "time" ?
                                        filefoldermodel.Time :
                                        (PQSettings.sortby == "size" ?
                                            filefoldermodel.Size :
                                            filefoldermodel.Type)))

            variables.allImageFilesInOrder = filefoldermodel.loadFilesInFolder(path,
                                                                               PQSettings.openShowHiddenFilesFolders,
                                                                               PQImageFormats.getEnabledFileFormats("all"),
                                                                               sortField,
                                                                               !PQSettings.sortbyAscending)

        }

        var fp = path
        if(PQImageFormats.enabledFileformatsPoppler.indexOf("*." + handlingFileDialog.getSuffix(fp)) > -1)
            fp = "0::PQT::" + fp

        variables.indexOfCurrentImage = variables.allImageFilesInOrder.indexOf(fp)

    }


}

function changeCurrentFilename(dir, newfile) {

    variables.allImageFilesInOrder[variables.indexOfCurrentImage] = dir + "/" + newfile
    var tmp = variables.indexOfCurrentImage
    variables.indexOfCurrentImage = -1
    variables.indexOfCurrentImage = tmp

}

function removeCurrentFilenameFromList(file) {

    variables.allImageFilesInOrder.splice(variables.indexOfCurrentImage, 1)
    if(variables.indexOfCurrentImage >= variables.allImageFilesInOrder.length-1)
        variables.indexOfCurrentImage -= 1

    var tmp = variables.indexOfCurrentImage
    variables.indexOfCurrentImage = -1
    variables.indexOfCurrentImage = tmp

}
