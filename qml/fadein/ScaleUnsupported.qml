import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

FadeInTemplate {

	id: scaleUnsupported_top

	heading: ""
	showSeperators: false

	marginTopBottom: (background.height-300)/2
	clipContent: false

	content: [

		Rectangle {
			color: "transparent"
			width: childrenRect.width
			height: childrenRect.height
			x: (scaleUnsupported_top.contentWidth-width)/2
			Text {
				color: colour.text
				font.pointSize: 20
//				font.bold: true
				horizontalAlignment: Text.AlignHCenter
				wrapMode: Text.WordWrap
				width: Math.min(background.width/2,500)
				lineHeight: 1.1
				text: qsTr("Sorry, this fileformat can currently not be scaled with PhotoQt!")
			}
		},

		Rectangle {
			color: "transparent"
			width: scaleUnsupported_top.contentWidth
			height: 1
		},

		CustomButton {
			text: qsTr("Okay, I understand")
			fontsize: 15
			x: (scaleUnsupported_top.contentWidth-width)/2
			onClickedButton: hideScaledUnsupported()
		}

	]

	function showScaledUnsupported() {
		show()
	}
	function hideScaledUnsupported() {
		hide()
	}

}
