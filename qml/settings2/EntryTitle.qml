import QtQuick 2.3

import "../elements"

Rectangle {

	id: top

	property string title: ""
	property string helptext: ""

	width: tab_top.titlewidth + 40
	height: childrenRect.height
	y: (item_top.height-height)/2
	color: "transparent"
	Row {
		spacing: 10
		Rectangle { color: "transparent"; width: 10; height: 1; }
		Text {
			y: (parent.height-height)/2
			color: colour.text
			font.pointSize: 12
			font.bold: true
			textFormat: Text.RichText
			text: top.title
			Component.onCompleted:
				if(width > tab_top.titlewidth)
					tab_top.titlewidth = width
		}

	}

	ToolTip {
		text: parent.helptext
		cursorShape: Qt.WhatsThisCursor
		waitbefore: 100
	}

}
