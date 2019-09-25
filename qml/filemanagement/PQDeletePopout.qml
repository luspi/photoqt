import QtQuick 2.9
import QtQuick.Window 2.9
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.9
import "../elements"

Window {

    id: delete_window

    Component.onCompleted: {
        delete_window.setX(windowgeometry.fileDeleteWindowGeometry.x)
        delete_window.setY(windowgeometry.fileDeleteWindowGeometry.y)
        delete_window.setWidth(windowgeometry.fileDeleteWindowGeometry.width)
        delete_window.setHeight(windowgeometry.fileDeleteWindowGeometry.height)
    }

    minimumWidth: 200
    minimumHeight: 300

    modality: Qt.ApplicationModal

    onClosing: {

        windowgeometry.fileDeleteWindowGeometry = Qt.rect(delete_window.x, delete_window.y, delete_window.width, delete_window.height)
        windowgeometry.fileDeleteWindowMaximized = (delete_window.visibility==Window.Maximized)

        if(variables.visibleItem == "filerename")
            variables.visibleItem = ""
    }

    visible: PQSettings.fileDeletePopoutElement&&curloader.item.opacity==1

    Connections {
        target: PQSettings
        onFileDeletePopoutElementChanged: {
            if(!PQSettings.fileDeletePopoutElement)
                delete_window.visible = Qt.binding(function() { return PQSettings.fileDeletePopoutElement&&curloader.item.opacity==1; })
        }
    }

    color: "#88000000"

    Loader {
        id: curloader
        source: "PQDelete.qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return delete_window.width })
                item.parentHeight = Qt.binding(function() { return delete_window.height })
            }
    }

}
