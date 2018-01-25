/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#ifndef SETTINGS_H
#define SETTINGS_H

#include "../logger.h"

#include <iostream>
#include <thread>
#include <QObject>
#include <QSettings>
#include <QDir>
#include <QFileSystemWatcher>
#include <QTimer>
#include <QTextStream>
#include <QPoint>
#include <QSize>
#ifdef Q_OS_WIN
#include <QtWinExtras/QtWin>
#endif

// Convenience class to access and change permanent settings

class Settings : public QObject {

    Q_OBJECT

public:
    explicit Settings(QObject *parent = 0) : QObject(parent) {

        // When saving the settings, we don't want to write the settings file hundreds of time within a few milliseconds,
        // but use a timer to save it once after all settings are set
        saveSettingsTimer = new QTimer;
        saveSettingsTimer->setInterval(400);
        saveSettingsTimer->setSingleShot(true);
        connect(saveSettingsTimer, SIGNAL(timeout()), this, SLOT(saveSettings()));

        watcher = new QFileSystemWatcher;
        connect(watcher, &QFileSystemWatcher::fileChanged, [this](QString){ readSettings(); });

        watcherAddFileTimer = new QTimer;
        watcherAddFileTimer->setInterval(500);
        watcherAddFileTimer->setSingleShot(true);
        connect(watcherAddFileTimer, &QTimer::timeout, this, &Settings::addFileToWatcher);

        setDefault();
        readSettings();

    }

    // CLean-up
    ~Settings() {
        delete saveSettingsTimer;
    }

private slots:
    void addFileToWatcher() {
        QFileInfo info(ConfigFiles::SETTINGS_FILE());
        if(!info.exists()) {
            watcherAddFileTimer->start();
            return;
        }
        watcher->removePath(ConfigFiles::SETTINGS_FILE());
        watcher->addPath(ConfigFiles::SETTINGS_FILE());
    }

private:

    QTimer *saveSettingsTimer;
    QFileSystemWatcher *watcher;
    QTimer *watcherAddFileTimer;

    /*#################################################################################################*/
    /*#################################################################################################*/

    /************
     * ELEMENTS *
     ************/

    QString m_version;
    QString m_versionInTextFile;  // differs from 'version' only when PhotoQt has been updated
    QString m_language;
    bool    m_animations;
    bool    m_saveWindowGeometry;
    bool    m_keepOnTop;
    bool    m_composite;
    bool    m_startupLoadLastLoadedImage;

    int     m_backgroundColorRed;
    int     m_backgroundColorGreen;
    int     m_backgroundColorBlue;
    int     m_backgroundColorAlpha;
    bool    m_backgroundImageScreenshot;
    bool    m_backgroundImageUse;
    QString m_backgroundImagePath;
    bool    m_backgroundImageScale;
    bool    m_backgroundImageScaleCrop;
    bool    m_backgroundImageStretch;
    bool    m_backgroundImageCenter;
    bool    m_backgroundImageTile;

    int     m_trayIcon;
    int     m_imageTransition;
    bool    m_loopThroughFolder;
    int     m_hotEdgeWidth;
    bool    m_closeOnEmptyBackground;
    int     m_marginAroundImage;
    QString m_sortby;
    bool    m_sortbyAscending;
    int     m_mouseWheelSensitivity;
    bool    m_keepZoomRotationMirror;
    bool    m_fitInWindow;
    int     m_interpolationNearestNeighbourThreshold;
    bool    m_interpolationNearestNeighbourUpscale;
    int     m_pixmapCache;
    bool    m_showTransparencyMarkerBackground;
    bool    m_leftButtonMouseClickAndMove;

    bool    m_quickInfoHideCounter;
    bool    m_quickInfoHideFilepath;
    bool    m_quickInfoHideFilename;
    bool    m_quickInfoHideX;
    bool    m_quickInfoFullX;
    int     m_quickInfoCloseXSize;

    int     m_slideShowTime;
    int     m_slideShowImageTransition;
    QString m_slideShowMusicFile;
    bool    m_slideShowShuffle;
    bool    m_slideShowLoop;
    bool    m_slideShowHideQuickInfo;

    int     m_thumbnailSize;
    QString m_thumbnailPosition;
    bool    m_thumbnailCache;
    bool    m_thumbnailCacheFile;
    int     m_thumbnailSpacingBetween;
    int     m_thumbnailLiftUp;
    bool    m_thumbnailKeepVisible;
    bool    m_thumbnailKeepVisibleWhenNotZoomedIn;
    bool    m_thumbnailCenterActive;
    bool    m_thumbnailFilenameInstead;
    int     m_thumbnailFilenameInsteadFontSize;
    bool    m_thumbnailDisable;
    bool    m_thumbnailWriteFilename;
    int     m_thumbnailFontSize;

    bool    m_windowMode;
    bool    m_windowDecoration;

    bool    m_metadataEnableHotEdge;
    bool    m_metaApplyRotation;
    QString m_metaGpsMapService;
    int     m_metadataFontSize;
    int     m_metadataOpacity;
    bool    m_metaFilename;
    bool    m_metaFileType;
    bool    m_metaFileSize;
    bool    m_metaImageNumber;
    bool    m_metaDimensions;
    bool    m_metaMake;
    bool    m_metaModel;
    bool    m_metaSoftware;
    bool    m_metaTimePhotoTaken;
    bool    m_metaExposureTime;
    bool    m_metaFlash;
    bool    m_metaIso;
    bool    m_metaSceneType;
    bool    m_metaFLength;
    bool    m_metaFNumber;
    bool    m_metaLightSource;
    bool    m_metaKeywords;
    bool    m_metaLocation;
    bool    m_metaCopyright;
    bool    m_metaGps;

    QString m_openDefaultView;
    bool    m_openPreview;
    int     m_openZoomLevel;
    int     m_openUserPlacesWidth;
    int     m_openFoldersWidth;
    bool    m_openThumbnails;
    bool    m_openPreviewHighQuality;
    bool    m_openUserPlacesStandard;
    bool    m_openUserPlacesUser;
    bool    m_openUserPlacesVolumes;
    bool    m_openKeepLastLocation;
    bool    m_openShowHiddenFilesFolders;
    bool    m_openHideUserPlaces;

    int     m_metadataWindowWidth;
    int     m_mainMenuWindowWidth;

    bool    m_histogram;
    QPoint  m_histogramPosition;
    QSize   m_histogramSize;
    QString m_histogramVersion;


    /*#################################################################################################*/
    /*#################################################################################################*/

public:
    /**********************
     * Q_PROPERTY methods *
     **********************/

    // version
    Q_PROPERTY(QString version
               READ    getVersion
               WRITE   setVersion
               NOTIFY  versionChanged)
    QString getVersion() { return m_version; }
    void    setVersion(QString val) { if(val != m_version) { m_version = val;
                                                             emit versionChanged(val);
                                                             saveSettingsTimer->start(); } }

    QString getVersionInTextFile() { return m_versionInTextFile; }

    // language
    Q_PROPERTY(QString language
               READ    getLanguage
               WRITE   setLanguage
               NOTIFY  languageChanged)
    QString getLanguage() { return m_language; }
    void    setLanguage(QString val) { if(val != m_language) { m_language = val;
                                                               emit languageChanged(val);
                                                               saveSettingsTimer->start(); } }

    // animations
    Q_PROPERTY(bool   animations
               READ   getAnimations
               WRITE  setAnimations
               NOTIFY animationsChanged)
    bool getAnimations() { return m_animations; }
    void setAnimations(bool val) { if(val != m_animations) { m_animations = val;
                                                             emit animationsChanged(val);
                                                             saveSettingsTimer->start(); } }

    // saveWindowGeometry
    Q_PROPERTY(bool   saveWindowGeometry
               READ   getSaveWindowGeometry
               WRITE  setSaveWindowGeometry
               NOTIFY saveWindowGeometryChanged)
    bool getSaveWindowGeometry() { return m_saveWindowGeometry; }
    void setSaveWindowGeometry(bool val) { if(val != m_saveWindowGeometry) { m_saveWindowGeometry = val;
                                                                             emit saveWindowGeometryChanged(val);
                                                                             saveSettingsTimer->start(); } }

    // keepOnTop
    Q_PROPERTY(bool   keepOnTop
               READ   getKeepOnTop
               WRITE  setKeepOnTop
               NOTIFY keepOnTopChanged)
    bool getKeepOnTop() { return m_keepOnTop; }
    void setKeepOnTop(bool val) { if(val != m_keepOnTop) { m_keepOnTop = val;
                                                           emit keepOnTopChanged(val);
                                                           saveSettingsTimer->start(); } }

