
function loadFile(filename, filter, forceReloadDirectory) {

    if(filename === undefined || filename == "")
        return

    if(filename.substring(0,1) == "/") {

        var filenameonly = getanddostuff.removePathFromFilename(filename)
        var pathonly = getanddostuff.removeFilenameFromPath(filename)

        if(pathonly != variables.currentDir || (forceReloadDirectory !== undefined && forceReloadDirectory)) {
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


    var src = variables.currentDir + "/" + variables.currentFile
    var anim = getanddostuff.isImageAnimated(src)
    var prefix = (anim ? "file://" : "image://full/")
    imageitem.loadImage(prefix + src, anim)
    metadata.setData(getmetadata.getExiv2(src))
    quickinfo.updateQuickInfo()

}

function getNewFilenameAfterDeletion() {
    verboseMessage("ThumbnailBar::getNewFilenameAfterDeletion()",variables.totalNumberImagesCurrentFolder, variables.currentFilePos)
    if(variables.totalNumberImagesCurrentFolder == 1) {
        // SET VIEW TO EMPTY
        return ""
    }
    if(variables.currentFilePos < variables.totalNumberImagesCurrentFolder-1)
        return variables.allFilesCurrentDir[variables.currentFilePos +1]
    return variables.allFilesCurrentDir[variables.currentFilePos -1]
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

function loadFirst() {
    loadFile(variables.allFilesCurrentDir[0], variables.filter)
}

function loadLast() {
    loadFile(variables.allFilesCurrentDir[variables.allFilesCurrentDir.length -1], variables.filter)
}
