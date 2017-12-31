function loadDirectory() {

    // If current directory is not loaded from history -> adjust history
    if(openvariables.loadedFromHistory)
        openvariables.loadedFromHistory = false
    else
        addToHistory()

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

// Add to history
function addToHistory() {

    verboseMessage("BreadCrumbs::addToHistory()", openvariables.currentDirectory + " - " + openvariables.historypos + " - " + openvariables.history.length)

    // If current position is not the end of history -> cut off end part
    if(openvariables.historypos != openvariables.history.length-1)
        openvariables.history = openvariables.history.slice(0,openvariables.historypos+1);

    // Add path
    openvariables.history.push(openvariables.currentDirectory)
    ++openvariables.historypos;

}

// Go back in history, if we're not already at the beginning
function goBackInHistory() {
    verboseMessage("BreadCrumbs::goBackInHistory()", openvariables.historypos + " - " + openvariables.history.length)
    if(openvariables.historypos > 0) {
        --openvariables.historypos
        openvariables.loadedFromHistory = true
        openfile_top.currentDirectory = openvariables.history[openvariables.historypos]
    }
}

// Go forwards in history, if we're not already at the end
function goForwardsInHistory() {
    verboseMessage("BreadCrumbs::goForwardsInHistory()", openvariables.historypos + " - " + openvariables.history.length)
    if(openvariables.historypos < openvariables.history.length-1) {
        ++openvariables.historypos
        openvariables.loadedFromHistory = true
        openfile_top.currentDirectory = openvariables.history[openvariables.historypos]
    }
}
