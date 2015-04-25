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
				id: navigation
				category: "Navigation"
				extern: false
				responsiblefor: ["__open","__filterImages","__next","__prev","__gotoFirstThb","__gotoLastThb","__hide","__close"]
				responsiblefor_text: ["Open New File","Filter Images in Folder","Next Image","Previous Image","Go to first Image","Go to last Image","Hide to System Tray","Quit PhotoQt"]
			}

			TabShortcutsCategories {
				id: image
				category: "Image"
				extern: false
				responsiblefor: ["__zoomIn","__zoomOut","__zoomActual","__zoomReset","__rotateR","__rotateL","__rotate0","__flipH","__flipV","__scale"]
				responsiblefor_text: ["Zoom In","Zoom Out","Reset Zoom","Zoom to Actual Size","Rotate Right","Rotate Left","Reset Rotation","Flip Horizontally","Flip Vertically","Scale Image"]
			}

			TabShortcutsCategories {
				id: file
				category: "File"
				extern: false
				responsiblefor: ["__rename","__delete","__copy","__move"]
				responsiblefor_text: ["Rename File","Delete File","Copy File to a New Location","Move File to a New Location"]
			}

			TabShortcutsCategories {
				id: other
				category: "Other"
				extern: false
				responsiblefor: ["__stopThb","__reloadThb","__hideMeta","__showContext","__settings","__slideshow","__slideshowQuick","__about","__wallpaper"]
				responsiblefor_text: ["Interrupt Thumbnail Creation","Reload Thumbnails","Hide/Show Exif Info","Show Context Menu","Show Settings","Start Slideshow","Start Slideshow (Quickstart)","About PhotoQt","Set as Wallpaper"]
			}

			TabShortcutsCategories {
				id: extern
				category: "Extern"
				extern: true
				responsiblefor: ["__extern"]
				responsiblefor_text: ["EXTERN"]
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

	function updateCommand(id, mouse, keys, cmd) {
		extern.updateCommand(id,mouse,keys,cmd)
	}

	function setData() {

		var shortcuts = getanddostuff.getShortcuts()

		navigation.setData(shortcuts)
		image.setData(shortcuts)
		file.setData(shortcuts)
		other.setData(shortcuts)
		extern.setData(shortcuts)
	}


}
