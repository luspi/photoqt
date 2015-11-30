import QtQuick 2.3

import "../../elements"
import "../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: "Click on Empty Area"

		}

		EntrySetting {

			CustomCheckBox {

				id: closeongrey
				text: qsTr("Close on click in empty area")

			}

		}

	}

}
