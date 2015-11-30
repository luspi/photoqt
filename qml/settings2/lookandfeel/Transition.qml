import QtQuick 2.3

import "../../elements"
import "../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: "Smooth Transition"

		}

		EntrySetting {

			Row {

				spacing: 10

				Text {
					color: colour.text
					text: qsTr("No Transition")
					font.pointSize: 10
				}

				CustomSlider {

					id: transition

					width: 400
					y: (parent.height-height)/2

					minimumValue: 0
					maximumValue: 10

					tickmarksEnabled: true
					stepSize: 1

				}

				Text {
					color: colour.text
					text: qsTr("Long Transition")
					font.pointSize: 10
				}

			}

		}

	}

}
