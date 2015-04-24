import QtQuick 2.3
import QtQuick.Controls 1.2
import "../javascript/keydetect.js" as KeyDetect

Item {

	id: detect

	property var shortcutfile: getanddostuff.getShortcuts()

	property string keys: ""

	Keys.onPressed: {

		if(blocked && blockedSystem) return

		var ret = KeyDetect.handleKeyPress(event.key, event.modifiers)

		keys = ret[1];

		if(!blockedSystem && ret[0]) {
			if(blocked && keys == "Escape")
				catchEscape()
			else if(keys in shortcutfile)
				execute(shortcutfile[keys][1]);
		}

	}

	Keys.onReleased: keys = ""

	function catchEscape() {
		if(about.opacity == 1)
			about.hideAbout()
		else if(settingsitem.opacity == 1)
			settingsitem.hideSettings()
	}

	function execute(cmd) {

//		if(cmd === "__stopThb")
		if(cmd === "__close")
			Qt.quit()
		if(cmd === "__hide")
			Qt.quit()
		if(cmd === "__settings")
			settingsitem.showSettings()
		if(cmd === "__next")
			thumbnailBar.nextImage()
		if(cmd === "__prev")
			thumbnailBar.previousImage()
//		if(cmd === "__reloadThb")
		if(cmd === "__about")
			about.showAbout()
//		if(cmd === "__slideshow")
//		if(cmd === "__filterImages")
//		if(cmd === "__slideshowQuick")
		if(cmd === "__open" || cmd === "__openOld") {
			openFile()
			keys = ""	// This is needed, as the KeyReleased event is not catched when the open dialog opens
		}
		if(cmd === "__zoomIn")
			image.zoomIn()
		if(cmd === "__zoomOut")
			image.zoomOut()
		if(cmd === "__zoomReset")
			image.resetZoom()
//		if(cmd === "__zoomActual")
		if(cmd === "__rotateL")
			image.rotateLeft()
		if(cmd === "__rotateR")
			image.rotateRight()
		if(cmd === "__rotate0")
			image.resetRotation()
		if(cmd === "__flipH")
			image.flipHorizontal()
		if(cmd === "__flipV")
			image.flipVertical()
//		if(cmd === "__rename")
//		if(cmd === "__delete")
//		if(cmd === "__copy")
//		if(cmd === "__move")
		if(cmd === "__hideMeta") {
			if(metaData.x < -40) {
				metaData.checkCheckbox()
				background.showMetadata()
			} else {
				metaData.uncheckCheckbox()
				background.hideMetadata()
			}
		}
//		if(cmd === "__showContext")
		if(cmd === "__gotoFirstThb")
			thumbnailBar.gotoFirstImage()
		if(cmd === "__gotoLastThb")
			thumbnailBar.gotoLastImage()

//		if(cmd === "__wallpaper")
//		if(cmd === "__scale")
	}

	function gotMouseShortcut(sh) {

		var shortcut = "[M] "
		if(keys != "") shortcut += getanddostuff.trim(keys.substr(0,keys.length-1)) + "+"
		shortcut += sh

		if(!blockedSystem && shortcut  in shortcutfile)
				execute(shortcutfile[shortcut][1]);

	}

}
