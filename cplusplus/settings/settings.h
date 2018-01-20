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

        verbose = false;

        // Watch the settings file (this needs to come BEFORE readSettings() as there's a bug in it (see readSettings() function)
        watcher = new QFileSystemWatcher;
        setFilesToWatcher();
        connect(watcher, SIGNAL(fileChanged(QString)), this, SLOT(readSettings()));

        // Read settings initially
        readSettings();

        // When saving the settings, we don't want to write the settings file hundreds of time within a few milliseconds,
        // but use a timer to save it once after all settings are set
        saveSettingsTimer = new QTimer;
        saveSettingsTimer->setInterval(400);
        saveSettingsTimer->setSingleShot(true);
        connect(saveSettingsTimer, SIGNAL(timeout()), this, SLOT(saveSettings()));


        /*#################################################################################################*/
        /*#################################################################################################*/

        /***************************************
         * A PROPERTY CHANGE TRIGGERS THE TIME *
         ***************************************/

        connect(this, &Settings::versionChanged,                                &Settings::saveSettingsTimerStart);
        connect(this, &Settings::languageChanged,                               &Settings::saveSettingsTimerStart);
        connect(this, &Settings::elementsFadeInChanged,                         &Settings::saveSettingsTimerStart);
        connect(this, &Settings::saveWindowGeometryChanged,                     &Settings::saveSettingsTimerStart);;
        connect(this, &Settings::keepOnTopChanged,                              &Settings::saveSettingsTimerStart);
        connect(this, &Settings::compositeChanged,                              &Settings::saveSettingsTimerStart);
        connect(this, &Settings::startupLoadLastLoadedImageChanged,             &Settings::saveSettingsTimerStart);

        connect(this, &Settings::backgroundColorRedChanged,                     &Settings::saveSettingsTimerStart);
        connect(this, &Settings::backgroundColorGreenChanged,                   &Settings::saveSettingsTimerStart);
        connect(this, &Settings::backgroundColorBlueChanged,                    &Settings::saveSettingsTimerStart);
        connect(this, &Settings::backgroundColorAlphaChanged,                   &Settings::saveSettingsTimerStart);

        connect(this, &Settings::backgroundImageScreenshotChanged,              &Settings::saveSettingsTimerStart);
        connect(this, &Settings::backgroundImageUseChanged,                     &Settings::saveSettingsTimerStart);
        connect(this, &Settings::backgroundImagePathChanged,                    &Settings::saveSettingsTimerStart);
        connect(this, &Settings::backgroundImageScaleChanged,                   &Settings::saveSettingsTimerStart);
        connect(this, &Settings::backgroundImageScaleCropChanged,               &Settings::saveSettingsTimerStart);
        connect(this, &Settings::backgroundImageStretchChanged,                 &Settings::saveSettingsTimerStart);
        connect(this, &Settings::backgroundImageCenterChanged,                  &Settings::saveSettingsTimerStart);
        connect(this, &Settings::backgroundImageTileChanged,                    &Settings::saveSettingsTimerStart);

        connect(this, &Settings::trayIconChanged,                               &Settings::saveSettingsTimerStart);
        connect(this, &Settings::transitionChanged,                             &Settings::saveSettingsTimerStart);
        connect(this, &Settings::loopThroughFolderChanged,                      &Settings::saveSettingsTimerStart);
        connect(this, &Settings::hotEdgeWidthChanged,                           &Settings::saveSettingsTimerStart);
        connect(this, &Settings::closeongreyChanged,                            &Settings::saveSettingsTimerStart);
        connect(this, &Settings::borderAroundImgChanged,                        &Settings::saveSettingsTimerStart);
        connect(this, &Settings::sortbyChanged,                                 &Settings::saveSettingsTimerStart);
        connect(this, &Settings::sortbyAscendingChanged,                        &Settings::saveSettingsTimerStart);
        connect(this, &Settings::mouseWheelSensitivityChanged,                  &Settings::saveSettingsTimerStart);
        connect(this, &Settings::keepZoomRotationMirrorChanged,                 &Settings::saveSettingsTimerStart);
        connect(this, &Settings::fitInWindowChanged,                            &Settings::saveSettingsTimerStart);
        connect(this, &Settings::interpolationNearestNeighbourThresholdChanged, &Settings::saveSettingsTimerStart);
        connect(this, &Settings::interpolationNearestNeighbourUpscaleChanged,   &Settings::saveSettingsTimerStart);
        connect(this, &Settings::pixmapCacheChanged,                            &Settings::saveSettingsTimerStart);

        connect(this, &Settings::leftButtonMouseClickAndMoveChanged,            &Settings::saveSettingsTimerStart);

        connect(this, &Settings::quickInfoHideCounterChanged,                   &Settings::saveSettingsTimerStart);
        connect(this, &Settings::quickInfoHideFilepathChanged,                  &Settings::saveSettingsTimerStart);
        connect(this, &Settings::quickInfoHideFilenameChanged,                  &Settings::saveSettingsTimerStart);
        connect(this, &Settings::quickInfoHideXChanged,                         &Settings::saveSettingsTimerStart);
        connect(this, &Settings::quickInfoFullXChanged,                         &Settings::saveSettingsTimerStart);
        connect(this, &Settings::quickInfoCloseXSizeChanged,                    &Settings::saveSettingsTimerStart);

        connect(this, &Settings::slideShowTimeChanged,                          &Settings::saveSettingsTimerStart);
        connect(this, &Settings::slideShowMusicFileChanged,                     &Settings::saveSettingsTimerStart);
        connect(this, &Settings::slideShowShuffleChanged,                       &Settings::saveSettingsTimerStart);
        connect(this, &Settings::slideShowLoopChanged,                          &Settings::saveSettingsTimerStart);
        connect(this, &Settings::slideShowImageTransitionChanged,               &Settings::saveSettingsTimerStart);
        connect(this, &Settings::slideShowHideQuickInfoChanged,                 &Settings::saveSettingsTimerStart);

        connect(this, &Settings::thumbnailSizeChanged,                          &Settings::saveSettingsTimerStart);
        connect(this, &Settings::thumbnailCacheChanged,                         &Settings::saveSettingsTimerStart);
        connect(this, &Settings::thumbnailCacheFileChanged,                     &Settings::saveSettingsTimerStart);
        connect(this, &Settings::thumbnailSpacingBetweenChanged,                &Settings::saveSettingsTimerStart);
        connect(this, &Settings::thumbnailLiftUpChanged,                        &Settings::saveSettingsTimerStart);
        connect(this, &Settings::thumbnailKeepVisibleChanged,                   &Settings::saveSettingsTimerStart);
        connect(this, &Settings::thumbnailKeepVisibleWhenNotZoomedInChanged,    &Settings::saveSettingsTimerStart);
        connect(this, &Settings::thumbnailFontSizeChanged,                      &Settings::saveSettingsTimerStart);
        connect(this, &Settings::thumbnailCenterActiveChanged,                  &Settings::saveSettingsTimerStart);
        connect(this, &Settings::thumbnailPositionChanged,                      &Settings::saveSettingsTimerStart);
        connect(this, &Settings::thumbnailFilenameInsteadChanged,               &Settings::saveSettingsTimerStart);
        connect(this, &Settings::thumbnailFilenameInsteadFontSizeChanged,       &Settings::saveSettingsTimerStart);
        connect(this, &Settings::thumbnailDisableChanged,                       &Settings::saveSettingsTimerStart);
        connect(this, &Settings::thumbnailWriteFilenameChanged,                 &Settings::saveSettingsTimerStart);

        connect(this, &Settings::windowModeChanged,                             &Settings::saveSettingsTimerStart);
        connect(this, &Settings::windowDecorationChanged,                       &Settings::saveSettingsTimerStart);

        connect(this, &Settings::metadataFontSizeChanged,                       &Settings::saveSettingsTimerStart);
        connect(this, &Settings::metadataOpacityChanged,                        &Settings::saveSettingsTimerStart);
        connect(this, &Settings::metadataEnableHotEdgeChanged,                  &Settings::saveSettingsTimerStart);
        connect(this, &Settings::metaApplyRotationChanged,                           &Settings::saveSettingsTimerStart);
        connect(this, &Settings::metaGpsMapServiceChanged,                      &Settings::saveSettingsTimerStart);
        connect(this, &Settings::metaFilenameChanged,                           &Settings::saveSettingsTimerStart);
        connect(this, &Settings::metaFileTypeChanged,                           &Settings::saveSettingsTimerStart);
        connect(this, &Settings::metaFileSizeChanged,                           &Settings::saveSettingsTimerStart);
        connect(this, &Settings::metaImageNumberChanged,                        &Settings::saveSettingsTimerStart);
        connect(this, &Settings::metaDimensionsChanged,                         &Settings::saveSettingsTimerStart);
        connect(this, &Settings::metaMakeChanged,                               &Settings::saveSettingsTimerStart);
        connect(this, &Settings::metaModelChanged,                              &Settings::saveSettingsTimerStart);
        connect(this, &Settings::metaSoftwareChanged,                           &Settings::saveSettingsTimerStart);
        connect(this, &Settings::metaTimePhotoTakenChanged,                     &Settings::saveSettingsTimerStart);
        connect(this, &Settings::metaExposureTimeChanged,                       &Settings::saveSettingsTimerStart);
        connect(this, &Settings::metaFlashChanged,                              &Settings::saveSettingsTimerStart);
        connect(this, &Settings::metaIsoChanged,                                &Settings::saveSettingsTimerStart);
        connect(this, &Settings::metaSceneTypeChanged,                          &Settings::saveSettingsTimerStart);
        connect(this, &Settings::metaFLengthChanged,                            &Settings::saveSettingsTimerStart);
        connect(this, &Settings::metaFNumberChanged,                            &Settings::saveSettingsTimerStart);
        connect(this, &Settings::metaLightSourceChanged,                        &Settings::saveSettingsTimerStart);
        connect(this, &Settings::metaKeywordsChanged,                           &Settings::saveSettingsTimerStart);
        connect(this, &Settings::metaLocationChanged,                           &Settings::saveSettingsTimerStart);
        connect(this, &Settings::metaCopyrightChanged,                          &Settings::saveSettingsTimerStart);
        connect(this, &Settings::metaGpsChanged,                                &Settings::saveSettingsTimerStart);

        connect(this, &Settings::openDefaultViewChanged,                        &Settings::saveSettingsTimerStart);
        connect(this, &Settings::openPreviewChanged,                            &Settings::saveSettingsTimerStart);
        connect(this, &Settings::openZoomLevelChanged,                          &Settings::saveSettingsTimerStart);
        connect(this, &Settings::openUserPlacesWidthChanged,                    &Settings::saveSettingsTimerStart);
        connect(this, &Settings::openFoldersWidthChanged,                       &Settings::saveSettingsTimerStart);
        connect(this, &Settings::openThumbnailsChanged,                         &Settings::saveSettingsTimerStart);
        connect(this, &Settings::openPreviewHighQualityChanged,                 &Settings::saveSettingsTimerStart);
        connect(this, &Settings::openUserPlacesStandardChanged,                 &Settings::saveSettingsTimerStart);
        connect(this, &Settings::openUserPlacesUserChanged,                     &Settings::saveSettingsTimerStart);
        connect(this, &Settings::openUserPlacesVolumesChanged,                  &Settings::saveSettingsTimerStart);
        connect(this, &Settings::openKeepLastLocationChanged,                   &Settings::saveSettingsTimerStart);
        connect(this, &Settings::openShowHiddenFilesFoldersChanged,             &Settings::saveSettingsTimerStart);

        connect(this, &Settings::metadataWindowWidthChanged,                    &Settings::saveSettingsTimerStart);
        connect(this, &Settings::mainMenuWindowWidthChanged,                    &Settings::saveSettingsTimerStart);

        connect(this, &Settings::histogramPositionChanged,                      &Settings::saveSettingsTimerStart);
        connect(this, &Settings::histogramSizeChanged,                          &Settings::saveSettingsTimerStart);
        connect(this, &Settings::histogramChanged,                              &Settings::saveSettingsTimerStart);
        connect(this, &Settings::histogramVersionChanged,                       &Settings::saveSettingsTimerStart);

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

    bool    verbose;

    QString version;
    QString versionInTextFile;  // differs from 'version' only when PhotoQt has been updated
    QString language;
    bool    elementsFadeIn;
    bool    saveWindowGeometry;
    bool    keepOnTop;
    bool    composite;
    bool    startupLoadLastLoadedImage;

    int     backgroundColorRed;
    int     backgroundColorGreen;
    int     backgroundColorBlue;
    int     backgroundColorAlpha;
    bool    backgroundImageScreenshot;
    bool    backgroundImageUse;
    QString backgroundImagePath;
    bool    backgroundImageScale;
    bool    backgroundImageScaleCrop;
    bool    backgroundImageStretch;
    bool    backgroundImageCenter;
    bool    backgroundImageTile;

    int         trayIcon;
    int     imageTransition;
    bool    loopThroughFolder;
    int     hotEdgeWidth;
    bool    closeOnEmptyBackground;
    int     marginAroundImage;
    QString sortby;
    bool    sortbyAscending;
    int     mouseWheelSensitivity;
    bool    keepZoomRotationMirror;
    bool    fitInWindow;
    int     interpolationNearestNeighbourThreshold;
    bool    interpolationNearestNeighbourUpscale;
    int     pixmapCache;
    bool    showTransparencyMarkerBackground;
    bool    leftButtonMouseClickAndMove;

    bool    quickInfoHideCounter;
    bool    quickInfoHideFilepath;
    bool    quickInfoHideFilename;
    bool    quickInfoHideX;
    bool    quickInfoFullX;
    int     quickInfoCloseXSize;

    int     slideShowTime;
    int     slideShowImageTransition;
    QString slideShowMusicFile;
    bool    slideShowShuffle;
    bool    slideShowLoop;
    bool    slideShowHideQuickInfo;

    int     thumbnailSize;
    QString thumbnailPosition;
    bool    thumbnailCache;
    bool    thumbnailCacheFile;
    int     thumbnailSpacingBetween;
    int     thumbnailLiftUp;
    bool    thumbnailKeepVisible;
    bool    thumbnailKeepVisibleWhenNotZoomedIn;
    bool    thumbnailCenterActive;
    bool    thumbnailFilenameInstead;
    int     thumbnailFilenameInsteadFontSize;
    bool    thumbnailDisable;
    bool    thumbnailWriteFilename;
    int     thumbnailFontSize;

    bool    windowMode;
    bool    windowDecoration;

    bool    metadataEnableHotEdge;
    bool    metaApplyRotation;
    QString metaGpsMapService;
    int     metadataFontSize;
    int     metadataOpacity;
    bool    metaFilename;
    bool    metaFileType;
    bool    metaFileSize;
    bool    metaImageNumber;
    bool    metaDimensions;
    bool    metaMake;
    bool    metaModel;
    bool    metaSoftware;
    bool    metaTimePhotoTaken;
    bool    metaExposureTime;
    bool    metaFlash;
    bool    metaIso;
    bool    metaSceneType;
    bool    metaFLength;
    bool    metaFNumber;
    bool    metaLightSource;
    bool    metaKeywords;
    bool    metaLocation;
    bool    metaCopyright;
    bool    metaGps;

    QString openDefaultView;
    bool    openPreview;
    int     openZoomLevel;
    int     openUserPlacesWidth;
    int     openFoldersWidth;
    bool    openThumbnails;
    bool    openPreviewHighQuality;
    bool    openUserPlacesStandard;
    bool    openUserPlacesUser;
    bool    openUserPlacesVolumes;
    bool    openKeepLastLocation;
    bool    openShowHiddenFilesFolders;

    int     metadataWindowWidth;
    int     mainMenuWindowWidth;

    bool    histogram;
    QPoint  histogramPosition;
    QSize   histogramSize;
    QString histogramVersion;


    /*#################################################################################################*/
    /*#################################################################################################*/

    /**********************
     * Q_PROPERTY methods *
     **********************/

    Q_PROPERTY(QString version                          MEMBER version                          NOTIFY versionChanged)
    Q_PROPERTY(QString language                         MEMBER language                         NOTIFY languageChanged)
    Q_PROPERTY(bool    elementsFadeIn                   MEMBER elementsFadeIn                   NOTIFY elementsFadeInChanged)
    Q_PROPERTY(bool    saveWindowGeometry               MEMBER saveWindowGeometry               NOTIFY saveWindowGeometryChanged)
    Q_PROPERTY(bool    keepOnTop                        MEMBER keepOnTop                        NOTIFY keepOnTopChanged)
    Q_PROPERTY(bool    composite                        MEMBER composite                        NOTIFY compositeChanged)
    Q_PROPERTY(bool    startupLoadLastLoadedImage       MEMBER startupLoadLastLoadedImage       NOTIFY startupLoadLastLoadedImageChanged)

    Q_PROPERTY(int     backgroundColorRed               MEMBER backgroundColorRed               NOTIFY backgroundColorRedChanged)
    Q_PROPERTY(int     backgroundColorGreen             MEMBER backgroundColorGreen             NOTIFY backgroundColorGreenChanged)
    Q_PROPERTY(int     backgroundColorBlue              MEMBER backgroundColorBlue              NOTIFY backgroundColorBlueChanged)
    Q_PROPERTY(int     backgroundColorAlpha             MEMBER backgroundColorAlpha             NOTIFY backgroundColorAlphaChanged)

    Q_PROPERTY(bool    backgroundImageScreenshot        MEMBER backgroundImageScreenshot        NOTIFY backgroundImageScreenshotChanged)
    Q_PROPERTY(bool    backgroundImageUse               MEMBER backgroundImageUse               NOTIFY backgroundImageUseChanged)
    Q_PROPERTY(QString backgroundImagePath              MEMBER backgroundImagePath              NOTIFY backgroundImagePathChanged)
    Q_PROPERTY(bool    backgroundImageScale             MEMBER backgroundImageScale             NOTIFY backgroundImageScaleChanged)
    Q_PROPERTY(bool    backgroundImageScaleCrop         MEMBER backgroundImageScaleCrop         NOTIFY backgroundImageScaleCropChanged)
    Q_PROPERTY(bool    backgroundImageStretch           MEMBER backgroundImageStretch           NOTIFY backgroundImageStretchChanged)
    Q_PROPERTY(bool    backgroundImageCenter            MEMBER backgroundImageCenter            NOTIFY backgroundImageCenterChanged)
    Q_PROPERTY(bool    backgroundImageTile              MEMBER backgroundImageTile              NOTIFY backgroundImageTileChanged)

    Q_PROPERTY(int     trayIcon                         MEMBER trayIcon                         NOTIFY trayIconChanged)
    Q_PROPERTY(int     imageTransition                  MEMBER imageTransition                  NOTIFY transitionChanged)
    Q_PROPERTY(bool    loopThroughFolder                MEMBER loopThroughFolder                NOTIFY loopThroughFolderChanged)
    Q_PROPERTY(int     hotEdgeWidth                     MEMBER hotEdgeWidth                     NOTIFY hotEdgeWidthChanged)
    Q_PROPERTY(bool    closeOnEmptyBackground           MEMBER closeOnEmptyBackground           NOTIFY closeongreyChanged)
    Q_PROPERTY(int     marginAroundImage                MEMBER marginAroundImage                NOTIFY borderAroundImgChanged)
    Q_PROPERTY(QString sortby                           MEMBER sortby                           NOTIFY sortbyChanged)
    Q_PROPERTY(bool    sortbyAscending                  MEMBER sortbyAscending                  NOTIFY sortbyAscendingChanged)
    Q_PROPERTY(int     mouseWheelSensitivity            MEMBER mouseWheelSensitivity            NOTIFY mouseWheelSensitivityChanged)
    Q_PROPERTY(bool    keepZoomRotationMirror           MEMBER keepZoomRotationMirror           NOTIFY keepZoomRotationMirrorChanged)
    Q_PROPERTY(bool    fitInWindow                      MEMBER fitInWindow                      NOTIFY fitInWindowChanged)
    Q_PROPERTY(int     interpolationNearestNeighbourThreshold
                                                        MEMBER interpolationNearestNeighbourThreshold
                                                                                                NOTIFY interpolationNearestNeighbourThresholdChanged)
    Q_PROPERTY(bool    interpolationNearestNeighbourUpscale
                                                        MEMBER interpolationNearestNeighbourUpscale
                                                                                                NOTIFY interpolationNearestNeighbourUpscaleChanged)
    Q_PROPERTY(int     pixmapCache                      MEMBER pixmapCache                      NOTIFY pixmapCacheChanged)
    Q_PROPERTY(bool    showTransparencyMarkerBackground MEMBER showTransparencyMarkerBackground NOTIFY showTransparencyMarkerBackgroundChanged)
    Q_PROPERTY(bool    leftButtonMouseClickAndMove      MEMBER leftButtonMouseClickAndMove      NOTIFY leftButtonMouseClickAndMoveChanged)

    Q_PROPERTY(bool    quickInfoHideCounter             MEMBER quickInfoHideCounter             NOTIFY quickInfoHideCounterChanged)
    Q_PROPERTY(bool    quickInfoHideFilepath            MEMBER quickInfoHideFilepath            NOTIFY quickInfoHideFilepathChanged)
    Q_PROPERTY(bool    quickInfoHideFilename            MEMBER quickInfoHideFilename            NOTIFY quickInfoHideFilenameChanged)
    Q_PROPERTY(bool    quickInfoHideX                   MEMBER quickInfoHideX                   NOTIFY quickInfoHideXChanged)
    Q_PROPERTY(bool    quickInfoFullX                   MEMBER quickInfoFullX                   NOTIFY quickInfoFullXChanged)
    Q_PROPERTY(int     quickInfoCloseXSize              MEMBER quickInfoCloseXSize              NOTIFY quickInfoCloseXSizeChanged)

    Q_PROPERTY(int     slideShowTime                    MEMBER slideShowTime                    NOTIFY slideShowTimeChanged)
    Q_PROPERTY(int     slideShowImageTransition         MEMBER slideShowImageTransition         NOTIFY slideShowImageTransitionChanged)
    Q_PROPERTY(QString slideShowMusicFile               MEMBER slideShowMusicFile               NOTIFY slideShowMusicFileChanged)
    Q_PROPERTY(bool    slideShowShuffle                 MEMBER slideShowShuffle                 NOTIFY slideShowShuffleChanged)
    Q_PROPERTY(bool    slideShowLoop                    MEMBER slideShowLoop                    NOTIFY slideShowLoopChanged)
    Q_PROPERTY(bool    slideShowHideQuickInfo           MEMBER slideShowHideQuickInfo           NOTIFY slideShowHideQuickInfoChanged)

    Q_PROPERTY(int     thumbnailSize                    MEMBER thumbnailSize                    NOTIFY thumbnailSizeChanged)
    Q_PROPERTY(QString thumbnailPosition                MEMBER thumbnailPosition                NOTIFY thumbnailPositionChanged)
    Q_PROPERTY(bool    thumbnailCache                   MEMBER thumbnailCache                   NOTIFY thumbnailCacheChanged)
    Q_PROPERTY(bool    thumbnailCacheFile               MEMBER thumbnailCacheFile               NOTIFY thumbnailCacheFileChanged)
    Q_PROPERTY(int     thumbnailSpacingBetween          MEMBER thumbnailSpacingBetween          NOTIFY thumbnailSpacingBetweenChanged)
    Q_PROPERTY(int     thumbnailLiftUp                  MEMBER thumbnailLiftUp                  NOTIFY thumbnailLiftUpChanged)
    Q_PROPERTY(bool    thumbnailKeepVisible             MEMBER thumbnailKeepVisible             NOTIFY thumbnailKeepVisibleChanged)
    Q_PROPERTY(bool    thumbnailKeepVisibleWhenNotZoomedIn
                                                        MEMBER thumbnailKeepVisibleWhenNotZoomedIn
                                                                                                NOTIFY thumbnailKeepVisibleWhenNotZoomedInChanged)
    Q_PROPERTY(bool    thumbnailCenterActive            MEMBER thumbnailCenterActive            NOTIFY thumbnailCenterActiveChanged)
    Q_PROPERTY(bool    thumbnailFilenameInstead         MEMBER thumbnailFilenameInstead         NOTIFY thumbnailFilenameInsteadChanged)
    Q_PROPERTY(int     thumbnailFilenameInsteadFontSize MEMBER thumbnailFilenameInsteadFontSize NOTIFY thumbnailFilenameInsteadFontSizeChanged)
    Q_PROPERTY(bool    thumbnailDisable                 MEMBER thumbnailDisable                 NOTIFY thumbnailDisableChanged)
    Q_PROPERTY(bool    thumbnailWriteFilename           MEMBER thumbnailWriteFilename           NOTIFY thumbnailWriteFilenameChanged)
    Q_PROPERTY(int     thumbnailFontSize                MEMBER thumbnailFontSize                NOTIFY thumbnailFontSizeChanged)

    Q_PROPERTY(bool    windowMode                       MEMBER windowMode                       NOTIFY windowModeChanged)
    Q_PROPERTY(bool    windowDecoration                 MEMBER windowDecoration                 NOTIFY windowDecorationChanged)

    Q_PROPERTY(bool    metadataEnableHotEdge            MEMBER metadataEnableHotEdge            NOTIFY metadataEnableHotEdgeChanged)
    Q_PROPERTY(bool    metaApplyRotation                MEMBER metaApplyRotation                NOTIFY metaApplyRotationChanged)
    Q_PROPERTY(QString metaGpsMapService                MEMBER metaGpsMapService                NOTIFY metaGpsMapServiceChanged)
    Q_PROPERTY(int     metadataFontSize                 MEMBER metadataFontSize                 NOTIFY metadataFontSizeChanged)
    Q_PROPERTY(int     metadataOpacity                  MEMBER metadataOpacity                  NOTIFY metadataOpacityChanged)
    Q_PROPERTY(bool    metaFilename                     MEMBER metaFilename                     NOTIFY metaFilenameChanged)
    Q_PROPERTY(bool    metaFileType                     MEMBER metaFileType                     NOTIFY metaFileTypeChanged)
    Q_PROPERTY(bool    metaFileSize                     MEMBER metaFileSize                     NOTIFY metaFileSizeChanged)
    Q_PROPERTY(bool    metaImageNumber                  MEMBER metaImageNumber                  NOTIFY metaImageNumberChanged)
    Q_PROPERTY(bool    metaDimensions                   MEMBER metaDimensions                   NOTIFY metaDimensionsChanged)
    Q_PROPERTY(bool    metaMake                         MEMBER metaMake                         NOTIFY metaMakeChanged)
    Q_PROPERTY(bool    metaModel                        MEMBER metaModel                        NOTIFY metaModelChanged)
    Q_PROPERTY(bool    metaSoftware                     MEMBER metaSoftware                     NOTIFY metaSoftwareChanged)
    Q_PROPERTY(bool    metaTimePhotoTaken               MEMBER metaTimePhotoTaken               NOTIFY metaTimePhotoTakenChanged)
    Q_PROPERTY(bool    metaExposureTime                 MEMBER metaExposureTime                 NOTIFY metaExposureTimeChanged)
    Q_PROPERTY(bool    metaFlash                        MEMBER metaFlash                        NOTIFY metaFlashChanged)
    Q_PROPERTY(bool    metaIso                          MEMBER metaIso                          NOTIFY metaIsoChanged)
    Q_PROPERTY(bool    metaSceneType                    MEMBER metaSceneType                    NOTIFY metaSceneTypeChanged)
    Q_PROPERTY(bool    metaFLength                      MEMBER metaFLength                      NOTIFY metaFLengthChanged)
    Q_PROPERTY(bool    metaFNumber                      MEMBER metaFNumber                      NOTIFY metaFNumberChanged)
    Q_PROPERTY(bool    metaLightSource                  MEMBER metaLightSource                  NOTIFY metaLightSourceChanged)
    Q_PROPERTY(bool    metaKeywords                     MEMBER metaKeywords                     NOTIFY metaKeywordsChanged)
    Q_PROPERTY(bool    metaLocation                     MEMBER metaLocation                     NOTIFY metaLocationChanged)
    Q_PROPERTY(bool    metaCopyright                    MEMBER metaCopyright                    NOTIFY metaCopyrightChanged)
    Q_PROPERTY(bool    metaGps                          MEMBER metaGps                          NOTIFY metaGpsChanged)

    Q_PROPERTY(QString openDefaultView                  MEMBER openDefaultView                  NOTIFY openDefaultViewChanged)
    Q_PROPERTY(bool    openPreview                      MEMBER openPreview                      NOTIFY openPreviewChanged)
    Q_PROPERTY(int     openZoomLevel                    MEMBER openZoomLevel                    NOTIFY openZoomLevelChanged)
    Q_PROPERTY(int     openUserPlacesWidth              MEMBER openUserPlacesWidth              NOTIFY openUserPlacesWidthChanged)
    Q_PROPERTY(int     openFoldersWidth                 MEMBER openFoldersWidth                 NOTIFY openFoldersWidthChanged)
    Q_PROPERTY(bool    openThumbnails                   MEMBER openThumbnails                   NOTIFY openThumbnailsChanged)
    Q_PROPERTY(bool    openPreviewHighQuality           MEMBER openPreviewHighQuality           NOTIFY openPreviewHighQualityChanged)
    Q_PROPERTY(bool    openUserPlacesStandard           MEMBER openUserPlacesStandard           NOTIFY openUserPlacesStandardChanged)
    Q_PROPERTY(bool    openUserPlacesUser               MEMBER openUserPlacesUser               NOTIFY openUserPlacesUserChanged)
    Q_PROPERTY(bool    openUserPlacesVolumes            MEMBER openUserPlacesVolumes            NOTIFY openUserPlacesVolumesChanged)
    Q_PROPERTY(bool    openKeepLastLocation             MEMBER openKeepLastLocation             NOTIFY openKeepLastLocationChanged)
    Q_PROPERTY(bool    openShowHiddenFilesFolders       MEMBER openShowHiddenFilesFolders       NOTIFY openShowHiddenFilesFoldersChanged)

    Q_PROPERTY(int     metadataWindowWidth              MEMBER metadataWindowWidth              NOTIFY metadataWindowWidthChanged)
    Q_PROPERTY(int     mainMenuWindowWidth              MEMBER mainMenuWindowWidth              NOTIFY mainMenuWindowWidthChanged)

    Q_PROPERTY(QPoint  histogramPosition                MEMBER histogramPosition                NOTIFY histogramPositionChanged)
    Q_PROPERTY(QSize   histogramSize                    MEMBER histogramSize                    NOTIFY histogramSizeChanged)
    Q_PROPERTY(bool    histogram                        MEMBER histogram                        NOTIFY histogramChanged)
    Q_PROPERTY(QString histogramVersion                 MEMBER histogramVersion                 NOTIFY histogramVersionChanged)


    /*#################################################################################################*/
    /*#################################################################################################*/

    // Set the default settings
    Q_INVOKABLE void setDefault() {

        version                    = QString::fromStdString(VERSION);
        versionInTextFile          = "";

        sortby                     = "name";
        sortbyAscending            = true;

        windowMode                 = true;
        windowDecoration           = false;

        elementsFadeIn             = true;
        saveWindowGeometry         = false;
        keepOnTop                  = false;

        language                   = QLocale::system().name();
        backgroundColorRed         = 0;
        backgroundColorGreen       = 0;
        backgroundColorBlue        = 0;
        backgroundColorAlpha       = 190;

#ifdef Q_OS_WIN
        backgroundImageScreenshot  = (QtWin::isCompositionEnabled() ? false : true);
#else
        backgroundImageScreenshot  = false;
#endif
        backgroundImageUse         = false;
        backgroundImagePath        = "";
        backgroundImageScale       = true;
        backgroundImageScaleCrop   = false;
        backgroundImageStretch     = false;
        backgroundImageCenter      = false;
        backgroundImageTile        = false;

#ifdef Q_OS_WIN
        composite                              = (QtWin::isCompositionEnabled() ? true : false);
#else
        composite                              = true;
#endif
        trayIcon                               = 0;
        imageTransition                        = 1;
        loopThroughFolder                      = true;
        hotEdgeWidth                           = 4;
        closeOnEmptyBackground                 = false;
        marginAroundImage                      = 5;
        mouseWheelSensitivity                  = 1;
        keepZoomRotationMirror                 = false;
        fitInWindow                            = false;
        interpolationNearestNeighbourThreshold = 100;
        interpolationNearestNeighbourUpscale   = false;
        pixmapCache                            = 128;
        leftButtonMouseClickAndMove            = true;
        showTransparencyMarkerBackground       = true;
        startupLoadLastLoadedImage             = false;
        mainMenuWindowWidth                    = 350;

        quickInfoHideCounter                   = false;
        quickInfoHideFilepath                  = true;
        quickInfoHideFilename                  = false;
        quickInfoHideX                         = false;
        quickInfoFullX                         = true;
        quickInfoCloseXSize                    = 10;

        thumbnailSize                          = 80;
        thumbnailPosition                      = "Bottom";
        thumbnailCache                         = true;
#ifdef Q_OS_WIN
        thumbnailCacheFile                     = false;
#else
        thumbnailCacheFile                     = true;
#endif
        thumbnailSpacingBetween                = 0;
        thumbnailLiftUp                        = 6;
        thumbnailKeepVisible                   = false;
        thumbnailKeepVisibleWhenNotZoomedIn    = false;
        thumbnailCenterActive                  = false;
        thumbnailDisable                       = false;
        thumbnailWriteFilename                 = true;
        thumbnailFontSize                      = 7;
        thumbnailFilenameInstead               = false;
        thumbnailFilenameInsteadFontSize       = 8;

        slideShowTime              = 5;
        slideShowImageTransition   = 4;
        slideShowMusicFile         = "";
        slideShowShuffle           = false;
        slideShowLoop              = true;
        slideShowHideQuickInfo     = true;

        metaFilename               = true;
        metaFileType               = true;
        metaFileSize               = true;
        metaImageNumber            = true;
        metaDimensions             = true;
        metaMake                   = true;
        metaModel                  = true;
        metaSoftware               = true;
        metaTimePhotoTaken         = true;
        metaExposureTime           = true;
        metaFlash                  = true;
        metaIso                    = true;
        metaSceneType              = true;
        metaFLength                = true;
        metaFNumber                = true;
        metaLightSource            = true;
        metaKeywords               = true;
        metaLocation               = true;
        metaCopyright              = true;
        metaGps                    = true;
        metaApplyRotation          = true;
        metaGpsMapService          = "openstreetmap.org";

        metadataEnableHotEdge      = true;
        metadataFontSize           = 10;
        metadataOpacity            = 200;
        metadataWindowWidth        = 350;

        openDefaultView            = "list";
        openPreview                = true;
        openPreviewHighQuality     = false;
        openZoomLevel              = 25;
        openUserPlacesWidth        = 200;
        openFoldersWidth           = 400;
        openThumbnails             = false;
        openUserPlacesStandard     = true;
        openUserPlacesUser         = true;
        openUserPlacesVolumes      = true;
        openKeepLastLocation       = false;
        openShowHiddenFilesFolders = false;

        histogram                  = false;
        histogramVersion           = "color";
        histogramPosition          = QPoint(100,100);
        histogramSize              = QSize(300,200);

    }


    /*#################################################################################################*/
    /*#################################################################################################*/

