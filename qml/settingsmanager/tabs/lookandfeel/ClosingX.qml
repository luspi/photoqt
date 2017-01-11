import QtQuick 2.3
import QtQuick.Controls 1.2

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			id: entrytitle

			title: qsTr("Exit button ('x' in top right corner)")
			helptext: qsTr("There are two looks for the exit button: a plain 'x', or a slightly more fancy 'x'. Here you can switch back and forth between both of them, and also change their size. If you prefer not to have a closing 'x' at all, see further down for an option to hide it completely.")

		}


		EntrySetting {

			Row {

				spacing: 10

				ExclusiveGroup { id: clo; }

				CustomRadioButton {
					id: closingx_fancy
					text: qsTr("Normal")
					exclusiveGroup: clo
				}
				CustomRadioButton {
					id: closingx_normal
					text: qsTr("Plain")
					exclusiveGroup: clo
					checked: true
				}

				Rectangle { color: "transparent"; width: 1; height: 1; }
				Rectangle { color: "transparent"; width: 1; height: 1; }

				Row {

					spacing: 5

					Text {
						id: txt_small
						color: colour.text
						font.pointSize: 10
						text: qsTr("Small Size")
					}

					CustomSlider {

						id: closingx_sizeslider

						width: Math.min(300, settings_top.width-entrytitle.width-closingx_fancy.width-closingx_normal.width
							   -txt_small.width-txt_large.width-80)
						y: (parent.height-height)/2

						minimumValue: 5
						maximumValue: 25

						tickmarksEnabled: true
						stepSize: 1

					}

					Text {
						id: txt_large
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
