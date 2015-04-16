import QtQuick 2.3

Rectangle {

	color: "#44ffffff"

	width: 100
	height: 100
	radius: 10

	property string _close: ""
	property string _keys: ""
	property bool _mouse: false
	property string _cmd: ""
	property string _desc: ""

	property int _id: 0
	signal deleteTile(var id)

	Text {
		width: parent.width
		y: 2
		visible: _mouse
		text: "M"
		color: "white"
		font.pointSize: 10
		font.bold: true
		horizontalAlignment: Text.AlignHCenter
	}

	Text {
		y: 0
		x: parent.width-width-parent.radius/2
		text: "x"
		color: "#390000"
		font.pointSize: 10
		font.bold: true
		horizontalAlignment: Text.AlignRight
		MouseArea {
			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
			onClicked: deleteTile(_id)
		}
	}

	Text {
		anchors.verticalCenter: parent.verticalCenter
		width: parent.width-6
		x: 3
		text: _desc
		color: "black"
		font.bold: true
		font.pointSize: 9
		horizontalAlignment: Text.AlignHCenter
		wrapMode: Text.WordWrap
	}

	Text {
		width: parent.width
		y: parent.height-height-2
		text: _keys
		color: "black"
		font.pointSize: 8
		horizontalAlignment: Text.AlignHCenter
		MouseArea {
			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
		}
	}

}
