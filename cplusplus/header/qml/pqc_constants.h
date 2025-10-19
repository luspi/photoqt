/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
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
#pragma once

#include <qml/pqc_resolutioncache.h>
#include <qml/pqc_scriptsimages.h>
#include <qml/pqc_localserver.h>
#include <shared/pqc_csettings.h>

#include <QObject>
#include <QStandardPaths>
#include <QDir>
#include <QTimer>
#include <QRect>
#include <QQmlEngine>
#include <QApplication>

/*************************************************************/
/*************************************************************/
//
//      NOTE: This singleton CANNOT be used from C++.
//            It can ONLY be used from QML.
//
/*************************************************************/
/*************************************************************/

class PQCConstants : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:

    explicit PQCConstants() : QObject() {

        m_availableWidth = 0;
        m_availableHeight = 0;
        m_menuBarHeight = 0;
        m_footerHeight = 0;
        m_mainWindowBeingResized = false;
        m_windowState = Qt::WindowNoState;
        m_windowFullScreen = false;
        m_windowMaxAndNotWindowed = true;
        m_faceTaggingMode = false;
        m_idOfVisibleItem = "";
        m_modalWindowOpen = false;
        m_lastExecutedShortcutCommand = "";
        m_ignoreFileFolderChangesTemporary = false;
        m_statusinfoIsVisible = true;
        m_shiftKeyPressed = false;

        m_slideshowRunning = false;
        m_slideshowRunningAndPlaying = false;
        m_slideshowVolume = 1.0;

        m_currentImageSource = "";
        m_currentImageScale = 1;
        m_currentImageRotation = 0;
        m_currentImageResolution = QSize(0,0);
        m_currentImageDefaultScale = 1.0;
        m_currentFileInsideNum = 0;
        m_currentFileInsideTotal = 0;
        m_currentFileInsideName = "";
        m_currentFileInsideList = {};
        m_imageInitiallyLoaded = false;

        m_currentVisibleContentPos = QPoint(-1,-1);
        m_currentVisibleContentSize = QSize(-1,-1);
        m_currentVisibleAreaX = 0;
        m_currentVisibleAreaY = 0;
        m_currentVisibleAreaWidthRatio = 0;
        m_currentVisibleAreaHeightRatio = 0;

        m_currentArchiveComboOpen = false;
        m_currentImageIsPhotoSphere = false;
        m_currentImageIsMotionPhoto = false;
        m_currentImageIsAnimated = false;
        m_currentImageIsDocument = false;
        m_currentImageIsArchive = false;
        m_showingPhotoSphere = false;
        m_motionPhotoIsPlaying = false;
        m_animatedImageIsPlaying = false;
        m_barcodeDisplayed = false;
        m_currentZValue = 1;
        m_extraControlsLocation = QPoint(-1,-1);

        m_thumbnailsBarWidth = 0;
        m_thumbnailsBarHeight = 0;
        m_thumbnailsBarOpacity = 0;
        m_thumbnailsMenuReloadIndex = -1;
        m_metadataOpacity = 0;
        m_mainmenuOpacity = 0;

        m_filedialogCurrentSelection.clear();
        m_filedialogCurrentIndex = -1;
        m_filedialogPlacesCurrentEntryId = "";
        m_filedialogPlacesCurrentEntryHidden = "false";
        m_filedialogPlacesShowHidden = false;
        m_filedialogHistory.clear();
        m_filedialogHistoryIndex = 0;
        m_filedialogPlacesWidth = 0;
        m_filedialogFileviewWidth = 0;
        m_filedialogAddressEditVisible = false;

        m_settingsManagerSettingChanged = false;
        m_settingsManagerCacheShortcutNames.clear();

        m_currentlyShowingVideo = false;
        m_currentlyShowingVideoPosition = 0;
        m_currentlyShowingVideoDuration = 0;
        m_currentlyShowingVideoHasAudio = false;
        m_currentlyShowingVideoPlaying = false;

        // cache any possible resolution change
        connect(this, &PQCConstants::currentImageResolutionChanged, this, [=](){
            if(m_currentImageResolution.height() > 0 && m_currentImageResolution.width() > 0)
                PQCResolutionCache::get().saveResolution(QFileInfo(m_currentImageSource).fileName(), m_currentImageResolution);
        });

        m_statusInfoCurrentRect = QRect(0,0,0,0);
        m_quickActionsCurrentRect = QRect(0,0,0,0);
        m_windowButtonsCurrentRect = QRect(0,0,0,0);
        m_statusInfoMovedManually = false;
        m_quickActionsMovedManually = false;
        m_statusInfoMovedDown = false;

        m_devicePixelRatio = 1.0;
        // if(PQCCSettings::get().getImageviewRespectDevicePixelRatio())
            // m_devicePixelRatio = PQCScriptsImages::get().getPixelDensity();

        m_touchGestureActive = false;

        m_updateDevicePixelRatio = new QTimer;
        m_updateDevicePixelRatio->setInterval(1000*60*5);
        m_updateDevicePixelRatio->setSingleShot(false);
        connect(m_updateDevicePixelRatio, &QTimer::timeout, this, [=]() {
            m_devicePixelRatio = 1.0;
            if(PQCCSettings::get().getImageviewRespectDevicePixelRatio())
                m_devicePixelRatio = PQCScriptsImages::get().getPixelDensity();
        });
        m_updateDevicePixelRatio->start();

        m_lastInternalShortcutExecuted = 0;
        m_whichContextMenusOpen.clear();

        m_colorProfileCache.clear();

        /****************************************/

        // in order to initialize the startup properties
        // we check if there is a cached value in PQCNotify
        // and we react to any changes to those values

        // TODO!!!
        m_startupFilePath = "";//PQCNotifyCPP::get().getFilePath();
        if(m_startupFilePath != "") {
            QFileInfo info(m_startupFilePath);
            m_startupFileIsFolder = info.isDir();
        } else
            m_startupFileIsFolder = false;
        // m_startupStartInTray = PQCNotifyCPP::get().getStartInTray();
        // m_startupHaveScreenshots = PQCNotifyCPP::get().getHaveScreenshots();
        // m_startupHaveSettingUpdate = (PQCNotifyCPP::get().getSettingUpdate().length() > 0);

        // connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::debugChanged, this, [=](bool val) { m_debugMode = val; Q_EMIT debugModeChanged(); });
        // connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::startInTrayChanged, this, [=](bool val) { m_startupStartInTray = val; Q_EMIT startupStartInTrayChanged(); });
        // connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::haveScreenshotsChanged, this, [=](bool val) { m_startupHaveScreenshots = val; Q_EMIT startupHaveScreenshotsChanged(); });
        // connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::settingUpdateChanged, this, [=](QStringList val) { m_startupHaveSettingUpdate = (val.length()>0); Q_EMIT startupHaveSettingUpdateChanged(); });



        connect(&PQCQLocalServer::get(), &PQCQLocalServer::performAction, this, [=](QString what, QStringList args) {

            // a color profile was set for some file
            if(what == "colorprofile" && args.length() > 1) {

                m_colorProfileCache[args[0]] = args[1];
                Q_EMIT colorProfileCacheChanged();

            // q startup message -> check for passed on filename
            } else if(what == "startup") {

                for(qsizetype i = 0; i < args.length(); ++i) {
                    if(args[i] == ":::FILE:::" && i < args.length()-1) {
                        m_startupFilePath = args[i+1];
                        if(m_startupFilePath != "") {
                            QFileInfo info(m_startupFilePath);
                            m_startupFileIsFolder = info.isDir();
                        } else
                            m_startupFileIsFolder = false;
                        Q_EMIT startupFilePathChanged();
                        Q_EMIT startupFileIsFolderChanged();
                    }
                }

            }
        });

    }

    /******************************************************/
    // some startup properties

    Q_PROPERTY(QString startupFilePath MEMBER m_startupFilePath NOTIFY startupFilePathChanged)
    Q_PROPERTY(bool startupFileIsFolder MEMBER m_startupFileIsFolder NOTIFY startupFileIsFolderChanged)
    Q_PROPERTY(bool startupStartInTray MEMBER m_startupStartInTray NOTIFY startupStartInTrayChanged)
    Q_PROPERTY(bool startupHaveScreenshots MEMBER m_startupHaveScreenshots NOTIFY startupHaveScreenshotsChanged)
    Q_PROPERTY(bool startupHaveSettingUpdate MEMBER m_startupHaveSettingUpdate NOTIFY startupHaveSettingUpdateChanged)


    /******************************************************/
    // some generic global properties

    Q_PROPERTY(bool photoQtShuttingDown MEMBER m_photoQtShuttingDown NOTIFY photoQtShuttingDownChanged)
    Q_PROPERTY(bool modalWindowOpen MEMBER m_modalWindowOpen NOTIFY modalWindowOpenChanged)
    Q_PROPERTY(QString idOfVisibleItem MEMBER m_idOfVisibleItem NOTIFY idOfVisibleItemChanged)
    Q_PROPERTY(double devicePixelRatio MEMBER m_devicePixelRatio NOTIFY devicePixelRatioChanged)
    Q_PROPERTY(bool touchGestureActive MEMBER m_touchGestureActive NOTIFY touchGestureActiveChanged)
    Q_PROPERTY(QString lastExecutedShortcutCommand MEMBER m_lastExecutedShortcutCommand NOTIFY lastExecutedShortcutCommandChanged)
    Q_PROPERTY(bool ignoreFileFolderChangesTemporary MEMBER m_ignoreFileFolderChangesTemporary NOTIFY ignoreFileFolderChangesTemporaryChanged)
    Q_PROPERTY(bool shiftKeyPressed MEMBER m_shiftKeyPressed NOTIFY shiftKeyPressedChanged)

    /******************************************************/
    // some window properties

    Q_PROPERTY(int availableWidth MEMBER m_availableWidth NOTIFY availableWidthChanged)
    Q_PROPERTY(int availableHeight MEMBER m_availableHeight NOTIFY availableHeightChanged)
    Q_PROPERTY(int menuBarHeight MEMBER m_menuBarHeight NOTIFY menuBarHeightChanged)
    Q_PROPERTY(int footerHeight MEMBER m_footerHeight NOTIFY footerHeightChanged)
    Q_PROPERTY(bool mainWindowBeingResized MEMBER m_mainWindowBeingResized NOTIFY mainWindowBeingResizedChanged)
    Q_PROPERTY(int windowState MEMBER m_windowState NOTIFY windowStateChanged)
    Q_PROPERTY(bool windowFullScreen MEMBER m_windowFullScreen NOTIFY windowFullScreenChanged)
    Q_PROPERTY(bool windowMaxAndNotWindowed MEMBER m_windowMaxAndNotWindowed NOTIFY windowMaxAndNotWindowedChanged)

    /******************************************************/
    // regarding certain specific elements

    Q_PROPERTY(QRect statusInfoCurrentRect MEMBER m_statusInfoCurrentRect NOTIFY statusInfoCurrentRectChanged)
    Q_PROPERTY(QRect quickActionsCurrentRect MEMBER m_quickActionsCurrentRect NOTIFY quickActionsCurrentRectChanged)
    Q_PROPERTY(QRect windowButtonsCurrentRect MEMBER m_windowButtonsCurrentRect NOTIFY windowButtonsCurrentRectChanged)
    Q_PROPERTY(bool statusInfoMovedManually MEMBER m_statusInfoMovedManually NOTIFY statusInfoMovedManuallyChanged)
    Q_PROPERTY(bool quickActionsMovedManually MEMBER m_quickActionsMovedManually NOTIFY quickActionsMovedManuallyChanged)
    Q_PROPERTY(bool statusInfoMovedDown MEMBER m_statusInfoMovedDown NOTIFY statusInfoMovedDownChanged)
    Q_PROPERTY(bool faceTaggingMode MEMBER m_faceTaggingMode NOTIFY faceTaggingModeChanged)
    Q_PROPERTY(bool statusinfoIsVisible MEMBER m_statusinfoIsVisible NOTIFY statusinfoIsVisibleChanged)
    Q_PROPERTY(int thumbnailsBarWidth MEMBER m_thumbnailsBarWidth NOTIFY thumbnailsBarWidthChanged)
    Q_PROPERTY(int thumbnailsBarHeight MEMBER m_thumbnailsBarHeight NOTIFY thumbnailsBarHeightChanged)
    Q_PROPERTY(double thumbnailsBarOpacity MEMBER m_thumbnailsBarOpacity NOTIFY thumbnailsBarOpacityChanged)
    Q_PROPERTY(int thumbnailsMenuReloadIndex MEMBER m_thumbnailsMenuReloadIndex NOTIFY thumbnailsMenuReloadIndexChanged)
    Q_PROPERTY(double mainmenuOpacity MEMBER m_mainmenuOpacity NOTIFY mainmenuOpacityChanged)
    Q_PROPERTY(double metadataOpacity MEMBER m_metadataOpacity NOTIFY metadataOpacityChanged)

    Q_PROPERTY(QList<int> filedialogCurrentSelection MEMBER m_filedialogCurrentSelection NOTIFY filedialogCurrentSelectionChanged)
    Q_PROPERTY(int filedialogCurrentIndex MEMBER m_filedialogCurrentIndex NOTIFY filedialogCurrentIndexChanged)
    Q_PROPERTY(QString filedialogPlacesCurrentEntryId MEMBER m_filedialogPlacesCurrentEntryId NOTIFY filedialogPlacesCurrentEntryIdChanged)
    Q_PROPERTY(QString filedialogPlacesCurrentEntryHidden MEMBER m_filedialogPlacesCurrentEntryHidden NOTIFY filedialogPlacesCurrentEntryHiddenChanged)
    Q_PROPERTY(bool filedialogPlacesShowHidden MEMBER m_filedialogPlacesShowHidden NOTIFY filedialogPlacesShowHiddenChanged)
    Q_PROPERTY(QStringList filedialogHistory MEMBER m_filedialogHistory NOTIFY filedialogHistoryChanged)
    Q_PROPERTY(int filedialogHistoryIndex MEMBER m_filedialogHistoryIndex NOTIFY filedialogHistoryIndexChanged)
    Q_PROPERTY(int filedialogPlacesWidth MEMBER m_filedialogPlacesWidth NOTIFY filedialogPlacesWidthChanged)
    Q_PROPERTY(int filedialogFileviewWidth MEMBER m_filedialogFileviewWidth NOTIFY filedialogFileviewWidthChanged)
    Q_PROPERTY(bool filedialogAddressEditVisible MEMBER m_filedialogAddressEditVisible NOTIFY filedialogAddressEditVisibleChanged)

    Q_PROPERTY(bool settingsManagerSettingChanged MEMBER m_settingsManagerSettingChanged NOTIFY settingsManagerSettingChangedChanged)
    // The following property can only be reliably used from all subtabs of Tab 4 (Shortcuts) of the settings manager
    Q_PROPERTY(QVariantList settingsManagerCacheShortcutNames MEMBER m_settingsManagerCacheShortcutNames NOTIFY settingsManagerCacheShortcutNamesChanged)


    /******************************************************/
    // some image properties

    Q_PROPERTY(QString currentImageSource MEMBER m_currentImageSource NOTIFY currentImageSourceChanged)
    Q_PROPERTY(double currentImageScale MEMBER m_currentImageScale NOTIFY currentImageScaleChanged)
    Q_PROPERTY(int currentImageRotation MEMBER m_currentImageRotation NOTIFY currentImageRotationChanged)
    Q_PROPERTY(QSize currentImageResolution MEMBER m_currentImageResolution NOTIFY currentImageResolutionChanged)
    Q_PROPERTY(double currentImageDefaultScale MEMBER m_currentImageDefaultScale NOTIFY currentImageDefaultScaleChanged)
    Q_PROPERTY(int currentFileInsideNum MEMBER m_currentFileInsideNum NOTIFY currentFileInsideNumChanged)
    Q_PROPERTY(int currentFileInsideTotal MEMBER m_currentFileInsideTotal NOTIFY currentFileInsideTotalChanged)
    Q_PROPERTY(QString currentFileInsideName MEMBER m_currentFileInsideName NOTIFY currentFileInsideNameChanged)
    Q_PROPERTY(QStringList currentFileInsideList MEMBER m_currentFileInsideList NOTIFY currentFileInsideListChanged)
    Q_PROPERTY(bool currentArchiveComboOpen MEMBER m_currentArchiveComboOpen NOTIFY currentArchiveComboOpenChanged)

    // this signals that an image (any image) has been fully loaded. Only then do we start, e.g., loading thumbnails
    Q_PROPERTY(bool imageInitiallyLoaded MEMBER m_imageInitiallyLoaded NOTIFY imageInitiallyLoadedChanged)

    Q_PROPERTY(bool currentlyShowingVideo MEMBER m_currentlyShowingVideo NOTIFY currentlyShowingVideoChanged)
    Q_PROPERTY(bool currentlyShowingVideoHasAudio MEMBER m_currentlyShowingVideoHasAudio NOTIFY currentlyShowingVideoHasAudioChanged)
    Q_PROPERTY(bool currentlyShowingVideoPlaying MEMBER m_currentlyShowingVideoPlaying NOTIFY currentlyShowingVideoPlayingChanged)
    Q_PROPERTY(int currentlyShowingVideoDuration MEMBER m_currentlyShowingVideoDuration NOTIFY currentlyShowingVideoDurationChanged)
    Q_PROPERTY(int currentlyShowingVideoPosition MEMBER m_currentlyShowingVideoPosition NOTIFY currentlyShowingVideoPositionChanged)

    Q_PROPERTY(QPoint currentVisibleContentPos MEMBER m_currentVisibleContentPos NOTIFY currentVisibleContentPosChanged)
    Q_PROPERTY(QSize currentVisibleContentSize MEMBER m_currentVisibleContentSize NOTIFY currentVisibleContentSizeChanged)
    Q_PROPERTY(double currentVisibleAreaX MEMBER m_currentVisibleAreaX NOTIFY currentVisibleAreaXChanged)
    Q_PROPERTY(double currentVisibleAreaY MEMBER m_currentVisibleAreaY NOTIFY currentVisibleAreaYChanged)
    Q_PROPERTY(double currentVisibleAreaWidthRatio MEMBER m_currentVisibleAreaWidthRatio NOTIFY currentVisibleAreaWidthRatioChanged)
    Q_PROPERTY(double currentVisibleAreaHeightRatio MEMBER m_currentVisibleAreaHeightRatio NOTIFY currentVisibleAreaHeightRatioChanged)

    Q_PROPERTY(bool currentImageIsPhotoSphere MEMBER m_currentImageIsPhotoSphere NOTIFY currentImageIsPhotoSphereChanged)
    Q_PROPERTY(bool currentImageIsMotionPhoto MEMBER m_currentImageIsMotionPhoto NOTIFY currentImageIsMotionPhotoChanged)
    Q_PROPERTY(bool currentImageIsAnimated MEMBER m_currentImageIsAnimated NOTIFY currentImageIsAnimatedChanged)
    Q_PROPERTY(bool currentImageIsDocument MEMBER m_currentImageIsDocument NOTIFY currentImageIsDocumentChanged)
    Q_PROPERTY(bool currentImageIsArchive MEMBER m_currentImageIsArchive NOTIFY currentImageIsArchiveChanged)

    Q_PROPERTY(bool showingPhotoSphere MEMBER m_showingPhotoSphere NOTIFY showingPhotoSphereChanged)
    Q_PROPERTY(bool motionPhotoIsPlaying MEMBER m_motionPhotoIsPlaying NOTIFY motionPhotoIsPlayingChanged)
    Q_PROPERTY(bool animatedImageIsPlaying MEMBER m_animatedImageIsPlaying NOTIFY animatedImageIsPlayingChanged)
    Q_PROPERTY(bool barcodeDisplayed MEMBER m_barcodeDisplayed NOTIFY barcodeDisplayedChanged)
    Q_PROPERTY(int currentZValue MEMBER m_currentZValue NOTIFY currentZValueChanged)
    Q_PROPERTY(QPoint extraControlsLocation MEMBER m_extraControlsLocation NOTIFY extraControlsLocationChanged)

    Q_PROPERTY(QVariantMap colorProfileCache MEMBER m_colorProfileCache NOTIFY colorProfileCacheChanged)

    /******************************************************/
    // some slideshow properties

    Q_PROPERTY(bool slideshowRunning MEMBER m_slideshowRunning NOTIFY slideshowRunningChanged)
    Q_PROPERTY(bool slideshowRunningAndPlaying MEMBER m_slideshowRunningAndPlaying NOTIFY slideshowRunningAndPlayingChanged)
    Q_PROPERTY(double slideshowVolume MEMBER m_slideshowVolume NOTIFY slideshowVolumeChanged)

    /******************************************************/
    // handling all the contextmenus

    Q_PROPERTY(QStringList whichContextMenusOpen READ getWhichContextMenusOpen NOTIFY whichContextMenusOpenChanged)
    Q_INVOKABLE void addToWhichContextMenusOpen(QString val) {
        if(!m_whichContextMenusOpen.contains(val)) {
            m_whichContextMenusOpen.append(val);
            Q_EMIT whichContextMenusOpenChanged();
        }
    }
    Q_INVOKABLE void removeFromWhichContextMenusOpen(QString val) {
        if(m_whichContextMenusOpen.contains(val)) {
            m_whichContextMenusOpen.remove(m_whichContextMenusOpen.indexOf(val));
            Q_EMIT whichContextMenusOpenChanged();
        }
    }
    Q_INVOKABLE QStringList getWhichContextMenusOpen() {
        return m_whichContextMenusOpen;
    }
    Q_INVOKABLE bool isContextmenuOpen(QString which) {
        return m_whichContextMenusOpen.contains(which);
    }

    /******************************************************/

