import QtQuick 2.3

Rectangle {

	color: "#22ffffff"

	// All have the same size
	width: 100
	height: 100
	radius: 10

	// Store description and command
	property string _desc: ""
	property string _cmd: ""

	Rectangle {

		id: desc

		color: colour.tiles_inactive

		// Top half is the description
		width: 100
		height: 50
		radius: 10

		// The description text
		Text {

			x: 3
			width: parent.width-6

			anchors.verticalCenter: parent.verticalCenter
			horizontalAlignment: Text.AlignHCenter
			wrapMode: Text.WordWrap

			color: colour.tiles_text
			font.bold: true
			font.pointSize: 8

			text: _desc

		}

		// Highlight description and key button
		MouseArea {

			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
			hoverEnabled: true

			onEntered: {
				key.color = colour.tiles_active
				desc.color = colour.tiles_active
			}
			onExited: {
				key.color = colour.tiles_inactive
				desc.color = colour.tiles_inactive
			}

			onClicked: {
				detectShortcut.command = _cmd
				detectShortcut.posIfNew = -1	// This means that it is a new shortcut
				detectShortcut.show()
			}

		}

	}

	// "Key" button
	Rectangle {

		id: key

		color: colour.tiles_inactive

		x: 1
		y: 53
		width: 47
		height: 45

		radius: 5

		// The text in the center
		Text {

			anchors.fill: parent

			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter

			color: colour.tiles_text
			font.pointSize: 8
			font.bold: true

			//: tile text for KEY shortcut. If multiple translations possible, please try to stick to a short one..
			text: qsTr("key")

		}

		// Highlight both the key button and the description, and on click set mouse shortcut
		MouseArea {

			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
			hoverEnabled: true

			onEntered: {
				key.color = colour.tiles_active
				desc.color = colour.tiles_active
			}
			onExited: {
				key.color = colour.tiles_inactive
				desc.color = colour.tiles_inactive
			}

			onClicked: {
				detectShortcut.command = _cmd
				detectShortcut.posIfNew = -1
				detectShortcut.show()
			}

		}

	}

	// A "mouse" button
	Rectangle {

		id: mouse

		color: colour.tiles_inactive

		x: 52
		y: 53
		width: 47
		height: 45

		radius: 5

		// The text
		Text {
			anchors.fill: parent

			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter

			color: colour.tiles_text
			font.pointSize: 8
			font.bold: true

			//: tile text for MOUSE shortcut. If multiple translations possible, please try to stick to a short one..
			text: qsTr("mouse")
		}

		// Highlight on hover and on click set mouse shortcut
		MouseArea {

			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
			hoverEnabled: true

			onEntered: mouse.color = colour.tiles_active
			onExited: mouse.color = colour.tiles_inactivee

			onClicked: {
				detectMouseShortcut.command = _cmd
				detectMouseShortcut.posIfNew = -1
				detectMouseShortcut.show()
			}

		}

	}

}
