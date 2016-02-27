#ifndef SETTINGS_H
#define SETTINGS_H

#include <iostream>
#include <thread>
#include <QObject>
#include <QSettings>
#include <QDir>
#include <QFileSystemWatcher>
#include <QTimer>
#include <QTextStream>

// Convenience class to access and change permanent settings

class Settings : public QObject {

	Q_OBJECT

public:
	explicit Settings(QObject *parent = 0) : QObject(parent) {
		verbose = false;

		// Watch the settings file (this needs to come BEFORE readSettings() as there's a bug in it (see readSettings() function)
		watcher = new QFileSystemWatcher;
		setFilesToWatcher();
		connect(watcher, SIGNAL(fileChanged(QString)), this, SLOT(readSettings()));

		// Read settings initially
		readSettings();

		// When saving the settings, we don't want to write the settings file hundreds of time within a few milliseconds, but use a timer to save it once after all settings are set
		saveSettingsTimer = new QTimer;
		saveSettingsTimer->setInterval(400);
		saveSettingsTimer->setSingleShot(true);
		connect(saveSettingsTimer, SIGNAL(timeout()), this, SLOT(saveSettings()));


		/*#################################################################################################*/
		/*#################################################################################################*/

		/***************************************
		 * A PROPERTY CHANGE TRIGGERS THE TIME *
		 ***************************************/

		connect(this, SIGNAL(languageChanged(QString)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(myWidgetAnimatedChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(saveWindowGeometryChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(keepOnTopChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(compositeChanged(bool)), saveSettingsTimer, SLOT(start()));

		connect(this, SIGNAL(bgColorRedChanged(int)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(bgColorGreenChanged(int)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(bgColorBlueChanged(int)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(bgColorAlphaChanged(int)), saveSettingsTimer, SLOT(start()));

		connect(this, SIGNAL(backgroundImageScreenshotChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(backgroundImageUseChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(backgroundImagePathChanged(QString)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(backgroundImageScaleChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(backgroundImageScaleCropChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(backgroundImageStretchChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(backgroundImageCenterChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(backgroundImageTileChanged(bool)), saveSettingsTimer, SLOT(start()));

		connect(this, SIGNAL(trayiconChanged(int)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(transitionChanged(int)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(loopthroughfolderChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(menusensitivityChanged(int)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(closeongreyChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(borderAroundImgChanged(int)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(quickSettingsChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(sortbyChanged(QString)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(sortbyAscendingChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(mouseWheelSensitivityChanged(int)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(rememberRotationChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(rememberZoomChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(fitInWindowChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(interpolationNearestNeighbourThresholdChanged(int)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(interpolationNearestNeighbourUpscaleChanged(bool)), saveSettingsTimer, SLOT(start()));

		connect(this, SIGNAL(hidecounterChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(hidefilepathshowfilenameChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(hidefilenameChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(hidexChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(closeXsizeChanged(int)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(fancyXChanged(bool)), saveSettingsTimer, SLOT(start()));

		connect(this, SIGNAL(slideShowTimeChanged(int)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(slideShowMusicFileChanged(QString)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(slideShowShuffleChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(slideShowLoopChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(slideShowTransitionChanged(int)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(slideShowHideQuickinfoChanged(bool)), saveSettingsTimer, SLOT(start()));

		connect(this, SIGNAL(wallpaperAlignmentChanged(QString)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(wallpaperScaleChanged(QString)), saveSettingsTimer, SLOT(start()));

		connect(this, SIGNAL(thumbnailsizeChanged(int)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(thumbnailcacheChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(thbcachefileChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(thumbnailSpacingBetweenChanged(int)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(thumbnailLiftUpChanged(int)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(thumbnailKeepVisibleChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(thumbnailFontSizeChanged(int)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(thumbnailDynamicChanged(int)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(thumbnailCenterActiveChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(thumbnailpositionChanged(QString)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(thumbnailFilenameInsteadChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(thumbnailFilenameInsteadFontSizeChanged(int)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(thumbnailDisableChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(thumbnailWriteFilenameChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(thumbnailWriteResolutionChanged(bool)), saveSettingsTimer, SLOT(start()));

		connect(this, SIGNAL(windowmodeChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(windowDecorationChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(knownFileTypesQtExtrasChanged(QString)), saveSettingsTimer, SLOT(start()));

		connect(this, SIGNAL(exiffontsizeChanged(int)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(exifopacityChanged(int)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(exifenablemousetriggeringChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(exifrotationChanged(QString)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(exifgpsmapserviceChanged(QString)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(exiffilenameChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(exiffiletypeChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(exiffilesizeChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(exifdimensionsChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(exifmakeChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(exifmodelChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(exifsoftwareChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(exifphototakenChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(exifexposuretimeChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(exifflashChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(exifisoChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(exifscenetypeChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(exifflengthChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(exiffnumberChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(exiflightsourceChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(iptckeywordsChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(iptclocationChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(iptccopyrightChanged(bool)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(exifgpsChanged(bool)), saveSettingsTimer, SLOT(start()));

		connect(this, SIGNAL(openDefaultViewChanged(QString)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(openPreviewModeChanged(QString)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(openZoomLevelChanged(int)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(openUserPlacesWidthChanged(int)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(openFoldersWidthChanged(int)), saveSettingsTimer, SLOT(start()));

		connect(this, SIGNAL(exifMetadaWindowWidthChanged(int)), saveSettingsTimer, SLOT(start()));
		connect(this, SIGNAL(mainMenuWindowWidthChanged(int)), saveSettingsTimer, SLOT(start()));

	}

	// CLean-up
	~Settings() {
		delete watcher;
		delete saveSettingsTimer;
	}


	/*#################################################################################################*/
	/*#################################################################################################*/

	/************
	 * ELEMENTS *
	 ************/

	bool verbose;

	// The current version
	QString version;
	// The language selected and available languages
	QString language;
	// Possibility to en-/disable animated fade-in
	bool myWidgetAnimated;
	// Possibility to en-/disable save/restore of window geometry on quit
	bool saveWindowGeometry;
	// Keep PhotoQt on top of other windows?
	bool keepOnTop;
	// Is composite enabled?
	bool composite;

	// Set the background color
	int bgColorRed;
	int bgColorGreen;
	int bgColorBlue;
	int bgColorAlpha;

	// Background image in use?
	bool backgroundImageScreenshot;
	bool backgroundImageUse;
	QString backgroundImagePath;
	bool backgroundImageScale;
	bool backgroundImageScaleCrop;
	bool backgroundImageStretch;
	bool backgroundImageCenter;
	bool backgroundImageTile;

	// Hide to tray icon?
	int trayicon;
	// Smooth Transition for changing images
	int transition;
	// Loop through folder?
	bool loopthroughfolder;
	// Menu sensitivity
	int menusensitivity;
	// Close on click on background exits?
	bool closeongrey;
	// Border around big image
	int borderAroundImg;
	// Show Quick Settings on mouse movement
	bool quickSettings;
	// Sort images by
	QString sortby;
	bool sortbyAscending;
	// Mouse Wheel sensitivity
	int mouseWheelSensitivity;
	// Remember per session
	bool rememberRotation;
	bool rememberZoom;
	// If image is too small, zoom to fit in window
	bool fitInWindow;
	// 'Nearest Neighbour' interpolation size threshold
	int interpolationNearestNeighbourThreshold;
	// 'Nearest Neighbour' interpolation for upscaling
	bool interpolationNearestNeighbourUpscale;

	// Are quickinfos hidden?
	bool hidecounter;
	bool hidefilepathshowfilename;
	bool hidefilename;
	bool hidex;
	// Size/Look of closing "x"
	int closeXsize;
	bool fancyX;

	// Some settings of the slideshow
	int slideShowTime;
	int slideShowTransition;
	QString slideShowMusicFile;
	bool slideShowShuffle;
	bool slideShowLoop;
	bool slideShowHideQuickinfo;

	// Some wallpaper settings
	QString wallpaperAlignment;
	QString wallpaperScale;

	// The Size of the thumbnail squares
	int thumbnailsize;
	// Thumbnails at the bottom or top?
	QString thumbnailposition;
	// Enable thumbnail cache
	bool thumbnailcache;
	// Are files used for caching (use database if false)
	bool thbcachefile;
	// Border between thumbnails
	int thumbnailSpacingBetween;
	// Lift hovered/selected thumbnails by x pixels
	int thumbnailLiftUp;
	// Are the thumbnails fading out or always visible?
	bool thumbnailKeepVisible;
	// Enable dynamic thumbnail creation (1 = dynamic, 2 = smart)
	int thumbnailDynamic;
	// Always center on active thumbnails
	bool thumbnailCenterActive;
	// Don't load actual thumbnail but just display the filename
	bool thumbnailFilenameInstead;
	int thumbnailFilenameInsteadFontSize;
	// Thumbnails can be disabled altogether
	bool thumbnailDisable;
	bool thumbnailWriteFilename;
	bool thumbnailWriteResolution;
	int thumbnailFontSize;

	// Window Mode
	bool windowmode;
	// w/ or w/o decoration
	bool windowDecoration;
	// The currently known filetypes (only extra Qt filetypes)
	QString knownFileTypesQtExtras;

	// Some exif settings
	bool exifenablemousetriggering;
	QString exifrotation;
	QString exifgpsmapservice;
	int exiffontsize;
	int exifopacity;
	// Which Exif data is shown?
	bool exiffilename;
	bool exiffiletype;
	bool exiffilesize;
	bool exifdimensions;
	bool exifmake;
	bool exifmodel;
	bool exifsoftware;
	bool exifphototaken;
	bool exifexposuretime;
	bool exifflash;
	bool exifiso;
	bool exifscenetype;
	bool exifflength;
	bool exiffnumber;
	bool exiflightsource;
	bool iptckeywords;
	bool iptclocation;
	bool iptccopyright;
	bool exifgps;

	// 'Open File' settings
	QString openDefaultView;
	QString openPreviewMode;
	int openZoomLevel;
	int openUserPlacesWidth;
	int openFoldersWidth;

	// Settings not adjustable in settings but other places
	int exifMetadaWindowWidth;	// changed by dragging right rectangle edge
	int mainMenuWindowWidth;	// changed by dragging left rectangle edge


	/*#################################################################################################*/
	/*#################################################################################################*/

	/**********************
	 * Q_PROPERTY methods *
	 **********************/

	Q_PROPERTY(QString language MEMBER language NOTIFY languageChanged)
	Q_PROPERTY(bool myWidgetAnimated MEMBER myWidgetAnimated NOTIFY myWidgetAnimatedChanged)
	Q_PROPERTY(bool saveWindowGeometry MEMBER saveWindowGeometry NOTIFY saveWindowGeometryChanged)
	Q_PROPERTY(bool keepOnTop MEMBER keepOnTop NOTIFY keepOnTopChanged)
	Q_PROPERTY(bool composite MEMBER composite NOTIFY compositeChanged)

	Q_PROPERTY(int bgColorRed MEMBER bgColorRed NOTIFY bgColorRedChanged)
	Q_PROPERTY(int bgColorGreen MEMBER bgColorGreen NOTIFY bgColorGreenChanged)
	Q_PROPERTY(int bgColorBlue MEMBER bgColorBlue NOTIFY bgColorBlueChanged)
	Q_PROPERTY(int bgColorAlpha MEMBER bgColorAlpha NOTIFY bgColorAlphaChanged)

	Q_PROPERTY(bool backgroundImageScreenshot MEMBER backgroundImageScreenshot NOTIFY backgroundImageScreenshotChanged)
	Q_PROPERTY(bool backgroundImageUse MEMBER backgroundImageUse NOTIFY backgroundImageUseChanged)
	Q_PROPERTY(QString backgroundImagePath MEMBER backgroundImagePath NOTIFY backgroundImagePathChanged)
	Q_PROPERTY(bool backgroundImageScale MEMBER backgroundImageScale NOTIFY backgroundImageScaleChanged)
	Q_PROPERTY(bool backgroundImageScaleCrop MEMBER backgroundImageScaleCrop NOTIFY backgroundImageScaleCropChanged)
	Q_PROPERTY(bool backgroundImageStretch MEMBER backgroundImageStretch NOTIFY backgroundImageStretchChanged)
	Q_PROPERTY(bool backgroundImageCenter MEMBER backgroundImageCenter NOTIFY backgroundImageCenterChanged)
	Q_PROPERTY(bool backgroundImageTile MEMBER backgroundImageTile NOTIFY backgroundImageTileChanged)

	Q_PROPERTY(int trayicon MEMBER trayicon NOTIFY trayiconChanged)
	Q_PROPERTY(int transition MEMBER transition NOTIFY transitionChanged)
	Q_PROPERTY(bool loopthroughfolder MEMBER loopthroughfolder NOTIFY loopthroughfolderChanged)
	Q_PROPERTY(int menusensitivity MEMBER menusensitivity NOTIFY menusensitivityChanged)
	Q_PROPERTY(bool closeongrey MEMBER closeongrey NOTIFY closeongreyChanged)
	Q_PROPERTY(int borderAroundImg MEMBER borderAroundImg NOTIFY borderAroundImgChanged)
	Q_PROPERTY(bool quickSettings MEMBER quickSettings NOTIFY quickSettingsChanged)
	Q_PROPERTY(QString sortby MEMBER sortby NOTIFY sortbyChanged)
	Q_PROPERTY(bool sortbyAscending MEMBER sortbyAscending NOTIFY sortbyAscendingChanged)
	Q_PROPERTY(int mouseWheelSensitivity MEMBER mouseWheelSensitivity NOTIFY mouseWheelSensitivityChanged)
	Q_PROPERTY(bool rememberRotation MEMBER rememberRotation NOTIFY rememberRotationChanged)
	Q_PROPERTY(bool rememberZoom MEMBER rememberZoom NOTIFY rememberZoomChanged)
	Q_PROPERTY(bool fitInWindow MEMBER fitInWindow NOTIFY fitInWindowChanged)
	Q_PROPERTY(int interpolationNearestNeighbourThreshold MEMBER interpolationNearestNeighbourThreshold NOTIFY interpolationNearestNeighbourThresholdChanged)
	Q_PROPERTY(bool interpolationNearestNeighbourUpscale MEMBER interpolationNearestNeighbourUpscale NOTIFY interpolationNearestNeighbourUpscaleChanged)

	Q_PROPERTY(bool hidecounter MEMBER hidecounter NOTIFY hidecounterChanged)
	Q_PROPERTY(bool hidefilepathshowfilename MEMBER hidefilepathshowfilename NOTIFY hidefilepathshowfilenameChanged)
	Q_PROPERTY(bool hidefilename MEMBER hidefilename NOTIFY hidefilenameChanged)
	Q_PROPERTY(bool hidex MEMBER hidex NOTIFY hidexChanged)
	Q_PROPERTY(int closeXsize MEMBER closeXsize NOTIFY closeXsizeChanged)
	Q_PROPERTY(bool fancyX MEMBER fancyX NOTIFY fancyXChanged)

	Q_PROPERTY(int slideShowTime MEMBER slideShowTime NOTIFY slideShowTimeChanged)
	Q_PROPERTY(int slideShowTransition MEMBER slideShowTransition NOTIFY slideShowTransitionChanged)
	Q_PROPERTY(QString slideShowMusicFile MEMBER slideShowMusicFile NOTIFY slideShowMusicFileChanged)
	Q_PROPERTY(bool slideShowShuffle MEMBER slideShowShuffle NOTIFY slideShowShuffleChanged)
	Q_PROPERTY(bool slideShowLoop MEMBER slideShowLoop NOTIFY slideShowLoopChanged)
	Q_PROPERTY(bool slideShowHideQuickinfo MEMBER slideShowHideQuickinfo NOTIFY slideShowHideQuickinfoChanged)

	Q_PROPERTY(QString wallpaperAlignment MEMBER wallpaperAlignment NOTIFY wallpaperAlignmentChanged)
	Q_PROPERTY(QString wallpaperScale MEMBER wallpaperScale NOTIFY wallpaperScaleChanged)

	Q_PROPERTY(int thumbnailsize MEMBER thumbnailsize NOTIFY thumbnailsizeChanged)
	Q_PROPERTY(QString thumbnailposition MEMBER thumbnailposition NOTIFY thumbnailpositionChanged)
	Q_PROPERTY(bool thumbnailcache MEMBER thumbnailcache NOTIFY thumbnailcacheChanged)
	Q_PROPERTY(bool thbcachefile MEMBER thbcachefile NOTIFY thbcachefileChanged)
	Q_PROPERTY(int thumbnailSpacingBetween MEMBER thumbnailSpacingBetween NOTIFY thumbnailSpacingBetweenChanged)
	Q_PROPERTY(int thumbnailLiftUp MEMBER thumbnailLiftUp NOTIFY thumbnailLiftUpChanged)
	Q_PROPERTY(bool thumbnailKeepVisible MEMBER thumbnailKeepVisible NOTIFY thumbnailKeepVisibleChanged)
	Q_PROPERTY(int thumbnailDynamic MEMBER thumbnailDynamic NOTIFY thumbnailDynamicChanged)
	Q_PROPERTY(bool thumbnailCenterActive MEMBER thumbnailCenterActive NOTIFY thumbnailCenterActiveChanged)
	Q_PROPERTY(bool thumbnailFilenameInstead MEMBER thumbnailFilenameInstead NOTIFY thumbnailFilenameInsteadChanged)
	Q_PROPERTY(int thumbnailFilenameInsteadFontSize MEMBER thumbnailFilenameInsteadFontSize NOTIFY thumbnailFilenameInsteadFontSizeChanged)
	Q_PROPERTY(bool thumbnailDisable MEMBER thumbnailDisable NOTIFY thumbnailDisableChanged)
	Q_PROPERTY(bool thumbnailWriteFilename MEMBER thumbnailWriteFilename NOTIFY thumbnailWriteFilenameChanged)
	Q_PROPERTY(bool thumbnailWriteResolution MEMBER thumbnailWriteResolution NOTIFY thumbnailWriteResolutionChanged)
	Q_PROPERTY(int thumbnailFontSize MEMBER thumbnailFontSize NOTIFY thumbnailFontSizeChanged)

	Q_PROPERTY(bool windowmode MEMBER windowmode NOTIFY windowmodeChanged)
	Q_PROPERTY(bool windowDecoration MEMBER windowDecoration NOTIFY windowDecorationChanged)
	Q_PROPERTY(QString knownFileTypesQtExtras MEMBER knownFileTypesQtExtras NOTIFY knownFileTypesQtExtrasChanged)

	Q_PROPERTY(bool exifenablemousetriggering MEMBER exifenablemousetriggering NOTIFY exifenablemousetriggeringChanged)
	Q_PROPERTY(QString exifrotation MEMBER exifrotation NOTIFY exifrotationChanged)
	Q_PROPERTY(QString exifgpsmapservice MEMBER exifgpsmapservice NOTIFY exifgpsmapserviceChanged)
	Q_PROPERTY(int exiffontsize MEMBER exiffontsize NOTIFY exiffontsizeChanged)
	Q_PROPERTY(int exifopacity MEMBER exifopacity NOTIFY exifopacityChanged)
	Q_PROPERTY(bool exiffilename MEMBER exiffilename NOTIFY exiffilenameChanged)
	Q_PROPERTY(bool exiffiletype MEMBER exiffiletype NOTIFY exiffiletypeChanged)
	Q_PROPERTY(bool exiffilesize MEMBER exiffilesize NOTIFY exiffilesizeChanged)
	Q_PROPERTY(bool exifdimensions MEMBER exifdimensions NOTIFY exifdimensionsChanged)
	Q_PROPERTY(bool exifmake MEMBER exifmake NOTIFY exifmakeChanged)
	Q_PROPERTY(bool exifmodel MEMBER exifmodel NOTIFY exifmodelChanged)
	Q_PROPERTY(bool exifsoftware MEMBER exifsoftware NOTIFY exifsoftwareChanged)
	Q_PROPERTY(bool exifphototaken MEMBER exifphototaken NOTIFY exifphototakenChanged)
	Q_PROPERTY(bool exifexposuretime MEMBER exifexposuretime NOTIFY exifexposuretimeChanged)
	Q_PROPERTY(bool exifflash MEMBER exifflash NOTIFY exifflashChanged)
	Q_PROPERTY(bool exifiso MEMBER exifiso NOTIFY exifisoChanged)
	Q_PROPERTY(bool exifscenetype MEMBER exifscenetype NOTIFY exifscenetypeChanged)
	Q_PROPERTY(bool exifflength MEMBER exifflength NOTIFY exifflengthChanged)
	Q_PROPERTY(bool exiffnumber MEMBER exiffnumber NOTIFY exiffnumberChanged)
	Q_PROPERTY(bool exiflightsource MEMBER exiflightsource NOTIFY exiflightsourceChanged)
	Q_PROPERTY(bool iptckeywords MEMBER iptckeywords NOTIFY iptckeywordsChanged)
	Q_PROPERTY(bool iptclocation MEMBER iptclocation NOTIFY iptclocationChanged)
	Q_PROPERTY(bool iptccopyright MEMBER iptccopyright NOTIFY iptccopyrightChanged)
	Q_PROPERTY(bool exifgps MEMBER exifgps NOTIFY exifgpsChanged)

	Q_PROPERTY(QString openDefaultView MEMBER openDefaultView NOTIFY openDefaultViewChanged)
	Q_PROPERTY(QString openPreviewMode MEMBER openPreviewMode NOTIFY openPreviewModeChanged)
	Q_PROPERTY(int openZoomLevel MEMBER openZoomLevel NOTIFY openZoomLevelChanged)
	Q_PROPERTY(int openUserPlacesWidth MEMBER openUserPlacesWidth NOTIFY openUserPlacesWidthChanged)
	Q_PROPERTY(int openFoldersWidth MEMBER openFoldersWidth NOTIFY openFoldersWidthChanged)

	Q_PROPERTY(int exifMetadaWindowWidth MEMBER exifMetadaWindowWidth NOTIFY exifMetadaWindowWidthChanged)
	Q_PROPERTY(int mainMenuWindowWidth MEMBER mainMenuWindowWidth NOTIFY mainMenuWindowWidthChanged)


	/*#################################################################################################*/
	/*#################################################################################################*/

	// Set the default settings
	Q_INVOKABLE void setDefault() {

		version = QString::fromStdString(VERSION);

		knownFileTypesQtExtras = "";

		sortby = "name";
		sortbyAscending = true;

#ifdef Q_OS_WIN32
		windowmode = true;
		windowDecoration = false;
#else
		windowmode = false;
		windowDecoration = false;
#endif
		myWidgetAnimated = true;
		saveWindowGeometry = true;
		keepOnTop = false;

		language = "";
		bgColorRed = 0;
		bgColorGreen = 0;
		bgColorBlue = 0;
		bgColorAlpha = 190;

//#ifdef Q_OS_WIN32
//		backgroundImageScreenshot = (QtWin::isCompositionEnabled() ? false : true);
//#else
		backgroundImageScreenshot = false;
//#endif
		backgroundImageUse = false;
		backgroundImagePath = "";
		backgroundImageScale = true;
		backgroundImageScaleCrop = false;
		backgroundImageStretch = false;
		backgroundImageCenter = false;
		backgroundImageTile = false;

//#ifdef Q_OS_WIN32
//		composite = (QtWin::isCompositionEnabled() ? true : false);
//#else
		composite = true;
//#endif
		trayicon = 0;
		transition = 0;
		loopthroughfolder = true;
		menusensitivity = 4;
		closeongrey = false;
		borderAroundImg = 5;
		quickSettings = true;
		mouseWheelSensitivity = 1;
		rememberRotation = true;
		rememberZoom = true;
		fitInWindow= false;
		interpolationNearestNeighbourThreshold = 100;
		interpolationNearestNeighbourUpscale = false;

		hidecounter = false;
		hidefilepathshowfilename = true;
		hidefilename = false;
		hidex = false;

		closeXsize = 10;
		fancyX = false;

		thumbnailsize = 80;
		thumbnailposition = "Bottom";
		thumbnailcache = true;
		thbcachefile = false;
		thumbnailSpacingBetween = 0;
		thumbnailLiftUp = 6;
		thumbnailKeepVisible = false;
		thumbnailDynamic = 2;
		thumbnailCenterActive = false;
		thumbnailDisable = false;
		thumbnailWriteFilename = true;
		thumbnailWriteResolution = false;
		thumbnailFontSize = 7;

		thumbnailFilenameInstead = false;
		thumbnailFilenameInsteadFontSize = 8;

		slideShowTime = 5;
		slideShowTransition = 4;
		slideShowMusicFile = "";
		slideShowShuffle = false;
		slideShowLoop = true;
		slideShowHideQuickinfo = true;

		wallpaperAlignment = "center";
		wallpaperScale = "noscale";


		exifenablemousetriggering = true;
		exiffontsize = 8;
		exifopacity = 200;
		exiffilename = true;
		exiffiletype = true;
		exiffilesize = true;
		exifdimensions = true;
		exifmake = true;
		exifmodel = true;
		exifsoftware = true;
		exifphototaken = true;
		exifexposuretime = true;
		exifflash = true;
		exifiso = true;
		exifscenetype = true;
		exifflength = true;
		exiffnumber = true;
		exiflightsource = true;
		iptckeywords = true;
		iptclocation = true;
		iptccopyright = true;
		exifgps = true;
		exifrotation = "Always";
		exifgpsmapservice = "openstreetmap.org";

		openDefaultView = "list";
		openPreviewMode = "lq";
		openZoomLevel = 15;
		openUserPlacesWidth = 200;
		openFoldersWidth = 400;

		exifMetadaWindowWidth = 350;
		mainMenuWindowWidth = 350;

	}


	/*#################################################################################################*/
	/*#################################################################################################*/

public slots:

	void setFilesToWatcher() {
		if(!QFile(QDir::homePath() + "/.photoqt/settings").exists())
			QTimer::singleShot(250, this, SLOT(setFilesToWatcher()));
		else
			watcher->addPath(QDir::homePath() + "/.photoqt/settings");
	}

	// Save settings
	void saveSettings() {

		QFile file(QDir::homePath() + "/.photoqt/settings");

		if(!file.open(QIODevice::ReadWrite))

			std::cerr << "ERROR saving settings" << std::endl;

		else {

			if(verbose) std::cout << "Save Settings" << std::endl;

			file.close();
			file.remove();
			file.open(QIODevice::ReadWrite);

			QTextStream out(&file);

			QString cont = "Version=" + version + "\n";
			cont += QString("Language=%1\n").arg(language);
			cont += QString("WindowMode=%1\n").arg(int(windowmode));
			cont += QString("WindowDecoration=%1\n").arg(int(windowDecoration));
			cont += QString("MyWidgetAnimated=%1\n").arg(int(myWidgetAnimated));
			cont += QString("SaveWindowGeometry=%1\n").arg(int(saveWindowGeometry));
			cont += QString("KeepOnTop=%1\n").arg(int(keepOnTop));
			cont += QString("KnownFileTypesQtExtras=%1\n").arg(knownFileTypesQtExtras);

			cont += "\n[Look]\n";

			cont += QString("Composite=%1\n").arg(int(composite));
			cont += QString("BgColorRed=%1\n").arg(bgColorRed);
			cont += QString("BgColorGreen=%1\n").arg(bgColorGreen);
			cont += QString("BgColorBlue=%1\n").arg(bgColorBlue);
			cont += QString("BgColorAlpha=%1\n").arg(bgColorAlpha);
			cont += QString("BackgroundImageScreenshot=%1\n").arg(backgroundImageScreenshot);
			cont += QString("BackgroundImageUse=%1\n").arg(backgroundImageUse);
			cont += QString("BackgroundImagePath=%1\n").arg(backgroundImagePath);
			cont += QString("BackgroundImageScale=%1\n").arg(backgroundImageScale);
			cont += QString("BackgroundImageScaleCrop=%1\n").arg(backgroundImageScaleCrop);
			cont += QString("BackgroundImageStretch=%1\n").arg(backgroundImageStretch);
			cont += QString("BackgroundImageCenter=%1\n").arg(backgroundImageCenter);
			cont += QString("BackgroundImageTile=%1\n").arg(backgroundImageTile);

			cont += "\n[Behaviour]\n";

			cont += QString("TrayIcon=%1\n").arg(trayicon);
			cont += QString("Transition=%1\n").arg(transition);
			cont += QString("LoopThroughFolder=%1\n").arg(int(loopthroughfolder));
			cont += QString("MenuSensitivity=%1\n").arg(menusensitivity);
			cont += QString("CloseOnGrey=%1\n").arg(int(closeongrey));
			cont += QString("BorderAroundImg=%1\n").arg(borderAroundImg);
			cont += QString("QuickSettings=%1\n").arg(int(quickSettings));
			cont += QString("SortImagesBy=%1\n").arg(sortby);
			cont += QString("SortImagesAscending=%1\n").arg(int(sortbyAscending));
			cont += QString("MouseWheelSensitivity=%1\n").arg(mouseWheelSensitivity);
			cont += QString("RememberRotation=%1\n").arg(int(rememberRotation));
			cont += QString("RememberZoom=%1\n").arg(int(rememberZoom));
			cont += QString("FitInWindow=%1\n").arg(int(fitInWindow));
			cont += QString("InterpolationNearestNeighbourThreshold=%1\n").arg(interpolationNearestNeighbourThreshold);
			cont += QString("InterpolationNearestNeighbourUpscale=%1\n").arg(int(interpolationNearestNeighbourUpscale));

			cont += "\n[Quickinfo]\n";

			cont += QString("HideCounter=%1\n").arg(int(hidecounter));
			cont += QString("HideFilepathShowFilename=%1\n").arg(int(hidefilepathshowfilename));
			cont += QString("HideFilename=%1\n").arg(int(hidefilename));
			cont += QString("HideX=%1\n").arg(int(hidex));
			cont += QString("FancyX=%1\n").arg(int(fancyX));
			cont += QString("CloseXSize=%1\n").arg(closeXsize);

			cont += "\n[Thumbnail]\n";

			cont += QString("ThumbnailSize=%1\n").arg(thumbnailsize);
			cont += QString("ThumbnailPosition=%1\n").arg(thumbnailposition);
			cont += QString("ThumbnailCache=%1\n").arg(int(thumbnailcache));
			cont += QString("ThbCacheFile=%1\n").arg(int(thbcachefile));
			cont += QString("ThumbnailSpacingBetween=%1\n").arg(thumbnailSpacingBetween);
			cont += QString("ThumbnailLiftUp=%1\n").arg(thumbnailLiftUp);
			cont += QString("ThumbnailKeepVisible=%1\n").arg(thumbnailKeepVisible);
			cont += QString("ThumbnailDynamic=%1\n").arg(thumbnailDynamic);
			cont += QString("ThumbnailCenterActive=%1\n").arg(int(thumbnailCenterActive));
			cont += QString("ThumbnailFilenameInstead=%1\n").arg(int(thumbnailFilenameInstead));
			cont += QString("ThumbnailFilenameInsteadFontSize=%1\n").arg(thumbnailFilenameInsteadFontSize);
			cont += QString("ThumbnailDisable=%1\n").arg(int(thumbnailDisable));
			cont += QString("ThumbnailWriteFilename=%1\n").arg(int(thumbnailWriteFilename));
			cont += QString("ThumbnailWriteResolution=%1\n").arg(int(thumbnailWriteResolution));
			cont += QString("ThumbnailFontSize=%1\n").arg(thumbnailFontSize);

			cont += "\n[Slideshow]\n";

			cont += QString("SlideShowTime=%1\n").arg(slideShowTime);
			cont += QString("SlideShowTransition=%1\n").arg(slideShowTransition);
			cont += QString("SlideShowMusicFile=%1\n").arg(slideShowMusicFile);
			cont += QString("SlideShowShuffle=%1\n").arg(int(slideShowShuffle));
			cont += QString("SlideShowLoop=%1\n").arg(int(slideShowLoop));
			cont += QString("SlideShowHideQuickinfo=%1\n").arg(int(slideShowHideQuickinfo));

			cont += "\n[Wallpaper]\n";

			cont += QString("WallpaperAlignment=%1\n").arg(wallpaperAlignment);
			cont += QString("WallpaperScale=%1\n").arg((wallpaperScale));

			cont += "\n[Exif]\n";

			cont += QString("ExifEnableMouseTriggering=%1\n").arg(int(exifenablemousetriggering));
			cont += QString("ExifFontSize=%1\n").arg(exiffontsize);
			cont += QString("ExifOpacity=%1\n").arg(exifopacity);
			cont += QString("ExifFilename=%1\n").arg(int(exiffilename));
			cont += QString("ExifFiletype=%1\n").arg(int(exiffiletype));
			cont += QString("ExifFilesize=%1\n").arg(int(exiffilesize));
			cont += QString("ExifDimensions=%1\n").arg(int(exifdimensions));
			cont += QString("ExifMake=%1\n").arg(int(exifmake));
			cont += QString("ExifModel=%1\n").arg(int(exifmodel));
			cont += QString("ExifSoftware=%1\n").arg(int(exifsoftware));
			cont += QString("ExifPhotoTaken=%1\n").arg(int(exifphototaken));
			cont += QString("ExifExposureTime=%1\n").arg(int(exifexposuretime));
			cont += QString("ExifFlash=%1\n").arg(int(exifflash));
			cont += QString("ExifIso=%1\n").arg(int(exifiso));
			cont += QString("ExifSceneType=%1\n").arg(int(exifscenetype));
			cont += QString("ExifFLength=%1\n").arg(int(exifflength));
			cont += QString("ExifFNumber=%1\n").arg(int(exiffnumber));
			cont += QString("ExifLightSource=%1\n").arg(int(exiflightsource));
			cont += QString("ExifGps=%1\n").arg(int(exifgps));
			cont += QString("ExifRotation=%1\n").arg(exifrotation);
			cont += QString("ExifGPSMapService=%1\n").arg(exifgpsmapservice);

			cont += "\n[Iptc]\n";
			cont += QString("IptcKeywords=%1\n").arg(int(iptckeywords));
			cont += QString("IptcLocation=%1\n").arg(int(iptclocation));
			cont += QString("IptcCopyright=%1\n").arg(int(iptccopyright));

			cont += "\n[Open File]\n";
			cont += QString("OpenDefaultView=%1\n").arg(openDefaultView);
			cont += QString("OpenPreviewMode=%1\n").arg(openPreviewMode);
			cont += QString("OpenZoomLevel=%1\n").arg(openZoomLevel);
			cont += QString("OpenUserPlacesWidth=%1\n").arg(openUserPlacesWidth);
			cont += QString("OpenFoldersWidth=%1\n").arg(openFoldersWidth);

			cont += QString("ExifMetadaWindowWidth=%1\n").arg(exifMetadaWindowWidth);
			cont += QString("MainMenuWindowWidth=%1\n").arg(mainMenuWindowWidth);

			out << cont;
			file.close();

		}

	}

	/*#################################################################################################*/
	/*#################################################################################################*/

	// Read the current settings
	void readSettings() {

		// QFileSystemWatcher always thinks that a file was deleted, even if it was only modified.
		// Thus, we need to re-add it to its list of watched files. Since the file might not yet be completely written, we
		// check if the file exists and wait for that (needs C++11 features)
		setFilesToWatcher();

		// Set default values to start out with
		setDefault();

		QFile file(QDir::homePath() + "/.photoqt/settings");

		if(file.exists() && !file.open(QIODevice::ReadOnly))

			std::cerr << "ERROR reading settings:" << file.errorString().trimmed().toStdString() << std::endl;

		else if(file.exists() && file.isOpen()) {

			if(verbose) std::cerr << "Read Settings from File" << std::endl;

			// Read file
			QTextStream in(&file);
			QString all = in.readAll();

			if(all.contains("Language="))
				language = all.split("Language=").at(1).split("\n").at(0);

			if(all.contains("KnownFileTypesQtExtras="))
				knownFileTypesQtExtras = all.split("KnownFileTypesQtExtras=").at(1).split("\n").at(0);

			if(all.contains("SortImagesBy="))
				sortby = all.split("SortImagesBy=").at(1).split("\n").at(0);

			if(all.contains("SortImagesAscending=1"))
				sortbyAscending = true;
			else if(all.contains("SortImagesAscending=0"))
				sortbyAscending = false;

			if(all.contains("WindowMode=1"))
				windowmode = true;
			else if(all.contains("WindowMode=0"))
				windowmode = false;

			if(all.contains("WindowDecoration=1"))
				windowDecoration = true;
			else if(all.contains("WindowDecoration=0"))
				windowDecoration = false;

			if(all.contains("MyWidgetAnimated=1"))
				myWidgetAnimated = true;
			else if(all.contains("MyWidgetAnimated=0"))
				myWidgetAnimated = false;

			if(all.contains("SaveWindowGeometry=1"))
				saveWindowGeometry = true;
			else if(all.contains("SaveWindowGeometry=0"))
				saveWindowGeometry = false;

			if(all.contains("KeepOnTop=1"))
				keepOnTop = true;
			else if(all.contains("KeepOnTop=0"))
				keepOnTop = false;

			if(all.contains("Composite=1"))
				composite = true;
			else if(all.contains("Composite=0"))
				composite = false;


			if(all.contains("QuickSettings=1"))
				quickSettings = true;
			else if(all.contains("QuickSettings=0"))
				quickSettings = false;


			if(all.contains("BgColorRed="))
				bgColorRed = all.split("BgColorRed=").at(1).split("\n").at(0).toInt();
			if(all.contains("BgColorGreen="))
				bgColorGreen = all.split("BgColorGreen=").at(1).split("\n").at(0).toInt();
			if(all.contains("BgColorBlue="))
				bgColorBlue = all.split("BgColorBlue=").at(1).split("\n").at(0).toInt();
			if(all.contains("BgColorAlpha="))
				bgColorAlpha = all.split("BgColorAlpha=").at(1).split("\n").at(0).toInt();

			if(all.contains("BackgroundImageScreenshot="))
				backgroundImageScreenshot = bool(all.split("BackgroundImageScreenshot=").at(1).split("\n").at(0).toInt());

			if(all.contains("BackgroundImagePath="))
				backgroundImagePath = all.split("BackgroundImagePath=").at(1).split("\n").at(0);
			if(all.contains("BackgroundImageUse="))
				backgroundImageUse = bool(all.split("BackgroundImageUse=").at(1).split("\n").at(0).toInt());
			if(all.contains("BackgroundImageScale="))
				backgroundImageScale = bool(all.split("BackgroundImageScale=").at(1).split("\n").at(0).toInt());
			if(all.contains("BackgroundImageScaleCrop="))
				backgroundImageScaleCrop = bool(all.split("BackgroundImageScaleCrop=").at(1).split("\n").at(0).toInt());
			if(all.contains("BackgroundImageStretch="))
				backgroundImageStretch = bool(all.split("BackgroundImageStretch=").at(1).split("\n").at(0).toInt());
			if(all.contains("BackgroundImageCenter="))
				backgroundImageCenter = bool(all.split("BackgroundImageCenter=").at(1).split("\n").at(0).toInt());
			if(all.contains("BackgroundImageTile="))
				backgroundImageTile = bool(all.split("BackgroundImageTile=").at(1).split("\n").at(0).toInt());


			if(all.contains("TrayIcon="))
				trayicon = all.split("TrayIcon=").at(1).split("\n").at(0).toInt();

			if(all.contains("Transition="))
				transition = all.split("Transition=").at(1).split("\n").at(0).toInt();

			if(all.contains("LoopThroughFolder=1"))
				loopthroughfolder = true;
			else if(all.contains("LoopThroughFolder=0"))
				loopthroughfolder = false;

			if(all.contains("MenuSensitivity="))
				menusensitivity = all.split("MenuSensitivity=").at(1).split("\n").at(0).toInt();

			if(all.contains("CloseOnGrey=1"))
				closeongrey = true;
			else if(all.contains("CloseOnGrey=0"))
				closeongrey = false;

			if(all.contains("BorderAroundImg="))
				borderAroundImg = all.split("BorderAroundImg=").at(1).split("\n").at(0).toInt();

			if(all.contains("MouseWheelSensitivity=")) {
				mouseWheelSensitivity = all.split("MouseWheelSensitivity=").at(1).split("\n").at(0).toInt();
				if(mouseWheelSensitivity < 1) mouseWheelSensitivity = 1;
			}

			if(all.contains("RememberRotation=1"))
				rememberRotation = true;
			else if(all.contains("RememberRotation=0"))
				rememberRotation = false;

			if(all.contains("RememberZoom=1"))
				rememberZoom = true;
			else if(all.contains("RememberZoom=0"))
				rememberZoom = false;

			if(all.contains("FitInWindow=1"))
				fitInWindow = true;
			else if(all.contains("FitInWindow=0"))
				fitInWindow = false;

			if(all.contains("InterpolationNearestNeighbourThreshold="))
				interpolationNearestNeighbourThreshold = all.split("InterpolationNearestNeighbourThreshold=").at(1).split("\n").at(0).toInt();

			if(all.contains("InterpolationNearestNeighbourUpscale=1"))
				interpolationNearestNeighbourUpscale = true;
			else if(all.contains("InterpolationNearestNeighbourUpscale=0"))
				interpolationNearestNeighbourUpscale = false;

			if(all.contains("HideCounter=1"))
				hidecounter = true;
			else if(all.contains("HideCounter=0"))
				hidecounter = false;

			if(all.contains("HideFilepathShowFilename=1"))
				hidefilepathshowfilename = true;
			else if(all.contains("HideFilepathShowFilename=0"))
				hidefilepathshowfilename = false;

			if(all.contains("HideFilename=1"))
				hidefilename = true;
			else if(all.contains("HideFilename=0"))
				hidefilename = false;

			if(all.contains("HideX=1"))
				hidex = true;
			else if(all.contains("HideX=0"))
				hidex = false;

			if(all.contains("CloseXSize="))
				closeXsize = all.split("CloseXSize=").at(1).split("\n").at(0).toInt();

			if(all.contains(("FancyX=1")))
				fancyX = true;
			else if(all.contains("FancyX=0"))
				fancyX = false;

			if(all.contains("ThumbnailSize="))
				thumbnailsize = all.split("ThumbnailSize=").at(1).split("\n").at(0).toInt();

			if(all.contains("ThumbnailPosition="))
				thumbnailposition = all.split("ThumbnailPosition=").at(1).split("\n").at(0);

			if(all.contains("ThumbnailCache=1"))
				thumbnailcache = true;
			else if(all.contains("ThumbnailCache=0"))
				thumbnailcache = false;

			if(all.contains("ThbCacheFile=1"))
				thbcachefile = true;
			else if(all.contains("ThbCacheFile=0"))
				thbcachefile = false;

			if(all.contains("ThumbnailSpacingBetween="))
				thumbnailSpacingBetween = all.split("ThumbnailSpacingBetween=").at(1).split("\n").at(0).toInt();
			// That below is the old property
			else if(all.contains("ThumbnailBorderAround="))
				thumbnailSpacingBetween = all.split("ThumbnailBorderAround=").at(1).split("\n").at(0).toInt();

			if(all.contains("ThumbnailLiftUp="))
				thumbnailLiftUp = all.split("ThumbnailLiftUp=").at(1).split("\n").at(0).toInt();

			if(all.contains("ThumbnailKeepVisible=1"))
				thumbnailKeepVisible = true;
			else if(all.contains("ThumbnailKeepVisible=0"))
				thumbnailKeepVisible = false;

			if(all.contains("ThumbnailDynamic="))
				thumbnailDynamic = all.split("ThumbnailDynamic=").at(1).split("\n").at(0).toInt();

			if(all.contains("ThumbnailCenterActive=1"))
				thumbnailCenterActive = true;
			else if(all.contains("ThumbnailCenterActive=0"))
				thumbnailCenterActive = false;

			if(all.contains("ThumbnailFilenameInstead=1"))
				thumbnailFilenameInstead = true;
			else if(all.contains("ThumbnailFilenameInstead=0"))
				thumbnailFilenameInstead = false;

			if(all.contains("ThumbnailFilenameInsteadFontSize="))
				thumbnailFilenameInsteadFontSize = all.split("ThumbnailFilenameInsteadFontSize=").at(1).split("\n").at(0).toInt();

			if(all.contains("ThumbnailDisable=1"))
				thumbnailDisable = true;
			else if(all.contains("ThumbnailDisable=0"))
				thumbnailDisable = false;

			if(all.contains("ThumbnailWriteFilename=1"))
				thumbnailWriteFilename = true;
			else if(all.contains("ThumbnailWriteFilename=0"))
				thumbnailWriteFilename = false;

			if(all.contains("ThumbnailWriteResolution=1"))
				thumbnailWriteResolution = true;
			else if(all.contains("ThumbnailWriteResolution=0"))
				thumbnailWriteResolution = false;

			if(all.contains("ThumbnailFontSize="))
				thumbnailFontSize = all.split("ThumbnailFontSize=").at(1).split("\n").at(0).toInt();


			if(all.contains("SlideShowTime="))
				slideShowTime = all.split("SlideShowTime=").at(1).split("\n").at(0).toInt();

			if(all.contains("SlideShowTransition="))
				slideShowTransition = all.split("SlideShowTransition=").at(1).split("\n").at(0).toInt();

			if(all.contains("SlideShowMusicFile="))
				slideShowMusicFile = all.split("SlideShowMusicFile=").at(1).split("\n").at(0).trimmed();

			if(all.contains("SlideShowShuffle=1"))
				slideShowShuffle = true;
			else if(all.contains("SlideShowShuffle=0"))
				slideShowShuffle = false;

			if(all.contains("SlideShowLoop=1"))
				slideShowLoop = true;
			else if(all.contains("SlideShowLoop=0"))
				slideShowLoop = false;

			if(all.contains("SlideShowHideQuickinfo="))
				slideShowHideQuickinfo = bool(all.split("SlideShowHideQuickinfo=").at(1).split("\n").at(0).toInt());

			if(all.contains("WallpaperAlignment="))
				wallpaperAlignment =  all.split("WallpaperAlignment=").at(1).split("\n").at(0);
			if(all.contains("WallpaperScale="))
				wallpaperScale = all.split("WallpaperScale=").at(1).split("\n").at(0);


			if(all.contains("ExifEnableMouseTriggering=1"))
				exifenablemousetriggering = true;
			else if(all.contains("ExifEnableMouseTriggering=0"))
				exifenablemousetriggering = false;

			if(all.contains("ExifFontSize="))
				exiffontsize = all.split("ExifFontSize=").at(1).split("\n").at(0).toInt();

			if(all.contains("ExifOpacity="))
				exifopacity = all.split("ExifOpacity=").at(1).split("\n").at(0).toInt();

			if(all.contains("ExifFilename=1"))
				exiffilename = true;
			else if(all.contains("ExifFilename=0"))
				exiffilename = false;

			if(all.contains("ExifFiletype=1"))
				exiffiletype = true;
			else if(all.contains("ExifFiletype=0"))
				exiffiletype = false;

			if(all.contains("ExifFilesize=1"))
				exiffilesize = true;
			else if(all.contains("ExifFilesize=0"))
				exiffilesize = false;

			if(all.contains("ExifDimensions=1"))
				exifdimensions = true;
			else if(all.contains("ExifDimensions=0"))
				exifdimensions = false;

			if(all.contains("ExifMake=1"))
				exifmake = true;
			else if(all.contains("ExifMake=0"))
				exifmake = false;

			if(all.contains("ExifModel=1"))
				exifmodel = true;
			else if(all.contains("ExifModel=0"))
				exifmodel = false;

			if(all.contains("ExifSoftware=1"))
				exifsoftware = true;
			else if(all.contains("ExifSoftware=0"))
				exifsoftware = false;

			if(all.contains("ExifPhotoTaken=1"))
				exifphototaken = true;
			else if(all.contains("ExifPhotoTaken=0"))
				exifphototaken = false;

			if(all.contains("ExifExposureTime=1"))
				exifexposuretime = true;
			else if(all.contains("ExifExposureTime=0"))
				exifexposuretime = false;

			if(all.contains("ExifFlash=1"))
				exifflash = true;
			else if(all.contains("ExifFlash=0"))
				exifflash = false;

			if(all.contains("ExifIso=1"))
				exifiso = true;
			else if(all.contains("ExifIso=0"))
				exifiso = false;

			if(all.contains("ExifSceneType=1"))
				exifscenetype = true;
			else if(all.contains("ExifSceneType=0"))
				exifscenetype = false;

			if(all.contains("ExifFLength=1"))
				exifflength = true;
			else if(all.contains("ExifFLength=0"))
				exifflength = false;

			if(all.contains("ExifFNumber=1"))
				exiffnumber = true;
			else if(all.contains("ExifFNumber=0"))
				exiffnumber = false;

			if(all.contains("ExifLightSource=1"))
				exiflightsource = true;
			else if(all.contains("ExifLightSource=0"))
				exiflightsource = false;

			if(all.contains("ExifGps=1"))
				exifgps = true;
			else if(all.contains("ExifGps=0"))
				exifgps = false;

			if(all.contains("IptcKeywords=1"))
				iptckeywords = true;
			else if(all.contains("IptcKeywords=0"))
				iptckeywords = false;

			if(all.contains("IptcLocation=1"))
				iptclocation = true;
			else if(all.contains("IptcLocation=0"))
				iptclocation = false;

			if(all.contains("IptcCopyright=1"))
				iptccopyright = true;
			else if(all.contains("IptcCopyright=0"))
				iptccopyright = false;

			if(all.contains("ExifRotation="))
				exifrotation = all.split("ExifRotation=").at(1).split("\n").at(0);

			if(all.contains("ExifGPSMapService="))
				exifgpsmapservice = all.split("ExifGPSMapService=").at(1).split("\n").at(0);


			if(all.contains("OpenDefaultView=list"))
				openDefaultView = "list";
			else if(all.contains("OpenDefaultView=icons"))
				openDefaultView = "icons";

			if(all.contains("OpenPreviewMode=hq"))
				openPreviewMode = "hq";
			else if(all.contains("OpenPreviewMode=lq"))
				openPreviewMode = "lq";
			else if(all.contains("OpenPreviewMode=none"))
				openPreviewMode = "none";

			if(all.contains("OpenZoomLevel="))
				openZoomLevel = all.split("OpenZoomLevel=").at(1).split("\n").at(0).toInt();

			if(all.contains("OpenUserPlacesWidth="))
				openUserPlacesWidth = all.split("OpenUserPlacesWidth=").at(1).split("\n").at(0).toInt();

			if(all.contains("OpenFoldersWidth="))
				openFoldersWidth = all.split("OpenFoldersWidth=").at(1).split("\n").at(0).toInt();


			if(all.contains("ExifMetadaWindowWidth="))
				exifMetadaWindowWidth = all.split("ExifMetadaWindowWidth=").at(1).split("\n").at(0).toInt();

			if(all.contains("MainMenuWindowWidth="))
				mainMenuWindowWidth = all.split("MainMenuWindowWidth=").at(1).split("\n").at(0).toInt();


			file.close();

		}

	}

private:
	QFileSystemWatcher *watcher;
	QTimer *saveSettingsTimer;


	/*#################################################################################################*/
	/*#################################################################################################*/

signals:
	void languageChanged(QString val);
	void myWidgetAnimatedChanged(bool val);
	void saveWindowGeometryChanged(bool val);
	void keepOnTopChanged(bool val);
	void compositeChanged(bool val);

	void bgColorRedChanged(int val);
	void bgColorGreenChanged(int val);
	void bgColorBlueChanged(int val);
	void bgColorAlphaChanged(int val);

	void backgroundImageScreenshotChanged(bool val);
	void backgroundImageUseChanged(bool val);
	void backgroundImagePathChanged(QString val);
	void backgroundImageScaleChanged(bool val);
	void backgroundImageScaleCropChanged(bool val);
	void backgroundImageStretchChanged(bool val);
	void backgroundImageCenterChanged(bool val);
	void backgroundImageTileChanged(bool val);

	void trayiconChanged(int val);
	void transitionChanged(int val);
	void loopthroughfolderChanged(bool val);
	void menusensitivityChanged(int val);
	void closeongreyChanged(bool val);
	void borderAroundImgChanged(int val);
	void quickSettingsChanged(bool val);
	void sortbyChanged(QString val);
	void sortbyAscendingChanged(bool val);
	void mouseWheelSensitivityChanged(int val);
	void rememberRotationChanged(bool val);
	void rememberZoomChanged(bool val);
	void fitInWindowChanged(bool val);
	void interpolationNearestNeighbourThresholdChanged(int val);
	void interpolationNearestNeighbourUpscaleChanged(bool val);

	void hidecounterChanged(bool val);
	void hidefilepathshowfilenameChanged(bool val);
	void hidefilenameChanged(bool val);
	void hidexChanged(bool val);
	void closeXsizeChanged(int val);
	void fancyXChanged(bool val);

	void slideShowTimeChanged(int val);
	void slideShowMusicFileChanged(QString);
	void slideShowShuffleChanged(bool val);
	void slideShowLoopChanged(bool val);
	void slideShowTransitionChanged(int val);
	void slideShowHideQuickinfoChanged(bool val);

	void wallpaperAlignmentChanged(QString);
	void wallpaperScaleChanged(QString);

	void thumbnailsizeChanged(int val);
	void thumbnailcacheChanged(bool val);
	void thbcachefileChanged(bool val);
	void thumbnailSpacingBetweenChanged(int val);
	void thumbnailLiftUpChanged(int val);
	void thumbnailKeepVisibleChanged(bool val);
	void thumbnailFontSizeChanged(int val);
	void thumbnailDynamicChanged(int val);
	void thumbnailCenterActiveChanged(bool val);
	void thumbnailpositionChanged(QString val);
	void thumbnailFilenameInsteadChanged(bool val);
	void thumbnailFilenameInsteadFontSizeChanged(int val);
	void thumbnailDisableChanged(bool val);
	void thumbnailWriteFilenameChanged(bool val);
	void thumbnailWriteResolutionChanged(bool val);

	void windowmodeChanged(bool val);
	void windowDecorationChanged(bool val);
	void knownFileTypesQtExtrasChanged(QString val);

	void exiffontsizeChanged(int val);
	void exifopacityChanged(int val);
	void exifenablemousetriggeringChanged(bool val);
	void exifrotationChanged(QString val);
	void exifgpsmapserviceChanged(QString val);
	void exiffilenameChanged(bool val);
	void exiffiletypeChanged(bool val);
	void exiffilesizeChanged(bool val);
	void exifdimensionsChanged(bool val);
	void exifmakeChanged(bool val);
	void exifmodelChanged(bool val);
	void exifsoftwareChanged(bool val);
	void exifphototakenChanged(bool val);
	void exifexposuretimeChanged(bool val);
	void exifflashChanged(bool val);
	void exifisoChanged(bool val);
	void exifscenetypeChanged(bool val);
	void exifflengthChanged(bool val);
	void exiffnumberChanged(bool val);
	void exiflightsourceChanged(bool val);
	void iptckeywordsChanged(bool val);
	void iptclocationChanged(bool val);
	void iptccopyrightChanged(bool val);
	void exifgpsChanged(bool val);

	void openDefaultViewChanged(QString val);
	void openPreviewModeChanged(QString val);
	void openZoomLevelChanged(int val);
	void openUserPlacesWidthChanged(int val);
	void openFoldersWidthChanged(int val);

	void exifMetadaWindowWidthChanged(int val);
	void mainMenuWindowWidthChanged(int val);

};

#endif // SETTINGS_H
