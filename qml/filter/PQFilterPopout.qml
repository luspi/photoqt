import QtQuick 2.9
import QtQuick.Window 2.9
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.9
import "../elements"

Window {

    id: filter_window

    Component.onCompleted: {
        filter_window.setX(windowgeometry.filterWindowGeometry.x)
        filter_window.setY(windowgeometry.filterWindowGeometry.y)
        filter_window.setWidth(windowgeometry.filterWindowGeometry.width)
        filter_window.setHeight(windowgeometry.filterWindowGeometry.height)
    }

    minimumWidth: 200
    minimumHeight: 300

    modality: Qt.ApplicationModal

    onClosing: {

        windowgeometry.filterWindowGeometry = Qt.rect(filter_window.x, filter_window.y, filter_window.width, filter_window.height)
        windowgeometry.filterWindowMaximized = (filter_window.visibility==Window.Maximized)

        if(variables.visibleItem == "filter")
            variables.visibleItem = ""
    }

    visible: PQSettings.filterPopoutElement&&curloader.item.opacity==1

    Connections {
        target: PQSettings
        onFilterPopoutElementChanged: {
            if(!PQSettings.filterPopoutElement)
                filter_window.visible = Qt.binding(function() { return PQSettings.filterPopoutElement&&curloader.item.opacity==1; })
        }
    }

    color: "#88000000"

    Loader {
        id: curloader
        source: "PQFilter.qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return filter_window.width })
                item.parentHeight = Qt.binding(function() { return filter_window.height })
            }
    }

}
