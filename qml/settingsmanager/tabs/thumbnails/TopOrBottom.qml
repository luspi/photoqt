import QtQuick 2.3
import QtQuick.Controls 1.2

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: qsTr("Top or Bottom")
			helptext: qsTr("Per default the bar with the thumbnails is shown at the lower edge. However, some might find it nice and handy to have the thumbnail bar at the upper edge, so that's what can be changed here.")

		}

		EntrySetting {

			id: entry

			Row {

				spacing: 10

				ExclusiveGroup { id: edgegroup; }

				CustomRadioButton {
					id: loweredge
					text: qsTr("Show at lower edge")
					checked: true
					exclusiveGroup: edgegroup
				}

				CustomRadioButton {
					id: upperedge
					text: qsTr("Show at upper edge")
					exclusiveGroup: edgegroup
				}

			}

		}

	}

	function setData() {
		loweredge.checked = (settings.thumbnailposition === "Bottom")
		upperedge.checked = (settings.thumbnailposition === "Top")
	}

	function saveData() {
		settings.thumbnailposition = (loweredge.checked ? "Bottom" : "Top")
	}

}
