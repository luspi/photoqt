import QtQuick 2.9
import QtQuick.Window 2.9

import PQSettings 1.0
import PQHandlingFileDialog 1.0
import PQHandlingGeneral 1.0
import PQHandlingShortcuts 1.0
import PQLocalisation 1.0
import PQImageProperties 1.0
import PQImageFormats 1.0
import PQFileWatcher 1.0

import "./mainwindow"
import "./shortcuts"

Window {

    id: toplevel

    visible: true

    visibility: settings.saveWindowGeometry ? Window.Windowed : (settings.windowMode ? Window.Maximized : Window.FullScreen)
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

    property var allSetShortcuts: []
    property string visibleItem: ""

    onClosing: {
        if(settings.saveWindowGeometry)
            handlingGeneral.saveWindowGeometry(toplevel.x, toplevel.y, toplevel.width, toplevel.height, toplevel.visibility==Window.Maximized)
        close.accepted = true
    }

    Component.onCompleted:  {

        if(settings.saveWindowGeometry) {

            var geo = handlingGeneral.getWindowGeometry()

            if(geo == Qt.rect(0,0,0,0))
                toplevel.visibility = Window.Maximized
            else {
                toplevel.setX(geo.x)
                toplevel.setY(geo.y)
                toplevel.setWidth(geo.width)
                toplevel.setHeight(geo.height)
            }

        }

        loader.show("filedialog")

    }

    PQLoader { id: loader }

    PQImage { id: imageitem }
    Loader { id: filedialog }
    PQSettings { id: settings }
    PQImageProperties { id: imageproperties }
    PQImageFormats { id: imageformats }
    PQFileWatcher { id: filewatcher }

    PQHandlingFileDialog { id: handlingFileDialog }
    PQHandlingGeneral { id: handlingGeneral }
    PQHandlingShortcuts { id: handlingShortcuts }

    PQShortcuts { id: shortcuts }

    // Localisation handler, allows for runtime switches of languages
    PQLocalisation { id : em }

}
