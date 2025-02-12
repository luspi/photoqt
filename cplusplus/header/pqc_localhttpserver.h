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

#ifndef PQCLOCALHTTPSERVER_H
#define PQCLOCALHTTPSERVER_H

#include <QtGlobal>

#ifdef Q_OS_WIN
#undef WIN32_LEAN_AND_MEAN
#include <winsock2.h>
#endif

#include <QObject>

class QTcpSocket;
class QTcpServer;

class PQCLocalHttpServer : public QObject {

    Q_OBJECT

public:
    explicit PQCLocalHttpServer(QObject *parent = 0);
    ~PQCLocalHttpServer();
    QTcpSocket *socket ;
    bool isRunning();

public Q_SLOTS:
    void serve();
    int start();
    void stop();

private:
    qint64 bytesAvailable() const;
    QTcpServer *server;
};

#endif // PQCLOCALHTTPSERVER_H
