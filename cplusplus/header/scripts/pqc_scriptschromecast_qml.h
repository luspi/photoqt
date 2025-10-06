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
#include <scripts/pqc_scriptschromecast.h>

class PQCLocalHttpServer;
class QProcess;

/*************************************************************/
/*************************************************************/
//
//      NOTE: This singleton is a wrapper for the C++ class
//            This class here can ONLY be used from QML!
//
/*************************************************************/
/*************************************************************/

class PQCScriptsChromeCastQML : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    QML_NAMED_ELEMENT(PQCScriptsChromeCast)

public:
    explicit PQCScriptsChromeCastQML() {
        connect(&PQCScriptsChromeCast::get(), &PQCScriptsChromeCast::availableDevicesChanged, this, [=]() {
            m_availableDevices = PQCScriptsChromeCast::get().getAvailableDevices();
            Q_EMIT availableDevicesChanged();
        });
        connect(&PQCScriptsChromeCast::get(), &PQCScriptsChromeCast::curDeviceNameChanged, this, [=]() {
            m_curDeviceName = PQCScriptsChromeCast::get().getCurDeviceName();
            Q_EMIT curDeviceNameChanged();
        });
        connect(&PQCScriptsChromeCast::get(), &PQCScriptsChromeCast::inDiscoveryChanged, this, [=]() {
            m_inDiscovery = PQCScriptsChromeCast::get().getInDiscovery();
            Q_EMIT inDiscoveryChanged();
        });
        connect(&PQCScriptsChromeCast::get(), &PQCScriptsChromeCast::connectedChanged, this, [=]() {
            m_connected = PQCScriptsChromeCast::get().getConnected();
            Q_EMIT connectedChanged();
        });
    }

    Q_PROPERTY(QVariantList availableDevices MEMBER m_availableDevices NOTIFY availableDevicesChanged)
    Q_PROPERTY(QString curDeviceName MEMBER m_curDeviceName NOTIFY curDeviceNameChanged)
    Q_PROPERTY(bool inDiscovery MEMBER m_inDiscovery NOTIFY inDiscoveryChanged)
    Q_PROPERTY(bool connected MEMBER m_connected NOTIFY connectedChanged)

    Q_INVOKABLE bool startDiscovery() {
        return PQCScriptsChromeCast::get().startDiscovery();
    }
    Q_INVOKABLE bool connectToDevice(int deviceId) {
        return PQCScriptsChromeCast::get().connectToDevice(deviceId);
    }
    Q_INVOKABLE bool castImage(QString filename) {
        return PQCScriptsChromeCast::get().castImage(filename);
    }
    Q_INVOKABLE bool disconnect() {
        return PQCScriptsChromeCast::get().disconnect();
    }

private:
    QVariantList m_availableDevices;
    bool m_inDiscovery;
    bool m_connected;
    QString m_curDeviceName;

Q_SIGNALS:
    void availableDevicesChanged();
    void inDiscoveryChanged();
    void connectedChanged();
    void curDeviceNameChanged();

};
