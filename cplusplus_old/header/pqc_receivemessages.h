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

#include <QObject>
#include <QQmlEngine>

class QLocalServer;

class PQCReceiveMessages : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    // The same ones are listed in PQCSingleInstance
    enum class Actions {
        File = Qt::UserRole+1,
        Open,
        Show,
        Hide,
        Quit,
        Toggle,
        StartInTray,
        Tray,
        NoTray,
        Shortcut,
        Debug,
        NoDebug,
        Setting
    };

public:
    PQCReceiveMessages();

private Q_SLOTS:

    // A new application instance was started (notification to main instance)
    void newConnection();

    // This one is used in main process, handling the message sent by sub-instances
    void handleMessage(const QList<Actions> msg);

private:
    QLocalServer *m_server;

    QString m_receivedFile;
    QString m_receivedShortcut;
    QString m_receivedSetting[2];

    bool m_debugMode;

Q_SIGNALS:
    void cmdOpen();
    void cmdShow();
    void cmdHide();
    void cmdQuit();
    void cmdToggle();
    void cmdShortcutSequence(QString seq);
    void cmdTray(bool tray);
    void cmdSetStartInTray(bool tray);
    void cmdSetDebugMode(bool dbg);
    void cmdSettingUpdate(QStringList val);

    void debugModeChanged();

};