    // composite
    Q_PROPERTY(bool   composite
               READ   getComposite
               WRITE  setComposite
               NOTIFY compositeChanged)
    bool getComposite() { return m_composite; }
    void setComposite(bool val) { if(val != m_composite) { m_composite = val;
                                                           emit compositeChanged(val);
                                                           saveSettingsTimer->start(); } }

    // startupLoadLastLoadedImage
    Q_PROPERTY(bool   startupLoadLastLoadedImage
               READ   getStartupLoadLastLoadedImage
               WRITE  setStartupLoadLastLoadedImage
               NOTIFY startupLoadLastLoadedImageChanged)
    bool getStartupLoadLastLoadedImage() { return m_startupLoadLastLoadedImage; }
    void setStartupLoadLastLoadedImage(bool val) { if(val != m_startupLoadLastLoadedImage) { m_startupLoadLastLoadedImage = val;
                                                                                             emit startupLoadLastLoadedImageChanged(val);
                                                                                             saveSettingsTimer->start(); } }

    // backgroundColorRed
    Q_PROPERTY(int    backgroundColorRed
               READ   getBackgroundColorRed
               WRITE  setBackgroundColorRed
               NOTIFY backgroundColorRedChanged)
    int  getBackgroundColorRed() { return m_backgroundColorRed; }
    void setBackgroundColorRed(int val) { if(val != m_backgroundColorRed) { m_backgroundColorRed = val;
                                                                            emit backgroundColorRedChanged(val);
                                                                            saveSettingsTimer->start(); } }

    // backgroundColorGreen
    Q_PROPERTY(int    backgroundColorGreen
               READ   getBackgroundColorGreen
               WRITE  setBackgroundColorGreen
               NOTIFY backgroundColorGreenChanged)
    int  getBackgroundColorGreen() { return m_backgroundColorGreen; }
    void setBackgroundColorGreen(int val) { if(val != m_backgroundColorGreen) { m_backgroundColorGreen = val;
                                                                                emit backgroundColorGreenChanged(val);
                                                                                saveSettingsTimer->start(); } }

    // backgroundColorBlue
    Q_PROPERTY(int    backgroundColorBlue
               READ   getBackgroundColorBlue
               WRITE  setBackgroundColorBlue
               NOTIFY backgroundColorBlueChanged)
    int  getBackgroundColorBlue() { return m_backgroundColorBlue; }
    void setBackgroundColorBlue(int val) { if(val != m_backgroundColorBlue) { m_backgroundColorBlue = val;
                                                                              emit backgroundColorBlueChanged(val);
                                                                              saveSettingsTimer->start(); } }

    // backgroundColorAlpha
    Q_PROPERTY(int    backgroundColorAlpha
               READ   getBackgroundColorAlpha
               WRITE  setBackgroundColorAlpha
               NOTIFY backgroundColorAlphaChanged)
    int  getBackgroundColorAlpha() { return m_backgroundColorAlpha; }
    void setBackgroundColorAlpha(int val) { if(val != m_backgroundColorAlpha) { m_backgroundColorAlpha = val;
                                                                                emit backgroundColorAlphaChanged(val);
                                                                                saveSettingsTimer->start(); } }

    // backgroundImageScreenshot
    Q_PROPERTY(bool   backgroundImageScreenshot
               READ   getBackgroundImageScreenshot
               WRITE  setBackgroundImageScreenshot
               NOTIFY backgroundImageScreenshotChanged)
    bool getBackgroundImageScreenshot() { return m_backgroundImageScreenshot; }
    void setBackgroundImageScreenshot(bool val) { if(val != m_backgroundImageScreenshot) { m_backgroundImageScreenshot = val;
                                                                                           emit backgroundImageScreenshotChanged(val);
                                                                                           saveSettingsTimer->start(); } }

    // backgroundImageUse
    Q_PROPERTY(bool   backgroundImageUse
               READ   getBackgroundImageUse
               WRITE  setBackgroundImageUse
               NOTIFY backgroundImageUseChanged)
    bool getBackgroundImageUse() { return m_backgroundImageUse; }
    void setBackgroundImageUse(bool val) { if(val != m_backgroundImageUse) { m_backgroundImageUse = val;
                                                                             emit backgroundImageUseChanged(val);
                                                                             saveSettingsTimer->start(); } }

    // backgroundImagePath
    Q_PROPERTY(QString backgroundImagePath
               READ    getBackgroundImagePath
               WRITE   setBackgroundImagePath
               NOTIFY  backgroundImagePathChanged)
    QString getBackgroundImagePath() { return m_backgroundImagePath; }
    void    setBackgroundImagePath(QString val) { if(val != m_backgroundImagePath) { m_backgroundImagePath = val;
                                                                                     emit backgroundImagePathChanged(val);
                                                                                     saveSettingsTimer->start(); } }

    // backgroundImageScale
    Q_PROPERTY(bool   backgroundImageScale
               READ   getBackgroundImageScale
               WRITE  setBackgroundImageScale
               NOTIFY backgroundImageScaleChanged)
    bool getBackgroundImageScale() { return m_backgroundImageScale; }
    void setBackgroundImageScale(bool val) { if(val != m_backgroundImageScale) { m_backgroundImageScale = val;
                                                                                 emit backgroundImageScaleChanged(val);
                                                                                 saveSettingsTimer->start(); } }

    // backgroundImageScaleCrop
    Q_PROPERTY(bool   backgroundImageScaleCrop
               READ   getBackgroundImageScaleCrop
               WRITE  setBackgroundImageScaleCrop
               NOTIFY backgroundImageScaleCropChanged)
    bool getBackgroundImageScaleCrop() { return m_backgroundImageScaleCrop; }
    void setBackgroundImageScaleCrop(bool val) { if(val != m_backgroundImageScaleCrop) { m_backgroundImageScaleCrop = val;
                                                                                         emit backgroundImageScaleCropChanged(val);
                                                                                         saveSettingsTimer->start(); } }

    // backgroundImageStretch
    Q_PROPERTY(bool   backgroundImageStretch
               READ   getBackgroundImageStretch
               WRITE  setBackgroundImageStretch
               NOTIFY backgroundImageStretchChanged)
    bool getBackgroundImageStretch() { return m_backgroundImageStretch; }
    void setBackgroundImageStretch(bool val) { if(val != m_backgroundImageStretch) { m_backgroundImageStretch = val;
                                                                                     emit backgroundImageStretchChanged(val);
                                                                                     saveSettingsTimer->start(); } }

    // backgroundImageCenter
    Q_PROPERTY(bool   backgroundImageCenter
               READ   getBackgroundImageCenter
               WRITE  setBackgroundImageCenter
               NOTIFY backgroundImageCenterChanged)
    bool getBackgroundImageCenter() { return m_backgroundImageCenter; }
    void setBackgroundImageCenter(bool val) { if(val != m_backgroundImageCenter) { m_backgroundImageCenter = val;
                                                                                   emit backgroundImageCenterChanged(val);
                                                                                   saveSettingsTimer->start(); } }

    // backgroundImageTile
    Q_PROPERTY(bool   backgroundImageTile
               READ   getBackgroundImageTile
               WRITE  setBackgroundImageTile
               NOTIFY backgroundImageTileChanged)
    bool getBackgroundImageTile() { return m_backgroundImageTile; }
    void setBackgroundImageTile(bool val) { if(val != m_backgroundImageTile) { m_backgroundImageTile = val;
                                                                               emit backgroundImageTileChanged(val);
                                                                               saveSettingsTimer->start(); } }

    // trayIcon
    Q_PROPERTY(int    trayIcon
               READ   getTrayIcon
               WRITE  setTrayIcon
               NOTIFY trayIconChanged)
    int  getTrayIcon() { return m_trayIcon; }
    void setTrayIcon(int val) { if(val != m_trayIcon) { m_trayIcon = val;
                                                        emit trayIconChanged(val);
                                                        saveSettingsTimer->start(); } }

    // imageTransition
    Q_PROPERTY(int    imageTransition
               READ   getImageTransition
               WRITE  setImageTransition
               NOTIFY imageTransitionChanged)
    int  getImageTransition() { return m_imageTransition; }
    void setImageTransition(int val) { if(val != m_imageTransition) { m_imageTransition = val;
                                                                      emit imageTransitionChanged(val);
                                                                      saveSettingsTimer->start(); } }

    // loopThroughFolder
    Q_PROPERTY(bool   loopThroughFolder
               READ   getLoopThroughFolder
               WRITE  setLoopThroughFolder
               NOTIFY loopThroughFolderChanged)
    bool getLoopThroughFolder() { return m_loopThroughFolder; }
    void setLoopThroughFolder(bool val) { if(val != m_loopThroughFolder) { m_loopThroughFolder = val;
                                                                           emit loopThroughFolderChanged(val);
                                                                           saveSettingsTimer->start(); } }

