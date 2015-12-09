import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Private 1.0

import "../../../elements"

Rectangle {

	id: rect

	property string fileEnding: ""
	property string tooltip: ""

	property bool checked: false
	property bool hovered: false

	property var exclusiveGroup: ExclusiveGroup

	// Size
	width: 100
	height: 30

	// Look
	color: checked ? colour.tiles_active : (hovered ? colour.tiles_inactive : colour.tiles_disabled)
	Behavior on color { ColorAnimation { duration: 150 } }
	radius: global_item_radius

	CustomCheckBox {
		y: (parent.height-height)/2
		x: y
		text: parent.fileEnding
		fsize: 9
		checkedButton: parent.checked
	}

	ToolTip {
		text: "<b>File Ending(s):</b><br>" + rect.tooltip
		cursorShape: Qt.PointingHandCursor
		onEntered:
			hovered = true
		onExited:
			hovered = false
		onClicked:
			checked = !checked
	}

}
