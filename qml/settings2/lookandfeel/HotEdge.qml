import QtQuick 2.3

import "../../elements"
import "../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: "Size of 'Hot Edge'"

		}

		EntrySetting {

			Row {

				spacing: 10

				Text {
					color: colour.text
					text: qsTr("Small")
					font.pointSize: 10
				}

				CustomSlider {

					id: menusensitivity

					width: 400
					y: (parent.height-height)/2

					minimumValue: 1
					maximumValue: 10

					tickmarksEnabled: true
					stepSize: 1

				}

				Text {
					color: colour.text
					text: qsTr("Large")
					font.pointSize: 10
				}

			}

		}

	}

}
