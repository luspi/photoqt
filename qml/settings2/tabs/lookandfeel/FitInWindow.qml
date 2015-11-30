import QtQuick 2.3

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: "Fit in Window"

		}

		EntrySetting {

			CustomCheckBox {

				text: "Fit Smaller Images in Window"

			}

		}

	}

}
