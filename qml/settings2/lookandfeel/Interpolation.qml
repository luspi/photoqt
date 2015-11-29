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
					text: "Interpolation"
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

//				Row {

//					spacing: 10

					Text {
						color: colour.text
						text: qsTr("Threshold:")
						font.pointSize: 10
						y: (parent.height-height)/2
					}

					CustomSpinBox {

						id: interpolationthreshold

						width: 100

						minimumValue: 0
						maximumValue: 99999

						stepSize: 5

						value: 100
						suffix: " px"

					}

					Rectangle { color: "transparent"; width: 1; height: 1; }
					Rectangle { color: "transparent"; width: 1; height: 1; }
					Rectangle { color: "transparent"; width: 1; height: 1; }

//				}

				CustomCheckBox {
					id: interpolationupscale
					text: qsTr("Use 'Nearest Neighbour' algorithm for upscaling")
				}

			}

		}

	}

}
