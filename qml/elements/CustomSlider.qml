import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

Slider {

	property int scrollStep: 3

	style: SliderStyle {
		groove: Rectangle {
			implicitWidth: 200
			implicitHeight: 3
			color: control.enabled ? colour.slider_groove_bg_color : colour.slider_groove_bg_color_disabled
			radius: 8
		}
		handle: Rectangle {
			anchors.centerIn: parent
			color: control.enabled ? (control.pressed ? colour.slider_handle_color_active : colour.slider_handle_color_inactive) : colour.slider_handle_color_disabled
			border.color: control.enabled ? colour.slider_handle_border_color : colour.slider_handle_border_color_disabled
			border.width: 1
			implicitWidth: 18
			implicitHeight: 12
			radius: 5
		}
	}

	MouseArea {
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
