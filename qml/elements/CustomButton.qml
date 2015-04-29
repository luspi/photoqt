import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

Button {

	id: but

	property bool pressedDown: false
	property bool hovered: false
	property int fontsize: 13

	implicitHeight: 2.5*fontsize

	signal clickedButton()

	style: ButtonStyle {

		background: Rectangle {
			anchors.fill: parent
			color: control.pressedDown ? "#66DDDDDD" : (control.hovered ? "#44DDDDDD" : "#22DDDDDD")
			radius: 5
		}

		label: Text {
			horizontalAlignment: Qt.AlignHCenter
			verticalAlignment: Qt.AlignVCenter
			font.pixelSize: fontsize
			color: control.enabled ? ((control.hovered || control.pressedDown) ? "#aacccccc" : "#aacccccc") : "#aacccccc"
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