    // hotEdgeWidth
    Q_PROPERTY(int    hotEdgeWidth
               READ   getHotEdgeWidth
               WRITE  setHotEdgeWidth
               NOTIFY hotEdgeWidthChanged)
    int  getHotEdgeWidth() { return m_hotEdgeWidth; }
    void setHotEdgeWidth(int val) { if(val != m_hotEdgeWidth) { m_hotEdgeWidth = val;
                                                                emit hotEdgeWidthChanged(val);
                                                                saveSettingsTimer->start(); } }

    // closeOnEmptyBackground
    Q_PROPERTY(bool   closeOnEmptyBackground
               READ   getCloseOnEmptyBackground
               WRITE  setCloseOnEmptyBackground
               NOTIFY closeOnEmptyBackgroundChanged)
    bool getCloseOnEmptyBackground() { return m_closeOnEmptyBackground; }
    void setCloseOnEmptyBackground(bool val) { if(val != m_closeOnEmptyBackground) { m_closeOnEmptyBackground = val;
                                                                                     emit closeOnEmptyBackgroundChanged(val);
                                                                                     saveSettingsTimer->start(); } }

    // marginAroundImage
    Q_PROPERTY(int    marginAroundImage
               READ   getMarginAroundImage
               WRITE  setMarginAroundImage
               NOTIFY marginAroundImageChanged)
    int  getMarginAroundImage() { return m_marginAroundImage; }
    void setMarginAroundImage(int val) { if(val != m_marginAroundImage) { m_marginAroundImage = val;
                                                                          emit marginAroundImageChanged(val);
                                                                          saveSettingsTimer->start(); } }

    // sortby
    Q_PROPERTY(QString sortby
               READ    getSortby
               WRITE   setSortby
               NOTIFY  sortbyChanged)
    QString getSortby() { return m_sortby; }
    void    setSortby(QString val) { if(val != m_sortby) { m_sortby = val;
                                                           emit sortbyChanged(val);
                                                           saveSettingsTimer->start(); } }

    // sortbyAscending
    Q_PROPERTY(bool   sortbyAscending
               READ   getSortbyAscending
               WRITE  setSortbyAscending
               NOTIFY sortbyAscendingChanged)
    bool getSortbyAscending() { return m_sortbyAscending; }
    void setSortbyAscending(bool val) { if(val != m_sortbyAscending) { m_sortbyAscending = val;
                                                                       emit sortbyAscendingChanged(val);
                                                                       saveSettingsTimer->start(); } }

    // mouseWheelSensitivity
    Q_PROPERTY(int    mouseWheelSensitivity
               READ   getMouseWheelSensitivity
               WRITE  setMouseWheelSensitivity
               NOTIFY mouseWheelSensitivityChanged)
    int  getMouseWheelSensitivity() { return m_mouseWheelSensitivity; }
    void setMouseWheelSensitivity(int val) { if(val != m_mouseWheelSensitivity) { m_mouseWheelSensitivity = val;
                                                                                  emit mouseWheelSensitivityChanged(val);
                                                                                  saveSettingsTimer->start(); } }

    // keepZoomRotationMirror
    Q_PROPERTY(bool   keepZoomRotationMirror
               READ   getKeepZoomRotationMirror
               WRITE  setKeepZoomRotationMirror
               NOTIFY keepZoomRotationMirrorChanged)
    bool getKeepZoomRotationMirror() { return m_keepZoomRotationMirror; }
    void setKeepZoomRotationMirror(bool val) { if(val != m_keepZoomRotationMirror) { m_keepZoomRotationMirror = val;
                                                                                     emit keepZoomRotationMirrorChanged(val);
                                                                                     saveSettingsTimer->start(); } }

    // fitInWindow
    Q_PROPERTY(bool   fitInWindow
               READ   getFitInWindow
               WRITE  setFitInWindow
               NOTIFY fitInWindowChanged)
    bool getFitInWindow() { return m_fitInWindow; }
    void setFitInWindow(bool val) { if(val != m_fitInWindow) { m_fitInWindow = val;
                                                               emit fitInWindowChanged(val);
                                                               saveSettingsTimer->start(); } }

    // interpolationNearestNeighbourThreshold
    Q_PROPERTY(int    interpolationNearestNeighbourThreshold
               READ   getInterpolationNearestNeighbourThreshold
               WRITE  setInterpolationNearestNeighbourThreshold
               NOTIFY interpolationNearestNeighbourThresholdChanged)
    int  getInterpolationNearestNeighbourThreshold() { return m_interpolationNearestNeighbourThreshold; }
    void setInterpolationNearestNeighbourThreshold(int val) { if(val != m_interpolationNearestNeighbourThreshold) { m_interpolationNearestNeighbourThreshold = val;
                                                                                                                    emit interpolationNearestNeighbourThresholdChanged(val);
                                                                                                                    saveSettingsTimer->start(); } }

    // interpolationNearestNeighbourUpscale
    Q_PROPERTY(bool   interpolationNearestNeighbourUpscale
               READ   getInterpolationNearestNeighbourUpscale
               WRITE  setInterpolationNearestNeighbourUpscale
               NOTIFY interpolationNearestNeighbourUpscaleChanged)
    bool getInterpolationNearestNeighbourUpscale() { return m_interpolationNearestNeighbourUpscale; }
    void setInterpolationNearestNeighbourUpscale(bool val) { if(val != m_interpolationNearestNeighbourUpscale) { m_interpolationNearestNeighbourUpscale = val;
                                                                                                                 emit interpolationNearestNeighbourUpscaleChanged(val);
                                                                                                                 saveSettingsTimer->start(); } }

    // pixmapCache
    Q_PROPERTY(int    pixmapCache
               READ   getPixmapCache
               WRITE  setPixmapCache
               NOTIFY pixmapCacheChanged)
    int  getPixmapCache() { return m_pixmapCache; }
    void setPixmapCache(int val) { if(val != m_pixmapCache) { m_pixmapCache = val;
                                                              emit pixmapCacheChanged(val);
                                                              saveSettingsTimer->start(); } }

    // showTransparencyMarkerBackground
    Q_PROPERTY(bool   showTransparencyMarkerBackground
               READ   getShowTransparencyMarkerBackground
               WRITE  setShowTransparencyMarkerBackground
               NOTIFY showTransparencyMarkerBackgroundChanged)
    bool getShowTransparencyMarkerBackground() { return m_showTransparencyMarkerBackground; }
    void setShowTransparencyMarkerBackground(bool val) { if(val != m_showTransparencyMarkerBackground) { m_showTransparencyMarkerBackground = val;
                                                                                                         emit showTransparencyMarkerBackgroundChanged(val);
                                                                                                         saveSettingsTimer->start(); } }

    // leftButtonMouseClickAndMove
    Q_PROPERTY(bool   leftButtonMouseClickAndMove
               READ   getLeftButtonMouseClickAndMove
               WRITE  setLeftButtonMouseClickAndMove
               NOTIFY leftButtonMouseClickAndMoveChanged)
    bool getLeftButtonMouseClickAndMove() { return m_leftButtonMouseClickAndMove; }
    void setLeftButtonMouseClickAndMove(bool val) { if(val != m_leftButtonMouseClickAndMove) { m_leftButtonMouseClickAndMove = val;
                                                                                               emit leftButtonMouseClickAndMoveChanged(val);
                                                                                               saveSettingsTimer->start(); } }

    // quickInfoHideCounter
    Q_PROPERTY(bool   quickInfoHideCounter
               READ   getQuickInfoHideCounter
               WRITE  setQuickInfoHideCounter
               NOTIFY quickInfoHideCounterChanged)
    bool getQuickInfoHideCounter() { return m_quickInfoHideCounter; }
    void setQuickInfoHideCounter(bool val) { if(val != m_quickInfoHideCounter) { m_quickInfoHideCounter = val;
                                                                                 emit quickInfoHideCounterChanged(val);
                                                                                 saveSettingsTimer->start(); } }

    // quickInfoHideFilepath
    Q_PROPERTY(bool   quickInfoHideFilepath
               READ   getQuickInfoHideFilepath
               WRITE  setQuickInfoHideFilepath
               NOTIFY quickInfoHideFilepathChanged)
    bool getQuickInfoHideFilepath() { return m_quickInfoHideFilepath; }
    void setQuickInfoHideFilepath(bool val) { if(val != m_quickInfoHideFilepath) { m_quickInfoHideFilepath = val;
                                                                                   emit quickInfoHideFilepathChanged(val);
                                                                                   saveSettingsTimer->start(); } }

