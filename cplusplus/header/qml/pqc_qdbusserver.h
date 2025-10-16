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

class PQCQDbusServer : public QObject {

    Q_OBJECT

public:
    static PQCQDbusServer& get() {
        static PQCQDbusServer instance;
        return instance;
    }

    PQCQDbusServer(PQCQDbusServer const&) = delete;
    void operator=(PQCQDbusServer const&) = delete;

    void sendMessage(QString what, QString message);
    bool hasExistingServer() { return m_existingServer; }

    QImage getImage(QString path);

    void setup() {}

private:
    PQCQDbusServer();
    ~PQCQDbusServer();

    QLocalServer *m_server;
    bool m_existingServer;

private Q_SLOTS:
    void handleConnection();

Q_SIGNALS:
    void performAction(QString what, QStringList args);

};
