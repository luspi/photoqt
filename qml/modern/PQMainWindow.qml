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
import PhotoQt.CPlusPlus
import PhotoQt.Modern

Window {

    id: toplevel

    flags: PQCSettings.interfaceWindowDecoration ?
               (PQCSettings.interfaceKeepWindowOnTop ? (Qt.Window|Qt.WindowStaysOnTopHint|Qt.WindowTitleHint|Qt.WindowMinMaxButtonsHint|Qt.WindowCloseButtonHint) : Qt.Window) :
               (PQCSettings.interfaceKeepWindowOnTop ? (Qt.FramelessWindowHint|Qt.WindowStaysOnTopHint|Qt.Window|Qt.WindowMinMaxButtonsHint|Qt.WindowCloseButtonHint) : (Qt.FramelessWindowHint|Qt.Window|Qt.WindowMinMaxButtonsHint))

    color: "transparent"

    property string titleOverride: ""
    title: titleOverride!="" ?
               (titleOverride + " | PhotoQt") :
               ((PQCFileFolderModel.currentFile==="" ? "" : (PQCScriptsFilesPaths.getFilename(PQCFileFolderModel.currentFile) + " | "))+ "PhotoQt")

    minimumWidth: 300
    minimumHeight: 200

    // if last geometry has been remembered that one is set in the show() function below
    width: 800
    height: 600

    // this signals whether the window is currently being resized or not
    onWidthChanged: {
        storeWindowGeometry.restart()
        PQCConstants.availableWidth = width
        PQCConstants.mainWindowBeingResized = true
        resetResizing.restart()
    }
    onHeightChanged: {
        storeWindowGeometry.restart()
        PQCConstants.availableHeight = height
        PQCConstants.mainWindowBeingResized = true
        resetResizing.restart()
    }
    onXChanged: {
        storeWindowGeometry.restart()
    }
    onYChanged: {
        storeWindowGeometry.restart()
    }

    Timer {
        id: resetResizing
        interval: 500
        onTriggered: {
            PQCConstants.mainWindowBeingResized = false
        }
    }

    // we store this with a delay to make sure the visibility properyt is properly updated
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

    PQMainWindowBackground {
        id: fullscreenitem
        anchors.fill: parent
    }

    Connections {
        target: PQCNotify
        function onResetActiveFocus() {
            fullscreenitem.forceActiveFocus()
        }
    }

    // we register clicks right away (if no image was passed on)
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        enabled: !masteritemattop.backgroundMessageReady && PQCConstants.startupFilePath===""
        onClicked: {
            PQCNotify.loaderShow("FileDialog")
        }
    }

    /****************************************************/

    // very cheap to set up, many properties needed everywhere -> no loader
    Loader {
        id: imageloader
        asynchronous: true
        active: false
        sourceComponent: PQImage {
            toplevelItem: fullscreenitem
        }
    }

    /****************************************************/

    Loader {
        id: shortcuts
        asynchronous: true
        sourceComponent: PQShortcuts {}
    }

    /****************************************************/
    /****************************************************/

    // This is a Loader that loads the rest of the application in the background after set up
    PQMasterItem {
        id: masteritemattop
    }

    Timer {
        id: loadAppInBackgroundTimer
        interval: 100
        onTriggered:
            masteritemattop.active = true
    }

    Connections {
        target: PQCConstants
        enabled: PQCConstants.startupFilePath!==""&&!PQCConstants.startupFileIsFolder
        function onImageInitiallyLoadedChanged() {
            if(PQCConstants.imageInitiallyLoaded)
                masteritemattop.active = true
        }
    }

    /****************************************************/

    Item {
        id: fullscreenitem_foreground
        anchors.fill: parent
    }

    /****************************************************/

    // this is called only when triggered from status info
    // if this is not done with a short delay then the state is not applied properly
    Timer {
        id: setStateTimer
        interval: 100
        property int newstate
        onTriggered: {
            toplevel.visibility = newstate
        }
    }

    Timer {
        id: setVersion
        interval: 1
        onTriggered:
            PQCSettings.generalVersion = PQCScriptsConfig.getVersion()
    }

    /****************************************************/

    function setXYWidthHeight(geo : rect) {
        toplevel.x = geo.x
        toplevel.y = geo.y
        toplevel.width = geo.width
        toplevel.height = geo.height
    }

    Component.onCompleted: {

        PQCScriptsLocalization.updateTranslation(PQCSettings.interfaceLanguage)

        if(PQCScriptsConfig.amIOnWindows() && !PQCConstants.startupStartInTray)
            toplevel.opacity = 0

        // show window according to settings
        if(PQCSettings.interfaceWindowMode) {
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
        } else {
            if(PQCConstants.startupStartInTray) {
                PQCSettings.interfaceTrayIcon = 1
                toplevel.hide()
            } else
                showFullScreen()
        }

        PQCNotify.loaderShow("MainMenu")
        PQCNotify.loaderShow("MetaData")

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

        target: PQCSettings

        function onInterfaceWindowModeChanged() {
            toplevel.visibility = (PQCSettings.interfaceWindowMode ? (PQCConstants.windowMaxAndNotWindowed ? Window.Maximized : Window.Windowed) : Window.FullScreen)
        }

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

        target: PQCReceiveMessages

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

        function onCmdSetStartInTray() : void {

            console.log("")

            if(PQCConstants.startupStartInTray)
                PQCSettings.interfaceTrayIcon = 1
            else if(!PQCConstants.startupStartInTray && PQCSettings.interfaceTrayIcon === 1)
                PQCSettings.interfaceTrayIcon = 0

        }

    }

    Connections {

        target: PQCNotify

        function onSetWindowState(state : int) {
            setStateTimer.newstate = state
            setStateTimer.restart()
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

    /*************************************************/

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

}
