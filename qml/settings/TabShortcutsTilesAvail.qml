import QtQuick 2.3

Rectangle {

	color: "#00000000"

	width: 100
	height: 100
	radius: 10

	property string _desc: ""
	property string _cmd: ""

	Rectangle {

		color: "#44ffffff"

		width: 100
		height: 50
		radius: 10

		property string _desc: ""

		Text {
			anchors.verticalCenter: parent.verticalCenter
			width: parent.width-6
			x: 3
			text: _desc
			color: "black"
			font.bold: true
			font.pointSize: 8
			horizontalAlignment: Text.AlignHCenter
			wrapMode: Text.WordWrap
		}

	}

	Rectangle {

		id: key

		color: "#44ffffff"

		x: 1
		width: 47
		height: 45
		y: 53
		radius: 5

		Text {
			anchors.fill: parent
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			color: "black"
			font.pointSize: 8
			font.bold: true
			text: "key"
		}

		MouseArea {

			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
			hoverEnabled: true

			onEntered: key.color = "#88ffffff"
			onExited: key.color = "#44ffffff"

			onClicked: {
				detectShortcut.command = _cmd
				detectShortcut.show()
			}

		}

	}

	Rectangle {

		id: mouse

		color: "#44ffffff"

		x: 52
		width: 47
		height: 45
		y: 53
		radius: 5

		Text {
			anchors.fill: parent
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			color: "black"
			font.pointSize: 8
			font.bold: true
			text: "mouse"
		}

		MouseArea {

			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
			hoverEnabled: true

			onEntered: mouse.color = "#88ffffff"
			onExited: mouse.color = "#44ffffff"

			onClicked: {
				detectMouseShortcut.command = _cmd
				detectMouseShortcut.show()
			}

		}

	}

}
