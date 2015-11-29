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
					text: "Hide to Tray Icon"
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

				ExclusiveGroup { id: tray; }
				CustomRadioButton {
					text: "No tray icon"
					exclusiveGroup: tray
					checked: true
				}
				CustomRadioButton {
					text: "Hide to tray icon"
					exclusiveGroup: tray
				}
				CustomRadioButton {
					text: "Show tray icon, but don't hide to it"
					exclusiveGroup: tray
				}

			}

		}

	}

}
