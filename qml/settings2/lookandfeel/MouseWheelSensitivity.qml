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
					text: "Mouse Wheel Sensitivity"
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

				Text {
					color: colour.text
					text: qsTr("Not at all sensitive")
					font.pointSize: 10
				}

				CustomSlider {

					id: wheelsensitivity

					width: 400

					minimumValue: 1
					maximumValue: 10

					tickmarksEnabled: true
					stepSize: 1

				}

				Text {
					color: colour.text
					text: qsTr("Very sensitive")
					font.pointSize: 10
				}

			}

		}

	}

}
