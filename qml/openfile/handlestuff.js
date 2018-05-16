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

function loadDirectory() {

    if(openvariables.currentDirectory == "") return

    verboseMessage("OpenFile/handlestuff.js", "loadDirectory()")

    // If current directory is not loaded from history -> adjust history
    if(openvariables.loadedFromHistory)
        openvariables.loadedFromHistory = false
    else
        addToHistory()

    loadDirectoryBreadCrumbs()

    loadDirectoryFolders()

    loadDirectoryFiles()

}

function loadDirectoryBreadCrumbs() {

    verboseMessage("OpenFile/handlestuff.js", "loadDirectoryBreadCrumbs()")

    /**********************************************************/
    // BREAD CRUMBS
    ///////////////

    var parts = openvariables.currentDirectory.split("/")
    var partialpath = ""

    breadcrumbs.modelForCrumbs.clear()

    // On Windows, the root directory is the drive letter, not a seperator
    if(openvariables.currentDirectory === "/" && !getanddostuff.amIOnWindows())
        breadcrumbs.modelForCrumbs.append({"type" : "separator", "location" : "/", "partialpath" : "/"})
    else {
        for(var i = 0; i < parts.length; ++i) {
            if(parts[i] === "") continue;
            if(parts[i] === "..") {
                var l = breadcrumbs.modelForCrumbs.count
                breadcrumbs.modelForCrumbs.remove(l-1)
                breadcrumbs.modelForCrumbs.remove(l-2)
                partialpath += "/" + parts[i]
            } else {
                // On Windows, the path starts with the drive letter, not a seperator
                if(!getanddostuff.amIOnWindows() || i != 0) {
                    partialpath += "/"
                    breadcrumbs.modelForCrumbs.append({"type" : "separator", "location" : parts[i], "partialpath" : partialpath})
                }
                partialpath += parts[i]
                breadcrumbs.modelForCrumbs.append({"type" : "folder", "location" : parts[i], "partialpath" : partialpath + "/"})
                // On Windows, if the path consists only of the drive letter, we add a slash behind (looks better)
                if(parts.length === 2 && getanddostuff.amIOnWindows()) {
                    partialpath += "/"
                    breadcrumbs.modelForCrumbs.append({"type" : "separator", "location" : parts[i], "partialpath" : partialpath})
                }
            }
        }
    }

    if(breadcrumbs.modelForCrumbs.count == 0)
        breadcrumbs.modelForCrumbs.append({"type" : "separator", "location" : "/", "partialpath" : "/"})

    breadcrumbs.viewForCrumbs.positionViewAtEnd()

}

function loadDirectoryFolders() {

    verboseMessage("OpenFile/handlestuff.js", "loadDirectoryFolders()")

    /**********************************************************/
    // FOLDERS
    ///////////////

    folders.folderListView.model.clear()

    // On Linux the filenames start with a slash '/', on Windows with the drive letter followed by ':/'
    if((openvariables.currentDirectory.substring(0,1) != "/" && !getanddostuff.amIOnWindows()) ||
            (openvariables.currentDirectory.substring(1,3) != ":/" && getanddostuff.amIOnWindows())) {
        folders.showUnsupportedProtocolFolderMessage = true
        return
    }

    folders.showUnsupportedProtocolFolderMessage = false

    openvariables.currentDirectoryFolders = getanddostuff.getFoldersIn(openvariables.currentDirectory, true, settings.openShowHiddenFilesFolders)

    for(var j = 0; j < openvariables.currentDirectoryFolders.length; ++j)
        folders.folderListView.model.append({"folder" : openvariables.currentDirectoryFolders[j],
                                             "path" : openvariables.currentDirectory+"/"+openvariables.currentDirectoryFolders[j],
                                             "icon" : "folder",
                                             "id" : "",
                                             "hidden" : "false",
                                             "systemitem" : "",
                                             "notvisible" : "0"})

}

