import QtQuick 2.3

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: qsTr("Histogram")
			helptext: qsTr("Here you can set whether an image histogram is to be shown overlaying the main image.") + "<br>" + qsTr("There are two variants available, color and greyscale. You can also quickly switch between them by right-clicking the histogram.") + "<br>" + qsTr("The histogram can also be shown/hidden from the mainmenu. You can move the histogram with a simple click-and-drag, and it can be resized from the lower right corner of the histogram.")

		}

		EntrySetting {

			Row {

				spacing: 5

				CustomCheckBox {
					id: gr
					text: "Show greyscale histogram"
					onCheckedButtonChanged:
						if(checkedButton) col.checkedButton = false
				}

				CustomCheckBox {
					id: col
					text: "Show colour histogram"
					onCheckedButtonChanged:
						if(checkedButton) gr.checkedButton = false
				}

			}

		}

	}

	function setData() {
		gr.checkedButton = (settings.histogram && settings.histogramVersion === "grey")
		col.checkedButton = (settings.histogram && settings.histogramVersion === "color")
	}

	function saveData() {
		settings.histogram = (gr.checkedButton || col.checkedButton)
		settings.histogramVersion = (gr.checkedButton ? "grey" : (col.checkedButton ? "color" : settings.histogramVersion))
	}

}
