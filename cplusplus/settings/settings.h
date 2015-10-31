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
		watcher->addPath(QDir::homePath() + "/.photoqt/settings");
		connect(watcher, SIGNAL(fileChanged(QString)), this, SLOT(readSettings()));

		// Read settings initially
		readSettings();

		// When saving the settings, we don't want to write the settings file hundreds of time within a few milliseconds, but use a timer to save it once after all settings are set
		saveSettingsTimer = new QTimer;
		saveSettingsTimer->setInterval(400);
		saveSettingsTimer->setSingleShot(true);
		connect(saveSettingsTimer, SIGNAL(timeout()), this, SLOT(saveSettings()));

	}

	// CLean-up
	~Settings() {
		delete watcher;
		delete saveSettingsTimer;
	}


	/*#################################################################################################*/
	/*#################################################################################################*/

	/***************
	 * ELEMENTS *
	 ***************/

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


	/*#################################################################################################*/
	/*#################################################################################################*/

	/***************
	 * GET methods *
	 ***************/

	QString getLanguage() { return language; }
	bool getMyWidgetAnimated() { return myWidgetAnimated; }
	bool getSaveWindowGeometry() { return saveWindowGeometry; }
	bool getKeepOnTop() { return keepOnTop; }
	bool getComposite() { return composite; }

	int getBgColorRed() { return bgColorRed; }
	int getBgColorGreen() { return bgColorGreen; }
	int getBgColorBlue() { return bgColorBlue; }
	int getBgColorAlpha() { return bgColorAlpha; }

	bool getBackgroundImageScreenshot() { return backgroundImageScreenshot; }
	bool getBackgroundImageUse() { return backgroundImageUse; }
	QString getBackgroundImagePath() { return backgroundImagePath; }
	bool getBackgroundImageScale() { return backgroundImageScale; }
	bool getBackgroundImageScaleCrop() { return backgroundImageScaleCrop; }
	bool getBackgroundImageStretch() { return backgroundImageStretch; }
	bool getBackgroundImageCenter() { return backgroundImageCenter; }
	bool getBackgroundImageTile() { return backgroundImageTile; }

	int getTrayicon() { return trayicon; }
	int getTransition() { return transition; }
	bool getLoopthroughfolder() { return loopthroughfolder; }
	int getMenusensitivity() { return menusensitivity; }
	bool getCloseongrey() { return closeongrey; }
	int getBorderAroundImg() { return borderAroundImg; }
	bool getQuickSettings() { return quickSettings; }
	QString getSortby() { return sortby; }
	bool getSortbyAscending() { return sortbyAscending; }
	int getMouseWheelSensitivity() { return mouseWheelSensitivity; }
	bool getRememberRotation() { return rememberRotation; }
	bool getRememberZoom() { return rememberZoom; }
	bool getFitInWindow() { return fitInWindow; }
	int getInterpolationNearestNeighbourThreshold() { return interpolationNearestNeighbourThreshold; }
	bool getInterpolationNearestNeighbourUpscale() { return interpolationNearestNeighbourUpscale; }

	bool getHidecounter() { return hidecounter; }
	bool getHidefilepathshowfilename() { return hidefilepathshowfilename; }
	bool getHidefilename() { return hidefilename; }
	bool getHidex() { return hidex; }
	int getCloseXsize() { return closeXsize; }
	bool getFancyX() { return fancyX; }

	int getSlideShowTime() { return slideShowTime; }
	int getSlideShowTransition() { return slideShowTransition; }
	QString getSlideShowMusicFile() { return slideShowMusicFile; }
	bool getSlideShowShuffle() { return slideShowShuffle; }
	bool getSlideShowLoop() { return slideShowLoop; }
	bool getSlideShowHideQuickinfo() { return slideShowHideQuickinfo; }

	QString getWallpaperAlignment() { return wallpaperAlignment; }
	QString getWallpaperScale() { return wallpaperScale; }

	int getThumbnailsize() { return thumbnailsize; }
	QString getThumbnailposition() { return thumbnailposition; }
	bool getThumbnailcache() { return thumbnailcache; }
	bool getThbcachefile() { return thbcachefile; }
	int getThumbnailSpacingBetween() { return thumbnailSpacingBetween; }
	int getThumbnailLiftUp() { return thumbnailLiftUp; }
	bool getThumbnailKeepVisible() { return thumbnailKeepVisible; }
	int getThumbnailDynamic() { return thumbnailDynamic; }
	bool getThumbnailCenterActive() { return thumbnailCenterActive; }
	bool getThumbnailFilenameInstead() { return thumbnailFilenameInstead; }
	int getThumbnailFilenameInsteadFontSize() { return thumbnailFilenameInsteadFontSize; }
	bool getThumbnailDisable() { return thumbnailDisable; }
	bool getThumbnailWriteFilename() { return thumbnailWriteFilename; }
	bool getThumbnailWriteResolution() { return thumbnailWriteResolution; }
	int getThumbnailFontSize() { return thumbnailFontSize; }

	bool getWindowmode() { return windowmode; }
	bool getWindowDecoration() { return windowDecoration; }
	QString getKnownFileTypesQtExtras() { return knownFileTypesQtExtras; }

	bool getExifenablemousetriggering() { return exifenablemousetriggering; }
	QString getExifrotation() { return exifrotation; }
	QString getExifgpsmapservice() { return exifgpsmapservice; }
	int getExiffontsize() { return exiffontsize; }
	bool getExiffilename() { return exiffilename; }
	bool getExiffiletype() { return exiffiletype; }
	bool getExiffilesize() { return exiffilesize; }
	bool getExifdimensions() { return exifdimensions; }
	bool getExifmake() { return exifmake; }
	bool getExifmodel() { return exifmodel; }
	bool getExifsoftware() { return exifsoftware; }
	bool getExifphototaken() { return exifphototaken; }
	bool getExifexposuretime() { return exifexposuretime; }
	bool getExifflash() { return exifflash; }
	bool getExifiso() { return exifiso; }
	bool getExifscenetype() { return exifscenetype; }
	bool getExifflength() { return exifflength; }
	bool getExiffnumber() { return exiffnumber; }
	bool getExiflightsource() { return exiflightsource; }
	bool getIptckeywords() { return iptckeywords; }
	bool getIptclocation() { return iptclocation; }
	bool getIptccopyright() { return iptccopyright; }
	bool getExifgps() { return exifgps; }


	/*#################################################################################################*/
	/*#################################################################################################*/

	/***************
	 * SET methods *
	 ***************/

	void setLanguage(QString val) { language = val; saveSettingsTimer->start(); }
	void setMyWidgetAnimated(bool val) { myWidgetAnimated = val; saveSettingsTimer->start(); }
	void setSaveWindowGeometry(bool val) { saveWindowGeometry = val; saveSettingsTimer->start(); }
	void setKeepOnTop(bool val) { keepOnTop = val; saveSettingsTimer->start(); }
	void setComposite(bool val) { composite = val; saveSettingsTimer->start(); }

	void setBgColorRed(int val) { bgColorRed = val; saveSettingsTimer->start(); }
	void setBgColorGreen(int val) { bgColorGreen = val; saveSettingsTimer->start(); }
	void setBgColorBlue(int val) { bgColorBlue = val; saveSettingsTimer->start(); }
	void setBgColorAlpha(int val) { bgColorAlpha = val; saveSettingsTimer->start(); }

	void setBackgroundImageScreenshot(bool val) { backgroundImageScreenshot = val; saveSettingsTimer->start(); }
	void setBackgroundImageUse(bool val) { backgroundImageUse = val; saveSettingsTimer->start(); }
	void setBackgroundImagePath(QString val) { backgroundImagePath = val; saveSettingsTimer->start(); }
	void setBackgroundImageScale(bool val) { backgroundImageScale = val; saveSettingsTimer->start(); }
	void setBackgroundImageScaleCrop(bool val) { backgroundImageScaleCrop = val; saveSettingsTimer->start(); }
	void setBackgroundImageStretch(bool val) { backgroundImageStretch = val; saveSettingsTimer->start(); }
	void setBackgroundImageCenter(bool val) { backgroundImageCenter = val; saveSettingsTimer->start(); }
	void setBackgroundImageTile(bool val) { backgroundImageTile = val; saveSettingsTimer->start(); }

	void setTrayicon(int val) { trayicon = val; saveSettingsTimer->start(); }
	void setTransition(int val) { transition = val; saveSettingsTimer->start(); }
	void setLoopthroughfolder(bool val) { loopthroughfolder = val; saveSettingsTimer->start(); }
	void setMenusensitivity(int val) { menusensitivity = val; saveSettingsTimer->start(); }
	void setCloseongrey(bool val) { closeongrey = val; saveSettingsTimer->start(); }
	void setBorderAroundImg(int val) { borderAroundImg = val; saveSettingsTimer->start(); }
	void setQuickSettings(bool val) { quickSettings = val; saveSettingsTimer->start(); }
	void setSortby(QString val) { sortby = val; saveSettingsTimer->start(); }
	void setSortbyAscending(bool val) { sortbyAscending = val; saveSettingsTimer->start(); }
	void setMouseWheelSensitivity(int val) { mouseWheelSensitivity = val; saveSettingsTimer->start(); }
	void setRememberRotation(bool val) { rememberRotation = val; saveSettingsTimer->start(); }
	void setRememberZoom(bool val) { rememberZoom = val; saveSettingsTimer->start(); }
	void setFitInWindow(bool val) { fitInWindow = val; saveSettingsTimer->start(); }
	void setInterpolationNearestNeighbourThreshold(int val) { interpolationNearestNeighbourThreshold = val; saveSettingsTimer->start(); }
	void setInterpolationNearestNeighbourUpscale(bool val) { interpolationNearestNeighbourUpscale = val; saveSettingsTimer->start(); }

	void setHidecounter(bool val) { hidecounter = val; saveSettingsTimer->start(); }
	void setHidefilepathshowfilename(bool val) { hidefilepathshowfilename = val; saveSettingsTimer->start(); }
	void setHidefilename(bool val) { hidefilename = val; saveSettingsTimer->start(); }
	void setHidex(bool val) { hidex = val; saveSettingsTimer->start(); }
	void setCloseXsize(int val) { closeXsize = val; saveSettingsTimer->start(); }
	void setFancyX(bool val) {fancyX = val; saveSettingsTimer->start(); }

	void setSlideShowTime(int val) { slideShowTime = val; saveSettingsTimer->start(); }
	void setSlideShowTransition(int val) { slideShowTransition = val; saveSettingsTimer->start(); }
	void setSlideShowMusicFile(QString val) { slideShowMusicFile = val; saveSettingsTimer->start(); }
	void setSlideShowShuffle(bool val) { slideShowShuffle = val; saveSettingsTimer->start(); }
	void setSlideShowLoop(bool val) { slideShowLoop = val; saveSettingsTimer->start(); }
	void setSlideShowHideQuickinfo(bool val) { slideShowHideQuickinfo = val; saveSettingsTimer->start(); }

	void setWallpaperAlignment(QString val) { wallpaperAlignment = val; saveSettingsTimer->start(); }
	void setWallpaperScale(QString val) { wallpaperScale = val; saveSettingsTimer->start(); }

	void setThumbnailsize(int val) { thumbnailsize = val; saveSettingsTimer->start(); }
	void setThumbnailposition(QString val) { thumbnailposition = val; saveSettingsTimer->start(); }
	void setThumbnailcache(bool val) { thumbnailcache = val; saveSettingsTimer->start(); }
	void setThbcachefile(bool val) { thbcachefile = val; saveSettingsTimer->start(); }
	void setThumbnailSpacingBetween(int val) { thumbnailSpacingBetween = val; saveSettingsTimer->start(); }
	void setThumbnailLiftUp(int val) { thumbnailLiftUp = val; saveSettingsTimer->start(); }
	void setThumbnailKeepVisible(bool val) { thumbnailKeepVisible = val; saveSettingsTimer->start(); }
	void setThumbnailDynamic(int val) { thumbnailDynamic = val; saveSettingsTimer->start(); }
	void setThumbnailCenterActive(bool val) { thumbnailCenterActive = val; saveSettingsTimer->start(); }
	void setThumbnailFilenameInstead(bool val) { thumbnailFilenameInstead = val; saveSettingsTimer->start(); }
	void setThumbnailFilenameInsteadFontSize(int val) { thumbnailFilenameInsteadFontSize = val; saveSettingsTimer->start(); }
	void setThumbnailDisable(bool val) { thumbnailDisable = val; saveSettingsTimer->start(); }
	void setThumbnailWriteFilename(bool val) { thumbnailWriteFilename = val; saveSettingsTimer->start(); }
	void setThumbnailWriteResolution(bool val) { thumbnailWriteResolution = val; saveSettingsTimer->start(); }
	void setThumbnailFontSize(int val) { thumbnailFontSize = val; saveSettingsTimer->start(); }

	void setWindowmode(bool val) { windowmode = val; saveSettingsTimer->start(); }
	void setWindowDecoration(bool val) { windowDecoration = val; saveSettingsTimer->start(); }
	void setKnownFileTypesQtExtras(QString val) { knownFileTypesQtExtras = val; saveSettingsTimer->start(); }

	void setExifenablemousetriggering(bool val) { exifenablemousetriggering = val; saveSettingsTimer->start(); }
	void setExifrotation(QString val) { exifrotation = val; saveSettingsTimer->start(); }
	void setExifgpsmapservice(QString val) { exifgpsmapservice = val; saveSettingsTimer->start(); }
	void setExiffontsize(int val) { exiffontsize = val; saveSettingsTimer->start(); }
	void setExiffilename(bool val) { exiffilename = val; saveSettingsTimer->start(); }
	void setExiffiletype(bool val) { exiffiletype = val; saveSettingsTimer->start(); }
	void setExiffilesize(bool val) { exiffilesize = val; saveSettingsTimer->start(); }
	void setExifdimensions(bool val) { exifdimensions = val; saveSettingsTimer->start(); }
	void setExifmake(bool val) { exifmake = val; saveSettingsTimer->start(); }
	void setExifmodel(bool val) { exifmodel = val; saveSettingsTimer->start(); }
	void setExifsoftware(bool val) { exifsoftware = val; saveSettingsTimer->start(); }
	void setExifphototaken(bool val) { exifphototaken = val; saveSettingsTimer->start(); }
	void setExifexposuretime(bool val) { exifexposuretime = val; saveSettingsTimer->start(); }
	void setExifflash(bool val) { exifflash = val; saveSettingsTimer->start(); }
	void setExifiso(bool val) { exifiso = val; saveSettingsTimer->start(); }
	void setExifscenetype(bool val) { exifscenetype = val; saveSettingsTimer->start(); }
	void setExifflength(bool val) { exifflength = val; saveSettingsTimer->start(); }
	void setExiffnumber(bool val) { exiffnumber = val; saveSettingsTimer->start(); }
	void setExiflightsource(bool val) { exiflightsource = val; saveSettingsTimer->start(); }
	void setIptckeywords(bool val) { iptckeywords = val; saveSettingsTimer->start(); }
	void setIptclocation(bool val) { iptclocation = val; saveSettingsTimer->start(); }
	void setIptccopyright(bool val) { iptccopyright = val; saveSettingsTimer->start(); }
	void setExifgps(bool val) { exifgps = val; saveSettingsTimer->start(); }


	/*#################################################################################################*/
	/*#################################################################################################*/

	/**********************
	 * Q_PROPERTY methods *
	 **********************/

	Q_PROPERTY(QString language READ getLanguage WRITE setLanguage NOTIFY languageChanged)
	Q_PROPERTY(bool myWidgetAnimated READ getMyWidgetAnimated WRITE setMyWidgetAnimated NOTIFY myWidgetAnimatedChanged)
	Q_PROPERTY(bool saveWindowGeometry READ getSaveWindowGeometry WRITE setSaveWindowGeometry NOTIFY saveWindowGeometryChanged)
	Q_PROPERTY(bool keepOnTop READ getKeepOnTop WRITE setKeepOnTop NOTIFY keepOnTopChanged)
	Q_PROPERTY(bool composite READ getComposite WRITE setComposite NOTIFY compositeChanged)

	Q_PROPERTY(int bgColorRed READ getBgColorRed WRITE setBgColorRed NOTIFY bgColorRedChanged)
	Q_PROPERTY(int bgColorGreen READ getBgColorGreen WRITE setBgColorGreen NOTIFY bgColorGreenChanged)
	Q_PROPERTY(int bgColorBlue READ getBgColorBlue WRITE setBgColorBlue NOTIFY bgColorBlueChanged)
	Q_PROPERTY(int bgColorAlpha READ getBgColorAlpha WRITE setBgColorAlpha NOTIFY bgColorAlphaChanged)

	Q_PROPERTY(bool backgroundImageScreenshot READ getBackgroundImageScreenshot WRITE setBackgroundImageScreenshot NOTIFY backgroundImageScreenshotChanged)
	Q_PROPERTY(bool backgroundImageUse READ getBackgroundImageUse WRITE setBackgroundImageUse NOTIFY backgroundImageUseChanged)
	Q_PROPERTY(QString backgroundImagePath READ getBackgroundImagePath WRITE setBackgroundImagePath NOTIFY backgroundImagePathChanged)
	Q_PROPERTY(bool backgroundImageScale READ getBackgroundImageScale WRITE setBackgroundImageScale NOTIFY backgroundImageScaleChanged)
	Q_PROPERTY(bool backgroundImageScaleCrop READ getBackgroundImageScaleCrop WRITE setBackgroundImageScaleCrop NOTIFY backgroundImageScaleCropChanged)
	Q_PROPERTY(bool backgroundImageStretch READ getBackgroundImageStretch WRITE setBackgroundImageStretch NOTIFY backgroundImageStretchChanged)
	Q_PROPERTY(bool backgroundImageCenter READ getBackgroundImageCenter WRITE setBackgroundImageCenter NOTIFY backgroundImageCenterChanged)
	Q_PROPERTY(bool backgroundImageTile READ getBackgroundImageTile WRITE setBackgroundImageTile NOTIFY backgroundImageTileChanged)

	Q_PROPERTY(int trayicon READ getTrayicon WRITE setTrayicon NOTIFY trayiconChanged)
	Q_PROPERTY(int transition READ getTransition WRITE setTransition NOTIFY transitionChanged)
	Q_PROPERTY(bool loopthroughfolder READ getLoopthroughfolder WRITE setLoopthroughfolder NOTIFY loopthroughfolderChanged)
	Q_PROPERTY(int menusensitivity READ getMenusensitivity WRITE setMenusensitivity NOTIFY menusensitivityChanged)
	Q_PROPERTY(bool closeongrey READ getCloseongrey WRITE setCloseongrey NOTIFY closeongreyChanged)
	Q_PROPERTY(int borderAroundImg READ getBorderAroundImg WRITE setBorderAroundImg NOTIFY borderAroundImgChanged)
	Q_PROPERTY(bool quickSettings READ getQuickSettings WRITE setQuickSettings NOTIFY quickSettingsChanged)
	Q_PROPERTY(QString sortby READ getSortby WRITE setSortby NOTIFY sortbyChanged)
	Q_PROPERTY(bool sortbyAscending READ getSortbyAscending WRITE setSortbyAscending NOTIFY sortbyAscendingChanged)
	Q_PROPERTY(int mouseWheelSensitivity READ getMouseWheelSensitivity WRITE setMouseWheelSensitivity NOTIFY mouseWheelSensitivityChanged)
	Q_PROPERTY(bool rememberRotation READ getRememberRotation WRITE setRememberRotation NOTIFY rememberRotationChanged)
	Q_PROPERTY(bool rememberZoom READ getRememberZoom WRITE setRememberZoom NOTIFY rememberZoomChanged)
	Q_PROPERTY(bool fitInWindow READ getFitInWindow WRITE setFitInWindow NOTIFY fitInWindowChanged)
	Q_PROPERTY(int interpolationNearestNeighbourThreshold READ getInterpolationNearestNeighbourThreshold WRITE setInterpolationNearestNeighbourThreshold NOTIFY interpolationNearestNeighbourThresholdChanged)
	Q_PROPERTY(bool interpolationNearestNeighbourUpscale READ getInterpolationNearestNeighbourUpscale WRITE setInterpolationNearestNeighbourUpscale NOTIFY interpolationNearestNeighbourUpscaleChanged)

	Q_PROPERTY(bool hidecounter READ getHidecounter WRITE setHidecounter NOTIFY hidecounterChanged)
	Q_PROPERTY(bool hidefilepathshowfilename READ getHidefilepathshowfilename WRITE setHidefilepathshowfilename NOTIFY hidefilepathshowfilenameChanged)
	Q_PROPERTY(bool hidefilename READ getHidefilename WRITE setHidefilename NOTIFY hidefilenameChanged)
	Q_PROPERTY(bool hidex READ getHidex WRITE setHidex NOTIFY hidexChanged)
	Q_PROPERTY(int closeXsize READ getCloseXsize WRITE setCloseXsize NOTIFY closeXsizeChanged)
	Q_PROPERTY(bool fancyX READ getFancyX WRITE setFancyX NOTIFY fancyXChanged)

	Q_PROPERTY(int slideShowTime READ getSlideShowTime WRITE setSlideShowTime NOTIFY slideShowTimeChanged)
	Q_PROPERTY(int slideShowTransition READ getSlideShowTransition WRITE setSlideShowTransition NOTIFY slideShowTransitionChanged)
	Q_PROPERTY(QString slideShowMusicFile READ getSlideShowMusicFile WRITE setSlideShowMusicFile NOTIFY slideShowMusicFileChanged)
	Q_PROPERTY(bool slideShowShuffle READ getSlideShowShuffle WRITE setSlideShowShuffle NOTIFY slideShowShuffleChanged)
	Q_PROPERTY(bool slideShowLoop READ getSlideShowLoop WRITE setSlideShowLoop NOTIFY slideShowLoopChanged)
	Q_PROPERTY(bool slideShowHideQuickinfo READ getSlideShowHideQuickinfo WRITE setSlideShowHideQuickinfo NOTIFY slideShowHideQuickinfoChanged)

	Q_PROPERTY(QString wallpaperAlignment READ getWallpaperAlignment WRITE setWallpaperAlignment NOTIFY wallpaperAlignmentChanged)
	Q_PROPERTY(QString wallpaperScale READ getWallpaperScale WRITE setWallpaperScale NOTIFY wallpaperScaleChanged)

	Q_PROPERTY(int thumbnailsize READ getThumbnailsize WRITE setThumbnailsize NOTIFY thumbnailsizeChanged)
	Q_PROPERTY(QString thumbnailposition READ getThumbnailposition WRITE setThumbnailposition NOTIFY thumbnailpositionChanged)
	Q_PROPERTY(bool thumbnailcache READ getThumbnailcache WRITE setThumbnailcache NOTIFY thumbnailcacheChanged)
	Q_PROPERTY(bool thbcachefile READ getThbcachefile WRITE setThbcachefile NOTIFY thbcachefileChanged)
	Q_PROPERTY(int thumbnailSpacingBetween READ getThumbnailSpacingBetween WRITE setThumbnailSpacingBetween NOTIFY thumbnailSpacingBetweenChanged)
	Q_PROPERTY(int thumbnailLiftUp READ getThumbnailLiftUp WRITE setThumbnailLiftUp NOTIFY thumbnailLiftUpChanged)
	Q_PROPERTY(bool thumbnailKeepVisible READ getThumbnailKeepVisible WRITE setThumbnailKeepVisible NOTIFY thumbnailKeepVisibleChanged)
	Q_PROPERTY(int thumbnailDynamic READ getThumbnailDynamic WRITE setThumbnailDynamic NOTIFY thumbnailDynamicChanged)
	Q_PROPERTY(bool thumbnailCenterActive READ getThumbnailCenterActive WRITE setThumbnailCenterActive NOTIFY thumbnailCenterActiveChanged)
	Q_PROPERTY(bool thumbnailFilenameInstead READ getThumbnailFilenameInstead WRITE setThumbnailFilenameInstead NOTIFY thumbnailFilenameInsteadChanged)
	Q_PROPERTY(int thumbnailFilenameInsteadFontSize READ getThumbnailFilenameInsteadFontSize WRITE setThumbnailFilenameInsteadFontSize NOTIFY thumbnailFilenameInsteadFontSizeChanged)
	Q_PROPERTY(bool thumbnailDisable READ getThumbnailDisable WRITE setThumbnailDisable NOTIFY thumbnailDisableChanged)
	Q_PROPERTY(bool thumbnailWriteFilename READ getThumbnailWriteFilename WRITE setThumbnailWriteFilename NOTIFY thumbnailWriteFilenameChanged)
	Q_PROPERTY(bool thumbnailWriteResolution READ getThumbnailWriteResolution WRITE setThumbnailWriteResolution NOTIFY thumbnailWriteResolutionChanged)
	Q_PROPERTY(int thumbnailFontSize READ getThumbnailFontSize WRITE setThumbnailFontSize NOTIFY thumbnailFontSizeChanged)

	Q_PROPERTY(bool windowmode READ getWindowmode WRITE setWindowmode NOTIFY windowmodeChanged)
	Q_PROPERTY(bool windowDecoration READ getWindowDecoration WRITE setWindowDecoration NOTIFY windowDecorationChanged)
	Q_PROPERTY(QString knownFileTypesQtExtras READ getKnownFileTypesQtExtras WRITE setKnownFileTypesQtExtras NOTIFY knownFileTypesQtExtrasChanged)

	Q_PROPERTY(bool exifenablemousetriggering READ getExifenablemousetriggering WRITE setExifenablemousetriggering NOTIFY exifenablemousetriggeringChanged)
	Q_PROPERTY(QString exifrotation READ getExifrotation WRITE setExifrotation NOTIFY exifrotationChanged)
	Q_PROPERTY(QString exifgpsmapservice READ getExifgpsmapservice WRITE setExifgpsmapservice NOTIFY exifgpsmapserviceChanged)
	Q_PROPERTY(int exiffontsize READ getExiffontsize WRITE setExiffontsize NOTIFY exiffontsizeChanged)
	Q_PROPERTY(bool exiffilename READ getExiffilename WRITE setExiffilename NOTIFY exiffilenameChanged)
	Q_PROPERTY(bool exiffiletype READ getExiffiletype WRITE setExiffiletype NOTIFY exiffiletypeChanged)
	Q_PROPERTY(bool exiffilesize READ getExiffilesize WRITE setExiffilesize NOTIFY exiffilesizeChanged)
	Q_PROPERTY(bool exifdimensions READ getExifdimensions WRITE setExifdimensions NOTIFY exifdimensionsChanged)
	Q_PROPERTY(bool exifmake READ getExifmake WRITE setExifmake NOTIFY exifmakeChanged)
	Q_PROPERTY(bool exifmodel READ getExifmodel WRITE setExifmodel NOTIFY exifmodelChanged)
	Q_PROPERTY(bool exifsoftware READ getExifsoftware WRITE setExifsoftware NOTIFY exifsoftwareChanged)
	Q_PROPERTY(bool exifphototaken READ getExifphototaken WRITE setExifphototaken NOTIFY exifphototakenChanged)
	Q_PROPERTY(bool exifexposuretime READ getExifexposuretime WRITE setExifexposuretime NOTIFY exifexposuretimeChanged)
	Q_PROPERTY(bool exifflash READ getExifflash WRITE setExifflash NOTIFY exifflashChanged)
	Q_PROPERTY(bool exifiso READ getExifiso WRITE setExifiso NOTIFY exifisoChanged)
	Q_PROPERTY(bool exifscenetype READ getExifscenetype WRITE setExifscenetype NOTIFY exifscenetypeChanged)
	Q_PROPERTY(bool exifflength READ getExifflength WRITE setExifflength NOTIFY exifflengthChanged)
	Q_PROPERTY(bool exiffnumber READ getExiffnumber WRITE setExiffnumber NOTIFY exiffnumberChanged)
	Q_PROPERTY(bool exiflightsource READ getExiflightsource WRITE setExiflightsource NOTIFY exiflightsourceChanged)
	Q_PROPERTY(bool iptckeywords READ getIptckeywords WRITE setIptckeywords NOTIFY iptckeywordsChanged)
	Q_PROPERTY(bool iptclocation READ getIptclocation WRITE setIptclocation NOTIFY iptclocationChanged)
	Q_PROPERTY(bool iptccopyright READ getIptccopyright WRITE setIptccopyright NOTIFY iptccopyrightChanged)
	Q_PROPERTY(bool exifgps READ getExifgps WRITE setExifgps NOTIFY exifgpsChanged)


	/*#################################################################################################*/
	/*#################################################################################################*/

	// Set the default settings
	void setDefault() {

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
	}


	/*#################################################################################################*/
	/*#################################################################################################*/

