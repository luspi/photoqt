import QtQuick 2.5
import "../../elements"

Item {

    x: 10
    height: parent.height
    width: zoom_txt.width+zoom_slider.width

    property alias tweaksZoomSlider: zoom_slider

    Text {
        id: zoom_txt
        color: "white"
        font.bold: true
        y: (parent.height-height)/2
        //: As in 'Zoom the files shown'
        text: em.pty+qsTr("Zoom:")
        anchors.right: zoom_slider.left
        anchors.rightMargin: 5
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
        tooltip: em.pty+qsTr("Move slider to adjust the size of files")
        value: settings.openZoomLevel
        Behavior on value { NumberAnimation { duration: variables.animationSpeed } }
        onValueChanged:
            settings.openZoomLevel = value
    }

}
