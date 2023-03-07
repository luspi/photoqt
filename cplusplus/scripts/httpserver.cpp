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

#include "httpserver.h"
#include <QImage>
#include <QBuffer>
#include <thread>
#include <chrono>

void delayms( int millisecondsToWait );

PQHttpServer::PQHttpServer(QObject *parent) : QObject(parent) {
    server = new QTcpServer(this);
    // waiting for the web brower to make contact,this will emit signal
    connect(server, SIGNAL(newConnection()),this, SLOT(serve()));
}

PQHttpServer::~PQHttpServer() {
    if(server->isListening())
        server->close();
}

int PQHttpServer::start() {

    if(!server->listen(QHostAddress::Any,0))
        LOG << CURDATE << "PQHTTPserver::PQHTTPserver(): ERROR: server unable to listen on automatic port" << NL;

    int count = 0;
    while(!server->isListening() && count < 10) {
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
        ++count;
    }

    return server->serverPort();

}

void PQHttpServer::stop() {

    server->close();

}

void PQHttpServer::serve() {

    socket = server->nextPendingConnection();

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

bool PQHttpServer::isRunning() {

    return server->isListening();

}
