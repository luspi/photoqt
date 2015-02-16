#ifndef SETTINGS_H
#define SETTINGS_H

//******************************************************//
// THIS IS THE GLOBAL VERSION STRING, ONCE DEFINED HERE //
//******************************************************//
#define VERSION "1.2"
//******************************************************//
//******************************************************//

#include <QObject>
#include <QSettings>
#include <QDir>
#include <QFileSystemWatcher>
#include "fileformats.h"

// Convenience class to access and change permanent settings

class Settings : public QObject {

	Q_OBJECT

public:
	explicit Settings(QObject *parent = 0) : QObject(parent) {
		verbose = false;
		readSettings();
		watcher = new QFileSystemWatcher;
		watcher->addPath(QDir::homePath() + "/.photoqt/settings");
		connect(watcher, SIGNAL(fileChanged(QString)), this, SLOT(readSettings()));
	}

	bool verbose;

	// The current version
	QString version;

	// The language selected and available languages
	QString language;
	QStringList availableLang;

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
	bool backgroundImageStretch;
	bool backgroundImageCenter;

	// Hide to tray icon?
	bool trayicon;
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

	// Are quickinfos hidden?
	bool hidecounter;
	bool hidefilepathshowfilename;
	bool hidefilename;
	bool hidex;
	// Size/Look of closing "x"
	int closeXsize;
	int getCloseXsize() { return closeXsize; }
	Q_PROPERTY(int closeXsize READ getCloseXsize NOTIFY closeXsizeChanged)
	bool fancyX;
	bool getFancyx() { return fancyX; }
	Q_PROPERTY(bool fancyX READ getFancyx NOTIFY fancyXChanged)

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
	int getThumbnailsize() { return thumbnailsize; }
	Q_PROPERTY(int thumbnailsize READ getThumbnailsize NOTIFY thumbnailsizeChanged)

	// Thumbnails at the bottom or top?
	QString thumbnailposition;

	// Enable thumbnail cache
	bool thumbnailcache;
	bool getThumbnailcache() { return thumbnailcache; }
	Q_PROPERTY(bool thumbnailcache READ getThumbnailcache NOTIFY thumbnailcacheChanged)

	// Are files used for caching (use database if false)
	bool thbcachefile;
	bool getThbcachefile() { return thbcachefile; }
	Q_PROPERTY(bool thbcachefile READ getThbcachefile NOTIFY thbcachefileChanged)

	// Border between thumbnails
	int thumbnailSpacingBetween;
	int getThumbnailSpacingBetween() { return thumbnailSpacingBetween; }
	Q_PROPERTY(int thumbnailSpacingBetween READ getThumbnailSpacingBetween NOTIFY thumbnailSpacingBetweenChanged)

	// Lift hovered/selected thumbnails by x pixels
	int thumbnailLiftUp;
	int getThumbnailLiftUp() { return thumbnailLiftUp; }
	Q_PROPERTY(int thumbnailLiftUp READ getThumbnailLiftUp NOTIFY thumbnailLiftUpChanged)

	// Are the thumbnails fading out or always visible?
	bool thumbnailKeepVisible;
	bool getThumbnailKeepVisible() { return thumbnailKeepVisible; }
	Q_PROPERTY(bool thumbnailKeepVisible READ getThumbnailKeepVisible NOTIFY thumbnailKeepVisibleChanged)

	// Enable dynamic thumbnail creation (1 = dynamic, 2 = smart)
	int thumbnailDynamic;
	// Always center on active thumbnails
	bool thumbnailCenterActive;
	// Don't load actual thumbnail but just display the filename
	bool thumbnailFilenameInstead;
	int thumbnailFilenameInsteadFontSize;
	// Thumbnails can be disabled altogether
	bool thumbnailDisable;
	// Preload full directory (no matter the size)
	bool thumbnailPreloadFullDirectory;
	// How many thumbnail shall be reloaded?
	unsigned int thumbnailPreloadNumber;

	bool thumbnailWriteFilename;
	bool thumbnailWriteResolution;

	int thumbnailFontSize;
	int getThumbnailFontSize() { return thumbnailFontSize; }
	Q_PROPERTY(int thumbnailFontSize READ getThumbnailFontSize NOTIFY thumbnailFontSizeChanged)

	// Window Mode
	bool windowmode;
	// w/ or w/o decoration
	bool windowDecoration;

	// The currently known filetypes
	FileFormats *fileFormats;
	QString knownFileTypesQt;
	QString knownFileTypesQtExtras;
	QString knownFileTypesGm;
	QString knownFileTypesExtras;
	// A combination of all of them
	QString knownFileTypes;

	// Some exif settings
	bool exifenablemousetriggering;
	QString exifrotation;
	QString exifgpsmapservice;

	int exiffontsize;
	int getExiffontsize() { return exiffontsize; }
	Q_PROPERTY(int exiffontsize READ getExiffontsize NOTIFY exiffontsizeChanged)

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
	bool exifgps;

