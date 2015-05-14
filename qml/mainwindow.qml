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

	// This is how much bigger than the thumbnails the thumbnail bar is (this is the space to the top)
	property int thumbnailbarheight_addon: 50

	// These signals is picked up by the mainwindow.cpp file
	signal thumbScrolled(var filenameAtCenter)
	signal openFile()
	signal loadMoreThumbnails();
	signal didntLoadThisThumbnail(var pos);
	signal imageLoaded(var path)
	signal hideToSystemTray();
	signal quitPhotoQt();
	signal reloadDirectory(var filename);

	// Interface blocked? System Shortcuts blocked?
	property bool blocked: false
	property bool blockedSystem: false
	property int softblocked: 0

	// Some colour settings
	property string colour_fadein_bg: "#DD000000"
	property string colour_fadein_block_bg: "#55000000"
	property string colour_fadein_border: "#55bbbbbb"
	property string colour_slidein_bg: "#BB000000"
	property string colour_slidein_border: "#55bbbbbb"
	property string colour_linecolour: "#99999999"

	// Detect some states (e.g. for slideshow)
	property bool slideshowRunning: false

	// When the slidein widgets are not visible, then they are moved away a safety distance,
	// otherwise they might be visible for a fraction of a second when resizing the windowChanged
	// (and also at startup)
	property int safetyDistanceForSlidein: 500

	// Access to the permanent settings file (~/.photoqt/settings)
	Settings { id: settings; }
	FileFormats { id: fileformats; }
	SettingsSession { id: settingssession; }

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

	SettingsItem { id: settingsitem; }


	// Adjust size of all the elements
	function resizeElements(w,h) {

		background.width = w
		background.height = h

		thumbnailBar.width = w
		thumbnailBar.y = h-(settings.thumbnailKeepVisible ? settings.thumbnailsize+thumbnailbarheight_addon : 0)

		image.width = w
		image.height = (settings.thumbnailKeepVisible ? h-thumbnailBar.height+thumbnailbarheight_addon/2 : h)

		metaData.x = -metaData.width-safetyDistanceForSlidein
		metaData.y = (h-metaData.height)/3

		mainmenu.x = w-mainmenu.width-100
		mainmenu.y = -mainmenu.height-safetyDistanceForSlidein

		quicksettings.x = w+safetyDistanceForSlidein
		quicksettings.y = (h-quicksettings.height)/3

		if(image.zoomSteps == 0) image.setSourceSize(w,h)

	}

	// Slots accessable by mainwindow.cpp, passed on to thumbnailbar
	function reloadImage(pos, smart) { thumbnailBar.reloadImage(pos, smart) }
	function setupModel(stringlist, pos) { thumbnailBar.setupModel(stringlist, pos) }
	function displayImage(pos) { thumbnailBar.displayImage(pos) }
	function nextImage() { thumbnailBar.nextImage(); }
	function previousImage() { thumbnailBar.previousImage(); }
	function getCenterPos() { console.log("center pos"); return thumbnailBar.getCenterPos(); }

	function detectedKeyCombo(combo) { sh.detectedKeyCombo(combo); settingsitem.detectedKeyCombo(combo); }
	function keysReleased(combo) { settingsitem.keysReleased(); sh.releasedKeys(combo); }
	function mouseWheelEvent(combo) { sh.gotMouseShortcut(combo); }
	function closeContextMenuWhenOpen() { softblocked = 0; contextmenu.hide(); }

	function alsoIgnoreSystemShortcuts(block) {
		blocked = block;
		blockedSystem = block;
	}

	Component.onCompleted: {
		quicksettings.setData()
	}

	// We can't emit the signal from the subcomponent (empty error message), so we go the detour with a function emitting the signal
	function doReload(path) {
		reloadDirectory(path)
	}

}
