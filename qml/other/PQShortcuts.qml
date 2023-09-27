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
import PQCScriptsFilesPaths
import PQCScriptsFileManagement
import PQCFileFolderModel
import PQCScriptsClipboard
import PQCScriptsOther

Item {

    id: keyshortcuts_top

    anchors.fill: parent

    focus: true

    property bool mouseGesture: false
    property string mouseButton: ""
    property var mousePath: []
    property point mousePreviousPos: Qt.point(-1,-1)

    Connections {

        target: PQCNotify

        function onExecuteInternalCommand(cmd) {
            executeInternalFunction(cmd)
        }

        function onKeyPress(key, modifiers) {

//            contextmenu.hideMenu()

            if(loader.visibleItem !== "")

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

            if(loader.visibleItem !== "")

                loader.passOn("mouseWheel", [angleDelta, modifiers])

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

                checkComboForShortcut(combo, angleDelta)

            }

        }

        function onMousePressed(modifiers, button, pos) {

            if(loader.visibleItem !== "")

                loader.passOn("mousePressed", [modifiers, button, pos])

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

                if(button === Qt.LeftButton)
                    combo += "Left Button"
                else if(button === Qt.RightButton)
                    combo += "Right Button"

                mouseButton = combo
                mousePath = []
                mouseGesture = false
                mousePreviousPos = pos

            }

        }

        function onMouseReleased(modifiers, button, pos) {

            if(loader.visibleItem !== "")

                loader.passOn("mouseReleased", [modifiers, button, pos])

            else {

                if(!keyshortcuts_top.mouseGesture)
                    checkComboForShortcut(keyshortcuts_top.mouseButton)
                else
                    checkComboForShortcut(mouseButton + "+" + mousePath.join(""))

                mousePath = []
                mouseButton = ""
                mouseGesture = false

            }

        }

        function onMouseMove(x, y) {

            if(loader.visibleItem !== "")

                loader.passOn("mouseMove", [x, y])

            else {

                var threshold = 50

                var dx = x-mousePreviousPos.x
                var dy = y-mousePreviousPos.y
                var distance = Math.sqrt(Math.pow(dx,2)+Math.pow(dy,2));

                var angle = (Math.atan2(dy, dx)/Math.PI)*180
                angle = (angle+360)%360;

                var dir = ""

                if(distance > threshold) {
                    if(angle <= 45 || angle > 315)
                        dir = "E"
                    else if(angle > 45 && angle <= 135)
                        dir = "S"
                    else if(angle > 135 && angle <= 225)
                        dir = "W"
                    else if(angle > 225 && angle <= 315)
                        dir = "N"
                }

                if(dir != "") {
                    keyshortcuts_top.mouseGesture = true
                    mousePreviousPos = Qt.point(x,y)
                    if(mousePath[mousePath.length-1] !== dir) {
                        mousePath.push(dir)
                        mousePathChanged()
                    }
                }

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
            case "__about":
                loader.show("about")
                break
            case "__slideshow":
                loader.show("slideshowsetup")
                break
            case "__slideshowQuick":
                loader.show("slideshowhandler")
                loader.show("slideshowcontrols")
                break
            case "__filterImages":
                loader.show("filter")
                break
//            case "__wallpaper":
//                break
            case "__scale":
                loader.show("scale")
                break
            case "__imgur":
                if(PQCFileFolderModel.countMainView > 0 && PQCFileFolderModel.currentIndex > -1) {
                    loader.show("imgur")
                    loader_imgur.item.uploadToAccount()
                }
                break
            case "__imgurAnonym":
                if(PQCFileFolderModel.countMainView > 0 && PQCFileFolderModel.currentIndex > -1) {
                    loader.show("imgur")
                    loader_imgur.item.uploadAnonymously()
                }
                break
            case "__tagFaces":
                loader.passOn("tagFaces", undefined)
                break
//            case "__chromecast":
//                break
            case "__logging":
                loader.show("logging")
                break;
            case "__advancedSort":
                loader.show("advancedsort")
                break
            case "__advancedSortQuick":
                loader.show("advancedsort")
                loader_advancedsort.item.doSorting()
                break

            /**********************/
            // elements (ongoing)

            case "__contextMenu":
                if(!PQCNotify.slideshowRunning)
                    contextmenu.popup()
                break
            case "__showMetaData":
            case "__keepMetaData":
                PQCSettings.metadataElementVisible = !PQCSettings.metadataElementVisible
                loader.show("metadata")
                break
            case "__showMainMenu":
                loader.show("mainmenu")
                break
            case "__toggleMainMenu":
                loader.passOn("toggle", "mainmenu")
                break
            case "__showThumbnails":
                loader.show("thumbnails")
                break


            /**********************/
            // interface functions

            case "__quit":
                toplevel.quitPhotoQt()
                break
            case "__close":
                toplevel.close()
                break
            case "__fullscreenToggle":
                PQCSettings.interfaceWindowMode = !PQCSettings.interfaceWindowMode
                break

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
            case "__loadRandom":
                image.showRandom()
                break
//            case "__viewerMode":
//                break
            case "__navigationFloating":
                loader.show("navigationfloating")
                break

            /**********************/
            // image functions

            case "__zoomIn":
                image.zoomIn(wheelDelta)
                break
            case "__zoomOut":
                image.zoomOut(wheelDelta)
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
            case "__flipReset":
                image.mirrorReset()
                break
            case "__histogram":
                loader.show("histogram")
                break
            case "__fitInWindow":
                PQCSettings.imageviewFitInWindow = !PQCSettings.imageviewFitInWindow
                break
//            case "__playPauseAni":
//                break
//            case "__showFaceTags":
//                break
            case "__showMapCurrent":
                loader.show("mapcurrent")
                break
//            case "__toggleAlwaysActualSize":
//                PQCSettings.imageviewAlwaysActualSize = !PQCSettings.imageviewAlwaysActualSize
//                break

            /**********************/
            // file actions

            case "__rename":
                loader.show("filerename")
                break
            case "__delete":
                loader.show("filedelete")
                break
            case "__copy":
                loader.show("filecopy")
                break
            case "__move":
                loader.show("filemove")
                break
            case "__deletePermanent":
                if(PQCFileFolderModel.countMainView > 0 && PQCFileFolderModel.currentIndex > -1) {
                    if(PQCScriptsFileManagement.deletePermanent(PQCFileFolderModel.currentFile)) {
                        loader.show("notification")
                        loader_notification.item.statustext = qsTranslate("filemanagement", "File successfully deleted")
                        PQCFileFolderModel.removeEntryMainView(PQCFileFolderModel.currentIndex)
                    } else {
                        loader.show("notification")
                        loader_notification.item.statustext = qsTranslate("filemanagement", "Could not delete file")
                    }
                }
                break
            case "__deleteTrash":
                if(PQCFileFolderModel.countMainView > 0 && PQCFileFolderModel.currentIndex > -1) {
                    if(PQCScriptsFileManagement.moveFileToTrash(PQCFileFolderModel.currentFile)) {
                        loader.show("notification")
                        loader_notification.item.statustext = qsTranslate("filemanagement", "File successfully moved to trash")
                        PQCFileFolderModel.removeEntryMainView(PQCFileFolderModel.currentIndex)
                    } else {
                        loader.show("notification")
                        loader_notification.item.statustext = qsTranslate("filemanagement", "Could not move file to trash")
                    }
                }
                break
            case "__saveAs":
            case "__export":
                loader.show("export")
                break
            case "__defaultFileManager":
                if(PQCFileFolderModel.countMainView > 0)
                    PQCScriptsFilesPaths.openInDefaultFileManager(PQCFileFolderModel.currentFile)
                break
            case "__clipboard":
                PQCScriptsClipboard.copyFilesToClipboard([PQCFileFolderModel.currentFile])
                break
            case "__print":
                if(PQCFileFolderModel.countMainView > 0 && PQCFileFolderModel.currentIndex > -1)
                    PQCScriptsOther.printFile(PQCFileFolderModel.currentFile)
                break

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
