import QtQuick 2.3
import QtQuick.Controls 1.2

Item {

	id: detect

	property var shortcutfile: getanddostuff.getShortcuts()

	property string combo: ""
	property bool normalkey: false

	Keys.onPressed: {

		if(blocked && (event.key !== Qt.Key_Escape || blockedSystem)) {
			combo = ""
			normalkey = false
			return
		}

		var txt = ""
		if(event.modifiers & Qt.ShiftModifier)
			txt += "Shift+"
		if(event.modifiers & Qt.ControlModifier)
			txt += "Ctrl+"
		if(event.modifiers & Qt.AltModifier)
			txt += "Alt+"
		if(event.modifiers & Qt.MetaModifier)
			txt += "Meta+"
		if(event.modifiers & Qt.KeypadModifier)
			txt += "Keypad+"
		if(event.key === Qt.Key_Escape) {
			normalkey = true
			txt += "Escape";
		} else if(event.key === Qt.Key_Right) {
			normalkey = true
			txt += "Right";
		} else if(event.key === Qt.Key_Left) {
			normalkey = true
			txt += "Left";
		} else if(event.key === Qt.Key_Up) {
			normalkey = true
			txt += "Up";
		} else if(event.key === Qt.Key_Down) {
			normalkey = true
			txt += "Down";
		} else if(event.key === Qt.Key_Space) {
			normalkey = true
			txt += "Space";
		} else if(event.key === Qt.Key_Delete) {
			normalkey = true
			txt += "Delete";
		} else if(event.key === Qt.Key_Home) {
			normalkey = true
			txt += "Home";
		} else if(event.key === Qt.Key_End) {
			normalkey = true
			txt += "End";
		} else if(event.key === Qt.Key_PageUp) {
			normalkey = true
			txt += "Page Up";
		} else if(event.key === Qt.Key_PageDown) {
			txt += "Page Down";
			normalkey = true
		} else if(event.key === Qt.Key_Insert) {
			normalkey = true
			txt += "Insert";
		} else if(event.key === Qt.Key_Tab) {
			normalkey = true
			txt += "Tab"
		} else if(event.key === Qt.Key_Return) {
			normalkey = true
			txt += "Return"
		} else if(event.key === Qt.Key_Enter) {
			normalkey = true
			txt += "Enter"
		} else if(event.key < 1000) {
			normalkey = true
			txt += String.fromCharCode(event.key)
		} else
			normalkey = false

		combo = txt

	}

	Keys.onReleased: {
		if(!blockedSystem && normalkey && (event.key == 0 || event.modifiers == 0)) {
			if(blocked && combo == "Escape")
				catchEscape()
			else if(combo in shortcutfile)
				execute(shortcutfile[combo][1]);
		}

		combo = "";
	}

	function catchEscape() {
		if(about.opacity == 1)
			about.hideAbout()
		else if(settingsitem.opacity == 1)
			settingsitem.hideSettings()
	}

	function execute(cmd) {

//		if(cmd == "__stopThb")

		if(cmd == "__close")
			Qt.quit()
		if(cmd == "__hide")
			Qt.quit()
		if(cmd == "__settings")
			settingsitem.showSettings()
		if(cmd == "__next")
			thumbnailBar.nextImage()
		if(cmd == "__prev")
			thumbnailBar.previousImage()
//		if(cmd == "__reloadThb")
		if(cmd == "__about")
			about.showAbout()
//		if(cmd == "__slideshow")
//		if(cmd == "__filterImages")
//		if(cmd == "__slideshowQuick")
		if(cmd == "__open" || cmd == "__openOld")
			openFile()
		if(cmd == "__zoomIn")
			image.zoomIn()
		if(cmd == "__zoomOut")
			image.zoomOut()
		if(cmd == "__zoomReset")
			image.resetZoom()
//		if(cmd == "__zoomActual")
		if(cmd == "__rotateL")
			image.rotateLeft()
		if(cmd == "__rotateR")
			image.rotateRight()
		if(cmd == "__rotate0")
			image.resetRotation()
//		if(cmd == "__flipH")
//		if(cmd == "__flipV")
//		if(cmd == "__rename")
//		if(cmd == "__delete")
//		if(cmd == "__copy")
//		if(cmd == "__move")
		if(cmd == "__hideMeta") {
			if(metaData.x < -40) {
				metaData.checkCheckbox()
				background.showMetadata()
			} else {
				metaData.uncheckCheckbox()
				background.hideMetadata()
			}
		}
//		if(cmd == "__showContext")
//		if(cmd == "__gotoFirstThb")
//		if(cmd == "__gotoLastThb")

//		if(cmd == "__wallpaper")
//		if(cmd == "__scale")
	}

}
