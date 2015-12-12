import QtQuick 2.3
import QtQuick.Controls 1.2

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: "Lift-Up of Thumbnails"
			helptext: "When a thumbnail is hovered, it is lifted up some pixels (default 10). Here you can increase/decrease this value according to your personal preference."

		}

		EntrySetting {

			id: entry

			// This variable is needed to avoid a binding loop of slider<->spinbox
			property int val: 20

			Row {

				spacing: 10

				CustomSlider {

					id: liftup_slider

					width: 500
					y: (parent.height-height)/2

					minimumValue: 0
					maximumValue: 40

					tickmarksEnabled: true
					stepSize: 1

					onValueChanged:
						entry.val = value

				}

				CustomSpinBox {

					id: liftup_spinbox

					width: 75

					minimumValue: 0
					maximumValue: 40

					suffix: " px"

					value: entry.val

					onValueChanged: {
						if(value%5 == 0)
							liftup_slider.value = value
					}

				}

			}

		}

	}

	function setData() {
		liftup_slider.value = settings.thumbnailsize
		entry.val = liftup_slider.value
	}

	function saveData() {
		settings.thumbnailsize = liftup_spinbox.value
	}

}
