import QtQuick 2.3
import QtQuick.Controls 1.2
import "../javascript/keydetect.js" as KeyDetect

Item {

	id: top

	property var shortcutfile: getanddostuff.getShortcuts()

	property string keys: ""

	// Connected via mainwindow to shortcuts.cpp file
	function detectedKeyCombo(combo) {
		if(!blockedSystem) {
			if(blocked)
				checkForSystemShortcut(combo)
			else if(combo in shortcutfile)
				execute(shortcutfile[combo][1]);
		}
		keys = combo
	}

	function releasedKeys() {
		keys = "";
	}

	function simulateShortcut(keys) {
		if(!blockedSystem) {
			if(blocked)
				checkForSystemShortcut(keys)
			else if(keys in shortcutfile)
				execute(shortcutfile[keys][1]);
		}
	}

	function checkForSystemShortcut(keys) {
		if(keys === "Escape") {
			if(about.opacity == 1)
				about.hideAbout()
			else if(settingsitem.opacity == 1) {
				settingsitem.hideSettings()
			}
		} else if(keys === "Ctrl+Tab" && settingsitem.opacity == 1)
			settingsitem.nextTab()
		else if((keys === "Ctrl+Shift+Tab") && settingsitem.opacity == 1)
			settingsitem.prevTab()

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
		if(cmd === "__open" || cmd === "__openOld")
			openFile()
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

		if(blocked) return

		// Sometimes there's a "leftover" key combo (in particular when 'open file' shortcut was triggered) - here we filter it out
		var mods = ["Ctrl","Alt","Shift"]
		var gotmod = (keys != "" ? true : false)
		var k = keys.split("+")
		for(var i = 0; i < k.length; ++i)
			if(k[i] !== "" && mods.indexOf(k[i]) == -1)
				gotmod = false

		var shortcut = "[M] "
		if(gotmod) shortcut += getanddostuff.trim(keys.substr(0,keys.length-1)) + "+"
		shortcut += sh

		if(!blockedSystem && shortcut  in shortcutfile)
				execute(shortcutfile[shortcut][1]);

	}

}