	// Set the default settings
	void setDefault() {

		version = QString::fromStdString(VERSION);

		fileFormats = new FileFormats;
		fileFormats->getFormats();
		knownFileTypesQt = fileFormats->formatsQtEnabled.join(",");
		knownFileTypesQtExtras = "";
		knownFileTypesGm = fileFormats->formatsGmEnabled.join(",");
		knownFileTypesExtras = fileFormats->formatsExtrasEnabled.join(",");
		knownFileTypes = (QStringList() << knownFileTypesQt << knownFileTypesGm << knownFileTypesExtras).join(",");

		sortby = "name";
		sortbyAscending = true;

		windowmode = false;
		windowDecoration = false;
		myWidgetAnimated = true;
		saveWindowGeometry = true;
		keepOnTop = true;

		language = "";
		bgColorRed = 0;
		bgColorGreen = 0;
		bgColorBlue = 0;
		bgColorAlpha = 190;

//#ifdef Q_OS_WIN32
//		backgroundImageScreenshot = (QtWin::isCompositionEnabled() ? false : true);
//#else
		backgroundImageScreenshot = true;
//#endif
		backgroundImageUse = false;
		backgroundImagePath = "";
		backgroundImageScale = false;
		backgroundImageStretch = false;
		backgroundImageCenter = false;

//#ifdef Q_OS_WIN32
//		composite = (QtWin::isCompositionEnabled() ? true : false);
//#else
		composite = false;
//#endif
		trayicon = false;
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
		thumbnailPreloadFullDirectory = false;
		thumbnailPreloadNumber = 400;

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
		exifgps = true;
		exifrotation = "Never";
		exifgpsmapservice = "openstreetmap.org";
	}


	// Save settings
	void saveSettings(QMap<QString,bool> applySet = QMap<QString,bool>()) {

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

			// We'll operate the replace() and split() below on temporary strings, not the actual ones (since we want to keep the *'s there)
			QString knownFileTypesQt_tmp = knownFileTypesQt;
			QString knownFileTypesGm_tmp = knownFileTypesGm;
			QString knownFileTypesExtras_tmp = knownFileTypesExtras;
			fileFormats->saveFormats(knownFileTypesQt_tmp.split(","),
						 knownFileTypesGm_tmp.split(","),
						 knownFileTypesExtras_tmp.split(","));

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
			cont += QString("BackgroundImageStretch=%1\n").arg(backgroundImageStretch);
			cont += QString("BackgroundImageCenter=%1\n").arg(backgroundImageCenter);

			cont += "\n[Behaviour]\n";

			cont += QString("TrayIcon=%1\n").arg(int(trayicon));
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
			cont += QString("ThumbnailPreloadFullDirectory=%1\n").arg(int(thumbnailPreloadFullDirectory));
			cont += QString("ThumbnailPreloadNumber=%1\n").arg(thumbnailPreloadNumber);

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

			out << cont;
			file.close();

		}

	}


public slots:
	// Read the current settings
	void readSettings() {

		setDefault();

		QFile file(QDir::homePath() + "/.photoqt/settings");

		if(!file.open(QIODevice::ReadOnly))

			std::cerr << "ERROR reading settings" << std::endl;

		else {

			if(verbose) std::cerr << "Read Settings from File" << std::endl;

			// Read file
			QTextStream in(&file);
			QString all = in.readAll();

			if(all.contains("Language="))
				language = all.split("Language=").at(1).split("\n").at(0);

			knownFileTypesQt = (fileFormats->formatsQtEnabled.length() != 0) ? fileFormats->formatsQtEnabled.join(",") : "";
			knownFileTypesGm = (fileFormats->formatsGmEnabled.length() != 0) ? fileFormats->formatsGmEnabled.join(",") : "";

			if(all.contains("KnownFileTypesQtExtras="))
				knownFileTypesQtExtras = all.split("KnownFileTypesQtExtras=").at(1).split("\n").at(0);

			knownFileTypes = "";
			if(knownFileTypesQt != "")
				knownFileTypes += "," + knownFileTypesQt;
			if(knownFileTypesGm != "")
				knownFileTypes += "," + knownFileTypesGm;
			if(knownFileTypesExtras != "")
				knownFileTypes += "," + knownFileTypesExtras;
			if(knownFileTypesQtExtras != "")
				knownFileTypes += "," + knownFileTypesQtExtras;
			if(knownFileTypes.startsWith(",")) knownFileTypes = knownFileTypes.remove(0,1);

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
			if(all.contains("BackgroundImageStretch="))
				backgroundImageStretch = bool(all.split("BackgroundImageStretch=").at(1).split("\n").at(0).toInt());
			if(all.contains("BackgroundImageCenter="))
				backgroundImageCenter = bool(all.split("BackgroundImageCenter=").at(1).split("\n").at(0).toInt());


			if(all.contains("TrayIcon=1"))
				trayicon = true;
			else if(all.contains("TrayIcon=0"))
				trayicon = false;

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

			if(all.contains("ThumbnailPreloadFullDirectory=1"))
				thumbnailPreloadFullDirectory = true;
			else if(all.contains("ThumbnailPreloadFullDirectory=0"))
				thumbnailPreloadFullDirectory = false;

			if(all.contains("ThumbnailPreloadNumber="))
				thumbnailPreloadNumber = all.split("ThumbnailPreloadNumber=").at(1).split("\n").at(0).toInt();


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

			if(all.contains("ExifRotation="))
				exifrotation = all.split("ExifRotation=").at(1).split("\n").at(0);

			if(all.contains("ExifGPSMapService="))
				exifgpsmapservice = all.split("ExifGPSMapService=").at(1).split("\n").at(0);

			file.close();

		}

	}


private:
    QFileSystemWatcher *watcher;

signals:
    void thumbnailsizeChanged(int s);
    void thumbnailcacheChanged(bool cache);
    void thbcachefileChanged(bool type);
    void thumbnailSpacingBetweenChanged(int spacing);
    void thumbnailLiftUpChanged(int liftup);
    void thumbnailKeepVisibleChanged(bool vis);
    void thumbnailFontSizeChanged(int s);
    void exiffontsizeChanged(int s);
    void fancyXChanged(bool f);
    void closeXsizeChanged(int s);


};

#endif // SETTINGS_H
