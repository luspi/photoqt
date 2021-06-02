/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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
 
 /* auto-generated using generatesettings.py */

#include "settings.h"

PQSettings::PQSettings() {

    // When saving the settings, we don't want to write the settings file hundreds of time within a few milliseconds,
    // but use a timer to save it once after all settings are set
    saveSettingsTimer = new QTimer;
    saveSettingsTimer->setInterval(400);
    saveSettingsTimer->setSingleShot(true);

    watcher = new QFileSystemWatcher;
    connect(watcher, &QFileSystemWatcher::fileChanged, [this](QString){ readSettings(); });

    watcherAddFileTimer = new QTimer;
    watcherAddFileTimer->setInterval(500);
    watcherAddFileTimer->setSingleShot(true);
    connect(watcherAddFileTimer, &QTimer::timeout, this, &PQSettings::addFileToWatcher);

    setDefault();
    readSettings();

    // we only connect it here so that setting the defaults doesn't accidentally trigger overwriting existing settings
    connect(saveSettingsTimer, &QTimer::timeout, this, &PQSettings::saveSettings);

}

void PQSettings::addFileToWatcher() {

    DBG << CURDATE << "PQSettings::addFileToWatcher()" << NL;

    QFileInfo info(ConfigFiles::SETTINGS_FILE());
    if(!info.exists()) {
        watcherAddFileTimer->start();
        return;
    }
    watcher->removePath(ConfigFiles::SETTINGS_FILE());
    watcher->addPath(ConfigFiles::SETTINGS_FILE());
    
}

void PQSettings::setDefault() {

    DBG << CURDATE << "PQSettings::setDefault()" << NL;
    
    setVersion(QString::fromStdString(VERSION));
    setLanguage(QLocale::system().name());
    setWindowMode(true);
    setWindowDecoration(true);
    setSaveWindowGeometry(false);
    setKeepOnTop(false);
    setStartupLoadLastLoadedImage(false);

    setBackgroundColorAlpha(190);
    setBackgroundColorBlue(0);
    setBackgroundColorGreen(0);
    setBackgroundColorRed(0);
    setBackgroundImageCenter(false);
    setBackgroundImagePath("");
    setBackgroundImageScale(true);
    setBackgroundImageScaleCrop(false);
    setBackgroundImageScreenshot(false);
    setBackgroundImageStretch(false);
    setBackgroundImageTile(false);
    setBackgroundImageUse(false);

    setAnimationDuration(3);
    setAnimationType("opacity");
    setArchiveUseExternalUnrar(false);
    setCloseOnEmptyBackground(false);
    setFitInWindow(false);
    setHotEdgeWidth(4);
    setInterpolationThreshold(100);
    setInterpolationDisableForSmallImages(true);
    setKeepZoomRotationMirror(false);
    setLeftButtonMouseClickAndMove(true);
    setLoopThroughFolder(true);
    setMarginAroundImage(5);
    setMouseWheelSensitivity(1);
    setPdfQuality(150);
    setPixmapCache(512);
    setQuickNavigation(false);
    setShowTransparencyMarkerBackground(false);
    setSortImagesBy("naturalname");
    setSortImagesAscending(true);
    setTrayIcon(0);
    setZoomSpeed(20);

    setLabelsWindowButtonsSize(10);
    setLabelsHideCounter(false);
    setLabelsHideFilepath(true);
    setLabelsHideFilename(false);
    setLabelsWindowButtons(false);
    setLabelsHideZoomLevel(false);
    setLabelsHideRotationAngle(false);
    setLabelsManageWindow(false);

    setThumbnailCache(true);
    setThumbnailCenterActive(false);
    setThumbnailDisable(false);
    setThumbnailFilenameInstead(false);
    setThumbnailFilenameInsteadFontSize(10);
    setThumbnailFontSize(7);
    setThumbnailKeepVisible(false);
    setThumbnailKeepVisibleWhenNotZoomedIn(false);
    setThumbnailLiftUp(6);
    setThumbnailMaxNumberThreads(4);
    setThumbnailPosition("Bottom");
    setThumbnailSize(80);
    setThumbnailSpacingBetween(0);
    setThumbnailWriteFilename(true);

    setSlideShowHideLabels(true);
    setSlideShowImageTransition(4);
    setSlideShowLoop(true);
    setSlideShowMusicFile("");
    setSlideShowShuffle(false);
    setSlideShowTime(5);
    setSlideShowTypeAnimation("opacity");
    setSlideShowIncludeSubFolders(false);

    setMetaApplyRotation(true);
    setMetaCopyright(true);
    setMetaDimensions(true);
    setMetaExposureTime(true);
    setMetaFilename(true);
    setMetaFileType(true);
    setMetaFileSize(true);
    setMetaFlash(true);
    setMetaFLength(true);
    setMetaFNumber(true);
    setMetaGps(true);
    setMetaGpsMapService("openstreetmap.org");
    setMetaImageNumber(true);
    setMetaIso(true);
    setMetaKeywords(true);
    setMetaLightSource(true);
    setMetaLocation(true);
    setMetaMake(true);
    setMetaModel(true);
    setMetaSceneType(true);
    setMetaSoftware(true);
    setMetaTimePhotoTaken(true);

    setMetadataEnableHotEdge(true);
    setMetadataOpacity(220);
    setMetadataWindowWidth(450);

    setPeopleTagInMetaAlwaysVisible(false);
    setPeopleTagInMetaBorderAroundFace(false);
    setPeopleTagInMetaBorderAroundFaceColor("#44ff0000");
    setPeopleTagInMetaBorderAroundFaceWidth(3);
    setPeopleTagInMetaDisplay(true);
    setPeopleTagInMetaFontSize(10);
    setPeopleTagInMetaHybridMode(true);
    setPeopleTagInMetaIndependentLabels(false);

    setOpenDefaultView("list");
    setOpenKeepLastLocation(false);
    setOpenPreview(true);
    setOpenShowHiddenFilesFolders(false);
    setOpenThumbnails(true);
    setOpenUserPlacesStandard(true);
    setOpenUserPlacesUser(true);
    setOpenUserPlacesVolumes(true);
    setOpenUserPlacesWidth(300);
    setOpenZoomLevel(20);

    setHistogram(false);
    setHistogramPosition(QPoint(100,100));
    setHistogramSize(QSize(300,200));
    setHistogramVersion("color");

    setMainMenuWindowWidth(450);

    setVideoAutoplay(true);
    setVideoLoop(false);
    setVideoVolume(100);
    setVideoThumbnailer("ffmpegthumbnailer");

    setMainMenuPopoutElement(false);
    setMetadataPopoutElement(false);
    setHistogramPopoutElement(false);
    setScalePopoutElement(false);
    setOpenPopoutElement(false);
    setOpenPopoutElementKeepOpen(false);
    setSlideShowSettingsPopoutElement(false);
    setSlideShowControlsPopoutElement(false);
    setFileRenamePopoutElement(false);
    setFileDeletePopoutElement(false);
    setAboutPopoutElement(false);
    setImgurPopoutElement(false);
    setWallpaperPopoutElement(false);
    setFilterPopoutElement(false);
    setSettingsManagerPopoutElement(false);
    setFileSaveAsPopoutElement(false);

}

