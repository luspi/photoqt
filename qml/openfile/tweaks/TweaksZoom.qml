import QtQuick 2.6
import "../../elements"

Item {

    x: 10
    height: parent.height
    width: zoom_txt.width+zoom_slider.width

    Text {
        id: zoom_txt
        color: "white"
        font.bold: true
        y: (parent.height-height)/2
        text: qsTr("Zoom:")
        anchors.right: zoom_slider.left
        anchors.rightMargin: 5
    }

    CustomSlider {
        id: zoom_slider
        width: 200
        y: (parent.height-height)/2
        anchors.right: parent.right
        minimumValue: 1
        maximumValue: 10
        tickmarksEnabled: true
        stepSize: 1
        scrollStep: 1
        tooltip: qsTr("Move slider to adjust the size of everything")
        value: settings.openZoomLevelSet
        Behavior on value { NumberAnimation { duration: 200 } }
        onValueChanged:
            settings.openZoomLevelSet = value
    }

}
