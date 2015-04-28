import QtQuick 2.3

Rectangle {

	id: rect

	// Some basic styling
	width: row.width
	height: row.height
	color: "#00000000"

	// These properties can be used to adjust behaviour and look of item
	property bool iconEnabled: true
	property bool textEnabled: true
	property string icon: ""
	property bool iconPositionLeft: true
	property string text: ""

	// Hovered by mouse?
	property bool _hovered: false

	// Click on item
	signal clicked()

	Row {

		id: row
		spacing: 2

		// Icon left of text
		Image {
			source: icon

			sourceSize: Qt.size(15,15)
			visible: iconEnabled && iconPositionLeft
			opacity: _hovered ? 1 : 0.75
		}

		// Some text
		Text {
			color: (_hovered ? "white" : "#cccccc")
			text: rect.text
			visible: textEnabled
		}

		// Icon right of text
		Image {
			source: icon
			sourceSize: Qt.size(15,15)
			visible: iconEnabled && !iconPositionLeft
			opacity: _hovered ? 1 : 0.75
		}

	}

	// Mouse Area catching hover/click events
	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
		onClicked: rect.clicked()
		onEntered: _hovered = true
		onExited: _hovered = false
	}

}
