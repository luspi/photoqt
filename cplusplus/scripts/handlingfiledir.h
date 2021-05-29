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

#ifndef PQHANDLINGFILEDIR_H
#define PQHANDLINGFILEDIR_H

#include <QObject>
#include <QFile>
#include <QUrl>
#include <QStorageInfo>
#include <QFileDialog>
#include <QMimeDatabase>
#include <QProcess>
#include "../settings/imageformats.h"
#include "../settings/settings.h"

#ifndef Q_OS_WIN
#include <unistd.h>
#endif

#ifdef LIBARCHIVE
#include <archive.h>
#include <archive_entry.h>
#endif

#include "../logger.h"

class PQHandlingFileDir : public QObject {

    Q_OBJECT

public:
    Q_INVOKABLE QString cleanPath(QString path);
    Q_INVOKABLE QString copyFile(QString filename);
    Q_INVOKABLE bool deleteFile(QString filename, bool permanent);
    Q_INVOKABLE bool doesItExist(QString path);
    Q_INVOKABLE QString getBaseName(QString path, bool lowerCase = true);
    Q_INVOKABLE QString getDirectory(QString path, bool lowerCase = true);
    Q_INVOKABLE QString getFileNameFromFullPath(QString path, bool onlyExtraInfo = false);
    Q_INVOKABLE QString getFilePathFromFullPath(QString path);
    Q_INVOKABLE qint64 getFileSize(QString path);
    Q_INVOKABLE QString getFileType(QString path);
    Q_INVOKABLE QDateTime getFileModified(QString path);
    Q_INVOKABLE QString getHomeDir();
    Q_INVOKABLE QString getSuffix(QString path, bool lowerCase = true);
    Q_INVOKABLE QString getTempDir();
    Q_INVOKABLE bool isDir(QString path);
    Q_INVOKABLE bool isRoot(QString path);
    Q_INVOKABLE QStringList listArchiveContent(QString path);
    Q_INVOKABLE QString moveFile(QString filename);
    Q_INVOKABLE bool renameFile(QString dir, QString oldName, QString newName);
    Q_INVOKABLE QString replaceSuffix(QString filename, QString newSuffix);

private:
    QMimeDatabase db;

};

#endif // PQHANDLINGFILEDIR_H
