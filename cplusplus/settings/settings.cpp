/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

#include "settings.h"

Settings::Settings(QObject *parent) : QObject(parent) {

    // When saving the settings, we don't want to write the settings file hundreds of time within a few milliseconds,
    // but use a timer to save it once after all settings are set
    saveSettingsTimer = new QTimer;
    saveSettingsTimer->setInterval(400);
    saveSettingsTimer->setSingleShot(true);
    connect(saveSettingsTimer, &QTimer::timeout, this, &Settings::saveSettings);

    watcher = new QFileSystemWatcher;
    connect(watcher, &QFileSystemWatcher::fileChanged, [this](QString){ readSettings(); });

    watcherAddFileTimer = new QTimer;
    watcherAddFileTimer->setInterval(500);
    watcherAddFileTimer->setSingleShot(true);
    connect(watcherAddFileTimer, &QTimer::timeout, this, &Settings::addFileToWatcher);

    setDefault();
    readSettings();

}

// Clean-up
Settings::~Settings() {
    delete saveSettingsTimer;
}

void Settings::addFileToWatcher() {
    QFileInfo info(ConfigFiles::SETTINGS_FILE());
    if(!info.exists()) {
        watcherAddFileTimer->start();
        return;
    }
    watcher->removePath(ConfigFiles::SETTINGS_FILE());
    watcher->addPath(ConfigFiles::SETTINGS_FILE());
}

// Set the default settings
void Settings::setDefault() {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "Settings::setDefault()" << NL;

    setVersion(QString::fromStdString(VERSION));
    m_versionInTextFile = "";

    setSortby("naturalname");
    setSortbyAscending(true);

    setWindowMode(true);
    setWindowDecoration(false);

    setAnimations(true);
    setSaveWindowGeometry(false);
    setKeepOnTop(false);

    setLanguage(QLocale::system().name());

    setBackgroundColorRed(0);
    setBackgroundColorGreen(0);
    setBackgroundColorBlue(0);
    setBackgroundColorAlpha(190);

#ifdef Q_OS_WIN
    setBackgroundImageScreenshot(QtWin::isCompositionEnabled() ? false : true);
#else
    setBackgroundImageScreenshot(false);
#endif
    setBackgroundImageUse(false);
    setBackgroundImagePath("");
    setBackgroundImageScale(true);
    setBackgroundImageScaleCrop(false);
    setBackgroundImageStretch(false);
    setBackgroundImageCenter(false);
    setBackgroundImageTile(false);

#ifdef Q_OS_WIN
    setComposite(QtWin::isCompositionEnabled() ? true : false);
#else
    setComposite(true);
#endif
    setTrayIcon(0);
    setImageTransition(1);
    setLoopThroughFolder(true);
    setHotEdgeWidth(4);
    setCloseOnEmptyBackground(false);
    setMarginAroundImage(5);
    setMouseWheelSensitivity(1);
    setKeepZoomRotationMirror(false);
    setFitInWindow(false);
    setInterpolationNearestNeighbourThreshold(100);
    setInterpolationNearestNeighbourUpscale(true);
    setPixmapCache(128);
    setLeftButtonMouseClickAndMove(true);
    setShowTransparencyMarkerBackground(false);
    setStartupLoadLastLoadedImage(false);
    setMainMenuWindowWidth(350);
    setPdfSingleDocument(true);
    setPdfQuality(150);
    setArchiveSingleFile(true);

#ifdef Q_OS_LINUX
    QProcess which;
    which.setStandardOutputFile(QProcess::nullDevice());
    which.start("which unrar");
    which.waitForFinished();
    setArchiveUseExternalUnrar(which.exitCode() ? false : true);
#else
    setArchiveUseExternalUnrar(false);
#endif

    setQuickInfoHideCounter(false);
    setQuickInfoHideFilepath(true);
    setQuickInfoHideFilename(false);
    setQuickInfoHideX(false);
    setQuickInfoHideZoomLevel(false);
    setQuickInfoFullX(true);
    setQuickInfoCloseXSize(10);

    setThumbnailSize(80);
    setThumbnailPosition("Bottom");
    setThumbnailCache(true);
#ifdef Q_OS_WIN
    setThumbnailCacheFile(false);
#else
    setThumbnailCacheFile(true);
#endif
    setThumbnailSpacingBetween(0);
    setThumbnailLiftUp(6);
    setThumbnailKeepVisible(false);
    setThumbnailKeepVisibleWhenNotZoomedIn(false);
    setThumbnailCenterActive(false);
    setThumbnailDisable(false);
    setThumbnailWriteFilename(true);
    setThumbnailFontSize(7);
    setThumbnailFilenameInstead(false);
    setThumbnailFilenameInsteadFontSize(8);

    setSlideShowTime(5);
    setSlideShowImageTransition(4);
    setSlideShowMusicFile("");
    setSlideShowShuffle(false);
    setSlideShowLoop(true);
    setSlideShowHideQuickInfo(true);

    setMetaFilename(true);
    setMetaFileType(true);
    setMetaFileSize(true);
    setMetaImageNumber(true);
    setMetaDimensions(true);
    setMetaMake(true);
    setMetaModel(true);
    setMetaSoftware(true);
    setMetaTimePhotoTaken(true);
    setMetaExposureTime(true);
    setMetaFlash(true);
    setMetaIso(true);
    setMetaSceneType(true);
    setMetaFLength(true);
    setMetaFNumber(true);
    setMetaLightSource(true);
    setMetaKeywords(true);
    setMetaLocation(true);
    setMetaCopyright(true);
    setMetaGps(true);
    setMetaApplyRotation(true);
    setMetaGpsMapService("openstreetmap.org");

    setPeopleTagInMetaDisplay(true);
    setPeopleTagInMetaBorderAroundFace(false);
    setPeopleTagInMetaBorderAroundFaceColor("#44ff0000");
    setPeopleTagInMetaBorderAroundFaceWidth(3);
    setPeopleTagInMetaAlwaysVisible(false);
    setPeopleTagInMetaIndependentLabels(false);
    setPeopleTagInMetaHybridMode(true);
    setPeopleTagInMetaFontSize(10);

    setMetadataEnableHotEdge(true);
    setMetadataFontSize(10);
    setMetadataOpacity(220);
    setMetadataWindowWidth(350);

    setOpenDefaultView("list");
    setOpenPreview(true);
    setOpenPreviewHighQuality(false);
    setOpenZoomLevel(25);
    setOpenUserPlacesWidth(300);
    setOpenFoldersWidth(400);
    setOpenThumbnails(true);
    setOpenUserPlacesStandard(true);
    setOpenUserPlacesUser(true);
    setOpenUserPlacesVolumes(false);
    setOpenKeepLastLocation(false);
    setOpenShowHiddenFilesFolders(false);
    setOpenHideUserPlaces(false);

    setHistogram(false);
    setHistogramVersion("color");
    setHistogramPosition(QPoint(100,100));
    setHistogramSize(QSize(300,200));

}

