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
#pragma once

#include <QObject>

class PQCLocalHttpServer;
class QProcess;

class PQCScriptsChromeCast : public QObject {

    Q_OBJECT

public:
    static PQCScriptsChromeCast& get() {
        static PQCScriptsChromeCast instance;
        return instance;
    }

    PQCScriptsChromeCast(PQCScriptsChromeCast const&) = delete;
    void operator=(PQCScriptsChromeCast const&) = delete;

    QVariantList getAvailableDevices() { return m_availableDevices; }
    QString getCurDeviceName() { return m_curDeviceName; }
    bool getInDiscovery() { return m_inDiscovery; }
    bool getConnected() { return m_connected; }

    bool startDiscovery();
    bool connectToDevice(int deviceId);
    bool castImage(QString filename);
    bool disconnect();

private:
    explicit PQCScriptsChromeCast();
    ~PQCScriptsChromeCast();

    QProcess *procDiscovery;
    QProcess *procCast;
    QProcess *procDisconnect;

    QVariantList m_availableDevices;
    int m_selectedDevice;
    bool m_inDiscovery;
    bool m_connected;

    QString m_curDeviceName;

    PQCLocalHttpServer *server;
    int serverPort;
    QString localIP;

private Q_SLOTS:
    void readDiscoveryOutput();

Q_SIGNALS:
    void availableDevicesChanged();
    void inDiscoveryChanged();
    void connectedChanged();
    void curDeviceNameChanged();

};
