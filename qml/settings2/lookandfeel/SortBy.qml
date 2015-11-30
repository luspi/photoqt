import QtQuick 2.3
import QtQuick.Controls 1.2

import "../../elements"
import "../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: "Sort Images"

		}

		EntrySetting {

			Row {

				spacing: 10

				// Label
				Text {
					y: (parent.height-height)/2
					color: colour.text
					text: qsTr("Sort by:")
					font.pointSize: 10
				}
				// Choose Criteria
				CustomComboBox {
					id: sortimages_checkbox
					y: (parent.height-height)/2
					width: 150
					model: [qsTr("Name"), qsTr("Natural Name"), qsTr("Date"), qsTr("Filesize")]
				}

				// Ascending or Descending
				ExclusiveGroup { id: radiobuttons_sorting }

				CustomRadioButton {
					id: sortimages_ascending
					y: (parent.height-height)/2
					text: qsTr("Ascending")
					icon: "qrc:/img/settings/sortascending.png"
					exclusiveGroup: radiobuttons_sorting
					checked: true
				}
				CustomRadioButton {
					id: sortimages_descending
					y: (parent.height-height)/2
					text: qsTr("Descending")
					icon: "qrc:/img/settings/sortdescending.png"
					exclusiveGroup: radiobuttons_sorting
				}

			}

		}

	}

}
