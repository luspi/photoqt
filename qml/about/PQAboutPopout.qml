import QtQuick 2.9
import QtQuick.Window 2.9
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.9
import "../elements"

Window {

    id: about_window

    Component.onCompleted: {
        about_window.setX(windowgeometry.aboutWindowGeometry.x)
        about_window.setY(windowgeometry.aboutWindowGeometry.y)
        about_window.setWidth(windowgeometry.aboutWindowGeometry.width)
        about_window.setHeight(windowgeometry.aboutWindowGeometry.height)
    }

    minimumWidth: 500
    minimumHeight: 500

    modality: Qt.ApplicationModal

    onClosing: {

        windowgeometry.aboutWindowGeometry = Qt.rect(about_window.x, about_window.y, about_window.width, about_window.height)
        windowgeometry.aboutWindowMaximized = (about_window.visibility==Window.Maximized)

        if(variables.visibleItem == "about")
            variables.visibleItem = ""
    }

    visible: PQSettings.aboutPopoutElement&&curloader.item.opacity==1

    Connections {
        target: PQSettings
        onScalePopoutElementChanged: {
            if(!PQSettings.aboutPopoutElement)
                about_window.visible = Qt.binding(function() { return PQSettings.aboutPopoutElement&&curloader.item.opacity==1; })
        }
    }

    color: "#88000000"

    Loader {
        id: curloader
        source: "PQAbout.qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return about_window.width })
                item.parentHeight = Qt.binding(function() { return about_window.height })
            }
    }

}
