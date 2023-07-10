import QtQuick
import QtQuick.Window

import "elements"
import "other"
import "manage"
import "image"
import "scripts/pq_shortcuts.js" as PQShortcutsJS

Window {

    id: toplevel

    flags: PQCSettings.interfaceWindowDecoration ?
               (PQCSettings.interfaceKeepWindowOnTop ? (Qt.Window|Qt.WindowStaysOnTopHint) : Qt.Window) :
               (PQCSettings.interfaceKeepWindowOnTop ? (Qt.FramelessWindowHint|Qt.WindowStaysOnTopHint|Qt.Window) : (Qt.FramelessWindowHint|Qt.Window))

    color: PQCLook.transColor

    minimumWidth: 800
    minimumHeight: 600

    // load this asynchronously
    Loader {
        id: background
        asynchronous: true
        source: "other/PQBackgroundMessage.qml"
    }

    // load this asynchronously
    Loader {
        id: shortcuts
        asynchronous: true
        source: "other/PQShortcuts.qml"
    }

    // this one we load synchronously for easier access
    PQLoader { id: loader }

    PQImage { id: image}

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

    Component.onCompleted:
        toplevel.showMaximized()

}
