
function loadFile(filename, filter) {

    if(filename === undefined || filename == "")
        return

    if(filename.substring(0,1) == "/") {

        var filenameonly = getanddostuff.removePathFromFilename(filename)
        var pathonly = getanddostuff.removeFilenameFromPath(filename)

        if(pathonly != variables.currentDir) {
            variables.allFilesCurrentDir = getanddostuff.getFilesIn(pathonly)
            variables.totalNumberImagesCurrentFolder = variables.allFilesCurrentDir.length
            variables.currentDir = pathonly
            variables.currentFile = filenameonly
            if(!settings.thumbnailDisable)
                call.load("thumbnailLoadDirectory")
        } else
            variables.currentFile = filenameonly

    } else
        variables.currentFile = filename

    imageitem.loadImage("image://full/" + variables.currentDir + "/" + variables.currentFile)
    metadata.setData(getmetadata.getExiv2(variables.currentDir + "/" + variables.currentFile))

}

function loadNext() {
    // We need to use a temp variable, otherwise wrapping the end of the images around to the beginning wont work!
    var loadpos = variables.currentFilePos
    if(loadpos == variables.allFilesCurrentDir.length-1)
        loadpos = 0
    else
        loadpos += 1
    loadFile(variables.allFilesCurrentDir[loadpos], variables.filter)
}

function loadPrev() {
    // We need to use a temp variable, otherwise wrapping the beginning of the images around to the end wont work!
    var loadpos = variables.currentFilePos
    if(loadpos <= 0)
        loadpos = variables.allFilesCurrentDir.length-1
    else
        loadpos -= 1
    loadFile(variables.allFilesCurrentDir[loadpos], variables.filter)
}
