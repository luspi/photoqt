import QtQuick 2.3
//import QtQuick.Dialogs 1.1
//import QtQuick.Controls 1.2

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: "Border Around Image"
			helptext: qsTr("Whenever you load an image, the image is per default not shown completely in fullscreen, i.e. it's not stretching from screen edge to screen edge. Instead there is a small margin around the image of a couple pixels (looks better). Here you can adjust the width of this margin (set to 0 to disable it).")

		}

		EntrySetting {

			Row {

				spacing: 10

				CustomSlider {

					id: border_sizeslider

					width: 400
					y: (parent.height-height)/2

					minimumValue: 0
					maximumValue: 50

					value: border_sizespinbox.value
					tickmarksEnabled: true
					stepSize: 1

				}

				CustomSpinBox {

					id: border_sizespinbox

					width: 75

					minimumValue: 0
					maximumValue: 50

					value: border_sizeslider.value
					suffix: " px"

				}

			}

		}

	}

	function setData() {
		border_sizeslider.value = settings.borderAroundImg
	}

	function saveData() {
		settings.borderAroundImg = border_sizeslider.value
	}

}
