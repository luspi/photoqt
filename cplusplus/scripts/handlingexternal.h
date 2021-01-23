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

#ifndef PQHANDLINGEXTERNAL_H
#define PQHANDLINGEXTERNAL_H

#include <QObject>
#include <QFileDialog>
#include <QTextStream>
#include <QProcess>
#ifdef LIBARCHIVE
#include <archive.h>
#include <archive_entry.h>
#endif
#include "../imageprovider/imageproviderfull.h"
#include "../logger.h"

class PQHandlingExternal : public QObject {

    Q_OBJECT

public:
    Q_INVOKABLE void copyToClipboard(QString filename);
    Q_INVOKABLE void copyTextToClipboard(QString txt);
    Q_INVOKABLE void executeExternal(QString cmd, QString currentfile);
    Q_INVOKABLE bool exportConfigTo(QString path);
    Q_INVOKABLE QVariantList getContextMenuEntries();
    Q_INVOKABLE QString getIconPathFromTheme(QString binary);
    Q_INVOKABLE bool importConfigFrom(QString path);
    Q_INVOKABLE void openInDefaultFileManager(QString filename);
    Q_INVOKABLE void saveContextMenuEntries(QVariantList entries);
    Q_INVOKABLE QSize getScreenSize();

private:
    PQImageProviderFull *imageprovider;

};

#endif // PQHANDLINGEXTERNAL_H