    // quickInfoHideFilename
    Q_PROPERTY(bool   quickInfoHideFilename
               READ   getQuickInfoHideFilename
               WRITE  setQuickInfoHideFilename
               NOTIFY quickInfoHideFilenameChanged)
    bool getQuickInfoHideFilename() { return m_quickInfoHideFilename; }
    void setQuickInfoHideFilename(bool val) { if(val != m_quickInfoHideFilename) { m_quickInfoHideFilename = val;
                                                                                   emit quickInfoHideFilenameChanged(val);
                                                                                   saveSettingsTimer->start(); } }

    // quickInfoHideX
    Q_PROPERTY(bool   quickInfoHideX
               READ   getQuickInfoHideX
               WRITE  setQuickInfoHideX
               NOTIFY quickInfoHideXChanged)
    bool getQuickInfoHideX() { return m_quickInfoHideX; }
    void setQuickInfoHideX(bool val) { if(val != m_quickInfoHideX) { m_quickInfoHideX = val;
                                                                     emit quickInfoHideXChanged(val);
                                                                     saveSettingsTimer->start(); } }

    // quickInfoFullX
    Q_PROPERTY(bool   quickInfoFullX
               READ   getQuickInfoFullX
               WRITE  setQuickInfoFullX
               NOTIFY quickInfoFullXChanged)
    bool getQuickInfoFullX() { return m_quickInfoFullX; }
    void setQuickInfoFullX(bool val) { if(val != m_quickInfoFullX) { m_quickInfoFullX = val;
                                                                     emit quickInfoFullXChanged(val);
                                                                     saveSettingsTimer->start(); } }

    // quickInfoCloseXSize
    Q_PROPERTY(int    quickInfoCloseXSize
               READ   getQuickInfoCloseXSize
               WRITE  setQuickInfoCloseXSize
               NOTIFY quickInfoCloseXSizeChanged)
    int  getQuickInfoCloseXSize() { return m_quickInfoCloseXSize; }
    void setQuickInfoCloseXSize(int val) { if(val != m_quickInfoCloseXSize) { m_quickInfoCloseXSize = val;
                                                                              emit quickInfoCloseXSizeChanged(val);
                                                                              saveSettingsTimer->start(); } }

    // slideShowTime
    Q_PROPERTY(int    slideShowTime
               READ   getSlideShowTime
               WRITE  setSlideShowTime
               NOTIFY slideShowTimeChanged)
    int  getSlideShowTime() { return m_slideShowTime; }
    void setSlideShowTime(int val) { if(val != m_slideShowTime) { m_slideShowTime = val;
                                                                  emit slideShowTimeChanged(val);
                                                                  saveSettingsTimer->start(); } }

    // slideShowImageTransition
    Q_PROPERTY(int    slideShowImageTransition
               READ   getSlideShowImageTransition
               WRITE  setSlideShowImageTransition
               NOTIFY slideShowImageTransitionChanged)
    int  getSlideShowImageTransition() { return m_slideShowImageTransition; }
    void setSlideShowImageTransition(int val) { if(val != m_slideShowImageTransition) { m_slideShowImageTransition = val;
                                                                                        emit slideShowImageTransitionChanged(val);
                                                                                        saveSettingsTimer->start(); } }

    // slideShowMusicFile
    Q_PROPERTY(QString slideShowMusicFile
               READ    getSlideShowMusicFile
               WRITE   setSlideShowMusicFile
               NOTIFY  slideShowMusicFileChanged)
    QString getSlideShowMusicFile() { return m_slideShowMusicFile; }
    void    setSlideShowMusicFile(QString val) { if(val != m_slideShowMusicFile) { m_slideShowMusicFile = val;
                                                                                   emit slideShowMusicFileChanged(val);
                                                                                   saveSettingsTimer->start(); } }

    // slideShowShuffle
    Q_PROPERTY(bool   slideShowShuffle
               READ   getSlideShowShuffle
               WRITE  setSlideShowShuffle
               NOTIFY slideShowShuffleChanged)
    bool getSlideShowShuffle() { return m_slideShowShuffle; }
    void setSlideShowShuffle(bool val) { if(val != m_slideShowShuffle) { m_slideShowShuffle = val;
                                                                         emit slideShowShuffleChanged(val);
                                                                         saveSettingsTimer->start(); } }

    // slideShowLoop
    Q_PROPERTY(bool   slideShowLoop
               READ   getSlideShowLoop
               WRITE  setSlideShowLoop
               NOTIFY slideShowLoopChanged)
    bool getSlideShowLoop() { return m_slideShowLoop; }
    void setSlideShowLoop(bool val) { if(val != m_slideShowLoop) { m_slideShowLoop = val;
                                                                   emit slideShowLoopChanged(val);
                                                                   saveSettingsTimer->start(); } }

    // slideShowHideQuickInfo
    Q_PROPERTY(bool   slideShowHideQuickInfo
               READ   getSlideShowHideQuickInfo
               WRITE  setSlideShowHideQuickInfo
               NOTIFY slideShowHideQuickInfoChanged)
    bool getSlideShowHideQuickInfo() { return m_slideShowHideQuickInfo; }
    void setSlideShowHideQuickInfo(bool val) { if(val != m_slideShowHideQuickInfo) { m_slideShowHideQuickInfo = val;
                                                                                     emit slideShowHideQuickInfoChanged(val);
                                                                                     saveSettingsTimer->start(); } }

    // thumbnailSize
    Q_PROPERTY(int    thumbnailSize
               READ   getThumbnailSize
               WRITE  setThumbnailSize
               NOTIFY thumbnailSizeChanged)
    int  getThumbnailSize() { return m_thumbnailSize; }
    void setThumbnailSize(int val) { if(val != m_thumbnailSize) { m_thumbnailSize = val;
                                                                  emit thumbnailSizeChanged(val);
                                                                  saveSettingsTimer->start(); } }

    // thumbnailPosition
    Q_PROPERTY(QString thumbnailPosition
               READ    getThumbnailPosition
               WRITE   setThumbnailPosition
               NOTIFY  thumbnailPositionChanged)
    QString getThumbnailPosition() { return m_thumbnailPosition; }
    void    setThumbnailPosition(QString val) { if(val != m_thumbnailPosition) { m_thumbnailPosition = val;
                                                                                 emit thumbnailPositionChanged(val);
                                                                                 saveSettingsTimer->start(); } }

    // thumbnailCache
    Q_PROPERTY(bool   thumbnailCache
               READ   getThumbnailCache
               WRITE  setThumbnailCache
               NOTIFY thumbnailCacheChanged)
    bool getThumbnailCache() { return m_thumbnailCache; }
    void setThumbnailCache(bool val) { if(val != m_thumbnailCache) { m_thumbnailCache = val;
                                                                     emit thumbnailCacheChanged(val);
                                                                     saveSettingsTimer->start(); } }

    // thumbnailCacheFile
    Q_PROPERTY(bool   thumbnailCacheFile
               READ   getThumbnailCacheFile
               WRITE  setThumbnailCacheFile
               NOTIFY thumbnailCacheFileChanged)
    bool getThumbnailCacheFile() { return m_thumbnailCacheFile; }
    void setThumbnailCacheFile(bool val) { if(val != m_thumbnailCacheFile) { m_thumbnailCacheFile = val;
                                                                             emit thumbnailCacheFileChanged(val);
                                                                             saveSettingsTimer->start(); } }

    // thumbnailSpacingBetween
    Q_PROPERTY(int    thumbnailSpacingBetween
               READ   getThumbnailSpacingBetween
               WRITE  setThumbnailSpacingBetween
               NOTIFY thumbnailSpacingBetweenChanged)
    int  getThumbnailSpacingBetween() { return m_thumbnailSpacingBetween; }
    void setThumbnailSpacingBetween(int val) { if(val != m_thumbnailSpacingBetween) { m_thumbnailSpacingBetween = val;
                                                                                      emit thumbnailSpacingBetweenChanged(val);
                                                                                      saveSettingsTimer->start(); } }

    // thumbnailLiftUp
    Q_PROPERTY(int    thumbnailLiftUp
               READ   getThumbnailLiftUp
               WRITE  setThumbnailLiftUp
               NOTIFY thumbnailLiftUpChanged)
    int  getThumbnailLiftUp() { return m_thumbnailLiftUp; }
    void setThumbnailLiftUp(int val) { if(val != m_thumbnailLiftUp) { m_thumbnailLiftUp = val;
                                                                      emit thumbnailLiftUpChanged(val);
                                                                      saveSettingsTimer->start(); } }

    // thumbnailKeepVisible
    Q_PROPERTY(bool   thumbnailKeepVisible
               READ   getThumbnailKeepVisible
               WRITE  setThumbnailKeepVisible
               NOTIFY thumbnailKeepVisibleChanged)
    bool getThumbnailKeepVisible() { return m_thumbnailKeepVisible; }
    void setThumbnailKeepVisible(bool val) { if(val != m_thumbnailKeepVisible) { m_thumbnailKeepVisible = val;
                                                                                 emit thumbnailKeepVisibleChanged(val);
                                                                                 saveSettingsTimer->start(); } }

