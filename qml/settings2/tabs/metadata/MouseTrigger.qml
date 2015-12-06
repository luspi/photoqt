import QtQuick 2.3
import QtQuick.Controls 1.2

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: "Enable 'Hot Edge'"
			helptext: qsTr("Per default the info widget can be shown two ways: Moving the mouse cursor to the left screen edge to fade it in temporarily (as long as the mouse is hovering it), or permanently by clicking the checkbox (checkbox only stored per session, can't be saved permanently!). Alternatively the widget can also be triggered by shortcut. On demand the mouse triggering can be disabled, so that the widget would only show on shortcut. This can come in handy, if you get annoyed by accidentally opening the widget occasionally.")

		}

		EntrySetting {

			id: entry

			CustomCheckBox {

				id: triggeronmouse
				text: qsTr("Turn mouse triggering OFF")

			}

		}

	}

	function setData() {
		triggeronmouse.checkedButton = settings.exifenablemousetriggering
	}

	function saveData() {
		settings.exifenablemousetriggering = triggeronmouse.checkedButton
	}

}
