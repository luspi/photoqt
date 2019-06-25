import QtQuick 2.9
import QtQuick.Window 2.9
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.9
import "../elements"

Window {

    id: histogram_window

    Component.onCompleted: {
        histogram_window.x = windowgeometry.histogramWindowGeometry.x
        histogram_window.y = windowgeometry.histogramWindowGeometry.y
        histogram_window.width = windowgeometry.histogramWindowGeometry.width
        histogram_window.height = windowgeometry.histogramWindowGeometry.height
    }

    minimumWidth: 100
    minimumHeight: 100

    modality: Qt.NonModal

    onClosing: {
        PQSettings.histogram = 0
    }

    Connections {
        target: toplevel
        onClosing: {
            windowgeometry.histogramWindowGeometry = Qt.rect(histogram_window.x, histogram_window.y, histogram_window.width, histogram_window.height)
            windowgeometry.histogramWindowMaximized = (histogram_window.visibility==Window.Maximized)
        }
    }

    visible: PQSettings.histogramPopoutElement

    color: "#88000000"

    Loader {
        source: "PQHistogram.qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return histogram_window.width })
                item.parentHeight = Qt.binding(function() { return histogram_window.height })
            }
    }

}
