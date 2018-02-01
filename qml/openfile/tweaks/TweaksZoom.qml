import QtQuick 2.5
import "../../elements"

Item {

    anchors.left: up.right
    anchors.leftMargin: 20
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
        value: 25
        Behavior on value { NumberAnimation { duration: variables.animationSpeed } }
        onValueChanged:
            settings.openZoomLevel = value
    }

    // If setting this directly to the value, then there seems to be a problem with older Qt versions (observed with Qt 5.5) where the value would
    // then be always set to its minimum...
    // This is a little longwinded, but at least works everywhere.
    Component.onCompleted:
        zoom_slider.value = settings.openZoomLevel
    Connections {
        target: settings
        onOpenZoomLevelChanged:
            zoom_slider.value = settings.openZoomLevel
    }

}
