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
//            if(about.opacity == 1)
//                about.hideAbout()
//            else
            if(call.whatisshown["settingsmanager"])
                call.hide("settingsmanager")
            else if(call.whatisshown["filemanagement"])
                call.hide("filemanagement")
//            else if(scaleImage.opacity == 1)
//                scaleImage.hideScale()
//            else if(scaleImageUnsupported.opacity == 1)
//                scaleImageUnsupported.hideScaledUnsupported()
//            else if(deleteImage.opacity == 1)
//                deleteImage.hideDelete()
//            else if(rename.opacity == 1)
//                rename.hideRename()
//            else if(wallpaper.opacity == 1)
//                wallpaper.hideWallpaper()
            else if(variables.slideshowRunning)
                call.load("slideshowStop")
//            else if(filter.opacity == 1)
//                filter.hideFilter()
//            else if(startup.opacity == 1)
//                startup.hideStartup()
            else if(call.whatisshown["openfile"])
                call.hide("openfile")
//            else if(imgurfeedback.opacity == 1)
//                imgurfeedback.hide()
        } else if(keys === "Enter" || keys === "Keypad+Enter" || keys === "Return") {
//            if(deleteImage.opacity == 1)
//                deleteImage.simulateEnter()
//            else if(rename.opacity == 1)
//                rename.simulateEnter()
//            else if(wallpaper.opacity == 1)
//                wallpaper.simulateEnter()
//            else if(slideshow.opacity == 1)
//                slideshow.simulateEnter()
//            else if(filter.opacity == 1)
//                filter.simulateEnter()
        } else if(keys === "Space") {
            if(variables.slideshowRunning)
                call.load("slideshowPause")
        } else if(keys === "Shift+Enter" || keys === "Shift+Return" || keys === "Shift+Keypad+Enter") {
//            if(deleteImage.opacity == 1)
//                deleteImage.simulateShiftEnter()
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
//        else if(cmd === "__about")
//            about.showAbout()
        else if(cmd === "__slideshow")
            call.show("slideshowsettings")
//        else if(cmd === "__filterImages")
//            filter.showFilter()
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
//        else if(cmd === "__flipH")
//            mainview.mirrorHorizontal()
//        else if(cmd === "__flipV")
//            mainview.mirrorVertical()
//        else if(cmd === "__rename")
//            rename.showRename()
//        else if(cmd === "__delete")
//            deleteImage.showDelete()
//        else if(cmd === "__deletePermanent")
//            deleteImage.doDirectPermanentDelete()
//        else if(cmd === "__copy")
//            getanddostuff.copyImage(thumbnailBar.currentFile)
//        else if(cmd === "__move")
//            getanddostuff.moveImage(thumbnailBar.currentFile)
        else if(cmd === "__hideMeta") {
            if(metadata.opacity > 0) {
                metadata.uncheckCheckbox()
                metadata.hide()
            } else {
                metadata.checkCheckbox()
                metadata.show()
            }
        }
//        else if(cmd === "__gotoFirstThb")
//            thumbnailBar.gotoFirstImage()
//        else if(cmd === "__gotoLastThb")
//            thumbnailBar.gotoLastImage()

//        else if(cmd === "__wallpaper")
//            wallpaper.showWallpaper()
//        else if(cmd === "__scale")
//            scaleImage.showScale()
//        else if(cmd === "__playPauseAni")
//            mainview.playPauseAnimation()
//        else if(cmd === "__imgur")
//            imgurfeedback.show(false)
//        else if(cmd === "__imgurAnonym")
//            imgurfeedback.show(true)
        else {
            getanddostuff.executeApp(cmd, variables.currentDir + "/" + variables.currentFile)
            if(close !== undefined && close == true)
                if(settings.trayicon)
                    hidePhotoQt()
                else
                    quitPhotoQt()
        }

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
