import QtQuick 2.3
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.2

import "./shortcuts"
import "../../elements"


Rectangle {

	id: tab_top

	property int titlewidth: 100
	property string currentKeyCombo: ""
	onCurrentKeyComboChanged: {
		navigation.currentKeyCombo = currentKeyCombo
		image.currentKeyCombo = currentKeyCombo
		file.currentKeyCombo = currentKeyCombo
		other.currentKeyCombo = currentKeyCombo
		external.currentKeyCombo = currentKeyCombo
	}

	property bool keysReleased: false
	onKeysReleasedChanged: {
		navigation.keysReleased = true
		image.keysReleased = true
		file.keysReleased = true
		other.keysReleased = true
		external.keysReleased = true
		keysReleased = false
	}

									 //: Refers to a keyboard modifier
	property var key_translations: { "Alt" : str_keys.alt,
									 //: Refers to a keyboard modifier
									 "Ctrl" : str_keys.ctrl,
									 //: Refers to a keyboard modifier
									 "Shift" : str_keys.shift,
									 //: Refers to a keyboard special key
									 "Page Up" : str_keys.pageUp,
									 //: Refers to a keyboard special key
									 "Page Down" : str_keys.pageDown,
									 //: Refers to a keyboard special key
									 "Meta" : str_keys.meta,
									 //: Refers to a keyboard special key
									 "Keypad" : str_keys.keypad,
									 //: Refers to a keyboard special key
									 "Escape" : str_keys.esc,
									 //: Refers to a keyboard arrow key
									 "Right" : str_keys.arrow_right,
									 //: Refers to a keyboard arrow key
									 "Left" : str_keys.arrow_left,
									 //: Refers to a keyboard arrow key
									 "Up" : str_keys.arrow_up,
									 //: Refers to a keyboard arrow key
									 "Down" : str_keys.arrow_down,
									 //: Refers to a keyboard special key
									 "Space" : str_keys.space,
									 //: Refers to a keyboard special key
									 "Delete" : str_keys.del,
									 //: Refers to a keyboard special key
									 "Home" : str_keys.home,
									 //: Refers to a keyboard special key
									 "End" : str_keys.end,
									 //: Refers to a keyboard special key
									 "Insert" : str_keys.insert,
									 //: Refers to a keyboard special key
									 "Tab" : str_keys.tab,
									 //: Refers to a keyboard special key
									 "Return" : str_keys.ret,
									 //: Refers to a keyboard special key
									 "Enter" : str_keys.enter,
									 //: Refers to a mouse button
									 "Left Button" : str_mouse.leftButton,
									 //: Refers to a mouse button
									 "Right Button" : str_mouse.rightButton,
									 //: Refers to a mouse button
									 "Middle Button" : str_mouse.middleButton,
									 //: Refers to a mouse wheel event
									 "Wheel Up" : str_mouse.wheelUp,
									 //: Refers to a mouse wheel event
									 "Wheel Down" : str_mouse.wheelDown}
	function getKeyTranslation(key) {

		if(key.indexOf("+") !== -1) {

			var parts = key.split("+")
			var ret = ""
			for(var ele in parts) {
				var cur = parts[ele]
				if(ret != "") ret += "+"
				if(cur in key_translations)
					ret += key_translations[cur]
				else
					ret += cur
			}

			return ret

		} else {
			if(key in key_translations)
				return key_translations[key]
			return key
		}
	}

	function getOriginalKeyText(trans) {

		if(trans.indexOf("+") !== -1) {

			var parts = trans.split("+")
			var ret = ""
			for(var ele in parts) {
				var cur = parts[ele]
				if(ret != "") ret += "+"
				var foundThisOne = ""
				for(var t in key_translations) {
					if(cur === key_translations[t])
						foundThisOne = t;
				}
				ret += foundThisOne
				if(foundThisOne == "")
					ret += cur

			}

			return ret

		} else {

			for(var ele in key_translations){
				if(key_translations[ele] === trans)
					return ele
			}
			return trans

		}

	}


	// If this is true, then all key presses are passed on to sub elements and doesn't trigger any shortcuts
	property bool amDetectingANewShortcut: false

	// This list holds all the currently set shortcuts to detect double shortcuts
	property var usedUpKeyCombos: ({})
	onUsedUpKeyCombosChanged: {
		recheckKeyCombo(usedUpKeyCombos)
		settings_top.usedUpKeyCombos = usedUpKeyCombos
	}

	// Re-check to see if key combo is set more than once
	signal recheckKeyCombo(var combos)

	// This signal ensures that only one shortcut is detected at a time in any category
	signal cancelDetectionEverywhere()

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

			CustomButton {
				x: (parent.width-width)/2
				text: qsTr("Set default shortcuts")
				onClickedButton: confirmdefaultshortcuts.show()
			}

			Rectangle { color: "transparent"; width: 1; height: 20; }

			ShortcutsContainer {
				id: navigation
				category: "Navigation"
				allAvailableItems: [["__open",qsTr("Open New File")],
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
				category: "Image"
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
				category: "File"
				allAvailableItems: [["__rename", qsTr("Rename File")],
									["__delete", qsTr("Delete File")],
									["__copy", qsTr("Copy File to a New Location")],
									["__move", qsTr("Move File to a New Location")]]
			}

			ShortcutsContainer {
				id: other
				category: "Other"
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
				category: "External"
				external: true
				allAvailableItems: [["", qsTr("")]]
			}

		}

	}

	function loadDefault() {
		var _shortcuts = getanddostuff.getDefaultShortcuts()
		navigation.setData(_shortcuts)
		image.setData(_shortcuts)
		file.setData(_shortcuts)
		other.setData(_shortcuts)
		external.setData(_shortcuts)

		usedUpKeyCombos = []
		// extract all set key combos
		for(var ele in _shortcuts) {
			if(ele in usedUpKeyCombos)
				usedUpKeyCombos[ele] += 1
			else
				usedUpKeyCombos[ele] = 1
		}

	}

	function setData() {
		var _shortcuts = getanddostuff.getShortcuts()
		navigation.setData(_shortcuts)
		image.setData(_shortcuts)
		file.setData(_shortcuts)
		other.setData(_shortcuts)
		external.setData(_shortcuts)

		usedUpKeyCombos = []
		// extract all set key combos
		for(var ele in _shortcuts) {
			if(ele in usedUpKeyCombos)
				usedUpKeyCombos[ele] += 1
			else
				usedUpKeyCombos[ele] = 1
		}

	}

	function addAKeyCombo(combo) {
		var tmp = usedUpKeyCombos
		if(combo in tmp) {
			tmp[combo] += 1
		} else
			tmp[combo] = 1
		usedUpKeyCombos = tmp
	}

	function deleteAKeyCombo(combo) {
		var tmp = usedUpKeyCombos
		tmp[combo] -= 1
		usedUpKeyCombos = tmp
	}

	function saveData() {

		var tosave = {}
		tosave = merge_options(tosave, navigation.saveData())
		tosave = merge_options(tosave, image.saveData())
		tosave = merge_options(tosave, file.saveData())
		tosave = merge_options(tosave, other.saveData())
		tosave = merge_options(tosave, external.saveData())

		getanddostuff.saveShortcuts(tosave)

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