private:
    QString m_startupFilePath;
    bool m_startupFileIsFolder;
    bool m_startupStartInTray;
    bool m_startupHaveScreenshots;
    bool m_startupHaveSettingUpdate;

    int m_availableWidth;
    int m_availableHeight;
    int m_menuBarHeight;
    int m_footerHeight;
    bool m_mainWindowBeingResized;

    bool m_photoQtShuttingDown;
    int m_windowState;
    bool m_windowFullScreen;
    bool m_windowMaxAndNotWindowed;

    bool m_faceTaggingMode;
    bool m_modalWindowOpen;
    QString m_idOfVisibleItem;
    double m_devicePixelRatio;
    bool m_touchGestureActive;
    bool m_ignoreFileFolderChangesTemporary;
    bool m_statusinfoIsVisible;
    bool m_shiftKeyPressed;

    bool m_slideshowRunning;
    bool m_slideshowRunningAndPlaying;
    double m_slideshowVolume;

    QString m_currentImageSource;
    double m_currentImageScale;
    int m_currentImageRotation;
    QSize m_currentImageResolution;
    double m_currentImageDefaultScale;
    int m_currentFileInsideNum;
    int m_currentFileInsideTotal;
    QString m_currentFileInsideName;
    QStringList m_currentFileInsideList;
    bool m_imageInitiallyLoaded;
    bool m_currentArchiveComboOpen;
    QPoint m_currentVisibleContentPos;
    QSize m_currentVisibleContentSize;
    double m_currentVisibleAreaX;
    double m_currentVisibleAreaY;
    double m_currentVisibleAreaWidthRatio;
    double m_currentVisibleAreaHeightRatio;
    int m_thumbnailsBarWidth;
    int m_thumbnailsBarHeight;
    double m_thumbnailsBarOpacity;
    int m_thumbnailsMenuReloadIndex;
    double m_mainmenuOpacity;
    double m_metadataOpacity;

    QList<int> m_filedialogCurrentSelection;
    int m_filedialogCurrentIndex;
    QString m_filedialogPlacesCurrentEntryId;
    QString m_filedialogPlacesCurrentEntryHidden;
    bool m_filedialogPlacesShowHidden;
    QStringList m_filedialogHistory;
    int m_filedialogHistoryIndex;
    int m_filedialogPlacesWidth;
    int m_filedialogFileviewWidth;
    bool m_filedialogAddressEditVisible;

    bool m_settingsManagerSettingChanged;
    QVariantList m_settingsManagerCacheShortcutNames;

    bool m_currentlyShowingVideo;
    bool m_currentlyShowingVideoHasAudio;
    bool m_currentlyShowingVideoPlaying;
    int m_currentlyShowingVideoPosition;
    int m_currentlyShowingVideoDuration;

    bool m_currentImageIsPhotoSphere;
    bool m_currentImageIsMotionPhoto;
    bool m_currentImageIsAnimated;
    bool m_currentImageIsDocument;
    bool m_currentImageIsArchive;
    bool m_showingPhotoSphere;
    bool m_motionPhotoIsPlaying;
    bool m_animatedImageIsPlaying;
    bool m_barcodeDisplayed;
    int m_currentZValue;
    QPoint m_extraControlsLocation;

    QVariantMap m_colorProfileCache;

    QRect m_statusInfoCurrentRect;
    QRect m_quickActionsCurrentRect;
    QRect m_windowButtonsCurrentRect;
    bool m_statusInfoMovedManually;
    bool m_quickActionsMovedManually;
    bool m_statusInfoMovedDown;

    QTimer *m_updateDevicePixelRatio;
    QString m_lastExecutedShortcutCommand;

    qint64 m_lastInternalShortcutExecuted;

    QStringList m_whichContextMenusOpen;

