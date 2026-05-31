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
#include <QHash>

class PQCFileFolderModelCache : public QObject {

    Q_OBJECT

public:
    PQCFileFolderModelCache();

    bool loadFilesFromCache(const size_t &cacheKey, QStringList &entriesFiles);
    bool loadFoldersFromCache(const size_t &cacheKey, QStringList &entriesFolders);
    void saveFilesToCache(const size_t &cacheKey, const QStringList &entriesFiles);
    void saveFoldersToCache(const size_t &cacheKey, const QStringList &entriesFolders);

    void resetData();

    // the howManyFormatsEnabled parameter is only required for caching files
    size_t composeCacheKey(QString foldername, bool considerFiles,
                           bool showHidden, bool sortReversed, QString sortBy, QSet<QString> defaultSuffixFilters, QStringList nameFilters,
                           QStringList filenameFileters, QSet<QString> mimeTypeFilters, QSize imageResolutionFilter, int fileSizeFilter,
                           bool ignoreFiltersExceptDefault, int howManyFormatsEnabled = 0);

private:

    qint64 getLastModified(QString dirPath, bool files, bool folders);

    QHash<size_t, QStringList> cacheFiles;
    QHash<size_t, QStringList> cacheFolders;


};
