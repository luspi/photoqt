/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

#ifndef PQHANDLINGEXTERNAL_H
#define PQHANDLINGEXTERNAL_H

#include <QObject>
#include <QFileDialog>
#include <QTextStream>
#include <QProcess>
#include <QtSql>
#ifdef LIBARCHIVE
#include <archive.h>
#include <archive_entry.h>
#endif
#include "../imageprovider/imageproviderfull.h"
#include "../logger.h"
#include "../startup/startup.h"

class PQHandlingExternal : public QObject {

    Q_OBJECT

public:
    PQHandlingExternal(QObject *parent = 0);
    Q_INVOKABLE void copyToClipboard(QString filename);
    Q_INVOKABLE void copyTextToClipboard(QString txt, bool removeHTML= false);
    Q_INVOKABLE void copyFilesToClipboard(QStringList filename);
    Q_INVOKABLE void executeExternal(QString exe, QString args, QString currentfile);
    Q_INVOKABLE static bool exportConfigTo(QString path);
    Q_INVOKABLE QString findDropBoxFolder();
    Q_INVOKABLE QString findNextcloudFolder();
    Q_INVOKABLE QString findOwnCloudFolder();
    Q_INVOKABLE QVariantList getContextMenuEntries();
    Q_INVOKABLE QStringList getListOfFilesInClipboard();
    Q_INVOKABLE void replaceContextMenuEntriesWithAvailable();
    Q_INVOKABLE QString getIconPathFromTheme(QString binary);
    Q_INVOKABLE static bool importConfigFrom(QString path);
    Q_INVOKABLE void openInDefaultFileManager(QString filename);
    Q_INVOKABLE void saveContextMenuEntries(QVariantList entries);
    Q_INVOKABLE QSize getScreenSize();
    Q_INVOKABLE QString loadImageAndConvertToBase64(QString filename);
    Q_INVOKABLE bool areFilesInClipboard();

    bool checkIfBinaryExists(QString exec);

private:
    PQImageProviderFull *imageprovider;
    QClipboard *clipboard;

Q_SIGNALS:
    void changedClipboardData();

};

#endif // PQHANDLINGEXTERNAL_H
