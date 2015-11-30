import QtQuick 2.3

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: "Window Mode"

		}

		EntrySetting {

			Row {

				spacing: 10

				CustomCheckBox {
					id: windowmode
					text: qsTr("Run PhotoQt in Window Mode")
					onButtonCheckedChanged:     // 'Window Decoration' checkbox is only enabled when the 'Window ModeÄ checkbox is checked
					windowmode_deco.enabled = checkedButton
				}

				CustomCheckBox {
					id: windowmode_deco
					enabled: false
					opacity: enabled ? 1 : 0.3
					Behavior on opacity { NumberAnimation { duration: 100; } }
					text: qsTr("Show Window Decoration")
				}

			}

		}

	}

	function setData() {
		windowmode.checkedButton = settings.windowmode
		windowmode_deco.enabled = windowmode.checkedButton
		windowmode_deco.checkedButton = settings.windowDecoration
	}

	function saveData() {
		settings.windowmode = windowmode.checkedButton
		settings.windowDecoration = windowmode_deco.checkedButton
	}

}
