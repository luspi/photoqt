import QtQuick 2.3
import QtQuick.Controls 1.2

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			id: entrytitle

			title: "Label on Thumbnails"
			helptext:  qsTr("When thumbnails are displayed at the top/bottom, PhotoQt usually writes the filename on them (if not disabled). You can also use the slider below to adjust the font size.")

		}

		EntrySetting {

			id: entry

			Row {

				spacing: 10

				CustomCheckBox {
					id: writefilename
					y: (parent.height-height)/2
					text: qsTr("Write Filename")
				}

				Rectangle { color: "transparent"; width: 10; height: 1; }

				Text {
					id: txt_fontsize
					color: enabled ? colour.text : colour.text_inactive
					Behavior on color { ColorAnimation { duration: 150; } }
					y: (parent.height-height)/2
					enabled: writefilename.checkedButton
					opacity: enabled ? 1 : 0.5
					text: "Fontsize:"
				}

				CustomSlider {

					id: fontsize_slider

					width: Math.min(400, Math.max(50,settings_top.width-entrytitle.width-writefilename.width-txt_fontsize.width-fontsize_spinbox.width-80))
					y: (parent.height-height)/2

					minimumValue: 5
					maximumValue: 20

					value: fontsize_spinbox.value
					stepSize: 1
					scrollStep: 1
					tickmarksEnabled: true

					enabled: writefilename.checkedButton

				}

				CustomSpinBox {

					id: fontsize_spinbox
					y: (parent.height-height)/2

					width: 75

					minimumValue: 5
					maximumValue: 20

					value: fontsize_slider.value

					enabled: writefilename.checkedButton

				}

			}

		}

	}

	function setData() {
		writefilename.checkedButton = settings.thumbnailWriteFilename
	}

	function saveData() {
		settings.thumbnailWriteFilename = writefilename.checkedButton
	}

}
