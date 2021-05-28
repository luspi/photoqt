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

#ifndef PQFILEFOLDERMODELCACHE_H
#define PQFILEFOLDERMODELCACHE_H

#include <QObject>
#include <QCryptographicHash>

#include "../logger.h"

class PQFileFolderModelCache : public QObject {

    Q_OBJECT

public:
    PQFileFolderModelCache() {
        cacheFiles.clear();
        cacheFolders.clear();
    }

    bool loadFilesFromCache(QString foldername, bool showHidden, int sortFlags, QStringList defaultNameFilters, QStringList nameFilters, QStringList filenameFileters, QStringList mimeTypeFilters, int sortField, bool sortReversed, QStringList &entriesFiles) {
        const QString key = getUniqueCacheKey(foldername, showHidden, sortFlags, defaultNameFilters, nameFilters, filenameFileters, mimeTypeFilters, sortField, sortReversed);
        if(cacheFiles.contains(key)) {
            entriesFiles = cacheFiles.value(key);
            return true;
        }
        return false;
    }

    bool loadFoldersFromCache(QString foldername, bool showHidden, int sortFlags, QStringList defaultNameFilters, QStringList nameFilters, QStringList filenameFileters, QStringList mimeTypeFilters, int sortField, bool sortReversed, QStringList &entriesFolders) {
        const QString key = getUniqueCacheKey(foldername, showHidden, sortFlags, defaultNameFilters, nameFilters, filenameFileters, mimeTypeFilters, sortField, sortReversed);
        if(cacheFiles.contains(key)) {
            entriesFolders = cacheFolders.value(key);
            return true;
        }
        return false;
    }

    void saveFilesToCache(QString foldername, bool showHidden, int sortFlags, QStringList defaultNameFilters, QStringList nameFilters, QStringList filenameFileters, QStringList mimeTypeFilters, int sortField, bool sortReversed, QStringList &entriesFiles) {
        const QString key = getUniqueCacheKey(foldername, showHidden, sortFlags, defaultNameFilters, nameFilters, filenameFileters, mimeTypeFilters, sortField, sortReversed);
        cacheFiles.insert(key, entriesFiles);
    }

    void saveFoldersToCache(QString foldername, bool showHidden, int sortFlags, QStringList defaultNameFilters, QStringList nameFilters, QStringList filenameFileters, QStringList mimeTypeFilters, int sortField, bool sortReversed, QStringList &entriesFolders) {
        const QString key = getUniqueCacheKey(foldername, showHidden, sortFlags, defaultNameFilters, nameFilters, filenameFileters, mimeTypeFilters, sortField, sortReversed);
        cacheFolders.insert(key, entriesFolders);
    }

private:
    QString getUniqueCacheKey(QString foldername, bool showHidden, int sortFlags, QStringList defaultNameFilters, QStringList nameFilters, QStringList filenameFileters, QStringList mimeTypeFilters, int sortField, bool sortReversed) {
        return QCryptographicHash::hash(QString("%1%2%3%4%5%6%7%8%9%10%11")
                                        .arg(foldername)
                                        .arg(showHidden)
                                        .arg(QFileInfo(foldername).lastModified().toMSecsSinceEpoch())
                                        .arg(sortFlags)
                                        .arg(nameFilters.join(""))
                                        .arg(defaultNameFilters.join(""))
                                        .arg(filenameFileters.join(""))
                                        .arg(mimeTypeFilters.join(""))
                                        .arg(sortField)
                                        .arg(sortReversed).toUtf8(),QCryptographicHash::Md5).toHex();
    }

    QHash<QString, QStringList> cacheFiles;
    QHash<QString, QStringList> cacheFolders;


};

#endif // PQFILEFOLDERMODELCACHE_H