// Save settings
void Settings::saveSettings() {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "Settings::saveSettings()" << NL;

    QFile file(ConfigFiles::SETTINGS_FILE());

    if(file.exists() && !file.open(QIODevice::ReadWrite))

        LOG << CURDATE << "Settings::saveSettings() - ERROR saving settings" << NL;

    else {

        if(file.exists()) {
            file.close();
            file.remove();
        }
        file.open(QIODevice::ReadWrite);

        QTextStream out(&file);

        QString cont = "Version=" + m_version + "\n";

        cont += QString("Language=%1\n").arg(m_language);
        cont += QString("WindowMode=%1\n").arg(int(m_windowMode));
        cont += QString("WindowDecoration=%1\n").arg(int(m_windowDecoration));
        cont += QString("Animations=%1\n").arg(int(m_animations));
        cont += QString("SaveWindowGeometry=%1\n").arg(int(m_saveWindowGeometry));
        cont += QString("KeepOnTop=%1\n").arg(int(m_keepOnTop));
        cont += QString("StartupLoadLastLoadedImage=%1\n").arg(int(m_startupLoadLastLoadedImage));

        cont += "\n[Look]\n";

        cont += QString("Composite=%1\n").arg(int(m_composite));
        cont += QString("BackgroundColorRed=%1\n").arg(m_backgroundColorRed);
        cont += QString("BackgroundColorGreen=%1\n").arg(m_backgroundColorGreen);
        cont += QString("BackgroundColorBlue=%1\n").arg(m_backgroundColorBlue);
        cont += QString("BackgroundColorAlpha=%1\n").arg(m_backgroundColorAlpha);
        cont += QString("BackgroundImageScreenshot=%1\n").arg(m_backgroundImageScreenshot);
        cont += QString("BackgroundImageUse=%1\n").arg(m_backgroundImageUse);
        cont += QString("BackgroundImagePath=%1\n").arg(m_backgroundImagePath);
        cont += QString("BackgroundImageScale=%1\n").arg(m_backgroundImageScale);
        cont += QString("BackgroundImageScaleCrop=%1\n").arg(m_backgroundImageScaleCrop);
        cont += QString("BackgroundImageStretch=%1\n").arg(m_backgroundImageStretch);
        cont += QString("BackgroundImageCenter=%1\n").arg(m_backgroundImageCenter);
        cont += QString("BackgroundImageTile=%1\n").arg(m_backgroundImageTile);

        cont += "\n[Behaviour]\n";

        cont += QString("TrayIcon=%1\n").arg(m_trayIcon);
        cont += QString("ImageTransition=%1\n").arg(m_imageTransition);
        cont += QString("LoopThroughFolder=%1\n").arg(int(m_loopThroughFolder));
        cont += QString("HotEdgeWidth=%1\n").arg(m_hotEdgeWidth);
        cont += QString("CloseOnEmptyBackground=%1\n").arg(int(m_closeOnEmptyBackground));
        cont += QString("MarginAroundImage=%1\n").arg(m_marginAroundImage);
        cont += QString("SortImagesBy=%1\n").arg(m_sortby);
        cont += QString("SortImagesAscending=%1\n").arg(int(m_sortbyAscending));
        cont += QString("MouseWheelSensitivity=%1\n").arg(m_mouseWheelSensitivity);
        cont += QString("KeepZoomRotationMirror=%1\n").arg(int(m_keepZoomRotationMirror));
        cont += QString("FitInWindow=%1\n").arg(int(m_fitInWindow));
        cont += QString("InterpolationNearestNeighbourThreshold=%1\n").arg(m_interpolationNearestNeighbourThreshold);
        cont += QString("InterpolationNearestNeighbourUpscale=%1\n").arg(int(m_interpolationNearestNeighbourUpscale));
        cont += QString("PixmapCache=%1\n").arg(m_pixmapCache);
        cont += QString("ShowTransparencyMarkerBackground=%1\n").arg(int(m_showTransparencyMarkerBackground));
        cont += QString("LeftButtonMouseClickAndMove=%1\n").arg(int(m_leftButtonMouseClickAndMove));
        cont += QString("PdfSingleDocument=%1\n").arg(int(m_pdfSingleDocument));
        cont += QString("PdfQuality=%1\n").arg(m_pdfQuality);
        cont += QString("ArchiveSingleFile=%1\n").arg(int(m_archiveSingleFile));
        cont += QString("ArchiveUseExternalUnrar=%1\n").arg(int(m_archiveUseExternalUnrar));

        cont += "\n[QuickInfo]\n";

        cont += QString("QuickInfoHideCounter=%1\n").arg(int(m_quickInfoHideCounter));
        cont += QString("QuickInfoHideFilepath=%1\n").arg(int(m_quickInfoHideFilepath));
        cont += QString("QuickInfoHideFilename=%1\n").arg(int(m_quickInfoHideFilename));
        cont += QString("QuickInfoHideX=%1\n").arg(int(m_quickInfoHideX));
        cont += QString("QuickInfoHideZoomLevel=%1\n").arg(int(m_quickInfoHideZoomLevel));
        cont += QString("QuickInfoFullX=%1\n").arg(int(m_quickInfoFullX));
        cont += QString("QuickInfoCloseXSize=%1\n").arg(m_quickInfoCloseXSize);

        cont += "\n[Thumbnail]\n";

        cont += QString("ThumbnailSize=%1\n").arg(m_thumbnailSize);
        cont += QString("ThumbnailPosition=%1\n").arg(m_thumbnailPosition);
        cont += QString("ThumbnailCache=%1\n").arg(int(m_thumbnailCache));
        cont += QString("ThumbnailCacheFile=%1\n").arg(int(m_thumbnailCacheFile));
        cont += QString("ThumbnailSpacingBetween=%1\n").arg(m_thumbnailSpacingBetween);
        cont += QString("ThumbnailLiftUp=%1\n").arg(m_thumbnailLiftUp);
        cont += QString("ThumbnailKeepVisible=%1\n").arg(int(m_thumbnailKeepVisible));
        cont += QString("ThumbnailKeepVisibleWhenNotZoomedIn=%1\n").arg(int(m_thumbnailKeepVisibleWhenNotZoomedIn));
        cont += QString("ThumbnailCenterActive=%1\n").arg(int(m_thumbnailCenterActive));
        cont += QString("ThumbnailFilenameInstead=%1\n").arg(int(m_thumbnailFilenameInstead));
        cont += QString("ThumbnailFilenameInsteadFontSize=%1\n").arg(m_thumbnailFilenameInsteadFontSize);
        cont += QString("ThumbnailDisable=%1\n").arg(int(m_thumbnailDisable));
        cont += QString("ThumbnailWriteFilename=%1\n").arg(int(m_thumbnailWriteFilename));
        cont += QString("ThumbnailFontSize=%1\n").arg(m_thumbnailFontSize);

        cont += "\n[Slideshow]\n";

        cont += QString("SlideShowTime=%1\n").arg(m_slideShowTime);
        cont += QString("SlideShowImageTransition=%1\n").arg(m_slideShowImageTransition);
        cont += QString("SlideShowMusicFile=%1\n").arg(m_slideShowMusicFile);
        cont += QString("SlideShowShuffle=%1\n").arg(int(m_slideShowShuffle));
        cont += QString("SlideShowLoop=%1\n").arg(int(m_slideShowLoop));
        cont += QString("SlideShowHideQuickInfo=%1\n").arg(int(m_slideShowHideQuickInfo));

        cont += "\n[Metadata]\n";

        cont += QString("MetaFilename=%1\n").arg(int(m_metaFilename));
        cont += QString("MetaFileType=%1\n").arg(int(m_metaFileType));
        cont += QString("MetaFileSize=%1\n").arg(int(m_metaFileSize));
        cont += QString("MetaImageNumber=%1\n").arg(int(m_metaImageNumber));
        cont += QString("MetaDimensions=%1\n").arg(int(m_metaDimensions));
        cont += QString("MetaMake=%1\n").arg(int(m_metaMake));
        cont += QString("MetaModel=%1\n").arg(int(m_metaModel));
        cont += QString("MetaSoftware=%1\n").arg(int(m_metaSoftware));
        cont += QString("MetaTimePhotoTaken=%1\n").arg(int(m_metaTimePhotoTaken));
        cont += QString("MetaExposureTime=%1\n").arg(int(m_metaExposureTime));
        cont += QString("MetaFlash=%1\n").arg(int(m_metaFlash));
        cont += QString("MetaIso=%1\n").arg(int(m_metaIso));
        cont += QString("MetaSceneType=%1\n").arg(int(m_metaSceneType));
        cont += QString("MetaFLength=%1\n").arg(int(m_metaFLength));
        cont += QString("MetaFNumber=%1\n").arg(int(m_metaFNumber));
        cont += QString("MetaLightSource=%1\n").arg(int(m_metaLightSource));
        cont += QString("MetaGps=%1\n").arg(int(m_metaGps));
        cont += QString("MetaApplyRotation=%1\n").arg(int(m_metaApplyRotation));
        cont += QString("MetaGpsMapService=%1\n").arg(m_metaGpsMapService);
        cont += QString("MetaKeywords=%1\n").arg(int(m_metaKeywords));
        cont += QString("MetaLocation=%1\n").arg(int(m_metaLocation));
        cont += QString("MetaCopyright=%1\n").arg(int(m_metaCopyright));

        cont += "\n[Metadata Element]\n";

        cont += QString("MetadataEnableHotEdge=%1\n").arg(int(m_metadataEnableHotEdge));
        cont += QString("MetadataFontSize=%1\n").arg(m_metadataFontSize);
        cont += QString("MetadataOpacity=%1\n").arg(m_metadataOpacity);
        cont += QString("MetadataWindowWidth=%1\n").arg(m_metadataWindowWidth);

        cont += "\n[People Tags in Metadata]\n";

        cont += QString("PeopleTagInMetaDisplay=%1\n").arg(int(m_peopleTagInMetaDisplay));
        cont += QString("PeopleTagInMetaBorderAroundFace=%1\n").arg(int(m_peopleTagInMetaBorderAroundFace));
        cont += QString("PeopleTagInMetaBorderAroundFaceColor=%1\n").arg(m_peopleTagInMetaBorderAroundFaceColor);
        cont += QString("PeopleTagInMetaBorderAroundFaceWidth=%1\n").arg(m_peopleTagInMetaBorderAroundFaceWidth);
        cont += QString("PeopleTagInMetaAlwaysVisible=%1\n").arg(int(m_peopleTagInMetaAlwaysVisible));
        cont += QString("PeopleTagInMetaIndependentLabels=%1\n").arg(int(m_peopleTagInMetaIndependentLabels));
        cont += QString("PeopleTagInMetaHybridMode=%1\n").arg(int(m_peopleTagInMetaHybridMode));
        cont += QString("PeopleTagInMetaFontSize=%1\n").arg(m_peopleTagInMetaFontSize);

        cont += "\n[Open File]\n";
        cont += QString("OpenDefaultView=%1\n").arg(m_openDefaultView);
        cont += QString("OpenPreview=%1\n").arg(int(m_openPreview));
        cont += QString("OpenPreviewHighQuality=%1\n").arg(int(m_openPreviewHighQuality));
        cont += QString("OpenZoomLevel=%1\n").arg(m_openZoomLevel);
        cont += QString("OpenUserPlacesWidth=%1\n").arg(m_openUserPlacesWidth);
        cont += QString("OpenFoldersWidth=%1\n").arg(m_openFoldersWidth);
        cont += QString("OpenThumbnails=%1\n").arg(int(m_openThumbnails));
        cont += QString("OpenUserPlacesStandard=%1\n").arg(int(m_openUserPlacesStandard));
        cont += QString("OpenUserPlacesUser=%1\n").arg(int(m_openUserPlacesUser));
        cont += QString("OpenUserPlacesVolumes=%1\n").arg(int(m_openUserPlacesVolumes));
        cont += QString("OpenKeepLastLocation=%1\n").arg(int(m_openKeepLastLocation));
        cont += QString("OpenShowHiddenFilesFolders=%1\n").arg(int(m_openShowHiddenFilesFolders));
        cont += QString("OpenHideUserPlaces=%1\n").arg(int(m_openHideUserPlaces));

        cont += "\n[Histogram]\n";

        cont += QString("Histogram=%1\n").arg(int(m_histogram));
        cont += QString("HistogramVersion=%1\n").arg(m_histogramVersion);
        cont += QString("HistogramPosition=%1,%2\n").arg(m_histogramPosition.x()).arg(m_histogramPosition.y());
        cont += QString("HistogramSize=%1,%2\n").arg(m_histogramSize.width()).arg(m_histogramSize.height());

        cont += "\n[Main Menu Element]\n";

        cont += QString("MainMenuWindowWidth=%1\n").arg(m_mainMenuWindowWidth);

        out << cont;
        file.close();

    }

}

