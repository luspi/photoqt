import QtQuick 2.3
import QtQuick.Controls 1.2

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: "Dynamic Thumbnails"
			helptext: qsTr("Dynamic thumbnail creation means, that PhotoQt only sets up those thumbnail images that are actually needed, i.e. it stops once it reaches the end of the visible area and sits idle until you scroll left/right.") + "<br>" +qsTr("Smart thumbnails are similar in nature. However, they make use of the fast, that once a thumbnail has been created, it can be loaded very quickly and efficiently. It also first loads all of the currently visible thumbnails, but it doesn't stop there: Any thumbnails (even if invisible at the moment) that once have been created are loaded. This is a nice compromise between efficiency and usability.") + "<br><br>" + qsTr("Enabling either the smart or dynamic option is recommended, as it increases the performance of PhotoQt significantly, while preserving the usability.")

		}

		EntrySetting {

			id: entry

			Row {

				spacing: 10

				ExclusiveGroup { id: dynamicgroup; }

				CustomRadioButton {
					id: normal
					text: qsTr("Normal Thumbnails")
					exclusiveGroup: dynamicgroup
				}

				CustomRadioButton {
					id: dynamic
					text: qsTr("Dynamic Thumbnails")
					exclusiveGroup: dynamicgroup
				}

				CustomRadioButton {
					id: smart
					text: qsTr("Smart Thumbnails")
					exclusiveGroup: dynamicgroup
					checked: true
				}

			}

		}

	}

	function setData() {
		normal.checked = (settings.thumbnailDynamic === 0)
		dynamic.checked = (settings.thumbnailDynamic === 1)
		smart.checked = (settings.thumbnailDynamic === 2)
	}

	function saveData() {
		settings.thumbnailDynamic = (normal.checked ? 0 : (dynamic.checked ? 1 : 2))
	}

}
