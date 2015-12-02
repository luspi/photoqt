import QtQuick 2.3

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: "Size of 'Hot Edge'"
			helptext: qsTr("Here you can adjust the sensitivity of the drop-down menu. The menu opens when your mouse cursor gets close to the right side of the upper edge. Here you can adjust how close you need to get for it to open.")

		}

		EntrySetting {

			Row {

				spacing: 10

				Text {
					color: colour.text
					text: qsTr("Small")
					font.pointSize: 10
				}

				CustomSlider {

					id: menusensitivity

					width: 400
					y: (parent.height-height)/2

					minimumValue: 1
					maximumValue: 10

					tickmarksEnabled: true
					stepSize: 1

				}

				Text {
					color: colour.text
					text: qsTr("Large")
					font.pointSize: 10
				}

			}

		}

	}

	function setData() {
		menusensitivity.value = settings.menusensitivity
	}

	function saveData() {
		settings.menusensitivity = menusensitivity.value
	}

}
