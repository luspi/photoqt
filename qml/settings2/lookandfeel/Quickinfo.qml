import QtQuick 2.3

import "../../elements"
import "../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			title: "Show Quickinfo (Text Labels)"

		}

		EntrySetting {

			Row {

				spacing: 10

				CustomCheckBox {
					id: quickinfo_counter
					text: qsTr("Counter")
				}

				CustomCheckBox {
					id: quickinfo_filepath
					text: qsTr("Filename")
				}

				CustomCheckBox {
					id: quickinfo_filename
					text: qsTr("Filepath and Filename")
				}

				CustomCheckBox {
					id: quickinfo_closingx
					text: qsTr("Closing \"X\"")
				}

			}

		}

	}

}
