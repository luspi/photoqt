import QtQuick
import PQCScriptsOther
import PQCFileFolderModel
import PQCScriptsFilesPaths
import PQCScriptsConfig
import PQCWindowGeometry
import PQCExtensionsHandler

import "./modern/other"
import "./modern/image"
import "./modern/ongoing"

import PQCScriptsPlain

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
        PQCConstants.windowWidth = width
        if(!PQCConstants.photoQtStartupDone) return
        resizing = true
        resetResizing.restart()
    }
    onHeightChanged: {
        PQCConstants.windowHeight = height
        if(PQCConstants.photoQtStartupDone) return
        resizing = true
        resetResizing.restart()
    }
    Timer {
        id: resetResizing
        interval: 500
        onTriggered: {
            toplevel.resizing = false
        }
    }

    property bool isFullscreen: toplevel.visibility==Window.FullScreen

    PQMainWindowBackground {
        id: fullscreenitem
        anchors.fill: parent
    }

    /****************************************************/

    Loader {
        id: bgmessage
        asynchronous: true
        active: false
        source: "modern/other/PQBackgroundMessage.qml"
    }

    Timer {
        id: bgmessage_active
        interval: 100
        onTriggered:
            bgmessage.active = true
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

    Item {
        id: fullscreenitem_foreground
        anchors.fill: parent
    }

    /****************************************************/

    PQContextMenu { id: contextmenu }

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

        // startupSetupShowDelay.start()
        bgmessage_active.start()

        console.warn(">>> set up:", PQCScriptsOther.getTimestamp()-PQCScriptsPlain.getInitTime())

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
            PQCFileFolderModel.fileInFolderMainView = PQCNotify.filePath // qmllint disable unqualified
            if(!toplevel.visible)
                toplevel.visible = true
            if(toplevel.visibility === Window.Minimized)
                toplevel.visibility = (PQCConstants.windowMaxAndNotWindowed ? Window.Maximized : Window.Windowed)
            toplevel.raise()
            toplevel.requestActivate()
        }

        function onSetWindowState(state : int) {
            // setStateTimer.newstate = state
            // setStateTimer.restart()
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
        // if(PQCNotify.slideshowRunning) // qmllint disable unqualified
            // loader_slideshowhandler.item.hide()

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

    Timer {
        id: resetStartup
        interval: 500
        running: true
        onTriggered:
            PQCConstants.photoQtStartupDone = true
    }

    // // these are run with a slight delay to make sure that the window is fully set up first
    // Timer {
    //     id: startupSetupShowDelay
    //     interval: 500
    //     onTriggered: {
    //         // this is set in another timer here
    //         // doing tings this way keeps them bth seperate and working independently
    //         if(!PQCConstants.photoQtStartupDone) {
    //             restart()
    //             return
    //         }
    //         var exts = PQCExtensionsHandler.getExtensions()
    //         for(var iE in exts) {
    //             var ext = exts[iE]
    //             var checks = PQCExtensionsHandler.getDoAtStartup(ext)
    //             for(var i in checks) {
    //                 var entry = checks[i]
    //                 if(entry[0] === "" || PQCSettings["extensions"+entry[0]]) {
    //                     if(entry[1] === "show") {
    //                         PQCNotify.loaderShowExtension(ext)
    //                     } else if(entry[1] === "setup") {
    //                         PQCNotify.loaderSetupExtension(ext)
    //                     } else {
    //                         console.warn("checkAtStartup command for '" + ext + "' not known/implemented:", entry)
    //                     }
    //                 }
    //             }
    //         }
    //     }
    // }

}
