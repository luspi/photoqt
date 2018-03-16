/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
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

// Load a file. The third paramater is optional, if not provided it is assumed to be false
function loadFile(filename, filter, forceReloadDirectory) {

    verboseMessage("handlstuff.js","loadFile(): "+ filename + " / " + filter + " / " + forceReloadDirectory)

    // Make sure a file is actually loaded
    if(filename === undefined || filename == "")
        return

    if(forceReloadDirectory && ((filename.substring(0,1) != "/" && !getanddostuff.amIOnWindows()) || (filename.substring(1,3) != ":/" && getanddostuff.amIOnWindows())))
        filename = variables.currentDir + "/" + filename

    // Load a file from full path
    if((filename.substring(0,1) == "/" && !getanddostuff.amIOnWindows()) || (filename.substring(1,3) == ":/" && getanddostuff.amIOnWindows())) {

        // Separate filename and path
        var filenameonly = getanddostuff.removePathFromFilename(filename)
        var pathonly = getanddostuff.removeFilenameFromPath(filename)

        if((getanddostuff.doesStringEndsWith(filenameonly, ".pdf") || getanddostuff.doesStringEndsWith(filenameonly, ".epdf")) && filenameonly.indexOf("__::pqt::__") == -1) {
            var tot = getanddostuff.getTotalNumberOfPagesOfPdf(pathonly + "/" + filenameonly)
            filenameonly = filenameonly.replace(".pdf", "__::pqt::__0__" + tot + ".pdf")
            filenameonly = filenameonly.replace(".epdf", "__::pqt::__0__" + tot + ".epdf")
        }

        // If it's a new path or a forced reload, load folder contents and set up thumbnails (if enabled)
        if(filenameonly == "" || pathonly != variables.currentDir || (forceReloadDirectory !== undefined && forceReloadDirectory)) {
            variables.allFilesCurrentDir = getanddostuff.getAllFilesIn(filename, 0, filter, false, settings.sortby, settings.sortbyAscending, false, true, settings.pdfSingleDocument)
            variables.totalNumberImagesCurrentFolder = variables.allFilesCurrentDir.length
            variables.currentDir = pathonly
            variables.currentFile = filenameonly
            // If no filename is available (e.g., when a directory was passed on during startup ...
            if(filenameonly == "") {
                // ... and if there are images in the current folder then load the first one ...
                if(variables.totalNumberImagesCurrentFolder > 0) {
                    filenameonly = variables.allFilesCurrentDir[0]
                    variables.currentFile = filenameonly
                // ... else show the open file element (by design will open at current folder as variables.currentDir is set above)
                } else {
                    call.show("openfile")
                    return
                }
            }
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

    // Set the image and load the metadata
    var src = variables.currentDir + "/" + variables.currentFile
    var anim = getanddostuff.isImageAnimated(src)
    var prefix = (anim ? "file://" : "image://full/")

    if(variables.currentFile != "") {
        imageitem.loadImage(prefix + src, anim)
        metadata.setData(getmetadata.getExiv2(src))
        watcher.setCurrentImageForWatching(src);
        getanddostuff.saveLastOpenedImage(src)
    } else {
        call.show("openfile")
        call.load("openfileNavigateToCurrentDir")
    }

}

// After deleting an image, we need to figure out the new filename to be displayed (if any left)
function getNewFilenameAfterDeletion() {

    verboseMessage("handlstuff.js","getNewFilenameAfterDeletion(): " + variables.totalNumberImagesCurrentFolder + " / " + variables.currentFilePos)

    if(variables.totalNumberImagesCurrentFolder == 1)
        return ""
    if(variables.currentFilePos < variables.totalNumberImagesCurrentFolder-1)
        return variables.allFilesCurrentDir[variables.currentFilePos +1]
    return variables.allFilesCurrentDir[variables.currentFilePos -1]
}

// After setting a filter, make sure the displayed image matches the set filter
function getFilenameMatchingFilter(filter) {

    verboseMessage("handlstuff.js","getFilenameMatchingFilter(): " + filter)

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

    verboseMessage("handlstuff.js","loadNext(): " + variables.filterNoMatch + " / " + variables.deleteNothingLeft)

    if(variables.filterNoMatch || variables.deleteNothingLeft) return

    // We need to use a temp variable, otherwise wrapping the end of the images around to the beginning wont work!
    var loadpos = variables.currentFilePos
    if(loadpos == variables.allFilesCurrentDir.length-1 && !settings.loopThroughFolder)
        return
    else if(loadpos == variables.allFilesCurrentDir.length-1)
        loadpos = 0
    else
        loadpos += 1
    loadFile(variables.allFilesCurrentDir[loadpos], variables.filter)
}

// Load the previous image in the folder
function loadPrev() {

    verboseMessage("handlstuff.js","loadPrev(): " + variables.filterNoMatch + " / " + variables.deleteNothingLeft)

    if(variables.filterNoMatch || variables.deleteNothingLeft) return

    // We need to use a temp variable, otherwise wrapping the beginning of the images around to the end wont work!
    var loadpos = variables.currentFilePos
    if(loadpos <= 0 && !settings.loopThroughFolder)
        return
    else if(loadpos <= 0)
        loadpos = variables.allFilesCurrentDir.length-1
    else
        loadpos -= 1
    loadFile(variables.allFilesCurrentDir[loadpos], variables.filter)
}

// Jump to the first image in the folder
function loadFirst() {
    verboseMessage("handlstuff.js","loadFirst(): " + variables.filterNoMatch + " / " + variables.deleteNothingLeft)
    if(variables.filterNoMatch || variables.deleteNothingLeft) return
    loadFile(variables.allFilesCurrentDir[0], variables.filter)
}

// Jump to the last image in the folder
function loadLast() {
    verboseMessage("handlstuff.js","loadLast(): " + variables.filterNoMatch + " / " + variables.deleteNothingLeft)
    if(variables.filterNoMatch || variables.deleteNothingLeft) return
    loadFile(variables.allFilesCurrentDir[variables.allFilesCurrentDir.length -1], variables.filter)
}

function checkIfClickOnEmptyArea(prsd, rlsd) {

    verboseMessage("handlstuff.js","checkIfClickOnEmptyArea(): " + prsd.x + " / " + prsd.y + " // " + rlsd.x + " / " + rlsd.y)

    var dx = prsd.x-rlsd.x
    var dy = prsd.y-rlsd.y

    if(dx > 50 || dy > 50 || !settings.closeOnEmptyBackground)
        return

    imageitem.checkClickOnEmptyArea((prsd.x+rlsd.x)/2, (prsd.y+rlsd.y)/2)

}
