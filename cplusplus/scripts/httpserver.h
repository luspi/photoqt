/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

#ifndef PQHTTPSERVER_H
#define PQHTTPSERVER_H

#include <QNetworkInterface>
#include <QObject>
#include <QTcpSocket>
#include <QTcpServer>
#include "../logger.h"

class PQHttpServer : public QObject {

    Q_OBJECT

public:
    explicit PQHttpServer(QObject *parent = 0);
    ~PQHttpServer();
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

#endif // PQHTTPSERVER_H
