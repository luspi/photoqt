/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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

import QtQuick
import QtQml
import PQCImageFormats
import PQCExtensionsHandler
import PQCLocation
import PQCScriptsShareImgur

import PhotoQt.CPlusPlus
import PhotoQt.Modern   // will be adjusted accordingly by CMake

/* :-)) <3 */

Item {

    id: keyshortcuts_top

    anchors.fill: parent

    focus: true

    property bool mouseGesture: false
    property string mouseButton: ""
    property list<string> mousePath: []
    property point mousePreviousPos: Qt.point(-1,-1)

    Connections {

        target: PQCScriptsShortcuts

        function onExecuteInternalCommand(cmd : string) {
            keyshortcuts_top.executeInternalFunction(cmd, Qt.point(-1,-1), Qt.point(0,0))
        }

        function onExecuteInternalCommandWithMousePos(cmd : string, pos : point) {
            keyshortcuts_top.executeInternalFunction(cmd, pos, Qt.point(0,0))
        }

    }

    Connections {

        target: PQCNotify

        function onCmdShortcutSequence(seq : string) {
            keyshortcuts_top.checkComboForShortcut(seq, Qt.point(-1,-1), Qt.point(0,0))
        }

        function onKeyPress(key : int, modifiers : int) {

            if(PQCConstants.modalWindowOpen || PQCConstants.idOfVisibleItem !== "") {

                // make sure contextmenu is closed on key press
                PQCScriptsShortcuts.sendShortcutDismissGlobalContextMenu()

                PQCNotify.loaderPassOn("keyEvent", [key, modifiers])

            } else if(PQCConstants.currentArchiveComboOpen) {

                PQCNotify.currentArchiveCloseCombo()

            } else {

                var combo = PQCScriptsShortcuts.analyzeModifier(modifiers).join("+")
                if(combo !== "")
                    combo += "+"

                // this seems to be the id when a modifier but no key is pressed... ignore key in that case
                if(key !== 16777249)
                    combo += PQCScriptsShortcuts.analyzeKeyPress(key)

                if(combo === "Shift+")
                    PQCConstants.shiftKeyPressed = true

                keyshortcuts_top.checkComboForShortcut(combo, Qt.point(-1,-1), Qt.point(0,0))

            }

        }

        function onKeyRelease(key: int, modifiers: int) {
            if(key < 16770000 || modifiers !== Qt.ShiftModifier)
                PQCConstants.shiftKeyPressed = false
        }

        function onMouseWheel(mousePos: point, angleDelta : point, modifiers : int) {

            if(PQCConstants.modalWindowOpen)

                PQCNotify.loaderPassOn("mouseWheel", [mousePos, angleDelta, modifiers])

            else {

                var combo = PQCScriptsShortcuts.analyzeModifier(modifiers).join("+")
                if(combo !== "")
                    combo += "+"

                if(combo === "" && PQCSettings.imageviewUseMouseWheelForImageMove)
                    return

                combo += PQCScriptsShortcuts.analyzeMouseWheel(angleDelta)

                keyshortcuts_top.checkComboForShortcut(combo, mousePos, angleDelta)

            }

        }

        function onMousePressed(modifiers : int, button : int, pos : point) {

            if(PQCConstants.modalWindowOpen)

                PQCNotify.loaderPassOn("mousePressed", [modifiers, button, pos])

            else {

                var combo = PQCScriptsShortcuts.analyzeModifier(modifiers).join("+")
                if(combo !== "") combo += "+"
                combo += PQCScriptsShortcuts.analyzeMouseButton(button)

                keyshortcuts_top.mouseButton = combo
                keyshortcuts_top.mousePath = []
                keyshortcuts_top.mouseGesture = false
                keyshortcuts_top.mousePreviousPos = pos

            }

        }

        function onMouseReleased(modifiers : int, button : int, pos : point) {

            if(PQCConstants.modalWindowOpen)

                PQCNotify.loaderPassOn("mouseReleased", [modifiers, button, pos])

            else {

                if(!keyshortcuts_top.mouseGesture)
                    keyshortcuts_top.checkComboForShortcut(keyshortcuts_top.mouseButton, pos, Qt.point(0,0))
                else
                    keyshortcuts_top.checkComboForShortcut(keyshortcuts_top.mouseButton + "+" + keyshortcuts_top.mousePath.join(""), pos, Qt.point(0,0))

                keyshortcuts_top.mousePath = []
                keyshortcuts_top.mouseButton = ""
                keyshortcuts_top.mouseGesture = false

            }

        }

        function onMouseMove(x : int, y : int) {

            if(PQCConstants.modalWindowOpen)

                PQCNotify.loaderPassOn("mouseMove", [x, y])

            else {

                var dir = PQCScriptsShortcuts.analyzeMouseDirection(Qt.point(x,y), keyshortcuts_top.mousePreviousPos)

                if(dir !== "") {
                    keyshortcuts_top.mouseGesture = true
                    keyshortcuts_top.mousePreviousPos = Qt.point(x,y)
                    if(keyshortcuts_top.mousePath[keyshortcuts_top.mousePath.length-1] !== dir) {
                        keyshortcuts_top.mousePath.push(dir)
                        keyshortcuts_top.mousePathChanged()
                    }
                }

            }
        }

        function onMouseDoubleClicked(modifiers : int, button : string, pos : point) {

            if(!PQCConstants.modalWindowOpen) {

                var combo = PQCScriptsShortcuts.analyzeModifier(modifiers).join("+")
                if(combo !== "") combo += "+"
                combo += "Double Click"

                keyshortcuts_top.checkComboForShortcut(combo, pos, Qt.point(0,0))

            }

        }

    }

    function checkComboForShortcut(combo : string, mousePos: point, wheelDelta : point) {

        console.log("args: combo =", combo)
        console.log("args: mousePos =", mousePos)
        console.log("args: wheelDelta =", wheelDelta)

        if(combo === "Ctrl+Alt+Shift+R") {

            console.log("Detected shortcut for resetting PhotoQt")

            if(PQCScriptsConfig.askForConfirmation(qsTranslate("configuration", "Reset PhotoQt to its default state."),
                                                   qsTranslate("configuration", "Do you want to reset PhotoQt to its default state? If you encounter any issues with your configuration, you should be able to fix it this way."),
                                                   "<b>" + qsTranslate("configuration", "Warning: This step cannot be undone!") + "</b>")) {

                PQCSettings.closeDatabase()
                PQCShortcuts.closeDatabase()
                PQCImageFormats.closeDatabase()
                PQCLocation.closeDatabase()
                PQCScriptsContextMenu.closeDatabase()
                PQCScriptsShareImgur.closeDatabase()

                PQCScriptsConfig.callStartupSetupFresh()

                PQCScriptsConfig.inform(qsTranslate("configuration", "Restart PhotoQt"),
                                        qsTranslate("configuration", "PhotoQt has been reset to its defaults and will need to be restarted."))

                Qt.quit()

            }
            return
        }


        // make sure contextmenu is closed before executing shortcut
        if(PQCConstants.isContextmenuOpen("globalcontextmenu")) {
            PQCScriptsShortcuts.sendShortcutDismissGlobalContextMenu()
            return
        }

        if(combo === "Esc") {

            // a context menu is open -> don't continue
            if(PQCConstants.whichContextMenusOpen.length > 0) {
                PQCNotify.closeAllContextMenus()
                return
            }

            // if in viewer mode, pressing 'Escape' exits viewer mode
            if(PQCFileFolderModel.isPDF && PQCSettings.imageviewEscapeExitDocument) {
                PQCFileFolderModel.disableViewerMode()
                return
            }

            // if in viewer mode, pressing 'Escape' exits viewer mode
            if(PQCFileFolderModel.isARC && PQCSettings.imageviewEscapeExitArchive) {
                PQCFileFolderModel.disableViewerMode()
                return
            }

            // Escape when bar/QR codes are displayed hides those bar codes
            if(PQCConstants.barcodeDisplayed && PQCSettings.imageviewEscapeExitBarcodes) {
                PQCNotify.currentImageDetectBarCodes()
                return
            }

            // Escape when filter is set removes filter
            if(PQCFileFolderModel.isUserFilterSet() && PQCSettings.imageviewEscapeExitFilter) {
                PQCFileFolderModel.removeAllUserFilter()
                return
            }

            if(PQCConstants.faceTaggingMode) {
                PQCNotify.stopFaceTagging()
                return
            }

        }

        // Left/Right/Space when video is loaded might have special actions
        if(((combo === "Left" || combo === "Right") && PQCSettings.filetypesVideoLeftRightJumpVideo) ||
                (combo === "Space" && PQCSettings.filetypesVideoSpacePause)) {

            var suffix = PQCScriptsFilesPaths.getSuffix(PQCFileFolderModel.currentFile)

            var isVideo = (PQCScriptsConfig.isMPVSupportEnabled() && PQCImageFormats.getEnabledFormatsLibmpv().indexOf(suffix)>-1) ||
                                (PQCScriptsConfig.isVideoQtSupportEnabled() && PQCImageFormats.getEnabledFormatsVideo().indexOf(suffix)>-1)

            if(isVideo) {

                if(PQCSettings.filetypesVideoLeftRightJumpVideo) {

                    if(combo === "Left") {
                        PQCNotify.currentVideoJump(-5)
                        return
                    }

                    if(combo === "Right") {
                        PQCNotify.currentVideoJump(5)
                        return
                    }

                }

                if(PQCSettings.filetypesVideoSpacePause && combo === "Space") {
                    PQCNotify.playPauseAnimationVideo()
                    return
                }

            }

        }

        // Left/Right/Space when animated image is loaded might have special actions
        if(((combo === "Left" || combo === "Right") && PQCSettings.filetypesAnimatedLeftRight) ||
                (combo === "Space" && PQCSettings.filetypesAnimatedSpacePause)) {

            if(PQCScriptsImages.isItAnimated(PQCFileFolderModel.currentFile)) {

                if(PQCSettings.filetypesAnimatedLeftRight) {

                    if(combo === "Left") {
                        PQCNotify.currentAnimatedJump(-1)
                        return
                    }

                    if(combo === "Right") {
                        PQCNotify.currentAnimatedJump(1)
                        return
                    }

                }

                if(combo === "Space" && PQCSettings.filetypesAnimatedSpacePause) {
                    PQCNotify.playPauseAnimationVideo()
                    return
                }

            }

        }

        // Space when motion photo is loaded might have special actions
        if(combo === "Space" && PQCConstants.currentImageIsMotionPhoto && PQCSettings.filetypesMotionSpacePause) {

            PQCNotify.playPauseAnimationVideo()
            return

        }

        // Left/Right when document is loaded might have special actions
        if((combo === "Left" || combo === "Right") && PQCSettings.filetypesDocumentLeftRight && !PQCFileFolderModel.isPDF) {

            if(PQCScriptsImages.isPDFDocument(PQCFileFolderModel.currentFile)) {

                if(combo === "Left") {
                    PQCNotify.currentDocumentJump(-1)
                    return
                }

                if(combo === "Right") {
                    PQCNotify.currentDocumentJump(1)
                    return
                }

            }

        }

        // Left/Right when archive is loaded might have special actions
        if((combo === "Left" || combo === "Right") && PQCSettings.filetypesArchiveLeftRight && !PQCFileFolderModel.isARC) {

            if(PQCScriptsImages.isArchive(PQCFileFolderModel.currentFile)) {

                if(combo === "Left") {
                    PQCNotify.currentArchiveJump(-1)
                    return
                }

                if(combo === "Right") {
                    PQCNotify.currentArchiveJump(1)
                    return
                }

            }

        }

        // Left/Right when archive is loaded might have special actions
        if(PQCConstants.showingPhotoSphere) {
            if(PQCSettings.filetypesPhotoSphereArrowKeys &&
                    (combo === "Left" || combo === "Right" || combo === "Up" || combo === "Down")) {

                PQCNotify.currentViewMove(combo.toLowerCase())
                return

            }

            if((!PQCScriptsImages.isPhotoSphere(PQCFileFolderModel.currentFile) || !PQCSettings.filetypesPhotoSphereAutoLoad) && combo === "Esc" && PQCSettings.imageviewEscapeExitSphere) {

                PQCNotify.exitPhotoSphere()
                return

            }

        }

        /***************************************/

        // check if shortcut is set somewhere internally
        var data = PQCShortcuts.getCommandsForShortcut(combo)

        // if it is not, then check extensions
        if(data.length !== 4) {

            // check for shortcuts that are enabled for extensions
            var ext = PQCExtensionsHandler.getExtensionForShortcut(combo)
            if(ext !== "" && (!PQCExtensionsHandler.getExtensionModalMake(ext) || (PQCExtensionsHandler.getExtensionModalRequireLoadedFile(ext) && PQCFileFolderModel.currentFile !== ""))) {
                PQCNotify.loaderShowExtension(ext)
            }

            // we always stop, no matter what, in this case
            return
        }

        // normal shortcut action

        var commands = data[0]
        var cycle = parseInt(data[1])
        var cycletimeout = parseInt(data[2])

        if(cycle === 0) {

            for(var c in commands) {
                var cmd = commands[c]
                if(cmd[0] === "_" && cmd[1] === "_")
                    keyshortcuts_top.executeInternalFunction(cmd, mousePos, wheelDelta)
                else {
                    if(PQCFileFolderModel.countMainView === 0)
                        return
                    var parts = cmd.split(":/:/:")
                    if(parts.length !== 3)
                        return
                    PQCScriptsShortcuts.executeExternal(parts[0], parts[1], PQCFileFolderModel.currentFile)
                    if(parts[2]*1 === 1)
                        PQCNotify.windowClose()
                }
            }

        } else {

            var index = PQCShortcuts.getNextCommandInCycle(combo, cycletimeout, commands.length)
            var curcmd = commands[index]
            if(curcmd[0] === "_" && curcmd[1] === "_")
                keyshortcuts_top.executeInternalFunction(curcmd, mousePos, wheelDelta)
            else {
                if(PQCFileFolderModel.countMainView === 0)
                    return
                var curparts = curcmd.split(":/:/:")
                if(curparts.length !== 3)
                    return
                PQCScriptsShortcuts.executeExternal(curparts[0], curparts[1], PQCFileFolderModel.currentFile)
                if(curparts[2]*1 === 1)
                    PQCNotify.windowClose()
            }

        }

    }

    function executeInternalFunction(cmd : string, mousePos : point, wheelDelta : point) {

        // We limit the internal shortcuts to happen at most once every threshold ms
        // We can't do the math directly here as 64bit integers are not properly supported by QML
        // The flick/move shortcuts ignore this check as otherwise the scrolling is a bit jarring when the respective shortcut is pressed continuously.
        if(PQCScriptsShortcuts.getCurrentTimestampDiffLessThan(100) && !cmd.startsWith("__flickView") && !cmd.startsWith("__moveView"))
            return
        PQCScriptsShortcuts.setCurrentTimestamp()

        console.debug("args: cmd =", cmd)
        console.debug("args: mousePos =", mousePos)
        console.debug("args: wheelDelta =", wheelDelta)

        PQCConstants.lastExecutedShortcutCommand = cmd

        switch(cmd) {

            /**********************/
            // elements

            case "__open":
                PQCNotify.loaderShow("filedialog")
                break
            case "__showMapExplorer":
                PQCNotify.loaderShow("mapexplorer")
                break
            case "__settings":
                PQCNotify.loaderShow("SettingsManager")
                break
            case "__about":
                PQCNotify.loaderShow("about")
                break
            case "__slideshow":
                PQCNotify.loaderShow("slideshowsetup")
                break
            case "__slideshowQuick":
                PQCNotify.showNotificationMessage(qsTranslate("slideshow", "Slideshow started."), "")
                PQCNotify.loaderShow("slideshowhandler")
                PQCNotify.loaderShow("slideshowcontrols")
                break
            case "__filterImages":
                PQCNotify.loaderShow("filter")
                break
            case "__tagFaces":
                PQCNotify.loaderPassOn("tagFaces", [])
                break
            case "__chromecast":
                PQCNotify.loaderShow("chromecastmanager")
                break
            case "__logging":
                PQCNotify.loaderShow("logging")
                break;
            case "__advancedSort":
                if(PQCFileFolderModel.countMainView > 0 && PQCFileFolderModel.currentIndex > -1)
                    PQCNotify.loaderShow("advancedsort")
                break
            case "__advancedSortQuick":
                if(PQCFileFolderModel.countMainView > 0 && PQCFileFolderModel.currentIndex > -1) {
                    PQCNotify.loaderShow("advancedsort")
                    loader_advancedsort.item.doSorting()
                }
                break

            /**********************/
            // elements (ongoing)

            case "__contextMenu":
                if(!PQCConstants.slideshowRunning)
                    PQCScriptsShortcuts.sendShortcutShowGlobalContextMenuAt(Qt.point(-1,-1))
                break
            case "__contextMenuTouch":
                if(!PQCConstants.slideshowRunning)
                    PQCScriptsShortcuts.sendShortcutShowGlobalContextMenuAt(mousePos)
                break
            case "__showMetaData":
            case "__keepMetaData":
                PQCNotify.loaderPassOn("toggle", ["metadata"])
                break
            case "__showMainMenu":
            case "__toggleMainMenu":
                PQCNotify.loaderPassOn("toggle", ["mainmenu"])
                break
            case "__showThumbnails":
                PQCNotify.loaderShow("thumbnails")
                break


            /**********************/
            // interface functions

            case "__quit":
                PQCNotify.photoQtQuit()
                break
            case "__close":
                PQCNotify.windowClose()
                break
            case "__fullscreenToggle":
                PQCSettings.interfaceWindowMode = !PQCSettings.interfaceWindowMode
                break

            /**********************/
            // navigation

            case "__next":
                PQCScriptsShortcuts.sendShortcutShowNextImage()
                break
            case "__prev":
                PQCScriptsShortcuts.sendShortcutShowPrevImage()
                break
            case "__nextArcDoc":
                PQCScriptsShortcuts.sendShortcutShowNextArcDocImage()
                break
            case "__prevArcDoc":
                PQCScriptsShortcuts.sendShortcutShowPrevArcDocImage()
                break
            case "__goToFirst":
                PQCScriptsShortcuts.sendShortcutShowFirstImage()
                break
            case "__goToLast":
                PQCScriptsShortcuts.sendShortcutShowLastImage()
                break
            case "__loadRandom":
                PQCScriptsShortcuts.sendShortcutShowRandomImage()
                break
            case "__viewerMode":
                if(!(PQCFileFolderModel.isPDF || PQCFileFolderModel.isARC)) {
                    if(PQCScriptsImages.isPDFDocument(PQCFileFolderModel.currentFile)) {
                        if(PQCScriptsImages.getNumberDocumentPages(PQCFileFolderModel.currentFile))
                            PQCFileFolderModel.enableViewerMode()
                    } else if(PQCScriptsImages.isArchive(PQCFileFolderModel.currentFile))
                        PQCFileFolderModel.enableViewerMode()
                }
                break
            case "__enterPhotoSphere":
                if(PQCScriptsConfig.isPhotoSphereSupportEnabled())
                    PQCNotify.enterPhotoSphere()
                else
                    PQCNotify.showNotificationMessage(qsTranslate("unavailable", "Feature unavailable"), qsTranslate("unavailable", "Photo spheres are not supported by this build of PhotoQt."))
                break

            /**********************/
            // image functions

            case "__zoomIn":
                PQCScriptsShortcuts.sendShortcutZoomIn(mousePos, wheelDelta)
                break
            case "__zoomOut":
                PQCScriptsShortcuts.sendShortcutZoomOut(mousePos, wheelDelta)
                break
            case "__zoomReset":
                PQCScriptsShortcuts.sendShortcutZoomReset()
                break
            case "__zoomActual":
                PQCScriptsShortcuts.sendShortcutZoomActual()
                break
            case "__rotateL":
                PQCScriptsShortcuts.sendShortcutRotateAntiClock()
                break
            case "__rotateR":
                PQCScriptsShortcuts.sendShortcutRotateClock()
                break
            case "__rotate0":
                PQCScriptsShortcuts.sendShortcutRotateReset()
                break
            case "__flipH":
                PQCScriptsShortcuts.sendShortcutMirrorHorizontal()
                break
            case "__flipV":
                PQCScriptsShortcuts.sendShortcutMirrorVertical()
                break
            case "__flipReset":
                PQCScriptsShortcuts.sendShortcutMirrorReset()
                break
            case "__fitInWindow":
                PQCSettings.imageviewFitInWindow = !PQCSettings.imageviewFitInWindow
                break
            case "__playPauseAni":
                PQCNotify.playPauseAnimationVideo()
                break
            case "__showFaceTags":
                PQCSettings.metadataFaceTagsEnabled = !PQCSettings.metadataFaceTagsEnabled
                break
            case "__toggleAlwaysActualSize":
                PQCSettings.imageviewAlwaysActualSize = !PQCSettings.imageviewAlwaysActualSize
                break
            case "__flickViewLeft":
                PQCNotify.currentViewFlick("left")
                break
            case "__flickViewRight":
                PQCNotify.currentViewFlick("right")
                break
            case "__flickViewUp":
                PQCNotify.currentViewFlick("up")
                break
            case "__flickViewDown":
                PQCNotify.currentViewFlick("down")
                break
            case "__moveViewLeft":
                PQCNotify.currentViewMove("left")
                break
            case "__moveViewRight":
                PQCNotify.currentViewMove("right")
                break
            case "__moveViewUp":
                PQCNotify.currentViewMove("up")
                break
            case "__moveViewDown":
                PQCNotify.currentViewMove("down")
                break
            case "__goToLeftEdge":
                PQCNotify.currentViewMove("leftedge")
                break
            case "__goToRightEdge":
                PQCNotify.currentViewMove("rightedge")
                break
            case "__goToTopEdge":
                PQCNotify.currentViewMove("topedge")
                break
            case "__goToBottomEdge":
                PQCNotify.currentViewMove("bottomedge")
                break
            case "__detectBarCodes":
                PQCNotify.currentImageDetectBarCodes()
                break
            case "__videoJumpForwards":
                PQCNotify.currentVideoJump(5)
                break
            case "__videoJumpBackwards":
                PQCNotify.currentVideoJump(-5)
                break

            /**********************/
            // file actions

            case "__rename":
                PQCNotify.loaderShow("FileRename")
                break
            case "__delete":
                PQCNotify.loaderShow("FileDelete")
                break
            case "__copy":
                PQCNotify.loaderShow("FileCopy")
                break
            case "__move":
                PQCNotify.loaderShow("FileMove")
                break
            case "__deletePermanent":
                if(PQCFileFolderModel.countMainView > 0 && PQCFileFolderModel.currentIndex > -1) {
                    if(PQCScriptsFileManagement.deletePermanent(PQCFileFolderModel.currentFile)) {
                        PQCNotify.showNotificationMessage(qsTranslate("filemanagement", "Success"), qsTranslate("filemanagement", "File successfully deleted"))
                        PQCFileFolderModel.removeEntryMainView(PQCFileFolderModel.currentIndex)
                    } else {
                        PQCNotify.showNotificationMessage(qsTranslate("filemanagement", "Failed"), qsTranslate("filemanagement", "Could not delete file"))
                    }
                }
                break
            case "__deleteTrash":
                if(PQCFileFolderModel.countMainView > 0 && PQCFileFolderModel.currentIndex > -1) {
                    if(PQCScriptsFileManagement.moveFileToTrash(PQCFileFolderModel.currentFile)) {
                        PQCNotify.showNotificationMessage(qsTranslate("filemanagement", "Success"), qsTranslate("filemanagement", "File successfully moved to trash"))
                        PQCFileFolderModel.removeEntryMainView(PQCFileFolderModel.currentIndex)
                    } else {
                        PQCNotify.showNotificationMessage(qsTranslate("filemanagement", "Failed"), qsTranslate("filemanagement", "Could not move file to trash"))
                    }
                }
                break
            case "__defaultFileManager":
                if(PQCFileFolderModel.countMainView > 0)
                    PQCScriptsFilesPaths.openInDefaultFileManager(PQCFileFolderModel.currentFile)
                break
            case "__clipboard":
                var src = PQCFileFolderModel.currentFile
                if(PQCConstants.currentFileInsideTotal > 0 && PQCScriptsImages.isArchive(src) && !src.includes("::ARC::"))
                    src = "%1::ARC::%2".arg(PQCConstants.currentFileInsideName).arg(src)
                if(PQCConstants.currentFileInsideTotal > 0 && PQCScriptsImages.isPDFDocument(src) && !src.includes("::PDF::"))
                    src = "%1::PDF::%2".arg(PQCConstants.currentFileInsideNum).arg(src)
                PQCScriptsClipboard.copyFilesToClipboard([src])
                break
            case "__print":
                if(PQCFileFolderModel.countMainView > 0 && PQCFileFolderModel.currentIndex > -1)
                    PQCScriptsOther.printFile(PQCFileFolderModel.currentFile)
                break
            case "__undoTrash":
                var ret = PQCScriptsFileManagement.undoLastAction("trash")
                if(ret === "")
                    PQCNotify.showNotificationMessage(qsTranslate("filemanagement", "Trash"), qsTranslate("filemanagement", "Nothing to restore"))
                else if(ret.startsWith("-"))
                    PQCNotify.showNotificationMessage(qsTranslate("filemanagement", "Error"), ret.substring(1))
                else
                    PQCNotify.showNotificationMessage(qsTranslate("filemanagement", "Success"), ret)
                break

            /**********************/
            // other

            case "__resetSessionAndHide":
                PQCNotify.resetSessionData()
                PQCSettings.interfaceTrayIcon = 1
                PQCNotify.windowClose()
                break
            case "__resetSession":
                PQCNotify.resetSessionData()
                break
            case "__onlineHelp":
                Qt.openUrlExternally("https://photoqt.org/support")
                break


            // other
            default:
                console.log("unknown internal shortcut:", cmd)
        }

    }

}
