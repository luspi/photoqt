function loadDirectory() {

    if(openvariables.currentDirectory == "") return

    // If current directory is not loaded from history -> adjust history
    if(openvariables.loadedFromHistory)
        openvariables.loadedFromHistory = false
    else
        addToHistory()

    loadDirectoryBreadCrumbs()

    loadDirectoryFolders()

}

function loadDirectoryBreadCrumbs() {

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

    /**********************************************************/
    // FOLDERS
    ///////////////

    folders.folderlistview.model.clear()
    openvariables.currentDirectoryFolders = getanddostuff.getFoldersIn(openvariables.currentDirectory, true, settings.openShowHiddenFilesFolders)

    for(var j = 0; j < openvariables.currentDirectoryFolders.length; ++j)
        folders.folderlistview.model.append({"folder" : openvariables.currentDirectoryFolders[j],
                                             "path" : openvariables.currentDirectory+"/"+openvariables.currentDirectoryFolders[j],
                                             "counter" : getanddostuff.getNumberFilesInFolder(openvariables.currentDirectory
                                                                                              + "/"
                                                                                              + openvariables.currentDirectoryFolders[j], 0), // tweaks.getFileTypeSelection()),
                                             "icon" : "folder",
                                             "id" : "",
                                             "hidden" : "false",
                                             "systemitem" : ""})

}

function loadUserPlaces() {

    var up = getanddostuff.getUserPlaces()

    userplaces.userPlacesModel.clear()

    // for the heading
    userplaces.userPlacesModel.append({"folder" : "",
                                       "path" : "",
                                       "icon" : "",
                                       "id" : "",
                                       "hidden" : "",
                                       "systemitem" : ""})

    for(var i = 0; i < up.length; i+=6)
        userplaces.userPlacesModel.append({"folder" : up[i],
                                           "path" : up[i+1],
                                           "icon" : up[i+2],
                                           "id" : up[i+3],
                                           "hidden" : up[i+4],
                                           "systemitem" : up[i+5]})
}

function saveUserPlaces() {

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

    var s = getanddostuff.getStorageInfo()

    for(var i = 0; i < s.length; i+=4) {
        var name = s[i]
        var size = Math.round(s[i+1]/1024/1024/1024 +1);
        var filesystemtype = s[i+2]
        var path = s[i+3]

        if(name == "")
            name = ""+size+" GB device"
        name += " (" + filesystemtype + ")"

        userplaces.storageInfoModel.append({"name" : name,
                                            "location" : path,
                                            "icon" : "drive-harddisk"})

    }

}

// Add to history
function addToHistory() {

    verboseMessage("BreadCrumbs::addToHistory()", openvariables.currentDirectory + " - " + openvariables.historypos + " - " + openvariables.history.length)

    // FIRST ITEM DOES NOT GET ADDED FOR SOME WEIRD REASON...???????!!

    // If current position is not the end of history -> cut off end part
//    if(openvariables.historypos != openvariables.history.length-1)
//        openvariables.history = openvariables.history.slice(0,openvariables.historypos+1);

    // Add path
    console.log(openvariables.history[openvariables.history.length-1], "followed by", openvariables.currentDirectory)
    openvariables.history.push(openvariables.currentDirectory)
    ++openvariables.historypos;

}

// Go back in history, if we're not already at the beginning
function goBackInHistory() {
    verboseMessage("BreadCrumbs::goBackInHistory()", openvariables.historypos + " - " + openvariables.history.length)
    if(openvariables.historypos > 0) {
        --openvariables.historypos
        openvariables.loadedFromHistory = true
        openvariables.currentDirectory = openvariables.history[openvariables.historypos]
        console.log("reverting to",openvariables.history[openvariables.historypos])
    }
}

// Go forwards in history, if we're not already at the end
function goForwardsInHistory() {
    verboseMessage("BreadCrumbs::goForwardsInHistory()", openvariables.historypos + " - " + openvariables.history.length)
    if(openvariables.historypos < openvariables.history.length-1) {
        ++openvariables.historypos
        openvariables.loadedFromHistory = true
        openvariables.currentDirectory = openvariables.history[openvariables.historypos]
    }
}
