import QtQuick 2.3

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			id: entrytitle

			title: "Animation and Window Geometry"
			helptext: qsTr("There are three things that can be adjusted here:") + "<ol><li>" + qsTr("Animation of fade-in widgets (like, e.g., Settings or About Widget)") + "</li><li>" + qsTr("Save and restore of Window Geometry: On quitting PhotoQt, it stores the size and position of the window and can restore it the next time started.") + "</li><li>" + qsTr("Keep PhotoQt above all other windows at all time") + "</li></ol>"

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
					wrapMode: Text.WordWrap
					fixedwidth: settings_top.width-entrytitle.width-animate_elements.width-save_restore_geometry.width-60
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
