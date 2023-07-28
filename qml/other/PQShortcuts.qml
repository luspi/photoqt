/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

import QtQuick 2.9
import QtQml 2.0

import PQCShortcuts
import PQCNotify

Item {

    id: keyshortcuts_top

    anchors.fill: parent

    focus: true

    Connections {

        target: PQCNotify

        function onKeyPress(key, modifiers) {

//            contextmenu.hideMenu()

            if(loader.numVisible > 0)

                loader.passOn("keyEvent", [key, modifiers])

            else {

                var combo = ""

                if(modifiers & Qt.ControlModifier)
                    combo += "Ctrl+";
                if(modifiers & Qt.AltModifier)
                    combo += "Alt+";
                if(modifiers & Qt.ShiftModifier)
                    combo += "Shift+";
                if(modifiers & Qt.MetaModifier)
                    combo += "Meta+";
                if(modifiers & Qt.KeypadModifier)
                    combo += "Keypad+";

                // this seems to be the id when a modifier but no key is pressed... ignore key in that case
                if(key !== 16777249)
                    combo += PQCShortcuts.convertKeyCodeToText(key)

                checkComboForShortcut(combo)

            }

        }

    }

    function checkComboForShortcut(combo, wheelDelta) {

        // if in viewer mode, pressing 'Escape' exits viewer mode
//        if(combo === "Escape" && (filefoldermodel.isPQT || filefoldermodel.isARC)) {
//            statusinfo.exitViewerMode()
//            return
//        }

//        if(combo === "Escape" && contextmenu.isOpen) {
//            contextmenu.hideMenu()
//            return
//        }

//        if(combo === "Escape" && filefoldermodel.filterCurrentlyActive) {
//            loader.passOn("filter", "removeFilter", undefined)
//            return
//        }

        var data = PQCShortcuts.getCommandsForShortcut(combo)

        if(data.length !== 4)
            return

        var commands = data[0]
        var cycle = data[1]*1
        var cycletimeout = data[2]*1
        var simultaneous = data[3]*1

        if(simultaneous == 1) {

            for(var c in commands) {
                var cmd = commands[c]
                if(cmd[0] === "_" && cmd[1] === "_")
                    executeInternalFunction(cmd, wheelDelta)
                else {
//                    if(filefoldermodel.countMainView === 0)
//                        return
//                    var parts = cmd.split(":/:/:")
//                    if(parts.length !== 3)
//                        return
//                    handlingExternal.executeExternal(parts[0], parts[1], filefoldermodel.currentFilePath)
//                    if(parts[2]*1 === 1)
//                        toplevel.closePhotoQt()
                }
            }

        } else {

            var index = PQCShortcuts.getNextCommandInCycle(combo, cycletimeout, commands.length)
            var curcmd = commands[index]
            if(curcmd[0] === "_" && curcmd[1] === "_")
                executeInternalFunction(curcmd, wheelDelta)
            else {
//                if(filefoldermodel.countMainView === 0)
//                    return
//                var curparts = curcmd.split(":/:/:")
//                if(curparts.length !== 3)
//                    return
//                handlingExternal.executeExternal(curparts[0], curparts[1], filefoldermodel.currentFilePath)
//                if(curparts[2]*1 === 1)
//                    toplevel.closePhotoQt()
            }

        }

    }

    function executeInternalFunction(cmd, wheelDelta) {

        console.debug("args: cmd =", cmd)
        console.debug("args: wheelDelta =", wheelDelta)

        // elements
        if(cmd === "__open")
            loader.show("filedialog")

        // interface functions
        else if(cmd === "__quit")
            PQClosing.quitPhotoQt()

        // image functions
        else if(cmd === "__next")
            image.showNext()
        else if(cmd === "__prev")
            image.showPrev()
        else if(cmd === "__zoomIn")
            image.zoomIn()
        else if(cmd === "__zoomOut")
            image.zoomOut()
        else if(cmd === "__zoomReset")
            image.zoomReset()
        else if(cmd === "__zoomActual")
            image.zoomActual()
        else if(cmd === "__rotateL")
            image.rotateAntiClock()
        else if(cmd === "__rotateR")
            image.rotateClock()
        else if(cmd === "__rotate0")
            image.rotateReset()
        else if(cmd === "__flipH")
            image.mirrorH()
        else if(cmd === "__flipV")
            image.mirrorV()

//        else if(cmd === "__close")
//            toplevel.closePhotoQt()
//        else if(cmd === "__settings")
//            loader.show("settingsmanager")
//        else if(cmd === "__loadRandom")
//            imageitem.loadRandomImage()
//        else if(cmd == "__contextMenu")
//            contextmenu.showMenu()
//        else if(cmd === "__about")
//            loader.show("about")
//        else if(cmd === "__slideshow")
//            loader.show("slideshowsettings")
//        else if(cmd === "__filterImages")
//            loader.show("filter")
//        else if(cmd === "__slideshowQuick") {
//            loader.ensureItIsReady("slideshowcontrols")
//            loader.passOn("slideshowcontrols", "start", undefined)
//        else if(cmd === "__flipReset")
//            imageitem.mirrorReset()
//        else if(cmd === "__rename")
//            loader.show("filerename")
//        else if(cmd === "__delete")
//            loader.show("filedelete")
//        else if(cmd === "__copy") {
//            loader.ensureItIsReady("copymove")
//            loader.passOn("copymove", "copy", undefined)
//        } else if(cmd === "__move") {
//            loader.ensureItIsReady("copymove")
//            loader.passOn("copymove", "move", undefined)
//        } else if(cmd === "__deletePermanent") {
//            if(filefoldermodel.current != -1)
//                handlingFileDir.deleteFile(filefoldermodel.currentFilePath, true)
//        } else if(cmd === "__deleteTrash") {
//            if(filefoldermodel.current != -1)
//                handlingFileDir.deleteFile(filefoldermodel.currentFilePath, false)
//        } else if(cmd === "__saveAs")
//            loader.show("filesaveas")
//        else if(cmd === "__showMetaData" || cmd == "__keepMetaData")
//            loader.metadataPassOn("toggleKeepOpen", undefined)
//        else if(cmd === "__showMainMenu")
//            loader.mainmenuPassOn("toggle", undefined)
//        else if(cmd === "__showThumbnails")
//            thumbnails.toggle()
//        else if(cmd === "__navigationFloating") {
//            loader.ensureItIsReady("navigationfloating")
//            PQSettings.interfaceNavigationFloating = !PQSettings.interfaceNavigationFloating
//        } else if(cmd === "__goToFirst")
//            imageitem.loadFirstImage()
//        else if(cmd === "__goToLast")
//            imageitem.loadLastImage()
//        else if(cmd === "__viewerMode")
//            statusinfo.toggleViewerMode()
//        else if(cmd === "__showFaceTags")
//            PQSettings.metadataFaceTagsEnabled = !PQSettings.metadataFaceTagsEnabled
//        else if(cmd === "__wallpaper")
//            loader.show("wallpaper")
//        else if(cmd === "__scale")
//            loader.show("scale")
//        else if(cmd === "__playPauseAni")
//            imageitem.playPauseAnimation()
//        else if(cmd === "__imgur")
//            loader.show("imgur")
//        else if(cmd === "__imgurAnonym")
//            loader.show("imguranonym")
//        else if(cmd === "__defaultFileManager")
//            handlingExternal.openInDefaultFileManager(filefoldermodel.currentFilePath)
//        else if(cmd === "__histogram") {
//            loader.ensureItIsReady("histogram")
//            PQSettings.histogramVisible = !PQSettings.histogramVisible
//        }
//        else if(cmd === "__clipboard")
//            handlingExternal.copyToClipboard(filefoldermodel.currentFilePath)
//        else if(cmd === "__tagFaces")
//            loader.passOn("facetagger", "start", undefined)
//        else if(cmd === "__chromecast") {
//            loader.show("chromecast")
//        } else if(cmd === "__logging")
//            loader.show("logging")
//        else if(cmd === "__print")
//            printsupport.printFile(filefoldermodel.currentFilePath)
//        else if(cmd == "__advancedSort")
//            loader.show("advancedsort")
//        else if(cmd == "__advancedSortQuick") {
//            loader.show("advancedsortbusy")
//            filefoldermodel.advancedSortMainView()
//        } else if(cmd == "__onlineHelp")
//            Qt.openUrlExternally("https://photoqt.org/man")
//        else if(cmd == "__fullscreenToggle")
//            PQSettings.interfaceWindowMode = !PQSettings.interfaceWindowMode
//        else if(cmd == "__fitInWindow")
//            PQSettings.imageviewFitInWindow = !PQSettings.imageviewFitInWindow
//        else if(cmd == "__toggleAlwaysActualSize")
//            PQSettings.imageviewAlwaysActualSize = !PQSettings.imageviewAlwaysActualSize
//        else if(cmd == "__resetSession" || cmd == "__resetSessionAndHide") {
//            toplevel.resetPhotoQt()
//            if(cmd == "__resetSessionAndHide") {
//                if(PQSettings.interfaceTrayIcon == 0)
//                    PQSettings.interfaceTrayIcon = 1
//                toplevel.closePhotoQt()
//            }
//        } else if(cmd == "__moveViewLeft")
//            imageitem.moveViewLeft()
//        else if(cmd == "__moveViewRight")
//            imageitem.moveViewRight()
//        else if(cmd == "__moveViewUp")
//            imageitem.moveViewUp()
//        else if(cmd == "__moveViewDown")
//            imageitem.moveViewDown()
//        else if(cmd == "__goToLeftEdge")
//            imageitem.goToLeftEdge()
//        else if(cmd == "__goToRightEdge")
//            imageitem.goToRightEdge()
//        else if(cmd == "__goToTopEdge")
//            imageitem.goToTopEdge()
//        else if(cmd == "__goToBottomEdge")
//            imageitem.goToBottomEdge()
//        else if(cmd == "__showMapCurrent") {
//            if(handlingGeneral.isLocationSupportEnabled()) {
//                loader.ensureItIsReady("mapcurrent")
//                PQSettings.mapviewCurrentVisible = !PQSettings.mapviewCurrentVisible
//            }
//        } else if(cmd == "__showMapExplorer") {
//            if(handlingGeneral.isLocationSupportEnabled())
//                loader.show("mapexplorer")
//        }
    }


}