public slots:

    void setFilesToWatcher() {

        ++avoidInfiniteLoopSettingFilesToWatcher;

        if(!QFile(ConfigFiles::SETTINGS_FILE()).exists() && avoidInfiniteLoopSettingFilesToWatcher < 100)
            QTimer::singleShot(250, this, SLOT(setFilesToWatcher()));
        else
            watcher->addPath(ConfigFiles::SETTINGS_FILE());
    }

    // Save settings
    void saveSettings() {

        QFile file(ConfigFiles::SETTINGS_FILE());

        if(!file.open(QIODevice::ReadWrite))

            LOG << CURDATE << "ERROR saving settings" << NL;

        else {

            if(verbose) LOG << CURDATE << "Save Settings" << NL;

            file.close();
            file.remove();
            file.open(QIODevice::ReadWrite);

            QTextStream out(&file);

            QString cont = "Version=" + version + "\n";

            cont += QString("Language=%1\n")    .arg(language);
            cont += QString("WindowMode=%1\n")  .arg(int(windowMode));
            cont += QString("WindowDecoration=%1\n").arg(int(windowDecoration));
            cont += QString("ElementsFadeIn=%1\n").arg(int(elementsFadeIn));
            cont += QString("SaveWindowGeometry=%1\n").arg(int(saveWindowGeometry));
            cont += QString("KeepOnTop=%1\n").arg(int(keepOnTop));
            cont += QString("StartupLoadLastLoadedImage=%1\n").arg(int(startupLoadLastLoadedImage));

            cont += "\n[Look]\n";

            cont += QString("Composite=%1\n").arg(int(composite));
            cont += QString("BackgroundColorRed=%1\n").arg(backgroundColorRed);
            cont += QString("BackgroundColorGreen=%1\n").arg(backgroundColorGreen);
            cont += QString("BackgroundColorBlue=%1\n").arg(backgroundColorBlue);
            cont += QString("BackgroundColorAlpha=%1\n").arg(backgroundColorAlpha);
            cont += QString("BackgroundImageScreenshot=%1\n").arg(backgroundImageScreenshot);
            cont += QString("BackgroundImageUse=%1\n").arg(backgroundImageUse);
            cont += QString("BackgroundImagePath=%1\n").arg(backgroundImagePath);
            cont += QString("BackgroundImageScale=%1\n").arg(backgroundImageScale);
            cont += QString("BackgroundImageScaleCrop=%1\n").arg(backgroundImageScaleCrop);
            cont += QString("BackgroundImageStretch=%1\n").arg(backgroundImageStretch);
            cont += QString("BackgroundImageCenter=%1\n").arg(backgroundImageCenter);
            cont += QString("BackgroundImageTile=%1\n").arg(backgroundImageTile);

            cont += "\n[Behaviour]\n";

            cont += QString("TrayIcon=%1\n").arg(trayIcon);
            cont += QString("ImageTransition=%1\n").arg(imageTransition);
            cont += QString("LoopThroughFolder=%1\n").arg(int(loopThroughFolder));
            cont += QString("HotEdgeWidth=%1\n").arg(hotEdgeWidth);
            cont += QString("CloseOnEmptyBackground=%1\n").arg(int(closeOnEmptyBackground));
            cont += QString("MarginAroundImage=%1\n").arg(marginAroundImage);
            cont += QString("SortImagesBy=%1\n").arg(sortby);
            cont += QString("SortImagesAscending=%1\n").arg(int(sortbyAscending));
            cont += QString("MouseWheelSensitivity=%1\n").arg(mouseWheelSensitivity);
            cont += QString("KeepZoomRotationMirror=%1\n").arg(int(keepZoomRotationMirror));
            cont += QString("FitInWindow=%1\n").arg(int(fitInWindow));
            cont += QString("InterpolationNearestNeighbourThreshold=%1\n").arg(interpolationNearestNeighbourThreshold);
            cont += QString("InterpolationNearestNeighbourUpscale=%1\n").arg(int(interpolationNearestNeighbourUpscale));
            cont += QString("PixmapCache=%1\n").arg(pixmapCache);
            cont += QString("ShowTransparencyMarkerBackground=%1\n").arg(int(showTransparencyMarkerBackground));
            cont += QString("LeftButtonMouseClickAndMove=%1\n").arg(int(leftButtonMouseClickAndMove));

            cont += "\n[QuickInfo]\n";

            cont += QString("QuickInfoHideCounter=%1\n").arg(int(quickInfoHideCounter));
            cont += QString("QuickInfoHideFilepath=%1\n").arg(int(quickInfoHideFilepath));
            cont += QString("QuickInfoHideFilename=%1\n").arg(int(quickInfoHideFilename));
            cont += QString("QuickInfoHideX=%1\n").arg(int(quickInfoHideX));
            cont += QString("QuickInfoFullX=%1\n").arg(int(quickInfoFullX));
            cont += QString("QuickInfoCloseXSize=%1\n").arg(quickInfoCloseXSize);

            cont += "\n[Thumbnail]\n";

            cont += QString("ThumbnailSize=%1\n").arg(thumbnailSize);
            cont += QString("ThumbnailPosition=%1\n").arg(thumbnailPosition);
            cont += QString("ThumbnailCache=%1\n").arg(int(thumbnailCache));
            cont += QString("ThumbnailCacheFile=%1\n").arg(int(thumbnailCacheFile));
            cont += QString("ThumbnailSpacingBetween=%1\n").arg(thumbnailSpacingBetween);
            cont += QString("ThumbnailLiftUp=%1\n").arg(thumbnailLiftUp);
            cont += QString("ThumbnailKeepVisible=%1\n").arg(int(thumbnailKeepVisible));
            cont += QString("ThumbnailKeepVisibleWhenNotZoomedIn=%1\n").arg(int(thumbnailKeepVisibleWhenNotZoomedIn));
            cont += QString("ThumbnailCenterActive=%1\n").arg(int(thumbnailCenterActive));
            cont += QString("ThumbnailFilenameInstead=%1\n").arg(int(thumbnailFilenameInstead));
            cont += QString("ThumbnailFilenameInsteadFontSize=%1\n").arg(thumbnailFilenameInsteadFontSize);
            cont += QString("ThumbnailDisable=%1\n").arg(int(thumbnailDisable));
            cont += QString("ThumbnailWriteFilename=%1\n").arg(int(thumbnailWriteFilename));
            cont += QString("ThumbnailFontSize=%1\n").arg(thumbnailFontSize);

            cont += "\n[Slideshow]\n";

            cont += QString("SlideShowTime=%1\n").arg(slideShowTime);
            cont += QString("SlideShowImageTransition=%1\n").arg(slideShowImageTransition);
            cont += QString("SlideShowMusicFile=%1\n").arg(slideShowMusicFile);
            cont += QString("SlideShowShuffle=%1\n").arg(int(slideShowShuffle));
            cont += QString("SlideShowLoop=%1\n").arg(int(slideShowLoop));
            cont += QString("SlideShowHideQuickInfo=%1\n").arg(int(slideShowHideQuickInfo));

            cont += "\n[Metadata]\n";

            cont += QString("MetaFilename=%1\n").arg(int(metaFilename));
            cont += QString("MetaFileType=%1\n").arg(int(metaFileType));
            cont += QString("MetaFileSize=%1\n").arg(int(metaFileSize));
            cont += QString("MetaImageNumber=%1\n").arg(int(metaImageNumber));
            cont += QString("MetaDimensions=%1\n").arg(int(metaDimensions));
            cont += QString("MetaMake=%1\n").arg(int(metaMake));
            cont += QString("MetaModel=%1\n").arg(int(metaModel));
            cont += QString("MetaSoftware=%1\n").arg(int(metaSoftware));
            cont += QString("MetaTimePhotoTaken=%1\n").arg(int(metaTimePhotoTaken));
            cont += QString("MetaExposureTime=%1\n").arg(int(metaExposureTime));
            cont += QString("MetaFlash=%1\n").arg(int(metaFlash));
            cont += QString("MetaIso=%1\n").arg(int(metaIso));
            cont += QString("MetaSceneType=%1\n").arg(int(metaSceneType));
            cont += QString("MetaFLength=%1\n").arg(int(metaFLength));
            cont += QString("MetaFNumber=%1\n").arg(int(metaFNumber));
            cont += QString("MetaLightSource=%1\n").arg(int(metaLightSource));
            cont += QString("MetaGps=%1\n").arg(int(metaGps));
            cont += QString("MetaApplyRotation=%1\n").arg(int(metaApplyRotation));
            cont += QString("MetaGpsMapService=%1\n").arg(metaGpsMapService);
            cont += QString("MetaKeywords=%1\n").arg(int(metaKeywords));
            cont += QString("MetaLocation=%1\n").arg(int(metaLocation));
            cont += QString("MetaCopyright=%1\n").arg(int(metaCopyright));

            cont += "\n[Metadata Element]\n";

            cont += QString("MetadataEnableHotEdge=%1\n").arg(int(metadataEnableHotEdge));
            cont += QString("MetadataFontSize=%1\n").arg(metadataFontSize);
            cont += QString("MetadataOpacity=%1\n").arg(metadataOpacity);
            cont += QString("MetadataWindowWidth=%1\n").arg(metadataWindowWidth);

            cont += "\n[Open File]\n";
            cont += QString("OpenDefaultView=%1\n").arg(openDefaultView);
            cont += QString("OpenPreview=%1\n").arg(int(openPreview));
            cont += QString("OpenPreviewHighQuality=%1\n").arg(int(openPreviewHighQuality));
            cont += QString("OpenZoomLevel=%1\n").arg(openZoomLevel);
            cont += QString("OpenUserPlacesWidth=%1\n").arg(openUserPlacesWidth);
            cont += QString("OpenFoldersWidth=%1\n").arg(openFoldersWidth);
            cont += QString("OpenThumbnails=%1\n").arg(int(openThumbnails));
            cont += QString("OpenUserPlacesStandard=%1\n").arg(int(openUserPlacesStandard));
            cont += QString("OpenUserPlacesUser=%1\n").arg(int(openUserPlacesUser));
            cont += QString("OpenUserPlacesVolumes=%1\n").arg(int(openUserPlacesVolumes));
            cont += QString("OpenKeepLastLocation=%1\n").arg(int(openKeepLastLocation));
            cont += QString("OpenShowHiddenFilesFolders=%1\n").arg(int(openShowHiddenFilesFolders));

            cont += "\n[Histogram]\n";

            cont += QString("Histogram=%1\n").arg(int(histogram));
            cont += QString("HistogramVersion=%1\n").arg(histogramVersion);
            cont += QString("HistogramPosition=%1,%2\n").arg(histogramPosition.x()).arg(histogramPosition.y());
            cont += QString("HistogramSize=%1,%2\n").arg(histogramSize.width()).arg(histogramSize.height());

            cont += "\n[Main Menu Element]\n";

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
        avoidInfiniteLoopSettingFilesToWatcher = 0;
        setFilesToWatcher();

        // Set default values to start out with
        setDefault();

        QFile file(ConfigFiles::SETTINGS_FILE());

        if(file.exists() && !file.open(QIODevice::ReadOnly))

            LOG << CURDATE  << "ERROR reading settings:" << file.errorString().trimmed().toStdString() << NL;

        else if(file.exists() && file.isOpen()) {

            if(verbose) LOG << CURDATE << "Read Settings from File" << NL;

            // Read file
            QTextStream in(&file);
            QString all = in.readAll();

            if(all.contains("Language="))
                language = all.split("Language=").at(1).split("\n").at(0);

            if(all.contains("Version="))
                versionInTextFile = all.split("Version=").at(1).split("\n").at(0);

            if(all.contains("SortImagesBy="))
                sortby = all.split("SortImagesBy=").at(1).split("\n").at(0);

            if(all.contains("SortImagesAscending=1"))
                sortbyAscending = true;
            else if(all.contains("SortImagesAscending=0"))
                sortbyAscending = false;

            if(all.contains("WindowMode=1"))
                windowMode = true;
            else if(all.contains("WindowMode=0"))
                windowMode = false;

            if(all.contains("WindowDecoration=1"))
                windowDecoration = true;
            else if(all.contains("WindowDecoration=0"))
                windowDecoration = false;

            if(all.contains("ElementsFadeIn=1"))
                elementsFadeIn = true;
            else if(all.contains("ElementsFadeIn=0"))
                elementsFadeIn = false;

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

            if(all.contains("StartupLoadLastLoadedImage=1"))
                startupLoadLastLoadedImage = true;
            else if(all.contains("StartupLoadLastLoadedImage=0"))
                startupLoadLastLoadedImage = false;


            if(all.contains("BackgroundColorRed="))
                backgroundColorRed = all.split("BackgroundColorRed=").at(1).split("\n").at(0).toInt();
            if(all.contains("BackgroundColorGreen="))
                backgroundColorGreen = all.split("BackgroundColorGreen=").at(1).split("\n").at(0).toInt();
            if(all.contains("BackgroundColorBlue="))
                backgroundColorBlue = all.split("BackgroundColorBlue=").at(1).split("\n").at(0).toInt();
            if(all.contains("BackgroundColorAlpha="))
                backgroundColorAlpha = all.split("BackgroundColorAlpha=").at(1).split("\n").at(0).toInt();

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
                trayIcon = all.split("TrayIcon=").at(1).split("\n").at(0).toInt();

            if(all.contains("ImageTransition="))
                imageTransition = all.split("ImageTransition=").at(1).split("\n").at(0).toInt();

            if(all.contains("LoopThroughFolder=1"))
                loopThroughFolder = true;
            else if(all.contains("LoopThroughFolder=0"))
                loopThroughFolder = false;

            if(all.contains("HotEdgeWidth="))
                hotEdgeWidth = all.split("HotEdgeWidth=").at(1).split("\n").at(0).toInt();

            if(all.contains("CloseOnEmptyBackground=1"))
                closeOnEmptyBackground = true;
            else if(all.contains("CloseOnEmptyBackground=0"))
                closeOnEmptyBackground = false;

            if(all.contains("MarginAroundImage="))
                marginAroundImage = all.split("MarginAroundImage=").at(1).split("\n").at(0).toInt();

            if(all.contains("MouseWheelSensitivity=")) {
                mouseWheelSensitivity = all.split("MouseWheelSensitivity=").at(1).split("\n").at(0).toInt();
                if(mouseWheelSensitivity < 1) mouseWheelSensitivity = 1;
            }

            if(all.contains("KeepZoomRotationMirror=1"))
                keepZoomRotationMirror = true;
            else if(all.contains("KeepZoomRotationMirror=0"))
                keepZoomRotationMirror = false;

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

            if(all.contains("PixmapCache="))
                pixmapCache = all.split("PixmapCache=").at(1).split("\n").at(0).toInt();

            if(all.contains("ShowTransparencyMarkerBackground="))
                showTransparencyMarkerBackground = all.split("ShowTransparencyMarkerBackground=").at(1).split("\n").at(0).toInt();

            if(all.contains("LeftButtonMouseClickAndMove=1"))
                leftButtonMouseClickAndMove = true;
            else if(all.contains("LeftButtonMouseClickAndMove=0"))
                leftButtonMouseClickAndMove = false;

            if(all.contains("QuickInfoHideCounter=1"))
                quickInfoHideCounter = true;
            else if(all.contains("QuickInfoHideCounter=0"))
                quickInfoHideCounter = false;

            if(all.contains("QuickInfoHideFilepath=1"))
                quickInfoHideFilepath = true;
            else if(all.contains("QuickInfoHideFilepath=0"))
                quickInfoHideFilepath = false;

            if(all.contains("QuickInfoHideFilename=1"))
                quickInfoHideFilename = true;
            else if(all.contains("QuickInfoHideFilename=0"))
                quickInfoHideFilename = false;

            if(all.contains("QuickInfoHideX=1"))
                quickInfoHideX = true;
            else if(all.contains("QuickInfoHideX=0"))
                quickInfoHideX = false;

            if(all.contains("QuickInfoCloseXSize="))
                quickInfoCloseXSize = all.split("QuickInfoCloseXSize=").at(1).split("\n").at(0).toInt();

            if(all.contains(("QuickInfoFullX=1")))
                quickInfoFullX = true;
            else if(all.contains("QuickInfoFullX=0"))
                quickInfoFullX = false;

            if(all.contains("ThumbnailSize="))
                thumbnailSize = all.split("ThumbnailSize=").at(1).split("\n").at(0).toInt();

            if(all.contains("ThumbnailPosition="))
                thumbnailPosition = all.split("ThumbnailPosition=").at(1).split("\n").at(0);

            if(all.contains("ThumbnailCache=1"))
                thumbnailCache = true;
            else if(all.contains("ThumbnailCache=0"))
                thumbnailCache = false;

            if(all.contains("ThumbnailCacheFile=1"))
                thumbnailCacheFile = true;
            else if(all.contains("ThumbnailCacheFile=0"))
                thumbnailCacheFile = false;

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

            if(all.contains("ThumbnailKeepVisibleWhenNotZoomedIn=1"))
                thumbnailKeepVisibleWhenNotZoomedIn = true;
            else if(all.contains("ThumbnailKeepVisibleWhenNotZoomedIn=0"))
                thumbnailKeepVisibleWhenNotZoomedIn = false;

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

            if(all.contains("ThumbnailFontSize="))
                thumbnailFontSize = all.split("ThumbnailFontSize=").at(1).split("\n").at(0).toInt();


            if(all.contains("SlideShowTime="))
                slideShowTime = all.split("SlideShowTime=").at(1).split("\n").at(0).toInt();

            if(all.contains("SlideShowImageTransition="))
                slideShowImageTransition = all.split("SlideShowImageTransition=").at(1).split("\n").at(0).toInt();

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

            if(all.contains("SlideShowHideQuickInfo="))
                slideShowHideQuickInfo = bool(all.split("SlideShowHideQuickInfo=").at(1).split("\n").at(0).toInt());


            if(all.contains("MetaFilename=1"))
                metaFilename = true;
            else if(all.contains("MetaFilename=0"))
                metaFilename = false;

            if(all.contains("MetaFileType=1"))
                metaFileType = true;
            else if(all.contains("MetaFileType=0"))
                metaFileType = false;

            if(all.contains("MetaFileSize=1"))
                metaFileSize = true;
            else if(all.contains("MetaFileSize=0"))
                metaFileSize = false;

            if(all.contains("MetaImageNumber=1"))
                metaImageNumber = true;
            else if(all.contains("MetaImageNumber=0"))
                metaImageNumber = false;

            if(all.contains("MetaDimensions=1"))
                metaDimensions = true;
            else if(all.contains("MetaDimensions=0"))
                metaDimensions = false;

            if(all.contains("MetaMake=1"))
                metaMake = true;
            else if(all.contains("MetaMake=0"))
                metaMake = false;

            if(all.contains("MetaModel=1"))
                metaModel = true;
            else if(all.contains("MetaModel=0"))
                metaModel = false;

            if(all.contains("MetaSoftware=1"))
                metaSoftware = true;
            else if(all.contains("MetaSoftware=0"))
                metaSoftware = false;

            if(all.contains("MetaTimePhotoTaken=1"))
                metaTimePhotoTaken = true;
            else if(all.contains("MetaTimePhotoTaken=0"))
                metaTimePhotoTaken = false;

            if(all.contains("MetaExposureTime=1"))
                metaExposureTime = true;
            else if(all.contains("MetaExposureTime=0"))
                metaExposureTime = false;

            if(all.contains("MetaFlash=1"))
                metaFlash = true;
            else if(all.contains("MetaFlash=0"))
                metaFlash = false;

            if(all.contains("MetaIso=1"))
                metaIso = true;
            else if(all.contains("MetaIso=0"))
                metaIso = false;

            if(all.contains("MetaSceneType=1"))
                metaSceneType = true;
            else if(all.contains("MetaSceneType=0"))
                metaSceneType = false;

            if(all.contains("MetaFLength=1"))
                metaFLength = true;
            else if(all.contains("MetaFLength=0"))
                metaFLength = false;

            if(all.contains("MetaFNumber=1"))
                metaFNumber = true;
            else if(all.contains("MetaFNumber=0"))
                metaFNumber = false;

            if(all.contains("MetaLightSource=1"))
                metaLightSource = true;
            else if(all.contains("MetaLightSource=0"))
                metaLightSource = false;

            if(all.contains("MetaGps=1"))
                metaGps = true;
            else if(all.contains("MetaGps=0"))
                metaGps = false;

            if(all.contains("MetaKeywords=1"))
                metaKeywords = true;
            else if(all.contains("MetaKeywords=0"))
                metaKeywords = false;

            if(all.contains("MetaLocation=1"))
                metaLocation = true;
            else if(all.contains("MetaLocation=0"))
                metaLocation = false;

            if(all.contains("MetaCopyright=1"))
                metaCopyright = true;
            else if(all.contains("MetaCopyright=0"))
                metaCopyright = false;

            if(all.contains("MetaApplyRotation=1"))
                metaApplyRotation = true;
            else if(all.contains("MetaApplyRotation=0"))
                metaApplyRotation = false;

            if(all.contains("MetaGpsMapService="))
                metaGpsMapService = all.split("MetaGpsMapService=").at(1).split("\n").at(0);

            if(all.contains("MetadataEnableHotEdge=1"))
                metadataEnableHotEdge = true;
            else if(all.contains("MetadataEnableHotEdge=0"))
                metadataEnableHotEdge = false;

            if(all.contains("MetadataFontSize="))
                metadataFontSize = all.split("MetadataFontSize=").at(1).split("\n").at(0).toInt();

            if(all.contains("MetadataOpacity="))
                metadataOpacity = all.split("MetadataOpacity=").at(1).split("\n").at(0).toInt();

            if(all.contains("MetadataWindowWidth="))
                metadataWindowWidth = all.split("MetadataWindowWidth=").at(1).split("\n").at(0).toInt();


            if(all.contains("OpenDefaultView=list"))
                openDefaultView = "list";
            else if(all.contains("OpenDefaultView=icons"))
                openDefaultView = "icons";

            if(all.contains("OpenPreview=1"))
                openPreview = true;
            else if(all.contains("OpenPreview=0"))
                openPreview = false;

            if(all.contains("OpenZoomLevel="))
                openZoomLevel = all.split("OpenZoomLevel=").at(1).split("\n").at(0).toInt();

            if(all.contains("OpenUserPlacesWidth="))
                openUserPlacesWidth = all.split("OpenUserPlacesWidth=").at(1).split("\n").at(0).toInt();

            if(all.contains("OpenFoldersWidth="))
                openFoldersWidth = all.split("OpenFoldersWidth=").at(1).split("\n").at(0).toInt();

            if(all.contains("OpenThumbnails=1"))
                openThumbnails = true;
            else if(all.contains("OpenThumbnails=0"))
                openThumbnails = false;

            if(all.contains("OpenPreviewHighQuality=1"))
                openPreviewHighQuality = true;
            else if(all.contains("OpenPreviewHighQuality=0"))
                openPreviewHighQuality = false;

            if(all.contains("OpenUserPlacesStandard=1"))
                openUserPlacesStandard = true;
            else if(all.contains("OpenUserPlacesStandard=0"))
                openUserPlacesStandard = false;

            if(all.contains("OpenUserPlacesUser=1"))
                openUserPlacesUser = true;
            else if(all.contains("OpenUserPlacesUser=0"))
                openUserPlacesUser = false;

            if(all.contains("OpenUserPlacesVolumes=1"))
                openUserPlacesVolumes = true;
            else if(all.contains("OpenUserPlacesVolumes=0"))
                openUserPlacesVolumes = false;

            if(all.contains("OpenKeepLastLocation=1"))
                openKeepLastLocation = true;
            else if(all.contains("OpenKeepLastLocation=0"))
                openKeepLastLocation = false;

            if(all.contains("OpenShowHiddenFilesFolders=1"))
                openShowHiddenFilesFolders = true;
            else if(all.contains("OpenShowHiddenFilesFolders=0"))
                openShowHiddenFilesFolders = false;


            if(all.contains("MainMenuWindowWidth="))
                mainMenuWindowWidth = all.split("MainMenuWindowWidth=").at(1).split("\n").at(0).toInt();

            if(all.contains("Histogram=1"))
                histogram = true;
            else if(all.contains("Histogram=0"))
                histogram = false;

            if(all.contains("HistogramVersion="))
                histogramVersion = all.split("HistogramVersion=").at(1).split("\n").at(0);

            if(all.contains("HistogramPosition=")) {
                QStringList parts = all.split("HistogramPosition=").at(1).split("\n").at(0).split(",");
                histogramPosition = QPoint(parts.at(0).toInt(), parts.at(1).toInt());
            }

            if(all.contains("HistogramSize=")) {
                QStringList parts = all.split("HistogramSize=").at(1).split("\n").at(0).split(",");
                histogramSize = QSize(parts.at(0).toInt(), parts.at(1).toInt());
            }

            file.close();

        }

    }

private:
    QFileSystemWatcher *watcher;
    QTimer *saveSettingsTimer;
    int avoidInfiniteLoopSettingFilesToWatcher;

private slots:
    void saveSettingsTimerStart(QVariant) { saveSettingsTimer->start(); }


    /*#################################################################################################*/
    /*#################################################################################################*/

signals:
    void versionChanged(QString val);
    void languageChanged(QString val);
    void elementsFadeInChanged(bool val);
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
    void transitionChanged(int val);
    void loopThroughFolderChanged(bool val);
    void hotEdgeWidthChanged(int val);
    void closeongreyChanged(bool val);
    void borderAroundImgChanged(int val);
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

    void metadataWindowWidthChanged(int val);
    void mainMenuWindowWidthChanged(int val);

    void histogramChanged(bool val);
    void histogramVersionChanged(QString val);
    void histogramPositionChanged(QPoint val);
    void histogramSizeChanged(QSize val);

};

#endif // SETTINGS_H
