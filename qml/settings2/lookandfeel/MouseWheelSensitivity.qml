import QtQuick 2.3

import "../../elements"
import "../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: "Mouse Wheel Sensitivity"

		}

		EntrySetting {

			Row {

				spacing: 10

				Text {

					color: colour.text
					text: qsTr("Not at all sensitive")
					font.pointSize: 10

				}

				CustomSlider {

					id: wheelsensitivity

					width: 400
					y: (parent.height-height)/2

					minimumValue: 1
					maximumValue: 10

					tickmarksEnabled: true
					stepSize: 1

				}

				Text {

					color: colour.text
					text: qsTr("Very sensitive")
					font.pointSize: 10

				}

			}

		}

	}

}
