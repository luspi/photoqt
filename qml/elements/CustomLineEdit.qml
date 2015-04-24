import QtQuick 2.3

Rectangle {

	width: 200
	height: 30

	radius: 3
	color: "#88000000"

	property string text: ed1.text

	signal textEdited()

	TextEdit {

		id: ed1

		x: 3
		y: (parent.height-height)/2

		width: parent.width-6

		color: "white"
		selectedTextColor: "black"
		selectionColor: "white"
		text: parent.text

		clip: true

		onTextChanged: parent.textEdited()

		MouseArea {

			property bool held: false

			anchors.fill: parent
			cursorShape: Qt.IBeamCursor

			// We use these to re-implement selecting text by mouse (otherwise it'll be overwritten by dragging feature)
			onDoubleClicked: parent.selectAll()
			onPressed: { held = true; ed1.cursorPosition = ed1.positionAt(mouse.x,mouse.y); parent.forceActiveFocus() }
			onReleased: held = false
			onPositionChanged: {if(held) ed1.moveCursorSelection(ed1.positionAt(mouse.x,mouse.y)) }

		}
	}
}
