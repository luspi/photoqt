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

#ifndef PQHANDLINGCHROMECAST_H
#define PQHANDLINGCHROMECAST_H

#include <QObject>
#ifdef CHROMECAST
#include <QJSValue>
#include <QJSEngine>
#include <QtConcurrent/QtConcurrent>
#include "httpserver.h"
#include "../../python/pqpy.h"
#include "../logger.h"
#include "../imageprovider/imageproviderfull.h"
#endif

class PQHandlingChromecast : public QObject {

    Q_OBJECT

public:
    PQHandlingChromecast(QObject *parent = nullptr);
    ~PQHandlingChromecast();

    Q_INVOKABLE void getListOfChromecastDevices();
    static QVariantList _getListOfChromecastDevices();

    Q_INVOKABLE bool connectToDevice(QString friendlyname);
    Q_INVOKABLE bool disconnectFromDevice();
    Q_INVOKABLE void streamOnDevice(QString src);

    Q_INVOKABLE void cancelScanForChromecast();

#ifdef CHROMECAST
    QFutureWatcher<QVariantList> *watcher;
#endif

Q_SIGNALS:
    void updatedListChromecast(QVariantList devices);
    void cancelScan();

private:
#ifdef CHROMECAST
    int triedReconnectingAfterDisconnect;
    QString chromecastModuleName;
    QString localIP;

    PQPyObject *chromecastCast;
    PQPyObject *chromecastServices;
    PQPyObject *chromecastBrowser;
    PQPyObject *chromecastMediaController;

    PQImageProviderFull *imageprovider;

    PQHttpServer *server;
    int serverPort;
    QString currentFriendlyName;
#endif

};


#endif // PQHANDLINGCHROMECAST_H
