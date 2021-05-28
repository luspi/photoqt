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

#ifndef PQSETTINGS_H
#define PQSETTINGS_H

#include <QObject>
#include <QQmlContext>
#include <QQmlEngine>
#include <QPoint>
#include <QSize>
#include <QTimer>
#include <QFileSystemWatcher>
#include <QFile>
#include <QFileInfo>

#include "../logger.h"

class PQSettings : public QObject {

    Q_OBJECT

public:
    static PQSettings& get() {
        static PQSettings instance;
        return instance;
    }

    PQSettings(PQSettings const&)     = delete;
    void operator=(PQSettings const&) = delete;

    Q_INVOKABLE void setDefault();
    
    Q_PROPERTY(QString version READ getVersion WRITE setVersion NOTIFY versionChanged)
    QString getVersion() { return m_version; }
    void setVersion(QString val) {
        if(m_version != val) {
            m_version = val;
            emit versionChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(QString language READ getLanguage WRITE setLanguage NOTIFY languageChanged)
    QString getLanguage() { return m_language; }
    void setLanguage(QString val) {
        if(m_language != val) {
            m_language = val;
            emit languageChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool windowMode READ getWindowMode WRITE setWindowMode NOTIFY windowModeChanged)
    bool getWindowMode() { return m_windowMode; }
    void setWindowMode(bool val) {
        if(m_windowMode != val) {
            m_windowMode = val;
            emit windowModeChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool windowDecoration READ getWindowDecoration WRITE setWindowDecoration NOTIFY windowDecorationChanged)
    bool getWindowDecoration() { return m_windowDecoration; }
    void setWindowDecoration(bool val) {
        if(m_windowDecoration != val) {
            m_windowDecoration = val;
            emit windowDecorationChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool saveWindowGeometry READ getSaveWindowGeometry WRITE setSaveWindowGeometry NOTIFY saveWindowGeometryChanged)
    bool getSaveWindowGeometry() { return m_saveWindowGeometry; }
    void setSaveWindowGeometry(bool val) {
        if(m_saveWindowGeometry != val) {
            m_saveWindowGeometry = val;
            emit saveWindowGeometryChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool keepOnTop READ getKeepOnTop WRITE setKeepOnTop NOTIFY keepOnTopChanged)
    bool getKeepOnTop() { return m_keepOnTop; }
    void setKeepOnTop(bool val) {
        if(m_keepOnTop != val) {
            m_keepOnTop = val;
            emit keepOnTopChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool startupLoadLastLoadedImage READ getStartupLoadLastLoadedImage WRITE setStartupLoadLastLoadedImage NOTIFY startupLoadLastLoadedImageChanged)
    bool getStartupLoadLastLoadedImage() { return m_startupLoadLastLoadedImage; }
    void setStartupLoadLastLoadedImage(bool val) {
        if(m_startupLoadLastLoadedImage != val) {
            m_startupLoadLastLoadedImage = val;
            emit startupLoadLastLoadedImageChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int backgroundColorAlpha READ getBackgroundColorAlpha WRITE setBackgroundColorAlpha NOTIFY backgroundColorAlphaChanged)
    int getBackgroundColorAlpha() { return m_backgroundColorAlpha; }
    void setBackgroundColorAlpha(int val) {
        if(m_backgroundColorAlpha != val) {
            m_backgroundColorAlpha = val;
            emit backgroundColorAlphaChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int backgroundColorBlue READ getBackgroundColorBlue WRITE setBackgroundColorBlue NOTIFY backgroundColorBlueChanged)
    int getBackgroundColorBlue() { return m_backgroundColorBlue; }
    void setBackgroundColorBlue(int val) {
        if(m_backgroundColorBlue != val) {
            m_backgroundColorBlue = val;
            emit backgroundColorBlueChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int backgroundColorGreen READ getBackgroundColorGreen WRITE setBackgroundColorGreen NOTIFY backgroundColorGreenChanged)
    int getBackgroundColorGreen() { return m_backgroundColorGreen; }
    void setBackgroundColorGreen(int val) {
        if(m_backgroundColorGreen != val) {
            m_backgroundColorGreen = val;
            emit backgroundColorGreenChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int backgroundColorRed READ getBackgroundColorRed WRITE setBackgroundColorRed NOTIFY backgroundColorRedChanged)
    int getBackgroundColorRed() { return m_backgroundColorRed; }
    void setBackgroundColorRed(int val) {
        if(m_backgroundColorRed != val) {
            m_backgroundColorRed = val;
            emit backgroundColorRedChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool backgroundImageCenter READ getBackgroundImageCenter WRITE setBackgroundImageCenter NOTIFY backgroundImageCenterChanged)
    bool getBackgroundImageCenter() { return m_backgroundImageCenter; }
    void setBackgroundImageCenter(bool val) {
        if(m_backgroundImageCenter != val) {
            m_backgroundImageCenter = val;
            emit backgroundImageCenterChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool backgroundImagePath READ getBackgroundImagePath WRITE setBackgroundImagePath NOTIFY backgroundImagePathChanged)
    bool getBackgroundImagePath() { return m_backgroundImagePath; }
    void setBackgroundImagePath(bool val) {
        if(m_backgroundImagePath != val) {
            m_backgroundImagePath = val;
            emit backgroundImagePathChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool backgroundImageScale READ getBackgroundImageScale WRITE setBackgroundImageScale NOTIFY backgroundImageScaleChanged)
    bool getBackgroundImageScale() { return m_backgroundImageScale; }
    void setBackgroundImageScale(bool val) {
        if(m_backgroundImageScale != val) {
            m_backgroundImageScale = val;
            emit backgroundImageScaleChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool backgroundImageScaleCrop READ getBackgroundImageScaleCrop WRITE setBackgroundImageScaleCrop NOTIFY backgroundImageScaleCropChanged)
    bool getBackgroundImageScaleCrop() { return m_backgroundImageScaleCrop; }
    void setBackgroundImageScaleCrop(bool val) {
        if(m_backgroundImageScaleCrop != val) {
            m_backgroundImageScaleCrop = val;
            emit backgroundImageScaleCropChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool backgroundImageScreenshot READ getBackgroundImageScreenshot WRITE setBackgroundImageScreenshot NOTIFY backgroundImageScreenshotChanged)
    bool getBackgroundImageScreenshot() { return m_backgroundImageScreenshot; }
    void setBackgroundImageScreenshot(bool val) {
        if(m_backgroundImageScreenshot != val) {
            m_backgroundImageScreenshot = val;
            emit backgroundImageScreenshotChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool backgroundImageStretch READ getBackgroundImageStretch WRITE setBackgroundImageStretch NOTIFY backgroundImageStretchChanged)
    bool getBackgroundImageStretch() { return m_backgroundImageStretch; }
    void setBackgroundImageStretch(bool val) {
        if(m_backgroundImageStretch != val) {
            m_backgroundImageStretch = val;
            emit backgroundImageStretchChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool backgroundImageTile READ getBackgroundImageTile WRITE setBackgroundImageTile NOTIFY backgroundImageTileChanged)
    bool getBackgroundImageTile() { return m_backgroundImageTile; }
    void setBackgroundImageTile(bool val) {
        if(m_backgroundImageTile != val) {
            m_backgroundImageTile = val;
            emit backgroundImageTileChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool backgroundImageUse READ getBackgroundImageUse WRITE setBackgroundImageUse NOTIFY backgroundImageUseChanged)
    bool getBackgroundImageUse() { return m_backgroundImageUse; }
    void setBackgroundImageUse(bool val) {
        if(m_backgroundImageUse != val) {
            m_backgroundImageUse = val;
            emit backgroundImageUseChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int animationDuration READ getAnimationDuration WRITE setAnimationDuration NOTIFY animationDurationChanged)
    int getAnimationDuration() { return m_animationDuration; }
    void setAnimationDuration(int val) {
        if(m_animationDuration != val) {
            m_animationDuration = val;
            emit animationDurationChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(QString animationType READ getAnimationType WRITE setAnimationType NOTIFY animationTypeChanged)
    QString getAnimationType() { return m_animationType; }
    void setAnimationType(QString val) {
        if(m_animationType != val) {
            m_animationType = val;
            emit animationTypeChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool archiveUseExternalUnrar READ getArchiveUseExternalUnrar WRITE setArchiveUseExternalUnrar NOTIFY archiveUseExternalUnrarChanged)
    bool getArchiveUseExternalUnrar() { return m_archiveUseExternalUnrar; }
    void setArchiveUseExternalUnrar(bool val) {
        if(m_archiveUseExternalUnrar != val) {
            m_archiveUseExternalUnrar = val;
            emit archiveUseExternalUnrarChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool closeOnEmptyBackground READ getCloseOnEmptyBackground WRITE setCloseOnEmptyBackground NOTIFY closeOnEmptyBackgroundChanged)
    bool getCloseOnEmptyBackground() { return m_closeOnEmptyBackground; }
    void setCloseOnEmptyBackground(bool val) {
        if(m_closeOnEmptyBackground != val) {
            m_closeOnEmptyBackground = val;
            emit closeOnEmptyBackgroundChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool fitInWindow READ getFitInWindow WRITE setFitInWindow NOTIFY fitInWindowChanged)
    bool getFitInWindow() { return m_fitInWindow; }
    void setFitInWindow(bool val) {
        if(m_fitInWindow != val) {
            m_fitInWindow = val;
            emit fitInWindowChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int hotEdgeWidth READ getHotEdgeWidth WRITE setHotEdgeWidth NOTIFY hotEdgeWidthChanged)
    int getHotEdgeWidth() { return m_hotEdgeWidth; }
    void setHotEdgeWidth(int val) {
        if(m_hotEdgeWidth != val) {
            m_hotEdgeWidth = val;
            emit hotEdgeWidthChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int interpolationThreshold READ getInterpolationThreshold WRITE setInterpolationThreshold NOTIFY interpolationThresholdChanged)
    int getInterpolationThreshold() { return m_interpolationThreshold; }
    void setInterpolationThreshold(int val) {
        if(m_interpolationThreshold != val) {
            m_interpolationThreshold = val;
            emit interpolationThresholdChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool interpolationDisableForSmallImages READ getInterpolationDisableForSmallImages WRITE setInterpolationDisableForSmallImages NOTIFY interpolationDisableForSmallImagesChanged)
    bool getInterpolationDisableForSmallImages() { return m_interpolationDisableForSmallImages; }
    void setInterpolationDisableForSmallImages(bool val) {
        if(m_interpolationDisableForSmallImages != val) {
            m_interpolationDisableForSmallImages = val;
            emit interpolationDisableForSmallImagesChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool keepZoomRotationMirror READ getKeepZoomRotationMirror WRITE setKeepZoomRotationMirror NOTIFY keepZoomRotationMirrorChanged)
    bool getKeepZoomRotationMirror() { return m_keepZoomRotationMirror; }
    void setKeepZoomRotationMirror(bool val) {
        if(m_keepZoomRotationMirror != val) {
            m_keepZoomRotationMirror = val;
            emit keepZoomRotationMirrorChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool leftButtonMouseClickAndMove READ getLeftButtonMouseClickAndMove WRITE setLeftButtonMouseClickAndMove NOTIFY leftButtonMouseClickAndMoveChanged)
    bool getLeftButtonMouseClickAndMove() { return m_leftButtonMouseClickAndMove; }
    void setLeftButtonMouseClickAndMove(bool val) {
        if(m_leftButtonMouseClickAndMove != val) {
            m_leftButtonMouseClickAndMove = val;
            emit leftButtonMouseClickAndMoveChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool loopThroughFolder READ getLoopThroughFolder WRITE setLoopThroughFolder NOTIFY loopThroughFolderChanged)
    bool getLoopThroughFolder() { return m_loopThroughFolder; }
    void setLoopThroughFolder(bool val) {
        if(m_loopThroughFolder != val) {
            m_loopThroughFolder = val;
            emit loopThroughFolderChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int marginAroundImage READ getMarginAroundImage WRITE setMarginAroundImage NOTIFY marginAroundImageChanged)
    int getMarginAroundImage() { return m_marginAroundImage; }
    void setMarginAroundImage(int val) {
        if(m_marginAroundImage != val) {
            m_marginAroundImage = val;
            emit marginAroundImageChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int mouseWheelSensitivity READ getMouseWheelSensitivity WRITE setMouseWheelSensitivity NOTIFY mouseWheelSensitivityChanged)
    int getMouseWheelSensitivity() { return m_mouseWheelSensitivity; }
    void setMouseWheelSensitivity(int val) {
        if(m_mouseWheelSensitivity != val) {
            m_mouseWheelSensitivity = val;
            emit mouseWheelSensitivityChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int pdfQuality READ getPdfQuality WRITE setPdfQuality NOTIFY pdfQualityChanged)
    int getPdfQuality() { return m_pdfQuality; }
    void setPdfQuality(int val) {
        if(m_pdfQuality != val) {
            m_pdfQuality = val;
            emit pdfQualityChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool pixmapCache READ getPixmapCache WRITE setPixmapCache NOTIFY pixmapCacheChanged)
    bool getPixmapCache() { return m_pixmapCache; }
    void setPixmapCache(bool val) {
        if(m_pixmapCache != val) {
            m_pixmapCache = val;
            emit pixmapCacheChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool showTransparencyMarkerBackground READ getShowTransparencyMarkerBackground WRITE setShowTransparencyMarkerBackground NOTIFY showTransparencyMarkerBackgroundChanged)
    bool getShowTransparencyMarkerBackground() { return m_showTransparencyMarkerBackground; }
    void setShowTransparencyMarkerBackground(bool val) {
        if(m_showTransparencyMarkerBackground != val) {
            m_showTransparencyMarkerBackground = val;
            emit showTransparencyMarkerBackgroundChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(QString sortImagesBy READ getSortImagesBy WRITE setSortImagesBy NOTIFY sortImagesByChanged)
    QString getSortImagesBy() { return m_sortImagesBy; }
    void setSortImagesBy(QString val) {
        if(m_sortImagesBy != val) {
            m_sortImagesBy = val;
            emit sortImagesByChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool sortImagesAscending READ getSortImagesAscending WRITE setSortImagesAscending NOTIFY sortImagesAscendingChanged)
    bool getSortImagesAscending() { return m_sortImagesAscending; }
    void setSortImagesAscending(bool val) {
        if(m_sortImagesAscending != val) {
            m_sortImagesAscending = val;
            emit sortImagesAscendingChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int trayIcon READ getTrayIcon WRITE setTrayIcon NOTIFY trayIconChanged)
    int getTrayIcon() { return m_trayIcon; }
    void setTrayIcon(int val) {
        if(m_trayIcon != val) {
            m_trayIcon = val;
            emit trayIconChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int zoomSpeed READ getZoomSpeed WRITE setZoomSpeed NOTIFY zoomSpeedChanged)
    int getZoomSpeed() { return m_zoomSpeed; }
    void setZoomSpeed(int val) {
        if(m_zoomSpeed != val) {
            m_zoomSpeed = val;
            emit zoomSpeedChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int quickInfoWindowButtonsSize READ getQuickInfoWindowButtonsSize WRITE setQuickInfoWindowButtonsSize NOTIFY quickInfoWindowButtonsSizeChanged)
    int getQuickInfoWindowButtonsSize() { return m_quickInfoWindowButtonsSize; }
    void setQuickInfoWindowButtonsSize(int val) {
        if(m_quickInfoWindowButtonsSize != val) {
            m_quickInfoWindowButtonsSize = val;
            emit quickInfoWindowButtonsSizeChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool quickInfoHideCounter READ getQuickInfoHideCounter WRITE setQuickInfoHideCounter NOTIFY quickInfoHideCounterChanged)
    bool getQuickInfoHideCounter() { return m_quickInfoHideCounter; }
    void setQuickInfoHideCounter(bool val) {
        if(m_quickInfoHideCounter != val) {
            m_quickInfoHideCounter = val;
            emit quickInfoHideCounterChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool quickInfoHideFilepath READ getQuickInfoHideFilepath WRITE setQuickInfoHideFilepath NOTIFY quickInfoHideFilepathChanged)
    bool getQuickInfoHideFilepath() { return m_quickInfoHideFilepath; }
    void setQuickInfoHideFilepath(bool val) {
        if(m_quickInfoHideFilepath != val) {
            m_quickInfoHideFilepath = val;
            emit quickInfoHideFilepathChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool quickInfoHideFilename READ getQuickInfoHideFilename WRITE setQuickInfoHideFilename NOTIFY quickInfoHideFilenameChanged)
    bool getQuickInfoHideFilename() { return m_quickInfoHideFilename; }
    void setQuickInfoHideFilename(bool val) {
        if(m_quickInfoHideFilename != val) {
            m_quickInfoHideFilename = val;
            emit quickInfoHideFilenameChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool quickInfoWindowButtons READ getQuickInfoWindowButtons WRITE setQuickInfoWindowButtons NOTIFY quickInfoWindowButtonsChanged)
    bool getQuickInfoWindowButtons() { return m_quickInfoWindowButtons; }
    void setQuickInfoWindowButtons(bool val) {
        if(m_quickInfoWindowButtons != val) {
            m_quickInfoWindowButtons = val;
            emit quickInfoWindowButtonsChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool quickInfoHideZoomLevel READ getQuickInfoHideZoomLevel WRITE setQuickInfoHideZoomLevel NOTIFY quickInfoHideZoomLevelChanged)
    bool getQuickInfoHideZoomLevel() { return m_quickInfoHideZoomLevel; }
    void setQuickInfoHideZoomLevel(bool val) {
        if(m_quickInfoHideZoomLevel != val) {
            m_quickInfoHideZoomLevel = val;
            emit quickInfoHideZoomLevelChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool quickInfoHideRotationAngle READ getQuickInfoHideRotationAngle WRITE setQuickInfoHideRotationAngle NOTIFY quickInfoHideRotationAngleChanged)
    bool getQuickInfoHideRotationAngle() { return m_quickInfoHideRotationAngle; }
    void setQuickInfoHideRotationAngle(bool val) {
        if(m_quickInfoHideRotationAngle != val) {
            m_quickInfoHideRotationAngle = val;
            emit quickInfoHideRotationAngleChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool quickInfoManageWindow READ getQuickInfoManageWindow WRITE setQuickInfoManageWindow NOTIFY quickInfoManageWindowChanged)
    bool getQuickInfoManageWindow() { return m_quickInfoManageWindow; }
    void setQuickInfoManageWindow(bool val) {
        if(m_quickInfoManageWindow != val) {
            m_quickInfoManageWindow = val;
            emit quickInfoManageWindowChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool thumbnailCache READ getThumbnailCache WRITE setThumbnailCache NOTIFY thumbnailCacheChanged)
    bool getThumbnailCache() { return m_thumbnailCache; }
    void setThumbnailCache(bool val) {
        if(m_thumbnailCache != val) {
            m_thumbnailCache = val;
            emit thumbnailCacheChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool thumbnailCenterActive READ getThumbnailCenterActive WRITE setThumbnailCenterActive NOTIFY thumbnailCenterActiveChanged)
    bool getThumbnailCenterActive() { return m_thumbnailCenterActive; }
    void setThumbnailCenterActive(bool val) {
        if(m_thumbnailCenterActive != val) {
            m_thumbnailCenterActive = val;
            emit thumbnailCenterActiveChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool thumbnailDisable READ getThumbnailDisable WRITE setThumbnailDisable NOTIFY thumbnailDisableChanged)
    bool getThumbnailDisable() { return m_thumbnailDisable; }
    void setThumbnailDisable(bool val) {
        if(m_thumbnailDisable != val) {
            m_thumbnailDisable = val;
            emit thumbnailDisableChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool thumbnailFilenameInstead READ getThumbnailFilenameInstead WRITE setThumbnailFilenameInstead NOTIFY thumbnailFilenameInsteadChanged)
    bool getThumbnailFilenameInstead() { return m_thumbnailFilenameInstead; }
    void setThumbnailFilenameInstead(bool val) {
        if(m_thumbnailFilenameInstead != val) {
            m_thumbnailFilenameInstead = val;
            emit thumbnailFilenameInsteadChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int thumbnailFilenameInsteadFontSize READ getThumbnailFilenameInsteadFontSize WRITE setThumbnailFilenameInsteadFontSize NOTIFY thumbnailFilenameInsteadFontSizeChanged)
    int getThumbnailFilenameInsteadFontSize() { return m_thumbnailFilenameInsteadFontSize; }
    void setThumbnailFilenameInsteadFontSize(int val) {
        if(m_thumbnailFilenameInsteadFontSize != val) {
            m_thumbnailFilenameInsteadFontSize = val;
            emit thumbnailFilenameInsteadFontSizeChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int thumbnailFontSize READ getThumbnailFontSize WRITE setThumbnailFontSize NOTIFY thumbnailFontSizeChanged)
    int getThumbnailFontSize() { return m_thumbnailFontSize; }
    void setThumbnailFontSize(int val) {
        if(m_thumbnailFontSize != val) {
            m_thumbnailFontSize = val;
            emit thumbnailFontSizeChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool thumbnailKeepVisible READ getThumbnailKeepVisible WRITE setThumbnailKeepVisible NOTIFY thumbnailKeepVisibleChanged)
    bool getThumbnailKeepVisible() { return m_thumbnailKeepVisible; }
    void setThumbnailKeepVisible(bool val) {
        if(m_thumbnailKeepVisible != val) {
            m_thumbnailKeepVisible = val;
            emit thumbnailKeepVisibleChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool thumbnailKeepVisibleWhenNotZoomedIn READ getThumbnailKeepVisibleWhenNotZoomedIn WRITE setThumbnailKeepVisibleWhenNotZoomedIn NOTIFY thumbnailKeepVisibleWhenNotZoomedInChanged)
    bool getThumbnailKeepVisibleWhenNotZoomedIn() { return m_thumbnailKeepVisibleWhenNotZoomedIn; }
    void setThumbnailKeepVisibleWhenNotZoomedIn(bool val) {
        if(m_thumbnailKeepVisibleWhenNotZoomedIn != val) {
            m_thumbnailKeepVisibleWhenNotZoomedIn = val;
            emit thumbnailKeepVisibleWhenNotZoomedInChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int thumbnailLiftUp READ getThumbnailLiftUp WRITE setThumbnailLiftUp NOTIFY thumbnailLiftUpChanged)
    int getThumbnailLiftUp() { return m_thumbnailLiftUp; }
    void setThumbnailLiftUp(int val) {
        if(m_thumbnailLiftUp != val) {
            m_thumbnailLiftUp = val;
            emit thumbnailLiftUpChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int thumbnailMaxNumberThreads READ getThumbnailMaxNumberThreads WRITE setThumbnailMaxNumberThreads NOTIFY thumbnailMaxNumberThreadsChanged)
    int getThumbnailMaxNumberThreads() { return m_thumbnailMaxNumberThreads; }
    void setThumbnailMaxNumberThreads(int val) {
        if(m_thumbnailMaxNumberThreads != val) {
            m_thumbnailMaxNumberThreads = val;
            emit thumbnailMaxNumberThreadsChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(QString thumbnailPosition READ getThumbnailPosition WRITE setThumbnailPosition NOTIFY thumbnailPositionChanged)
    QString getThumbnailPosition() { return m_thumbnailPosition; }
    void setThumbnailPosition(QString val) {
        if(m_thumbnailPosition != val) {
            m_thumbnailPosition = val;
            emit thumbnailPositionChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int thumbnailSize READ getThumbnailSize WRITE setThumbnailSize NOTIFY thumbnailSizeChanged)
    int getThumbnailSize() { return m_thumbnailSize; }
    void setThumbnailSize(int val) {
        if(m_thumbnailSize != val) {
            m_thumbnailSize = val;
            emit thumbnailSizeChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int thumbnailSpacingBetween READ getThumbnailSpacingBetween WRITE setThumbnailSpacingBetween NOTIFY thumbnailSpacingBetweenChanged)
    int getThumbnailSpacingBetween() { return m_thumbnailSpacingBetween; }
    void setThumbnailSpacingBetween(int val) {
        if(m_thumbnailSpacingBetween != val) {
            m_thumbnailSpacingBetween = val;
            emit thumbnailSpacingBetweenChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool thumbnailWriteFilename READ getThumbnailWriteFilename WRITE setThumbnailWriteFilename NOTIFY thumbnailWriteFilenameChanged)
    bool getThumbnailWriteFilename() { return m_thumbnailWriteFilename; }
    void setThumbnailWriteFilename(bool val) {
        if(m_thumbnailWriteFilename != val) {
            m_thumbnailWriteFilename = val;
            emit thumbnailWriteFilenameChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool slideShowHideQuickInfo READ getSlideShowHideQuickInfo WRITE setSlideShowHideQuickInfo NOTIFY slideShowHideQuickInfoChanged)
    bool getSlideShowHideQuickInfo() { return m_slideShowHideQuickInfo; }
    void setSlideShowHideQuickInfo(bool val) {
        if(m_slideShowHideQuickInfo != val) {
            m_slideShowHideQuickInfo = val;
            emit slideShowHideQuickInfoChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int slideShowImageTransition READ getSlideShowImageTransition WRITE setSlideShowImageTransition NOTIFY slideShowImageTransitionChanged)
    int getSlideShowImageTransition() { return m_slideShowImageTransition; }
    void setSlideShowImageTransition(int val) {
        if(m_slideShowImageTransition != val) {
            m_slideShowImageTransition = val;
            emit slideShowImageTransitionChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool slideShowLoop READ getSlideShowLoop WRITE setSlideShowLoop NOTIFY slideShowLoopChanged)
    bool getSlideShowLoop() { return m_slideShowLoop; }
    void setSlideShowLoop(bool val) {
        if(m_slideShowLoop != val) {
            m_slideShowLoop = val;
            emit slideShowLoopChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(QString slideShowMusicFile READ getSlideShowMusicFile WRITE setSlideShowMusicFile NOTIFY slideShowMusicFileChanged)
    QString getSlideShowMusicFile() { return m_slideShowMusicFile; }
    void setSlideShowMusicFile(QString val) {
        if(m_slideShowMusicFile != val) {
            m_slideShowMusicFile = val;
            emit slideShowMusicFileChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool slideShowShuffle READ getSlideShowShuffle WRITE setSlideShowShuffle NOTIFY slideShowShuffleChanged)
    bool getSlideShowShuffle() { return m_slideShowShuffle; }
    void setSlideShowShuffle(bool val) {
        if(m_slideShowShuffle != val) {
            m_slideShowShuffle = val;
            emit slideShowShuffleChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int slideShowTime READ getSlideShowTime WRITE setSlideShowTime NOTIFY slideShowTimeChanged)
    int getSlideShowTime() { return m_slideShowTime; }
    void setSlideShowTime(int val) {
        if(m_slideShowTime != val) {
            m_slideShowTime = val;
            emit slideShowTimeChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(QString slideShowTypeAnimation READ getSlideShowTypeAnimation WRITE setSlideShowTypeAnimation NOTIFY slideShowTypeAnimationChanged)
    QString getSlideShowTypeAnimation() { return m_slideShowTypeAnimation; }
    void setSlideShowTypeAnimation(QString val) {
        if(m_slideShowTypeAnimation != val) {
            m_slideShowTypeAnimation = val;
            emit slideShowTypeAnimationChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool slideShowIncludeSubFolders READ getSlideShowIncludeSubFolders WRITE setSlideShowIncludeSubFolders NOTIFY slideShowIncludeSubFoldersChanged)
    bool getSlideShowIncludeSubFolders() { return m_slideShowIncludeSubFolders; }
    void setSlideShowIncludeSubFolders(bool val) {
        if(m_slideShowIncludeSubFolders != val) {
            m_slideShowIncludeSubFolders = val;
            emit slideShowIncludeSubFoldersChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool metaApplyRotation READ getMetaApplyRotation WRITE setMetaApplyRotation NOTIFY metaApplyRotationChanged)
    bool getMetaApplyRotation() { return m_metaApplyRotation; }
    void setMetaApplyRotation(bool val) {
        if(m_metaApplyRotation != val) {
            m_metaApplyRotation = val;
            emit metaApplyRotationChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool metaCopyright READ getMetaCopyright WRITE setMetaCopyright NOTIFY metaCopyrightChanged)
    bool getMetaCopyright() { return m_metaCopyright; }
    void setMetaCopyright(bool val) {
        if(m_metaCopyright != val) {
            m_metaCopyright = val;
            emit metaCopyrightChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool metaDimensions READ getMetaDimensions WRITE setMetaDimensions NOTIFY metaDimensionsChanged)
    bool getMetaDimensions() { return m_metaDimensions; }
    void setMetaDimensions(bool val) {
        if(m_metaDimensions != val) {
            m_metaDimensions = val;
            emit metaDimensionsChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool metaExposureTime READ getMetaExposureTime WRITE setMetaExposureTime NOTIFY metaExposureTimeChanged)
    bool getMetaExposureTime() { return m_metaExposureTime; }
    void setMetaExposureTime(bool val) {
        if(m_metaExposureTime != val) {
            m_metaExposureTime = val;
            emit metaExposureTimeChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool metaFilename READ getMetaFilename WRITE setMetaFilename NOTIFY metaFilenameChanged)
    bool getMetaFilename() { return m_metaFilename; }
    void setMetaFilename(bool val) {
        if(m_metaFilename != val) {
            m_metaFilename = val;
            emit metaFilenameChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool metaFileType READ getMetaFileType WRITE setMetaFileType NOTIFY metaFileTypeChanged)
    bool getMetaFileType() { return m_metaFileType; }
    void setMetaFileType(bool val) {
        if(m_metaFileType != val) {
            m_metaFileType = val;
            emit metaFileTypeChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool metaFileSize READ getMetaFileSize WRITE setMetaFileSize NOTIFY metaFileSizeChanged)
    bool getMetaFileSize() { return m_metaFileSize; }
    void setMetaFileSize(bool val) {
        if(m_metaFileSize != val) {
            m_metaFileSize = val;
            emit metaFileSizeChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool metaFlash READ getMetaFlash WRITE setMetaFlash NOTIFY metaFlashChanged)
    bool getMetaFlash() { return m_metaFlash; }
    void setMetaFlash(bool val) {
        if(m_metaFlash != val) {
            m_metaFlash = val;
            emit metaFlashChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool metaFLength READ getMetaFLength WRITE setMetaFLength NOTIFY metaFLengthChanged)
    bool getMetaFLength() { return m_metaFLength; }
    void setMetaFLength(bool val) {
        if(m_metaFLength != val) {
            m_metaFLength = val;
            emit metaFLengthChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool metaFNumber READ getMetaFNumber WRITE setMetaFNumber NOTIFY metaFNumberChanged)
    bool getMetaFNumber() { return m_metaFNumber; }
    void setMetaFNumber(bool val) {
        if(m_metaFNumber != val) {
            m_metaFNumber = val;
            emit metaFNumberChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool metaGps READ getMetaGps WRITE setMetaGps NOTIFY metaGpsChanged)
    bool getMetaGps() { return m_metaGps; }
    void setMetaGps(bool val) {
        if(m_metaGps != val) {
            m_metaGps = val;
            emit metaGpsChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(QString metaGpsMapService READ getMetaGpsMapService WRITE setMetaGpsMapService NOTIFY metaGpsMapServiceChanged)
    QString getMetaGpsMapService() { return m_metaGpsMapService; }
    void setMetaGpsMapService(QString val) {
        if(m_metaGpsMapService != val) {
            m_metaGpsMapService = val;
            emit metaGpsMapServiceChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool metaImageNumber READ getMetaImageNumber WRITE setMetaImageNumber NOTIFY metaImageNumberChanged)
    bool getMetaImageNumber() { return m_metaImageNumber; }
    void setMetaImageNumber(bool val) {
        if(m_metaImageNumber != val) {
            m_metaImageNumber = val;
            emit metaImageNumberChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool metaIso READ getMetaIso WRITE setMetaIso NOTIFY metaIsoChanged)
    bool getMetaIso() { return m_metaIso; }
    void setMetaIso(bool val) {
        if(m_metaIso != val) {
            m_metaIso = val;
            emit metaIsoChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool metaKeywords READ getMetaKeywords WRITE setMetaKeywords NOTIFY metaKeywordsChanged)
    bool getMetaKeywords() { return m_metaKeywords; }
    void setMetaKeywords(bool val) {
        if(m_metaKeywords != val) {
            m_metaKeywords = val;
            emit metaKeywordsChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool metaLightSource READ getMetaLightSource WRITE setMetaLightSource NOTIFY metaLightSourceChanged)
    bool getMetaLightSource() { return m_metaLightSource; }
    void setMetaLightSource(bool val) {
        if(m_metaLightSource != val) {
            m_metaLightSource = val;
            emit metaLightSourceChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool metaLocation READ getMetaLocation WRITE setMetaLocation NOTIFY metaLocationChanged)
    bool getMetaLocation() { return m_metaLocation; }
    void setMetaLocation(bool val) {
        if(m_metaLocation != val) {
            m_metaLocation = val;
            emit metaLocationChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool metaMake READ getMetaMake WRITE setMetaMake NOTIFY metaMakeChanged)
    bool getMetaMake() { return m_metaMake; }
    void setMetaMake(bool val) {
        if(m_metaMake != val) {
            m_metaMake = val;
            emit metaMakeChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool metaModel READ getMetaModel WRITE setMetaModel NOTIFY metaModelChanged)
    bool getMetaModel() { return m_metaModel; }
    void setMetaModel(bool val) {
        if(m_metaModel != val) {
            m_metaModel = val;
            emit metaModelChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool metaSceneType READ getMetaSceneType WRITE setMetaSceneType NOTIFY metaSceneTypeChanged)
    bool getMetaSceneType() { return m_metaSceneType; }
    void setMetaSceneType(bool val) {
        if(m_metaSceneType != val) {
            m_metaSceneType = val;
            emit metaSceneTypeChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool metaSoftware READ getMetaSoftware WRITE setMetaSoftware NOTIFY metaSoftwareChanged)
    bool getMetaSoftware() { return m_metaSoftware; }
    void setMetaSoftware(bool val) {
        if(m_metaSoftware != val) {
            m_metaSoftware = val;
            emit metaSoftwareChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool metaTimePhotoTaken READ getMetaTimePhotoTaken WRITE setMetaTimePhotoTaken NOTIFY metaTimePhotoTakenChanged)
    bool getMetaTimePhotoTaken() { return m_metaTimePhotoTaken; }
    void setMetaTimePhotoTaken(bool val) {
        if(m_metaTimePhotoTaken != val) {
            m_metaTimePhotoTaken = val;
            emit metaTimePhotoTakenChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool metadataEnableHotEdge READ getMetadataEnableHotEdge WRITE setMetadataEnableHotEdge NOTIFY metadataEnableHotEdgeChanged)
    bool getMetadataEnableHotEdge() { return m_metadataEnableHotEdge; }
    void setMetadataEnableHotEdge(bool val) {
        if(m_metadataEnableHotEdge != val) {
            m_metadataEnableHotEdge = val;
            emit metadataEnableHotEdgeChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int metadataOpacity READ getMetadataOpacity WRITE setMetadataOpacity NOTIFY metadataOpacityChanged)
    int getMetadataOpacity() { return m_metadataOpacity; }
    void setMetadataOpacity(int val) {
        if(m_metadataOpacity != val) {
            m_metadataOpacity = val;
            emit metadataOpacityChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int metadataWindowWidth READ getMetadataWindowWidth WRITE setMetadataWindowWidth NOTIFY metadataWindowWidthChanged)
    int getMetadataWindowWidth() { return m_metadataWindowWidth; }
    void setMetadataWindowWidth(int val) {
        if(m_metadataWindowWidth != val) {
            m_metadataWindowWidth = val;
            emit metadataWindowWidthChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool peopleTagInMetaAlwaysVisible READ getPeopleTagInMetaAlwaysVisible WRITE setPeopleTagInMetaAlwaysVisible NOTIFY peopleTagInMetaAlwaysVisibleChanged)
    bool getPeopleTagInMetaAlwaysVisible() { return m_peopleTagInMetaAlwaysVisible; }
    void setPeopleTagInMetaAlwaysVisible(bool val) {
        if(m_peopleTagInMetaAlwaysVisible != val) {
            m_peopleTagInMetaAlwaysVisible = val;
            emit peopleTagInMetaAlwaysVisibleChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool peopleTagInMetaBorderAroundFace READ getPeopleTagInMetaBorderAroundFace WRITE setPeopleTagInMetaBorderAroundFace NOTIFY peopleTagInMetaBorderAroundFaceChanged)
    bool getPeopleTagInMetaBorderAroundFace() { return m_peopleTagInMetaBorderAroundFace; }
    void setPeopleTagInMetaBorderAroundFace(bool val) {
        if(m_peopleTagInMetaBorderAroundFace != val) {
            m_peopleTagInMetaBorderAroundFace = val;
            emit peopleTagInMetaBorderAroundFaceChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(QString peopleTagInMetaBorderAroundFaceColor READ getPeopleTagInMetaBorderAroundFaceColor WRITE setPeopleTagInMetaBorderAroundFaceColor NOTIFY peopleTagInMetaBorderAroundFaceColorChanged)
    QString getPeopleTagInMetaBorderAroundFaceColor() { return m_peopleTagInMetaBorderAroundFaceColor; }
    void setPeopleTagInMetaBorderAroundFaceColor(QString val) {
        if(m_peopleTagInMetaBorderAroundFaceColor != val) {
            m_peopleTagInMetaBorderAroundFaceColor = val;
            emit peopleTagInMetaBorderAroundFaceColorChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int peopleTagInMetaBorderAroundFaceWidth READ getPeopleTagInMetaBorderAroundFaceWidth WRITE setPeopleTagInMetaBorderAroundFaceWidth NOTIFY peopleTagInMetaBorderAroundFaceWidthChanged)
    int getPeopleTagInMetaBorderAroundFaceWidth() { return m_peopleTagInMetaBorderAroundFaceWidth; }
    void setPeopleTagInMetaBorderAroundFaceWidth(int val) {
        if(m_peopleTagInMetaBorderAroundFaceWidth != val) {
            m_peopleTagInMetaBorderAroundFaceWidth = val;
            emit peopleTagInMetaBorderAroundFaceWidthChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool peopleTagInMetaDisplay READ getPeopleTagInMetaDisplay WRITE setPeopleTagInMetaDisplay NOTIFY peopleTagInMetaDisplayChanged)
    bool getPeopleTagInMetaDisplay() { return m_peopleTagInMetaDisplay; }
    void setPeopleTagInMetaDisplay(bool val) {
        if(m_peopleTagInMetaDisplay != val) {
            m_peopleTagInMetaDisplay = val;
            emit peopleTagInMetaDisplayChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int peopleTagInMetaFontSize READ getPeopleTagInMetaFontSize WRITE setPeopleTagInMetaFontSize NOTIFY peopleTagInMetaFontSizeChanged)
    int getPeopleTagInMetaFontSize() { return m_peopleTagInMetaFontSize; }
    void setPeopleTagInMetaFontSize(int val) {
        if(m_peopleTagInMetaFontSize != val) {
            m_peopleTagInMetaFontSize = val;
            emit peopleTagInMetaFontSizeChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool peopleTagInMetaHybridMode READ getPeopleTagInMetaHybridMode WRITE setPeopleTagInMetaHybridMode NOTIFY peopleTagInMetaHybridModeChanged)
    bool getPeopleTagInMetaHybridMode() { return m_peopleTagInMetaHybridMode; }
    void setPeopleTagInMetaHybridMode(bool val) {
        if(m_peopleTagInMetaHybridMode != val) {
            m_peopleTagInMetaHybridMode = val;
            emit peopleTagInMetaHybridModeChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool peopleTagInMetaIndependentLabels READ getPeopleTagInMetaIndependentLabels WRITE setPeopleTagInMetaIndependentLabels NOTIFY peopleTagInMetaIndependentLabelsChanged)
    bool getPeopleTagInMetaIndependentLabels() { return m_peopleTagInMetaIndependentLabels; }
    void setPeopleTagInMetaIndependentLabels(bool val) {
        if(m_peopleTagInMetaIndependentLabels != val) {
            m_peopleTagInMetaIndependentLabels = val;
            emit peopleTagInMetaIndependentLabelsChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(QString openDefaultView READ getOpenDefaultView WRITE setOpenDefaultView NOTIFY openDefaultViewChanged)
    QString getOpenDefaultView() { return m_openDefaultView; }
    void setOpenDefaultView(QString val) {
        if(m_openDefaultView != val) {
            m_openDefaultView = val;
            emit openDefaultViewChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool openKeepLastLocation READ getOpenKeepLastLocation WRITE setOpenKeepLastLocation NOTIFY openKeepLastLocationChanged)
    bool getOpenKeepLastLocation() { return m_openKeepLastLocation; }
    void setOpenKeepLastLocation(bool val) {
        if(m_openKeepLastLocation != val) {
            m_openKeepLastLocation = val;
            emit openKeepLastLocationChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool openPreview READ getOpenPreview WRITE setOpenPreview NOTIFY openPreviewChanged)
    bool getOpenPreview() { return m_openPreview; }
    void setOpenPreview(bool val) {
        if(m_openPreview != val) {
            m_openPreview = val;
            emit openPreviewChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool openShowHiddenFilesFolders READ getOpenShowHiddenFilesFolders WRITE setOpenShowHiddenFilesFolders NOTIFY openShowHiddenFilesFoldersChanged)
    bool getOpenShowHiddenFilesFolders() { return m_openShowHiddenFilesFolders; }
    void setOpenShowHiddenFilesFolders(bool val) {
        if(m_openShowHiddenFilesFolders != val) {
            m_openShowHiddenFilesFolders = val;
            emit openShowHiddenFilesFoldersChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool openThumbnails READ getOpenThumbnails WRITE setOpenThumbnails NOTIFY openThumbnailsChanged)
    bool getOpenThumbnails() { return m_openThumbnails; }
    void setOpenThumbnails(bool val) {
        if(m_openThumbnails != val) {
            m_openThumbnails = val;
            emit openThumbnailsChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool openUserPlacesStandard READ getOpenUserPlacesStandard WRITE setOpenUserPlacesStandard NOTIFY openUserPlacesStandardChanged)
    bool getOpenUserPlacesStandard() { return m_openUserPlacesStandard; }
    void setOpenUserPlacesStandard(bool val) {
        if(m_openUserPlacesStandard != val) {
            m_openUserPlacesStandard = val;
            emit openUserPlacesStandardChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool openUserPlacesUser READ getOpenUserPlacesUser WRITE setOpenUserPlacesUser NOTIFY openUserPlacesUserChanged)
    bool getOpenUserPlacesUser() { return m_openUserPlacesUser; }
    void setOpenUserPlacesUser(bool val) {
        if(m_openUserPlacesUser != val) {
            m_openUserPlacesUser = val;
            emit openUserPlacesUserChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool openUserPlacesVolumes READ getOpenUserPlacesVolumes WRITE setOpenUserPlacesVolumes NOTIFY openUserPlacesVolumesChanged)
    bool getOpenUserPlacesVolumes() { return m_openUserPlacesVolumes; }
    void setOpenUserPlacesVolumes(bool val) {
        if(m_openUserPlacesVolumes != val) {
            m_openUserPlacesVolumes = val;
            emit openUserPlacesVolumesChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int openUserPlacesWidth READ getOpenUserPlacesWidth WRITE setOpenUserPlacesWidth NOTIFY openUserPlacesWidthChanged)
    int getOpenUserPlacesWidth() { return m_openUserPlacesWidth; }
    void setOpenUserPlacesWidth(int val) {
        if(m_openUserPlacesWidth != val) {
            m_openUserPlacesWidth = val;
            emit openUserPlacesWidthChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int openZoomLevel READ getOpenZoomLevel WRITE setOpenZoomLevel NOTIFY openZoomLevelChanged)
    int getOpenZoomLevel() { return m_openZoomLevel; }
    void setOpenZoomLevel(int val) {
        if(m_openZoomLevel != val) {
            m_openZoomLevel = val;
            emit openZoomLevelChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool histogram READ getHistogram WRITE setHistogram NOTIFY histogramChanged)
    bool getHistogram() { return m_histogram; }
    void setHistogram(bool val) {
        if(m_histogram != val) {
            m_histogram = val;
            emit histogramChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(QPoint histogramPosition READ getHistogramPosition WRITE setHistogramPosition NOTIFY histogramPositionChanged)
    QPoint getHistogramPosition() { return m_histogramPosition; }
    void setHistogramPosition(QPoint val) {
        if(m_histogramPosition != val) {
            m_histogramPosition = val;
            emit histogramPositionChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(QSize histogramSize READ getHistogramSize WRITE setHistogramSize NOTIFY histogramSizeChanged)
    QSize getHistogramSize() { return m_histogramSize; }
    void setHistogramSize(QSize val) {
        if(m_histogramSize != val) {
            m_histogramSize = val;
            emit histogramSizeChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(QString histogramVersion READ getHistogramVersion WRITE setHistogramVersion NOTIFY histogramVersionChanged)
    QString getHistogramVersion() { return m_histogramVersion; }
    void setHistogramVersion(QString val) {
        if(m_histogramVersion != val) {
            m_histogramVersion = val;
            emit histogramVersionChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int mainMenuWindowWidth READ getMainMenuWindowWidth WRITE setMainMenuWindowWidth NOTIFY mainMenuWindowWidthChanged)
    int getMainMenuWindowWidth() { return m_mainMenuWindowWidth; }
    void setMainMenuWindowWidth(int val) {
        if(m_mainMenuWindowWidth != val) {
            m_mainMenuWindowWidth = val;
            emit mainMenuWindowWidthChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool videoAutoplay READ getVideoAutoplay WRITE setVideoAutoplay NOTIFY videoAutoplayChanged)
    bool getVideoAutoplay() { return m_videoAutoplay; }
    void setVideoAutoplay(bool val) {
        if(m_videoAutoplay != val) {
            m_videoAutoplay = val;
            emit videoAutoplayChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool videoLoop READ getVideoLoop WRITE setVideoLoop NOTIFY videoLoopChanged)
    bool getVideoLoop() { return m_videoLoop; }
    void setVideoLoop(bool val) {
        if(m_videoLoop != val) {
            m_videoLoop = val;
            emit videoLoopChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(int videoVolume READ getVideoVolume WRITE setVideoVolume NOTIFY videoVolumeChanged)
    int getVideoVolume() { return m_videoVolume; }
    void setVideoVolume(int val) {
        if(m_videoVolume != val) {
            m_videoVolume = val;
            emit videoVolumeChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(QString videoThumbnailer READ getVideoThumbnailer WRITE setVideoThumbnailer NOTIFY videoThumbnailerChanged)
    QString getVideoThumbnailer() { return m_videoThumbnailer; }
    void setVideoThumbnailer(QString val) {
        if(m_videoThumbnailer != val) {
            m_videoThumbnailer = val;
            emit videoThumbnailerChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool mainMenuPopoutElement READ getMainMenuPopoutElement WRITE setMainMenuPopoutElement NOTIFY mainMenuPopoutElementChanged)
    bool getMainMenuPopoutElement() { return m_mainMenuPopoutElement; }
    void setMainMenuPopoutElement(bool val) {
        if(m_mainMenuPopoutElement != val) {
            m_mainMenuPopoutElement = val;
            emit mainMenuPopoutElementChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool metadataPopoutElement READ getMetadataPopoutElement WRITE setMetadataPopoutElement NOTIFY metadataPopoutElementChanged)
    bool getMetadataPopoutElement() { return m_metadataPopoutElement; }
    void setMetadataPopoutElement(bool val) {
        if(m_metadataPopoutElement != val) {
            m_metadataPopoutElement = val;
            emit metadataPopoutElementChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool histogramPopoutElement READ getHistogramPopoutElement WRITE setHistogramPopoutElement NOTIFY histogramPopoutElementChanged)
    bool getHistogramPopoutElement() { return m_histogramPopoutElement; }
    void setHistogramPopoutElement(bool val) {
        if(m_histogramPopoutElement != val) {
            m_histogramPopoutElement = val;
            emit histogramPopoutElementChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool scalePopoutElement READ getScalePopoutElement WRITE setScalePopoutElement NOTIFY scalePopoutElementChanged)
    bool getScalePopoutElement() { return m_scalePopoutElement; }
    void setScalePopoutElement(bool val) {
        if(m_scalePopoutElement != val) {
            m_scalePopoutElement = val;
            emit scalePopoutElementChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool openPopoutElement READ getOpenPopoutElement WRITE setOpenPopoutElement NOTIFY openPopoutElementChanged)
    bool getOpenPopoutElement() { return m_openPopoutElement; }
    void setOpenPopoutElement(bool val) {
        if(m_openPopoutElement != val) {
            m_openPopoutElement = val;
            emit openPopoutElementChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool openPopoutElementKeepOpen READ getOpenPopoutElementKeepOpen WRITE setOpenPopoutElementKeepOpen NOTIFY openPopoutElementKeepOpenChanged)
    bool getOpenPopoutElementKeepOpen() { return m_openPopoutElementKeepOpen; }
    void setOpenPopoutElementKeepOpen(bool val) {
        if(m_openPopoutElementKeepOpen != val) {
            m_openPopoutElementKeepOpen = val;
            emit openPopoutElementKeepOpenChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool slideShowSettingsPopoutElement READ getSlideShowSettingsPopoutElement WRITE setSlideShowSettingsPopoutElement NOTIFY slideShowSettingsPopoutElementChanged)
    bool getSlideShowSettingsPopoutElement() { return m_slideShowSettingsPopoutElement; }
    void setSlideShowSettingsPopoutElement(bool val) {
        if(m_slideShowSettingsPopoutElement != val) {
            m_slideShowSettingsPopoutElement = val;
            emit slideShowSettingsPopoutElementChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool slideShowControlsPopoutElement READ getSlideShowControlsPopoutElement WRITE setSlideShowControlsPopoutElement NOTIFY slideShowControlsPopoutElementChanged)
    bool getSlideShowControlsPopoutElement() { return m_slideShowControlsPopoutElement; }
    void setSlideShowControlsPopoutElement(bool val) {
        if(m_slideShowControlsPopoutElement != val) {
            m_slideShowControlsPopoutElement = val;
            emit slideShowControlsPopoutElementChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool fileRenamePopoutElement READ getFileRenamePopoutElement WRITE setFileRenamePopoutElement NOTIFY fileRenamePopoutElementChanged)
    bool getFileRenamePopoutElement() { return m_fileRenamePopoutElement; }
    void setFileRenamePopoutElement(bool val) {
        if(m_fileRenamePopoutElement != val) {
            m_fileRenamePopoutElement = val;
            emit fileRenamePopoutElementChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool fileDeletePopoutElement READ getFileDeletePopoutElement WRITE setFileDeletePopoutElement NOTIFY fileDeletePopoutElementChanged)
    bool getFileDeletePopoutElement() { return m_fileDeletePopoutElement; }
    void setFileDeletePopoutElement(bool val) {
        if(m_fileDeletePopoutElement != val) {
            m_fileDeletePopoutElement = val;
            emit fileDeletePopoutElementChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool aboutPopoutElement READ getAboutPopoutElement WRITE setAboutPopoutElement NOTIFY aboutPopoutElementChanged)
    bool getAboutPopoutElement() { return m_aboutPopoutElement; }
    void setAboutPopoutElement(bool val) {
        if(m_aboutPopoutElement != val) {
            m_aboutPopoutElement = val;
            emit aboutPopoutElementChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool imgurPopoutElement READ getImgurPopoutElement WRITE setImgurPopoutElement NOTIFY imgurPopoutElementChanged)
    bool getImgurPopoutElement() { return m_imgurPopoutElement; }
    void setImgurPopoutElement(bool val) {
        if(m_imgurPopoutElement != val) {
            m_imgurPopoutElement = val;
            emit imgurPopoutElementChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool wallpaperPopoutElement READ getWallpaperPopoutElement WRITE setWallpaperPopoutElement NOTIFY wallpaperPopoutElementChanged)
    bool getWallpaperPopoutElement() { return m_wallpaperPopoutElement; }
    void setWallpaperPopoutElement(bool val) {
        if(m_wallpaperPopoutElement != val) {
            m_wallpaperPopoutElement = val;
            emit wallpaperPopoutElementChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool filterPopoutElement READ getFilterPopoutElement WRITE setFilterPopoutElement NOTIFY filterPopoutElementChanged)
    bool getFilterPopoutElement() { return m_filterPopoutElement; }
    void setFilterPopoutElement(bool val) {
        if(m_filterPopoutElement != val) {
            m_filterPopoutElement = val;
            emit filterPopoutElementChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool settingsManagerPopoutElement READ getSettingsManagerPopoutElement WRITE setSettingsManagerPopoutElement NOTIFY settingsManagerPopoutElementChanged)
    bool getSettingsManagerPopoutElement() { return m_settingsManagerPopoutElement; }
    void setSettingsManagerPopoutElement(bool val) {
        if(m_settingsManagerPopoutElement != val) {
            m_settingsManagerPopoutElement = val;
            emit settingsManagerPopoutElementChanged();
            saveSettingsTimer->start();
        }
    }
    
    Q_PROPERTY(bool fileSaveAsPopoutElement READ getFileSaveAsPopoutElement WRITE setFileSaveAsPopoutElement NOTIFY fileSaveAsPopoutElementChanged)
    bool getFileSaveAsPopoutElement() { return m_fileSaveAsPopoutElement; }
    void setFileSaveAsPopoutElement(bool val) {
        if(m_fileSaveAsPopoutElement != val) {
            m_fileSaveAsPopoutElement = val;
            emit fileSaveAsPopoutElementChanged();
            saveSettingsTimer->start();
        }
    }
    

private:
    PQSettings();

    QTimer *saveSettingsTimer;
    QFileSystemWatcher *watcher;
    QTimer *watcherAddFileTimer;
    
    QString m_version;
    QString m_language;
    bool    m_windowMode;
    bool    m_windowDecoration;
    bool    m_saveWindowGeometry;
    bool    m_keepOnTop;
    bool    m_startupLoadLastLoadedImage;
    int     m_backgroundColorAlpha;
    int     m_backgroundColorBlue;
    int     m_backgroundColorGreen;
    int     m_backgroundColorRed;
    bool    m_backgroundImageCenter;
    bool    m_backgroundImagePath;
    bool    m_backgroundImageScale;
    bool    m_backgroundImageScaleCrop;
    bool    m_backgroundImageScreenshot;
    bool    m_backgroundImageStretch;
    bool    m_backgroundImageTile;
    bool    m_backgroundImageUse;
    int     m_animationDuration;
    QString m_animationType;
    bool    m_archiveUseExternalUnrar;
    bool    m_closeOnEmptyBackground;
    bool    m_fitInWindow;
    int     m_hotEdgeWidth;
    int     m_interpolationThreshold;
    bool    m_interpolationDisableForSmallImages;
    bool    m_keepZoomRotationMirror;
    bool    m_leftButtonMouseClickAndMove;
    bool    m_loopThroughFolder;
    int     m_marginAroundImage;
    int     m_mouseWheelSensitivity;
    int     m_pdfQuality;
    bool    m_pixmapCache;
    bool    m_showTransparencyMarkerBackground;
    QString m_sortImagesBy;
    bool    m_sortImagesAscending;
    int     m_trayIcon;
    int     m_zoomSpeed;
    int     m_quickInfoWindowButtonsSize;
    bool    m_quickInfoHideCounter;
    bool    m_quickInfoHideFilepath;
    bool    m_quickInfoHideFilename;
    bool    m_quickInfoWindowButtons;
    bool    m_quickInfoHideZoomLevel;
    bool    m_quickInfoHideRotationAngle;
    bool    m_quickInfoManageWindow;
    bool    m_thumbnailCache;
    bool    m_thumbnailCenterActive;
    bool    m_thumbnailDisable;
    bool    m_thumbnailFilenameInstead;
    int     m_thumbnailFilenameInsteadFontSize;
    int     m_thumbnailFontSize;
    bool    m_thumbnailKeepVisible;
    bool    m_thumbnailKeepVisibleWhenNotZoomedIn;
    int     m_thumbnailLiftUp;
    int     m_thumbnailMaxNumberThreads;
    QString m_thumbnailPosition;
    int     m_thumbnailSize;
    int     m_thumbnailSpacingBetween;
    bool    m_thumbnailWriteFilename;
    bool    m_slideShowHideQuickInfo;
    int     m_slideShowImageTransition;
    bool    m_slideShowLoop;
    QString m_slideShowMusicFile;
    bool    m_slideShowShuffle;
    int     m_slideShowTime;
    QString m_slideShowTypeAnimation;
    bool    m_slideShowIncludeSubFolders;
    bool    m_metaApplyRotation;
    bool    m_metaCopyright;
    bool    m_metaDimensions;
    bool    m_metaExposureTime;
    bool    m_metaFilename;
    bool    m_metaFileType;
    bool    m_metaFileSize;
    bool    m_metaFlash;
    bool    m_metaFLength;
    bool    m_metaFNumber;
    bool    m_metaGps;
    QString m_metaGpsMapService;
    bool    m_metaImageNumber;
    bool    m_metaIso;
    bool    m_metaKeywords;
    bool    m_metaLightSource;
    bool    m_metaLocation;
    bool    m_metaMake;
    bool    m_metaModel;
    bool    m_metaSceneType;
    bool    m_metaSoftware;
    bool    m_metaTimePhotoTaken;
    bool    m_metadataEnableHotEdge;
    int     m_metadataOpacity;
    int     m_metadataWindowWidth;
    bool    m_peopleTagInMetaAlwaysVisible;
    bool    m_peopleTagInMetaBorderAroundFace;
    QString m_peopleTagInMetaBorderAroundFaceColor;
    int     m_peopleTagInMetaBorderAroundFaceWidth;
    bool    m_peopleTagInMetaDisplay;
    int     m_peopleTagInMetaFontSize;
    bool    m_peopleTagInMetaHybridMode;
    bool    m_peopleTagInMetaIndependentLabels;
    QString m_openDefaultView;
    bool    m_openKeepLastLocation;
    bool    m_openPreview;
    bool    m_openShowHiddenFilesFolders;
    bool    m_openThumbnails;
    bool    m_openUserPlacesStandard;
    bool    m_openUserPlacesUser;
    bool    m_openUserPlacesVolumes;
    int     m_openUserPlacesWidth;
    int     m_openZoomLevel;
    bool    m_histogram;
    QPoint  m_histogramPosition;
    QSize   m_histogramSize;
    QString m_histogramVersion;
    int     m_mainMenuWindowWidth;
    bool    m_videoAutoplay;
    bool    m_videoLoop;
    int     m_videoVolume;
    QString m_videoThumbnailer;
    bool    m_mainMenuPopoutElement;
    bool    m_metadataPopoutElement;
    bool    m_histogramPopoutElement;
    bool    m_scalePopoutElement;
    bool    m_openPopoutElement;
    bool    m_openPopoutElementKeepOpen;
    bool    m_slideShowSettingsPopoutElement;
    bool    m_slideShowControlsPopoutElement;
    bool    m_fileRenamePopoutElement;
    bool    m_fileDeletePopoutElement;
    bool    m_aboutPopoutElement;
    bool    m_imgurPopoutElement;
    bool    m_wallpaperPopoutElement;
    bool    m_filterPopoutElement;
    bool    m_settingsManagerPopoutElement;
    bool    m_fileSaveAsPopoutElement;

private slots:
    void readSettings();
    void saveSettings();
    void addFileToWatcher();
    
signals:
    void versionChanged();
    void languageChanged();
    void windowModeChanged();
    void windowDecorationChanged();
    void saveWindowGeometryChanged();
    void keepOnTopChanged();
    void startupLoadLastLoadedImageChanged();
    void backgroundColorAlphaChanged();
    void backgroundColorBlueChanged();
    void backgroundColorGreenChanged();
    void backgroundColorRedChanged();
    void backgroundImageCenterChanged();
    void backgroundImagePathChanged();
    void backgroundImageScaleChanged();
    void backgroundImageScaleCropChanged();
    void backgroundImageScreenshotChanged();
    void backgroundImageStretchChanged();
    void backgroundImageTileChanged();
    void backgroundImageUseChanged();
    void animationDurationChanged();
    void animationTypeChanged();
    void archiveUseExternalUnrarChanged();
    void closeOnEmptyBackgroundChanged();
    void fitInWindowChanged();
    void hotEdgeWidthChanged();
    void interpolationThresholdChanged();
    void interpolationDisableForSmallImagesChanged();
    void keepZoomRotationMirrorChanged();
    void leftButtonMouseClickAndMoveChanged();
    void loopThroughFolderChanged();
    void marginAroundImageChanged();
    void mouseWheelSensitivityChanged();
    void pdfQualityChanged();
    void pixmapCacheChanged();
    void showTransparencyMarkerBackgroundChanged();
    void sortImagesByChanged();
    void sortImagesAscendingChanged();
    void trayIconChanged();
    void zoomSpeedChanged();
    void quickInfoWindowButtonsSizeChanged();
    void quickInfoHideCounterChanged();
    void quickInfoHideFilepathChanged();
    void quickInfoHideFilenameChanged();
    void quickInfoWindowButtonsChanged();
    void quickInfoHideZoomLevelChanged();
    void quickInfoHideRotationAngleChanged();
    void quickInfoManageWindowChanged();
    void thumbnailCacheChanged();
    void thumbnailCenterActiveChanged();
    void thumbnailDisableChanged();
    void thumbnailFilenameInsteadChanged();
    void thumbnailFilenameInsteadFontSizeChanged();
    void thumbnailFontSizeChanged();
    void thumbnailKeepVisibleChanged();
    void thumbnailKeepVisibleWhenNotZoomedInChanged();
    void thumbnailLiftUpChanged();
    void thumbnailMaxNumberThreadsChanged();
    void thumbnailPositionChanged();
    void thumbnailSizeChanged();
    void thumbnailSpacingBetweenChanged();
    void thumbnailWriteFilenameChanged();
    void slideShowHideQuickInfoChanged();
    void slideShowImageTransitionChanged();
    void slideShowLoopChanged();
    void slideShowMusicFileChanged();
    void slideShowShuffleChanged();
    void slideShowTimeChanged();
    void slideShowTypeAnimationChanged();
    void slideShowIncludeSubFoldersChanged();
    void metaApplyRotationChanged();
    void metaCopyrightChanged();
    void metaDimensionsChanged();
    void metaExposureTimeChanged();
    void metaFilenameChanged();
    void metaFileTypeChanged();
    void metaFileSizeChanged();
    void metaFlashChanged();
    void metaFLengthChanged();
    void metaFNumberChanged();
    void metaGpsChanged();
    void metaGpsMapServiceChanged();
    void metaImageNumberChanged();
    void metaIsoChanged();
    void metaKeywordsChanged();
    void metaLightSourceChanged();
    void metaLocationChanged();
    void metaMakeChanged();
    void metaModelChanged();
    void metaSceneTypeChanged();
    void metaSoftwareChanged();
    void metaTimePhotoTakenChanged();
    void metadataEnableHotEdgeChanged();
    void metadataOpacityChanged();
    void metadataWindowWidthChanged();
    void peopleTagInMetaAlwaysVisibleChanged();
    void peopleTagInMetaBorderAroundFaceChanged();
    void peopleTagInMetaBorderAroundFaceColorChanged();
    void peopleTagInMetaBorderAroundFaceWidthChanged();
    void peopleTagInMetaDisplayChanged();
    void peopleTagInMetaFontSizeChanged();
    void peopleTagInMetaHybridModeChanged();
    void peopleTagInMetaIndependentLabelsChanged();
    void openDefaultViewChanged();
    void openKeepLastLocationChanged();
    void openPreviewChanged();
    void openShowHiddenFilesFoldersChanged();
    void openThumbnailsChanged();
    void openUserPlacesStandardChanged();
    void openUserPlacesUserChanged();
    void openUserPlacesVolumesChanged();
    void openUserPlacesWidthChanged();
    void openZoomLevelChanged();
    void histogramChanged();
    void histogramPositionChanged();
    void histogramSizeChanged();
    void histogramVersionChanged();
    void mainMenuWindowWidthChanged();
    void videoAutoplayChanged();
    void videoLoopChanged();
    void videoVolumeChanged();
    void videoThumbnailerChanged();
    void mainMenuPopoutElementChanged();
    void metadataPopoutElementChanged();
    void histogramPopoutElementChanged();
    void scalePopoutElementChanged();
    void openPopoutElementChanged();
    void openPopoutElementKeepOpenChanged();
    void slideShowSettingsPopoutElementChanged();
    void slideShowControlsPopoutElementChanged();
    void fileRenamePopoutElementChanged();
    void fileDeletePopoutElementChanged();
    void aboutPopoutElementChanged();
    void imgurPopoutElementChanged();
    void wallpaperPopoutElementChanged();
    void filterPopoutElementChanged();
    void settingsManagerPopoutElementChanged();
    void fileSaveAsPopoutElementChanged();

};

#endif // PQSETTINGS_H
