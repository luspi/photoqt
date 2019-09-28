import QtQuick 2.9
import QtQuick.Window 2.9
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.9
import "../elements"

Window {

    id: imgur_window

    Component.onCompleted: {
        imgur_window.setX(windowgeometry.imgurWindowGeometry.x)
        imgur_window.setY(windowgeometry.imgurWindowGeometry.y)
        imgur_window.setWidth(windowgeometry.imgurWindowGeometry.width)
        imgur_window.setHeight(windowgeometry.imgurWindowGeometry.height)
    }

    minimumWidth: 500
    minimumHeight: 500

    modality: Qt.ApplicationModal

    onClosing: {

        windowgeometry.imgurWindowGeometry = Qt.rect(imgur_window.x, imgur_window.y, imgur_window.width, imgur_window.height)
        windowgeometry.imgurWindowMaximized = (imgur_window.visibility==Window.Maximized)

        if(variables.visibleItem == "imgur")
            variables.visibleItem = ""
    }

    visible: PQSettings.imgurPopoutElement&&curloader.item.opacity==1

    Connections {
        target: PQSettings
        onImgurPopoutElementChanged: {
            if(!PQSettings.imgurPopoutElement)
                imgur_window.visible = Qt.binding(function() { return PQSettings.imgurPopoutElement&&curloader.item.opacity==1; })
        }
    }

    color: "#88000000"

    Loader {
        id: curloader
        source: "PQImgur.qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return imgur_window.width })
                item.parentHeight = Qt.binding(function() { return imgur_window.height })
            }
    }

}
