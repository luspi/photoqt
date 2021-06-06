/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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

function checkComboForShortcut(combo) {

    // if in viewer mode, pressing 'Escape' exits viewer mode
    if(combo == "Escape" && (filefoldermodel.isPQT || filefoldermodel.isARC)) {
        labels.exitViewerMode()
        return
    }

    for(var i = 0; i < variables.shortcuts.length; ++i) {

        if(variables.shortcuts[i][1] === combo) {
            whatToDoWithFoundShortcut(variables.shortcuts[i])
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
    else if(cmd === "__settings")
        loader.show("settingsmanager")
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
    else if(cmd === "__hideMeta")
        loader.metadataPassOn("toggleKeepOpen", undefined)
    else if(cmd === "__goToFirst")
        imageitem.loadFirstImage()
    else if(cmd === "__goToLast")
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
        handlingExternal.openInDefaultFileManager(filefoldermodel.currentFilePath)
    else if(cmd === "__histogram") {
        loader.ensureItIsReady("histogram")
        PQSettings.histogram = !PQSettings.histogram
    }
    else if(cmd === "__clipboard")
        handlingExternal.copyToClipboard(filefoldermodel.currentFilePath)
    else if(cmd === "__tagFaces")
        loader.passOn("facetagger", "start", undefined)
    else {
        handlingShortcuts.executeExternalApp(cmd, filefoldermodel.currentFilePath)
        if(close === "1")
            toplevel.closePhotoQt()
    }

}
