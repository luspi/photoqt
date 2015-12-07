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
			title: "Language"
			helptext: qsTr("There are a good few different languages available. Thanks to everybody who took the time to translate PhotoQt!")

		}

		EntrySetting {

			id: entry

			Rectangle {

				id: contextrect

				width: 650
				height: 300
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

				Rectangle {

					color: "#00000000"
					width: contextrect.width
					height: contextadd.height
					anchors.top: context.bottom
					anchors.topMargin: 15

					CustomButton {
						id: contextadd
						text: qsTr("Add new context menu entry")
						anchors.horizontalCenter: parent.horizontalCenter
						onClickedButton: context.addNewItem()
					}


					CustomButton {
						id: contextreset
						text: qsTr("(Re-)set automatically")
						fontsize: 10
						anchors.right: parent.right
						onClickedButton: {
							getanddostuff.setDefaultContextMenuEntries()
							context.setData()
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