void PQSettings::readSettings() {

    DBG << CURDATE << "PQSettings::readSettings()" << NL;

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
        
            if(line.startsWith("Version="))
                setVersion(line.split("=").at(1).trimmed());

            else if(line.startsWith("Language="))
                setLanguage(line.split("=").at(1).trimmed());

            else if(line.startsWith("WindowMode="))
                setWindowMode(line.split("=").at(1).toInt());

            else if(line.startsWith("WindowDecoration="))
                setWindowDecoration(line.split("=").at(1).toInt());

            else if(line.startsWith("SaveWindowGeometry="))
                setSaveWindowGeometry(line.split("=").at(1).toInt());

            else if(line.startsWith("KeepOnTop="))
                setKeepOnTop(line.split("=").at(1).toInt());

            else if(line.startsWith("StartupLoadLastLoadedImage="))
                setStartupLoadLastLoadedImage(line.split("=").at(1).toInt());


            else if(line.startsWith("BackgroundColorAlpha="))
                setBackgroundColorAlpha(line.split("=").at(1).toInt());

            else if(line.startsWith("BackgroundColorBlue="))
                setBackgroundColorBlue(line.split("=").at(1).toInt());

            else if(line.startsWith("BackgroundColorGreen="))
                setBackgroundColorGreen(line.split("=").at(1).toInt());

            else if(line.startsWith("BackgroundColorRed="))
                setBackgroundColorRed(line.split("=").at(1).toInt());

            else if(line.startsWith("BackgroundImageCenter="))
                setBackgroundImageCenter(line.split("=").at(1).toInt());

            else if(line.startsWith("BackgroundImagePath="))
                setBackgroundImagePath(line.split("=").at(1).toInt());

            else if(line.startsWith("BackgroundImageScale="))
                setBackgroundImageScale(line.split("=").at(1).toInt());

            else if(line.startsWith("BackgroundImageScaleCrop="))
                setBackgroundImageScaleCrop(line.split("=").at(1).toInt());

            else if(line.startsWith("BackgroundImageScreenshot="))
                setBackgroundImageScreenshot(line.split("=").at(1).toInt());

            else if(line.startsWith("BackgroundImageStretch="))
                setBackgroundImageStretch(line.split("=").at(1).toInt());

            else if(line.startsWith("BackgroundImageTile="))
                setBackgroundImageTile(line.split("=").at(1).toInt());

            else if(line.startsWith("BackgroundImageUse="))
                setBackgroundImageUse(line.split("=").at(1).toInt());


            else if(line.startsWith("AnimationDuration="))
                setAnimationDuration(line.split("=").at(1).toInt());

            else if(line.startsWith("AnimationType="))
                setAnimationType(line.split("=").at(1).trimmed());

            else if(line.startsWith("ArchiveUseExternalUnrar="))
                setArchiveUseExternalUnrar(line.split("=").at(1).toInt());

            else if(line.startsWith("CloseOnEmptyBackground="))
                setCloseOnEmptyBackground(line.split("=").at(1).toInt());

            else if(line.startsWith("FitInWindow="))
                setFitInWindow(line.split("=").at(1).toInt());

            else if(line.startsWith("HotEdgeWidth="))
                setHotEdgeWidth(line.split("=").at(1).toInt());

            else if(line.startsWith("InterpolationThreshold="))
                setInterpolationThreshold(line.split("=").at(1).toInt());

            else if(line.startsWith("InterpolationDisableForSmallImages="))
                setInterpolationDisableForSmallImages(line.split("=").at(1).toInt());

            else if(line.startsWith("KeepZoomRotationMirror="))
                setKeepZoomRotationMirror(line.split("=").at(1).toInt());

            else if(line.startsWith("LeftButtonMouseClickAndMove="))
                setLeftButtonMouseClickAndMove(line.split("=").at(1).toInt());

            else if(line.startsWith("LoopThroughFolder="))
                setLoopThroughFolder(line.split("=").at(1).toInt());

            else if(line.startsWith("MarginAroundImage="))
                setMarginAroundImage(line.split("=").at(1).toInt());

            else if(line.startsWith("MouseWheelSensitivity="))
                setMouseWheelSensitivity(line.split("=").at(1).toInt());

            else if(line.startsWith("PdfQuality="))
                setPdfQuality(line.split("=").at(1).toInt());

            else if(line.startsWith("PixmapCache="))
                setPixmapCache(line.split("=").at(1).toInt());

            else if(line.startsWith("QuickNavigation="))
                setQuickNavigation(line.split("=").at(1).toInt());

            else if(line.startsWith("ShowTransparencyMarkerBackground="))
                setShowTransparencyMarkerBackground(line.split("=").at(1).toInt());

            else if(line.startsWith("SortImagesBy="))
                setSortImagesBy(line.split("=").at(1).trimmed());

            else if(line.startsWith("SortImagesAscending="))
                setSortImagesAscending(line.split("=").at(1).toInt());

            else if(line.startsWith("TrayIcon="))
                setTrayIcon(line.split("=").at(1).toInt());

            else if(line.startsWith("ZoomSpeed="))
                setZoomSpeed(line.split("=").at(1).toInt());


            else if(line.startsWith("LabelsWindowButtonsSize="))
                setLabelsWindowButtonsSize(line.split("=").at(1).toInt());

            else if(line.startsWith("LabelsHideCounter="))
                setLabelsHideCounter(line.split("=").at(1).toInt());

            else if(line.startsWith("LabelsHideFilepath="))
                setLabelsHideFilepath(line.split("=").at(1).toInt());

            else if(line.startsWith("LabelsHideFilename="))
                setLabelsHideFilename(line.split("=").at(1).toInt());

            else if(line.startsWith("LabelsWindowButtons="))
                setLabelsWindowButtons(line.split("=").at(1).toInt());

            else if(line.startsWith("LabelsHideZoomLevel="))
                setLabelsHideZoomLevel(line.split("=").at(1).toInt());

            else if(line.startsWith("LabelsHideRotationAngle="))
                setLabelsHideRotationAngle(line.split("=").at(1).toInt());

            else if(line.startsWith("LabelsManageWindow="))
                setLabelsManageWindow(line.split("=").at(1).toInt());


            else if(line.startsWith("ThumbnailCache="))
                setThumbnailCache(line.split("=").at(1).toInt());

            else if(line.startsWith("ThumbnailCenterActive="))
                setThumbnailCenterActive(line.split("=").at(1).toInt());

            else if(line.startsWith("ThumbnailDisable="))
                setThumbnailDisable(line.split("=").at(1).toInt());

            else if(line.startsWith("ThumbnailFilenameInstead="))
                setThumbnailFilenameInstead(line.split("=").at(1).toInt());

            else if(line.startsWith("ThumbnailFilenameInsteadFontSize="))
                setThumbnailFilenameInsteadFontSize(line.split("=").at(1).toInt());

            else if(line.startsWith("ThumbnailFontSize="))
                setThumbnailFontSize(line.split("=").at(1).toInt());

            else if(line.startsWith("ThumbnailKeepVisible="))
                setThumbnailKeepVisible(line.split("=").at(1).toInt());

            else if(line.startsWith("ThumbnailKeepVisibleWhenNotZoomedIn="))
                setThumbnailKeepVisibleWhenNotZoomedIn(line.split("=").at(1).toInt());

            else if(line.startsWith("ThumbnailLiftUp="))
                setThumbnailLiftUp(line.split("=").at(1).toInt());

            else if(line.startsWith("ThumbnailMaxNumberThreads="))
                setThumbnailMaxNumberThreads(line.split("=").at(1).toInt());

            else if(line.startsWith("ThumbnailPosition="))
                setThumbnailPosition(line.split("=").at(1).trimmed());

            else if(line.startsWith("ThumbnailSize="))
                setThumbnailSize(line.split("=").at(1).toInt());

            else if(line.startsWith("ThumbnailSpacingBetween="))
                setThumbnailSpacingBetween(line.split("=").at(1).toInt());

            else if(line.startsWith("ThumbnailWriteFilename="))
                setThumbnailWriteFilename(line.split("=").at(1).toInt());


            else if(line.startsWith("SlideShowHideLabels="))
                setSlideShowHideLabels(line.split("=").at(1).toInt());

            else if(line.startsWith("SlideShowImageTransition="))
                setSlideShowImageTransition(line.split("=").at(1).toInt());

            else if(line.startsWith("SlideShowLoop="))
                setSlideShowLoop(line.split("=").at(1).toInt());

            else if(line.startsWith("SlideShowMusicFile="))
                setSlideShowMusicFile(line.split("=").at(1).trimmed());

            else if(line.startsWith("SlideShowShuffle="))
                setSlideShowShuffle(line.split("=").at(1).toInt());

            else if(line.startsWith("SlideShowTime="))
                setSlideShowTime(line.split("=").at(1).toInt());

            else if(line.startsWith("SlideShowTypeAnimation="))
                setSlideShowTypeAnimation(line.split("=").at(1).trimmed());

            else if(line.startsWith("SlideShowIncludeSubFolders="))
                setSlideShowIncludeSubFolders(line.split("=").at(1).toInt());


            else if(line.startsWith("MetaApplyRotation="))
                setMetaApplyRotation(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaCopyright="))
                setMetaCopyright(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaDimensions="))
                setMetaDimensions(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaExposureTime="))
                setMetaExposureTime(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaFilename="))
                setMetaFilename(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaFileType="))
                setMetaFileType(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaFileSize="))
                setMetaFileSize(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaFlash="))
                setMetaFlash(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaFLength="))
                setMetaFLength(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaFNumber="))
                setMetaFNumber(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaGps="))
                setMetaGps(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaGpsMapService="))
                setMetaGpsMapService(line.split("=").at(1).trimmed());

            else if(line.startsWith("MetaImageNumber="))
                setMetaImageNumber(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaIso="))
                setMetaIso(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaKeywords="))
                setMetaKeywords(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaLightSource="))
                setMetaLightSource(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaLocation="))
                setMetaLocation(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaMake="))
                setMetaMake(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaModel="))
                setMetaModel(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaSceneType="))
                setMetaSceneType(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaSoftware="))
                setMetaSoftware(line.split("=").at(1).toInt());

            else if(line.startsWith("MetaTimePhotoTaken="))
                setMetaTimePhotoTaken(line.split("=").at(1).toInt());


            else if(line.startsWith("MetadataEnableHotEdge="))
                setMetadataEnableHotEdge(line.split("=").at(1).toInt());

            else if(line.startsWith("MetadataOpacity="))
                setMetadataOpacity(line.split("=").at(1).toInt());

            else if(line.startsWith("MetadataWindowWidth="))
                setMetadataWindowWidth(line.split("=").at(1).toInt());


            else if(line.startsWith("PeopleTagInMetaAlwaysVisible="))
                setPeopleTagInMetaAlwaysVisible(line.split("=").at(1).toInt());

            else if(line.startsWith("PeopleTagInMetaBorderAroundFace="))
                setPeopleTagInMetaBorderAroundFace(line.split("=").at(1).toInt());

            else if(line.startsWith("PeopleTagInMetaBorderAroundFaceColor="))
                setPeopleTagInMetaBorderAroundFaceColor(line.split("=").at(1).trimmed());

            else if(line.startsWith("PeopleTagInMetaBorderAroundFaceWidth="))
                setPeopleTagInMetaBorderAroundFaceWidth(line.split("=").at(1).toInt());

            else if(line.startsWith("PeopleTagInMetaDisplay="))
                setPeopleTagInMetaDisplay(line.split("=").at(1).toInt());

            else if(line.startsWith("PeopleTagInMetaFontSize="))
                setPeopleTagInMetaFontSize(line.split("=").at(1).toInt());

            else if(line.startsWith("PeopleTagInMetaHybridMode="))
                setPeopleTagInMetaHybridMode(line.split("=").at(1).toInt());

            else if(line.startsWith("PeopleTagInMetaIndependentLabels="))
                setPeopleTagInMetaIndependentLabels(line.split("=").at(1).toInt());


            else if(line.startsWith("OpenDefaultView="))
                setOpenDefaultView(line.split("=").at(1).trimmed());

            else if(line.startsWith("OpenKeepLastLocation="))
                setOpenKeepLastLocation(line.split("=").at(1).toInt());

            else if(line.startsWith("OpenPreview="))
                setOpenPreview(line.split("=").at(1).toInt());

            else if(line.startsWith("OpenShowHiddenFilesFolders="))
                setOpenShowHiddenFilesFolders(line.split("=").at(1).toInt());

            else if(line.startsWith("OpenThumbnails="))
                setOpenThumbnails(line.split("=").at(1).toInt());

            else if(line.startsWith("OpenUserPlacesStandard="))
                setOpenUserPlacesStandard(line.split("=").at(1).toInt());

            else if(line.startsWith("OpenUserPlacesUser="))
                setOpenUserPlacesUser(line.split("=").at(1).toInt());

            else if(line.startsWith("OpenUserPlacesVolumes="))
                setOpenUserPlacesVolumes(line.split("=").at(1).toInt());

            else if(line.startsWith("OpenUserPlacesWidth="))
                setOpenUserPlacesWidth(line.split("=").at(1).toInt());

            else if(line.startsWith("OpenZoomLevel="))
                setOpenZoomLevel(line.split("=").at(1).toInt());


            else if(line.startsWith("Histogram="))
                setHistogram(line.split("=").at(1).toInt());

            else if(line.startsWith("HistogramPosition=")) {
                QStringList parts = line.split("HistogramPosition=").at(1).split(",");
                setHistogramPosition(QPoint(parts.at(0).toInt(), parts.at(1).toInt()));
            }

            else if(line.startsWith("HistogramSize=")) {
                QStringList parts = line.split("HistogramSize=").at(1).split(",");
                setHistogramSize(QSize(parts.at(0).toInt(), parts.at(1).toInt()));
            }

            else if(line.startsWith("HistogramVersion="))
                setHistogramVersion(line.split("=").at(1).trimmed());


            else if(line.startsWith("MainMenuWindowWidth="))
                setMainMenuWindowWidth(line.split("=").at(1).toInt());


            else if(line.startsWith("VideoAutoplay="))
                setVideoAutoplay(line.split("=").at(1).toInt());

            else if(line.startsWith("VideoLoop="))
                setVideoLoop(line.split("=").at(1).toInt());

            else if(line.startsWith("VideoVolume="))
                setVideoVolume(line.split("=").at(1).toInt());

            else if(line.startsWith("VideoThumbnailer="))
                setVideoThumbnailer(line.split("=").at(1).trimmed());


            else if(line.startsWith("MainMenuPopoutElement="))
                setMainMenuPopoutElement(line.split("=").at(1).toInt());

            else if(line.startsWith("MetadataPopoutElement="))
                setMetadataPopoutElement(line.split("=").at(1).toInt());

            else if(line.startsWith("HistogramPopoutElement="))
                setHistogramPopoutElement(line.split("=").at(1).toInt());

            else if(line.startsWith("ScalePopoutElement="))
                setScalePopoutElement(line.split("=").at(1).toInt());

            else if(line.startsWith("OpenPopoutElement="))
                setOpenPopoutElement(line.split("=").at(1).toInt());

            else if(line.startsWith("OpenPopoutElementKeepOpen="))
                setOpenPopoutElementKeepOpen(line.split("=").at(1).toInt());

            else if(line.startsWith("SlideShowSettingsPopoutElement="))
                setSlideShowSettingsPopoutElement(line.split("=").at(1).toInt());

            else if(line.startsWith("SlideShowControlsPopoutElement="))
                setSlideShowControlsPopoutElement(line.split("=").at(1).toInt());

            else if(line.startsWith("FileRenamePopoutElement="))
                setFileRenamePopoutElement(line.split("=").at(1).toInt());

            else if(line.startsWith("FileDeletePopoutElement="))
                setFileDeletePopoutElement(line.split("=").at(1).toInt());

            else if(line.startsWith("AboutPopoutElement="))
                setAboutPopoutElement(line.split("=").at(1).toInt());

            else if(line.startsWith("ImgurPopoutElement="))
                setImgurPopoutElement(line.split("=").at(1).toInt());

            else if(line.startsWith("WallpaperPopoutElement="))
                setWallpaperPopoutElement(line.split("=").at(1).toInt());

            else if(line.startsWith("FilterPopoutElement="))
                setFilterPopoutElement(line.split("=").at(1).toInt());

            else if(line.startsWith("SettingsManagerPopoutElement="))
                setSettingsManagerPopoutElement(line.split("=").at(1).toInt());

            else if(line.startsWith("FileSaveAsPopoutElement="))
                setFileSaveAsPopoutElement(line.split("=").at(1).toInt());


        }

    }

}


// Save settings
void PQSettings::saveSettings() {

    DBG << CURDATE << "PQSettings::saveSettings()" << NL;

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

        QString cont = QString("Version=%1\n").arg(m_version);
        cont += QString("Language=%1\n").arg(m_language);
        cont += QString("WindowMode=%1\n").arg(int(m_windowMode));
        cont += QString("WindowDecoration=%1\n").arg(int(m_windowDecoration));
        cont += QString("SaveWindowGeometry=%1\n").arg(int(m_saveWindowGeometry));
        cont += QString("KeepOnTop=%1\n").arg(int(m_keepOnTop));
        cont += QString("StartupLoadLastLoadedImage=%1\n").arg(int(m_startupLoadLastLoadedImage));

        cont += "\n[Look]\n";

        cont += QString("BackgroundColorAlpha=%1\n").arg(m_backgroundColorAlpha);
        cont += QString("BackgroundColorBlue=%1\n").arg(m_backgroundColorBlue);
        cont += QString("BackgroundColorGreen=%1\n").arg(m_backgroundColorGreen);
        cont += QString("BackgroundColorRed=%1\n").arg(m_backgroundColorRed);
        cont += QString("BackgroundImageCenter=%1\n").arg(int(m_backgroundImageCenter));
        cont += QString("BackgroundImagePath=%1\n").arg(int(m_backgroundImagePath));
        cont += QString("BackgroundImageScale=%1\n").arg(int(m_backgroundImageScale));
        cont += QString("BackgroundImageScaleCrop=%1\n").arg(int(m_backgroundImageScaleCrop));
        cont += QString("BackgroundImageScreenshot=%1\n").arg(int(m_backgroundImageScreenshot));
        cont += QString("BackgroundImageStretch=%1\n").arg(int(m_backgroundImageStretch));
        cont += QString("BackgroundImageTile=%1\n").arg(int(m_backgroundImageTile));
        cont += QString("BackgroundImageUse=%1\n").arg(int(m_backgroundImageUse));

        cont += "\n[Behaviour]\n";

        cont += QString("AnimationDuration=%1\n").arg(m_animationDuration);
        cont += QString("AnimationType=%1\n").arg(m_animationType);
        cont += QString("ArchiveUseExternalUnrar=%1\n").arg(int(m_archiveUseExternalUnrar));
        cont += QString("CloseOnEmptyBackground=%1\n").arg(int(m_closeOnEmptyBackground));
        cont += QString("FitInWindow=%1\n").arg(int(m_fitInWindow));
        cont += QString("HotEdgeWidth=%1\n").arg(m_hotEdgeWidth);
        cont += QString("InterpolationThreshold=%1\n").arg(m_interpolationThreshold);
        cont += QString("InterpolationDisableForSmallImages=%1\n").arg(int(m_interpolationDisableForSmallImages));
        cont += QString("KeepZoomRotationMirror=%1\n").arg(int(m_keepZoomRotationMirror));
        cont += QString("LeftButtonMouseClickAndMove=%1\n").arg(int(m_leftButtonMouseClickAndMove));
        cont += QString("LoopThroughFolder=%1\n").arg(int(m_loopThroughFolder));
        cont += QString("MarginAroundImage=%1\n").arg(m_marginAroundImage);
        cont += QString("MouseWheelSensitivity=%1\n").arg(m_mouseWheelSensitivity);
        cont += QString("PdfQuality=%1\n").arg(m_pdfQuality);
        cont += QString("PixmapCache=%1\n").arg(int(m_pixmapCache));
        cont += QString("QuickNavigation=%1\n").arg(int(m_quickNavigation));
        cont += QString("ShowTransparencyMarkerBackground=%1\n").arg(int(m_showTransparencyMarkerBackground));
        cont += QString("SortImagesBy=%1\n").arg(m_sortImagesBy);
        cont += QString("SortImagesAscending=%1\n").arg(int(m_sortImagesAscending));
        cont += QString("TrayIcon=%1\n").arg(m_trayIcon);
        cont += QString("ZoomSpeed=%1\n").arg(m_zoomSpeed);

        cont += "\n[Labels]\n";

        cont += QString("LabelsWindowButtonsSize=%1\n").arg(m_labelsWindowButtonsSize);
        cont += QString("LabelsHideCounter=%1\n").arg(int(m_labelsHideCounter));
        cont += QString("LabelsHideFilepath=%1\n").arg(int(m_labelsHideFilepath));
        cont += QString("LabelsHideFilename=%1\n").arg(int(m_labelsHideFilename));
        cont += QString("LabelsWindowButtons=%1\n").arg(int(m_labelsWindowButtons));
        cont += QString("LabelsHideZoomLevel=%1\n").arg(int(m_labelsHideZoomLevel));
        cont += QString("LabelsHideRotationAngle=%1\n").arg(int(m_labelsHideRotationAngle));
        cont += QString("LabelsManageWindow=%1\n").arg(int(m_labelsManageWindow));

        cont += "\n[Thumbnail]\n";

        cont += QString("ThumbnailCache=%1\n").arg(int(m_thumbnailCache));
        cont += QString("ThumbnailCenterActive=%1\n").arg(int(m_thumbnailCenterActive));
        cont += QString("ThumbnailDisable=%1\n").arg(int(m_thumbnailDisable));
        cont += QString("ThumbnailFilenameInstead=%1\n").arg(int(m_thumbnailFilenameInstead));
        cont += QString("ThumbnailFilenameInsteadFontSize=%1\n").arg(m_thumbnailFilenameInsteadFontSize);
        cont += QString("ThumbnailFontSize=%1\n").arg(m_thumbnailFontSize);
        cont += QString("ThumbnailKeepVisible=%1\n").arg(int(m_thumbnailKeepVisible));
        cont += QString("ThumbnailKeepVisibleWhenNotZoomedIn=%1\n").arg(int(m_thumbnailKeepVisibleWhenNotZoomedIn));
        cont += QString("ThumbnailLiftUp=%1\n").arg(m_thumbnailLiftUp);
        cont += QString("ThumbnailMaxNumberThreads=%1\n").arg(m_thumbnailMaxNumberThreads);
        cont += QString("ThumbnailPosition=%1\n").arg(m_thumbnailPosition);
        cont += QString("ThumbnailSize=%1\n").arg(m_thumbnailSize);
        cont += QString("ThumbnailSpacingBetween=%1\n").arg(m_thumbnailSpacingBetween);
        cont += QString("ThumbnailWriteFilename=%1\n").arg(int(m_thumbnailWriteFilename));

        cont += "\n[Slideshow]\n";

        cont += QString("SlideShowHideLabels=%1\n").arg(int(m_slideShowHideLabels));
        cont += QString("SlideShowImageTransition=%1\n").arg(m_slideShowImageTransition);
        cont += QString("SlideShowLoop=%1\n").arg(int(m_slideShowLoop));
        cont += QString("SlideShowMusicFile=%1\n").arg(m_slideShowMusicFile);
        cont += QString("SlideShowShuffle=%1\n").arg(int(m_slideShowShuffle));
        cont += QString("SlideShowTime=%1\n").arg(m_slideShowTime);
        cont += QString("SlideShowTypeAnimation=%1\n").arg(m_slideShowTypeAnimation);
        cont += QString("SlideShowIncludeSubFolders=%1\n").arg(int(m_slideShowIncludeSubFolders));

        cont += "\n[Metadata]\n";

        cont += QString("MetaApplyRotation=%1\n").arg(int(m_metaApplyRotation));
        cont += QString("MetaCopyright=%1\n").arg(int(m_metaCopyright));
        cont += QString("MetaDimensions=%1\n").arg(int(m_metaDimensions));
        cont += QString("MetaExposureTime=%1\n").arg(int(m_metaExposureTime));
        cont += QString("MetaFilename=%1\n").arg(int(m_metaFilename));
        cont += QString("MetaFileType=%1\n").arg(int(m_metaFileType));
        cont += QString("MetaFileSize=%1\n").arg(int(m_metaFileSize));
        cont += QString("MetaFlash=%1\n").arg(int(m_metaFlash));
        cont += QString("MetaFLength=%1\n").arg(int(m_metaFLength));
        cont += QString("MetaFNumber=%1\n").arg(int(m_metaFNumber));
        cont += QString("MetaGps=%1\n").arg(int(m_metaGps));
        cont += QString("MetaGpsMapService=%1\n").arg(m_metaGpsMapService);
        cont += QString("MetaImageNumber=%1\n").arg(int(m_metaImageNumber));
        cont += QString("MetaIso=%1\n").arg(int(m_metaIso));
        cont += QString("MetaKeywords=%1\n").arg(int(m_metaKeywords));
        cont += QString("MetaLightSource=%1\n").arg(int(m_metaLightSource));
        cont += QString("MetaLocation=%1\n").arg(int(m_metaLocation));
        cont += QString("MetaMake=%1\n").arg(int(m_metaMake));
        cont += QString("MetaModel=%1\n").arg(int(m_metaModel));
        cont += QString("MetaSceneType=%1\n").arg(int(m_metaSceneType));
        cont += QString("MetaSoftware=%1\n").arg(int(m_metaSoftware));
        cont += QString("MetaTimePhotoTaken=%1\n").arg(int(m_metaTimePhotoTaken));

        cont += "\n[Metadata Element]\n";

        cont += QString("MetadataEnableHotEdge=%1\n").arg(int(m_metadataEnableHotEdge));
        cont += QString("MetadataOpacity=%1\n").arg(m_metadataOpacity);
        cont += QString("MetadataWindowWidth=%1\n").arg(m_metadataWindowWidth);

        cont += "\n[People Tags in Metadata]\n";

        cont += QString("PeopleTagInMetaAlwaysVisible=%1\n").arg(int(m_peopleTagInMetaAlwaysVisible));
        cont += QString("PeopleTagInMetaBorderAroundFace=%1\n").arg(int(m_peopleTagInMetaBorderAroundFace));
        cont += QString("PeopleTagInMetaBorderAroundFaceColor=%1\n").arg(m_peopleTagInMetaBorderAroundFaceColor);
        cont += QString("PeopleTagInMetaBorderAroundFaceWidth=%1\n").arg(m_peopleTagInMetaBorderAroundFaceWidth);
        cont += QString("PeopleTagInMetaDisplay=%1\n").arg(int(m_peopleTagInMetaDisplay));
        cont += QString("PeopleTagInMetaFontSize=%1\n").arg(m_peopleTagInMetaFontSize);
        cont += QString("PeopleTagInMetaHybridMode=%1\n").arg(int(m_peopleTagInMetaHybridMode));
        cont += QString("PeopleTagInMetaIndependentLabels=%1\n").arg(int(m_peopleTagInMetaIndependentLabels));

        cont += "\n[Open File]\n";

        cont += QString("OpenDefaultView=%1\n").arg(m_openDefaultView);
        cont += QString("OpenKeepLastLocation=%1\n").arg(int(m_openKeepLastLocation));
        cont += QString("OpenPreview=%1\n").arg(int(m_openPreview));
        cont += QString("OpenShowHiddenFilesFolders=%1\n").arg(int(m_openShowHiddenFilesFolders));
        cont += QString("OpenThumbnails=%1\n").arg(int(m_openThumbnails));
        cont += QString("OpenUserPlacesStandard=%1\n").arg(int(m_openUserPlacesStandard));
        cont += QString("OpenUserPlacesUser=%1\n").arg(int(m_openUserPlacesUser));
        cont += QString("OpenUserPlacesVolumes=%1\n").arg(int(m_openUserPlacesVolumes));
        cont += QString("OpenUserPlacesWidth=%1\n").arg(m_openUserPlacesWidth);
        cont += QString("OpenZoomLevel=%1\n").arg(m_openZoomLevel);

        cont += "\n[Histogram]\n";

        cont += QString("Histogram=%1\n").arg(int(m_histogram));
        cont += QString("HistogramPosition=%1,%2\n").arg(m_histogramPosition.x()).arg(m_histogramPosition.y());
        cont += QString("HistogramSize=%1,%2\n").arg(m_histogramSize.width()).arg(m_histogramSize.height());
        cont += QString("HistogramVersion=%1\n").arg(m_histogramVersion);

        cont += "\n[Main Menu Element]\n";

        cont += QString("MainMenuWindowWidth=%1\n").arg(m_mainMenuWindowWidth);

        cont += "\n[Video]\n";

        cont += QString("VideoAutoplay=%1\n").arg(int(m_videoAutoplay));
        cont += QString("VideoLoop=%1\n").arg(int(m_videoLoop));
        cont += QString("VideoVolume=%1\n").arg(m_videoVolume);
        cont += QString("VideoThumbnailer=%1\n").arg(m_videoThumbnailer);

        cont += "\n[Popout]\n";

        cont += QString("MainMenuPopoutElement=%1\n").arg(int(m_mainMenuPopoutElement));
        cont += QString("MetadataPopoutElement=%1\n").arg(int(m_metadataPopoutElement));
        cont += QString("HistogramPopoutElement=%1\n").arg(int(m_histogramPopoutElement));
        cont += QString("ScalePopoutElement=%1\n").arg(int(m_scalePopoutElement));
        cont += QString("OpenPopoutElement=%1\n").arg(int(m_openPopoutElement));
        cont += QString("OpenPopoutElementKeepOpen=%1\n").arg(int(m_openPopoutElementKeepOpen));
        cont += QString("SlideShowSettingsPopoutElement=%1\n").arg(int(m_slideShowSettingsPopoutElement));
        cont += QString("SlideShowControlsPopoutElement=%1\n").arg(int(m_slideShowControlsPopoutElement));
        cont += QString("FileRenamePopoutElement=%1\n").arg(int(m_fileRenamePopoutElement));
        cont += QString("FileDeletePopoutElement=%1\n").arg(int(m_fileDeletePopoutElement));
        cont += QString("AboutPopoutElement=%1\n").arg(int(m_aboutPopoutElement));
        cont += QString("ImgurPopoutElement=%1\n").arg(int(m_imgurPopoutElement));
        cont += QString("WallpaperPopoutElement=%1\n").arg(int(m_wallpaperPopoutElement));
        cont += QString("FilterPopoutElement=%1\n").arg(int(m_filterPopoutElement));
        cont += QString("SettingsManagerPopoutElement=%1\n").arg(int(m_settingsManagerPopoutElement));
        cont += QString("FileSaveAsPopoutElement=%1\n").arg(int(m_fileSaveAsPopoutElement));

        out << cont;
        file.close();

    }

}
