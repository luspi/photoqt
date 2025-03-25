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

    Q_PROPERTY(int windowWidth MEMBER m_windowWidth NOTIFY windowWidthChanged)
    Q_PROPERTY(int windowHeight MEMBER m_windowHeight NOTIFY windowHeightChanged)
    Q_PROPERTY(int windowState MEMBER m_windowState NOTIFY windowStateChanged);
    Q_PROPERTY(bool windowFullScreen MEMBER m_windowFullScreen NOTIFY windowFullScreenChanged);
    Q_PROPERTY(bool windowMaxAndNotWindowed MEMBER m_windowMaxAndNotWindowed NOTIFY windowMaxAndNotWindowedChanged);

    Q_PROPERTY(bool photoQtStartupDone MEMBER m_photoQtStartupDone NOTIFY photoQtStartupDoneChanged);
    Q_PROPERTY(bool photoQtShuttingDown MEMBER m_photoQtShuttingDown NOTIFY photoQtShuttingDownChanged);

    Q_PROPERTY(bool faceTaggingMode MEMBER m_faceTaggingMode NOTIFY faceTaggingModeChanged);
    Q_PROPERTY(bool modalWindowOpen MEMBER m_modalWindowOpen NOTIFY modalWindowOpenChanged);
    Q_PROPERTY(QString idOfVisibleItem MEMBER m_idOfVisibleItem NOTIFY idOfVisibleItemChanged);
    Q_PROPERTY(double devicePixelRatio MEMBER m_devicePixelRatio NOTIFY devicePixelRatioChanged);

    Q_PROPERTY(int howManyFiles MEMBER m_howManyFiles NOTIFY howManyFilesChanged)

private:
    PQCConstants() : QObject() {
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

        m_devicePixelRatio = 1.0;
        if(PQCSettings::get()["imageviewRespectDevicePixelRatio"].toBool())
            m_devicePixelRatio = PQCScriptsImages::get().getPixelDensity();

        m_updateDevicePixelRatio = new QTimer;
        m_updateDevicePixelRatio->setInterval(1000*60*5);
        m_updateDevicePixelRatio->setSingleShot(false);
        connect(m_updateDevicePixelRatio, &QTimer::timeout, this, [=]() {
            m_devicePixelRatio = 1.0;
            if(PQCSettings::get()["imageviewRespectDevicePixelRatio"].toBool())
                m_devicePixelRatio = PQCScriptsImages::get().getPixelDensity();
        });
        m_updateDevicePixelRatio->start();


    }

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

    int m_howManyFiles;

    QTimer *m_updateDevicePixelRatio;

Q_SIGNALS:
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
    void howManyFilesChanged();

};

#endif