// Read the current settings
void Settings::readSettings() {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "Settings::readSettings()" << NL;

    watcherAddFileTimer->start();

    QFile file(ConfigFiles::SETTINGS_FILE());

    if(file.exists() && !file.open(QIODevice::ReadOnly))

        LOG << CURDATE  << "Settings::readSettings() - ERROR reading settings:" << file.errorString().trimmed().toStdString() << NL;

    else if(file.exists() && file.isOpen()) {

        // Read file
        QTextStream in(&file);
        QStringList parts = in.readAll().split("\n");
        file.close();

        for(QString line : parts) {

            if(line.startsWith("Language="))
                setLanguage(line.split("=").at(1).trimmed());

            else if(line.startsWith("Version="))
                m_versionInTextFile = line.split("=").at(1).trimmed();


            else if(line.startsWith("SortImagesBy="))
                setSortby(line.split("=").at(1).trimmed());

            else if(line.startsWith("SortImagesAscending="))
                setSortbyAscending(line.split("=").at(1).toInt());

            else if(line.startsWith("WindowMode="))
                setWindowMode(line.split("=").at(1).toInt());

            else if(line.startsWith("WindowDecoration="))
                setWindowDecoration(line.split("=").at(1).toInt());

            else if(line.startsWith("Animations="))
                setAnimations(line.split("=").at(1).toInt());

            else if(line.startsWith("SaveWindowGeometry="))
                setSaveWindowGeometry(line.split("=").at(1).toInt());

            else if(line.startsWith("KeepOnTop="))
                setKeepOnTop(line.split("=").at(1).toInt());

            else if(line.startsWith("Composite="))
                setComposite(line.split("=").at(1).toInt());

            else if(line.startsWith("StartupLoadLastLoadedImage="))
                setStartupLoadLastLoadedImage(line.split("=").at(1).toInt());


            else if(line.startsWith("BackgroundColorRed="))
                setBackgroundColorRed(line.split("=").at(1).toInt());
            else if(line.startsWith("BackgroundColorGreen="))
                setBackgroundColorGreen(line.split("=").at(1).toInt());
            else if(line.startsWith("BackgroundColorBlue="))
                setBackgroundColorBlue(line.split("=").at(1).toInt());
            else if(line.startsWith("BackgroundColorAlpha="))
                setBackgroundColorAlpha(line.split("=").at(1).toInt());

            else if(line.startsWith("BackgroundImageScreenshot="))
                setBackgroundImageScreenshot(line.split("=").at(1).toInt());

            else if(line.startsWith("BackgroundImagePath="))
                setBackgroundImagePath(line.split("=").at(1).trimmed());
            else if(line.startsWith("BackgroundImageUse="))
                setBackgroundImageUse(line.split("=").at(1).toInt());
            else if(line.startsWith("BackgroundImageScale="))
                setBackgroundImageScale(line.split("=").at(1).toInt());
            else if(line.startsWith("BackgroundImageScaleCrop="))
                setBackgroundImageScaleCrop(line.split("=").at(1).toInt());
            else if(line.startsWith("BackgroundImageStretch="))
                setBackgroundImageStretch(line.split("=").at(1).toInt());
            else if(line.startsWith("BackgroundImageCenter="))
                setBackgroundImageCenter(line.split("=").at(1).toInt());
            else if(line.startsWith("BackgroundImageTile="))
                setBackgroundImageTile(line.split("=").at(1).toInt());


            else if(line.startsWith("TrayIcon="))
                setTrayIcon(line.split("=").at(1).toInt());

            else if(line.startsWith("ImageTransition="))
                setImageTransition(line.split("=").at(1).toInt());

            else if(line.startsWith("LoopThroughFolder="))
                setLoopThroughFolder(line.split("=").at(1).toInt());

            else if(line.startsWith("HotEdgeWidth="))
                setHotEdgeWidth(line.split("=").at(1).toInt());

            else if(line.startsWith("CloseOnEmptyBackground="))
                setCloseOnEmptyBackground(line.split("=").at(1).toInt());

            else if(line.startsWith("MarginAroundImage="))
                setMarginAroundImage(line.split("=").at(1).toInt());

            else if(line.startsWith("MouseWheelSensitivity="))
                setMouseWheelSensitivity(line.split("=").at(1).toInt());

            else if(line.startsWith("KeepZoomRotationMirror="))
                setKeepZoomRotationMirror(line.split("=").at(1).toInt());

            else if(line.startsWith("FitInWindow="))
                setFitInWindow(line.split("=").at(1).toInt());

            else if(line.startsWith("InterpolationNearestNeighbourThreshold="))
                setInterpolationNearestNeighbourThreshold(line.split("=").at(1).toInt());

            else if(line.startsWith("InterpolationNearestNeighbourUpscale="))
                setInterpolationNearestNeighbourUpscale(line.split("=").at(1).toInt());

            else if(line.startsWith("PixmapCache="))
                setPixmapCache(line.split("=").at(1).toInt());

            else if(line.startsWith("ShowTransparencyMarkerBackground="))
                setShowTransparencyMarkerBackground(line.split("=").at(1).toInt());

            else if(line.startsWith("LeftButtonMouseClickAndMove="))
                setLeftButtonMouseClickAndMove(line.split("=").at(1).toInt());

            else if(line.startsWith("PdfSingleDocument="))
                setPdfSingleDocument(line.split("=").at(1).toInt());

            else if(line.startsWith("PdfQuality="))
                setPdfQuality(line.split("=").at(1).toInt());

            else if(line.startsWith("ArchiveSingleFile="))
                setArchiveSingleFile(line.split("=").at(1).toInt());

            else if(line.startsWith("ArchiveUseExternalUnrar="))
                setArchiveUseExternalUnrar(line.split("=").at(1).toInt());


            else if(line.startsWith("QuickInfoHideCounter="))
                setQuickInfoHideCounter(line.split("=").at(1).toInt());

            else if(line.startsWith("QuickInfoHideFilepath="))
                setQuickInfoHideFilepath(line.split("=").at(1).toInt());

            else if(line.startsWith("QuickInfoHideFilename="))
                setQuickInfoHideFilename(line.split("=").at(1).toInt());

            else if(line.startsWith("QuickInfoHideX="))
                setQuickInfoHideX(line.split("=").at(1).toInt());

            else if(line.startsWith("QuickInfoHideZoomLevel="))
                setQuickInfoHideZoomLevel(line.split("=").at(1).toInt());

            else if(line.startsWith("QuickInfoCloseXSize="))
                setQuickInfoCloseXSize(line.split("=").at(1).toInt());

            else if(line.startsWith("QuickInfoFullX="))
                setQuickInfoFullX(line.split("=").at(1).toInt());


            else if(line.startsWith("ThumbnailSize="))
                setThumbnailSize(line.split("=").at(1).toInt());

            else if(line.startsWith("ThumbnailPosition="))
                setThumbnailPosition(line.split("=").at(1).trimmed());

            else if(line.startsWith("ThumbnailCache="))
                setThumbnailCache(line.split("=").at(1).toInt());

            else if(line.startsWith("ThumbnailCacheFile="))
                setThumbnailCacheFile(line.split("=").at(1).toInt());

            else if(line.startsWith("ThumbnailSpacingBetween="))
                setThumbnailSpacingBetween(line.split("=").at(1).toInt());

            else if(line.startsWith("ThumbnailLiftUp="))
                setThumbnailLiftUp(line.split("=").at(1).toInt());

            if(line.startsWith("ThumbnailKeepVisible="))
                setThumbnailKeepVisible(line.split("=").at(1).trimmed().toInt());

            else if(line.startsWith("ThumbnailKeepVisibleWhenNotZoomedIn="))
                setThumbnailKeepVisibleWhenNotZoomedIn(line.split("=").at(1).toInt());

            else if(line.startsWith("ThumbnailCenterActive="))
                setThumbnailCenterActive(line.split("=").at(1).toInt());

            else if(line.startsWith("ThumbnailFilenameInstead="))
                setThumbnailFilenameInstead(line.split("=").at(1).toInt());

            else if(line.startsWith("ThumbnailFilenameInsteadFontSize="))
                setThumbnailFilenameInsteadFontSize(line.split("=").at(1).toInt());

            else if(line.startsWith("ThumbnailDisable="))
                setThumbnailDisable(line.split("=").at(1).toInt());

            else if(line.startsWith("ThumbnailWriteFilename="))
                setThumbnailWriteFilename(line.split("=").at(1).toInt());

            else if(line.startsWith("ThumbnailFontSize="))
                setThumbnailFontSize(line.split("=").at(1).toInt());


            else if(line.startsWith("SlideShowTime="))
                setSlideShowTime(line.split("=").at(1).toInt());

            else if(line.startsWith("SlideShowImageTransition="))
                setSlideShowImageTransition(line.split("=").at(1).toInt());

            else if(line.startsWith("SlideShowMusicFile="))
                setSlideShowMusicFile(line.split("=").at(1).trimmed());

            else if(line.startsWith("SlideShowShuffle="))
                setSlideShowShuffle(line.split("=").at(1).toInt());

            else if(line.startsWith("SlideShowLoop="))
                setSlideShowLoop(line.split("=").at(1).toInt());

            else if(line.startsWith("SlideShowHideQuickInfo="))
                setSlideShowHideQuickInfo(line.split("=").at(1).toInt());


            else if(line.startsWith("MetaFilename="))
                setMetaFilename(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaFileType="))
                setMetaFileType(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaFileSize="))
                setMetaFileSize(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaImageNumber="))
                setMetaImageNumber(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaDimensions="))
                setMetaDimensions(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaMake="))
                setMetaMake(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaModel="))
                setMetaModel(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaSoftware="))
                setMetaSoftware(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaTimePhotoTaken="))
                setMetaTimePhotoTaken(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaExposureTime="))
                setMetaExposureTime(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaFlash="))
                setMetaFlash(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaIso="))
                setMetaIso(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaSceneType="))
                setMetaSceneType(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaFLength="))
                setMetaFLength(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaFNumber="))
                setMetaFNumber(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaLightSource="))
                setMetaLightSource(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaGps="))
                setMetaGps(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaKeywords="))
                setMetaKeywords(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaLocation="))
                setMetaLocation(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaCopyright="))
                setMetaCopyright(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaApplyRotation="))
                setMetaApplyRotation(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaGpsMapService="))
                setMetaGpsMapService(line.split("=").at(1).trimmed());

            else if(line.startsWith("MetadataEnableHotEdge="))
                setMetadataEnableHotEdge(line.split("=").at(1).toInt());

            else if(line.startsWith("MetadataFontSize="))
                setMetadataFontSize(line.split("=").at(1).toInt());

            else if(line.startsWith("MetadataOpacity="))
                setMetadataOpacity(line.split("=").at(1).toInt());

            else if(line.startsWith("MetadataWindowWidth="))
                setMetadataWindowWidth(line.split("=").at(1).toInt());


            else if(line.startsWith("PeopleTagInMetaDisplay="))
                setPeopleTagInMetaDisplay(line.split("=").at(1).toInt());

            else if(line.startsWith("PeopleTagInMetaBorderAroundFace="))
                setPeopleTagInMetaBorderAroundFace(line.split("=").at(1).toInt());

            else if(line.startsWith("PeopleTagInMetaBorderAroundFaceColor="))
                setPeopleTagInMetaBorderAroundFaceColor(line.split("=").at(1).trimmed());

            else if(line.startsWith("PeopleTagInMetaBorderAroundFaceWidth="))
                setPeopleTagInMetaBorderAroundFaceWidth(line.split("=").at(1).toInt());

            else if(line.startsWith("PeopleTagInMetaAlwaysVisible="))
                setPeopleTagInMetaAlwaysVisible(line.split("=").at(1).toInt());

            else if(line.startsWith("PeopleTagInMetaIndependentLabels="))
                setPeopleTagInMetaIndependentLabels(line.split("=").at(1).toInt());

            else if(line.startsWith("PeopleTagInMetaHybridMode="))
                setPeopleTagInMetaHybridMode(line.split("=").at(1).toInt());

            else if(line.startsWith("PeopleTagInMetaFontSize="))
                setPeopleTagInMetaFontSize(line.split("=").at(1).toInt());


            else if(line.startsWith("OpenDefaultView="))
                setOpenDefaultView(line.split("=").at(1).trimmed());

            else if(line.startsWith("OpenPreview="))
                setOpenPreview(line.split("=").at(1).toInt());

            else if(line.startsWith("OpenZoomLevel="))
                setOpenZoomLevel(line.split("=").at(1).toInt());

            else if(line.startsWith("OpenUserPlacesWidth="))
                setOpenUserPlacesWidth(line.split("=").at(1).toInt());

            else if(line.startsWith("OpenFoldersWidth="))
                setOpenFoldersWidth(line.split("=").at(1).toInt());

            else if(line.startsWith("OpenThumbnails="))
                setOpenThumbnails(line.split("=").at(1).toInt());

            else if(line.startsWith("OpenPreviewHighQuality="))
                setOpenPreviewHighQuality(line.split("=").at(1).toInt());

            else if(line.startsWith("OpenUserPlacesStandard="))
                setOpenUserPlacesStandard(line.split("=").at(1).toInt());

            else if(line.startsWith("OpenUserPlacesUser="))
                setOpenUserPlacesUser(line.split("=").at(1).toInt());

            else if(line.startsWith("OpenUserPlacesVolumes="))
                setOpenUserPlacesVolumes(line.split("=").at(1).toInt());

            else if(line.startsWith("OpenKeepLastLocation="))
                setOpenKeepLastLocation(line.split("=").at(1).toInt());

            else if(line.startsWith("OpenShowHiddenFilesFolders="))
                setOpenShowHiddenFilesFolders(line.split("=").at(1).toInt());

            else if(line.startsWith("OpenHideUserPlaces="))
                setOpenHideUserPlaces(line.split("=").at(1).toInt());


            else if(line.startsWith("MainMenuWindowWidth="))
                setMainMenuWindowWidth(line.split("=").at(1).toInt());


            else if(line.startsWith("Histogram="))
                setHistogram(line.split("=").at(1).toInt());

            else if(line.startsWith("HistogramVersion="))
                setHistogramVersion(line.split("=").at(1).trimmed());

            else if(line.startsWith("HistogramPosition=")) {
                QStringList parts = line.split("HistogramPosition=").at(1).split(",");
                setHistogramPosition(QPoint(parts.at(0).toInt(), parts.at(1).toInt()));
            }

            else if(line.startsWith("HistogramSize=")) {
                QStringList parts = line.split("HistogramSize=").at(1).split(",");
                setHistogramSize(QSize(parts.at(0).toInt(), parts.at(1).toInt()));
            }

        }

    }

}
