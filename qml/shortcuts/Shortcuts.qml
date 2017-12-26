import QtQuick 2.6
import "./keyshortcuts.js" as AnalyseKeys
import "../loadfile.js" as Load

Item {

    id: top

    property var keycodes: ({})
    property var setKeyShortcuts: ({})

    Component.onCompleted: {
        top.forceActiveFocus()

        var keys = shortcutshandler.load()

        for(var i = 0; i < keys.length; i+=3)
            setKeyShortcuts[keys[i]] = [keys[i+1], keys[i+2]]

    }

    Keys.onPressed: analyseKeyEvent(event)

    function analyseKeyEvent(event) {

        var combostring = AnalyseKeys.analyseKeyEvent(event)

        processString(combostring)

    }

    function analyseMouseEvent(startedEventAtPos, event) {

        var combostring = AnalyseKeys.analyseMouseEvent(startedEventAtPos, event)

        processString(combostring)

    }

    function analyseWheelEvent(event) {

        var combostring = AnalyseKeys.analyseWheelEvent(event)

        processString(combostring)

    }

    function processString(combostring) {

        // We need to check for guiBlocked before doing any of the below checks that might change its value.
        if(variables.guiBlocked)
            checkForSystemShortcut(combostring)
        else
            analyseKeyCombo(combostring)

    }


    function checkForSystemShortcut(keys) {

        verboseMessage("Shortcuts::checkForSystemShortcut()", keys)

        if(keys === "Escape") {
            if(call.whatisshown["about"])
                call.hide("about")
            else if(call.whatisshown["settingsmanager"])
                call.hide("settingsmanager")
            else if(call.whatisshown["filemanagement"])
                call.hide("filemanagement")
            else if(call.whatisshown["scale"])
                call.hide("scale")
            else if(call.whatisshown["scaleunsupported"])
                call.hide("scaleunsupported")
            else if(call.whatisshown["wallpaper"])
                call.hide("wallpaper")
            else if(variables.slideshowRunning)
                call.load("slideshowStop")
            else if(call.whatisshown["slideshowsettings"])
                call.hide("slideshowsettings")
            else if(call.whatisshown["filter"])
                call.hide("filter")
            else if(call.whatisshown["startup"])
                call.hide("startup")
            else if(call.whatisshown["openfile"])
                call.hide("openfile")
            else if(call.whatisshown["imgurfeedback"])
                call.hide("imgurfeedback")
        } else if(keys === "Enter" || keys === "Keypad+Enter" || keys === "Return") {
            if(call.whatisshown["filemanagement"] && variables.filemanagementCurrentCategory == "del")
                call.load("filemanagementDeleteImage")
            else if(call.whatisshown["filemanagement"] && variables.filemanagementCurrentCategory == "rn")
                call.load("filemanagementPerformRename")
            else if(call.whatisshown["wallpaper"])
                call.load("wallpaperAccept")
            else if(call.whatisshown["slideshowsettings"])
                call.load("slideshowStartFromSettings")
            else if(call.whatisshown["filter"])
                call.load("filterAccept")
        } else if(keys === "Space") {
            if(variables.slideshowRunning)
                call.load("slideshowPause")
        } else if(keys === "Shift+Enter" || keys === "Shift+Return" || keys === "Shift+Keypad+Enter") {
            if(call.whatisshown["filemanagement"] && variables.filemanagementCurrentCategory == "del")
                call.load("permanentDeleteFile")
        } else if(call.whatisshown["settingsmanager"]) {
            if(keys === "Ctrl+Tab")
                call.load("settingsmanagerNextTab")
            else if(keys === "Ctrl+Shift+Tab")
                call.load("settingsmanagerPrevTab")
            else if(keys === "Ctrl+S")
                call.load("settingsmanagerSave")
            else if(keys === "Alt+1")
                call.load("settingsmanagerGoToTab1")
            else if(keys === "Alt+2")
                call.load("settingsmanagerGoToTab2")
            else if(keys === "Alt+3")
                call.load("settingsmanagerGoToTab3")
            else if(keys === "Alt+4")
                call.load("settingsmanagerGoToTab4")
            else if(keys === "Alt+5")
                call.load("settingsmanagerGoToTab5")
            else if(keys === "Alt+6")
                call.load("settingsmanagerGoToTab6")
        }

    }


    function analyseKeyCombo(combo) {

        if(combo in setKeyShortcuts) {

            var close = setKeyShortcuts[combo][0]
            var cmd = setKeyShortcuts[combo][1]

            executeShortcut(cmd, close)

        }

    }

    function executeShortcut(cmd, close) {

//        if(cmd === "__stopThb")
//            thumbnailBar.stopThumbnails()
        if(cmd === "__close")
            mainwindow.quitPhotoQt()
        else if(cmd === "__hide") {
            if(settings.trayicon)
                mainwindow.hidePhotoQt()
            else
                mainwindow.quitPhotoQt()
        } else if(cmd === "__settings")
                call.show("settingsmanager")
        else if(cmd === "__next")
            Load.loadNext()
        else if(cmd === "__prev")
            Load.loadPrev()
//        if(cmd === "__reloadThb")
//            thumbnailBar.reloadThumbnails()
        else if(cmd === "__about")
            call.show("about")
        else if(cmd === "__slideshow")
            call.show("slideshowsettings")
        else if(cmd === "__filterImages")
            call.show("filter")
        else if(cmd === "__slideshowQuick")
            call.load("slideshowQuickStart")
        else if(cmd === "__open")
            call.show("openfile")
        else if(cmd === "__openOld")
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
            Load.loadFirst()
        else if(cmd === "__gotoLastThb")
            Load.loadLast()
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
            if(call.whatisshown["histogram"])
                call.hide("histogram")
            else
                call.show("histogram")
        } else {
            getanddostuff.executeApp(cmd, variables.currentDir + "/" + variables.currentFile)
            if(close !== undefined && close == true)
                if(settings.trayicon)
                    hidePhotoQt()
                else
                    quitPhotoQt()
        }

    }

    onActiveFocusChanged: {
        if(!variables.textEntryRequired)
            top.forceActiveFocus()
    }
    Connections {
        target: variables
        onTextEntryRequiredChanged: {
            if(!variables.textEntryRequired)
                top.forceActiveFocus()
        }
    }

}