function loadDirectoryFiles() {

    verboseMessage("OpenFile/handlestuff.js", "loadDirectoryFiles()")

    filesview.filesViewModel.clear()

    // On Linux the filenames start with a slash '/', on Windows with the drive letter followed by ':/'
    if((openvariables.currentDirectory.substring(0,1) != "/" && !getanddostuff.amIOnWindows()) ||
            (openvariables.currentDirectory.substring(1,3) != ":/" && getanddostuff.amIOnWindows())) {
        filesview.showUnsupportedProtocolFolderMessage = true
        return
    }
    filesview.showUnsupportedProtocolFolderMessage = false

    openvariables.currentDirectoryFiles = getanddostuff.getAllFilesIn(openvariables.currentDirectory,
                                                                      openvariables.filesFileTypeCategorySelected,
                                                                      "",
                                                                      settings.openShowHiddenFilesFolders,
                                                                      settings.sortby,
                                                                      settings.sortbyAscending,
                                                                      true, false, false, false, false, false)

    filesview.filesView.contentY = 0
    for(var j = 0; j < openvariables.currentDirectoryFiles.length; j+=2)
        filesview.filesViewModel.append({"filename" : openvariables.currentDirectoryFiles[j], "filesize" : openvariables.currentDirectoryFiles[j+1]})

}

function loadUserPlaces() {

    verboseMessage("OpenFile/handlestuff.js", "loadUserPlaces()")

    var up = getanddostuff.getUserPlaces()

    userplaces.userPlacesModel.clear()

    // for the heading
    userplaces.userPlacesModel.append({"folder" : "",
                                       "path" : "",
                                       "icon" : "",
                                       "id" : "",
                                       "hidden" : "",
                                       "systemitem" : "",
                                       "notvisible" : "0"})

    for(var i = 0; i < up.length; i+=6)
        userplaces.userPlacesModel.append({"folder" : up[i],
                                           "path" : up[i+1],
                                           "icon" : up[i+2],
                                           "id" : up[i+3],
                                           "hidden" : up[i+4],
                                           "systemitem" : up[i+5],
                                           "notvisible" : "0"})

    userplaces.userPlacesView.currentIndex = 1
}

function saveUserPlaces() {

    verboseMessage("OpenFile/handlestuff.js", "saveUserPlaces()")

    var ret = [[]]

    for(var i = 1; i < userplaces.userPlacesModel.count; ++i) {
        var path = userplaces.userPlacesModel.get(i).path
        if(path[0] == "/")
            path = "file://" + path
        ret.push([userplaces.userPlacesModel.get(i).folder, path, userplaces.userPlacesModel.get(i).icon,
                  userplaces.userPlacesModel.get(i).id, userplaces.userPlacesModel.get(i).hidden, userplaces.userPlacesModel.get(i).systemitem])
    }

    getanddostuff.saveUserPlaces(ret);

}

function loadStorageInfo() {

    verboseMessage("OpenFile/handlestuff.js", "loadStorageInfo()")

    var s = getanddostuff.getStorageInfo()

    userplaces.storageInfoModel.clear()

    // for the heading
    userplaces.storageInfoModel.append({"name" : "",
                                       "location" : "",
                                       "filesystemtype" : "",
                                       "icon" : ""})

    for(var i = 0; i < s.length; i+=4) {

        var name = s[i]
        var size = Math.round(s[i+1]/1024/1024/1024 +1);
        var filesystemtype = s[i+2]
        var path = s[i+3]

        userplaces.storageInfoModel.append({"name" : name,
                                            "size" : size,
                                            "location" : path,
                                            "filesystemtype" : filesystemtype,
                                            "icon" : "drive-harddisk"})

    }

}

// Add to history
function addToHistory() {

    verboseMessage("OpenFile/handlestuff.js", "addToHistory()")

    // FIRST ITEM DOES NOT GET ADDED FOR SOME WEIRD REASON...???????!!

    // If current position is not the end of history -> cut off end part
    if(openvariables.historypos != openvariables.history.length-1)
        openvariables.history = openvariables.history.slice(0,openvariables.historypos+1);

    // Add path
    openvariables.history.push(openvariables.currentDirectory)
    ++openvariables.historypos;

}

// Go back in history, if we're not already at the beginning
function goBackInHistory() {
    verboseMessage("OpenFile/handlestuff.js", "goBackInHistory()")
    if(openvariables.historypos > 0) {
        --openvariables.historypos
        openvariables.loadedFromHistory = true
        openvariables.currentDirectory = openvariables.history[openvariables.historypos]
    }
}

// Go forwards in history, if we're not already at the end
function goForwardsInHistory() {
    verboseMessage("OpenFile/handlestuff.js", "goForwardsInHistory()")
    if(openvariables.historypos < openvariables.history.length-1) {
        ++openvariables.historypos
        openvariables.loadedFromHistory = true
        openvariables.currentDirectory = openvariables.history[openvariables.historypos]
    }
}
