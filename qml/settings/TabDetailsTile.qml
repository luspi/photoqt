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
	color: (checked || hovered) ? colour.exif_bg_active : colour.exif_bg_inactive
	radius: 5

	// the text, which item this one is
	Text {

		x: 5
		y: 5
		width: parent.width-5
		height: parent.height-check.height-10

		color: (checked || hovered) ? colour.exif_text_active : colour.exif_text_inactive
		verticalAlignment: Qt.AlignVCenter
		horizontalAlignment: Qt.AlignHCenter
		wrapMode: Text.WordWrap

		text: rect.text

	}

	// And the checkbox indicator
	CustomCheckBox {

		id: check

		checkedButton: checked

		x: (parent.width-width)/2
		y: parent.height-height-5

		indicatorColourEnabled: colour.exif_indicator_col
		indicatorBackgroundColourEnabled: colour.exif_indicator_bg

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