    // thumbnailKeepVisibleWhenNotZoomedIn
    Q_PROPERTY(bool   thumbnailKeepVisibleWhenNotZoomedIn
               READ   getThumbnailKeepVisibleWhenNotZoomedIn
               WRITE  setThumbnailKeepVisibleWhenNotZoomedIn
               NOTIFY thumbnailKeepVisibleWhenNotZoomedInChanged)
    bool getThumbnailKeepVisibleWhenNotZoomedIn() { return m_thumbnailKeepVisibleWhenNotZoomedIn; }
    void setThumbnailKeepVisibleWhenNotZoomedIn(bool val) { if(val != m_thumbnailKeepVisibleWhenNotZoomedIn) { m_thumbnailKeepVisibleWhenNotZoomedIn = val;
                                                                                                               emit thumbnailKeepVisibleWhenNotZoomedInChanged(val);
                                                                                                               saveSettingsTimer->start(); } }

    // thumbnailCenterActive
    Q_PROPERTY(bool   thumbnailCenterActive
               READ   getThumbnailCenterActive
               WRITE  setThumbnailCenterActive
               NOTIFY thumbnailCenterActiveChanged)
    bool getThumbnailCenterActive() { return m_thumbnailCenterActive; }
    void setThumbnailCenterActive(bool val) { if(val != m_thumbnailCenterActive) { m_thumbnailCenterActive = val;
                                                                                   emit thumbnailCenterActiveChanged(val);
                                                                                   saveSettingsTimer->start(); } }

    // thumbnailFilenameInstead
    Q_PROPERTY(bool   thumbnailFilenameInstead
               READ   getThumbnailFilenameInstead
               WRITE  setThumbnailFilenameInstead
               NOTIFY thumbnailFilenameInsteadChanged)
    bool getThumbnailFilenameInstead() { return m_thumbnailFilenameInstead; }
    void setThumbnailFilenameInstead(bool val) { if(val != m_thumbnailFilenameInstead) { m_thumbnailFilenameInstead = val;
                                                                                         emit thumbnailFilenameInsteadChanged(val);
                                                                                         saveSettingsTimer->start(); } }

    // thumbnailFilenameInsteadFontSize
    Q_PROPERTY(int    thumbnailFilenameInsteadFontSize
               READ   getThumbnailFilenameInsteadFontSize
               WRITE  setThumbnailFilenameInsteadFontSize
               NOTIFY thumbnailFilenameInsteadFontSizeChanged)
    int  getThumbnailFilenameInsteadFontSize() { return m_thumbnailFilenameInsteadFontSize; }
    void setThumbnailFilenameInsteadFontSize(int val) { if(val != m_thumbnailFilenameInsteadFontSize) { m_thumbnailFilenameInsteadFontSize = val;
                                                                                                        emit thumbnailFilenameInsteadFontSizeChanged(val);
                                                                                                        saveSettingsTimer->start(); } }

    // thumbnailDisable
    Q_PROPERTY(bool   thumbnailDisable
               READ   getThumbnailDisable
               WRITE  setThumbnailDisable
               NOTIFY thumbnailDisableChanged)
    bool getThumbnailDisable() { return m_thumbnailDisable; }
    void setThumbnailDisable(bool val) { if(val != m_thumbnailDisable) { m_thumbnailDisable = val;
                                                                         emit thumbnailDisableChanged(val);
                                                                         saveSettingsTimer->start(); } }

    // thumbnailWriteFilename
    Q_PROPERTY(bool   thumbnailWriteFilename
               READ   getThumbnailWriteFilename
               WRITE  setThumbnailWriteFilename
               NOTIFY thumbnailWriteFilenameChanged)
    bool getThumbnailWriteFilename() { return m_thumbnailWriteFilename; }
    void setThumbnailWriteFilename(bool val) { if(val != m_thumbnailWriteFilename) { m_thumbnailWriteFilename = val;
                                                                                     emit thumbnailWriteFilenameChanged(val);
                                                                                     saveSettingsTimer->start(); } }

    // thumbnailFontSize
    Q_PROPERTY(int    thumbnailFontSize
               READ   getThumbnailFontSize
               WRITE  setThumbnailFontSize
               NOTIFY thumbnailFontSizeChanged)
    int  getThumbnailFontSize() { return m_thumbnailFontSize; }
    void setThumbnailFontSize(int val) { if(val != m_thumbnailFontSize) { m_thumbnailFontSize = val;
                                                                          emit thumbnailFontSizeChanged(val);
                                                                          saveSettingsTimer->start(); } }

    // windowMode
    Q_PROPERTY(bool   windowMode
               READ   getWindowMode
               WRITE  setWindowMode
               NOTIFY windowModeChanged)
    bool getWindowMode() { return m_windowMode; }
    void setWindowMode(bool val) { if(val != m_windowMode) { m_windowMode = val;
                                                             emit windowModeChanged(val);
                                                             saveSettingsTimer->start(); } }

    // windowDecoration
    Q_PROPERTY(bool   windowDecoration
               READ   getWindowDecoration
               WRITE  setWindowDecoration
               NOTIFY windowDecorationChanged)
    bool getWindowDecoration() { return m_windowDecoration; }
    void setWindowDecoration(bool val) { if(val != m_windowDecoration) { m_windowDecoration = val;
                                                                         emit windowDecorationChanged(val);
                                                                         saveSettingsTimer->start(); } }

    // metadataEnableHotEdge
    Q_PROPERTY(bool   metadataEnableHotEdge
               READ   getMetadataEnableHotEdge
               WRITE  setMetadataEnableHotEdge
               NOTIFY metadataEnableHotEdgeChanged)
    bool getMetadataEnableHotEdge() { return m_metadataEnableHotEdge; }
    void setMetadataEnableHotEdge(bool val) { if(val != m_metadataEnableHotEdge) { m_metadataEnableHotEdge = val;
                                                                                   emit metadataEnableHotEdgeChanged(val);
                                                                                   saveSettingsTimer->start(); } }

    // metaApplyRotation
    Q_PROPERTY(bool   metaApplyRotation
               READ   getMetaApplyRotation
               WRITE  setMetaApplyRotation
               NOTIFY metaApplyRotationChanged)
    bool getMetaApplyRotation() { return m_metaApplyRotation; }
    void setMetaApplyRotation(bool val) { if(val != m_metaApplyRotation) { m_metaApplyRotation = val;
                                                                           emit metaApplyRotationChanged(val);
                                                                           saveSettingsTimer->start(); } }

    // metaGpsMapService
    Q_PROPERTY(QString metaGpsMapService
               READ    getMetaGpsMapService
               WRITE   setMetaGpsMapService
               NOTIFY  metaGpsMapServiceChanged)
    QString getMetaGpsMapService() { return m_metaGpsMapService; }
    void    setMetaGpsMapService(QString val) { if(val != m_metaGpsMapService) { m_metaGpsMapService = val;
                                                                                 emit metaGpsMapServiceChanged(val);
                                                                                 saveSettingsTimer->start(); } }

    // metadataFontSize
    Q_PROPERTY(int    metadataFontSize
               READ   getMetadataFontSize
               WRITE  setMetadataFontSize
               NOTIFY metadataFontSizeChanged)
    int  getMetadataFontSize() { return m_metadataFontSize; }
    void setMetadataFontSize(int val) { if(val != m_metadataFontSize) { m_metadataFontSize = val;
                                                                        emit metadataFontSizeChanged(val);
                                                                        saveSettingsTimer->start(); } }

    // metadataOpacity
    Q_PROPERTY(int    metadataOpacity
               READ   getMetadataOpacity
               WRITE  setMetadataOpacity
               NOTIFY metadataOpacityChanged)
    int  getMetadataOpacity() { return m_metadataOpacity; }
    void setMetadataOpacity(int val) { if(val != m_metadataOpacity) { m_metadataOpacity = val;
                                                                      emit metadataOpacityChanged(val);
                                                                      saveSettingsTimer->start(); } }

    // metaFilename
    Q_PROPERTY(bool   metaFilename
               READ   getMetaFilename
               WRITE  setMetaFilename
               NOTIFY metaFilenameChanged)
    bool getMetaFilename() { return m_metaFilename; }
    void setMetaFilename(bool val) { if(val != m_metaFilename) { m_metaFilename = val;
                                                                 emit metaFilenameChanged(val);
                                                                 saveSettingsTimer->start(); } }

