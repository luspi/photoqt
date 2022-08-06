/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
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

function checkComboForShortcut(combo, wheelDelta) {

    // if in viewer mode, pressing 'Escape' exits viewer mode
    if(combo == "Escape" && (filefoldermodel.isPQT || filefoldermodel.isARC)) {
        labels.exitViewerMode()
        return
    }

    if(combo == "Escape" && contextmenu.visible) {
        contextmenu.hideMenu()
        return
    }

    whatToDoWithFoundShortcut(PQShortcuts.getCommandForShortcut(combo), wheelDelta)

}

function executeInternalFunction(func) {
    whatToDoWithFoundShortcut(["",func])
}

function whatToDoWithFoundShortcut(sh, wheelDelta) {

    var close = sh[0]
    var cmd = sh[1]

    if(cmd === "__quit")
        toplevel.quitPhotoQt()
    else if(cmd === "__close")
        toplevel.closePhotoQt()
    else if(cmd === "__settings")
        loader.show("settingsmanager")
    else if(cmd === "__next")
        imageitem.loadNextImage()
    else if(cmd === "__prev")
        imageitem.loadPrevImage()
    else if(cmd == "__contextMenu")
        contextmenu.showMenu()
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
        imageitem.zoomIn(wheelDelta)
    else if(cmd === "__zoomOut")
        imageitem.zoomOut(wheelDelta)
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
    else if(cmd === "__copy") {
        loader.ensureItIsReady("copymove")
        loader.passOn("copymove", "copy", undefined)
    } else if(cmd === "__move") {
        loader.ensureItIsReady("copymove")
        loader.passOn("copymove", "move", undefined)
    } else if(cmd === "__deletePermanent") {
        if(filefoldermodel.current != -1)
            handlingFileDir.deleteFile(filefoldermodel.currentFilePath, true)
    } else if(cmd === "__deleteTrash") {
        if(filefoldermodel.current != -1)
            handlingFileDir.deleteFile(filefoldermodel.currentFilePath, false)
    } else if(cmd === "__saveAs")
        loader.show("filesaveas")
    else if(cmd === "__showMetaData")
        loader.metadataPassOn("toggle", undefined)
    else if(cmd === "__keepMetaData")
        loader.metadataPassOn("toggleKeepOpen", undefined)
    else if(cmd === "__showMainMenu")
        loader.mainmenuPassOn("toggle", undefined)
    else if(cmd === "__showThumbnails")
        thumbnails.toggle()
    else if(cmd === "__navigationFloating") {
        loader.ensureItIsReady("navigationfloating")
        PQSettings.interfaceNavigationFloating = !PQSettings.interfaceNavigationFloating
    } else if(cmd === "__goToFirst")
        imageitem.loadFirstImage()
    else if(cmd === "__goToLast")
        imageitem.loadLastImage()
    else if(cmd === "__viewerMode")
        labels.toggleViewerMode()
    else if(cmd === "__showFaceTags")
        PQSettings.metadataFaceTagsEnabled = !PQSettings.metadataFaceTagsEnabled
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
        handlingExternal.openInDefaultFileManager(filefoldermodel.currentFilePath)
    else if(cmd === "__histogram") {
        loader.ensureItIsReady("histogram")
        PQSettings.histogramVisible = !PQSettings.histogramVisible
    }
    else if(cmd === "__clipboard")
        handlingExternal.copyToClipboard(filefoldermodel.currentFilePath)
    else if(cmd === "__tagFaces")
        loader.passOn("facetagger", "start", undefined)
    else if(cmd === "__chromecast") {
        if(handlingGeneral.isChromecastEnabled())
            loader.show("chromecast")
    } else if(cmd === "__logging")
        loader.show("logging")
    else if(cmd === "__print")
        printsupport.printFile(filefoldermodel.currentFilePath)
    else if(cmd == "__advancedSort")
        loader.show("advancedsort")
    else if(cmd == "__advancedSortQuick") {
        loader.show("advancedsortbusy")
        filefoldermodel.advancedSortMainView()
    } else if(cmd == "__onlineHelp")
        Qt.openUrlExternally("https://photoqt.org/man")
    else if(cmd == "__fullscreenToggle") {
        PQSettings.interfaceWindowMode = !PQSettings.interfaceWindowMode
    } else {
        handlingExternal.executeExternal(cmd, filefoldermodel.currentFilePath)
        if(close === "1")
            toplevel.closePhotoQt()
    }

}
