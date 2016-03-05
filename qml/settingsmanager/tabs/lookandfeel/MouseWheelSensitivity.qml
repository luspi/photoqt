import QtQuick 2.3

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			id: entrytitle

			title: "Mouse Wheel Sensitivity"
			helptext: qsTr("Here you can adjust the sensitivity of the mouse wheel. For example, if you have set the mouse wheel up/down for switching back and forth between images, then a lower sensitivity means that you will have to scroll further for triggering a shortcut. Per default it is set to the highest sensitivity, i.e. every single wheel movement is evaluated.")

		}

		EntrySetting {

			Row {

				spacing: 10

				Text {

					id: txt_no
					color: colour.text
					text: qsTr("Not at all sensitive")
					font.pointSize: 10

				}

				CustomSlider {

					id: wheelsensitivity

					width: Math.min(400, settings_top.width-entrytitle.width-txt_no.width-txt_very.width-60)
					y: (parent.height-height)/2

					minimumValue: 1
					maximumValue: 10

					tickmarksEnabled: true
					stepSize: 1

				}

				Text {

					id: txt_very
					color: colour.text
					text: qsTr("Very sensitive")
					font.pointSize: 10

				}

			}

		}

	}

	function setData() {
		wheelsensitivity.value = wheelsensitivity.maximumValue-settings.mouseWheelSensitivity
	}

	function saveData() {
		settings.mouseWheelSensitivity = wheelsensitivity.maximumValue-wheelsensitivity.value
	}

}