Q_SIGNALS:
    void startupFilePathChanged();
    void startupFileIsFolderChanged();
    void startupStartInTrayChanged();
    void startupHaveScreenshotsChanged();
    void startupHaveSettingUpdateChanged();

    void availableWidthChanged();
    void availableHeightChanged();
    void menuBarHeightChanged();
    void footerHeightChanged();
    void mainWindowBeingResizedChanged();
    void windowStateChanged();
    void windowFullScreenChanged();
    void windowMaxAndNotWindowedChanged();
    void photoQtShuttingDownChanged();
    void faceTaggingModeChanged();
    void modalWindowOpenChanged();
    void idOfVisibleItemChanged();
    void devicePixelRatioChanged();
    void touchGestureActiveChanged();
    void lastExecutedShortcutCommandChanged();
    void statusInfoCurrentRectChanged();
    void quickActionsCurrentRectChanged();
    void windowButtonsCurrentRectChanged();
    void statusInfoMovedManuallyChanged();
    void quickActionsMovedManuallyChanged();
    void statusInfoMovedDownChanged();
    void lastInternalShortcutExecutedChanged();
    void currentImageSourceChanged();
    void currentImageScaleChanged();
    void currentImageRotationChanged();
    void currentImageResolutionChanged();
    void globalContextMenuOpenedChanged();
    void whichContextMenusOpenChanged();
    void currentFileInsideNumChanged();
    void currentFileInsideTotalChanged();
    void currentFileInsideNameChanged();
    void currentFileInsideListChanged();
    void ignoreFileFolderChangesTemporaryChanged();
    void imageInitiallyLoadedChanged();
    void currentImageDefaultScaleChanged();
    void currentlyShowingVideoChanged();
    void currentlyShowingVideoHasAudioChanged();
    void currentlyShowingVideoPlayingChanged();
    void currentlyShowingVideoPositionChanged();
    void currentlyShowingVideoDurationChanged();
    void slideshowRunningChanged();
    void slideshowRunningAndPlayingChanged();
    void slideshowVolumeChanged();
    void statusinfoIsVisibleChanged();
    void currentVisibleContentPosChanged();
    void currentVisibleContentSizeChanged();
    void currentVisibleAreaXChanged();
    void currentVisibleAreaYChanged();
    void currentVisibleAreaWidthRatioChanged();
    void currentVisibleAreaHeightRatioChanged();
    void currentArchiveComboOpenChanged();
    void thumbnailsBarWidthChanged();
    void thumbnailsBarHeightChanged();
    void thumbnailsBarOpacityChanged();
    void thumbnailsMenuReloadIndexChanged();
    void mainmenuOpacityChanged();
    void metadataOpacityChanged();
    void showingPhotoSphereChanged();
    void motionPhotoIsPlayingChanged();
    void animatedImageIsPlayingChanged();
    void currentImageIsPhotoSphereChanged();
    void currentImageIsMotionPhotoChanged();
    void currentImageIsAnimatedChanged();
    void currentImageIsDocumentChanged();
    void currentImageIsArchiveChanged();
    void barcodeDisplayedChanged();
    void currentZValueChanged();
    void colorProfileCacheChanged();
    void extraControlsLocationChanged();
    void shiftKeyPressedChanged();
    void filedialogCurrentSelectionChanged();
    void filedialogCurrentIndexChanged();
    void filedialogPlacesCurrentEntryIdChanged();
    void filedialogPlacesCurrentEntryHiddenChanged();
    void filedialogPlacesShowHiddenChanged();
    void filedialogHistoryChanged();
    void filedialogHistoryIndexChanged();
    void filedialogPlacesWidthChanged();
    void filedialogFileviewWidthChanged();
    void filedialogAddressEditVisibleChanged();
    void settingsManagerSettingChangedChanged();
    void settingsManagerCacheShortcutNamesChanged();

};
