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

class PQCExtensionMethods : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    PQCExtensionMethods(QObject *parent = 0);

    // request that one of the custom cpp actions is implemented
    Q_INVOKABLE QVariant callAction(const QString &id, QVariant additional = QVariant());
    Q_INVOKABLE QVariant callActionWithImage(const QString &id, QVariant additional = QVariant());
    Q_INVOKABLE void callActionNonBlocking(const QString &id, QVariant additional = QVariant());
    Q_INVOKABLE void callActionWithImageNonBlocking(const QString &id, QVariant additional = QVariant());

    /**********************************/

    // execute an internal command
    Q_INVOKABLE void executeInternalCommand(QString cmd);

    // show a notification
    Q_INVOKABLE void showNotification(QString title, QString txt);

    // run another extension
    Q_INVOKABLE void runExtension(const QString &id);

    // image formats methods
    Q_INVOKABLE QVariantList getImageFormatsAllInformation();
    Q_INVOKABLE QStringList  getImageFormatsThatAreEnabled();
    Q_INVOKABLE QStringList  getImageFormatsMimeTypesThatAreEnabled();
    Q_INVOKABLE QVariantList getImageFormatsThatAreWriteable();

    Q_INVOKABLE int          getImageFormatId(const QString filename);
    Q_INVOKABLE QString      getImageFormatName(const int uniqueid);
    Q_INVOKABLE QStringList  getImageFormatEndings(const int uniqueid);
    Q_INVOKABLE QVariantMap  getImageFormatInfo(const int uniqueid);
    Q_INVOKABLE int          getImageFormatWriteStatus(const int uniqueid);

    /*******************************************/
    // no-op to ensure this class is setup
    Q_INVOKABLE void setup() {}

Q_SIGNALS:
    // communicate between two currently active extensions
    Q_INVOKABLE void communicateBetweenExtensions(const QString &fromId, const QString &toId, QVariant arguments);

    // resuest resetting position
    // this can be used by floating extensions to put them back into their default spot
    Q_INVOKABLE void resetGeometry(QString id);

    // Whatever result the two possible actions produces
    void replyForActionWithImage(const QString id, QVariant val);
    void replyForAction(const QString id, QVariant val);

    // When a shortcut happened while a modal extension is visible
    void receivedShortcut(QString combo);
    void receivedMessage(const QString id, QVariant val);

};
