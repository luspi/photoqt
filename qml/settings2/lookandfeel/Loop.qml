import QtQuick 2.3

import "../../elements"
import "../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: "Looping"

		}

		EntrySetting {

			CustomCheckBox {

				text: "Loop through images in folder"

			}

		}

	}

}
