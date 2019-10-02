Qt.include("../loadfiles.js")

function checkComboForShortcut(combo) {

    for(var i = 0; i < variables.shortcuts.length; ++i) {

        if(variables.shortcuts[i][1] === combo) {
            whatToDoWithFoundShortcut(variables.shortcuts[i])
            break;
        }

    }

}

function executeInternalFunction(func) {
    whatToDoWithFoundShortcut(["","",func])
}

function whatToDoWithFoundShortcut(sh) {

    var cmd = sh[2]
    var close = sh[0]

    if(cmd === "__quit")
        toplevel.quitPhotoQt()
    else if(cmd === "__close")
        toplevel.closePhotoQt()
//    else if(cmd === "__settings")
//        call.show("settingsmanager")
    else if(cmd === "__next")
        imageitem.loadNextImage()
    else if(cmd === "__prev")
        imageitem.loadPrevImage()
    else if(cmd === "__about")
        loader.show("about")
    else if(cmd === "__slideshow")
        loader.show("slideshowsettings")
    else if(cmd === "__filterImages")
        loader.show("filter")
    else if(cmd === "__slideshowQuick") {
        loader.ensureItIsReady("slideshowcontrols")
        loader.passOn("slideshowcontrols", "start", undefined)
    } else if(cmd === "__open")
        loader.show("filedialog")
    else if(cmd === "__zoomIn")
        imageitem.zoomIn()
    else if(cmd === "__zoomOut")
        imageitem.zoomOut()
    else if(cmd === "__zoomReset")
        imageitem.zoomReset()
    else if(cmd === "__zoomActual")
        imageitem.zoomActual()
    else if(cmd === "__rotateL")
        imageitem.rotate(-90)
    else if(cmd === "__rotateR")
        imageitem.rotate(90)
    else if(cmd === "__rotate0")
        imageitem.rotateReset()
    else if(cmd === "__flipH")
        imageitem.mirrorH()
    else if(cmd === "__flipV")
        imageitem.mirrorV()
    else if(cmd === "__flipReset")
        imageitem.mirrorReset()
    else if(cmd === "__rename")
        loader.show("filerename")
    else if(cmd === "__delete")
        loader.show("filedelete")
    else if(cmd === "__deletePermanent") {
        if(variables.indexOfCurrentImage != -1 && handlingFileManagement.deleteFile(variables.allImageFilesInOrder[variables.indexOfCurrentImage], true)) {
            removeCurrentFilenameFromList(variables.allImageFilesInOrder[variables.indexOfCurrentImage])
            thumbnails.reloadThumbnails()
        }
    } else if(cmd === "__deleteTrash") {
        if(variables.indexOfCurrentImage != -1 && handlingFileManagement.deleteFile(variables.allImageFilesInOrder[variables.indexOfCurrentImage], false)) {
            removeCurrentFilenameFromList(variables.allImageFilesInOrder[variables.indexOfCurrentImage])
            thumbnails.reloadThumbnails()
        }
    } else if(cmd === "__hideMeta")
        loader.passOn("metadata", "toggle", undefined)
    else if(cmd === "__gotoFirstThb")
        imageitem.loadFirstImage()
    else if(cmd === "__gotoLastThb")
        imageitem.loadLastImage()
    else if(cmd === "__wallpaper")
        loader.show("wallpaper")
    else if(cmd === "__scale")
        loader.show("scale")
    else if(cmd === "__playPauseAni")
        imageitem.playPauseAnimation()
    else if(cmd === "__imgur")
        loader.show("imgur")
    else if(cmd === "__imgurAnonym")
        loader.show("imguranonym")
    else if(cmd === "__defaultFileManager")
        handlingGeneral.openInDefaultFileManager(variables.allImageFilesInOrder[variables.indexOfCurrentImage])
    else if(cmd === "__histogram") {
        loader.ensureItIsReady("histogram")
        PQSettings.histogram = !PQSettings.histogram
    }
    else if(cmd === "__clipboard")
        handlingGeneral.copyToClipboard(variables.allImageFilesInOrder[variables.indexOfCurrentImage])
//    else if(cmd === "__tagFaces")
//        call.requestTagFaces()
    else {
        handlingShortcuts.executeExternalApp(cmd, variables.allImageFilesInOrder[variables.indexOfCurrentImage])
        if(close === "1")
            toplevel.closePhotoQt()
    }

}
