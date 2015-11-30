import QtQuick 2.3
//import QtQuick.Dialogs 1.1
//import QtQuick.Controls 1.2

import "../../elements"
import "../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: "Border Around Image"

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

}
