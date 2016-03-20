import QtQuick 2.3
import QtQuick.Controls 1.2

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: qsTr("Disable thumbnails")
			helptext: qsTr("If you just don't need or don't want any thumbnails whatsoever, then you can disable them here completely. This option can also be toggled remotely via command line (run 'photoqt --help' for more information on that). This might increase the speed of PhotoQt a good bit, however, navigating through a folder might be a little harder without thumbnails.")

		}

		EntrySetting {

			id: entry

			CustomCheckBox {

				id: disable
				text: qsTr("Disable Thumbnails altogether")

			}

		}

	}

	function setData() {
		disable.checkedButton = settings.thumbnailDisable
	}

	function saveData() {
		settings.thumbnailDisable = disable.checkedButton
	}

}
