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

			spacing: 15

			/**********
			* HEADER *
			**********/

			Rectangle {
				id: header
				width: flickable.width
				height: childrenRect.height
				color: "#00000000"
				Text {
					color: "white"
					font.pointSize: 18
					font.bold: true
					text: "Shortcuts"
					anchors.horizontalCenter: parent.horizontalCenter
				}
			}

			/********************
			* DESCRIPTIVE TEXT *
			********************/

			SettingsText {

				width: flickable.width

				text: "<br>Here you can adjust the shortcuts, add new or remove existing ones, or change a key combination. The shortcuts are grouped into 4 different categories for internal commands plus a category for external commands. The boxes on the right side contain all the possible commands. To add a shortcut for one of the available function you can either double click on the tile or click the \"+\" button. This automatically opens another widget where you can set a key combination.<br>"

			}


			/****************************
			 * RE-SET DEFAULT SHORTCUTS *
			 ****************************/

			CustomButton {
				text: "Set default shortcuts"
				anchors.horizontalCenter: parent.horizontalCenter
			}

			TabShortcutsCategories {
				id: cat
				category: "Navigation"
				responsiblefor: ["__open","__filterImages","__next","__prev","__gotoFirstThb","__gotoLastThb","__hide","__close"]
				responsiblefor_text: ["Open New File","Filter Images in Folder","Next Image","Previous Image","Go to first Image","Go to last Image","Hide to System Tray","Quit PhotoQt"]
			}




		}

	}

	function addShortcut(cmd, key) {
		if(cat.responsiblefor.indexOf(cmd) != -1) {
			cat.addShortcut(cmd,key)
		}

		console.log("new:",cmd,key)
	}

	function addMouseShortcut(cmd, key) {
		if(cat.responsiblefor.indexOf(cmd) != -1) {
			cat.addMouseShortcut(cmd,key)
		}

		console.log("new mouse:",cmd,key)
	}

	function setData() {

		var shortcuts = getanddostuff.getShortcuts()

		cat.setData(shortcuts)
	}


}
