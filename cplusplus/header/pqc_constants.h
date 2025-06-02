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
#include <pqc_settings.h>

#include <QObject>
#include <QStandardPaths>
#include <QDir>
#include <QTimer>

class PQCConstants : public QObject {

    Q_OBJECT

public:
    static PQCConstants& get() {
        static PQCConstants instance;
        return instance;
    }
    ~PQCConstants() {}

    PQCConstants(PQCConstants const&)     = delete;
    void operator=(PQCConstants const&) = delete;

    Q_PROPERTY(QString startupFileLoad MEMBER m_startupFileLoad NOTIFY startupFileLoadChanged)

    Q_PROPERTY(int windowWidth MEMBER m_windowWidth NOTIFY windowWidthChanged)
    Q_PROPERTY(int windowHeight MEMBER m_windowHeight NOTIFY windowHeightChanged)
    Q_PROPERTY(int windowState MEMBER m_windowState NOTIFY windowStateChanged)
    Q_PROPERTY(bool windowFullScreen MEMBER m_windowFullScreen NOTIFY windowFullScreenChanged)
    Q_PROPERTY(bool windowMaxAndNotWindowed MEMBER m_windowMaxAndNotWindowed NOTIFY windowMaxAndNotWindowedChanged)

    Q_PROPERTY(bool photoQtStartupDone MEMBER m_photoQtStartupDone NOTIFY photoQtStartupDoneChanged)
    Q_PROPERTY(bool photoQtShuttingDown MEMBER m_photoQtShuttingDown NOTIFY photoQtShuttingDownChanged)

    Q_PROPERTY(bool faceTaggingMode MEMBER m_faceTaggingMode NOTIFY faceTaggingModeChanged)
    Q_PROPERTY(bool modalWindowOpen MEMBER m_modalWindowOpen NOTIFY modalWindowOpenChanged)
    Q_PROPERTY(QString idOfVisibleItem MEMBER m_idOfVisibleItem NOTIFY idOfVisibleItemChanged)
    Q_PROPERTY(double devicePixelRatio MEMBER m_devicePixelRatio NOTIFY devicePixelRatioChanged)
    Q_PROPERTY(bool touchGestureActive MEMBER m_touchGestureActive NOTIFY touchGestureActiveChanged)

    Q_PROPERTY(QRect statusInfoCurrentRect MEMBER m_statusInfoCurrentRect NOTIFY statusInfoCurrentRectChanged)
    Q_PROPERTY(QRect quickActionsCurrentRect MEMBER m_quickActionsCurrentRect NOTIFY quickActionsCurrentRectChanged)
    Q_PROPERTY(QRect windowButtonsCurrentRect MEMBER m_windowButtonsCurrentRect NOTIFY windowButtonsCurrentRectChanged)
    Q_PROPERTY(bool statusInfoMovedManually MEMBER m_statusInfoMovedManually NOTIFY statusInfoMovedManuallyChanged)
    Q_PROPERTY(bool quickActionsMovedManually MEMBER m_quickActionsMovedManually NOTIFY quickActionsMovedManuallyChanged)
    Q_PROPERTY(bool statusInfoMovedDown MEMBER m_statusInfoMovedDown NOTIFY statusInfoMovedDownChanged)

    Q_PROPERTY(int howManyFiles MEMBER m_howManyFiles NOTIFY howManyFilesChanged)
    Q_PROPERTY(QString lastExecutedShortcutCommand MEMBER m_lastExecutedShortcutCommand NOTIFY lastExecutedShortcutCommandChanged)

    Q_PROPERTY(qint64 initTime MEMBER m_initTime NOTIFY initTimeChanged)

    void setInitTime(qint64 t) {
        m_initTime = t;
        initTimeChanged();
    }

private:
    PQCConstants() : QObject() {

        m_startupFileLoad = "";

        m_windowWidth = 0;
        m_windowHeight = 0;
        m_windowState = Qt::WindowNoState;
        m_windowFullScreen = false;
        m_windowMaxAndNotWindowed = true;
        m_photoQtStartupDone = false;
        m_howManyFiles = 0;
        m_faceTaggingMode = false;
        m_idOfVisibleItem = "";
        m_modalWindowOpen = false;
        m_lastExecutedShortcutCommand = "";

        m_statusInfoCurrentRect = QRect(0,0,0,0);
        m_quickActionsCurrentRect = QRect(0,0,0,0);
        m_windowButtonsCurrentRect = QRect(0,0,0,0);
        m_statusInfoMovedManually = false;
        m_quickActionsMovedManually = false;
        m_statusInfoMovedDown = false;

        m_devicePixelRatio = 1.0;
        if(PQCSettings::get()["imageviewRespectDevicePixelRatio"].toBool())
            m_devicePixelRatio = PQCScriptsImages::get().getPixelDensity();

        m_touchGestureActive = false;

        m_updateDevicePixelRatio = new QTimer;
        m_updateDevicePixelRatio->setInterval(1000*60*5);
        m_updateDevicePixelRatio->setSingleShot(false);
        connect(m_updateDevicePixelRatio, &QTimer::timeout, this, [=]() {
            m_devicePixelRatio = 1.0;
            if(PQCSettings::get()["imageviewRespectDevicePixelRatio"].toBool())
                m_devicePixelRatio = PQCScriptsImages::get().getPixelDensity();
        });
        m_updateDevicePixelRatio->start();

        m_initTime = 0;

    }

    QString m_startupFileLoad;

    int m_windowWidth;
    int m_windowHeight;

    bool m_photoQtStartupDone;
    bool m_photoQtShuttingDown;
    int m_windowState;
    bool m_windowFullScreen;
    bool m_windowMaxAndNotWindowed;

    bool m_faceTaggingMode;
    bool m_modalWindowOpen;
    QString m_idOfVisibleItem;
    double m_devicePixelRatio;
    bool m_touchGestureActive;

    QRect m_statusInfoCurrentRect;
    QRect m_quickActionsCurrentRect;
    QRect m_windowButtonsCurrentRect;
    bool m_statusInfoMovedManually;
    bool m_quickActionsMovedManually;
    bool m_statusInfoMovedDown;

    int m_howManyFiles;

    QTimer *m_updateDevicePixelRatio;
    QString m_lastExecutedShortcutCommand;

    qint64 m_initTime;

Q_SIGNALS:
    void startupFileLoadChanged();
    void windowWidthChanged();
    void windowHeightChanged();
    void windowStateChanged();
    void windowFullScreenChanged();
    void windowMaxAndNotWindowedChanged();
    void photoQtStartupDoneChanged();
    void photoQtShuttingDownChanged();
    void faceTaggingModeChanged();
    void modalWindowOpenChanged();
    void idOfVisibleItemChanged();
    void devicePixelRatioChanged();
    void touchGestureActiveChanged();
    void howManyFilesChanged();
    void lastExecutedShortcutCommandChanged();
    void statusInfoCurrentRectChanged();
    void quickActionsCurrentRectChanged();
    void windowButtonsCurrentRectChanged();
    void statusInfoMovedManuallyChanged();
    void quickActionsMovedManuallyChanged();
    void statusInfoMovedDownChanged();
    void initTimeChanged();

};

#endif
