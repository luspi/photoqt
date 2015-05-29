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
					text: qsTr("Shortcuts")
					anchors.horizontalCenter: parent.horizontalCenter
				}
			}

			/********************
			* DESCRIPTIVE TEXT *
			********************/

			Rectangle {
				color: "#00000000"
				width: 1
				height: 1
			}

			SettingsText {

				width: flickable.width

				text: qsTr("Here you can adjust the shortcuts, add new or remove existing ones, or change a key combination. The shortcuts are grouped into 4 different categories for internal commands plus a category for external commands. The boxes on the right side contain all the possible commands. To add a shortcut for one of the available function you can either double click on the tile or click the \"+\" button. This automatically opens another widget where you can set a key combination.")

			}

			Rectangle {
				color: "#00000000"
				width: 1
				height: 1
			}


			/****************************
			 * RE-SET DEFAULT SHORTCUTS *
			 ****************************/

			CustomButton {
				text: qsTr("Set default shortcuts")
				anchors.horizontalCenter: parent.horizontalCenter
				onClickedButton: confirmdefaultshortcuts.show()
			}

			TabShortcutsCategories {
				id: navigation
				category: qsTr("Navigation")
				extern: false
				responsiblefor: ["__open","__filterImages","__next","__prev","__gotoFirstThb","__gotoLastThb","__hide","__close"]
				responsiblefor_text: [qsTr("Open New File"),qsTr("Filter Images in Folder"),qsTr("Next Image"),qsTr("Previous Image"),qsTr("Go to first Image"),qsTr("Go to last Image"),qsTr("Hide to System Tray"),qsTr("Quit PhotoQt")]
			}

			TabShortcutsCategories {
				id: image
				category: qsTr("Image")
				extern: false
				responsiblefor: ["__zoomIn","__zoomOut","__zoomActual","__zoomReset","__rotateR","__rotateL","__rotate0","__flipH","__flipV","__scale"]
				responsiblefor_text: [qsTr("Zoom In"),qsTr("Zoom Out"),qsTr("Zoom to Actual Size"),qsTr("Reset Zoom"),qsTr("Rotate Right"),qsTr("Rotate Left"),qsTr("Reset Rotation"),qsTr("Flip Horizontally"),qsTr("Flip Vertically"),qsTr("Scale Image")]
			}

			TabShortcutsCategories {
				id: file
				category: qsTr("File")
				extern: false
				responsiblefor: ["__rename","__delete","__copy","__move"]
				responsiblefor_text: [qsTr("Rename File"),qsTr("Delete File"),qsTr("Copy File to a New Location"),qsTr("Move File to a New Location")]
			}

			TabShortcutsCategories {
				id: other
				category: qsTr("Other")
				extern: false
				responsiblefor: ["__stopThb","__reloadThb","__hideMeta","__showContext","__settings","__slideshow","__slideshowQuick","__about","__wallpaper"]
				responsiblefor_text: [qsTr("Interrupt Thumbnail Creation"),qsTr("Reload Thumbnails"),qsTr("Hide/Show Exif Info"),qsTr("Show Context Menu"),qsTr("Show Settings"),qsTr("Start Slideshow"),qsTr("Start Slideshow (Quickstart)"),qsTr("About PhotoQt"),qsTr("Set as Wallpaper")]
			}

			TabShortcutsCategories {
				id: extern
				category: qsTr("Extern")
				extern: true
				responsiblefor: ["__extern"]
				//: Is the shortcut tile text for EXTERNal shortcuts
				responsiblefor_text: [qsTr("EXTERN")]
			}

		}

	}

	function addShortcut(cmd, key) {
		if(navigation.responsiblefor.indexOf(cmd) != -1) {
			navigation.addShortcut(cmd,key)
		} else if(image.responsiblefor.indexOf(cmd) != -1) {
			image.addShortcut(cmd,key)
		} else if(file.responsiblefor.indexOf(cmd) != -1) {
			file.addShortcut(cmd,key)
		} else if(other.responsiblefor.indexOf(cmd) != -1) {
			other.addShortcut(cmd,key)
		} else
			extern.addExternalShortcut(key)
	}

	function addMouseShortcut(cmd, key) {
		if(navigation.responsiblefor.indexOf(cmd) != -1)
			navigation.addMouseShortcut(cmd,key)
		else if(image.responsiblefor.indexOf(cmd) != -1)
			image.addMouseShortcut(cmd,key)
		else if(file.responsiblefor.indexOf(cmd) != -1)
			file.addMouseShortcut(cmd,key)
		else if(other.responsiblefor.indexOf(cmd) != -1)
			other.addMouseShortcut(cmd,key)
		else
			extern.addExternalMouseShortcut(key)
	}

	function updateExistingShortcut(cmd, key, id) {
		if(navigation.responsiblefor.indexOf(cmd) != -1) {
			navigation.updateShortcut(cmd, key, id)
		}
		if(image.responsiblefor.indexOf(cmd) != -1) {
			image.updateShortcut(cmd, key, id)
		}
		if(file.responsiblefor.indexOf(cmd) != -1) {
			file.updateShortcut(cmd, key, id)
		}
		if(other.responsiblefor.indexOf(cmd) != -1) {
			other.updateShortcut(cmd, key, id)
		}
	}

	function updateExistingMouseShortcut(cmd, key, id) {
		if(navigation.responsiblefor.indexOf(cmd) != -1) {
			navigation.updateMouseShortcut(cmd, key, id)
		}
		if(image.responsiblefor.indexOf(cmd) != -1) {
			image.updateMouseShortcut(cmd, key, id)
		}
		if(file.responsiblefor.indexOf(cmd) != -1) {
			file.updateMouseShortcut(cmd, key, id)
		}
		if(other.responsiblefor.indexOf(cmd) != -1) {
			other.updateMouseShortcut(cmd, key, id)
		}
	}

	function updateCommand(id, close, mouse, keys, cmd) {
		extern.updateCommand(id,close,mouse,keys,cmd)
	}

	function setData() {

		var shortcuts = getanddostuff.getShortcuts()

		navigation.setData(shortcuts)
		image.setData(shortcuts)
		file.setData(shortcuts)
		other.setData(shortcuts)
		extern.setData(shortcuts)
	}

	function saveData() {

		var collected1 = navigation.saveData()
		collected1 = collected1.concat(image.saveData())
		collected1 = collected1.concat(file.saveData())
		collected1 = collected1.concat(other.saveData())
		collected1 = collected1.concat(extern.saveData())

		getanddostuff.saveShortcuts(collected1)

	}

}
