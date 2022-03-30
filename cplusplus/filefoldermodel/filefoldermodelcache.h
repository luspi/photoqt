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

#ifndef PQFILEFOLDERMODELCACHE_H
#define PQFILEFOLDERMODELCACHE_H

#include <QObject>
#include <QCryptographicHash>
#include <QSize>

#include "../logger.h"

class PQFileFolderModelCache : public QObject {

    Q_OBJECT

public:
    PQFileFolderModelCache() {
        cacheFiles.clear();
        cacheFolders.clear();
    }

    bool loadFilesFromCache(QString foldername, bool showHidden, int sortFlags, QStringList defaultNameFilters, QStringList nameFilters, QStringList filenameFileters, QStringList mimeTypeFilters, QSize imageResolutionFilter, int fileSizeFilter, int sortField, bool sortReversed, QStringList &entriesFiles) {
        const QString key = getUniqueCacheKey(foldername, showHidden, sortFlags, defaultNameFilters, nameFilters, filenameFileters, mimeTypeFilters, imageResolutionFilter, fileSizeFilter, sortField, sortReversed);
        if(cacheFiles.contains(key)) {
            entriesFiles = cacheFiles.value(key);
            return true;
        }
        return false;
    }

    bool loadFoldersFromCache(QString foldername, bool showHidden, int sortFlags, QStringList defaultNameFilters, QStringList nameFilters, QStringList filenameFileters, QStringList mimeTypeFilters, QSize imageResolutionFilter, int fileSizeFilter, int sortField, bool sortReversed, QStringList &entriesFolders) {
        const QString key = getUniqueCacheKey(foldername, showHidden, sortFlags, defaultNameFilters, nameFilters, filenameFileters, mimeTypeFilters, imageResolutionFilter, fileSizeFilter, sortField, sortReversed);
        if(cacheFiles.contains(key)) {
            entriesFolders = cacheFolders.value(key);
            return true;
        }
        return false;
    }

    void saveFilesToCache(QString foldername, bool showHidden, int sortFlags, QStringList defaultNameFilters, QStringList nameFilters, QStringList filenameFileters, QStringList mimeTypeFilters, QSize imageResolutionFilter, int fileSizeFilter, int sortField, bool sortReversed, QStringList &entriesFiles) {
        const QString key = getUniqueCacheKey(foldername, showHidden, sortFlags, defaultNameFilters, nameFilters, filenameFileters, mimeTypeFilters, imageResolutionFilter, fileSizeFilter, sortField, sortReversed);
        cacheFiles.insert(key, entriesFiles);
    }

    void saveFoldersToCache(QString foldername, bool showHidden, int sortFlags, QStringList defaultNameFilters, QStringList nameFilters, QStringList filenameFileters, QStringList mimeTypeFilters, QSize imageResolutionFilter, int fileSizeFilter, int sortField, bool sortReversed, QStringList &entriesFolders) {
        const QString key = getUniqueCacheKey(foldername, showHidden, sortFlags, defaultNameFilters, nameFilters, filenameFileters, mimeTypeFilters, imageResolutionFilter, fileSizeFilter, sortField, sortReversed);
        cacheFolders.insert(key, entriesFolders);
    }

private:
    QString getUniqueCacheKey(QString foldername, bool showHidden, int sortFlags, QStringList defaultNameFilters, QStringList nameFilters, QStringList filenameFilters, QStringList mimeTypeFilters, QSize imageResolutionFilter, int fileSizeFilter, int sortField, bool sortReversed) {
        QString key;
        QTextStream(&key) << foldername
                          << showHidden
                          << QFileInfo(foldername).lastModified().toMSecsSinceEpoch()
                          << sortFlags
                          << nameFilters.join("")
                          << defaultNameFilters.join("")
                          << filenameFilters.join("")
                          << mimeTypeFilters.join("")
                          << imageResolutionFilter.width() << imageResolutionFilter.height()
                          << fileSizeFilter
                          << sortField
                          << sortReversed;
        return QCryptographicHash::hash(key.toUtf8(),QCryptographicHash::Md5).toHex();
    }

    QHash<QString, QStringList> cacheFiles;
    QHash<QString, QStringList> cacheFolders;


};

#endif // PQFILEFOLDERMODELCACHE_H
