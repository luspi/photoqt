/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
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

#include "handlingchromecast.h"
#include <QtDebug>
#include <variant>
#include <QFutureWatcher>

PQHandlingChromecast::PQHandlingChromecast(QObject *parent) : QObject(parent) {

    server = new PQHttpServer;

    chromecastModuleName = QString("%1/photoqt_chromecast.py").arg(QDir::tempPath());

    if(QFile::exists(chromecastModuleName))
        QFile::remove(chromecastModuleName);

    if(!QFile::copy(":/chromecast.py", chromecastModuleName))
        LOG << CURDATE << "PQHandlingStreaming::PQHandlingStreaming(): Unable to make chromecast module accessible" << NL;

    watcher = nullptr;

    Py_Initialize();

}

PQHandlingChromecast::~PQHandlingChromecast() {

    delete server;

    if(watcher != nullptr) {
        if(watcher->isRunning()) {
            watcher->cancel();
            LOG << "Waiting for Chromecast connection to terminate..." << NL;
            watcher->waitForFinished();
        }
        delete watcher;
    }
    Py_FinalizeEx();

    if(!QFile::remove(chromecastModuleName))
        LOG << CURDATE << "PQHandlingStreaming::~PQHandlingStreaming: Unable to remove chromecast module file" << NL;

}

void PQHandlingChromecast::getListOfChromecastDevices() {

    if(!QFile::exists(QString("%1/photoqt_chromecast.py").arg(QDir::tempPath())))
        return;

    if(watcher != nullptr)
        delete watcher;
    watcher = new QFutureWatcher<QVariantList>(this);
    QObject::connect(watcher, &QFutureWatcher<QVariantList>::finished, this, [=]() {
        QVariantList devices = watcher->result();
        if(devices.length() > 0) {
            chromecastServices = devices[0].value<PQPyObject>();
            Q_EMIT updatedListChromecast(devices.mid(1));
        } else
            Q_EMIT updatedListChromecast(QVariantList());
    });
    watcher->setFuture(QtConcurrent::run(&PQHandlingChromecast::_getListOfChromecastDevices));
    connect(this, &PQHandlingChromecast::cancelScan, watcher, &QFutureWatcher<QVariantList>::cancel);

}

QVariantList PQHandlingChromecast::_getListOfChromecastDevices() {

    QVariantList ret;

    PyObject *sys_path = PySys_GetObject("path");
    if(PyList_Append(sys_path, PyUnicode_FromString(QDir::tempPath().toStdString().c_str())) == -1) {
        LOG << CURDATE << "PQHandlingChromecast::_getListOfChromecastDevices(): Python error: Unable to append temp path to sys path" << NL;
        return ret;
    }

    PQPyObject pModule = PyImport_ImportModule("photoqt_chromecast");
    if(PQPyObject::catchEx("PQHandlingChromecast::_getListOfChromecastDevices()")) return ret;

    PQPyObject funcGetAvailable = PyObject_GetAttrString(pModule, "getAvailable");
    if(PQPyObject::catchEx("PQHandlingChromecast::_getListOfChromecastDevices()")) return ret;

    PQPyObject services_count = PyObject_CallFunction(funcGetAvailable, NULL);
    if(PQPyObject::catchEx("PQHandlingChromecast::_getListOfChromecastDevices()")) return ret;

    PQPyObject count = PyList_GetItem(services_count, 0);
    if(PQPyObject::catchEx("PQHandlingChromecast::_getListOfChromecastDevices()")) return ret;

    PQPyObject services = PyList_GetItem(services_count, 1);
    if(PQPyObject::catchEx("PQHandlingChromecast::_getListOfChromecastDevices()")) return ret;

    int c = PyLong_AsSize_t(count);
    if(c == 0)
        return ret;

    // the first one is a pychromecast variable
    // since this is static we need to wrap it into the return type
    // as we do not have access to global class variables as easily
    ret.push_back(QVariant::fromValue(services));

    PQPyObject funcGetNames = PyObject_GetAttrString(pModule, "getNamesIps");
    if(PQPyObject::catchEx("PQHandlingChromecast::_getListOfChromecastDevices()")) return ret;

    PQPyObject namesips = PyObject_CallOneArg(funcGetNames, services);
    if(PQPyObject::catchEx("PQHandlingChromecast::_getListOfChromecastDevices()")) return ret;

    PQPyObject names = PyList_GetItem(namesips, 0);
    if(PQPyObject::catchEx("PQHandlingChromecast::_getListOfChromecastDevices()")) return ret;

    PQPyObject ips = PyList_GetItem(namesips, 1);
    if(PQPyObject::catchEx("PQHandlingChromecast::_getListOfChromecastDevices()")) return ret;

    auto len = PyList_Size(names);
    for(int i = 0; i < len; ++i) {
        ret.push_back(PyUnicode_AsUTF8(PyList_GetItem(names, i)));
        ret.push_back(PyUnicode_AsUTF8(PyList_GetItem(ips, i)));
        if(PQPyObject::catchEx("PQHandlingChromecast::_getListOfChromecastDevices()")) return ret;
    }

    return ret;

}

