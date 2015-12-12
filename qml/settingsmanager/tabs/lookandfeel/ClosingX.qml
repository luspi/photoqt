import QtQuick 2.3
import QtQuick.Controls 1.2

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: "Closing 'X' (top right corner)"
			helptext: qsTr("There are two looks for the closing 'x' at the top right: a normal 'x', or a slightly more fancy 'x'. Here you can switch back and forth between both of them, and also change their size. If you prefer not to have a closing 'x' at all, see below for an option to hide it.")

		}


		EntrySetting {

			Row {

				spacing: 10

				ExclusiveGroup { id: clo; }

				CustomRadioButton {
					id: closingx_normal
					text: "Normal Look"
					exclusiveGroup: clo
					checked: true
				}
				CustomRadioButton {
					id: closingx_fancy
					text: "Fancy Look"
					exclusiveGroup: clo
				}

				Rectangle { color: "transparent"; width: 1; height: 1; }
				Rectangle { color: "transparent"; width: 1; height: 1; }

				Row {

					spacing: 5

					Text {
						color: colour.text
						font.pointSize: 10
						text: qsTr("Small Size")
					}

					CustomSlider {

						id: closingx_sizeslider

						width: 300
						y: (parent.height-height)/2

						minimumValue: 5
						maximumValue: 25

						tickmarksEnabled: true
						stepSize: 1

					}

					Text {
						color: colour.text
						font.pointSize: 10
						text: qsTr("Large Size")
					}

				}

			}

		}

	}

	function setData() {
		closingx_fancy.checked = settings.fancyX
		closingx_sizeslider.value = settings.closeXsize
	}

	function saveData() {
		settings.fancyX = closingx_fancy.checked
		settings.closeXsize = closingx_sizeslider.value
	}

}
