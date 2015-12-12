import QtQuick 2.3
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.2

import "./shortcuts"
import "../../elements"


Rectangle {

	id: tab_top

	property int titlewidth: 100
	property string currentKeyCombo: ""
	onCurrentKeyComboChanged: navigation.currentKeyCombo = currentKeyCombo

	property bool keysReleased: false
	onKeysReleasedChanged: {
		navigation.keysReleased = true
		keysReleased = false
	}

	color: "#00000000"

	anchors {
		fill: parent
		bottomMargin: 5
	}

	Flickable {

		id: flickable

		clip: true

		anchors.fill: parent

		contentHeight: contentItem.childrenRect.height+20
		contentWidth: maincol.width

		Column {

			id: maincol

			Rectangle { color: "transparent"; width: 1; height: 10; }

			Text {
				width: flickable.width
				color: "white"
				font.pointSize: 20
				font.bold: true
				text: "Shortcuts"
				horizontalAlignment: Text.AlignHCenter
			}

			Rectangle { color: "transparent"; width: 1; height: 20; }

			Text {
				color: "white"
				width: flickable.width-20
				x: 10
				wrapMode: Text.WordWrap
				text: qsTr("Here you can adjust the shortcuts, add new or remove existing ones, or change a key combination. The shortcuts are grouped into 4 different categories for internal commands plus a category for external commands. The boxes on the right side contain all the possible commands. To add a shortcut for one of the available function you can either double click on the tile or click the \"+\" button. This automatically opens another widget where you can set a key combination.")
			}

			Rectangle { color: "transparent"; width: 1; height: 30; }

			Rectangle { color: "#88ffffff"; width: parent.width; height: 1; }

			Rectangle { color: "transparent"; width: 1; height: 20; }

			Navigation { id: navigation }
//			Language { id: language }
//			CustomEntries { id: customentries; alternating: true }
//			FileTypesQt { id: filetypesqt }
//			FileTypesGM { id: filetypesgm; alternating: true }
//			FileTypesGMGhostscript { id: filetypesgmghostscript }
//			FileTypesExtras { id: filetypesextras; alternating: true }
//			FileTypesUntested { id: filetypesuntested }


		}

	}

	function setData() {
		navigation.setData()
	}

	function saveData() {
	}


	function addShortcut() {
		console.log("ADDING:", detectShortcut.command, detectShortcut.combo, detectShortcut.category)
	}

}
