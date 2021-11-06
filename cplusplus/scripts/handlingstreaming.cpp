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

#include "handlingstreaming.h"
#include <QtDebug>
#include <variant>

PQHandlingStreaming::PQHandlingStreaming(QObject *parent) : QObject(parent) {

    chromecastModuleName = QString("%1/photoqt_chromecast.py").arg(QDir::tempPath());

    if(!QFile::exists(chromecastModuleName) && !QFile::copy(":/chromecast.py", chromecastModuleName))
        LOG << CURDATE << "PQHandlingStreaming::PQHandlingStreaming(): Unable to make chromecast module accessible" << NL;

    watcher = nullptr;

    Py_Initialize();

}

PQHandlingStreaming::~PQHandlingStreaming() {

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

void PQHandlingStreaming::getListOfChromecastDevices() {

    if(!QFile::exists(QString("%1/photoqt_chromecast.py").arg(QDir::tempPath())))
        return;

    if(watcher != nullptr)
        delete watcher;
    watcher = new QFutureWatcher<QVariantList>(this);
    QObject::connect(watcher, &QFutureWatcher<QVariantList>::finished, this, [=]() {
        QVariantList devices = watcher->result();
        chromecastServices = devices[0].value<PQPyObject>();
        chromecastBrowser = devices[1].value<PQPyObject>();
        Q_EMIT updatedListChromecast(devices.mid(2));
    });
    watcher->setFuture(QtConcurrent::run(&PQHandlingStreaming::_getListOfChromecastDevices));
    connect(this, &PQHandlingStreaming::cancelScan, watcher, &QFutureWatcher<QVariantList>::cancel);

}

QVariantList PQHandlingStreaming::_getListOfChromecastDevices() {

    QVariantList ret;

    PyObject *sys_path = PySys_GetObject("path");
    PyList_Append(sys_path, PyUnicode_FromString(QDir::tempPath().toStdString().c_str()));

    PQPyObject pModule = PyImport_ImportModule("photoqt_chromecast");

    PQPyObject funcGetAvailable = PyObject_GetAttrString(pModule, "getAvailable");
    PQPyObject services_browser = PyObject_CallFunction(funcGetAvailable, NULL);

    PQPyObject services = PyList_GetItem(services_browser, 0);
    PQPyObject browser = PyList_GetItem(services_browser, 1);

    // the first two are pychromecast variables
    // since this is static we need to wrap it into the return type
    // as we do not have access to global class variables as easily
    ret.push_back(QVariant::fromValue(services));
    ret.push_back(QVariant::fromValue(browser));

    PQPyObject funcGetNames = PyObject_GetAttrString(pModule, "getNames");
    PQPyObject names = PyObject_CallOneArg(funcGetNames, services);

    PQPyObject funcGetIps = PyObject_GetAttrString(pModule, "getIps");
    PQPyObject ips = PyObject_CallOneArg(funcGetIps, services);

    auto len = PyList_Size(names);
    for(int i = 0; i < len; ++i) {
        ret.push_back(PyUnicode_AsUTF8(PyList_GetItem(names, i)));
        ret.push_back(PyUnicode_AsUTF8(PyList_GetItem(ips, i)));
    }

    return ret;

}

void PQHandlingStreaming::cancelScanForChromecast() {
    Q_EMIT cancelScan();
}

