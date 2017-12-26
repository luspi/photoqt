
// Load a file. The third paramater is optional, if not provided it is assumed to be false
function loadFile(filename, filter, forceReloadDirectory) {

    // Make sure a file is actually loaded
    if(filename === undefined || filename == "")
        return

    // Load a file from full path
    if(filename.substring(0,1) == "/") {

        // Separate filename and path
        var filenameonly = getanddostuff.removePathFromFilename(filename)
        var pathonly = getanddostuff.removeFilenameFromPath(filename)

        // If it's a new path or a forced reload, load folder contents and set up thumbnails (if enabled)
        if(pathonly != variables.currentDir || (forceReloadDirectory !== undefined && forceReloadDirectory)) {
            variables.allFilesCurrentDir = getanddostuff.getFilesIn(pathonly, filter)
            variables.totalNumberImagesCurrentFolder = variables.allFilesCurrentDir.length
            variables.currentDir = pathonly
            variables.currentFile = filenameonly
            if(!settings.thumbnailDisable)
                call.load("thumbnailLoadDirectory")
        // Otherwise it is just a file in the same folder > Only display right image
        } else
            variables.currentFile = filenameonly

    // Image in current folder, display
    } else
        variables.currentFile = filename

    // Reset these two, as something has arrived here
    variables.deleteNothingLeft = false
    variables.filterNoMatch = false

    // Set the image, load the metadata and update the quickinfo
    var src = variables.currentDir + "/" + variables.currentFile
    var anim = getanddostuff.isImageAnimated(src)
    var prefix = (anim ? "file://" : "image://full/")
    imageitem.loadImage(prefix + src, anim)
    metadata.setData(getmetadata.getExiv2(src))
    quickinfo.updateQuickInfo()

}

// After deleting an image, we need to figure out the new filename to be displayed (if any left)
function getNewFilenameAfterDeletion() {
    verboseMessage("ThumbnailBar::getNewFilenameAfterDeletion()",variables.totalNumberImagesCurrentFolder, variables.currentFilePos)
    if(variables.totalNumberImagesCurrentFolder == 1)
        return ""
    if(variables.currentFilePos < variables.totalNumberImagesCurrentFolder-1)
        return variables.allFilesCurrentDir[variables.currentFilePos +1]
    return variables.allFilesCurrentDir[variables.currentFilePos -1]
}

// After setting a filter, make sure the displayed image matches the set filter
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

// Load the next image in the folder
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

// Load the previous image in the folder
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

// Jump to the first image in the folder
function loadFirst() {
    if(variables.filterNoMatch || variables.deleteNothingLeft) return
    loadFile(variables.allFilesCurrentDir[0], variables.filter)
}

// Jump to the last image in the folder
function loadLast() {
    if(variables.filterNoMatch || variables.deleteNothingLeft) return
    loadFile(variables.allFilesCurrentDir[variables.allFilesCurrentDir.length -1], variables.filter)
}
