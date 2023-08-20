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

        function onExecuteInternalCommand(cmd) {
            executeInternalFunction(cmd)
        }

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

        function onMouseWheel(angleDelta, modifiers) {

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

            if(combo == "" && PQCSettings.imageviewUseMouseWheelForImageMove)
                return

            if(Math.abs(angleDelta.x) < 2) {
                if(angleDelta.y < 0)
                    combo += "Wheel Down"
                else if(angleDelta.y > 0)
                    combo += "Wheel Up"
            } else {
                if(angleDelta.x < 0)
                    combo += "Wheel Left"
                else if(angleDelta.x > 0)
                    combo += "Wheel Right"
            }

            checkComboForShortcut(combo)

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

        switch(cmd) {

            /**********************/
            // elements

            case "__open":
                loader.show("filedialog")
                break
//            case "__showMapExplorer":
//                break
//            case "__settings":
//                break
//            case "__about":
//                break
//            case "__slideshow":
//                break
//            case "__slideshowQuick":
//                break
//            case "__filterImages":
//                break
//            case "__wallpaper":
//                break
//            case "__scale":
//                break
//            case "__imgur":
//                break
//            case "__imgurAnonym":
//                break
//            case "__tagFaces":
//                break
//            case "__chromecast":
//                break
//            case "__logging":
//                break
//            case "__advancedSort":
//                break
//            case "__advancedSortQuick":
//                break

            /**********************/
            // elements (ongoing)

//            case "__contextMenu":
//                break
            case "__showMetaData":
            case "__keepMetaData":
                PQCSettings.metadataElementVisible = !PQCSettings.metadataElementVisible
                break
//            case "__showMainMenu":
//                break
//            case "__showThumbnails":
//                break


            /**********************/
            // interface functions

            case "__quit":
                toplevel.quitPhotoQt()
                break
//            case "__close":
//                break
//            case "__fullscreenToggle":
//                PQCSettings.interfaceWindowMode = !PQCSettings.interfaceWindowMode
//                break

            /**********************/
            // navigation

            case "__next":
                image.showNext()
                break
            case "__prev":
                image.showPrev()
                break
            case "__goToFirst":
                image.showFirst()
                break
            case "__goToLast":
                image.showLast()
                break
//            case "__loadRandom":
//                break
//            case "__viewerMode":
//                break
//            case "__navigationFloating":
//                break
//            case "__moveViewLeft":
//                break
//            case "__moveViewRight":
//                break
//            case "__moveViewUp":
//                break
//            case "__moveViewDown":
//                break
//            case "__goToLeftEdge":
//                break
//            case "__goToRightEdge":
//                break
//            case "__goToTopEdge":
//                break
//            case "__goToBottomEdge":
//                break

            /**********************/
            // image functions

            case "__zoomIn":
                image.zoomIn()
                break
            case "__zoomOut":
                image.zoomOut()
                break
            case "__zoomReset":
                image.zoomReset()
                break
            case "__zoomActual":
                image.zoomActual()
                break
            case "__rotateL":
                image.rotateAntiClock()
                break
            case "__rotateR":
                image.rotateClock()
                break
            case "__rotate0":
                image.rotateReset()
                break
            case "__flipH":
                image.mirrorH()
                break
            case "__flipV":
                image.mirrorV()
                break
//            case "__flipReset":
//                break
//            case "__histogram":
//                break
//            case "__fitInWindow":
//                PQCSettings.imageviewFitInWindow = !PQCSettings.imageviewFitInWindow
//                break
//            case "__playPauseAni":
//                break
//            case "__showFaceTags":
//                break
//            case "__showMapCurrent":
//                break
//            case "__toggleAlwaysActualSize":
//                PQCSettings.imageviewAlwaysActualSize = !PQCSettings.imageviewAlwaysActualSize
//                break

            /**********************/
            // file actions

//            case "__rename":
//                break
//            case "__delete":
//                break
//            case "__copy":
//                break
//            case "__move":
//                break
//            case "__deletePermanent":
//                break
//            case "__deleteTrash":
//                break
//            case "__saveAs":
//                break
//            case "__defaultFileManager":
//                break
//            case "__clipboard":
//                break
//            case "__print":
//                break

            /**********************/
            // other

            case "__resetSessionAndHide":
            case "__resetSession":
                break
            case "__onlineHelp":
                Qt.openUrlExternally("https://photoqt.org/man")
                break


            // other
            default:
                console.log("unknown internal shortcut:", cmd)
        }

    }

}
