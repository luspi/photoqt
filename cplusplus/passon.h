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

#ifndef PQPASSON_H
#define PQPASSON_H

#include <QObject>
// DO NOT use PQSettings in this class!
// The right folders are not yet set up at this point
// This will cause unintended side effects
// including not loading the settings properly/resetting defaults

class PQPassOn : public QObject {

    Q_OBJECT

public:
    static PQPassOn& get() {
        static PQPassOn instance;
        return instance;
    }

    PQPassOn(PQPassOn const&)     = delete;
    void operator=(PQPassOn const&) = delete;

    /******************************************************/
    // at startup, call this method instead of signal directly
    // later-on, the signal can be used without this method
    void setFilePath(QString path) {
        filepath = path;
        Q_EMIT cmdFilePath(filepath);
    }
    Q_INVOKABLE QString getFilePath() {
        return filepath;
    }
    /******************************************************/
    // used to show 'welcome' screen if this seems to be a new install
    void setFreshInstall(bool inst) {
        freshInstall = inst;
    }
    Q_INVOKABLE bool getFreshInstall() {
        return freshInstall;
    }
    /******************************************************/
    void setThumbs(bool thb) {
        thumbs = int(thb);
        Q_EMIT cmdThumbs(thb);
    }
    Q_INVOKABLE int getThumbs() {
        return thumbs;
    }
    /******************************************************/
    void setStartInTray() {
        startintray = true;
    }
    Q_INVOKABLE bool getStartInTray() {
        return startintray;
    }
    /******************************************************/


private:
    PQPassOn() {
        filepath = "";
        freshInstall = false;
        startintray = false;
        thumbs = 2;
    }
    // these are used at startup
    // afterwards we only listen to the signals
    QString filepath;
    bool freshInstall;
    int thumbs;
    bool startintray;

Q_SIGNALS:
    void cmdFilePath(QString path);
    void cmdOpen();
    void cmdShow();
    void cmdHide();
    void cmdToggle();
    void cmdThumbs(bool thb);
    void cmdShortcutSequence(QString seq);
    void cmdTray(bool tray);
    void resetSessionData();

};


#endif // PQPASSON_H
