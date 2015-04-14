import QtQuick 2.3

Rectangle {

	color: "#00000000"

	width: 100
	height: 100
	radius: 10

	property string _desc: ""

	Rectangle {

		color: "#44ffffff"

		width: 100
		height: 70
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

		color: "#44ffffff"

		width: 100
		height: 25
		y: 75
		radius: 10

		Image {

			x: (parent.width-width)/2
			y: 3

			source: "qrc:/img/settings/addshortcut.png"
			sourceSize: Qt.size(19,19)

		}


	}

	MouseArea {

		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor

	}

}
