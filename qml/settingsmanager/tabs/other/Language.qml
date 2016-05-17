import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

import "../../../elements"
import "../../"

EntryContainer {

	id: item_top

	Row {

		spacing: 20

		EntryTitle {

			id: title
			title: qsTr("Language")
			helptext: qsTr("There are a good few different languages available. Thanks to everybody who took the time to translate PhotoQt!")

		}

		EntrySetting {

			id: entry

			ExclusiveGroup { id: languagegroup; }

			GridView {

				property var languageitems: [["en","English",""],
											["ar","عربي ,عربى",""],
											["cs","Čeština",""],
											["de","Deutsch",""],
											["el","Ελληνικά",""],
											["es_ES","Español (España)",""],
											["es_CR","Español (Costa Rica)",""],
											["fi","Suomen kieli",""],
											["fr","Français",""],
											["he","עברית",""],
											["it","Italiano",""],
											["ja","日本語",""],
											["lt","lietuvių kalba",""],
											["pl","Polski",""],
											["pt_BR","Português (Brasil)",""],
											["pt_PT","Português (Portugal)",""],
											["ru_RU","русский язык",""],
											["sk","Slovenčina",""],
											["tr","Türkçe",""],
											["uk_UA","Українська",""],
											["zh_CN","Chinese",""],
											["zh_TW","Chinese (traditional)",""]]

				property string currentlySelected: ""

				id: grid
				width: Math.floor((item_top.width-title.width-title.x-parent.parent.spacing-5)/(cellWidth)) * (cellWidth)
				height: childrenRect.height
				cellWidth: 200
				cellHeight: 30 + 2*spacing
				property int spacing: 3

				model: languageitems.length
				delegate: LanguageTile {
					id: tile
					objectName: grid.languageitems[index][0]
					text: grid.languageitems[index][1]
					author: grid.languageitems[index][2]
					checked: (objectName===grid.currentlySelected)
					exclusiveGroup: languagegroup
					width: grid.cellWidth-grid.spacing*2
					x: grid.spacing
					height: grid.cellHeight-grid.spacing*2
					y: grid.spacing
				}


			}

		}

	}

	function setData() {
		grid.currentlySelected = settings.language
	}

	function saveData() {
		settings.language = languagegroup.current.objectName
	}

}
