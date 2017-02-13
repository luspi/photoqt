import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import "../elements/"


Rectangle {

    id: zoom
    y: 10
    width: zoom_slider.width+zoom_txt.width+zoom_txt.anchors.rightMargin
    height: parent.height-20
    color: "#00000000"

    signal updateZoom(var level)

    Text {
        id: zoom_txt
        color: "white"
        font.bold: true
        y: (parent.height-height)/2
        text: qsTr("Zoom:")
        anchors.right: zoom_slider.left
        anchors.rightMargin: 5
    }

    // We save it after a short delay, as the user might drag it over a little range
    Timer {
        id: saveZoomLevel
        interval: 250
        repeat: false
        running: false
        onTriggered: settings.openZoomLevel = zoom_slider.value
    }

    CustomSlider {
        id: zoom_slider
        width: 200
        y: (parent.height-height)/2
        anchors.right: parent.right
        minimumValue: 10
        maximumValue: 50
        tickmarksEnabled: true
        stepSize: 1
        scrollStep: 1
        tooltip: qsTr("Move slider to adjust the size of the files")
        value: settings.openZoomLevel
        onValueChanged: {
            saveZoomLevel.start()
            updateZoom(value)
        }
    }

    function getZoomLevel() {
        return zoom_slider.value
    }

}
