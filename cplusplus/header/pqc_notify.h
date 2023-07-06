/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

#ifndef PQCNOTIFY_H
#define PQCNOTIFY_H

#include <QObject>

class PQCNotify : public QObject {

    Q_OBJECT

public:
    static PQCNotify& get();

    PQCNotify(PQCNotify const&)     = delete;
    void operator=(PQCNotify const&) = delete;

    /******************************************************/

    Q_PROPERTY(QString filePath READ getFilePath WRITE setFilePath NOTIFY filePathChanged)
    void setFilePath(QString val);
    Q_INVOKABLE QString getFilePath();

    /******************************************************/

    Q_PROPERTY(bool debug READ getDebug WRITE setDebug NOTIFY debugChanged)
    void setDebug(bool val);
    Q_INVOKABLE bool getDebug();

    /******************************************************/

    // used to show 'welcome' screen if this seems to be a new install
    Q_PROPERTY(bool freshInstall READ getFreshInstall WRITE setFreshInstall NOTIFY freshInstallChanged)
    void setFreshInstall(bool val);
    Q_INVOKABLE bool getFreshInstall();

    /******************************************************/

    Q_PROPERTY(int thumbs READ getThumbs WRITE setThumbs NOTIFY thumbsChanged)
    void setThumbs(int val);
    Q_INVOKABLE int getThumbs();

    /******************************************************/

    Q_PROPERTY(bool startInTray READ getStartInTray WRITE setStartInTray NOTIFY startInTrayChanged)
    void setStartInTray(bool val);
    Q_INVOKABLE bool getStartInTray();

    /******************************************************/

private:
    PQCNotify(QObject *parent = 0) : QObject(parent) {
        m_filepath = "";
        m_debug = false;
        m_freshInstall = false;
        m_startInTray = false;
        m_thumbs = 2;
    }
    // these are used at startup
    // afterwards we only listen to the signals
    QString m_filepath;
    bool m_debug;
    bool m_freshInstall;
    int m_thumbs;
    bool m_startInTray;

Q_SIGNALS:
    void filePathChanged();
    void debugChanged();
    void freshInstallChanged();
    void thumbsChanged();
    void startInTrayChanged();

    // these are kept similar to the
    void cmdOpen();
    void cmdShow();
    void cmdHide();
    void cmdToggle();
    void cmdShortcutSequence(QString seq);
    void cmdTray(bool tray);
//    void resetSessionData();

    void keyPress(int key, int modifiers);

};


#endif // PQCNotify_H
