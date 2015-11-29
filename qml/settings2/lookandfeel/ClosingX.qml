import QtQuick 2.3
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.2

import "../../elements"
import "../"

Rectangle {

	id: top

	color: "transparent"
	width: parent.flickablewidth
	height: childrenRect.height+parent.spacingbetween/2

	Row {

		spacing: 20

		Rectangle { color: "transparent"; width: 1; height: 1; }

		Rectangle {
			id: txt
			width: top.parent.titlewidth+top.parent.titlespacing
			height: childrenRect.height
			y: (top.height-height)/2
			color: "transparent"
			Row {
				spacing: 10
				Text {
					y: (parent.height-height)/2
					color: colour.text
					font.pointSize: 12
					font.bold: true
					text: "Closing 'X' (top right corner)"
					Component.onCompleted: if(width > top.parent.titlewidth) top.parent.titlewidth = width
				}

			}

		}

		Rectangle {

			color: "#00000000"

			// center rectangle
			width: childrenRect.width
			height: childrenRect.height
			y: (top.height-height)/2

			Row {

				spacing: 10

				ExclusiveGroup { id: clo; }
				CustomRadioButton {
					text: "Normal Look"
					exclusiveGroup: clo
					checked: true
				}
				CustomRadioButton {
					text: "Fancy Look"
					exclusiveGroup: clo
				}

				Rectangle { color: "transparent"; width: 1; height: 1; }
				Rectangle { color: "transparent"; width: 1; height: 1; }

				Row {

					spacing: 5

					Text {
						color: colour.text
						font.pointSize: 10
						text: qsTr("Small Size")
					}

					CustomSlider {
						id: closingx_sizeslider
						width: 300
						minimumValue: 5
						maximumValue: 25
						tickmarksEnabled: true
						stepSize: 1
					}

					Text {
						color: colour.text
						font.pointSize: 10
						text: qsTr("Large Size")
					}

				}

			}

		}

	}

}
