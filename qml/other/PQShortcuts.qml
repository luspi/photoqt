/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

import PQCShortcuts
import PQCNotify
import PQCScriptsFilesPaths
import PQCScriptsFileManagement
import PQCFileFolderModel
import PQCScriptsClipboard
import PQCScriptsOther
import PQCScriptsShortcuts
import PQCScriptsImages
import PQCImageFormats
import PQCScriptsConfig

Item {

    id: keyshortcuts_top

    anchors.fill: parent

    focus: true

    // translate shortcuts below
    // we use qsTr() here as before they were translated this way
    // this way we avoid having to retranslate 40-50 strings

    property var keyStrings: {
        //: Refers to a keyboard modifier
        "alt" : qsTr("Alt"),
        //: Refers to a keyboard modifier
        "ctrl" : qsTr("Ctrl"),
        //: Refers to a keyboard modifier
        "shift" : qsTr("Shift"),
        //: Refers to one of the keys on the keyboard
        "page up" : qsTr("Page Up"),
        //: Refers to one of the keys on the keyboard
        "page down" : qsTr("Page Down"),
        //: Refers to the key that usually has the Windows symbol on it
        "meta" : qsTr("Meta"),
        //: Refers to the key that triggers the number block on keyboards
        "keypad" : qsTr("Keypad"),
        //: Refers to one of the keys on the keyboard
        "esc" : qsTr("Escape"),
        //: Refers to one of the arrow keys on the keyboard
        "right" : qsTr("Right"),
        //: Refers to one of the arrow keys on the keyboard
        "left" : qsTr("Left"),
        //: Refers to one of the arrow keys on the keyboard
        "up" : qsTr("Up"),
        //: Refers to one of the arrow keys on the keyboard
        "down" : qsTr("Down"),
        //: Refers to one of the keys on the keyboard
        "space" : qsTr("Space"),
        //: Refers to one of the keys on the keyboard
        "delete" : qsTr("Delete"),
        //: Refers to one of the keys on the keyboard
        "backspace" : qsTr("Backspace"),
        //: Refers to one of the keys on the keyboard
        "home" : qsTr("Home"),
        //: Refers to one of the keys on the keyboard
        "end" : qsTr("End"),
        //: Refers to one of the keys on the keyboard
        "insert" : qsTr("Insert"),
        //: Refers to one of the keys on the keyboard
        "tab" : qsTr("Tab"),
        //: Return refers to the enter key of the number block - please try to make the translations of Return and Enter (the main button) different if possible!
        "return" : qsTr("Return"),
        //: Enter refers to the main enter key - please try to make the translations of Return (in the number block) and Enter different if possible!
        "enter" : qsTr("Enter")
    }

    property var mouseStrings: {
        //: Refers to a mouse button
        "left button" : qsTr("Left Button"),
        //: Refers to a mouse button
        "right button" : qsTr("Right Button"),
        //: Refers to a mouse button
        "middle button" : qsTr("Middle Button"),
        //: Refers to a mouse button
        "back button" : qsTr("Back Button"),
        //: Refers to a mouse button
        "forward button" : qsTr("Forward Button"),
        //: Refers to a mouse button
        "task button" : qsTr("Task Button"),
        //: Refers to a mouse button
        "button #7" : qsTr("Button #7"),
        //: Refers to a mouse button
        "button #8" : qsTr("Button #8"),
        //: Refers to a mouse button
        "button #9" : qsTr("Button #9"),
        //: Refers to a mouse button
        "button #10" : qsTr("Button #10"),
        //: Refers to a mouse event
        "double click" : qsTr("Double Click"),
        //: Refers to the mouse wheel
        "wheel up" : qsTr("Wheel Up"),
        //: Refers to the mouse wheel
        "wheel down" : qsTr("Wheel Down"),
        //: Refers to the mouse wheel
        "wheel left" : qsTr("Wheel Left"),
        //: Refers to the mouse wheel
        "wheel right" : qsTr("Wheel Right"),
        //: Refers to a direction of the mouse when performing a mouse gesture
        "east" : qsTr("East"),
        //: Refers to a direction of the mouse when performing a mouse gesture
        "south" : qsTr("South"),
        //: Refers to a direction of the mouse when performing a mouse gesture
        "west" : qsTr("West"),
        //: Refers to a direction of the mouse when performing a mouse gesture
        "north" : qsTr("North")
    }

    property var keyStringsKeys: Object.keys(keyStrings)
    property var mouseStringsKeys: Object.keys(mouseStrings)


    property bool mouseGesture: false
    property string mouseButton: ""
    property var mousePath: []
    property point mousePreviousPos: Qt.point(-1,-1)

    Connections {

        target: PQCNotify

        function onCmdShortcutSequence(seq) {
            checkComboForShortcut(seq)
        }

        function onExecuteInternalCommand(cmd) {
            executeInternalFunction(cmd)
        }

        function onKeyPress(key, modifiers) {

            if(loader.visibleItem !== "") {

                // make sure contextmenu is closed on key press
                contextmenu.dismiss()

                loader.passOn("keyEvent", [key, modifiers])

            } else {

                var combo = PQCScriptsShortcuts.analyzeModifier(modifiers).join("+")
                if(combo !== "")
                    combo += "+"

                // this seems to be the id when a modifier but no key is pressed... ignore key in that case
                if(key !== 16777249)
                    combo += PQCScriptsShortcuts.analyzeKeyPress(key)

                checkComboForShortcut(combo)

            }

        }

        function onMouseWheel(angleDelta, modifiers) {

            if(loader.visibleItem !== "")

                loader.passOn("mouseWheel", [angleDelta, modifiers])

            else {

                var combo = PQCScriptsShortcuts.analyzeModifier(modifiers).join("+")
                if(combo !== "")
                    combo += "+"

                if(combo === "" && PQCSettings.imageviewUseMouseWheelForImageMove)
                    return

                combo += PQCScriptsShortcuts.analyzeMouseWheel(angleDelta)

                checkComboForShortcut(combo, angleDelta)

            }

        }

        function onMousePressed(modifiers, button, pos) {

            if(loader.visibleItem !== "")

                loader.passOn("mousePressed", [modifiers, button, pos])

            else {

                var combo = PQCScriptsShortcuts.analyzeModifier(modifiers).join("+")
                if(combo !== "") combo += "+"
                combo += PQCScriptsShortcuts.analyzeMouseButton(button)

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

                var dir = PQCScriptsShortcuts.analyzeMouseDirection(Qt.point(x,y), mousePreviousPos)

                if(dir !== "") {
                    keyshortcuts_top.mouseGesture = true
                    mousePreviousPos = Qt.point(x,y)
                    if(mousePath[mousePath.length-1] !== dir) {
                        mousePath.push(dir)
                        mousePathChanged()
                    }
                }

            }
        }

        function onMouseDoubleClicked(modifiers, button, pos) {

            if(loader.visibleItem === "") {

                var combo = PQCScriptsShortcuts.analyzeModifier(modifiers).join("+")
                if(combo !== "") combo += "+"
                combo += "Double Click"

                checkComboForShortcut(combo)

            }

        }

    }

    function checkComboForShortcut(combo, wheelDelta) {

        console.log("args: combo =", combo)
        console.log("args: wheelDelta =", wheelDelta)

        // a context menu is open -> don't continue
        if(PQCNotify.whichContextMenusOpen.length > 0) {
            if(combo === "Esc")
                PQCNotify.closeAllContextMenus()
            return
        }

        // if in viewer mode, pressing 'Escape' exits viewer mode
        if(combo === "Esc" && (PQCFileFolderModel.isPDF || PQCFileFolderModel.isARC)) {
            PQCFileFolderModel.disableViewerMode()
            return
        }

        // make sure contextmenu is closed before executing shortcut
        if(contextmenu.opened) {
            contextmenu.dismiss()
            return
        }

        // Escape when bar/QR codes are displayed hides those bar codes
        if(combo === "Esc" && PQCNotify.barcodeDisplayed) {
            image.detectBarCodes()
            return
        }

        // Escape when filter is set removes filter
        if(combo === "Esc" && PQCFileFolderModel.isUserFilterSet()) {
            PQCFileFolderModel.removeAllUserFilter()
            return
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
                        image.videoJump(-5)
                        return
                    }

                    if(combo === "Right") {
                        image.videoJump(5)
                        return
                    }

                }

                if(PQCSettings.filetypesVideoSpacePause && combo === "Space") {
                    image.playPauseAnimationVideo()
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
                        image.animImageJump(-1)
                        return
                    }

                    if(combo === "Right") {
                        image.animImageJump(1)
                        return
                    }

                }

                if(combo === "Space" && PQCSettings.filetypesAnimatedSpacePause) {
                    image.playPauseAnimationVideo()
                    return
                }

            }

        }

        // Space when motion photo is loaded might have special actions
        if(combo === "Space" && PQCNotify.isMotionPhoto && PQCSettings.filetypesMotionSpacePause) {

            image.playPauseAnimationVideo()
            return

        }

        // Left/Right when document is loaded might have special actions
        if((combo === "Left" || combo === "Right") && PQCSettings.filetypesDocumentLeftRight && !PQCFileFolderModel.isPDF) {

            if(PQCScriptsImages.isPDFDocument(PQCFileFolderModel.currentFile)) {

                if(combo === "Left") {
                    image.documentJump(-1)
                    return
                }

                if(combo === "Right") {
                    image.documentJump(1)
                    return
                }

            }

        }

        // Left/Right when archive is loaded might have special actions
        if((combo === "Left" || combo === "Right") && PQCSettings.filetypesArchiveLeftRight && !PQCFileFolderModel.isARC) {

            if(PQCScriptsImages.isArchive(PQCFileFolderModel.currentFile)) {

                if(combo === "Left") {
                    image.archiveJump(-1)
                    return
                }

                if(combo === "Right") {
                    image.archiveJump(1)
                    return
                }

            }

        }

        /***************************************/

        // normal shortcut action

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
                    if(PQCFileFolderModel.countMainView === 0)
                        return
                    var parts = cmd.split(":/:/:")
                    if(parts.length !== 3)
                        return
                    PQCScriptsShortcuts.executeExternal(parts[0], parts[1], PQCFileFolderModel.currentFile)
                    if(parts[2]*1 === 1)
                        toplevel.close()
                }
            }

        } else {

            var index = PQCShortcuts.getNextCommandInCycle(combo, cycletimeout, commands.length)
            var curcmd = commands[index]
            if(curcmd[0] === "_" && curcmd[1] === "_")
                executeInternalFunction(curcmd, wheelDelta)
            else {
                if(PQCFileFolderModel.countMainView === 0)
                    return
                var curparts = curcmd.split(":/:/:")
                if(curparts.length !== 3)
                    return
                PQCScriptsShortcuts.executeExternal(curparts[0], curparts[1], PQCFileFolderModel.currentFile)
                if(curparts[2]*1 === 1)
                    toplevel.close()
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
            case "__showMapExplorer":
                loader.show("mapexplorer")
                break
            case "__settings":
                loader.show("settingsmanager")
                break
            case "__about":
                loader.show("about")
                break
            case "__slideshow":
                loader.show("slideshowsetup")
                break
            case "__slideshowQuick":
                loader.show("notification", qsTranslate("slideshow", "Slideshow started."))
                loader.show("slideshowhandler")
                loader.show("slideshowcontrols")
                break
            case "__filterImages":
                loader.show("filter")
                break
            case "__wallpaper":
                loader.show("wallpaper")
                break
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
            case "__chromecast":
                loader.show("chromecastmanager")
                break
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
            case "__contextMenuTouch":
                if(!PQCNotify.slideshowRunning)
                    // we "misuse" the wheelDelta parameter to pass on the touch point
                    contextmenu.popup(wheelDelta)
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
            case "__viewerMode":
                if(!(PQCFileFolderModel.isPDF || PQCFileFolderModel.isARC)) {
                    if(PQCScriptsImages.isPDFDocument(PQCFileFolderModel.currentFile)) {
                        if(PQCScriptsImages.getNumberDocumentPages(PQCFileFolderModel.currentFile))
                            PQCFileFolderModel.enableViewerMode()
                    } else if(PQCScriptsImages.isArchive(PQCFileFolderModel.currentFile))
                        PQCFileFolderModel.enableViewerMode()
                }
                break
            case "__navigationFloating":
                loader.show("navigationfloating")
                break
            case "__enterPhotoSphere":
                if(PQCScriptsConfig.isPhotoSphereSupportEnabled())
                    PQCNotify.enterPhotoSphere()
                else
                    loader.show("notification", qsTranslate("unavailable", "Photo spheres are not supported by this build of PhotoQt."))
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
            case "__playPauseAni":
                image.playPauseAnimationVideo()
                break
            case "__showFaceTags":
                PQCSettings.metadataFaceTagsEnabled = !PQCSettings.metadataFaceTagsEnabled
                break
            case "__showMapCurrent":
                loader.show("mapcurrent")
                break
            case "__toggleAlwaysActualSize":
                PQCSettings.imageviewAlwaysActualSize = !PQCSettings.imageviewAlwaysActualSize
                break
            case "__moveViewLeft":
                image.moveView("left")
                break
            case "__moveViewRight":
                image.moveView("right")
                break
            case "__moveViewUp":
                image.moveView("up")
                break
            case "__moveViewDown":
                image.moveView("down")
                break
            case "__goToLeftEdge":
                image.moveView("leftedge")
                break
            case "__goToRightEdge":
                image.moveView("rightedge")
                break
            case "__goToTopEdge":
                image.moveView("topedge")
                break
            case "__goToBottomEdge":
                image.moveView("bottomedge")
                break
            case "__detectBarCodes":
                image.detectBarCodes()
                break
            case "__videoJumpForwards":
                image.videoJump(5)
                break
            case "__videoJumpBackwards":
                image.videoJump(-5)
                break

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
                        loader.show("notification", qsTranslate("filemanagement", "File successfully deleted"))
                        PQCFileFolderModel.removeEntryMainView(PQCFileFolderModel.currentIndex)
                    } else {
                        loader.show("notification", qsTranslate("filemanagement", "Could not delete file"))
                    }
                }
                break
            case "__deleteTrash":
                if(PQCFileFolderModel.countMainView > 0 && PQCFileFolderModel.currentIndex > -1) {
                    if(PQCScriptsFileManagement.moveFileToTrash(PQCFileFolderModel.currentFile)) {
                        loader.show("notification", qsTranslate("filemanagement", "File successfully move to trash"))
                        PQCFileFolderModel.removeEntryMainView(PQCFileFolderModel.currentIndex)
                    } else {
                        loader.show("notification", qsTranslate("filemanagement", "Could not move file to trash"))
                    }
                }
                break
            case "__deleteTrash":
                if(PQCFileFolderModel.countMainView > 0 && PQCFileFolderModel.currentIndex > -1) {
                    if(PQCScriptsFileManagement.moveFileToTrash(PQCFileFolderModel.currentFile)) {
                        loader.show("notification", qsTranslate("filemanagement", "File successfully moved to trash"))
                        PQCFileFolderModel.removeEntryMainView(PQCFileFolderModel.currentIndex)
                    } else {
                        loader.show("notification", qsTranslate("filemanagement", "Could not move file to trash"))
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
                PQCNotify.resetSessionData()
                PQCSettings.interfaceTrayIcon = 1
                toplevel.close()
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

    function translateShortcut(combo) {

        if(combo === "")
            return "";

        combo = combo.replace("++","+PLUS");
        if(combo === "+") combo = "PLUS";

        var parts = combo.split("+");

        var dir = "";
        if(combo.includes(" Button")) {
            var checkdir = parts[parts.length-1]
            var onlydir = true;
            for(var i in checkdir) {
                var d = checkdir[i]
                if(d !== 'N' && d !== 'S' && d !== 'E' && d !== 'W') {
                    onlydir = false;
                    break;
                }
            }
            if(onlydir) {
                dir = parts[parts.length-1]
                parts.splice(parts.length-1, 1)
            }
        }

        var ret = "";
        for(var j in parts) {
            var ele = parts[j]
            if(ret != "")
                ret += " + ";
            if(ele === "")
                continue;
            if(ele === "PLUS")
                ret += "+";
            else {
                var key_check = ele.toLowerCase()
                if(keyStringsKeys.indexOf(key_check) > -1)
                    ret += keyStrings[key_check];
                else if(mouseStringsKeys.indexOf(key_check) > -1)
                    ret += mouseStrings[key_check];
                else
                    ret += ele
            }
        }

        if(dir != "") {
            if(ret != "")
                ret += "  ";
            ret += translateMouseDirection(dir.split(""))
        }

        return ret;

    }

    function translateMouseDirection(parts) {

        var ret = ""

        for(var i in parts) {
            var p = parts[i]
            if(p === "N")
                ret += "↑";
            else if(p === "S")
                ret += "↓";
            else if(p === "E")
                ret += "→";
            else if(p === "W")
                ret += "←";
        }

        return ret

    }

}
