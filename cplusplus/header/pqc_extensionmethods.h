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
#include <pqc_notify_cpp.h>
#include <scripts/pqc_scriptsshortcuts.h>
#include <scripts/pqc_scriptsconfig.h>
#include <pqc_extensionshandler.h>

class PQCExtensionMethods : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    PQCExtensionMethods(QObject *parent = 0);

    // REQUEST ONE OF THE CPP ACTIONS TO BE EXECUTED
    Q_INVOKABLE void requestCallActionWithImage(const QString &id, QVariant additional = QVariant(), bool async = true);
    Q_INVOKABLE void requestCallAction(const QString &id, QVariant additional = QVariant(), bool async = true);

    /**********************************/

    // execute an internal command
    Q_INVOKABLE void executeInternalCommand(QString cmd);

    // show a notification
    Q_INVOKABLE void showNotification(QString title, QString txt);

    // check if we are operating on Windows
    Q_INVOKABLE bool amIOnWindows();

    // run another extension
    Q_INVOKABLE void runExtension(const QString &id);

Q_SIGNALS:
    Q_INVOKABLE void requestResetGeometry(QString id);

    void replyForActionWithImage(const QString id, QVariant val);
    void replyForAction(const QString id, QVariant val);

    void receivedShortcut(QString combo);
    void receivedMessage(const QString id, QVariant val);

};
