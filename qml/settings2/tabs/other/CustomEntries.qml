import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

import "../../../elements"
import "../../"
import "./"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			id: title
			title: "Custom Menu Entries"
			helptext: qsTr("Here you can adjust the context menu. You can simply drag and drop the entries, edit them, add a new one and remove an existing one.")

		}

		EntrySetting {

			id: entry

			Row {

				spacing: 15

				Rectangle {

					id: contextrect

					width: 650
					height: 200
	//				x: (parent.width-width)/2

					radius: global_item_radius

					color: colour.tiles_inactive

					Rectangle {

						id: headContext

						color: colour.context_header_bg

						width: parent.width-10
						height: 30

						x: 5
						y: 5
						radius: global_item_radius

						Text {

							x: context.binaryX
							y: (parent.height-height)/2
							width: context.textEditWidth

							font.bold: true
							font.pointSize: 10
							color: colour.context_header_text
							verticalAlignment: Qt.AlignVCenter
							horizontalAlignment: Qt.AlignHCenter

							text: qsTr("Executable")

						}

						Text {

							x: context.descriptionX
							y: (parent.height-height)/2
							width: context.textEditWidth

							font.bold: true
							font.pointSize: 10
							color: colour.context_header_text
							verticalAlignment: Qt.AlignVCenter
							horizontalAlignment: Qt.AlignHCenter

							text: qsTr("Menu Text")

						}

					}

					CustomEntriesInteractive {
						id: context
						x: 5
						y: headContext.height+10
						width: parent.width-10
						height: parent.height-headContext.height-20
					}

				}

				Rectangle {

					color: "transparent"
					width: childrenRect.width
					height: childrenRect.height
					y: (parent.height-height)/2

					Column {

						spacing: 20

						CustomButton {
							id: contextadd
							width: 150
							wrapMode: Text.WordWrap
							text: qsTr("Add new entry")
							onClickedButton: context.addNewItem()
						}


						CustomButton {
							id: contextreset
							text: qsTr("Set default")
							width: 150
							onClickedButton: {
								getanddostuff.setDefaultContextMenuEntries()
								context.setData()
							}
						}

					}

				}

			}

		}

	}

	function setData() {
		context.setData()
	}

	function saveData() {
		context.saveData()
	}

}
