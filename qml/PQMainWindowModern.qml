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
import PQCFileFolderModel
import PQCScriptsFilesPaths
import PQCScriptsConfig
import PhotoQt

Window {

    id: toplevel

    flags: PQCSettings.interfaceWindowDecoration ? // qmllint disable unqualified
               (PQCSettings.interfaceKeepWindowOnTop ? (Qt.Window|Qt.WindowStaysOnTopHint|Qt.WindowTitleHint|Qt.WindowMinMaxButtonsHint) : Qt.Window) :
               (PQCSettings.interfaceKeepWindowOnTop ? (Qt.FramelessWindowHint|Qt.WindowStaysOnTopHint|Qt.Window|Qt.WindowMinMaxButtonsHint) : (Qt.FramelessWindowHint|Qt.Window|Qt.WindowMinMaxButtonsHint))

    color: "transparent"

    property string titleOverride: ""
    title: titleOverride!="" ?
               (titleOverride + " | PhotoQt") :
               ((PQCFileFolderModel.currentFile==="" ? "" : (PQCScriptsFilesPaths.getFilename(PQCFileFolderModel.currentFile) + " | "))+ "PhotoQt") // qmllint disable unqualified

    minimumWidth: 300
    minimumHeight: 200

    // if last geometry has been remembered that one is set in the show() function below
    width: 800
    height: 600

    // this signals whether the window is currently being resized or not
    property bool resizing: false
    onWidthChanged: {
        storeWindowGeometry.restart()
        PQCConstants.windowWidth = width
        resizing = true
        resetResizing.restart()
    }
    onHeightChanged: {
        storeWindowGeometry.restart()
        PQCConstants.windowHeight = height
        resizing = true
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
            toplevel.resizing = false
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

    // we register clicks right away (if no image was passed on)
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        enabled: !masteritemattop.backgroundMessageReady && PQCConstants.startupFileLoad===""
        onClicked: {
            PQCNotify.loaderShow("filedialog")
        }
    }

    /****************************************************/

    // very cheap to set up, many properties needed everywhere -> no loader
    Loader {
        id: imageloader
        asynchronous: true
        active: false
        source: "modern/image/PQImage.qml"
    }

    /****************************************************/

    Loader {
        id: shortcuts
        asynchronous: true
        source: "modern/other/PQShortcuts.qml"
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
        enabled: PQCConstants.startupFileLoad!==""
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

    Component.onCompleted: {

        PQCScriptsConfig.updateTranslation() // qmllint disable unqualified

        if(PQCScriptsConfig.amIOnWindows() && !PQCNotify.startInTray)
            toplevel.opacity = 0

        // show window according to settings
        if(PQCSettings.interfaceWindowMode) {
            if(PQCSettings.interfaceSaveWindowGeometry) {
                var geo = PQCWindowGeometry.mainWindowGeometry
                toplevel.x = geo.x
                toplevel.y = geo.y
                toplevel.width = geo.width
                toplevel.height = geo.height
                if(PQCNotify.startInTray) {
                    PQCSettings.interfaceTrayIcon = 1
                    toplevel.hide()
                } else {
                    if(PQCWindowGeometry.mainWindowMaximized)
                        showMaximized()
                    else
                        showNormal()
                }
            } else {
                if(PQCNotify.startInTray) {
                    PQCSettings.interfaceTrayIcon = 1
                    toplevel.hide()
                } else
                    showMaximized()
            }
        } else {
            if(PQCNotify.startInTray) {
                PQCSettings.interfaceTrayIcon = 1
                toplevel.hide()
            } else
                showFullScreen()
        }

        PQCNotify.loaderShow("mainmenu")
        PQCNotify.loaderShow("metadata")
        PQCNotify.loaderSetup("thumbnails")

        if(PQCNotify.filePath !== "")
            PQCConstants.startupFileLoad = PQCNotify.filePath
        else if(PQCSettings.interfaceRememberLastImage)
            PQCConstants.startupFileLoad = PQCScriptsConfig.getLastLoadedImage()

        // this comes after the above to make sure we load a potentially passed-on image
        imageloader.active = true

        if(PQCScriptsConfig.amIOnWindows() && !PQCNotify.startInTray)
            showOpacity.restart()

        if(PQCConstants.startupFileLoad === "")
            loadAppInBackgroundTimer.triggered()
        else
            loadAppInBackgroundTimer.start()

        setVersion.start()

    }

    Connections {

        target: PQCSettings // qmllint disable unqualified

        function onInterfaceWindowModeChanged() {
            toplevel.visibility = (PQCSettings.interfaceWindowMode ? (PQCConstants.windowMaxAndNotWindowed ? Window.Maximized : Window.Windowed) : Window.FullScreen) // qmllint disable unqualified
        }

    }

    Connections {

        target: PQCNotify // qmllint disable unqualified

        function onCmdOpen() : void {
            console.log("")
            PQCNotify.loaderShow("filedialog")
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
            PQCSettings.interfaceTrayIcon = 1 // qmllint disable unqualified
            toplevel.close()
        }

        function onCmdQuit() : void {
            console.log("")
            toplevel.quitPhotoQt()
        }

        function onCmdToggle() : void {

            console.log("")

            if(toplevel.visible) {
                PQCSettings.interfaceTrayIcon = 1 // qmllint disable unqualified
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

            if(enabled && PQCSettings.interfaceTrayIcon === 0) // qmllint disable unqualified
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

        function onStartInTrayChanged() : void {

            console.log("")

            if(PQCNotify.startInTray) // qmllint disable unqualified
                PQCSettings.interfaceTrayIcon = 1
            else if(!PQCNotify.startInTray && PQCSettings.interfaceTrayIcon === 1)
                PQCSettings.interfaceTrayIcon = 0

        }

        function onFilePathChanged() : void {
            console.log("")
            PQCFileFolderModel.fileInFolderMainView = PQCNotify.filePath
            if(!toplevel.visible)
                toplevel.visible = true
            if(toplevel.visibility === Window.Minimized)
                toplevel.visibility = (PQCConstants.windowMaxAndNotWindowed ? Window.Maximized : Window.Windowed)
            toplevel.raise()
            toplevel.requestActivate()
        }

        function onSetWindowState(state : int) {
            setStateTimer.newstate = state
            setStateTimer.restart()
        }

        function onWindowClose() {
            toplevel.close()
        }

        function onPhotoQtQuit() {
            toplevel.quitPhotoQt()
        }

        function onWindowTitleOverride(title : string) {
            toplevel.titleOverride = title
        }

        function onWindowRaiseAndFocus() {
            toplevel.raise()
            toplevel.requestActivate()
        }

        function onWindowStartSystemMove() {
            toplevel.startSystemMove()
        }

        function onWindowStartSystemResize(edge : int) {
            toplevel.startSystemResize(edge)
        }

        // this one is handled directly in PQShortcuts class
        // function onCmdShortcutSequence(seq) {}

    }

    function handleBeforeClosing() {

        PQCFileFolderModel.advancedSortMainViewCANCEL() // qmllint disable unqualified

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
