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

#include <scripts/pqc_scriptschromecast.h>
#include <pqc_localhttpserver.h>
#include <pqc_imagehandler.h>
#include <pqc_settingscpp.h>
#include <pqc_filefoldermodelCPP.h>

#include <QVariantList>
#include <QFile>
#include <QDir>
#include <QNetworkInterface>
#include <QProcess>
#include <QImage>
#include <QSize>
#include <QPainter>

PQCScriptsChromeCast::PQCScriptsChromeCast() {

    m_connected = false;
    m_curDeviceName = "";

    server = new PQCLocalHttpServer;

    procDiscovery = new QProcess;
    procCast = new QProcess;
    procDisconnect = new QProcess;

    connect(procDiscovery, &QProcess::readyReadStandardOutput, this, &PQCScriptsChromeCast::readDiscoveryOutput);

}

PQCScriptsChromeCast::~PQCScriptsChromeCast() {

    disconnect();

    QFile::remove(QDir::tempPath() % "/chromecast_discovery.py");
    QFile::remove(QDir::tempPath() % "/chromecast_cast.py");
    QFile::remove(QDir::tempPath() % "/chromecast_disconnect.py");

    server->deleteLater();
    procDiscovery->deleteLater();
    procCast->deleteLater();
    procDisconnect->deleteLater();

}

/************************************************************/

void PQCScriptsChromeCast::readDiscoveryOutput() {

    qDebug() << "";

    QString str = procDiscovery->readAll();

    m_availableDevices.clear();

    if(str.trimmed() != "x") {

        QStringList p = str.split("\n");
        for(int i = 0; i < p.length()/2; ++i) {
            QVariantList l;
            l.push_back(p[2*i].trimmed());
            l.push_back(p[2*i+1].trimmed());
            m_availableDevices.push_back(l);
        }

    }

    m_inDiscovery = false;
    Q_EMIT inDiscoveryChanged();
    Q_EMIT availableDevicesChanged();

}

bool PQCScriptsChromeCast::startDiscovery() {

    qDebug() << "";

    m_inDiscovery = true;
    Q_EMIT inDiscoveryChanged();

    const QString tmpPath = QDir::tempPath() % "/chromecast_discovery.py";

    QFile::remove(tmpPath);
    if(!QFile::copy(":/chromecast_discovery.py", tmpPath)) {
        qWarning() << "ERROR preparing discovery python script, chromecast not available";
        m_inDiscovery = false;
        Q_EMIT inDiscoveryChanged();
        return false;
    }

    procDiscovery->start("python", {tmpPath});

    return true;

}

bool PQCScriptsChromeCast::connectToDevice(int index) {

    qDebug() << "args: index =" << index;

    if(index >= m_availableDevices.length())
        return false;

    m_selectedDevice = index;

    const QVariantList lst = m_availableDevices[m_selectedDevice].toList();
    m_curDeviceName = lst[0].toString();
    Q_EMIT curDeviceNameChanged();

    m_connected = true;
    Q_EMIT connectedChanged();

    if(PQCFileFolderModelCPP::get().getCountMainView() > 0 && PQCFileFolderModelCPP::get().getCurrentIndex() > -1)
        return castImage(PQCFileFolderModelCPP::get().getCurrentFile());
    return castImage("");


}

bool PQCScriptsChromeCast::castImage(QString filename) {

    qDebug() << "args: filename =" << filename;

    if(m_curDeviceName.isEmpty()) {
        qDebug() << "Not connected to chromecast device.";
        return false;
    }

    procCast->kill();

    if(!server->isRunning()) {

        serverPort = server->start();

        // find local ip address
        localIP = "";
        const auto addresses = QNetworkInterface::allAddresses();
        for(const auto &entry : addresses) {
            if(!entry.isLoopback() &&  entry.protocol() == QAbstractSocket::IPv4Protocol) {
                const QString ip = entry.toString();
                if(ip != "127.0.0.1" && ip != "localhost") {
                    localIP = ip;
                    break;
                }
            }
        }

    }


    // request image

    // PhotoQt logo
    if(filename.isEmpty()) {

        QImage img(":/other/logo_chromecast.jpg");
        if(!img.save(QDir::tempPath() % "/photoqtchromecast.jpg", nullptr, 100)) {
            qWarning() << "Failed to save default image.";
            return false;
        }

    } else {

        QSize orig;
        QString err = "";
        QImage img = PQCImageHandler::get().getImage(filename, QSize(1920,1080), orig, err);

        if(img.height() > 1080)
            img = img.scaledToHeight(1080);

        // if image is smaller than display and is not to be fit to window size
        if(!PQCSettingsCPP::get().getImageviewFitInWindow() && (img.width() < 1920 || img.height() < 1080)) {
            QImage ret(1920, 1080, QImage::Format_ARGB32);
            ret.fill(Qt::black);
            QPainter painter(&ret);
            painter.drawImage((1920-img.width())/2, (1080-img.height())/2, img);
            painter.end();
            if(!ret.save(QDir::tempPath() % "/photoqtchromecast.jpg", nullptr, 100)) {
                qWarning() << "Failed to save image:" << filename;
                return false;
            }
        } else {
            if(!img.save(QDir::tempPath() % "/photoqtchromecast.jpg", nullptr, 100)) {
                qWarning() << "Failed to save image:" << filename;
                return false;
            }
        }
    }

    const QString pyPath = QString("%1/chromecast_cast.py").arg(QDir::tempPath());
    QFile::remove(pyPath);
    if(!QFile::copy(":/chromecast_cast.py", pyPath)) {
        qWarning() << "ERROR preparing cast python script, chromecast not available";
        return false;
    }

    procCast->start("python", {pyPath, m_curDeviceName, localIP, QString::number(serverPort)});

    return true;

}

bool PQCScriptsChromeCast::disconnect() {

    qDebug() << "";

    if(!m_connected)
        return true;

    const QString pyPath = QDir::tempPath() % "/chromecast_disconnect.py";
    QFile::remove(pyPath);
    if(!QFile::copy(":/chromecast_disconnect.py", pyPath)) {
        qWarning() << "ERROR preparing disconnect python script, chromecast won't properly shut down";
        return false;
    }

    server->stop();

    procDisconnect->start("python", {pyPath, m_curDeviceName, localIP, QString::number(serverPort)});

    m_curDeviceName = "";
    Q_EMIT curDeviceNameChanged();

    m_connected = false;
    Q_EMIT connectedChanged();

    return true;

}
