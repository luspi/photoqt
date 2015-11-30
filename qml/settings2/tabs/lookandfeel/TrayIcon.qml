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
					id: tray_one
					text: "No tray icon"
					exclusiveGroup: tray
					checked: true
				}
				CustomRadioButton {
					id: tray_two
					text: "Hide to tray icon"
					exclusiveGroup: tray
				}
				CustomRadioButton {
					id: tray_three
					text: "Show tray icon, but don't hide to it"
					exclusiveGroup: tray
				}

			}

		}

	}

	function setData() {
		if(settings.trayicon == 0)
			tray_one.checked = true
		else if(settings.trayicon == 1)
			tray_two.checked = true
		else if(settings.trayicon == 2)
			tray_three.checked = true
	}

	function saveData() {
		if(tray_one.checked)
			settings.trayicon = 0
		else if(tray_two.checked)
			settings.trayicon = 1
		else if(tray_three.checked)
			settings.trayicon = 2
	}

}
