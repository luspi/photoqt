import QtQuick 2.3

import "../elements"

Rectangle {

	id: rect

	property string text: ""

	property bool checked: false
	property bool hovered: false

	// Size
	width: 90
	height: 90

	// Look
	color: (checked || hovered) ? colour.tiles_active : colour.tiles_inactive
	radius: 5

	// the text, which item this one is
	Text {

		x: 5
		y: 5
		width: parent.width-5
		height: parent.height-check.height-10

		color: (parent.checked || parent.hovered) ? colour.tiles_text_active : colour.tiles_text_inactive
		verticalAlignment: Qt.AlignVCenter
		horizontalAlignment: Qt.AlignHCenter
		wrapMode: Text.WordWrap

		font.pointSize: 7.5
		font.bold: true

		text: rect.text

	}

	// And the checkbox indicator
	CustomCheckBox {

		id: check

		checkedButton: checked

		x: (parent.width-width)/2
		y: parent.height-height-5

		indicatorColourEnabled: colour.tiles_indicator_col
		indicatorBackgroundColourEnabled: colour.tiles_indicator_bg

		text: ""

	}

	// A mouseares governing the hover/checked look
	MouseArea {

		anchors.fill: rect
		cursorShape: Qt.PointingHandCursor
		hoverEnabled: true
		onEntered: hovered = true
		onExited: hovered = false
		onClicked: checked = !checked

	}

}