void PQHandlingChromecast::cancelScanForChromecast() {
    Q_EMIT cancelScan();
}

bool PQHandlingChromecast::connectToDevice(QString friendlyname) {

    PyObject *sys_path = PySys_GetObject("path");
    if(PyList_Append(sys_path, PyUnicode_FromString(QDir::tempPath().toStdString().c_str())) == -1) {
        LOG << CURDATE << "PQHandlingChromecast::connectToDevice(): Python error: Unable to append temp path to sys path" << NL;
        return false;
    }

    PQPyObject pModule = PyImport_ImportModule("photoqt_chromecast");
    if(PQPyObject::catchEx("PQHandlingChromecast::connectToDevice()")) return false;

    PQPyObject funcConnectTo = PyObject_GetAttrString(pModule, "connectTo");
    if(PQPyObject::catchEx("PQHandlingChromecast::connectToDevice()")) return false;

    PQPyObject browser_mc = PyObject_CallOneArg(funcConnectTo, PyUnicode_FromString(friendlyname.toStdString().c_str()));
    if(PQPyObject::catchEx("PQHandlingChromecast::connectToDevice()")) return false;

    chromecastBrowser = PyList_GetItem(browser_mc, 0);
    if(PQPyObject::catchEx("PQHandlingChromecast::connectToDevice()")) return false;

    chromecastMediaController = PyList_GetItem(browser_mc, 1);
    if(PQPyObject::catchEx("PQHandlingChromecast::connectToDevice()")) return false;

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

    if(localIP == "")
        return false;

    return true;

}

bool PQHandlingChromecast::disconnectFromDevice() {

    return true;

}

void PQHandlingChromecast::streamOnDevice(QString src) {

    // Make sure image provider exists
    if(imageprovider == nullptr)
         imageprovider = new PQImageProviderFull;

    // request image
    QImage img = imageprovider->requestImage(src, new QSize, QSize(1920,1280));
    if(!img.save(QString("%1/photoqtchromecast.jpg").arg(QDir::tempPath()), nullptr, 50))
        LOG << "FAILED TO SAVE IMAGE!" << NL;

    PyObject *sys_path = PySys_GetObject("path");
    if(PyList_Append(sys_path, PyUnicode_FromString(QDir::tempPath().toStdString().c_str())) == -1) {
        LOG << CURDATE << "PQHandlingChromecast::streamOnDevice(): Python error: Unable to append temp path to sys path" << NL;
        return;
    }

    PQPyObject pModule = PyImport_ImportModule("photoqt_chromecast");
    if(PQPyObject::catchEx("PQHandlingChromecast::streamOnDevice()")) return;

    PQPyObject funcStreamOn = PyObject_GetAttrString(pModule, "streamOnDevice");
    if(PQPyObject::catchEx("PQHandlingChromecast::streamOnDevice()")) return;

    PQPyObject args = PyTuple_Pack(3, PyUnicode_FromString(localIP.toStdString().c_str()), PyLong_FromLong(serverPort), chromecastMediaController.get());
    if(PQPyObject::catchEx("PQHandlingChromecast::streamOnDevice()")) return;

    PQPyObject keywords = PyDict_New();
    if(PQPyObject::catchEx("PQHandlingChromecast::streamOnDevice()")) return;

    PQPyObject browser_mc = PyObject_Call(funcStreamOn, args, keywords);
    if(PQPyObject::catchEx("PQHandlingChromecast::streamOnDevice()")) return;

}
