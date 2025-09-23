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
import QtQuick.Controls
import QtQuick.Layouts
import PhotoQt.CPlusPlus
import PhotoQt.Integrated

ApplicationWindow {

    id: toplevel

    property string titleOverride: ""
    title: titleOverride!="" ?
               (titleOverride + " | PhotoQt") :
               ((PQCFileFolderModel.currentFile==="" ? "" : (PQCScriptsFilesPaths.getFilename(PQCFileFolderModel.currentFile) + " | "))+ "PhotoQt")

    minimumWidth: 300
    minimumHeight: 200

    // if last geometry has been remembered that one is set in the show() function below
    width: 800
    height: 600

    color: pqtPalette.base

    SystemPalette { id: pqtPalette }
    SystemPalette { id: pqtPaletteDisabled; colorGroup: SystemPalette.Disabled }

    // this signals whether the window is currently being resized or not
    onWidthChanged: {
        storeWindowGeometry.restart()
        PQCConstants.availableWidth = width - (PQCSettings.metadataSideBar ? PQCSettings.metadataSideBarWidth : 0)
        PQCConstants.mainWindowBeingResized = true
        resetResizing.restart()
    }
    onHeightChanged: {
        storeWindowGeometry.restart()
        PQCConstants.availableHeight = height-footer.height-menuBar.height
        PQCConstants.mainWindowBeingResized = true
        resetResizing.restart()
    }
    onXChanged: {
        storeWindowGeometry.restart()
    }
    onYChanged: {
        storeWindowGeometry.restart()
    }

    Connections {
        target: PQCSettings
        function onMetadataSideBarWidthChanged() {
            PQCConstants.availableWidth = toplevel.width - (PQCSettings.metadataSideBar ? PQCSettings.metadataSideBarWidth : 0)
        }
        function onMetadataSideBarChanged() {
            PQCConstants.availableWidth = toplevel.width - (PQCSettings.metadataSideBar ? PQCSettings.metadataSideBarWidth : 0)
        }
    }

    Timer {
        id: resetResizing
        interval: 500
        onTriggered: {
            PQCConstants.mainWindowBeingResized = false
        }
    }

    // we store this with a delay to make sure the visibility property is properly updated
    Timer {
        id: storeWindowGeometry
        interval: 200
        onTriggered: {

            if(PQCConstants.photoQtShuttingDown)
                return

            if(toplevel.visibility === Window.Windowed) {
                PQCWindowGeometry.mainWindowGeometry = Qt.rect(toplevel.x, toplevel.y, toplevel.width, toplevel.height)
                PQCWindowGeometry.mainWindowMaximized = false
            } else if(toplevel.visibility === Window.Maximized)
                PQCWindowGeometry.mainWindowMaximized = true

        }

    }

    property bool isFullscreen: toplevel.visibility==Window.FullScreen

    onVisibilityChanged: (visibility) => {

        storeWindowGeometry.restart()

        // we keep track of whether a window is maximized or windowed
        // when restoring the window we then can restore it to the state it was in before
        if(visibility === Window.Maximized)
            PQCConstants.windowMaxAndNotWindowed = true
        else if(visibility === Window.Windowed)
            PQCConstants.windowMaxAndNotWindowed = false

        PQCConstants.windowFullScreen = (visibility === Window.FullScreen)

    }

    // divider between menubar and content
    Rectangle {
        width: parent.width
        height: 1
        color: pqtPaletteDisabled.text
        opacity: 0.5
    }
    // divider between footer and content
    Rectangle {
        y: (parent.height-height)
        width: parent.width
        height: 1
        color: pqtPaletteDisabled.text
        opacity: 0.5
    }

    menuBar: PQMenuBar {}
    footer: PQFooter {}

    Item {
        id: fullscreenitem
        anchors.fill: parent
    }

    Connections {
        target: PQCNotify
        function onResetActiveFocus() {
            fullscreenitem.forceActiveFocus()
        }
    }

    Loader {
        asynchronous: (PQCConstants.startupFilePath!=="")
        sourceComponent: PQBackgroundMessage {
            x: (PQCSettings.metadataSideBar&&PQCSettings.metadataSideBarLocation==="left" ? PQCSettings.metadataSideBarWidth : 0)
            width: PQCConstants.availableWidth
            height: PQCConstants.availableHeight
        }
    }

    /****************************************************/

    Loader {
        active: PQCSettings.metadataSideBar&&PQCSettings.metadataSideBarLocation==="left"
        sourceComponent: PQMetaData {}
    }

    Loader {
        id: imageloader
        asynchronous: true
        active: false
        sourceComponent: PQImage {
            toplevelItem: fullscreenitem
        }
    }

    Loader {
        active: PQCSettings.metadataSideBar&&PQCSettings.metadataSideBarLocation==="right"
        sourceComponent: PQMetaData {
            x: toplevel.width-width
        }
    }

    /****************************************************/

    Loader {
        id: shortcuts
        asynchronous: true
        sourceComponent: PQShortcuts {}
    }

    Loader {
        id: masterloader
        anchors.fill: parent
        asynchronous: true
        sourceComponent: PQLoader {
            onShowExtension: (ele) => {
                masteritemattop.showExtension(ele)
            }
        }
    }

    /****************************************************/

    // This is a Loader that loads the rest of the application in the background after set up
    PQMasterItem {
        id: masteritemattop
    }

    /****************************************************/

    Timer {
        id: setVersion
        interval: 1
        onTriggered:
            PQCSettings.generalVersion = PQCScriptsConfig.getVersion()
    }

    Timer {
        id: loadAppInBackgroundTimer
        interval: 100
        onTriggered:
            masteritemattop.active = true
    }

    // on windows there is a white flash when the window is created
    // thus we set up the window with opacity set to 0
    // and this animation fades the window without white flash
    PropertyAnimation {
        id: showOpacity
        target: toplevel
        property: "opacity"
        from: 0
        to: 1
        duration: 100
    }

    /****************************************************/

    function setXYWidthHeight(geo : rect) {
        toplevel.x = geo.x
        toplevel.y = geo.y
        toplevel.width = geo.width
        toplevel.height = geo.height
    }

    Component.onCompleted: {

        PQCScriptsConfig.updateTranslation(PQCSettings.interfaceLanguage)

        if(PQCScriptsConfig.amIOnWindows() && !PQCConstants.startupStartInTray)
            toplevel.opacity = 0

        // show window according to settings
        if(PQCSettings.interfaceSaveWindowGeometry) {
            var geo = PQCWindowGeometry.mainWindowGeometry
            setXYWidthHeight(geo)
            if(PQCConstants.startupStartInTray) {
                PQCSettings.interfaceTrayIcon = 1
                toplevel.hide()
            } else {
                if(PQCWindowGeometry.mainWindowMaximized)
                    showMaximized()
                else
                    showNormal()
            }
        } else {
            if(PQCConstants.startupStartInTray) {
                PQCSettings.interfaceTrayIcon = 1
                toplevel.hide()
            } else
                showMaximized()
        }

        if(PQCConstants.startupFilePath !== "") {
            // in the case of a FOLDER passed on we actually need to load the files first to get the first one:
            if(PQCConstants.startupFileIsFolder)
                PQCFileFolderModel.fileInFolderMainView = PQCConstants.startupFilePath
        } else if(PQCSettings.interfaceRememberLastImage) {
            PQCConstants.startupFilePath = PQCScriptsConfig.getLastLoadedImage()
            PQCConstants.startupFileIsFolder = PQCScriptsFilesPaths.isFolder(PQCConstants.startupFilePath)
        }

        // this comes after the above to make sure we load a potentially passed-on image
        imageloader.active = true

        if(PQCScriptsConfig.amIOnWindows() && !PQCConstants.startupStartInTray)
            showOpacity.restart()

        if(PQCConstants.startupFilePath === "")
            loadAppInBackgroundTimer.triggered()
        else
            loadAppInBackgroundTimer.start()

        setVersion.start()

    }

    Connections {

        target: PQCConstants

        function onStartupFilePathChanged() : void {
            console.log("")
            PQCFileFolderModel.fileInFolderMainView = PQCConstants.startupFilePath
            if(!toplevel.visible)
                toplevel.visible = true
            if(toplevel.visibility === Window.Minimized)
                toplevel.visibility = (PQCConstants.windowMaxAndNotWindowed ? Window.Maximized : Window.Windowed)
            toplevel.raise()
            toplevel.requestActivate()
        }

    }

    Connections {

        target: PQCNotify

        function onStartInTrayChanged() : void {

            console.log("")

            if(PQCConstants.startupStartInTray)
                PQCSettings.interfaceTrayIcon = 1
            else if(!PQCConstants.startupStartInTray && PQCSettings.interfaceTrayIcon === 1)
                PQCSettings.interfaceTrayIcon = 0

        }

        function onCmdOpen() : void {
            console.log("")
            PQCNotify.loaderShow("FileDialog")
        }

        function onCmdShow() : void {

            console.log("")

            if(toplevel.visible) {
                toplevel.raise()
                toplevel.requestActivate()
                return
            }

            toplevel.visible = true
            if(toplevel.visibility === Window.Minimized)
                toplevel.visibility = (PQCConstants.windowMaxAndNotWindowed ? Window.Maximized : Window.Windowed)
            toplevel.raise()
            toplevel.requestActivate()

        }

        function onCmdHide() : void {
            console.log("")
            PQCSettings.interfaceTrayIcon = 1
            toplevel.close()
        }

        function onCmdQuit() : void {
            console.log("")
            toplevel.quitPhotoQt()
        }

        function onCmdToggle() : void {

            console.log("")

            if(toplevel.visible) {
                PQCSettings.interfaceTrayIcon = 1
                toplevel.close()
            } else {
                toplevel.visible = true
                if(toplevel.visibility === Window.Minimized)
                    toplevel.visibility = (PQCConstants.windowMaxAndNotWindowed ? Window.Maximized : Window.Windowed)
                toplevel.raise()
                toplevel.requestActivate()
            }

        }

        function onCmdTray(enabled : bool) : void {

            console.log("args: enabled =", enabled)

            if(enabled && PQCSettings.interfaceTrayIcon === 0)
                PQCSettings.interfaceTrayIcon = 2
            else if(!enabled) {
                PQCSettings.interfaceTrayIcon = 0
                if(!toplevel.visible) {
                    toplevel.visible = true
                    if(toplevel.visibility === Window.Minimized)
                        toplevel.visibility = (PQCConstants.windowMaxAndNotWindowed ? Window.Maximized : Window.Windowed)
                    toplevel.raise()
                    toplevel.requestActivate()
                }
            }

        }

        function onWindowRaiseAndFocus() {
            toplevel.raise()
            toplevel.requestActivate()
        }

        function onWindowClose() {
            toplevel.close()
        }

        function onWindowTitleOverride(title : string) {
            toplevel.titleOverride = title
        }

        function onWindowStartSystemMove() {
            toplevel.startSystemMove()
        }

        function onWindowStartSystemResize(edge : int) {
            toplevel.startSystemResize(edge)
        }

        function onPhotoQtQuit() {
            toplevel.quitPhotoQt()
        }

    }

    function handleBeforeClosing() {

        PQCFileFolderModel.advancedSortMainViewCANCEL()

        if(PQCFileFolderModel.currentIndex > -1 && PQCSettings.interfaceRememberLastImage)
            PQCScriptsConfig.setLastLoadedImage(PQCFileFolderModel.currentFile)
        else
            PQCScriptsConfig.deleteLastLoadedImage()

        PQCScriptsFilesPaths.cleanupTemporaryFiles()

        PQCScriptsOther.deleteScreenshots()

    }

    onClosing: (close) => {

        PQCConstants.photoQtShuttingDown = true

        // We stop a running slideshow to make sure all settings are restored to their normal state
        if(PQCConstants.slideshowRunning)
            PQCNotify.slideshowHideHandler()

        if(PQCSettings.interfaceTrayIcon === 1) {
            close.accepted = false
            toplevel.visibility = Window.Hidden
            if(PQCSettings.interfaceTrayIconHideReset)
                PQCNotify.resetSessionData()
            PQCConstants.photoQtShuttingDown = false
        } else {
            close.accepted = true
            quitPhotoQt()
        }
    }

    function quitPhotoQt() {
        handleBeforeClosing()
        Qt.quit()
    }

}
