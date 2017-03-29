import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3

Slider {

    property int scrollStep: 3

    property string tooltip: ""

    style: SliderStyle {
        groove: Rectangle {
            implicitWidth: 200
            implicitHeight: 3
            color: control.enabled ? colour.slider_groove_bg_color : colour.slider_groove_bg_color_disabled
            Behavior on color { ColorAnimation { duration: 150; } }
            radius: global_item_radius
            property bool en: control.enabled
        }
        handle: Rectangle {
            anchors.centerIn: parent
            color: control.enabled ? (control.pressed ? colour.slider_handle_color_active : colour.slider_handle_color_inactive) : colour.slider_handle_color_disabled
            Behavior on color { ColorAnimation { duration: 150; } }
            border.color: control.enabled ? colour.slider_handle_border_color : colour.slider_handle_border_color_disabled
            Behavior on border.color { ColorAnimation { duration: 150; } }
            border.width: 1
            implicitWidth: 18
            implicitHeight: 12
            radius: global_item_radius
        }
    }

    ToolTip {
        id: tooltip
        text: parent.tooltip
        anchors.fill: parent
        cursorShape: (parent.pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor)
        propagateComposedEvents: true
        onPressed: mouse.accepted = false
        onReleased: mouse.accepted = false
        onWheel: {
            if(wheel.angleDelta.y < 0)
                value += scrollStep
            else
                value -= scrollStep
        }
    }

}
