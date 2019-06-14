import QtQuick 2.9
import QtQuick.Window 2.9

import PQHandlingFileDialog 1.0
import PQHandlingGeneral 1.0
import PQHandlingShortcuts 1.0
import PQLocalisation 1.0
import PQImageProperties 1.0
import PQImageFormats 1.0
import PQFileWatcher 1.0
import PQWindowGeometry 1.0

import "./mainwindow"
import "./shortcuts"

Window {

    id: toplevel

    visible: true

    visibility: PQSettings.windowMode ? (PQSettings.saveWindowGeometry ? Window.Windowed : Window.Maximized) : Window.FullScreen
    flags: PQSettings.windowDecoration ?
               (PQSettings.keepOnTop ? (Qt.Window|Qt.WindowStaysOnTopHint) : Qt.Window) :
               (PQSettings.keepOnTop ? (Qt.FramelessWindowHint|Qt.WindowStaysOnTopHint) : Qt.FramelessWindowHint)

    minimumWidth: 600
    minimumHeight: 400

    width: 1024
    height: 768

    color: Qt.rgba(PQSettings.backgroundColorRed/256.0,
                   PQSettings.backgroundColorGreen/256.0,
                   PQSettings.backgroundColorBlue/256.0,
                   PQSettings.backgroundColorAlpha/256.0)

    title: em.pty+qsTranslate("other", "PhotoQt Image Viewer")

    onClosing: {
        if(PQSettings.saveWindowGeometry) {
            windowgeometry.mainWindowMaximized = (visibility==Window.Maximized)
            windowgeometry.mainWindowGeometry = Qt.rect(toplevel.x, toplevel.y, toplevel.width, toplevel.height)
        }
        close.accepted = true
    }

    Component.onCompleted:  {

        if(PQSettings.saveWindowGeometry) {

            if(windowgeometry.mainWindowMaximized)

                toplevel.visibility = Window.Maximized

            else {

                toplevel.setX(windowgeometry.mainWindowGeometry.x)
                toplevel.setY(windowgeometry.mainWindowGeometry.y)
                toplevel.setWidth(windowgeometry.mainWindowGeometry.width)
                toplevel.setHeight(windowgeometry.mainWindowGeometry.height)

            }

        }

        loader.show("filedialog")

    }

    PQVariables { id: variables }
    PQLoader { id: loader }

    PQMouseShortcuts { id: mouseshortcuts }

    PQImage { id: imageitem }
    PQQuickInfo { id: quickinfo }
    PQCloseButton { id: closebutton }

    PQThumbnailBar { id: thumbnails }

    Loader { id: filedialog }
    Loader { id: filedialog_popout }

    PQImageProperties { id: imageproperties }
    PQImageFormats { id: imageformats }
    PQFileWatcher { id: filewatcher }

    PQHandlingFileDialog { id: handlingFileDialog }
    PQHandlingGeneral { id: handlingGeneral }
    PQHandlingShortcuts { id: handlingShortcuts }

    PQWindowGeometry { id: windowgeometry }

    PQKeyShortcuts { id: shortcuts }

    // Localisation handler, allows for runtime switches of languages
    PQLocalisation { id : em }

//    function close

}