    // metaFileType
    Q_PROPERTY(bool   metaFileType
               READ   getMetaFileType
               WRITE  setMetaFileType
               NOTIFY metaFileTypeChanged)
    bool getMetaFileType() { return m_metaFileType; }
    void setMetaFileType(bool val) { if(val != m_metaFileType) { m_metaFileType = val;
                                                                 emit metaFileTypeChanged(val);
                                                                 saveSettingsTimer->start(); } }

    // metaFileSize
    Q_PROPERTY(bool   metaFileSize
               READ   getMetaFileSize
               WRITE  setMetaFileSize
               NOTIFY metaFileSizeChanged)
    bool getMetaFileSize() { return m_metaFileSize; }
    void setMetaFileSize(bool val) { if(val != m_metaFileSize) { m_metaFileSize = val;
                                                                 emit metaFileSizeChanged(val);
                                                                 saveSettingsTimer->start(); } }

    // metaImageNumber
    Q_PROPERTY(bool   metaImageNumber
               READ   getMetaImageNumber
               WRITE  setMetaImageNumber
               NOTIFY metaImageNumberChanged)
    bool getMetaImageNumber() { return m_metaImageNumber; }
    void setMetaImageNumber(bool val) { if(val != m_metaImageNumber) { m_metaImageNumber = val;
                                                                       emit metaImageNumberChanged(val);
                                                                       saveSettingsTimer->start(); } }

    // metaDimensions
    Q_PROPERTY(bool   metaDimensions
               READ   getMetaDimensions
               WRITE  setMetaDimensions
               NOTIFY metaDimensionsChanged)
    bool getMetaDimensions() { return m_metaDimensions; }
    void setMetaDimensions(bool val) { if(val != m_metaDimensions) { m_metaDimensions = val;
                                                                     emit metaDimensionsChanged(val);
                                                                     saveSettingsTimer->start(); } }

    // metaMake
    Q_PROPERTY(bool   metaMake
               READ   getMetaMake
               WRITE  setMetaMake
               NOTIFY metaMakeChanged)
    bool getMetaMake() { return m_metaMake; }
    void setMetaMake(bool val) { if(val != m_metaMake) { m_metaMake = val;
                                                         emit metaMakeChanged(val);
                                                         saveSettingsTimer->start(); } }

    // metaModel
    Q_PROPERTY(bool   metaModel
               READ   getMetaModel
               WRITE  setMetaModel
               NOTIFY metaModelChanged)
    bool getMetaModel() { return m_metaModel; }
    void setMetaModel(bool val) { if(val != m_metaModel) { m_metaModel = val;
                                                           emit metaModelChanged(val);
                                                           saveSettingsTimer->start(); } }

    // metaSoftware
    Q_PROPERTY(bool   metaSoftware
               READ   getMetaSoftware
               WRITE  setMetaSoftware
               NOTIFY metaSoftwareChanged)
    bool getMetaSoftware() { return m_metaSoftware; }
    void setMetaSoftware(bool val) { if(val != m_metaSoftware) { m_metaSoftware = val;
                                                                 emit metaSoftwareChanged(val);
                                                                 saveSettingsTimer->start(); } }

    // metaTimePhotoTaken
    Q_PROPERTY(bool   metaTimePhotoTaken
               READ   getMetaTimePhotoTaken
               WRITE  setMetaTimePhotoTaken
               NOTIFY metaTimePhotoTakenChanged)
    bool getMetaTimePhotoTaken() { return m_metaTimePhotoTaken; }
    void setMetaTimePhotoTaken(bool val) { if(val != m_metaTimePhotoTaken) { m_metaTimePhotoTaken = val;
                                                                             emit metaTimePhotoTakenChanged(val);
                                                                             saveSettingsTimer->start(); } }

    // metaExposureTime
    Q_PROPERTY(bool   metaExposureTime
               READ   getMetaExposureTime
               WRITE  setMetaExposureTime
               NOTIFY metaExposureTimeChanged)
    bool getMetaExposureTime() { return m_metaExposureTime; }
    void setMetaExposureTime(bool val) { if(val != m_metaExposureTime) { m_metaExposureTime = val;
                                                                         emit metaExposureTimeChanged(val);
                                                                         saveSettingsTimer->start(); } }

    // metaFlash
    Q_PROPERTY(bool   metaFlash
               READ   getMetaFlash
               WRITE  setMetaFlash
               NOTIFY metaFlashChanged)
    bool getMetaFlash() { return m_metaFlash; }
    void setMetaFlash(bool val) { if(val != m_metaFlash) { m_metaFlash = val;
                                                           emit metaFlashChanged(val);
                                                           saveSettingsTimer->start(); } }

    // metaIso
    Q_PROPERTY(bool   metaIso
               READ   getMetaIso
               WRITE  setMetaIso
               NOTIFY metaIsoChanged)
    bool getMetaIso() { return m_metaIso; }
    void setMetaIso(bool val) { if(val != m_metaIso) { m_metaIso = val;
                                                       emit metaIsoChanged(val);
                                                       saveSettingsTimer->start(); } }

    // metaSceneType
    Q_PROPERTY(bool   metaSceneType
               READ   getMetaSceneType
               WRITE  setMetaSceneType
               NOTIFY metaSceneTypeChanged)
    bool getMetaSceneType() { return m_metaSceneType; }
    void setMetaSceneType(bool val) { if(val != m_metaSceneType) { m_metaSceneType = val;
                                                                   emit metaSceneTypeChanged(val);
                                                                   saveSettingsTimer->start(); } }

    // metaFLength
    Q_PROPERTY(bool   metaFLength
               READ   getMetaFLength
               WRITE  setMetaFLength
               NOTIFY metaFLengthChanged)
    bool getMetaFLength() { return m_metaFLength; }
    void setMetaFLength(bool val) { if(val != m_metaFLength) { m_metaFLength = val;
                                                               emit metaFLengthChanged(val);
                                                               saveSettingsTimer->start(); } }

    // metaFNumber
    Q_PROPERTY(bool   metaFNumber
               READ   getMetaFNumber
               WRITE  setMetaFNumber
               NOTIFY metaFNumberChanged)
    bool getMetaFNumber() { return m_metaFNumber; }
    void setMetaFNumber(bool val) { if(val != m_metaFNumber) { m_metaFNumber = val;
                                                               emit metaFNumberChanged(val);
                                                               saveSettingsTimer->start(); } }

    // metaLightSource
    Q_PROPERTY(bool   metaLightSource
               READ   getMetaLightSource
               WRITE  setMetaLightSource
               NOTIFY metaLightSourceChanged)
    bool getMetaLightSource() { return m_metaLightSource; }
    void setMetaLightSource(bool val) { if(val != m_metaLightSource) { m_metaLightSource = val;
                                                                       emit metaLightSourceChanged(val);
                                                                       saveSettingsTimer->start(); } }

    // metaKeywords
    Q_PROPERTY(bool   metaKeywords
               READ   getMetaKeywords
               WRITE  setMetaKeywords
               NOTIFY metaKeywordsChanged)
    bool getMetaKeywords() { return m_metaKeywords; }
    void setMetaKeywords(bool val) { if(val != m_metaKeywords) { m_metaKeywords = val;
                                                                 emit metaKeywordsChanged(val);
                                                                 saveSettingsTimer->start(); } }

    // metaLocation
    Q_PROPERTY(bool   metaLocation
               READ   getMetaLocation
               WRITE  setMetaLocation
               NOTIFY metaLocationChanged)
    bool getMetaLocation() { return m_metaLocation; }
    void setMetaLocation(bool val) { if(val != m_metaLocation) { m_metaLocation = val;
                                                                 emit metaLocationChanged(val);
                                                                 saveSettingsTimer->start(); } }

    // metaCopyright
    Q_PROPERTY(bool   metaCopyright
               READ   getMetaCopyright
               WRITE  setMetaCopyright
               NOTIFY metaCopyrightChanged)
    bool getMetaCopyright() { return m_metaCopyright; }
    void setMetaCopyright(bool val) { if(val != m_metaCopyright) { m_metaCopyright = val;
                                                                   emit metaCopyrightChanged(val);
                                                                   saveSettingsTimer->start(); } }

    // metaGps
    Q_PROPERTY(bool   metaGps
               READ   getMetaGps
               WRITE  setMetaGps
               NOTIFY metaGpsChanged)
    bool getMetaGps() { return m_metaGps; }
    void setMetaGps(bool val) { if(val != m_metaGps) { m_metaGps = val;
                                                       emit metaGpsChanged(val);
                                                       saveSettingsTimer->start(); } }

    // openDefaultView
    Q_PROPERTY(QString openDefaultView
               READ    getOpenDefaultView
               WRITE   setOpenDefaultView
               NOTIFY  openDefaultViewChanged)
    QString getOpenDefaultView() { return m_openDefaultView; }
    void    setOpenDefaultView(QString val) { if(val != m_openDefaultView) { m_openDefaultView = val;
                                                                             emit openDefaultViewChanged(val);
                                                                             saveSettingsTimer->start(); } }

