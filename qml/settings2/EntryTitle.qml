import QtQuick 2.3

Rectangle {

	id: top

	property string title: ""

	width: settings_top.titlewidth + 20
	height: childrenRect.height
	y: (item_top.height-height)/2
	color: "transparent"
	Row {
		spacing: 10
		Rectangle { color: "transparent"; width: 1; height: 1; }
		Text {
			y: (parent.height-height)/2
			color: colour.text
			font.pointSize: 12
			font.bold: true
			text: top.title
			Component.onCompleted:
				if(width > settings_top.titlewidth)
					settings_top.titlewidth = width
		}

	}

}
