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

#ifndef PQCSCRIPTSCHROMECAST_H
#define PQCSCRIPTSCHROMECAST_H

#include <QObject>
#include <QtQmlIntegration>

class PQCLocalHttpServer;
class QProcess;

class PQCScriptsChromeCast : public QObject {

    Q_OBJECT
    QML_SINGLETON

public:
    static PQCScriptsChromeCast& get() {
        static PQCScriptsChromeCast instance;
        return instance;
    }
    ~PQCScriptsChromeCast();

    PQCScriptsChromeCast(PQCScriptsChromeCast const&)     = delete;
    void operator=(PQCScriptsChromeCast const&) = delete;

    Q_PROPERTY(QVariantList availableDevices READ getAvailableDevices WRITE setAvailableDevices NOTIFY availableDevicesChanged)
    void setAvailableDevices(QVariantList val);
    QVariantList getAvailableDevices();

    Q_PROPERTY(QString curDeviceName READ getCurDeviceName WRITE setCurDeviceName NOTIFY curDeviceNameChanged)
    void setCurDeviceName(QString val);
    QString getCurDeviceName();

    Q_PROPERTY(bool inDiscovery READ getInDiscovery WRITE setInDiscovery NOTIFY inDiscoveryChanged)
    int getInDiscovery();
    void setInDiscovery(bool val);

    Q_PROPERTY(bool connected READ getConnected WRITE setConnected NOTIFY connectedChanged)
    int getConnected();
    void setConnected(bool val);

    Q_INVOKABLE bool startDiscovery();
    Q_INVOKABLE bool connectToDevice(int deviceId);
    Q_INVOKABLE bool castImage(QString filename);
    Q_INVOKABLE bool disconnect();

private:
    PQCScriptsChromeCast();

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
    void selectedDeviceChanged();
    void inDiscoveryChanged();
    void connectedChanged();
    void curDeviceNameChanged();

};

#endif
