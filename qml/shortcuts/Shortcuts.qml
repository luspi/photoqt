import QtQuick 2.3
import "mouseshortcuts.js" as Mouse
import "keyshortcuts.js" as Key

// The shortcuts engine with flexible mouse, key and touch shortcuts

Item {

	id: top

	// Get the current shortcuts
	property var keyshortcutfile: getanddostuff.getKeyShortcuts()
	property var mouseshortcutfile: getanddostuff.getMouseShortcuts()

	// This is a "trick" of sorts. The notifierChanged signal is triggered in getanddostuff.h
	// whenever the shortcuts files were modified, which in turns reloads the shortcuts files.
	property int keyNotifier: getanddostuff.keyShortcutNotifier
	property int mouseNotifier: getanddostuff.mouseShortcutNotifier
	onKeyNotifierChanged:
		keyshortcutfile = getanddostuff.getKeyShortcuts()
	onMouseNotifierChanged:
		mouseshortcutfile = getanddostuff.getMouseShortcuts()


	function gotFinishedMouseGesture(startPoint, endPoint, duration, button, gesture, wheelAngleDelta, modifiers) {
		Mouse.gotFinishedMouseGesture(startPoint, endPoint, duration, button, gesture, wheelAngleDelta, modifiers)
	}
	function gotUpdatedMouseGesture(button, gesture, modifiers) {
		Mouse.gotUpdatedMouseGesture(button, gesture, modifiers)
	}

	function updateKeyCombo(combo) { Key.updateKeyCombo(combo) }
	function finishedKeyCombo(combo) { Key.finishedKeyCombo(combo) }
	function simulateShortcut(keys) { Key.simulateShortcut(keys) }

	function checkForSystemShortcut(keys) {
		verboseMessage("Shortcuts::checkForSystemShortcut()", keys)
		if(keys === "Escape") {
			if(about.opacity == 1)
				about.hideAbout()
			else if(settingsmanager.opacity == 1)
				settingsmanager.hideSettings()
			else if(scaleImage.opacity == 1)
				scaleImage.hideScale()
			else if(scaleImageUnsupported.opacity == 1)
				scaleImageUnsupported.hideScaledUnsupported()
			else if(deleteImage.opacity == 1)
				deleteImage.hideDelete()
			else if(rename.opacity == 1)
				rename.hideRename()
			else if(wallpaper.opacity == 1)
				wallpaper.hideWallpaper()
			else if(slideshow.opacity == 1)
				slideshow.hideSlideshow()
			else if(filter.opacity == 1)
				filter.hideFilter()
			else if(startup.opacity == 1)
				startup.hideStartup()
			else if(openfile.opacity == 1)
				openfile.hide()
		} else if(keys === "Enter" || keys === "Keypad+Enter" || keys === "Return") {
			if(deleteImage.opacity == 1)
				deleteImage.simulateEnter()
			else if(rename.opacity == 1)
				rename.simulateEnter()
			else if(wallpaper.opacity == 1)
				wallpaper.simulateEnter()
			else if(slideshow.opacity == 1)
				slideshow.simulateEnter()
			else if(filter.opacity == 1)
				filter.simulateEnter()
		} else if(keys === "Space") {
			if(slideshowRunning) {
				slideshowbar.pauseSlideshow()
				if(!slideshowbar.paused) slideshowbar.hideBar()
			}
		} else if(keys === "Shift+Enter" || keys === "Shift+Return" || keys === "Shift+Keypad+Enter") {
			if(deleteImage.opacity == 1)
				deleteImage.simulateShiftEnter()
		} else if(!settingsmanager.wait_amDetectingANewShortcut && settingsmanager.opacity == 1) {
			if(keys === "Ctrl+Tab")
				settingsmanager.nextTab()
			else if(keys === "Ctrl+Shift+Tab")
				settingsmanager.prevTab()
			else if(keys === "Ctrl+S")
				settingsmanager.saveSettings()
			else if(keys === "Alt+1")
				settingsmanager.gotoTab(0)
			else if(keys === "Alt+2")
				settingsmanager.gotoTab(1)
			else if(keys === "Alt+3")
				settingsmanager.gotoTab(2)
			else if(keys === "Alt+4")
				settingsmanager.gotoTab(3)
			else if(keys === "Alt+5")
				settingsmanager.gotoTab(4)
		}

	}

	// Close is only defined for external shortcuts
	function execute(cmd, close, bymouse) {

		verboseMessage("Shortcuts::execute()", cmd + " - " + close)

		if(bymouse === undefined)
			bymouse = false;

		if(cmd === "__stopThb")
			stopThumbnails()
		if(cmd === "__close")
			quitPhotoQt()
		else if(cmd === "__hide") {
			if(settings.trayicon)
				hideToSystemTray()
			else
				quitPhotoQt()
		} else if(cmd === "__settings")
			settingsmanager.showSettings()
		else if(cmd === "__next")
			thumbnailBar.nextImage()
		else if(cmd === "__prev")
			thumbnailBar.previousImage()
		if(cmd === "__reloadThb")
			reloadThumbnails()
		else if(cmd === "__about")
			about.showAbout()
		else if(cmd === "__slideshow")
			slideshow.showSlideshow()
		else if(cmd === "__filterImages")
			filter.showFilter()
		else if(cmd === "__slideshowQuick")
			slideshow.quickstart()
		else if(cmd === "__open")
			openFile()
		else if(cmd === "__openOld")
			openFileOLD()
		else if(cmd === "__zoomIn")
			mainview.zoomIn(!bymouse)
		else if(cmd === "__zoomOut")
			mainview.zoomOut(!bymouse)
		else if(cmd === "__zoomReset")
			mainview.resetZoom()
		else if(cmd === "__zoomActual")
			mainview.zoomActual()
		else if(cmd === "__rotateL")
			mainview.rotateLeft()
		else if(cmd === "__rotateR")
			mainview.rotateRight()
		else if(cmd === "__rotate0")
			mainview.resetRotation()
		else if(cmd === "__flipH")
			mainview.mirrorHorizontal()
		else if(cmd === "__flipV")
			mainview.mirrorVertical()
		else if(cmd === "__rename")
			rename.showRename()
		else if(cmd === "__delete")
			deleteImage.showDelete()
		else if(cmd === "__deletePermanent")
			deleteImage.doDirectPermanentDelete()
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
		} else if(cmd === "__gotoFirstThb")
			thumbnailBar.gotoFirstImage()
		else if(cmd === "__gotoLastThb")
			thumbnailBar.gotoLastImage()

		else if(cmd === "__wallpaper")
			wallpaper.showWallpaper()
		else if(cmd === "__scale")
			scaleImage.showScale()
		else {
			getanddostuff.executeApp(cmd,thumbnailBar.currentFile)
			if(close !== undefined && close == true)
				if(settings.trayicon)
					hideToSystemTray()
				else
					quitPhotoQt()
		}

	}

	function gotTouchGesture(startPoint, endPoint, type, numFingers, duration, path) {

		console.log(startPoint, endPoint, type, numFingers, duration, path)

//		var dx = endPoint.x-startPoint.x
//		var dy = endPoint.y-startPoint.y

//		if(gesture.length === 1 && numFingers === 1) {
//			if(startPoint.x > background.width-100 && gesture[0] === "W") {
//				mainmenu.show()
//				return
//			} else if(startPoint.x < 100 && gesture[0] === "E") {
//				metaData.show()
//				return
//			} else if(startPoint.y > background.height-100 && gesture[0] === "N") {
//				thumbnailBar.show()
//				return
//			}
//		}

//		if(gesture.length === 1 && numFingers === 1 && duration < 300 && thumbnailBar.currentFile != "") {
//			if(gesture[0] === "E") {
//				nextImage()
//				return
//			} else if(gesture[0] === "W") {
//				previousImage()
//				return
//			}
//		}

//		if(gesture.length === 3 && numFingers === 1 && duration < 1500) {
//			if(gesture[0] === "S" && gesture[1] === "E" && gesture[2] === "S") {
//				quitPhotoQt()
//				return
//			}
//		}

//		if(gesture.length === 2 && numFingers === 1 && duration < 750) {
//			if(gesture[0] === "S" && gesture[1] === "N") {
//				openFile()
//				return
//			}
//		}

	}

}
