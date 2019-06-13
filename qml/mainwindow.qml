import QtQuick 2.9
import QtQuick.Window 2.9

//import PQSettings 1.0
import PQHandlingFileDialog 1.0
import PQHandlingGeneral 1.0
import PQHandlingShortcuts 1.0
import PQLocalisation 1.0
import PQImageProperties 1.0
import PQImageFormats 1.0
import PQFileWatcher 1.0
//import SingletonTestAccess 1.0

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
        if(PQSettings.saveWindowGeometry)
            handlingGeneral.saveWindowGeometry(toplevel.x, toplevel.y, toplevel.width, toplevel.height, toplevel.visibility==Window.Maximized)
        close.accepted = true
    }

//    SingletonTestAccess {
//        id: singleton
//        Component.onCompleted: {
//            console.log("at start:", singleton.someValue)
//        }
//    }

//    Timer {
//        interval: 5000
//        repeat: true
//        running: true
//        onTriggered:
//            console.log("after 5s:", SingletonTest.someValue)
//    }

    Component.onCompleted:  {

        if(PQSettings.saveWindowGeometry) {

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

    PQVariables { id: variables }
    PQLoader { id: loader }

    PQMouseShortcuts { id: mouseshortcuts }

    PQImage { id: imageitem }
    PQQuickInfo { id: quickinfo }
    PQCloseButton { id: closebutton }

    PQThumbnailBar { id: thumbnails }

    Loader { id: filedialog }
//    PQSettings { id: settings }
    PQImageProperties { id: imageproperties }
    PQImageFormats { id: imageformats }
    PQFileWatcher { id: filewatcher }

    PQHandlingFileDialog { id: handlingFileDialog }
    PQHandlingGeneral { id: handlingGeneral }
    PQHandlingShortcuts { id: handlingShortcuts }

    PQKeyShortcuts { id: shortcuts }

    // Localisation handler, allows for runtime switches of languages
    PQLocalisation { id : em }

}
