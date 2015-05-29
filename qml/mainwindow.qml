import QtQuick 2.3
import Settings 1.0
import FileFormats 1.0
import SettingsSession 1.0
import GetAndDoStuff 1.0
import GetMetaData 1.0
import ThumbnailManagement 1.0

import "mainview/"
import "slidein/"
import "fadein/"
import "settings/"

Item {

	id: toplevel

	width: (parent != null ? parent.width : 600)
	height: (parent != null ? parent.height : 400)

	// This is how much bigger than the thumbnails the thumbnail bar is (this is the space to the top)
	readonly property int thumbnailbarheight_addon: 50

	// These signals is picked up by the mainwindow.cpp file
	signal thumbScrolled(var filenameAtCenter)
	signal openFile()
	signal loadMoreThumbnails();
	signal didntLoadThisThumbnail(var pos);
	signal imageLoaded(var path)
	signal hideToSystemTray();
	signal quitPhotoQt();
	signal reloadDirectory(var filename, var filter);

	// Interface blocked? System Shortcuts blocked?
	property bool blocked: false
	property bool blockedSystem: false
	property int softblocked: 0

	// Detect some states/properties (e.g. for slideshow)
	property bool slideshowRunning: false
	property string currentfilter: ""
	property int windowx: 0
	property int windowy: 0
	property bool windowshown: true
	onWindowshownChanged: if(windowshown) background.reloadScreenshot()
	onWindowxChanged: if(windowshown) background.reloadScreenshot()

	// When the slidein widgets are not visible, then they are moved away a safety distance,
	// otherwise they might be visible for a fraction of a second when resizing the windowChanged
	// (and also at startup)
	readonly property int safetyDistanceForSlidein: 500

	// Access to the permanent settings file (~/.photoqt/settings)
	Settings {
		id: settings;
		onHidecounterChanged: quickInfo.updateQuickInfo(quickInfo._pos, thumbnailBar.totalNumberImages, thumbnailBar.currentFile)
		onHidefilenameChanged: quickInfo.updateQuickInfo(quickInfo._pos, thumbnailBar.totalNumberImages, thumbnailBar.currentFile)
		onHidefilepathshowfilenameChanged: quickInfo.updateQuickInfo(quickInfo._pos, thumbnailBar.totalNumberImages, thumbnailBar.currentFile)
		onHidexChanged: quickInfo.updateQuickInfo(quickInfo._pos, thumbnailBar.totalNumberImages, thumbnailBar.currentFile)
	}
	FileFormats { id: fileformats; }
	SettingsSession { id: settingssession; }

	Colour { id: colour; }
	GetAndDoStuff {
		id: getanddostuff;
		// The reloadDirectory signal is emitted by copy/move actions in getanddostuff.cpp
		// We can't emit the qml reload signal from here (empty error message?), so we go the detour with a function emitting the signal
		onReloadDirectory: {
			if(deleted)
				doReload(thumbnailBar.getNewFilenameAfterDeletion())
			else
				doReload(path)
		}
	}
	GetMetaData { id: getmetadata; }
	ThumbnailManagement { id: thumbnailmanagement; }

	Shortcuts { id: sh; }

	// Application background
	Background { id: background; }

	// The main displayed image
	Display { id: image; }

	// The thumbnail bar at the bottom
	ThumbnailBar { id: thumbnailBar; }

	// The quickinfo (position in folder, filename)
	QuickInfo { id: quickInfo; }

	ContextMenu { id: contextmenu; }

	MainMenu { id: mainmenu; }

	// MetaData of the image (using the C++ Exiv2 library)
	MetaData { id: metaData; }

	QuickSettings { id: quicksettings; }

	About { id: about; }
	Wallpaper { id: wallpaper; }
	Scale { id: scaleImage; }
	Delete { id: deleteImage; }
	Rename { id: rename; }
	Slideshow { id: slideshow; }
	SlideshowBar { id: slideshowbar; }
	Filter { id: filter; }
	Startup { id: startup; }

	SettingsItem { id: settingsitem; }

	// Slots accessable by mainwindow.cpp, passed on to thumbnailbar
	function reloadImage(pos, smart) { thumbnailBar.reloadImage(pos, smart) }
	function setupModel(stringlist, pos) { thumbnailBar.setupModel(stringlist, pos) }
	function displayImage(pos) { thumbnailBar.displayImage(pos) }
	function nextImage() { thumbnailBar.nextImage(); }
	function previousImage() { thumbnailBar.previousImage(); }
	function getCenterPos() { console.log("center pos"); return thumbnailBar.getCenterPos(); }
	function resetZoom() { image.resetZoom(); }

	function detectedKeyCombo(combo) { sh.detectedKeyCombo(combo); settingsitem.detectedKeyCombo(combo); }
	function keysReleased(combo) { settingsitem.keysReleased(); sh.releasedKeys(combo); }
	function mouseWheelEvent(combo) { sh.gotMouseShortcut(combo); }
	function closeContextMenuWhenOpen() { softblocked = 0; contextmenu.hide(); }

	function showStartup(type) { startup.showStartup(type); }

	function noResultsFromFilter() {
		image.noFilterResultsFound()
		thumbnailBar.setupModel([],0)
		metaData.clear()
		quickInfo.updateQuickInfo(-1,0,"")
	}

	function alsoIgnoreSystemShortcuts(block) {
		blocked = block;
		blockedSystem = block;
	}

	Component.onCompleted: {
		quicksettings.setData()
	}

	// We can't emit the signal from the subcomponent (empty error message), so we go the detour with a function emitting the signal
	function doReload(path) {
		reloadDirectory(path,currentfilter)
	}

}