public slots:
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
		QFileInfo checkFile(QDir::homePath() + "/.photoqt/settings");
		while(!checkFile.exists())
			std::this_thread::sleep_for(std::chrono::milliseconds(10));

		watcher->addPath(QDir::homePath() + "/.photoqt/settings");

		// Set default values to start out with
		setDefault();

		QFile file(QDir::homePath() + "/.photoqt/settings");

		if(!file.open(QIODevice::ReadOnly))

			std::cerr << "ERROR reading settings:" << file.errorString().trimmed().toStdString() << std::endl;

		else {

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

			file.close();

			emitAllSignals();

		}

	}

private slots:
	void emitAllSignals() {
		emit languageChanged(language);
		emit myWidgetAnimatedChanged(myWidgetAnimated);
		emit saveWindowGeometryChanged(saveWindowGeometry);
		emit keepOnTopChanged(keepOnTop);
		emit compositeChanged(composite);

		emit bgColorRedChanged(bgColorRed);
		emit bgColorGreenChanged(bgColorGreen);
		emit bgColorBlueChanged(bgColorBlue);
		emit bgColorAlphaChanged(bgColorAlpha);

		emit backgroundImageScreenshotChanged(backgroundImageScreenshot);
		emit backgroundImageUseChanged(backgroundImageUse);
		emit backgroundImagePathChanged(backgroundImagePath);
		emit backgroundImageScaleChanged(backgroundImageScale);
		emit backgroundImageScaleCropChanged(backgroundImageScaleCrop);
		emit backgroundImageStretchChanged(backgroundImageStretch);
		emit backgroundImageCenterChanged(backgroundImageCenter);
		emit backgroundImageTileChanged(backgroundImageTile);

		emit trayiconChanged(trayicon);
		emit transitionChanged(transition);
		emit loopthroughfolderChanged(loopthroughfolder);
		emit menusensitivityChanged(menusensitivity);
		emit closeongreyChanged(closeongrey);
		emit borderAroundImgChanged(borderAroundImg);
		emit quickSettingsChanged(quickSettings);
		emit sortbyChanged(sortby);
		emit sortbyAscendingChanged(sortbyAscending);
		emit mouseWheelSensitivityChanged(mouseWheelSensitivity);
		emit rememberRotationChanged(rememberRotation);
		emit rememberZoomChanged(rememberZoom);
		emit fitInWindowChanged(fitInWindow);
		emit interpolationNearestNeighbourThresholdChanged(interpolationNearestNeighbourThreshold);
		emit interpolationNearestNeighbourUpscaleChanged(interpolationNearestNeighbourUpscale);

		emit hidecounterChanged(hidecounter);
		emit hidefilepathshowfilenameChanged(hidefilepathshowfilename);
		emit hidefilenameChanged(hidefilename);
		emit hidexChanged(hidex);
		emit closeXsizeChanged(closeXsize);
		emit fancyXChanged(fancyX);

		emit slideShowTimeChanged(slideShowTime);
		emit slideShowMusicFileChanged(slideShowMusicFile);
		emit slideShowShuffleChanged(slideShowShuffle);
		emit slideShowLoopChanged(slideShowLoop);
		emit slideShowTransitionChanged(slideShowTransition);
		emit slideShowHideQuickinfoChanged(slideShowHideQuickinfo);

		emit wallpaperAlignmentChanged(wallpaperAlignment);
		emit wallpaperScaleChanged(wallpaperScale);

		emit thumbnailsizeChanged(thumbnailsize);
		emit thumbnailcacheChanged(thumbnailcache);
		emit thbcachefileChanged(thbcachefile);
		emit thumbnailSpacingBetweenChanged(thumbnailSpacingBetween);
		emit thumbnailLiftUpChanged(thumbnailLiftUp);
		emit thumbnailKeepVisibleChanged(thumbnailKeepVisible);
		emit thumbnailFontSizeChanged(thumbnailFontSize);
		emit thumbnailDynamicChanged(thumbnailDynamic);
		emit thumbnailCenterActiveChanged(thumbnailCenterActive);
		emit thumbnailpositionChanged(thumbnailposition);
		emit thumbnailFilenameInsteadChanged(thumbnailFilenameInstead);
		emit thumbnailFilenameInsteadFontSizeChanged(thumbnailFilenameInsteadFontSize);
		emit thumbnailDisableChanged(thumbnailDisable);
		emit thumbnailWriteFilenameChanged(thumbnailWriteFilename);
		emit thumbnailWriteResolutionChanged(thumbnailWriteResolution);

		emit windowmodeChanged(windowmode);
		emit windowDecorationChanged(windowDecoration);
		emit knownFileTypesQtExtrasChanged(knownFileTypesQtExtras);

		emit exiffontsizeChanged(exiffontsize);
		emit exifenablemousetriggeringChanged(exifenablemousetriggering);
		emit exifrotationChanged(exifrotation);
		emit exifgpsmapserviceChanged(exifgpsmapservice);
		emit exiffilenameChanged(exiffilename);
		emit exiffiletypeChanged(exiffiletype);
		emit exiffilesizeChanged(exiffilesize);
		emit exifdimensionsChanged(exifdimensions);
		emit exifmakeChanged(exifmake);
		emit exifmodelChanged(exifmodel);
		emit exifsoftwareChanged(exifsoftware);
		emit exifphototakenChanged(exifphototaken);
		emit exifexposuretimeChanged(exifexposuretime);
		emit exifflashChanged(exifflash);
		emit exifisoChanged(exifiso);
		emit exifscenetypeChanged(exifscenetype);
		emit exifflengthChanged(exifflength);
		emit exiffnumberChanged(exiffnumber);
		emit exiflightsourceChanged(exiflightsource);
		emit iptckeywordsChanged(iptckeywords);
		emit iptclocationChanged(iptclocation);
		emit iptccopyrightChanged(iptccopyright);
		emit exifgpsChanged(exifgps);
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


};

#endif // SETTINGS_H
