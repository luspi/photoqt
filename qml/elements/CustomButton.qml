import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

Button {

	id: but

	property bool pressedDown: false
	property bool hovered: false
	property int fontsize: 13
	property int wrapMode: Text.NoWrap

	implicitHeight: 2.5*fontsize

	signal clickedButton()

	style: ButtonStyle {

		background: Rectangle {
			anchors.fill: parent
			color: control.enabled ? (control.pressedDown ? colour.button_bg_pressed : (control.hovered ? colour.button_bg_hovered : colour.button_bg)) : colour.button_bg_disabled
			Behavior on color { ColorAnimation { duration: 150; } }
			radius: global_item_radius
		}

		label: Text {
			id: txt
			horizontalAlignment: Qt.AlignHCenter
			verticalAlignment: Qt.AlignVCenter
			font.pixelSize: fontsize
			wrapMode: but.wrapMode
			color: control.enabled ? ((control.hovered || control.pressedDown) ? colour.button_text_active : colour.button_text) : colour.button_text_disabled
			Behavior on color { ColorAnimation { duration: 150; } }
			text: "  " + control.text + "  "
		}

	}

	MouseArea {

		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor

		onPressed: but.pressedDown = true
		onReleased: but.pressedDown = false
		onEntered: but.hovered = true
		onExited: but.hovered = false
		onClicked: clickedButton()

	}

}
