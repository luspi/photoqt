import QtQuick 2.3
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.2

import "../../elements"
import "shortcuts"


Rectangle {

	id: tab_top

	property int titlewidth: 100

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
				text: qsTr("Shortcuts")
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

			CustomButton {
				x: (parent.width-width)/2
				text: qsTr("Set default shortcuts")
				onClickedButton: confirmdefaultshortcuts.show()
			}

			Rectangle { color: "transparent"; width: 1; height: 20; }

			ShortcutsContainer {
				id: navigation
				category: qsTr("Navigation")
				allAvailableItems: [["__open",qsTr("Open New File")],
									["__openOld",qsTr("Open New File") + " (Old)"],
									["__filterImages",qsTr("Filter Images in Folder")],
									["__next",qsTr("Next Image")],
									["__prev",qsTr("Previous Image")],
									["__gotoFirstThb",qsTr("Go to first Image")],
									["__gotoLastThb",qsTr("Go to last Image")],
									["__hide",qsTr("Hide to System Tray")],
									["__close",qsTr("Quit PhotoQt")]]
			}

			ShortcutsContainer {
				id: image
				category: qsTr("Image")
				allAvailableItems: [["__zoomIn", qsTr("Zoom In")],
									["__zoomOut", qsTr("Zoom Out")],
									["__zoomActual", qsTr("Zoom to Actual Size")],
									["__zoomReset", qsTr("Reset Zoom")],
									["__rotateR", qsTr("Rotate Right")],
									["__rotateL", qsTr("Rotate Left")],
									["__rotate0", qsTr("Reset Rotation")],
									["__flipH", qsTr("Flip Horizontally")],
									["__flipV", qsTr("Flip Vertically")],
									["__scale", qsTr("Scale Image")]]
			}

			ShortcutsContainer {
				id: file
				category: qsTr("File")
				allAvailableItems: [["__rename", qsTr("Rename File")],
									["__delete", qsTr("Delete File")],
									["__deletePermanent", qsTr("Delete File (without confirmation)")],
									["__copy", qsTr("Copy File to a New Location")],
									["__move", qsTr("Move File to a New Location")]]
			}

			ShortcutsContainer {
				id: other
				category: qsTr("Other")
				allAvailableItems: [["__stopThb", qsTr("Interrupt Thumbnail Creation")],
									["__reloadThb", qsTr("Reload Thumbnails")],
									["__hideMeta", qsTr("Hide/Show Exif Info")],
									["__settings", qsTr("Show Settings")],
									["__slideshow", qsTr("Start Slideshow")],
									["__slideshowQuick", qsTr("Start Slideshow (Quickstart)")],
									["__about", qsTr("About PhotoQt")],
									["__wallpaper", qsTr("Set as Wallpaper")]]
			}

			ShortcutsContainer {
				id: external
				category: qsTr("External")
				external: true
				allAvailableItems: [["", qsTr("")]]
			}

		}

	}

	function setData() {
		var _key_shortcuts = getanddostuff.getKeyShortcuts()
		var _mouse_shortcuts = getanddostuff.getMouseShortcuts()
		var _touch_shortcuts = getanddostuff.getTouchShortcuts()
		detectshortcut.setTakenShortcuts(_key_shortcuts, _mouse_shortcuts, _touch_shortcuts)
		navigation.setData(_key_shortcuts, _mouse_shortcuts, _touch_shortcuts)
		image.setData(_key_shortcuts, _mouse_shortcuts, _touch_shortcuts)
		file.setData(_key_shortcuts, _mouse_shortcuts, _touch_shortcuts)
		other.setData(_key_shortcuts, _mouse_shortcuts, _touch_shortcuts)
		external.setData(_key_shortcuts, _mouse_shortcuts, _touch_shortcuts)
	}

	function loadDefault() {
		var _key_shortcuts = getanddostuff.getDefaultKeyShortcuts()
		var _mouse_shortcuts = getanddostuff.getDefaultMouseShortcuts()
		var _touch_shortcuts = getanddostuff.getDefaultTouchShortcuts()
		detectshortcut.setTakenShortcuts(_key_shortcuts, _mouse_shortcuts, _touch_shortcuts)
		navigation.setData(_key_shortcuts, _mouse_shortcuts, _touch_shortcuts)
		image.setData(_key_shortcuts, _mouse_shortcuts, _touch_shortcuts)
		file.setData(_key_shortcuts, _mouse_shortcuts, _touch_shortcuts)
		other.setData(_key_shortcuts, _mouse_shortcuts, _touch_shortcuts)
		external.setData(_key_shortcuts, _mouse_shortcuts, _touch_shortcuts)
	}

	function saveData() {
		var ret = {};
		ret = merge_options(ret, navigation.saveData())
		ret = merge_options(ret, image.saveData())
		ret = merge_options(ret, file.saveData())
		ret = merge_options(ret, other.saveData())
		ret = merge_options(ret, external.saveData())
		getanddostuff.saveShortcuts(ret)
	}

	function merge_options(obj1,obj2){
		var obj3 = {};
		for (var attrname in obj1)
			obj3[attrname] = obj1[attrname];
		for (attrname in obj2)
			obj3[attrname] = obj2[attrname];
		return obj3;
	}

}
