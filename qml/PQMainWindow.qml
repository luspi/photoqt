import QtQuick
import QtQuick.Window

import "other"
import "scripts/pq_shortcuts.js" as PQShortcutsJS

Window {

    id: toplevel

    flags: PQCSettings.interfaceWindowDecoration ?
               (PQCSettings.interfaceKeepWindowOnTop ? (Qt.Window|Qt.WindowStaysOnTopHint) : Qt.Window) :
               (PQCSettings.interfaceKeepWindowOnTop ? (Qt.FramelessWindowHint|Qt.WindowStaysOnTopHint|Qt.Window) : (Qt.FramelessWindowHint|Qt.Window))

    color: PQCLook.baseColorTrans

    minimumWidth: 800
    minimumHeight: 600

    PQShortcuts { id: shortcuts }

    PQContainer { id: container }

    Component.onCompleted:
        toplevel.showMaximized()

}
