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

#ifndef PQCCONSTANTS_H
#define PQCCONSTANTS_H

#include <scripts/pqc_scriptsimages.h>
#include <pqc_settingscpp.h>
#include <pqc_resolutioncache.h>
#include <pqc_filefoldermodel.h>

#include <QObject>
#include <QStandardPaths>
#include <QDir>
#include <QTimer>

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

        m_startupFileLoad = "";

        m_windowWidth = 0;
        m_windowHeight = 0;
        m_windowState = Qt::WindowNoState;
        m_windowFullScreen = false;
        m_windowMaxAndNotWindowed = true;
        m_faceTaggingMode = false;
        m_idOfVisibleItem = "";
        m_modalWindowOpen = false;
        m_lastExecutedShortcutCommand = "";
        m_ignoreFileFolderChangesTemporary = false;
        m_statusinfoIsVisible = true;

        m_slideshowRunning = false;
        m_slideshowRunningAndPlaying = false;
        m_slideshowVolume = 1.0;

        m_currentImageScale = 1;
        m_currentImageRotation = 0;
        m_currentImageResolution = QSize(0,0);
        m_currentImageDefaultScale = 1.0;
        m_currentFileInsideNum = 0;
        m_currentFileInsideTotal = 0;
        m_currentFileInsideName = "";
        m_imageQMLItemHeight = 0;
        m_imageInitiallyLoaded = false;
        m_currentVisibleAreaX = 0;
        m_currentVisibleAreaY = 0;
        m_currentVisibleAreaWidthRatio = 0;
        m_currentVisibleAreaHeightRatio = 0;
        m_currentArchiveComboOpen = false;

        m_currentlyShowingVideo = false;
        m_currentlyShowingVideoHasAudio = false;
        m_currentlyShowingVideoPlaying = false;

        // cache any possible resolution change
        connect(this, &PQCConstants::currentImageResolutionChanged, this, [=]{
            if(m_currentImageResolution.height() > 0 && m_currentImageResolution.width() > 0)
                PQCResolutionCache::get().saveResolution(PQCFileFolderModel::get().getCurrentFile(), m_currentImageResolution);
        });

        m_statusInfoCurrentRect = QRect(0,0,0,0);
        m_quickActionsCurrentRect = QRect(0,0,0,0);
        m_windowButtonsCurrentRect = QRect(0,0,0,0);
        m_statusInfoMovedManually = false;
        m_quickActionsMovedManually = false;
        m_statusInfoMovedDown = false;

        m_devicePixelRatio = 1.0;
        if(PQCSettingsCPP::get().getImageviewRespectDevicePixelRatio())
            m_devicePixelRatio = PQCScriptsImages::get().getPixelDensity();

        m_touchGestureActive = false;

        m_updateDevicePixelRatio = new QTimer;
        m_updateDevicePixelRatio->setInterval(1000*60*5);
        m_updateDevicePixelRatio->setSingleShot(false);
        connect(m_updateDevicePixelRatio, &QTimer::timeout, this, [=]() {
            m_devicePixelRatio = 1.0;
            if(PQCSettingsCPP::get().getImageviewRespectDevicePixelRatio())
                m_devicePixelRatio = PQCScriptsImages::get().getPixelDensity();
        });
        m_updateDevicePixelRatio->start();

        m_initTime = 0;

        m_lastInternalShortcutExecuted = 0;

        m_whichContextMenusOpen.clear();

    }

    /******************************************************/
    // some generic global propertues

    Q_PROPERTY(QString startupFileLoad MEMBER m_startupFileLoad NOTIFY startupFileLoadChanged)
    Q_PROPERTY(bool photoQtShuttingDown MEMBER m_photoQtShuttingDown NOTIFY photoQtShuttingDownChanged)
    Q_PROPERTY(bool modalWindowOpen MEMBER m_modalWindowOpen NOTIFY modalWindowOpenChanged)
    Q_PROPERTY(QString idOfVisibleItem MEMBER m_idOfVisibleItem NOTIFY idOfVisibleItemChanged)
    Q_PROPERTY(double devicePixelRatio MEMBER m_devicePixelRatio NOTIFY devicePixelRatioChanged)
    Q_PROPERTY(bool touchGestureActive MEMBER m_touchGestureActive NOTIFY touchGestureActiveChanged)
    Q_PROPERTY(QString lastExecutedShortcutCommand MEMBER m_lastExecutedShortcutCommand NOTIFY lastExecutedShortcutCommandChanged)
    Q_PROPERTY(bool ignoreFileFolderChangesTemporary MEMBER m_ignoreFileFolderChangesTemporary NOTIFY ignoreFileFolderChangesTemporaryChanged)

    /******************************************************/
    // some window properties

    Q_PROPERTY(int windowWidth MEMBER m_windowWidth NOTIFY windowWidthChanged)
    Q_PROPERTY(int windowHeight MEMBER m_windowHeight NOTIFY windowHeightChanged)
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

    /******************************************************/
    // some image properties

    Q_PROPERTY(double currentImageScale MEMBER m_currentImageScale NOTIFY currentImageScaleChanged)
    Q_PROPERTY(int currentImageRotation MEMBER m_currentImageRotation NOTIFY currentImageRotationChanged)
    Q_PROPERTY(QSize currentImageResolution MEMBER m_currentImageResolution NOTIFY currentImageResolutionChanged)
    Q_PROPERTY(double currentImageDefaultScale MEMBER m_currentImageDefaultScale NOTIFY currentImageDefaultScaleChanged)
    Q_PROPERTY(int currentFileInsideNum MEMBER m_currentFileInsideNum NOTIFY currentFileInsideNumChanged)
    Q_PROPERTY(int currentFileInsideTotal MEMBER m_currentFileInsideTotal NOTIFY currentFileInsideTotalChanged)
    Q_PROPERTY(QString currentFileInsideName MEMBER m_currentFileInsideName NOTIFY currentFileInsideNameChanged)
    Q_PROPERTY(int imageQMLItemHeight MEMBER m_imageQMLItemHeight NOTIFY imageQMLItemHeightChanged)
    Q_PROPERTY(bool currentArchiveComboOpen MEMBER m_currentArchiveComboOpen NOTIFY currentArchiveComboOpenChanged)

    // this signals that an image (any image) has been fully loaded. Only then do we start, e.g., loading thumbnails
    Q_PROPERTY(bool imageInitiallyLoaded MEMBER m_imageInitiallyLoaded NOTIFY imageInitiallyLoadedChanged)

    Q_PROPERTY(bool currentlyShowingVideo MEMBER m_currentlyShowingVideo NOTIFY currentlyShowingVideoChanged)
    Q_PROPERTY(bool currentlyShowingVideoHasAudio MEMBER m_currentlyShowingVideoHasAudio NOTIFY currentlyShowingVideoHasAudioChanged)
    Q_PROPERTY(bool currentlyShowingVideoPlaying MEMBER m_currentlyShowingVideoPlaying NOTIFY currentlyShowingVideoPlayingChanged)

    Q_PROPERTY(double currentVisibleAreaX MEMBER m_currentVisibleAreaX NOTIFY currentVisibleAreaXChanged)
    Q_PROPERTY(double currentVisibleAreaY MEMBER m_currentVisibleAreaY NOTIFY currentVisibleAreaYChanged)
    Q_PROPERTY(double currentVisibleAreaWidthRatio MEMBER m_currentVisibleAreaWidthRatio NOTIFY currentVisibleAreaWidthRatioChanged)
    Q_PROPERTY(double currentVisibleAreaHeightRatio MEMBER m_currentVisibleAreaHeightRatio NOTIFY currentVisibleAreaHeightRatioChanged)

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

    Q_PROPERTY(qint64 initTime MEMBER m_initTime NOTIFY initTimeChanged)

    void setInitTime(qint64 t) {
        m_initTime = t;
        initTimeChanged();
    }

