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
					color: colour.text
					font.pointSize: 12
					font.bold: true
					text: "Sort Images"
					Component.onCompleted: if(width > top.parent.titlewidth) top.parent.titlewidth = width
				}

			}

		}

		Rectangle {

			id: set
			width: childrenRect.width
			height: childrenRect.height
			color: "transparent"
			y: (top.height-height)/2

			Row {

				spacing: 10

				// Label
				Text {
					y: (set.height-height)/2
					color: colour.text
					text: qsTr("Sort by:")
					font.pointSize: 10
				}
				// Choose Criteria
				CustomComboBox {
					id: sortimages_checkbox
					y: (set.height-height)/2
					width: 150
					model: [qsTr("Name"), qsTr("Natural Name"), qsTr("Date"), qsTr("Filesize")]
				}

				// Ascending or Descending
				ExclusiveGroup { id: radiobuttons_sorting }
				CustomRadioButton {
					id: sortimages_ascending
					y: (set.height-height)/2
					text: qsTr("Ascending")
					icon: "qrc:/img/settings/sortascending.png"
					exclusiveGroup: radiobuttons_sorting
					checked: true
				}
				CustomRadioButton {
					id: sortimages_descending
					y: (set.height-height)/2
					text: qsTr("Descending")
					icon: "qrc:/img/settings/sortdescending.png"
					exclusiveGroup: radiobuttons_sorting
				}
			}

		}

	}

}
