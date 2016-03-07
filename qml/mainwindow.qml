import QtQuick 2.3
import Settings 1.0
import FileFormats 1.0
import SettingsSession 1.0
import GetAndDoStuff 1.0
import GetMetaData 1.0
import ThumbnailManagement 1.0
import ToolTip 1.0
import ShortcutsNotifier 1.0
import Colour 1.0
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.0

import "mainview/"
import "slidein/"
import "fadein/"
import "settingsmanager/"
import "openfile/"

import "globalstrings/" as Strings

Item {

	id: toplevel

	width: (parent != null ? parent.width : 600)
	height: (parent != null ? parent.height : 400)

	// This is how much bigger than the thumbnails the thumbnail bar is (this is the space to the top)
	readonly property int thumbnailbarheight_addon: 50

	// These signals is picked up by the mainwindow.cpp file
	signal thumbScrolled(var filenameAtCenter)
	signal loadMoreThumbnails();
	signal didntLoadThisThumbnail(var pos);
	signal imageLoaded(var path)
	signal hideToSystemTray();
	signal quitPhotoQt();
	signal reloadDirectory(var filename, var filter);
	signal verboseMessage(var loc, var msg);
	signal setOverrideCursor();
	signal restoreOverrideCursor();

	// Interface blocked? System Shortcuts blocked?
	property bool blocked: false
	property bool blockedSystem: false
	property int softblocked: 0

	// Detect some states/properties (e.g. for slideshow)
	property bool slideshowRunning: false
	property string currentfilter: ""
	property int windowx: 0
	property int windowy: 0
	property int windowx_currentscreen: 0
	property int windowy_currentscreen: 0
	property point localcursorpos: Qt.point(0,0);
	property bool windowshown: true
	onWindowshownChanged: if(windowshown) background.reloadScreenshot()
	onWindowxChanged: if(windowshown) background.reloadScreenshot()

	// Element radius is the radius of "windows" (e.g., About or Quicksettings)
	// Item radius is the radius of smaller items (e.g., spinbox)
	readonly property int global_element_radius: 10
	readonly property int global_item_radius: 5

	// GLOBAL FONT SIZE SETTINGS
	// An attempt to use global variables for font-sizes failed
	// as this resulted in numerous mysterious and unexplainable
	// 'QFont::setPointSizeF: Point size <= 0 (0.000000), must be greater than 0'
	// that I have no idea where they came from...
	// SO, BECAUSE OF THIS
	// Use these font point sizes directly in the code:
	// tiles = 8
	// normal = 10
	// large = 13
	// header = 15
	// title = 18


	// When the slidein widgets are not visible, then they are moved away a safety distance,
	// otherwise they might be visible for a fraction of a second when resizing the windowChanged
	// (and also at startup)
	readonly property int safetyDistanceForSlidein: 500



	/////////////////////////////////////////////////
	// THE FOLLOWING ITEMS DO NOT HAVE A VISUAL    //
	// REPRESENTATION! THEY HAVE MERELY FUNCTIONAL //
	// PURPOSE                                     //
	/////////////////////////////////////////////////


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
		onUserPlacesUpdated: {
			openfile.reloadUserPlaces()
		}
	}
	GetMetaData { id: getmetadata; }
	ThumbnailManagement { id: thumbnailmanagement; }
	Shortcuts { id: sh; }
	ShortcutsNotifier { id: sh_notifier; }

	Strings.Keys { id: str_keys }
	Strings.Mouse { id: str_mouse }

	/////////////////////////////////////////////////


	//////////////////////////////////////////////////////
	// THE FOLLOWING ITEMS REPRESENT THE MAIN ELEMENTS  //
	// OF PHOTOQT THAT ARE ALWAYS NEEDED AND ARE ALWAYS //
	// VISIBLE (WELL KINDA)                             //
	//////////////////////////////////////////////////////

	// Application background
	Background { id: background; }

	////////////////////////////

	// The main displayed image
	MainView { id: mainview; }
	GaussianBlur {
		id: blur_mainview
		anchors.fill: mainview
		visible: opacity != 0
		opacity: 0
		samples: settings.blurIntensity*3
		Behavior on opacity { NumberAnimation { duration: 250 } }
		radius: settings.blurIntensity*4
		source: ShaderEffectSource {
			sourceItem: mainview
			// The small decrease in width prevents a narrow margin on the right with no blur (as it borders transparency)
			sourceRect: Qt.rect(0, 0, blur_mainview.width-settings.blurIntensity, blur_mainview.height)
		}
	}

	////////////////////////////

	// The quickinfo (position in folder, filename)
	QuickInfo { id: quickInfo; }

	////////////////////////////

	// The thumbnail bar at the bottom
	ThumbnailBar { id: thumbnailBar; }
	GaussianBlur {
		id: blur_thumbnailBar
		anchors.fill: thumbnailBar
		visible: opacity != 0 && thumbnailBar.y > 0 && thumbnailBar.y < parent.height
		opacity: 0
		samples: settings.blurIntensity*3
		Behavior on opacity { NumberAnimation { duration: 250 } }
		radius: settings.blurIntensity*4
		source: thumbnailBar
	}

	////////////////////////////


	GaussianBlur {
		id: blur_BELOW_mainmenu
		anchors.fill: mainmenu
		visible: opacity != 0
		opacity: 0
		samples: settings.blurIntensity*2
		radius: settings.blurIntensity*4
		Behavior on opacity { NumberAnimation { duration: 250 } }
		source: ShaderEffectSource {
			sourceItem: mainview
			// The small decrease in width prevents a narrow margin on the right with no blur (as it borders transparency)
			sourceRect: Qt.rect(mainmenu.x, 0, blur_BELOW_mainmenu.width-settings.blurIntensity, blur_BELOW_mainmenu.height)
		}
	}
	MainMenu { id: mainmenu; }
	GaussianBlur {
		id: blur_mainmenu
		anchors.fill: mainmenu
		visible: opacity != 0 && mainmenu.opacity == 1
		opacity: 0
		samples: settings.blurIntensity*2
		Behavior on opacity { NumberAnimation { duration: 250 } }
		radius: settings.blurIntensity*4
		source: mainmenu
	}

	////////////////////////////

	// MetaData of the image (using the C++ Exiv2 library)
	GaussianBlur {
		id: blur_BELOW_metadata
		anchors.fill: metaData
		visible: opacity != 0 && settingssession.value("metadatakeepopen")==="false"
		opacity: 0
		samples: settings.blurIntensity*2
		radius: settings.blurIntensity*4
		Behavior on opacity { NumberAnimation { duration: 250 } }
		source: ShaderEffectSource {
			sourceItem: mainview
			sourceRect: Qt.rect(0, 0, blur_BELOW_metadata.width, blur_BELOW_metadata.height)
		}
	}
	MetaData { id: metaData; }
	GaussianBlur {
		id: blur_metadata
		anchors.fill: metaData
		visible: opacity != 0 && metaData.opacity == 1
		opacity: 0
		samples: settings.blurIntensity*2
		Behavior on opacity { NumberAnimation { duration: 250 } }
		radius: settings.blurIntensity*4
		source: metaData
	}

	//////////////////////////////////////////////////////


	////////////////////////////////////////////
	// THESE ARE ALL THE WIDGETS THAT FADE IN //
	// THEY ARE ALWAYS IN THE FOREGROUND      //
	////////////////////////////////////////////

	About { id: about; }
	Wallpaper { id: wallpaper; }
	Scale { id: scaleImage; }
	Delete { id: deleteImage; }
	Rename { id: rename; }
	Slideshow { id: slideshow; }
	SlideshowBar { id: slideshowbar; }
	Filter { id: filter; }
	Startup { id: startup; }
	OpenFile { id: openfile; }
	SettingsManager { id: settingsmanager; }

	////////////////////////////////////////////

	//////////////////////////////////////////////
	// THE TOOLTIP HAS A SPECIAL ROLE: IT'S NOT //
	// DIRECTLY A VISUAL ITEM BUT RELAYS BACK   //
	// TO A QWIDGETS BASED QTOOLTIP
	//////////////////////////////////////////////

	ToolTip {
		id: globaltooltip;
		Component.onCompleted: {
			setBackgroundColor(colour.tooltip_bg)
			setTextColor(colour.tooltip_text)
		}
	}

	//////////////////////////////////////////////

	// We don't show them at startup right away, as that can lead to small graphical glitches
	// This way, we simply avoid that altogether
	Component.onCompleted:
		mainview.displayIdleAndNothingLoadedMessage()

	// Slots accessable by mainwindow.cpp, passed on to thumbnailbar
	function reloadImage(pos, smart) { thumbnailBar.reloadImage(pos, smart) }
	function setupModel(stringlist, pos) { thumbnailBar.setupModel(stringlist, pos) }
	function displayImage(pos) { thumbnailBar.displayImage(pos) }
	function nextImage() { thumbnailBar.nextImage(); }
	function previousImage() { thumbnailBar.previousImage(); }
	function getCenterPos() { return thumbnailBar.getCenterPos(); }
	function resetZoom() { mainview.resetZoom(); }
	function isZoomed() { return mainview.isZoomed(); }

	function detectedKeyCombo(combo) { sh.detectedKeyCombo(combo); settingsmanager.setCurrentKeyCombo(combo) }
	function keysReleased(combo) { settingsmanager.keysReleased(); sh.releasedKeys(combo); }
	function mouseWheelEvent(combo) { sh.gotMouseShortcut(combo); }

	function showStartup(type) { startup.showStartup(type); }

	function openFile() { openfile.show(); }
	function hideOpenFile() { openfile.hide(); }

	function getCursorPos() { return localcursorpos; }

	function noResultsFromFilter() {
		verboseMessage("MainWindow::noResultsFromFilter()","Displaying 'no results found' message")
		image.noFilterResultsFound()
		thumbnailBar.setupModel([],0)
		metaData.clear()
		quickInfo.updateQuickInfo(-1,0,"")
	}

	function alsoIgnoreSystemShortcuts(block) {
		verboseMessage("MainWindow::alsoIgnoreSystemShortcuts()","Setting interface and system shortcut block to '" + block + "'")
		blocked = block;
		blockedSystem = block;
	}

	// We can't emit the signal from the subcomponent (empty error message), so we go the detour with a function emitting the signal
	function doReload(path) {
		verboseMessage("MainWindow::doReload()","Reloading directory '" + path + "'")
		reloadDirectory(path,currentfilter)
	}

	// For blurring, we animate by using a NumberAnimation on opacity
	// Thus, besides updating the source, this is the only thing we need to adjust.
	function blurAllBackgroundElements() {

		blur_mainview.opacity = 1
		blur_metadata.opacity = 1
		blur_mainmenu.opacity = 1
		blur_thumbnailBar.opacity = 1

	}
	function unblurAllBackgroundElements() {

		blur_mainview.opacity = 0
		blur_metadata.opacity = 0
		blur_mainmenu.opacity = 0
		blur_thumbnailBar.opacity = 0

	}

	function blurForMainMenu() {
		blur_BELOW_mainmenu.opacity = 1
	}
	function blurForMetaData() {
		blur_BELOW_metadata.opacity = 1
	}

	function unblurForMainMenu() {
		blur_BELOW_mainmenu.opacity = 0
	}
	function unblurForMetaData() {
		blur_BELOW_metadata.opacity = 0
	}


}
