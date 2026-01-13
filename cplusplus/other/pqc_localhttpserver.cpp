/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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

#include <pqc_localhttpserver.h>
#include <QImage>
#include <QBuffer>
#include <thread>
#include <chrono>
#include <QDir>
#include <QNetworkInterface>
#include <QTcpSocket>
#include <QTcpServer>
#include <QtDebug>

void delayms( int millisecondsToWait );

PQCLocalHttpServer::PQCLocalHttpServer(QObject *parent) : QObject(parent) {
    server = new QTcpServer(this);
    // waiting for the web browser to make contact,this will emit signal
    connect(server, SIGNAL(newConnection()),this, SLOT(serve()));
}

PQCLocalHttpServer::~PQCLocalHttpServer() {
    if(server->isListening())
        server->close();
}

int PQCLocalHttpServer::start() {

    if(!server->listen(QHostAddress::Any,0))
        qWarning() << "ERROR: server unable to listen on automatic port";

    int count = 0;
    while(!server->isListening() && count < 100) {
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
        ++count;
    }

    return server->serverPort();

}

void PQCLocalHttpServer::stop() {

    server->close();

}

void PQCLocalHttpServer::serve() {

    socket = server->nextPendingConnection();

    if(socket == nullptr) {
        qWarning() << "No pending connection";
        return;
    }

    QImage image(QString("%1/photoqtchromecast.jpg").arg(QDir::tempPath()));
    QByteArray data;
    QBuffer buffer(&data);
    buffer.open(QIODevice::WriteOnly);
    image.save(&buffer, "JPG");

    QByteArray payload = "HTTP/1.0 200 Ok\n";
    payload += "Content-Type: image/jpg\n";
    payload += QString("Content-Length: %1\n\n").arg(data.size()).toUtf8();
    payload += data;

    socket->write(payload);
    socket->waitForBytesWritten();

    socket->flush();
    connect(socket, SIGNAL(disconnected()),socket, SLOT(deleteLater()));
    socket->disconnectFromHost();
}

bool PQCLocalHttpServer::isRunning() {

    return server->isListening();

}
