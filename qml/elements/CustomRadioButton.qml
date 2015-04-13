import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

RadioButton {

	// there can be an icon displayed as part of the label
	property string icon: ""

	property string indicatorColourEnabled: "#ffffff"
	property string indicatorBackgroundColourEnabled: "#22FFFFFF"

	style: RadioButtonStyle {
		indicator: Rectangle {
			implicitWidth: 16
			implicitHeight: 16
			radius: 9
			color: control.enabled ? indicatorBackgroundColourEnabled : "#22888888"
			Rectangle {
				anchors.fill: parent
				visible: control.checked
				color: indicatorColourEnabled
				radius: 9
				anchors.margins: 4
			}
		}
		label: Rectangle {
			color: "#00000000"
			implicitWidth: childrenRect.width
			implicitHeight: childrenRect.height
			Image {
				id: img
				x: 0
				y: 0
				width: (icon != "") ? 16 : 0
				height: (icon != "") ? 16 : 0
				source: icon
				visible: (icon != "")
			}
			Text {
				id: txt
				x: (icon != "") ? 18 : 0
				y: 0
				color: control.enabled ? "white" : "#555555"
				height: 16
				text: control.text
			}
		}
	}

	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		onClicked: parent.checked = true
	}

}
