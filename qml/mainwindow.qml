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
import QtQuick.Window 2.2

import PQHandlingFileDialog 1.0
import PQHandlingGeneral 1.0
import PQHandlingShortcuts 1.0
import PQHandlingFileDir 1.0
import PQHandlingManipulation 1.0
import PQLocalisation 1.0
import PQImageProperties 1.0
import PQFileWatcher 1.0
import PQWindowGeometry 1.0
import PQCppMetaData 1.0
import PQHandlingShareImgur 1.0
import PQHandlingWallpaper 1.0
import PQHandlingFaceTags 1.0
import PQHandlingExternal 1.0
import PQHandlingChromecast 1.0
import PQPrintSupport 1.0

import "./mainwindow"
import "./shortcuts"
import "./menumeta"
import "./histogram"
import "./slideshow"
import "./settingsmanager"
import "./mapview"

Window {

    id: toplevel

    visibility: Window.Hidden
    flags: PQSettings.interfaceWindowDecoration ?
               (PQSettings.interfaceKeepWindowOnTop ? (Qt.Window|Qt.WindowStaysOnTopHint) : Qt.Window) :
               (PQSettings.interfaceKeepWindowOnTop ? (Qt.FramelessWindowHint|Qt.WindowStaysOnTopHint|Qt.Window) : (Qt.FramelessWindowHint|Qt.Window))

    minimumWidth: (variables.visibleItem==""||width<800) ? 600 : ((variables.visibleItem!="settingsmanager" || width < 1024) ? 800 : 1024)
    minimumHeight: (variables.visibleItem==""||height<600) ? 400 : ((variables.visibleItem!="settingsmanager" || height < 768) ? 600 : 768)

    color: "transparent"

    //: The window title of PhotoQt
    title: (filefoldermodel.currentFilePath=="" ? "" : (handlingFileDir.getFileNameFromFullPath(filefoldermodel.currentFilePath) + " | "))+ em.pty+qsTranslate("other", "PhotoQt Image Viewer")

    onClosing: {

        handleBeforeClosing()

        if(PQSettings.interfaceTrayIcon == 1) {
            close.accepted = false
            toplevel.visible = false
            if(PQSettings.interfaceTrayIconHideReset)
                resetPhotoQt()
        } else {
            close.accepted = true
            Qt.quit()
            handlingchromecast.cancelScanForChromecast()
        }
    }

    Component.onCompleted:  {
        start()
    }

    // This needs to be the first item as it paints the background
    PQBackground { id: toplevel_bg }

    PQTrayIcon { id: trayicon }

    PQVariables { id: variables }
    PQBaseLook { id: baselook }
    PQCmdReceived { id: cmdreceived }
    PQLoader { id: loader }
    PQWindowSizePopupManager { id: windowsizepopup }

    // this needs to come BEFORE some of the following items
    // otherwise they will not be able to receive mouse events at all
    PQMainMouseArea { id: mainmousearea }

    PQImage { id: imageitem }
    PQStatusInfo { id: statusinfo }
    PQResetView { id: resetview }
    PQMessage { id: message }
    PQWindowButtons { id: windowbuttons }
    PQWindowButtons { id: windowsbuttons_ontop; visibleAlways: true }

    PQThumbnailBar { id: thumbnails }

    PQContextMenu { id: contextmenu }

    PQModel { id: filefoldermodel }

    Loader { id: histogram }
    Loader { id: mapcurrent }

    Loader { id: metadata }
    Loader { id: navigationfloating }
    Loader { id: mainmenu }

    Loader { id: slideshowsettings }
    Loader { id: slideshowcontrols }
    Loader { id: filedialog }
    Loader { id: mapexplorer }

    Loader { id: filerename }
    Loader { id: filedelete }
    Loader { id: copymove }
    Loader { id: filesaveas }

    Loader { id: scaleimage }
    Loader { id: about }
    Loader { id: imgur }
    Loader { id: wallpaper }
    Loader { id: filter }
    Loader { id: settingsmanager }


    Loader { id: unavailable }
    Loader { id: unavailablepopout }
    Loader { id: logging }

    Loader { id: chromecast }

    Loader { id: advancedsort }
    Loader { id: advancedsortbusy }

    PQImageProperties { id: imageproperties }
    PQFileWatcher { id: filewatcher }

    PQHandlingFileDialog { id: handlingFileDialog }
    PQHandlingGeneral { id: handlingGeneral }
    PQHandlingShortcuts { id: handlingShortcuts }
    PQHandlingFileDir { id: handlingFileDir }
    PQHandlingManipulation { id: handlingManipulation }
    PQHandlingShareImgur { id: handlingShareImgur }
    PQHandlingWallpaper { id: handlingWallpaper }
    PQHandlingFaceTags { id: handlingFaceTags }
    PQHandlingExternal { id: handlingExternal }
    PQHandlingChromecast { id: handlingchromecast }
    PQPrintSupport { id: printsupport }

    PQWindowGeometry { id: windowgeometry }
    PQCppMetaData { id: cppmetadata }

    PQKeyShortcuts { id: shortcuts }
    PQKeyMouseStrings { id: keymousestrings }

    // Localisation handler, allows for runtime switches of languages
    PQLocalisation {
        id : em
        Component.onCompleted:
            em.setLanguage(PQSettings.interfaceLanguage)
    }

    Connections {
        target: PQSettings
        onInterfaceLanguageChanged:
            em.setLanguage(PQSettings.interfaceLanguage)
        onInterfaceWindowModeChanged: {
            if(PQSettings.interfaceWindowMode) {
                toplevel.visibility = Window.Maximized  // calling this only once does not always restore a maximized window but a 'normal' window
                toplevel.visibility = Window.Maximized  // calling it twice has been observed to correct this situation, though ymmv
            } else
                toplevel.visibility = Window.FullScreen
        }
    }

    Connections {
        target: filefoldermodel
        onCurrentFilePathChanged: {
            cppmetadata.updateMetadata(filefoldermodel.currentFilePath)
        }
    }

    function start() {

        if(PQSettings.interfaceWindowMode) {

            if(PQSettings.interfaceSaveWindowGeometry)
                visibility = Window.Windowed

            else if(PQSettings.interfacePopoutMainMenu == 1 &&
                    PQSettings.interfacePopoutMetadata == 1 &&
                    PQSettings.interfacePopoutHistogram == 1 &&
                    PQSettings.interfacePopoutScale == 1 &&
                    PQSettings.interfacePopoutOpenFile == 1 &&
                    PQSettings.interfacePopoutSlideShowSettings == 1 &&
                    PQSettings.interfacePopoutSlideShowControls == 1 &&
                    PQSettings.interfacePopoutFileRename == 1 &&
                    PQSettings.interfacePopoutFileDelete == 1 &&
                    PQSettings.interfacePopoutAbout == 1 &&
                    PQSettings.interfacePopoutImgur == 1 &&
                    PQSettings.interfacePopoutWallpaper == 1 &&
                    PQSettings.interfacePopoutFilter == 1 &&
                    PQSettings.interfacePopoutSettingsManager == 1 &&
                    PQSettings.interfacePopoutFileSaveAs == 1)

                visibility = Window.Windowed

            else
                visibility = Window.Maximized

        } else
            visibility = Window.FullScreen

        if(PQSettings.interfaceSaveWindowGeometry) {

            if(windowgeometry.mainWindowMaximized)

                toplevel.visibility = Window.Maximized

            else {

                toplevel.setX(windowgeometry.mainWindowGeometry.x)
                toplevel.setY(windowgeometry.mainWindowGeometry.y)
                toplevel.setWidth(windowgeometry.mainWindowGeometry.width)
                toplevel.setHeight(windowgeometry.mainWindowGeometry.height)

            }

        }

        loader.ensureItIsReady("mainmenu")
        loader.ensureItIsReady("metadata")

        if(PQSettings.histogramVisible)
            loader.ensureItIsReady("histogram")

        if(PQSettings.mapviewCurrentVisible)
            loader.ensureItIsReady("mapcurrent")

        if(PQSettings.interfaceNavigationFloating)
            loader.ensureItIsReady("navigationfloating")

        var filenameToLoad = handlingGeneral.getLastLoadedImage()

        if(PQPassOn.getFilePath() != "" || (PQSettings.interfaceRememberLastImage && filenameToLoad != "")) {

            if(PQPassOn.getFilePath() != "")
                filenameToLoad = PQPassOn.getFilePath()

            var folderToLoad = handlingFileDir.getFilePathFromFullPath(filenameToLoad)

            if(handlingFileDir.isDir(filenameToLoad)) {
                loader.show("filedialog")
                filefoldermodel.folderFileDialog = filenameToLoad
            } else {
                filefoldermodel.setFileNameOnceReloaded = filenameToLoad
                filefoldermodel.fileInFolderMainView = filenameToLoad
                filefoldermodel.folderFileDialog = folderToLoad
            }

        } else {
            if(PQSettings.openfileKeepLastLocation)
                filefoldermodel.folderFileDialog = handlingFileDialog.getLastLocation()
            else
                filefoldermodel.folderFileDialog = handlingFileDir.getHomeDir()
        }

        setStartupCompleted.start()

    }

    Timer {
        id: setStartupCompleted
        interval: 200
        running: false
        repeat: false
        onTriggered:
            variables.startupCompleted = true
    }


    function handleBeforeClosing() {

        // helps with deleting temporary animated image files on Windows at the end of function
        if(handlingGeneral.amIOnWindows())
            imageitem.resetImageView()

        if(variables.chromecastConnected)
            handlingchromecast.disconnectFromDevice()

        if(variables.slideShowActive)
            loader.passOn("slideshowcontrols", "quit", undefined)

        filefoldermodel.advancedSortMainViewCANCEL()

        if(PQSettings.interfaceSaveWindowGeometry) {
            windowgeometry.mainWindowMaximized = (visibility==Window.Maximized)
            windowgeometry.mainWindowGeometry = Qt.rect(toplevel.x, toplevel.y, toplevel.width, toplevel.height)
        }
        if(filefoldermodel.current > -1 && PQSettings.interfaceRememberLastImage)
            handlingGeneral.setLastLoadedImage(filefoldermodel.currentFilePath)
        else
            handlingGeneral.deleteLastLoadedImage()
        handlingGeneral.cleanUpScreenshotsTakenAtStartup()

        if(handlingGeneral.amIOnWindows())
            handlingFileDir.deleteTemporaryAnimatedImageFiles()

    }

    function quitPhotoQt() {
        handleBeforeClosing()
        Qt.quit()
    }

    function closePhotoQt() {
        close()
    }

    function resetPhotoQt() {
        loader.resetAll()
        imageitem.resetImageView()
        filefoldermodel.resetQMLModel()
        filefoldermodel.resetModel()
        PQPassOn.resetSessionData()
        gc()
    }

}
