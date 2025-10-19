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

class QLocalServer;

class PQCQLocalServer : public QObject {

    Q_OBJECT

public:
    static PQCQLocalServer& get() {
        static PQCQLocalServer instance;
        return instance;
    }

    PQCQLocalServer(PQCQLocalServer const&) = delete;
    void operator=(PQCQLocalServer const&) = delete;

    void sendMessage(QString what, QString message);
    bool hasExistingServer() { return m_existingServer; }

    QImage getImage(QString path);
    QStringList getStartupMessage() { return m_startupMessage; }
    void checkForData();

private:
    PQCQLocalServer();
    ~PQCQLocalServer();

    QLocalServer *m_server;
    bool m_existingServer;

    // we store a duplicate here to be used during startup
    QStringList m_startupMessage;

private Q_SLOTS:
    void handleConnection();

Q_SIGNALS:
    void performAction(QString what, QStringList args);

};
