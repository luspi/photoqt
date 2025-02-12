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

#ifndef PQCFILEFOLDERMODELCACHE_H
#define PQCFILEFOLDERMODELCACHE_H

#include <QObject>
#include <QHash>

class PQCFileFolderModelCache : public QObject {

    Q_OBJECT

public:
    PQCFileFolderModelCache();

    bool loadFilesFromCache(QString foldername, bool showHidden, bool sortReversed, QString sortBy,
                            QStringList defaultNameFilters, QStringList nameFilters, QStringList filenameFileters, QStringList mimeTypeFilters, QSize imageResolutionFilter, int fileSizeFilter,
                            bool ignoreFiltersExceptDefault, int numberFormatsEnabled, QStringList &entriesFiles);

    bool loadFoldersFromCache(QString foldername, bool showHidden, bool sortReversed, QString sortBy,
                              QStringList defaultNameFilters, QStringList nameFilters, QStringList filenameFileters, QStringList mimeTypeFilters, QSize imageResolutionFilter, int fileSizeFilter,
                              bool ignoreFiltersExceptDefault, QStringList &entriesFolders);

    void saveFilesToCache(QString foldername, bool showHidden, bool sortReversed, QString sortBy,
                          QStringList defaultNameFilters, QStringList nameFilters, QStringList filenameFileters, QStringList mimeTypeFilters, QSize imageResolutionFilter, int fileSizeFilter,
                          bool ignoreFiltersExceptDefault, int numberFormatsEnabled, QStringList &entriesFiles);

    void saveFoldersToCache(QString foldername, bool showHidden, bool sortReversed, QString sortBy,
                            QStringList defaultNameFilters, QStringList nameFilters, QStringList filenameFileters, QStringList mimeTypeFilters, QSize imageResolutionFilter, int fileSizeFilter,
                            bool ignoreFiltersExceptDefault, QStringList &entriesFolders);

    void resetData();

private:
    QString getUniqueCacheKey(QString foldername, bool showHidden, bool sortReversed, QString sortBy,
                              QStringList defaultNameFilters, QStringList nameFilters, QStringList filenameFilters, QStringList mimeTypeFilters, QSize imageResolutionFilter, int fileSizeFilter,
                              bool ignoreFiltersExceptDefault, int numberFormatsEnabled = 0);

    QHash<QString, QStringList> cacheFiles;
    QHash<QString, QStringList> cacheFolders;


};

#endif // PQFILEFOLDERMODELCACHE_H
