import QtQuick 2.3

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: "Looping"

		}

		EntrySetting {

			CustomCheckBox {

				id: loopfolder
				text: "Loop through images in folder"

			}

		}

	}

	function setData() {
		loopfolder.checkedButton = settings.loopthroughfolder
	}

	function saveData() {
		settings.loopthroughfolder = loopfolder.checkedButton
	}

}
