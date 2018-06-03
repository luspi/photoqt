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

Item {

    /***********************************************************/
    /***********************************************************/
    // These signals are used to interact with loaded elements.

    signal openfileShow()
    signal openfileNavigateToCurrentDir(var dir)

    signal thumbnailsShow()
    signal thumbnailsHide()
    signal thumbnailsLoadDirectory()

    signal settingsmanagerShow()

    signal slideshowSettingsShow()
    signal slideshowBarShow()
    signal slideshowBarHide()
    signal slideshowStart()

    signal histogramShow()
    signal histogramHide()

    signal filemanagementShow(var category)

    signal aboutShow()

    signal imgurfeedbackShow()
    signal imgurfeedbackAnonymShow()

    signal filterShow()

    signal wallpaperShow()

    signal scaleShow()
    signal scaleunsupportedShow()

    signal startupShow(var type, var filename)

    signal shortcut(var sh)
    signal keysReleased()

    signal closeAnyElement()

    signal tagFaces()

    /***********************************************************/
    /***********************************************************/

    // Load and show a component
    function show(component) {

        getanddostuff.setBusyCursor(true)

        verboseMessage("Caller","show(): " + component)

        ensureElementSetup(component)

        if(component === "openfile")
            openfileShow()
        else if(component === "thumbnails")
            thumbnailsShow()
        else if(component === "settingsmanager")
            settingsmanagerShow()
        else if(component === "slideshowsettings")
            slideshowSettingsShow()
        else if(component === "slideshowbar")
            slideshowBarShow()
        else if(component === "histogram")
            histogramShow()
        else if(component === "about")
            aboutShow()
        else if(component === "imgurfeedback")
            imgurfeedbackShow()
        else if(component === "imgurfeedbackanonym")
            imgurfeedbackAnonymShow()
        else if(component === "filter")
            filterShow()
        else if(component === "wallpaper")
            wallpaperShow()
        else if(component === "scale")
            scaleShow()
        else if(component === "scaleunsupported")
            scaleunsupportedShow()
        else if(component === "startup")
            startupShow(variables.startupUpdateStatus, variables.startupFilenameAfter)
        else
            console.error("ERROR: Requested faulty show():", component)

        getanddostuff.setBusyCursor(false)

    }

    // Hide a component
    function hide(component) {

        verboseMessage("Caller","hide(): " + component)

        if(component === "thumbnails")
            thumbnailsHide()
        else if(component === "slideshowbar")
            slideshowBarHide()
        else if(component === "histogram")
            histogramHide()
        else
            console.error("ERROR: Requested faulty hide():", component)
    }

    // Load some function
    function load(func) {

        verboseMessage("Caller","load(): " + func)

        if(func === "thumbnailLoadDirectory")
            thumbnailsLoadDirectory()
        else if(func === "slideshowStart") {
            ensureElementSetup("slideshowbar")
            slideshowStart()
        } else if(func === "filemanagementCopyShow") {
            ensureElementSetup("filemanagement")
            filemanagementShow("cp")
        } else if(func === "filemanagementDeleteShow") {
            ensureElementSetup("filemanagement")
            filemanagementShow("del")
        } else if(func === "filemanagementMoveShow") {
            ensureElementSetup("filemanagement")
            filemanagementShow("mv")
        } else if(func === "filemanagementRenameShow") {
            ensureElementSetup("filemanagement")
            filemanagementShow("rn")
        } else if(func === "keysReleased")
            keysReleased()
        else if(func === "closeAnyElement")
            closeAnyElement()
        else if(func === "openfileNavigateToCurrentDir")
            openfileNavigateToCurrentDir(variables.currentDir)
        else
            console.error("ERROR: Requested faulty load():", func)
    }

    function passOnShortcut(sh) {
        verboseMessage("Caller","passOnShortcut(): " + sh)
        shortcut(sh)
    }

    function requestTagFaces() {
        tagFaces()
    }

    function ensureElementSetup(component) {

        verboseMessage("Caller","ensureElementSetup()" + component)

        // We do this weird double if statement to be able to catch any faulty call at the end
        if(component === "openfile") {
            if(openfile.status == Loader.Null)
                openfile.source = "openfile/OpenFile.qml"
        } else if(component === "thumbnails") {
            if(thumbnails.status == Loader.Null)
                thumbnails.source = "mainview/Thumbnails.qml"
        } else if(component === "settingsmanager") {
            if(settingsmanager.status == Loader.Null)
                settingsmanager.source = "settingsmanager/SettingsManager.qml"
        } else if(component === "slideshowsettings") {
            if(slideshowsettings.status == Loader.Null)
                slideshowsettings.source = "slideshow/SlideshowSettings.qml"
        } else if(component === "slideshowbar") {
            if(slideshowbar.status == Loader.Null)
                slideshowbar.source = "slideshow/SlideshowBar.qml"
        } else if(component === "histogram") {
            if(histogram.status == Loader.Null)
                histogram.source = "mainview/Histogram.qml"
        } else if(component === "filemanagement") {
            if(filemanagement.status == Loader.Null)
                filemanagement.source = "filemanagement/Management.qml"
        } else if(component === "about") {
            if(about.status == Loader.Null)
                about.source = "other/About.qml"
        } else if((component === "imgurfeedback" || component === "imgurfeedbackanonym")) {
            if(imgurfeedback.status == Loader.Null)
                imgurfeedback.source = "other/ImgurFeedback.qml"
        } else if(component === "filter") {
            if(filter.status == Loader.Null)
                filter.source = "other/Filter.qml"
        } else if(component === "wallpaper") {
            if(wallpaper.status == Loader.Null)
                wallpaper.source = "wallpaper/Wallpaper.qml"
        } else if(component === "scale") {
            if(scaleimage.status == Loader.Null)
                scaleimage.source = "other/Scale.qml"
        } else if(component === "scaleunsupported") {
            if(scaleimageunsupported.status == Loader.Null)
                scaleimageunsupported.source = "other/ScaleUnsupported.qml"
        } else if(component === "startup") {
            if(startup.status == Loader.Null)
                startup.source = "other/Startup.qml"
        } else
            console.error("ERROR: Requested faulty ensureElementSetup():", component)

    }

}
