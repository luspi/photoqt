import QtQuick 2.3
import QtQuick.Controls 1.2

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			//: Settings title: Rotate/flip image automatically according to its metadata
			title: qsTr("Automatic Rotate/Flip")
			helptext: qsTr("Some cameras can detect - while taking the photo - whether the camera was turned and might store this information in the image exif data. If PhotoQt finds this information, it can rotate the image accordingly. When asking PhotoQt to always rotate images automatically without asking, it already does so at image load (including thumbnails).")

		}

		EntrySetting {

			id: entry

			ExclusiveGroup { id: rotateflipgroup; }

			Row {

				spacing: 10

				CustomRadioButton {
					id: neverrotate
					text: qsTr("Never rotate/flip images")
					exclusiveGroup: rotateflipgroup
					checked: true
				}
				CustomRadioButton {
					id: alwaysrotate
					text: qsTr("Always rotate/flip images")
					exclusiveGroup: rotateflipgroup
				}
				CustomRadioButton {
					id: alwaysask
					//: Used as in 'Always ask whether to rotate/flip an image according to its metadata'
					text: qsTr("Always ask")
					exclusiveGroup: rotateflipgroup
				}

			}

		}

	}

	function setData() {
		neverrotate.checked = (settings.exifrotation === "Never")
		alwaysrotate.checked = (settings.exifrotation === "Always")
		alwaysask.checked = (settings.exifrotation === "Ask")
	}

	function saveData() {
		settings.exifrotation = neverrotate.checked ? "Never" : (alwaysrotate.checked ? "Always" : "Ask")
	}

}
