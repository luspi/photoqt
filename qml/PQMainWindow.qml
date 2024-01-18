import QtQuick
import QtQuick.Window

import PQCScriptsOther
import PQCFileFolderModel
import PQCScriptsConfig
import PQCNotify
import PQCWindowGeometry
import PQCScriptsFilesPaths

import "elements"
import "other"
import "manage"
import "image"
import "ongoing"

Window {

    id: toplevel

    flags: PQCSettings.interfaceWindowDecoration ?
               (PQCSettings.interfaceKeepWindowOnTop ? (Qt.Window|Qt.WindowStaysOnTopHint) : Qt.Window) :
               (PQCSettings.interfaceKeepWindowOnTop ? (Qt.FramelessWindowHint|Qt.WindowStaysOnTopHint|Qt.Window) : (Qt.FramelessWindowHint|Qt.Window))

    color: "transparent"

    title: (PQCFileFolderModel.currentFile==="" ? "" : (PQCScriptsFilesPaths.getFilename(PQCFileFolderModel.currentFile) + " | "))+ "PhotoQt Image Viewer"

    minimumWidth: 800
    minimumHeight: 600

    property rect geometry: Qt.rect(x, y, width, height)
    onGeometryChanged: {
        if(!toplevel.startup && toplevel.visibility != Window.FullScreen) {
            PQCWindowGeometry.mainWindowGeometry = geometry
            PQCWindowGeometry.mainWindowMaximized = (toplevel.visibility == Window.Maximized)
        }
    }

    property bool startup: true

    PQMainWindowBackground {
        id: fullscreenitem
        anchors.fill: parent
    }

    // load this asynchronously
    Loader {
        id: shortcuts
        asynchronous: true
        source: "other/PQShortcuts.qml"
    }

    // this one we load synchronously for easier access
    PQLoader { id: loader }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onPositionChanged: (mouse) => {
            PQCNotify.mouseMove(mouse.x, mouse.y)
        }
        onWheel: (wheel) => {
            PQCNotify.mouseWheel(wheel.angleDelta, wheel.modifiers)
        }
    }

    // very cheap to set up, many properties needed everywhere -> no loader
    PQImage { id: image}

    /*************************************************/
    // load assynchronously at startup

    // startup message
    Loader { id: background; asynchronous: true; source: "other/PQBackgroundMessage.qml" }
    // status info
    Loader { id: statusinfo; asynchronous: true; source: "ongoing/PQStatusInfo.qml" }

    PQContextMenu { id: contextmenu }

    Loader { id: loader_trayicon; asynchronous: true; source: "ongoing/PQTrayIcon.qml" }

    Loader { id: windowbuttons; asynchronous: true; source: "ongoing/PQWindowButtons.qml" }
    Loader {
        id: windowbuttons_ontop
        asynchronous: true
        source: "ongoing/PQWindowButtons.qml"
        z: loader.visibleItem!=="filedialog" ? 999 : 0
        onStatusChanged: {
            if(windowbuttons_ontop.status == Loader.Ready)
                windowbuttons_ontop.item.visibleAlways = true
        }
    }

    /*************************************************/
    // load on-demand

    // ongoing
    Loader { id: loader_histogram }
    Loader { id: loader_mapcurrent }
    Loader { id: loader_navigationfloating }
    Loader { id: loader_slideshowcontrols }
    Loader { id: loader_slideshowhandler }
    Loader { id: loader_notification }
    Loader { id: loader_logging }
    Loader { id: loader_chromecast }

    // these should be above the other ongoing ones
    Loader { id: loader_thumbnails; asynchronous: true; }
    Loader { id: loader_metadata; asynchronous: true; }
    Loader { id: loader_mainmenu; asynchronous: true; }

    // actions
    Loader { id: loader_about }
    Loader { id: loader_advancedsort }
    Loader { id: loader_copy }
    Loader { id: loader_move }
    Loader { id: loader_export }
    Loader { id: loader_filedelete }
    Loader { id: loader_filedialog }
    Loader { id: loader_filerename }
    Loader { id: loader_filesaveas }
    Loader { id: loader_filter }
    Loader { id: loader_imgur }
    Loader { id: loader_mapexplorer }
    Loader { id: loader_scale }
    Loader { id: loader_settingsmanager }
    Loader { id: loader_slideshowsetup }
    Loader { id: loader_wallpaper }
    Loader { id: loader_chromecastmanager }

    /*************************************************/

    Item {
        id: fullscreenitem_foreground
        anchors.fill: parent
    }

    Loader {
        asynchronous: true
        active: PQCSettings.interfaceWindowMode && !PQCSettings.interfaceWindowDecoration
        source: "ongoing/PQWindowHandles.qml"
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
        interval: 1000
        running: true
        onTriggered:
            toplevel.startup = false
    }

    Connections {
        target: PQCSettings

        function onInterfaceWindowModeChanged() {
            toplevel.visibility = (PQCSettings.interfaceWindowMode ? Window.Maximized : Window.FullScreen)
        }

    }

    Connections {

        target: PQCNotify

        function onCmdOpen() {
            loader.show("filedialog")
        }

        function onCmdShow() {

            if(toplevel.visible)
                return

            toplevel.visible = true
            if(toplevel.visibility === Window.Minimized)
                toplevel.visibility = Window.Maximized
            toplevel.raise()
            toplevel.requestActivate()

        }

        function onCmdHide() {
            PQCSettings.interfaceTrayIcon = 1
            toplevel.close()
        }

        function onCmdQuit() {
            quitPhotoQt()
        }

        function onCmdToggle() {

            if(toplevel.visible) {
                PQCSettings.interfaceTrayIcon = 1
                toplevel.close()
            } else {
                toplevel.visible = true
                if(toplevel.visibility === Window.Minimized)
                    toplevel.visibility = Window.Maximized
                toplevel.raise()
                toplevel.requestActivate()
            }

        }

        function onCmdTray(enabled) {

            if(enabled && PQCSettings.interfaceTrayIcon === 0)
                PQCSettings.interfaceTrayIcon = 2
            else if(!enabled) {
                PQCSettings.interfaceTrayIcon = 0
                if(!toplevel.visible) {
                    toplevel.visible = true
                    if(toplevel.visibility === Window.Minimized)
                        toplevel.visibility = Window.Maximized
                    toplevel.raise()
                    toplevel.requestActivate()
                }
            }

        }

        function onStartInTrayChanged() {

            if(PQCNotify.startInTray)
                PQCSettings.interfaceTrayIcon = 1
            else if(!PQCNotify.startInTray && PQCSettings.interfaceTrayIcon === 1)
                PQCSettings.interfaceTrayIcon = 0

        }

        function onFilePathChanged() {
            PQCFileFolderModel.fileInFolderMainView = PQCNotify.filePath
        }

        // this one is handled directly in PQShortcuts class
        // function onCmdShortcutSequence(seq) {}

    }

    // clean up some temporary files, mostly from last session
    Timer {
        running: true
        interval: 500
        onTriggered:
            PQCScriptsFilesPaths.cleanupTemporaryFiles()
    }

    Component.onCompleted: {

        fullscreenitem.setBackground()

        PQCScriptsConfig.updateTranslation()

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

        loader.show("mainmenu")
        loader.show("metadata")
        loader.ensureItIsReady("thumbnails", loader.loadermapping["thumbnails"])

        if(PQCSettings.histogramVisible)
            loader.show("histogram")
        if(PQCSettings.mapviewCurrentVisible)
            loader.show("mapcurrent")
        if(PQCSettings.interfaceNavigationFloating)
            loader.show("navigationfloating")
        else
            loader.ensureItIsReady("navigationfloating", loader.loadermapping["navigationfloating"])

        var fp = ""
        if(PQCNotify.filePath !== "")
            fp = PQCNotify.filePath
        else if(PQCSettings.interfaceRememberLastImage)
            fp = PQCScriptsConfig.getLastLoadedImage()

        if(fp != "") {
            PQCFileFolderModel.fileInFolderMainView = fp
            loader.ensureItIsReady("filedialog", loader.loadermapping["filedialog"])
            loader_filedialog.item.loadNewPath(PQCScriptsFilesPaths.isFolder(fp) ? fp : PQCScriptsFilesPaths.getDir(fp))
        }

        if(PQCScriptsConfig.amIOnWindows() && !PQCNotify.startInTray)
            showOpacity.restart()

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
        if(PQCSettings.interfaceTrayIcon === 1) {
            close.accepted = false
            toplevel.visibility = Window.Hidden
            if(PQCSettings.interfaceTrayIconHideReset)
                PQCNotify.resetSessionData()
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
