import QtQuick 2.9
import QtQuick.Window 2.9
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.9
import "../elements"

Window {

    id: mainmenu_window

    Component.onCompleted: {
        mainmenu_window.x = windowgeometry.mainMenuWindowGeometry.x
        mainmenu_window.y = windowgeometry.mainMenuWindowGeometry.y
        mainmenu_window.width = windowgeometry.mainMenuWindowGeometry.width
        mainmenu_window.height = windowgeometry.mainMenuWindowGeometry.height
    }

    minimumWidth: 100
    minimumHeight: 600

    modality: Qt.NonModal

    onClosing: {
        toplevel.close()
    }

    Connections {
        target: toplevel
        onClosing: {
            windowgeometry.mainMenuWindowGeometry = Qt.rect(mainmenu_window.x, mainmenu_window.y, mainmenu_window.width, mainmenu_window.height)
            windowgeometry.mainMenuWindowMaximized = (mainmenu_window.visibility==Window.Maximized)
        }
    }

    visible: PQSettings.mainMenuPopoutElement

    color: "#88000000"

    Loader {
        source: "PQMainMenu.qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return mainmenu_window.width })
                item.parentHeight = Qt.binding(function() { return mainmenu_window.height })
            }
    }

}
