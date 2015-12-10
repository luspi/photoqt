import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Private 1.0

import "../../../elements"

Rectangle {

	id: rect

	property string fileEnding: ""
	property string fileType: ""
	property string description: ""

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
		fixedwidth: parent.width-2*x
		elide: Text.ElideRight
		text: parent.fileType
		fsize: 9
		checkedButton: parent.checked
	}

	ToolTip {
		text: description=="" ? "<b>" + rect.fileType + ":</b><br>" + rect.fileEnding
							  : "<b>" + rect.description + "</b><br>" + rect.fileEnding
		cursorShape: Qt.PointingHandCursor
		onEntered:
			hovered = true
		onExited:
			hovered = false
		onClicked:
			checked = !checked
	}

}
