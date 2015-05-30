import QtQuick 2.3
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

import "../elements"


Rectangle {

	id: tab

	color: "#00000000"

	anchors {
		fill: parent
		leftMargin: 20
		rightMargin: 20
		topMargin: 15
		bottomMargin: 5
	}

	Flickable {

		id: flickable

		clip: true

		anchors.fill: parent

		contentHeight: contentItem.childrenRect.height+50
		contentWidth: tab.width

		boundsBehavior: Flickable.StopAtBounds

		Column {

			id: maincol

			spacing: 25

			/**********
			* HEADER *
			**********/

			Rectangle {
				id: header
				width: flickable.width
				height: childrenRect.height
				color: "#00000000"
				Text {
					color: colour.text
					font.pointSize: global_fontsize_title
					font.bold: true
					text: qsTr("Other Settings")
					anchors.horizontalCenter: parent.horizontalCenter
				}
			}


			/************
			* LANGUAGE *
			************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("Choose Language") + "</h2><br>" + qsTr("There are a good few different languages available. Thanks to everybody who took the time to translate PhotoQt!")

			}

			ExclusiveGroup { id: languagegroup; }

			Rectangle {

				color: "#00000000"

				width: childrenRect.width
				height: childrenRect.height

				x: (parent.width-width)/2

				GridLayout {

					id: languages

					columns: 6

					TabOtherLanguageTiles { objectName: "en"; text: "English"; exclusiveGroup: languagegroup; checked: true }
					TabOtherLanguageTiles { objectName: "cs"; text: "Čeština"; exclusiveGroup: languagegroup; }
					TabOtherLanguageTiles { objectName: "de"; text: "Deutsch"; exclusiveGroup: languagegroup; }
					TabOtherLanguageTiles { objectName: "el"; text: "Ελληνικά"; exclusiveGroup: languagegroup; }
					TabOtherLanguageTiles { objectName: "es_ES"; text: "Español"; exclusiveGroup: languagegroup; }
					TabOtherLanguageTiles { objectName: "fi"; text: "Suomen kieli"; exclusiveGroup: languagegroup; }
					TabOtherLanguageTiles { objectName: "fr"; text: "Français"; exclusiveGroup: languagegroup; }
					TabOtherLanguageTiles { objectName: "it"; text: "Italiano"; exclusiveGroup: languagegroup; }
					TabOtherLanguageTiles { objectName: "ja"; text: "日本語"; exclusiveGroup: languagegroup; }
					TabOtherLanguageTiles { objectName: "pt_BR"; text: "Português (Brasil)"; exclusiveGroup: languagegroup; }
					TabOtherLanguageTiles { objectName: "pt_PT"; text: "Português (Portugal)"; exclusiveGroup: languagegroup; }
					TabOtherLanguageTiles { objectName: "sk"; text: "Slovenčina"; exclusiveGroup: languagegroup; }
					TabOtherLanguageTiles { objectName: "uk_UA"; text: "Українська"; exclusiveGroup: languagegroup; }
					TabOtherLanguageTiles { objectName: "zh_CN"; text: "Chinese"; exclusiveGroup: languagegroup; }
					TabOtherLanguageTiles { objectName: "zh_TW"; text: "Chinese (traditional)"; exclusiveGroup: languagegroup; }

				}

			}


			/******************
			* QUICK SETTINGS *
			******************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("Quick Settings") + "</h2><br>" + qsTr("The 'Quick Settings' is a widget hidden on the right side of the screen. When you move the cursor there, it shows up, and you can adjust a few simple settings on the spot without having to go through this settings dialog. Of course, only a small subset of settings is available (the ones needed most often). Here you can disable the dialog so that it doesn't show on mouse movement anymore.")

			}

			CustomCheckBox {

				id: quicksettings

				x: (parent.width-width)/2

				text: qsTr("Show 'Quick Settings' on mouse hovering")

			}


			/****************
			* CONTEXT MENU *
			****************/

			SettingsText {

				width: flickable.width

				text: "<h2>" + qsTr("Adjust Context Menu") + "</h2><br>" + qsTr("Here you can adjust the context menu. You can simply drag and drop the entries, edit them, add a new one and remove an existing one.")

			}

			Rectangle {

				id: contextrect

				width: 650
				height: 300
				x: (parent.width-width)/2

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
						font.pointSize: global_fontsize_normal
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
						font.pointSize: global_fontsize_normal
						color: colour.context_header_text
						verticalAlignment: Qt.AlignVCenter
						horizontalAlignment: Qt.AlignHCenter

						text: qsTr("Menu Text")

					}

				}

				TabOtherContext {
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
						fontsize: global_fontsize_normal
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

		for(var i = 0; i < languages.children.length; ++i) {
			if(settings.language === languages.children[i].objectName) {
				languages.children[i].checked = true
				break
			}

		}

		quicksettings.checkedButton = settings.quickSettings

		// The sub element handles its own data
		context.setData()

	}

	function saveData() {

		settings.language = languagegroup.current.objectName

		settings.quickSettings = quicksettings.checkedButton

		// The sub element handles its own data
		context.saveData()

	}

}
