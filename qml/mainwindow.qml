import QtQuick 2.9
import QtQuick.Window 2.9

import PQSettings 1.0
import PQHandlingFileDialog 1.0
import PQHandlingGeneral 1.0
import PQLocalisation 1.0
import PQImageProperties 1.0
import PQImageFormats 1.0
import PQFileWatcher 1.0

import "./mainwindow"
import "./shortcuts"

Window {

    id: toplevel

    visible: true

    visibility: settings.windowMode ? Window.Maximized : Window.FullScreen
    flags: settings.windowDecoration ?
               (settings.keepOnTop ? (Qt.Window|Qt.WindowStaysOnTopHint) : Qt.Window) :
               (settings.keepOnTop ? (Qt.FramelessWindowHint|Qt.WindowStaysOnTopHint) : Qt.FramelessWindowHint)

    minimumWidth: 600
    minimumHeight: 400

    width: 1024
    height: 768

    color: Qt.rgba(settings.backgroundColorRed/256.0,
                   settings.backgroundColorGreen/256.0,
                   settings.backgroundColorBlue/256.0,
                   settings.backgroundColorAlpha/256.0)

    title: em.pty+qsTranslate("other", "PhotoQt Image Viewer")

    property int transitionDuration: 3
    // possible values: x, y, opacity
    property string transitionAnimation: "x"

    PQImage { id: imageitem }
    PQFileDialog { id: filedialog }
    PQSettings { id: settings }
    PQImageProperties { id: imageproperties }
    PQImageFormats { id: imageformats }
    PQFileWatcher { id: filewatcher }

    PQHandlingFileDialog { id: handlingFileDialog }
    PQHandlingGeneral { id: handlingGeneral }

    PQShortcuts { id: shortcuts }

    // Localisation handler, allows for runtime switches of languages
    PQLocalisation { id : em }

    Timer {
        interval: 100
        repeat: false
        running: true
        onTriggered: {
            imageitem.hideImageTemporary()
            filedialog.showFileDialog()
        }
    }

    Shortcut {
        sequence: "o"
        onActivated: {
            imageitem.hideImageTemporary()
            filedialog.showFileDialog()
        }
    }

}
