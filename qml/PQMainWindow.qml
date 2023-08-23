import QtQuick
import QtQuick.Window

import PQCScriptsOther
import PQCFileFolderModel
import PQCScriptsConfig
import PQCNotify

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

    color: PQCLook.transColor

    minimumWidth: 800
    minimumHeight: 600

    property bool startup: true

    Item {
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
    // thumbnails
    Loader { id: thumbnails; asynchronous: true; source: "ongoing/PQThumbnails.qml" }
    // main menu
    Loader { id: mainmenu;   asynchronous: true; source: "ongoing/PQMainMenu.qml" }
    // meta data
    Loader { id: metadata;   asynchronous: true; source: "ongoing/PQMetaData.qml" }
    PQContextMenu { id: contextmenu }

    /*************************************************/
    // load on-demand

    Loader { id: loader_about }
    Loader { id: loader_advancedsort }
    Loader { id: loader_advancedsortbusy }
    Loader { id: loader_chromecast }
    Loader { id: loader_copymove }
    Loader { id: loader_filedelete }
    Loader { id: loader_filedialog }
    Loader { id: loader_filerename }
    Loader { id: loader_filesaveas }
    Loader { id: loader_filter }
    Loader { id: loader_histogram }
    Loader { id: loader_imgur }
    Loader { id: loader_imguranonym }
    Loader { id: loader_logging }
    Loader { id: loader_mainmenu }
    Loader { id: loader_mapcurrent }
    Loader { id: loader_mapexplorer }
    Loader { id: loader_metadata }
    Loader { id: loader_navigationfloating }
    Loader { id: loader_scale }
    Loader { id: loader_settingsmanager }
    Loader { id: loader_slideshowcontrols }
    Loader { id: loader_slideshowsettings }
    Loader { id: loader_unavailable }
    Loader { id: loader_wallpaper }

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

    Component.onCompleted: {
        if(PQCScriptsConfig.amIOnWindows())
            toplevel.opacity = 0

        toplevel.showMaximized()

        if(PQCNotify.filePath !== "")
            PQCFileFolderModel.fileInFolderMainView = PQCNotify.filePath

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
//        handlingGeneral.cleanUpScreenshotsTakenAtStartup()

//        if(PQCScriptsConfig.amIOnWindows())
//            handlingFileDir.deleteTemporaryAnimatedImageFiles()

    }

    function quitPhotoQt() {
        handleBeforeClosing()
        Qt.quit()
    }

}
