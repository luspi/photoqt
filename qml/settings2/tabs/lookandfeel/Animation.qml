import QtQuick 2.3

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: "Animation and Window Geometry"

		}

		EntrySetting {

			Row {

				spacing: 10

				CustomCheckBox {

					id: animate_elements
					text: qsTr("Animate all fade-in elements")

				}

				CustomCheckBox {

					id: save_restore_geometry
					text: qsTr("Save and restore window geometry")

				}

				CustomCheckBox {

					id: keep_on_top
					text: qsTr("Keep above other windows")

				}

			}

		}

	}

	function setData() {
		animate_elements.checkedButton = settings.myWidgetAnimated
		save_restore_geometry.checkedButton = settings.saveWindowGeometry
		keep_on_top.checkedButton = settings.keepOnTop
	}

	function saveData() {
		settings.myWidgetAnimated = animate_elements.checkedButton
		settings.saveWindowGeometry = save_restore_geometry.checkedButton
		settings.keepOnTop = keep_on_top.checkedButton
	}

}
