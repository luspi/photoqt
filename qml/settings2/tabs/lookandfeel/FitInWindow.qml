import QtQuick 2.3

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: "Fit in Window"

		}

		EntrySetting {

			CustomCheckBox {

				id: fitinwindow
				text: "Fit Smaller Images in Window"

			}

		}

	}

	function setData() {
		fitinwindow.checkedButton = settings.fitInWindow
	}

	function saveData() {
		settings.fitInWindow = fitinwindow.checkedButton
	}

}
