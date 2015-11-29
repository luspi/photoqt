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
					text: "Window Mode"
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

				CustomCheckBox {
					id: windowmode
					text: qsTr("Run PhotoQt in Window Mode")
					onButtonCheckedChanged:     // 'Window Decoration' checkbox is only enabled when the 'Window ModeÄ checkbox is checked
					windowmode_deco.enabled = checkedButton
				}

				CustomCheckBox {
					id: windowmode_deco
					enabled: false
					opacity: enabled ? 1 : 0.3
					Behavior on opacity { NumberAnimation { duration: 100; } }
					text: qsTr("Show Window Decoration")
				}

			}

		}

	}

}
