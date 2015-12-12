import QtQuick 2.3

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: "Click on Empty Area"
			helptext: qsTr("This option makes PhotoQt behave a bit like the JavaScript image viewers you find on many websites. A click outside of the image on the empty background will close the application. It can be a nice feature, PhotoQt will feel even more like a \"floating layer\". However, you might at times close PhotoQt accidentally.") + "<br><br>" + qsTr("Note: If you use a mouse click for a shortcut already, then this option wont have any effect!")

		}

		EntrySetting {

			CustomCheckBox {

				id: closeongrey
				text: qsTr("Close on click in empty area")

			}

		}

	}

	function setData() {
		closeongrey.checkedButton = settings.closeongrey
	}

	function saveData() {
		settings.closeongrey = closeongrey.checkedButton
	}

}
