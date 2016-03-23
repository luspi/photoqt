import QtQuick 2.3

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: qsTr("Touchscreen Gestures")
			helptext: qsTr("PhotoQt has some very basic support for touchscreen gestures. This feature is currently still in an experimental state. As of right now, it isn't possible to adjust the gestures. In the near future, support for touchscreen gestures will be extended.")

		}

		EntrySetting {

			CustomCheckBox {

				id: touchscreensupport
				text: qsTr("Enable experimental support for touchscreen gestures")

			}

		}

	}

	function setData() {
		touchscreensupport.checkedButton = settings.experimentalTouchscreenSupport
	}

	function saveData() {
		settings.experimentalTouchscreenSupport = touchscreensupport.checkedButton
	}

}
