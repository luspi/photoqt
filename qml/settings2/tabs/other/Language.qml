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
			title: "Language"
			helptext: qsTr("There are a good few different languages available. Thanks to everybody who took the time to translate PhotoQt!")

		}

		EntrySetting {

			id: entry

			ExclusiveGroup { id: languagegroup; }

			GridLayout {

				id: grid
				property int w: item_top.width-title.width-title.x
				width: item_top.width-title.width-title.x-parent.parent.spacing-20
				columns: width/(english.width+columnSpacing)

				clip: true
				rowSpacing: 3
				columnSpacing: 5

				LanguageTile { id: english; objectName: "en"; text: "English"; exclusiveGroup: languagegroup; checked: true }
				LanguageTile { objectName: "cs"; text: "Čeština"; exclusiveGroup: languagegroup; }
				LanguageTile { objectName: "de"; text: "Deutsch"; exclusiveGroup: languagegroup; }
				LanguageTile { objectName: "el"; text: "Ελληνικά"; exclusiveGroup: languagegroup; }
				LanguageTile { objectName: "es_ES"; text: "Español (España)"; exclusiveGroup: languagegroup; }
				LanguageTile { objectName: "es_CR"; text: "Español (Costa Rica)"; exclusiveGroup: languagegroup; }
				LanguageTile { objectName: "fi"; text: "Suomen kieli"; exclusiveGroup: languagegroup; }
				LanguageTile { objectName: "fr"; text: "Français"; exclusiveGroup: languagegroup; }
				LanguageTile { objectName: "he"; text: "עברית"; exclusiveGroup: languagegroup; }
				LanguageTile { objectName: "it"; text: "Italiano"; exclusiveGroup: languagegroup; }
				LanguageTile { objectName: "ja"; text: "日本語"; exclusiveGroup: languagegroup; }
				LanguageTile { objectName: "pl"; text: "Polski"; exclusiveGroup: languagegroup; }
				LanguageTile { objectName: "pt_BR"; text: "Português (Brasil)"; exclusiveGroup: languagegroup; }
				LanguageTile { objectName: "pt_PT"; text: "Português (Portugal)"; exclusiveGroup: languagegroup; }
				LanguageTile { objectName: "sk"; text: "Slovenčina"; exclusiveGroup: languagegroup; }
				LanguageTile { objectName: "uk_UA"; text: "Українська"; exclusiveGroup: languagegroup; }
				LanguageTile { objectName: "zh_CN"; text: "Chinese"; exclusiveGroup: languagegroup; }
				LanguageTile { objectName: "zh_TW"; text: "Chinese (traditional)"; exclusiveGroup: languagegroup; }

			}

		}

	}

	function setData() {
		for(var i = 0; i < grid.children.length; ++i) {
			if(settings.language === grid.children[i].objectName) {
				grid.children[i].checked = true
				break
			}
		}
	}

	function saveData() {
		settings.language = languagegroup.current.objectName
	}

}
