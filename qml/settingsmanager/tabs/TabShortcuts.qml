import QtQuick 2.3
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
				//: Used as heading of tab in the settings manager
				text: qsTr("Shortcuts")
				horizontalAlignment: Text.AlignHCenter
			}

			Rectangle { color: "transparent"; width: 1; height: 20; }

			SettingsText {
				width: flickable.width-20
				x: 10
				text: qsTr("Here you can adjust the shortcuts, add new or remove existing ones, or change a key/mouse/touch combination. The shortcuts are grouped into 4 different categories for internal commands plus a category for external commands. The boxes on the right side contain all the possible commands. To add a shortcut for one of the available function simply click on one of the rectangles. This will automatically open another element where you can set the desired shortcut.")
			}

			Rectangle { color: "transparent"; width: 1; height: 30; }

			Rectangle { color: "#88ffffff"; width: parent.width; height: 1; }

			Rectangle { color: "transparent"; width: 1; height: 20; }

			SettingsText {

				width: flickable.width-20
				x: 10

				text: qsTr("Pressing the left button of the mouse and moving it around can be used for moving a zommed image around. The same goes for a single finger on a touch screen (if one is available). If you want to use them for this purpose, then these type of gestures cannot be used for any other shortcut!")

			}

			Rectangle { color: "transparent"; width: 1; height: 10; }

			Rectangle {
				color: "transparent"
				width: childrenRect.width
				height: childrenRect.height
				x: (parent.width-width)/2

				Row {

					spacing: 15

					CustomCheckBox {
						id: mouseleftbutton
						//: This is written on a checkbox in the shortcuts tab of the settings manager
						text: qsTr("Mouse: Left button click-and-move")
						onCheckedButtonChanged: detectshortcut.leftButtonMouseClickAndMove = checkedButton
					}

					CustomCheckBox {
						id: touchsinglefinger
						enabled: getanddostuff.isTouchScreenAvailable()
						//: This is written on a checkbox in the shortcuts tab of the settings manager
						text: qsTr("Touch screen: One finger press-and-move")
						onCheckedButtonChanged: detectshortcut.singleFingerTouchPressAndMove = checkedButton
					}

				}

			}

			Rectangle { color: "transparent"; width: 1; height: 30; }

			CustomButton {
				x: (parent.width-width)/2
				//: Written on a button in the shortcuts section of the settings manager
				text: qsTr("Set default shortcuts")
				onClickedButton: confirmdefaultshortcuts.show()
			}

			Rectangle { color: "transparent"; width: 1; height: 20; }

			ShortcutsContainer {
				id: navigation
				//: One of the shortcuts categories
				category: qsTr("Navigation")
				//: This is a shortcut description
				allAvailableItems: [["__open",qsTr("Open New File")],
									//: This is a shortcut description
									["__filterImages",qsTr("Filter Images in Folder")],
									//: This is a shortcut description
									["__next",qsTr("Next Image")],
									//: This is a shortcut description
									["__prev",qsTr("Previous Image")],
									//: This is a shortcut description
									["__gotoFirstThb",qsTr("Go to first Image")],
									//: This is a shortcut description
									["__gotoLastThb",qsTr("Go to last Image")],
									//: This is a shortcut description
									["__hide",qsTr("Hide to System Tray")],
									//: This is a shortcut description
									["__close",qsTr("Quit PhotoQt")]]
			}

			ShortcutsContainer {
				id: image
				//: One of the shortcuts categories
				category: qsTr("Image")
				//: This is a shortcut description
				allAvailableItems: [["__zoomIn", qsTr("Zoom In")],
									//: This is a shortcut description
									["__zoomOut", qsTr("Zoom Out")],
									//: This is a shortcut description
									["__zoomActual", qsTr("Zoom to Actual Size")],
									//: This is a shortcut description
									["__zoomReset", qsTr("Reset Zoom")],
									//: This is a shortcut description
									["__rotateR", qsTr("Rotate Right")],
									//: This is a shortcut description
									["__rotateL", qsTr("Rotate Left")],
									//: This is a shortcut description
									["__rotate0", qsTr("Reset Rotation")],
									//: This is a shortcut description
									["__flipH", qsTr("Flip Horizontally")],
									//: This is a shortcut description
									["__flipV", qsTr("Flip Vertically")],
									//: This is a shortcut description
									["__scale", qsTr("Scale Image")]]
			}

			ShortcutsContainer {
				id: file
				//: One of the shortcuts categories
				category: qsTr("File")
				//: This is a shortcut description
				allAvailableItems: [["__rename", qsTr("Rename File")],
									//: This is a shortcut description
									["__delete", qsTr("Delete File")],
									//: This is a shortcut description
									["__deletePermanent", qsTr("Delete File (without confirmation)")],
									//: This is a shortcut description
									["__copy", qsTr("Copy File to a New Location")],
									//: This is a shortcut description
									["__move", qsTr("Move File to a New Location")]]
			}

			ShortcutsContainer {
				id: other
				//: One of the shortcuts categories
				category: qsTr("Other")
				//: This is a shortcut description
				allAvailableItems: [["__stopThb", qsTr("Interrupt Thumbnail Creation")],
									//: This is a shortcut description
									["__reloadThb", qsTr("Reload Thumbnails")],
									//: This is a shortcut description
									["__hideMeta", qsTr("Hide/Show Exif Info")],
									//: This is a shortcut description
									["__settings", qsTr("Show Settings")],
									//: This is a shortcut description
									["__slideshow", qsTr("Start Slideshow")],
									//: This is a shortcut description
									["__slideshowQuick", qsTr("Start Slideshow (Quickstart)")],
									//: This is a shortcut description
									["__about", qsTr("About PhotoQt")],
									//: This is a shortcut description
									["__wallpaper", qsTr("Set as Wallpaper")]]
			}

			ShortcutsContainer {
				id: external
				//: One of the shortcuts categories
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

		mouseleftbutton.checkedButton = settings.leftButtonMouseClickAndMove
		touchsinglefinger.checkedButton = settings.singleFingerTouchPressAndMove

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

		settings.leftButtonMouseClickAndMove = mouseleftbutton.checkedButton
		settings.singleFingerTouchPressAndMove = touchsinglefinger.checkedButton

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
