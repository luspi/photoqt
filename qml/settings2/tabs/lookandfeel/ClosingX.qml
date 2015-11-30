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

		}


		EntrySetting {

			Row {

				spacing: 10

				ExclusiveGroup { id: clo; }

				CustomRadioButton {
					text: "Normal Look"
					exclusiveGroup: clo
					checked: true
				}
				CustomRadioButton {
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

}