    // openPreview
    Q_PROPERTY(bool   openPreview
               READ   getOpenPreview
               WRITE  setOpenPreview
               NOTIFY openPreviewChanged)
    bool getOpenPreview() { return m_openPreview; }
    void setOpenPreview(bool val) { if(val != m_openPreview) { m_openPreview = val;
                                                               emit openPreviewChanged(val);
                                                               saveSettingsTimer->start(); } }

    // openZoomLevel
    Q_PROPERTY(int    openZoomLevel
               READ   getOpenZoomLevel
               WRITE  setOpenZoomLevel
               NOTIFY openZoomLevelChanged)
    int  getOpenZoomLevel() { return m_openZoomLevel; }
    void setOpenZoomLevel(int val) { if(val != m_openZoomLevel) { m_openZoomLevel = val;
                                                                  emit openZoomLevelChanged(val);
                                                                  saveSettingsTimer->start(); } }

    // openUserPlacesWidth
    Q_PROPERTY(int    openUserPlacesWidth
               READ   getOpenUserPlacesWidth
               WRITE  setOpenUserPlacesWidth
               NOTIFY openUserPlacesWidthChanged)
    int  getOpenUserPlacesWidth() { return m_openUserPlacesWidth; }
    void setOpenUserPlacesWidth(int val) { if(val != m_openUserPlacesWidth) { m_openUserPlacesWidth = val;
                                                                              emit openUserPlacesWidthChanged(val);
                                                                              saveSettingsTimer->start(); } }

    // openFoldersWidth
    Q_PROPERTY(int    openFoldersWidth
               READ   getOpenFoldersWidth
               WRITE  setOpenFoldersWidth
               NOTIFY openFoldersWidthChanged)
    int  getOpenFoldersWidth() { return m_openFoldersWidth; }
    void setOpenFoldersWidth(int val) { if(val != m_openFoldersWidth) { m_openFoldersWidth = val;
                                                                        emit openFoldersWidthChanged(val);
                                                                        saveSettingsTimer->start(); } }

    // openThumbnails
    Q_PROPERTY(bool   openThumbnails
               READ   getOpenThumbnails
               WRITE  setOpenThumbnails
               NOTIFY openThumbnailsChanged)
    bool getOpenThumbnails() { return m_openThumbnails; }
    void setOpenThumbnails(bool val) { if(val != m_openThumbnails) { m_openThumbnails = val;
                                                                     emit openThumbnailsChanged(val);
                                                                     saveSettingsTimer->start(); } }

    // openPreviewHighQuality
    Q_PROPERTY(bool   openPreviewHighQuality
               READ   getOpenPreviewHighQuality
               WRITE  setOpenPreviewHighQuality
               NOTIFY openPreviewHighQualityChanged)
    bool getOpenPreviewHighQuality() { return m_openPreviewHighQuality; }
    void setOpenPreviewHighQuality(bool val) { if(val != m_openPreviewHighQuality) { m_openPreviewHighQuality = val;
                                                                                     emit openPreviewHighQualityChanged(val);
                                                                                     saveSettingsTimer->start(); } }

    // openUserPlacesStandard
    Q_PROPERTY(bool   openUserPlacesStandard
               READ   getOpenUserPlacesStandard
               WRITE  setOpenUserPlacesStandard
               NOTIFY openUserPlacesStandardChanged)
    bool getOpenUserPlacesStandard() { return m_openUserPlacesStandard; }
    void setOpenUserPlacesStandard(bool val) { if(val != m_openUserPlacesStandard) { m_openUserPlacesStandard = val;
                                                                                     emit openUserPlacesStandardChanged(val);
                                                                                     saveSettingsTimer->start(); } }

    // openUserPlacesUser
    Q_PROPERTY(bool   openUserPlacesUser
               READ   getOpenUserPlacesUser
               WRITE  setOpenUserPlacesUser
               NOTIFY openUserPlacesUserChanged)
    bool getOpenUserPlacesUser() { return m_openUserPlacesUser; }
    void setOpenUserPlacesUser(bool val) { if(val != m_openUserPlacesUser) { m_openUserPlacesUser = val;
                                                                             emit openUserPlacesUserChanged(val);
                                                                             saveSettingsTimer->start(); } }

    // openUserPlacesVolumes
    Q_PROPERTY(bool   openUserPlacesVolumes
               READ   getOpenUserPlacesVolumes
               WRITE  setOpenUserPlacesVolumes
               NOTIFY openUserPlacesVolumesChanged)
    bool getOpenUserPlacesVolumes() { return m_openUserPlacesVolumes; }
    void setOpenUserPlacesVolumes(bool val) { if(val != m_openUserPlacesVolumes) { m_openUserPlacesVolumes = val;
                                                                                   emit openUserPlacesVolumesChanged(val);
                                                                                   saveSettingsTimer->start(); } }

    // openKeepLastLocation
    Q_PROPERTY(bool   openKeepLastLocation
               READ   getOpenKeepLastLocation
               WRITE  setOpenKeepLastLocation
               NOTIFY openKeepLastLocationChanged)
    bool getOpenKeepLastLocation() { return m_openKeepLastLocation; }
    void setOpenKeepLastLocation(bool val) { if(val != m_openKeepLastLocation) { m_openKeepLastLocation = val;
                                                                                 emit openKeepLastLocationChanged(val);
                                                                                 saveSettingsTimer->start(); } }

    // openShowHiddenFilesFolders
    Q_PROPERTY(bool   openShowHiddenFilesFolders
               READ   getOpenShowHiddenFilesFolders
               WRITE  setOpenShowHiddenFilesFolders
               NOTIFY openShowHiddenFilesFoldersChanged)
    bool getOpenShowHiddenFilesFolders() { return m_openShowHiddenFilesFolders; }
    void setOpenShowHiddenFilesFolders(bool val) { if(val != m_openShowHiddenFilesFolders) { m_openShowHiddenFilesFolders = val;
                                                                                             emit openShowHiddenFilesFoldersChanged(val);
                                                                                             saveSettingsTimer->start(); } }

    // openHideUserPlaces
    Q_PROPERTY(bool   openHideUserPlaces
               READ   getOpenHideUserPlaces
               WRITE  setOpenHideUserPlaces
               NOTIFY openHideUserPlacesChanged)
    bool getOpenHideUserPlaces() { return m_openHideUserPlaces; }
    void setOpenHideUserPlaces(bool val) { if(val != m_openHideUserPlaces) { m_openHideUserPlaces = val;
                                                                             emit openHideUserPlacesChanged(val);
                                                                             saveSettingsTimer->start(); } }

    // metadataWindowWidth
    Q_PROPERTY(int    metadataWindowWidth
               READ   getMetadataWindowWidth
               WRITE  setMetadataWindowWidth
               NOTIFY metadataWindowWidthChanged)
    int  getMetadataWindowWidth() { return m_metadataWindowWidth; }
    void setMetadataWindowWidth(int val) { if(val != m_metadataWindowWidth) { m_metadataWindowWidth = val;
                                                                              emit metadataWindowWidthChanged(val);
                                                                              saveSettingsTimer->start(); } }

    // mainMenuWindowWidth
    Q_PROPERTY(int    mainMenuWindowWidth
               READ   getMainMenuWindowWidth
               WRITE  setMainMenuWindowWidth
               NOTIFY mainMenuWindowWidthChanged)
    int  getMainMenuWindowWidth() { return m_mainMenuWindowWidth; }
    void setMainMenuWindowWidth(int val) { if(val != m_mainMenuWindowWidth) { m_mainMenuWindowWidth = val;
                                                                              emit mainMenuWindowWidthChanged(val);
                                                                              saveSettingsTimer->start(); } }

    // histogramPosition
    Q_PROPERTY(QPoint histogramPosition
               READ   getHistogramPosition
               WRITE  setHistogramPosition
               NOTIFY histogramPositionChanged)
    QPoint getHistogramPosition() { return m_histogramPosition; }
    void   setHistogramPosition(QPoint val) { if(val != m_histogramPosition) { m_histogramPosition = val;
                                                                               emit histogramPositionChanged(val);
                                                                               saveSettingsTimer->start(); } }

    // histogramSize
    Q_PROPERTY(QSize  histogramSize
               READ   getHistogramSize
               WRITE  setHistogramSize
               NOTIFY histogramSizeChanged)
    QSize getHistogramSize() { return m_histogramSize; }
    void  setHistogramSize(QSize val) { if(val != m_histogramSize) { m_histogramSize = val;
                                                                     emit histogramSizeChanged(val);
                                                                     saveSettingsTimer->start(); } }

