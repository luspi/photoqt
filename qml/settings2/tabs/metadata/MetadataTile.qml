import QtQuick 2.3

import "../../../elements"

Rectangle {

	id: rect

	property string text: ""

	property bool checked: false
	property bool hovered: false

	// Size
	width: 75
	height: 75

	// Look
	color: enabled ? (checked || hovered) ? colour.tiles_active : colour.tiles_inactive : colour.tiles_disabled
	Behavior on color { ColorAnimation { duration: 150; } }
	radius: global_item_radius

	// the text, which item this one is
	Text {

		x: 5
		y: 5
		width: parent.width-5
		height: parent.height-check.height-10

		color: (checked || hovered) ? colour.tiles_text_active : colour.tiles_text_inactive
		Behavior on color { ColorAnimation { duration: 150; } }
		verticalAlignment: Qt.AlignVCenter
		horizontalAlignment: Qt.AlignHCenter
		wrapMode: Text.WordWrap
		font.pointSize: 8

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
