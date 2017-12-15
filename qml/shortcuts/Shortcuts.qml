import QtQuick 2.6
import "./keyshortcuts.js" as AnalyseKeys

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

    signal shortcutReceived(var combo)

    Keys.onPressed: {

        var combostring = AnalyseKeys.analyseEvent(event)

        checkForSystemShortcut(combostring)
        if(!variables.guiBlocked)
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
//            else if(slideshow.opacity == 1)
//                slideshow.hideSlideshow()
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
//            if(slideshowRunning) {
//                slideshowbar.pauseSlideshow()
//                if(!slideshowbar.paused) slideshowbar.hideBar()
//            }
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
//        if(cmd === "__close")
//            quitPhotoQt()
//        else if(cmd === "__hide") {
//            if(settings.trayicon)
//                hideToSystemTray()
//            else
//                quitPhotoQt()
//        } else
            if(cmd === "__settings")
                call.show("settingsmanager")
        else if(cmd === "__next")
                call.load("loadnext")
        else if(cmd === "__prev")
                call.load("loadprev")
//        if(cmd === "__reloadThb")
//            thumbnailBar.reloadThumbnails()
//        else if(cmd === "__about")
//            about.showAbout()
//        else if(cmd === "__slideshow")
//            slideshow.showSlideshow()
//        else if(cmd === "__filterImages")
//            filter.showFilter()
//        else if(cmd === "__slideshowQuick")
//            slideshow.quickstart()
        else if(cmd === "__open")
            call.show("openfile")
        else if(cmd === "__openOld")
            call.show("openfile")
//        else if(cmd === "__zoomIn")
//            mainview.zoomIn(!bymouse)
//        else if(cmd === "__zoomOut")
//            mainview.zoomOut(!bymouse)
//        else if(cmd === "__zoomReset")
//            mainview.resetZoom()
//        else if(cmd === "__zoomActual")
//            mainview.zoomActual()
//        else if(cmd === "__rotateL")
//            mainview.rotateLeft()
//        else if(cmd === "__rotateR")
//            mainview.rotateRight()
//        else if(cmd === "__rotate0")
//            mainview.resetRotation()
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
//        else if(cmd === "__hideMeta") {
//            if(metaData.x < -40) {
//                metaData.checkCheckbox()
//                background.showMetadata()
//            } else {
//                metaData.uncheckCheckbox()
//                background.hideMetadata()
//            }
//        } else if(cmd === "__gotoFirstThb")
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
//        else {
//            getanddostuff.executeApp(cmd,thumbnailBar.currentFile)
//            if(close !== undefined && close == true)
//                if(settings.trayicon)
//                    hideToSystemTray()
//                else
//                    quitPhotoQt()
        }

    }

    onActiveFocusChanged:
        top.forceActiveFocus()

}
