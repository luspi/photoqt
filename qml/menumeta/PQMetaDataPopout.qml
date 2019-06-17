import QtQuick 2.9
import QtQuick.Window 2.9
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.9
import "../elements"

Window {

    id: metadata_window

    Component.onCompleted: {
        metadata_window.x = windowgeometry.metaDataWindowGeometry.x
        metadata_window.y = windowgeometry.metaDataWindowGeometry.y
        metadata_window.width = windowgeometry.metaDataWindowGeometry.width
        metadata_window.height = windowgeometry.metaDataWindowGeometry.height
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
            windowgeometry.metaDataWindowGeometry = Qt.rect(metadata_window.x, metadata_window.y, metadata_window.width, metadata_window.height)
            windowgeometry.metaDataWindowMaximized = (metadata_window.visibility==Window.Maximized)
        }
    }

    visible: PQSettings.metadataPopoutElement

    color: "#88000000"

    Loader {
        source: "PQMetaData.qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return metadata_window.width })
                item.parentHeight = Qt.binding(function() { return metadata_window.height })
            }
    }

}
