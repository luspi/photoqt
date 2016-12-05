import QtQuick 2.3
import QtQuick.Controls 1.2

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			//: Settings title: Keep active thumbnail in the center of the screen
			title: qsTr("Keep in Center")
			helptext: qsTr("If this option is set, then the active thumbnail (i.e., the thumbnail of the currently displayed image) will always be kept in the center of the thumbnail bar (if possible). If this option is not set, then the active thumbnail will simply be kept visible, but not necessarily in the center.")

		}

		EntrySetting {

			id: entry

			CustomCheckBox {
				id: centeron
				text: qsTr("Center on Active Thumbnails")
			}

		}

	}

	function setData() {
		centeron.checkedButton = settings.thumbnailCenterActive
	}

	function saveData() {
		settings.thumbnailCenterActive = centeron.checkedButton
	}

}
