import QtQuick
import QtQuick.Window

import PQCScriptsOther
import PQCFileFolderModel
import PQCScriptsConfig
import PQCNotify
import PQCPopoutGeometry

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

    visibility: PQCSettings.interfaceWindowMode ? Window.Maximized : Window.FullScreen

    color: "transparent"

    minimumWidth: 800
    minimumHeight: 600

    onWidthChanged: {
        PQCPopoutGeometry.windowWidth = width
    }
    onHeightChanged: {
        PQCPopoutGeometry.windowHeight = height
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

    Component.onCompleted: {

        fullscreenitem.setBackground()

        PQCScriptsConfig.updateTranslation()

        if(PQCScriptsConfig.amIOnWindows())
            toplevel.opacity = 0

        toplevel.showMaximized()

        loader.show("mainmenu")
        loader.show("metadata")
        loader.ensureItIsReady("thumbnails", loader.loadermapping["thumbnails"])

        if(PQCSettings.histogramVisible)
            loader.show("histogram")
        if(PQCSettings.mapviewCurrentVisible)
            loader.show("mapcurrent")
        if(PQCSettings.interfaceNavigationFloating)
            loader.show("navigationfloating")

        if(PQCNotify.filePath !== "")
            PQCFileFolderModel.fileInFolderMainView = PQCNotify.filePath
        else if(PQCSettings.interfaceRememberLastImage)
            PQCFileFolderModel.fileInFolderMainView = PQCScriptsConfig.getLastLoadedImage()


        if(PQCScriptsConfig.amIOnWindows())
            showOpacity.restart()

    }

    function handleBeforeClosing() {

        // helps with deleting temporary animated image files on Windows at the end of function
//        if(handlingGeneral.amIOnWindows())
//            imageitem.resetImageView()

//        if(variables.chromecastConnected)
//            handlingchromecast.disconnectFromDevice()

//        if(variables.slideShowActive)
//            loader.passOn("slideshowcontrols", "quit", undefined)

        PQCFileFolderModel.advancedSortMainViewCANCEL()

//        if(PQSettings.interfaceSaveWindowGeometry) {
//            windowgeometry.mainWindowMaximized = (visibility==Window.Maximized)
//            windowgeometry.mainWindowGeometry = Qt.rect(toplevel.x, toplevel.y, toplevel.width, toplevel.height)
//        }
        if(PQCFileFolderModel.currentIndex > -1 && PQCSettings.interfaceRememberLastImage)
            PQCScriptsConfig.setLastLoadedImage(PQCFileFolderModel.currentFile)
        else
            PQCScriptsConfig.deleteLastLoadedImage()

        PQCScriptsOther.deleteScreenshots()

//        if(PQCScriptsConfig.amIOnWindows())
//            handlingFileDir.deleteTemporaryAnimatedImageFiles()

    }

    onClosing: (close) => {
        if(PQCSettings.interfaceTrayIcon === 1) {
            close.accepted = false
            toplevel.visibility = Window.Hidden
//            if(PQCSettings.interfaceTrayIconHideReset)
//                resetPhotoQt()
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
