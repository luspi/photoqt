/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

#ifndef PQHANDLINGFILEDIALOG_H
#define PQHANDLINGFILEDIALOG_H

#include <QObject>
#include <QXmlStreamWriter>
#include <QStorageInfo>
#include <QUrl>
#include <QFutureWatcher>
#include <QJSValue>
#include <QJSEngine>
#include <QtConcurrent/QtConcurrent>
#include <QDomDocument>
#ifdef PUGIXML
#include <pugixml.hpp>
#endif
#include <QMimeDatabase>
#include <QKeySequence>

#include "../logger.h"
#include "../settings/imageformats.h"
#include "../settings/settings.h"

class PQHandlingFileDialog : public QObject {

    Q_OBJECT

public:
    Q_INVOKABLE void addNewUserPlacesEntry(QString path, int pos);
    Q_INVOKABLE QStringList getFoldersIn(QString path);
    Q_INVOKABLE QString getLastLocation();
    unsigned int getNumberOfFilesInFolder(QString path);
    Q_INVOKABLE void getNumberOfFilesInFolder(QString path, const QJSValue &callback);
    Q_INVOKABLE QVariantList getStorageInfo();
    QString getNewUniqueId();
    Q_INVOKABLE QVariantList getUserPlaces();
    Q_INVOKABLE void hideUserPlacesEntry(QString id, bool hidden);
    Q_INVOKABLE void moveUserPlacesEntry(QString id, bool moveDown, int howmany);
    Q_INVOKABLE void removeUserPlacesEntry(QString id);
    Q_INVOKABLE void setLastLocation(QString path);
    Q_INVOKABLE QString createTooltipFilename(QString fname);

private:
    QHash<QString,int> cacheNumberOfFilesInFolder;

};

#endif // PQHANDLINGFILEDIALOG_H