private:
    QString m_startupFileLoad;

    int m_windowWidth;
    int m_windowHeight;

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

    bool m_slideshowRunning;
    bool m_slideshowRunningAndPlaying;
    double m_slideshowVolume;

    double m_currentImageScale;
    int m_currentImageRotation;
    QSize m_currentImageResolution;
    double m_currentImageDefaultScale;
    int m_currentFileInsideNum;
    int m_currentFileInsideTotal;
    QString m_currentFileInsideName;
    bool m_imageInitiallyLoaded;
    int m_imageQMLItemHeight;
    bool m_currentArchiveComboOpen;
    double m_currentVisibleAreaX;
    double m_currentVisibleAreaY;
    double m_currentVisibleAreaWidthRatio;
    double m_currentVisibleAreaHeightRatio;

    bool m_currentlyShowingVideo;
    bool m_currentlyShowingVideoHasAudio;
    bool m_currentlyShowingVideoPlaying;

    QRect m_statusInfoCurrentRect;
    QRect m_quickActionsCurrentRect;
    QRect m_windowButtonsCurrentRect;
    bool m_statusInfoMovedManually;
    bool m_quickActionsMovedManually;
    bool m_statusInfoMovedDown;

    QTimer *m_updateDevicePixelRatio;
    QString m_lastExecutedShortcutCommand;

    qint64 m_initTime;
    qint64 m_lastInternalShortcutExecuted;

    QStringList m_whichContextMenusOpen;

Q_SIGNALS:
    void startupFileLoadChanged();
    void windowWidthChanged();
    void windowHeightChanged();
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
    void initTimeChanged();
    void lastInternalShortcutExecutedChanged();
    void currentImageScaleChanged();
    void currentImageRotationChanged();
    void currentImageResolutionChanged();
    void globalContextMenuOpenedChanged();
    void whichContextMenusOpenChanged();
    void currentFileInsideNumChanged();
    void currentFileInsideTotalChanged();
    void currentFileInsideNameChanged();
    void ignoreFileFolderChangesTemporaryChanged();
    void imageInitiallyLoadedChanged();
    void currentImageDefaultScaleChanged();
    void currentlyShowingVideoChanged();
    void currentlyShowingVideoHasAudioChanged();
    void currentlyShowingVideoPlayingChanged();
    void slideshowRunningChanged();
    void slideshowRunningAndPlayingChanged();
    void slideshowVolumeChanged();
    void imageQMLItemHeightChanged();
    void statusinfoIsVisibleChanged();
    void currentVisibleAreaXChanged();
    void currentVisibleAreaYChanged();
    void currentVisibleAreaWidthRatioChanged();
    void currentVisibleAreaHeightRatioChanged();
    void currentArchiveComboOpenChanged();

};

#endif
