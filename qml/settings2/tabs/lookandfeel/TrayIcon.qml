import QtQuick 2.3
import QtQuick.Controls 1.2

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: "Hide to Tray Icon"

		}

		EntrySetting {

			Row {

				spacing: 10

				ExclusiveGroup { id: tray; }

				CustomRadioButton {
					text: "No tray icon"
					exclusiveGroup: tray
					checked: true
				}
				CustomRadioButton {
					text: "Hide to tray icon"
					exclusiveGroup: tray
				}
				CustomRadioButton {
					text: "Show tray icon, but don't hide to it"
					exclusiveGroup: tray
				}

			}

		}

	}

}
