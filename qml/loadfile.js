
function loadFile(filename, filter, forceReloadDirectory) {

    if(filename === undefined || filename == "")
        return

    if(filename.substring(0,1) == "/") {

        var filenameonly = getanddostuff.removePathFromFilename(filename)
        var pathonly = getanddostuff.removeFilenameFromPath(filename)

        if(pathonly != variables.currentDir || (forceReloadDirectory !== undefined && forceReloadDirectory)) {
            variables.allFilesCurrentDir = getanddostuff.getFilesIn(pathonly, filter)
            variables.totalNumberImagesCurrentFolder = variables.allFilesCurrentDir.length
            variables.currentDir = pathonly
            variables.currentFile = filenameonly
            if(!settings.thumbnailDisable)
                call.load("thumbnailLoadDirectory")
        } else
            variables.currentFile = filenameonly

    } else
        variables.currentFile = filename

    variables.deleteNothingLeft = false
    variables.filterNoMatch = false

    var src = variables.currentDir + "/" + variables.currentFile
    var anim = getanddostuff.isImageAnimated(src)
    var prefix = (anim ? "file://" : "image://full/")
    imageitem.loadImage(prefix + src, anim)
    metadata.setData(getmetadata.getExiv2(src))
    quickinfo.updateQuickInfo()

}

function getNewFilenameAfterDeletion() {
    verboseMessage("ThumbnailBar::getNewFilenameAfterDeletion()",variables.totalNumberImagesCurrentFolder, variables.currentFilePos)
    if(variables.totalNumberImagesCurrentFolder == 1)
        return ""
    if(variables.currentFilePos < variables.totalNumberImagesCurrentFolder-1)
        return variables.allFilesCurrentDir[variables.currentFilePos +1]
    return variables.allFilesCurrentDir[variables.currentFilePos -1]
}

function getFilenameMatchingFilter(filter) {
    if((filter.charAt(0) == "." && variables.currentFile.indexOf(filter) == variables.currentFile.length-filter.length)
            || (filter.charAt(0) != "." && variables.currentFile.indexOf(filter) >= 0)) {
        return variables.currentFile
    } else {
        if(filter.charAt(0) == ".") {
            for(var i = 0; i < variables.totalNumberImagesCurrentFolder; ++i) {
                if(variables.allFilesCurrentDir[i].indexOf(filter) == variables.allFilesCurrentDir[i].length-filter.length) {
                    return variables.allFilesCurrentDir[i]
                }
            }
        } else {
            for(var i = 0; i < variables.totalNumberImagesCurrentFolder; ++i) {
                if(variables.allFilesCurrentDir[i].indexOf(filter) >= 0) {
                    return variables.allFilesCurrentDir[i]
                }
            }
        }

        return ""
    }
}

function loadNext() {
    if(variables.filterNoMatch || variables.deleteNothingLeft) return
    // We need to use a temp variable, otherwise wrapping the end of the images around to the beginning wont work!
    var loadpos = variables.currentFilePos
    if(loadpos == variables.allFilesCurrentDir.length-1)
        loadpos = 0
    else
        loadpos += 1
    loadFile(variables.allFilesCurrentDir[loadpos], variables.filter)
}

function loadPrev() {
    if(variables.filterNoMatch || variables.deleteNothingLeft) return
    // We need to use a temp variable, otherwise wrapping the beginning of the images around to the end wont work!
    var loadpos = variables.currentFilePos
    if(loadpos <= 0)
        loadpos = variables.allFilesCurrentDir.length-1
    else
        loadpos -= 1
    loadFile(variables.allFilesCurrentDir[loadpos], variables.filter)
}

function loadFirst() {
    if(variables.filterNoMatch || variables.deleteNothingLeft) return
    loadFile(variables.allFilesCurrentDir[0], variables.filter)
}

function loadLast() {
    if(variables.filterNoMatch || variables.deleteNothingLeft) return
    loadFile(variables.allFilesCurrentDir[variables.allFilesCurrentDir.length -1], variables.filter)
}
