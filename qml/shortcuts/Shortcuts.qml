/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
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

import QtQuick 2.5
import "./mouseshortcuts.js" as AnalyseMouse
import "../handlestuff.js" as Handle

Item {

    id: top

    property var setKeyShortcuts: ({})

    Component.onCompleted:
        loadShortcuts()

    Connections {
        target: watcher
        onShortcutsUpdated:
            loadShortcuts()
    }

    function loadShortcuts() {

        var keys = shortcutshandler.load()
        setKeyShortcuts= ({})

        for(var i = 0; i < keys.length; i+=3) {

            if(keys[i] in setKeyShortcuts) {
                setKeyShortcuts[keys[i]][0] += 1
                setKeyShortcuts[keys[i]].push(keys[i+1])
                setKeyShortcuts[keys[i]].push(keys[i+2])
            } else
                setKeyShortcuts[keys[i]] = [1, keys[i+1], keys[i+2]]
        }

    }

    function analyseMouseEvent(startedEventAtPos, event) {

        var combostring = AnalyseMouse.analyseMouseEvent(startedEventAtPos, event)

        processString(combostring)

    }

    function analyseWheelEvent(event) {

        var combostring = AnalyseMouse.analyseWheelEvent(event)

        processString(combostring)

    }

    function processString(combostring) {

        // We need to check for guiBlocked before doing any of the below checks that might change its value.
        if(variables.guiBlocked)

            call.passOnShortcut(combostring)

        // Execute the shortcut if something is set
        else if(!variables.guiBlocked && combostring in setKeyShortcuts) {

            for(var i = 0; i < setKeyShortcuts[combostring][0]; ++i) {
                var close = setKeyShortcuts[combostring][1+i*2]
                var cmd = setKeyShortcuts[combostring][2+i*2]
                executeShortcut(cmd, close)
            }

        }

    }

    function executeShortcut(cmd, close) {

        if(cmd === "__quit")
            mainwindow.quitPhotoQt();
        else if(cmd === "__close")
            mainwindow.closePhotoQt()
        else if(cmd === "__settings")
            call.show("settingsmanager")
        else if(cmd === "__next")
            Handle.loadNext()
        else if(cmd === "__prev")
            Handle.loadPrev()
        else if(cmd === "__about")
            call.show("about")
        else if(cmd === "__slideshow")
            call.show("slideshowsettings")
        else if(cmd === "__filterImages")
            call.show("filter")
        else if(cmd === "__slideshowQuick")
            call.load("slideshowStart")
        else if(cmd === "__open")
            call.show("openfile")
        else if(cmd === "__zoomIn")
            imageitem.zoomIn()
        else if(cmd === "__zoomOut")
            imageitem.zoomOut()
        else if(cmd === "__zoomReset") {
            imageitem.resetPosition()
            imageitem.resetZoom()
        } else if(cmd === "__zoomActual")
            imageitem.zoomActual()
        else if(cmd === "__rotateL")
            imageitem.rotateImage(-90)
        else if(cmd === "__rotateR")
            imageitem.rotateImage(90)
        else if(cmd === "__rotate0")
            imageitem.resetRotation()
        else if(cmd === "__flipH")
            imageitem.mirrorHorizontal()
        else if(cmd === "__flipV")
            imageitem.mirrorVertical()
        else if(cmd === "__flipReset")
            imageitem.resetMirror()
        else if(cmd === "__rename") {
            call.load("filemanagementRenameShow")
        } else if(cmd === "__delete")
            call.load("filemanagementDeleteShow")
        else if(cmd === "__deletePermanent")
            call.load("permanentDeleteFile")
        else if(cmd === "__copy")
            call.load("filemanagementCopyShow")
        else if(cmd === "__move")
            call.load("filemanagementMoveShow")
        else if(cmd === "__hideMeta") {
            if(metadata.opacity > 0) {
                metadata.uncheckCheckbox()
                metadata.hide()
            } else {
                metadata.checkCheckbox()
                metadata.show()
            }
        }
        else if(cmd === "__gotoFirstThb")
            Handle.loadFirst()
        else if(cmd === "__gotoLastThb")
            Handle.loadLast()
        else if(cmd === "__wallpaper")
            call.show("wallpaper")
        else if(cmd === "__scale")
            call.show("scale")
        else if(cmd === "__playPauseAni")
            imageitem.playPauseAnimation()
        else if(cmd === "__imgur")
            call.show("imgurfeedback")
        else if(cmd === "__imgurAnonym")
            call.show("imgurfeedbackanonym")
        else if(cmd === "__defaultFileManager")
            getanddostuff.openInDefaultFileManager(variables.currentDir + "/" + variables.currentFile)
        else if(cmd === "__histogram") {
            call.ensureElementSetup("histogram")
            settings.histogram = !settings.histogram
        } else if(cmd === "__clipboard")
            getanddostuff.clipboardSetImage(variables.currentDir + "/" + variables.currentFile)
        else {
            getanddostuff.executeApp(cmd, variables.currentDir + "/" + variables.currentFile)
            if(close !== undefined && close === true)
                mainwindow.closePhotoQt()
        }

    }

}
