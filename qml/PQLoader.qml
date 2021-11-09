/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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

import QtQuick 2.9

Item {

    id: load_top

    signal mainmenuPassOn(var what, var param)
    signal metadataPassOn(var what, var param)
    signal filedialogPassOn(var what, var param)
    signal slideshowPassOn(var what, var param)
    signal slideshowControlsPassOn(var what, var param)
    signal fileRenamePassOn(var what, var param)
    signal fileDeletePassOn(var what, var param)
    signal copyMoveFilePassOn(var what, var param)
    signal scalePassOn(var what, var param)
    signal aboutPassOn(var what, var param)
    signal imgurPassOn(var what, var param)
    signal wallpaperPassOn(var what, var param)
    signal filterPassOn(var what, var param)
    signal faceTaggerPassOn(var what, var param)
    signal settingsManagerPassOn(var what, var param)
    signal fileSaveAsPassOn(var what, var param)
    signal quickNavigationPassOn(var what, var param)
    signal unavailablePassOn(var what, var param)
    signal unavailablePopoutPassOn(var what, var param)
    signal chromecastPassOn(var what, var param)

    function show(ele) {

        // This is used to mask features that are not (yet) available on Windows
        if(handlingGeneral.amIOnWindows()) {
            if(ele == "wallpaper") {
                if(PQSettings.interfacePopoutWallpaper)
                    ele = "unavailablepopout"
                else
                    ele = "unavailable"
            }
        }

        ensureItIsReady(ele)

        if(ele == "filedialog")
            filedialogPassOn("show", undefined)

        else if(ele == "mainmenu")
            mainmenuPassOn("show", undefined)

        else if(ele == "metadata")
            metadataPassOn("show", undefined)

        else if(ele == "slideshowsettings")
            slideshowPassOn("show", undefined)

        else if(ele == "slideshowcontrols")
            slideshowControlsPassOn("show", undefined)

        else if(ele == "filerename")
            fileRenamePassOn("show", undefined)

        else if(ele == "filedelete")
            fileDeletePassOn("show", undefined)

        else if(ele == "scale")
            scalePassOn("show", undefined)

        else if(ele == "about")
            aboutPassOn("show", undefined)

        else if(ele == "imgur")
            imgurPassOn("show", undefined)

        else if(ele == "imguranonym")
            imgurPassOn("show_anonym", undefined)

        else if(ele == "wallpaper")
            wallpaperPassOn("show", undefined)

        else if(ele == "filter")
            filterPassOn("show", undefined)

        else if(ele == "settingsmanager")
            settingsManagerPassOn("show", undefined)

        else if(ele == "filesaveas")
            fileSaveAsPassOn("show", undefined)

        else if(ele == "unavailable")
            unavailablePassOn("show", undefined)

        else if(ele == "unavailablepopout")
            unavailablePopoutPassOn("show", undefined)

        else if(ele == "quicknavigation")
            quickNavigationPassOn("show", undefined)

        else if(ele == "chromecast")
            chromecastPassOn("show", undefined)

    }

    function passOn(ele, what, param) {

        if(ele == "mainmenu")
            mainmenuPassOn(what, param)

        else if(ele == "metadata")
            metadataPassOn(what, param)

        else if(ele == "filedialog")
            filedialogPassOn(what, param)

        else if(ele == "slideshowsettings")
            slideshowPassOn(what, param)

        else if(ele == "slideshowcontrols")
            slideshowControlsPassOn(what, param)

        else if(ele == "filedelete")
            fileDeletePassOn(what, param)

        else if(ele == "filerename")
            fileRenamePassOn(what, param)

        else if(ele == "scale")
            scalePassOn(what, param)

        else if(ele == "about")
            aboutPassOn(what, param)

        else if(ele == "imgur" || ele == "imguranonym")
            imgurPassOn(what, param)

        else if(ele == "wallpaper")
            wallpaperPassOn(what, param)

        else if(ele == "settingsmanager")
            settingsManagerPassOn(what, param)

        else if(ele == "filter")
            filterPassOn(what, param)

        else if(ele == "facetagger")
            faceTaggerPassOn(what, param)

        else if(ele == "copymove")
            copyMoveFilePassOn(what, param)

        else if(ele == "unavailable")
            unavailablePassOn(what, param)

        else if(ele == "quicknavigation")
            quickNavigationPassOn(what, param)

        else if(ele == "chromecast")
            chromecastPassOn(what, param)

    }

    function passKeyEvent(ele, key, mod) {

        ensureItIsReady(ele)

        if(ele == "mainmenu")
            mainmenuPassOn("keyevent", [key, mod])

        else if(ele == "metadata")
            metadataPassOn("keyevent", [key, mod])

        else if(ele == "filedialog")
            filedialogPassOn("keyevent", [key, mod])

        else if(ele == "slideshowsettings")
            slideshowPassOn("keyevent", [key, mod])

        else if(ele == "slideshowcontrols")
            slideshowControlsPassOn("keyevent", [key, mod])

        else if(ele == "filedelete")
            fileDeletePassOn("keyevent", [key, mod])

        else if(ele == "filerename")
            fileRenamePassOn("keyevent", [key, mod])

        else if(ele == "scale")
            scalePassOn("keyevent", [key, mod])

        else if(ele == "about")
            aboutPassOn("keyevent", [key, mod])

        else if(ele == "imgur" || ele == "imguranonym")
            imgurPassOn("keyevent", [key, mod])

        else if(ele == "wallpaper")
            wallpaperPassOn("keyevent", [key, mod])

        else if(ele == "filter")
            filterPassOn("keyevent", [key, mod])

        else if(ele == "facetagger")
            faceTaggerPassOn("keyevent", [key, mod])

        else if(ele == "settingsmanager")
            settingsManagerPassOn("keyevent", [key, mod])

        else if(ele == "filesaveas")
            fileSaveAsPassOn("keyevent", [key, mod])

        else if(ele == "unavailable")
            unavailablePassOn("keyevent", [key, mod])

        else if(ele == "unavailablepopout")
            unavailablePopoutPassOn("keyevent", [key, mod])

        else if(ele == "quicknavigation")
            quickNavigationPassOn("keyevent", [key, mod])

        else if(ele == "chromecast")
            chromecastPassOn("keyevent", [key, mod])

    }

    function ensureItIsReady(ele) {

        if(ele == "mainmenu") {

            if(PQSettings.interfacePopoutMainMenu && mainmenu.source != "menumeta/PQMainMenuPopout.qml")
                mainmenu.source = "menumeta/PQMainMenuPopout.qml"

             else if(!PQSettings.interfacePopoutMainMenu && mainmenu.source != "menumeta/PQMainMenu.qml")
                mainmenu.source = "menumeta/PQMainMenu.qml"

        } else if(ele == "metadata") {

            if(PQSettings.interfacePopoutMetadata && metadata.source != "menumeta/PQMetaDataPopout.qml")
                metadata.source = "menumeta/PQMetaDataPopout.qml"

             else if(!PQSettings.interfacePopoutMetadata && metadata.source != "menumeta/PQMetaData.qml")
                metadata.source = "menumeta/PQMetaData.qml"

        } else if(ele == "filedialog") {

            if(PQSettings.interfacePopoutOpenFile && filedialog.source != "filedialog/PQFileDialogPopout.qml")
                filedialog.source = "filedialog/PQFileDialogPopout.qml"

            else if(!PQSettings.interfacePopoutOpenFile && filedialog.source != "filedialog/PQFileDialog.qml")
                filedialog.source = "filedialog/PQFileDialog.qml"

        } else if(ele == "histogram") {

            if(PQSettings.interfacePopoutHistogram && histogram.source != "histogram/PQHistogramPopout.qml")
                histogram.source = "histogram/PQHistogramPopout.qml"

            else if(!PQSettings.interfacePopoutHistogram && histogram.source != "histogram/PQHistogram.qml")
                histogram.source = "histogram/PQHistogram.qml"

        } else if(ele == "slideshowsettings") {

            if(PQSettings.interfacePopoutSlideShowSettings && slideshowsettings.source != "slideshow/PQSlideShowSettingsPopout.qml")
                slideshowsettings.source = "slideshow/PQSlideShowSettingsPopout.qml"

            else if(!PQSettings.interfacePopoutSlideShowSettings && slideshowsettings.source != "slideshow/PQSlideShowSettings.qml")
                slideshowsettings.source = "slideshow/PQSlideShowSettings.qml"

        } else if(ele == "slideshowcontrols") {

            if(PQSettings.interfacePopoutSlideShowControls && slideshowcontrols.source != "slideshow/PQSlideShowControlsPopout.qml")
                slideshowcontrols.source = "slideshow/PQSlideShowControlsPopout.qml"

            else if(!PQSettings.interfacePopoutSlideShowControls && slideshowcontrols.source != "slideshow/PQSlideShowControls.qml")
                slideshowcontrols.source = "slideshow/PQSlideShowControls.qml"

        } else if(ele == "filerename") {

            if(PQSettings.interfacePopoutFileRename && filerename.source != "filemanagement/PQRenamePopout.qml")
                filerename.source = "filemanagement/PQRenamePopout.qml"

            else if(!PQSettings.interfacePopoutFileRename && filerename.source != "filemanagement/PQRename.qml")
                filerename.source = "filemanagement/PQRename.qml"

        } else if(ele == "filedelete") {

            if(PQSettings.interfacePopoutFileDelete && filedelete.source != "filemanagement/PQDeletePopout.qml")
                filedelete.source = "filemanagement/PQDeletePopout.qml"

            else if(!PQSettings.interfacePopoutFileDelete && filedelete.source != "filemanagement/PQDelete.qml")
                filedelete.source = "filemanagement/PQDelete.qml"

        } else if(ele == "scale") {

            if(PQSettings.interfacePopoutScale && scaleimage.source != "scale/PQScalePopout.qml")
                scaleimage.source = "scale/PQScalePopout.qml"

            else if(!PQSettings.interfacePopoutScale && scaleimage.source != "scale/PQScale.qml")
                scaleimage.source = "scale/PQScale.qml"

        } else if(ele == "about") {

            if(PQSettings.interfacePopoutAbout && about.source != "about/PQAboutPopout.qml")
                about.source = "about/PQAboutPopout.qml"

            else if(!PQSettings.interfacePopoutAbout && about.source != "about/PQAbout.qml")
                about.source = "about/PQAbout.qml"

        } else if(ele == "imgur" || ele == "imguranonym") {

            if(PQSettings.interfacePopoutImgur && imgur.source != "imgur/PQImgurPopout.qml")
                imgur.source = "imgur/PQImgurPopout.qml"

            else if(!PQSettings.interfacePopoutImgur && imgur.source != "imgur/PQImgur.qml")
                imgur.source = "imgur/PQImgur.qml"

        } else if(ele == "wallpaper") {

            if(PQSettings.interfacePopoutWallpaper && wallpaper.source != "wallpaper/PQWallpaperPopout.qml")
                wallpaper.source = "wallpaper/PQWallpaperPopout.qml"

            else if(!PQSettings.interfacePopoutWallpaper && wallpaper.source != "wallpaper/PQWallpaper.qml")
                wallpaper.source = "wallpaper/PQWallpaper.qml"

        } else if(ele == "filter") {

            if(PQSettings.interfacePopoutFilter && filter.source != "filter/PQFilterPopout.qml")
                filter.source = "filter/PQFilterPopout.qml"

            else if(!PQSettings.interfacePopoutFilter && filter.source != "filter/PQFilter.qml")
                filter.source = "filter/PQFilter.qml"

        } else if(ele == "settingsmanager") {

            if(PQSettings.interfacePopoutSettingsManager && settingsmanager.source != "settingsmanager/PQSettingsManagerPopout.qml")
                settingsmanager.source = "settingsmanager/PQSettingsManagerPopout.qml"

            else if(!PQSettings.interfacePopoutSettingsManager && settingsmanager.source != "settingsmanager/PQSettingsManager.qml")
                settingsmanager.source = "settingsmanager/PQSettingsManager.qml"

        } else if(ele == "copymove") {

            if(copymove.source != "filemanagement/PQCopyMove.qml")
                copymove.source = "filemanagement/PQCopyMove.qml"

        } else if(ele == "filesaveas") {

            if(PQSettings.interfacePopoutFileSaveAs && filesaveas.source != "filemanagement/PQSaveAsPopout.qml")
                filesaveas.source = "filemanagement/PQSaveAsPopout.qml"

            else if(!PQSettings.interfacePopoutFileSaveAs && filesaveas.source != "filemanagement/PQSaveAs.qml")
                filesaveas.source = "filemanagement/PQSaveAs.qml"

        } else if(ele == "chromecast") {

            if(PQSettings.interfacePopoutChromecast && chromecast.source != "chromecast/PQChromecastPopout.qml")
                chromecast.source = "chromecast/PQChromecastPopout.qml"

            else if(!PQSettings.interfacePopoutChromecast && chromecast.source != "chromecast/PQChromecast.qml")
                chromecast.source = "chromecast/PQChromecast.qml"

        } else if(ele == "quicknavigation") {

            quicknavigation.source = "mainwindow/PQNavigation.qml"

        } else if(ele == "unavailable") {

            unavailable.source = "unavailable/PQUnavailable.qml"

        } else if(ele == "unavailablepopout") {

            unavailablepopout.source = "unavailable/PQUnavailablePopout.qml"

        }

    }

}
