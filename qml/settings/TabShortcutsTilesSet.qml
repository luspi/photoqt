import QtQuick 2.3

Rectangle {

	color: "#44ffffff"

	// The size
	width: 100
	height: 100
	radius: 10

	// Some properties
	property string _close: ""
	property string _keys: ""
	property bool _mouse: false
	property string _cmd: ""
	property string _desc: ""

	// An external shortcut
	property bool _extern: false

	// This is the id in the model
	property int _id: 0

	// Delete this tile
	signal deleteTile(var id)

	// Highlight on hover
	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		onEntered: color = "#88ffffff"
		onExited: color = "#44ffffff"
	}

	// This "M" is visible for mouse shortcuts only
	Text {
		y: 2
		width: parent.width
		visible: _mouse

		color: "white"
		font.pointSize: 10
		font.bold: true
		horizontalAlignment: Text.AlignHCenter

		text: "M"
	}

	// An "x" to delete this tile
	Text {

		x: parent.width-width-parent.radius/2
		y: 0

		color: "#390000"
		font.pointSize: 10
		font.bold: true
		horizontalAlignment: Text.AlignRight

		text: "x"

		// Delete on click
		MouseArea {
			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
			onClicked: deleteTile(_id)
		}
	}

	// The description label
	Text {
		x: 3
		width: parent.width-6

		anchors.verticalCenter: parent.verticalCenter
		horizontalAlignment: Text.AlignHCenter

		color: "black"
		font.bold: true
		font.pointSize: (_extern ? 7 : 9)
		wrapMode: Text.WordWrap

		text: _desc

		MouseArea {
			anchors.fill: parent
			cursorShape: (_extern ? Qt.PointingHandCursor : Qt.ArrowCursor)

			onClicked: {
				if(_extern) {
					setExternalCommand.command = _cmd
					setExternalCommand.show()
				}
			}

		}

	}

	// The shortcut
	Text {

		y: parent.height-height-2
		width: parent.width

		color: "black"
		font.pointSize: 8
		horizontalAlignment: Text.AlignHCenter
		wrapMode: Text.Wrap

		text: _keys

		// Change shortcut on click
		MouseArea {
			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor

			onClicked: {

				if(_mouse) {

					resetMouseShortcut.command = _cmd
					resetMouseShortcut.posIfNew = _id

					var parts = _keys.split("+")
					var but = getanddostuff.trim(parts.pop())
					var modifiers = getanddostuff.trim(parts.join("+"))

					// Pre-set mouse shortcut
					resetMouseShortcut.setShortcut(modifiers,but)
					resetMouseShortcut.show()

				} else {

					resetShortcut.command = _cmd
					resetShortcut.posIfNew = _id
					resetShortcut.show()

				}

			}
		}
	}

}
