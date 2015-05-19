import QtQuick 2.3
import QtQuick.Controls 1.2
import "../javascript/keydetect.js" as KeyDetect

Item {

	// softBlocked = 1 -> context menu (and there like opened)
	// softBlocked = 2 -> context menu closed (still ignore shortcuts)

	id: top

	property var shortcutfile: getanddostuff.getShortcuts()

	property string keys: ""

	// Connected via mainwindow to shortcuts.cpp file
	function detectedKeyCombo(combo) {
		if(softblocked != 0 && combo === "Escape") {
			if(slideshowRunning)
				slideshowbar.stopSlideshow()
			else {
				softblocked = 0
				if(contextmenu.visible) contextmenu.hide()
			}
		} else if(softblocked != 0 && !slideshowRunning)
			return
		else if(!blockedSystem) {
			if(blocked)
				checkForSystemShortcut(combo)
			else if(combo in shortcutfile)
				execute(shortcutfile[combo][1],shortcutfile[combo][0]);
		}
		keys = combo
	}

	function releasedKeys(combo) {
		if(softblocked != 0 && combo === "Escape") {
			softblocked = 0
			if(contextmenu.visible)
				contextmenu.hide()
		}
		keys = "";
	}

	function simulateShortcut(keys) {
		if(softblocked != 0 && combo === "Escape")
			softblocked = 0
		else if(softblocked != 0)
			return
		else if(!blockedSystem) {
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
			else if(settingsitem.opacity == 1)
				settingsitem.hideSettings()
			else if(scaleImage.opacity == 1)
				scaleImage.hideScale()
			else if(deleteImage.opacity == 1)
				deleteImage.hideDelete()
			else if(rename.opacity == 1)
				rename.hideRename()
			else if(wallpaper.opacity == 1)
				wallpaper.hideWallpaper()
			else if(slideshow.opacity == 1)
				slideshow.hideSlideshow()
		} else if(keys === "Enter" || keys === "Keypad+Enter" || keys === "Return") {
			if(deleteImage.opacity == 1)
				deleteImage.simulateEnter()
			else if(rename.opacity == 1)
				rename.simulateEnter()
			else if(wallpaper.opacity == 1)
				wallpaper.simulateEnter()
			else if(slideshow.opacity == 1)
				slideshow.simulateEnter()
		} else if(keys === "Space") {
			if(slideshowRunning) {
				slideshowbar.pauseSlideshow()
				if(!slideshowbar.paused) slideshowbar.hideBar()
			}
		} else if(keys === "Shift+Enter" || keys === "Shift+Return" || keys === "Shift+Keypad+Enter") {
			if(deleteImage.opacity == 1)
				deleteImage.simulateShiftEnter()
		} else if(keys === "Ctrl+Tab" && settingsitem.opacity == 1)
			settingsitem.nextTab()
		else if((keys === "Ctrl+Shift+Tab") && settingsitem.opacity == 1)
			settingsitem.prevTab()
		else if(keys === "Ctrl+S")
			settingsitem.saveSettings()

	}

	// Close is only defined for external shortcuts
	function execute(cmd, close) {

//		if(cmd === "__stopThb")
		if(cmd === "__close")
			quitPhotoQt()
		else if(cmd === "__hide") {
			if(settings.trayicon)
				hideToSystemTray()
			else
				quitPhotoQt()
		} else if(cmd === "__settings")
			settingsitem.showSettings()
		else if(cmd === "__next")
			thumbnailBar.nextImage()
		else if(cmd === "__prev")
			thumbnailBar.previousImage()
//		if(cmd === "__reloadThb")
		else if(cmd === "__about")
			about.showAbout()
		else if(cmd === "__slideshow")
			slideshow.showSlideshow()
//		if(cmd === "__filterImages")
//		if(cmd === "__slideshowQuick")
		else if(cmd === "__open" || cmd === "__openOld")
			openFile()
		else if(cmd === "__zoomIn")
			image.zoomIn()
		else if(cmd === "__zoomOut")
			image.zoomOut()
		else if(cmd === "__zoomReset")
			image.resetZoom()
		else if(cmd === "__zoomActual")
			image.zoomActual()
		else if(cmd === "__rotateL")
			image.rotateLeft()
		else if(cmd === "__rotateR")
			image.rotateRight()
		else if(cmd === "__rotate0")
			image.resetRotation()
		else if(cmd === "__flipH")
			image.flipHorizontal()
		else if(cmd === "__flipV")
			image.flipVertical()
		else if(cmd === "__rename")
			rename.showRename()
		else if(cmd === "__delete")
			deleteImage.showDelete()
		else if(cmd === "__copy")
			getanddostuff.copyImage(thumbnailBar.currentFile)
		else if(cmd === "__move")
			getanddostuff.moveImage(thumbnailBar.currentFile)
		else if(cmd === "__hideMeta") {
			if(metaData.x < -40) {
				metaData.checkCheckbox()
				background.showMetadata()
			} else {
				metaData.uncheckCheckbox()
				background.hideMetadata()
			}
		} else if(cmd === "__showContext")
			contextmenu.popup(getanddostuff.getCursorPos())
		else if(cmd === "__gotoFirstThb")
			thumbnailBar.gotoFirstImage()
		else if(cmd === "__gotoLastThb")
			thumbnailBar.gotoLastImage()

		else if(cmd === "__wallpaper")
			wallpaper.showWallpaper()
		else if(cmd === "__scale")
			scaleImage.showScale()
		else {
			getanddostuff.executeApp(cmd,thumbnailBar.currentFile)
			console.log("external:",close)
			if(close !== undefined && close == true)
				if(settings.trayicon)
					hideToSystemTray()
				else
					quitPhotoQt()
		}

	}

	function gotMouseShortcut(sh) {

		// Ignore Wheel events when, e.g., a context menu is open
		if(softblocked != 0 && sh !== "Right Button" && sh !== "Left Button")
			return

		if((sh === "Right Button" || sh === "Left Button") && contextmenu.visible) {
			var pos = getanddostuff.getCursorPos()
			if(contextmenu.x < pos.x && contextmenu.x+contextmenu.width > pos.x
					&& contextmenu.y < pos.y && contextmenu.y+contextmenu.height > pos.y) return
			softblocked = 0
			contextmenu.hide()
			return
		}

		// This means, e.g., a context menu is open and the user clicked somewhere else (closes context menu, doesn't do anything else)
		if(softblocked == 1) {
			softblocked = 2
			return
		}
		if(softblocked == 2) {
			softblocked = 0
			return
		}

		if(blocked) return

		// We need to ignore mouseclicks on slidein widgets like mainmenu, etc.
		var cursorpos = getanddostuff.getCursorPos()

		// Check for mainmenu
		if(mainmenu.x < cursorpos.x && (mainmenu.x+mainmenu.width) > cursorpos.x && (mainmenu.y+mainmenu.height) > cursorpos.y) return
		// Check for thumbnailbar
		if(thumbnailBar.y < cursorpos.y) return
		// Check for image data
		if((metaData.x+metaData.width) > cursorpos.x && metaData.y < cursorpos.y && (metaData.y+metaData.height) > cursorpos.y) return
		// Check for quickinfo
		if(quickInfo.x < cursorpos.x && (quickInfo.x+quickInfo.getWidth()) > cursorpos.x
				&& quickInfo.y < cursorpos.y && (quickInfo.y+quickInfo.getHeight()) > cursorpos.y) return
		if(image.getClosingX_x() < cursorpos.x && image.getClosingX_height() > cursorpos.y) return
		// Check for quicksettings
		if(quicksettings.x < cursorpos.x && quicksettings.y < cursorpos.y && (quicksettings.y+quicksettings.height) > cursorpos.y) return

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
