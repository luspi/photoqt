import QtQuick 2.3

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: "Fit in Window"
			helptext: qsTr("If the image dimensions are smaller than the screen dimensions, PhotoQt can zoom those images to make them fir into the window. However, keep in mind, that such images will look pixelated to a certain degree (depending on each image).")

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
