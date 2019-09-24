import QtQuick 2.9
import QtQuick.Window 2.9
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.9
import "../elements"

Window {

    id: rename_window

    Component.onCompleted: {
        rename_window.setX(windowgeometry.fileRenameWindowGeometry.x)
        rename_window.setY(windowgeometry.fileRenameWindowGeometry.y)
        rename_window.setWidth(windowgeometry.fileRenameWindowGeometry.width)
        rename_window.setHeight(windowgeometry.fileRenameWindowGeometry.height)
    }

    minimumWidth: 200
    minimumHeight: 300

    modality: Qt.ApplicationModal

    onClosing: {

        windowgeometry.fileRenameWindowGeometry = Qt.rect(rename_window.x, rename_window.y, rename_window.width, rename_window.height)
        windowgeometry.fileRenameWindowMaximized = (rename_window.visibility==Window.Maximized)

        if(variables.visibleItem == "filerename")
            variables.visibleItem = ""
    }

    visible: PQSettings.fileRenamePopoutElement&&curloader.item.opacity==1

    Connections {
        target: PQSettings
        onFileRenamePopoutElementChanged: {
            if(!PQSettings.fileRenamePopoutElement)
                rename_window.visible = Qt.binding(function() { return PQSettings.fileRenamePopoutElement&&curloader.item.opacity==1; })
        }
    }

    color: "#88000000"

    Loader {
        id: curloader
        source: "PQRename.qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return rename_window.width })
                item.parentHeight = Qt.binding(function() { return rename_window.height })
            }
    }

}
