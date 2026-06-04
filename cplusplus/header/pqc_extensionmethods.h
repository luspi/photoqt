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
#include <QQmlEngine>
#include <QRect>

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

    // open settings for extension
    Q_INVOKABLE void showSettingsFor(const QString &id);

    /**********************************/
    // some general requests

    // get all enabled formats
    Q_INVOKABLE const QSet<QString> getEnabledFormats();
    // get all enabled suffixes
    Q_INVOKABLE const QSet<QString> getEnabledSuffixes();
    // get all enabled mimetypes
    Q_INVOKABLE const QSet<QString> getEnabledMimetypes();

    // get all writable formats
    Q_INVOKABLE const QSet<QString> getWritableFormats();
    // get all writable suffixes
    Q_INVOKABLE const QSet<QString> getWritableSuffixes();

    // get all suffixes for any given format
    Q_INVOKABLE const QSet<QString> getSuffixesForFormat(const QString format);

    /**********/

    // get the format of any given file (if known)
    Q_INVOKABLE const QString getFormatOfFile(const QString file);

    // compose the image provider string to take advantage of PhotoQt's image engine for showing images/thumbs
    Q_INVOKABLE QString path2ImageProvider(QString path, bool thumb = false);

    // get the size of any image (if known)
    Q_INVOKABLE QSize getSizeOfImage(const QString file);

    // take a source image and write it to a target with optional clipping/cropping/resizing
    Q_INVOKABLE bool writeImage(const QString sourceFile, const QString targetFile, const QRect sourceRect = QRect(), const QSize targetSize = QSize());

    /**********/

    // prompt user to select an existing directory using a file dialog
    Q_INVOKABLE QString getExistingDirectory(const QString caption, const QString dir);

    // prompt user to select an existing file using a file dialog
    Q_INVOKABLE QString getOpenFileName(const QString caption = QString(), const QString dir = QString(), const QString filter = QString());

    // prompt user to select existing files using a file dialog
    Q_INVOKABLE QStringList getOpenFileNames(const QString caption = QString(), const QString dir = QString(), const QString filter = QString());

    // prompt user to select an existing or new file using a file dialog
    Q_INVOKABLE QString getSaveFileName(const QString caption = QString(), const QString dir = QString(), const QString filter = QString());

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