    // histogram
    Q_PROPERTY(bool   histogram
               READ   getHistogram
               WRITE  setHistogram
               NOTIFY histogramChanged)
    bool getHistogram() { return m_histogram; }
    void setHistogram(bool val) { if(val != m_histogram) { m_histogram = val;
                                                           emit histogramChanged(val);
                                                           saveSettingsTimer->start(); } }

    // histogramVersion
    Q_PROPERTY(QString histogramVersion
               READ    getHistogramVersion
               WRITE   setHistogramVersion
               NOTIFY  histogramVersionChanged)
    QString getHistogramVersion() { return m_histogramVersion; }
    void    setHistogramVersion(QString val) { if(val != m_histogramVersion) { m_histogramVersion = val;
                                                                               emit histogramVersionChanged(val);
                                                                               saveSettingsTimer->start(); } }


    /*#################################################################################################*/
    /*#################################################################################################*/

    // Set the default settings
    Q_INVOKABLE void setDefault() {

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
        setShowTransparencyMarkerBackground(true);
        setStartupLoadLastLoadedImage(false);
        setMainMenuWindowWidth(350);

        setQuickInfoHideCounter(false);
        setQuickInfoHideFilepath(true);
        setQuickInfoHideFilename(false);
        setQuickInfoHideX(false);
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

        setMetadataEnableHotEdge(true);
        setMetadataFontSize(10);
        setMetadataOpacity(204);
        setMetadataWindowWidth(350);

        setOpenDefaultView("list");
        setOpenPreview(true);
        setOpenPreviewHighQuality(false);
        setOpenZoomLevel(25);
        setOpenUserPlacesWidth(300);
        setOpenFoldersWidth(400);
        setOpenThumbnails(false);
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


    /*#################################################################################################*/
    /*#################################################################################################*/

public slots:

    // Save settings
    void saveSettings() {

        QFile file(ConfigFiles::SETTINGS_FILE());

        if(file.exists() && !file.open(QIODevice::ReadWrite))

            LOG << CURDATE << "ERROR saving settings" << NL;

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

            cont += "\n[QuickInfo]\n";

            cont += QString("QuickInfoHideCounter=%1\n").arg(int(m_quickInfoHideCounter));
            cont += QString("QuickInfoHideFilepath=%1\n").arg(int(m_quickInfoHideFilepath));
            cont += QString("QuickInfoHideFilename=%1\n").arg(int(m_quickInfoHideFilename));
            cont += QString("QuickInfoHideX=%1\n").arg(int(m_quickInfoHideX));
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

    /*#################################################################################################*/
    /*#################################################################################################*/

    // Read the current settings
    void readSettings() {

        watcherAddFileTimer->start();

        QFile file(ConfigFiles::SETTINGS_FILE());

        if(file.exists() && !file.open(QIODevice::ReadOnly))

            LOG << CURDATE  << "ERROR reading settings:" << file.errorString().trimmed().toStdString() << NL;

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


                else if(line.startsWith("QuickInfoHideCounter="))
                    setQuickInfoHideCounter(line.split("=").at(1).toInt());

                else if(line.startsWith("QuickInfoHideFilepath="))
                    setQuickInfoHideFilepath(line.split("=").at(1).toInt());

                else if(line.startsWith("QuickInfoHideFilename="))
                    setQuickInfoHideFilename(line.split("=").at(1).toInt());

                else if(line.startsWith("QuickInfoHideX="))
                    setQuickInfoHideX(line.split("=").at(1).toInt());

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

    /*#################################################################################################*/
    /*#################################################################################################*/

signals:
    void versionChanged(QString val);
    void languageChanged(QString val);
    void animationsChanged(bool val);
    void saveWindowGeometryChanged(bool val);
    void keepOnTopChanged(bool val);
    void compositeChanged(bool val);
    void startupLoadLastLoadedImageChanged(bool val);

    void backgroundColorRedChanged(int val);
    void backgroundColorGreenChanged(int val);
    void backgroundColorBlueChanged(int val);
    void backgroundColorAlphaChanged(int val);

    void backgroundImageScreenshotChanged(bool val);
    void backgroundImageUseChanged(bool val);
    void backgroundImagePathChanged(QString val);
    void backgroundImageScaleChanged(bool val);
    void backgroundImageScaleCropChanged(bool val);
    void backgroundImageStretchChanged(bool val);
    void backgroundImageCenterChanged(bool val);
    void backgroundImageTileChanged(bool val);

    void trayIconChanged(int val);
    void imageTransitionChanged(int val);
    void loopThroughFolderChanged(bool val);
    void hotEdgeWidthChanged(int val);
    void closeOnEmptyBackgroundChanged(bool val);
    void marginAroundImageChanged(int val);
    void sortbyChanged(QString val);
    void sortbyAscendingChanged(bool val);
    void mouseWheelSensitivityChanged(int val);
    void keepZoomRotationMirrorChanged(bool val);
    void fitInWindowChanged(bool val);
    void interpolationNearestNeighbourThresholdChanged(int val);
    void interpolationNearestNeighbourUpscaleChanged(bool val);
    void pixmapCacheChanged(int val);
    void showTransparencyMarkerBackgroundChanged(bool val);
    void leftButtonMouseClickAndMoveChanged(bool val);

    void quickInfoHideCounterChanged(bool val);
    void quickInfoHideFilepathChanged(bool val);
    void quickInfoHideFilenameChanged(bool val);
    void quickInfoHideXChanged(bool val);
    void quickInfoFullXChanged(bool val);
    void quickInfoCloseXSizeChanged(int val);

    void slideShowTimeChanged(int val);
    void slideShowMusicFileChanged(QString);
    void slideShowShuffleChanged(bool val);
    void slideShowLoopChanged(bool val);
    void slideShowImageTransitionChanged(int val);
    void slideShowHideQuickInfoChanged(bool val);

    void thumbnailSizeChanged(int val);
    void thumbnailCacheChanged(bool val);
    void thumbnailCacheFileChanged(bool val);
    void thumbnailSpacingBetweenChanged(int val);
    void thumbnailLiftUpChanged(int val);
    void thumbnailKeepVisibleChanged(bool val);
    void thumbnailKeepVisibleWhenNotZoomedInChanged(bool val);
    void thumbnailFontSizeChanged(int val);
    void thumbnailCenterActiveChanged(bool val);
    void thumbnailPositionChanged(QString val);
    void thumbnailFilenameInsteadChanged(bool val);
    void thumbnailFilenameInsteadFontSizeChanged(int val);
    void thumbnailDisableChanged(bool val);
    void thumbnailWriteFilenameChanged(bool val);

    void windowModeChanged(bool val);
    void windowDecorationChanged(bool val);

    void metadataFontSizeChanged(int val);
    void metadataOpacityChanged(int val);
    void metadataEnableHotEdgeChanged(bool val);
    void metaApplyRotationChanged(bool val);
    void metaGpsMapServiceChanged(QString val);
    void metaFilenameChanged(bool val);
    void metaFileTypeChanged(bool val);
    void metaFileSizeChanged(bool val);
    void metaImageNumberChanged(bool val);
    void metaDimensionsChanged(bool val);
    void metaMakeChanged(bool val);
    void metaModelChanged(bool val);
    void metaSoftwareChanged(bool val);
    void metaTimePhotoTakenChanged(bool val);
    void metaExposureTimeChanged(bool val);
    void metaFlashChanged(bool val);
    void metaIsoChanged(bool val);
    void metaSceneTypeChanged(bool val);
    void metaFLengthChanged(bool val);
    void metaFNumberChanged(bool val);
    void metaLightSourceChanged(bool val);
    void metaKeywordsChanged(bool val);
    void metaLocationChanged(bool val);
    void metaCopyrightChanged(bool val);
    void metaGpsChanged(bool val);

    void openDefaultViewChanged(QString val);
    void openPreviewChanged(bool val);
    void openPreviewHighQualityChanged(bool val);
    void openZoomLevelChanged(int val);
    void openUserPlacesWidthChanged(int val);
    void openFoldersWidthChanged(int val);
    void openThumbnailsChanged(bool val);
    void openUserPlacesStandardChanged(bool val);
    void openUserPlacesUserChanged(bool val);
    void openUserPlacesVolumesChanged(bool val);
    void openKeepLastLocationChanged(bool val);
    void openShowHiddenFilesFoldersChanged(bool val);
    void openHideUserPlacesChanged(bool val);

    void metadataWindowWidthChanged(int val);
    void mainMenuWindowWidthChanged(int val);

    void histogramChanged(bool val);
    void histogramVersionChanged(QString val);
    void histogramPositionChanged(QPoint val);
    void histogramSizeChanged(QSize val);

};

#endif // SETTINGS_H
