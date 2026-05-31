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

#include <pqc_filefoldermodelcache.h>
#include <pqc_helper.h>
#include <QTextStream>
#include <QFileInfo>
#include <QSize>
#include <QDir>

PQCFileFolderModelCache::PQCFileFolderModelCache() {
    cacheFiles.clear();
    cacheFolders.clear();
}

bool PQCFileFolderModelCache::loadFilesFromCache(const size_t &cacheKey, QStringList &entriesFiles) {
    if(cacheFiles.contains(cacheKey)) {
        entriesFiles = cacheFiles.value(cacheKey);
        return true;
    }
    return false;
}

bool PQCFileFolderModelCache::loadFoldersFromCache(const size_t &cacheKey, QStringList &entriesFolders) {
    if(cacheFolders.contains(cacheKey)) {
        entriesFolders = cacheFolders.value(cacheKey);
        return true;
    }
    return false;
}

void PQCFileFolderModelCache::saveFilesToCache(const size_t &cacheKey, const QStringList &entriesFiles) {
    cacheFiles.insert(cacheKey, entriesFiles);
}

void PQCFileFolderModelCache::saveFoldersToCache(const size_t &cacheKey, const QStringList &entriesFolders) {
    cacheFolders.insert(cacheKey, entriesFolders);
}

size_t PQCFileFolderModelCache::composeCacheKey(QString foldername, bool considerFiles,
                                                 bool showHidden, bool sortReversed, QString sortBy, QSet<QString> defaultSuffixFilters,
                                                 QStringList nameFilters, QStringList filenameFileters, QSet<QString> mimeTypeFilters,
                                                 QSize imageResolutionFilter, int fileSizeFilter, bool ignoreFiltersExceptDefault,
                                                 int howManyFormatsEnabled) {

    return qHashMulti(getLastModified(foldername, considerFiles, !considerFiles),
                      foldername,
                      showHidden,
                      sortReversed,
                      sortBy,
                      nameFilters,
                      defaultSuffixFilters,
                      nameFilters,
                      mimeTypeFilters,
                      imageResolutionFilter,
                      fileSizeFilter,
                      ignoreFiltersExceptDefault,
                      howManyFormatsEnabled);

}

void PQCFileFolderModelCache::resetData() {
    qDebug() << "";
    cacheFiles.clear();
    cacheFolders.clear();
}

qint64 PQCFileFolderModelCache::getLastModified(QString dirPath, bool files, bool folders) {

    QFileInfo info(dirPath);
    if(!info.exists())
        return 0;

    QDateTime latest = info.lastModified();

    QFileInfoList entries;
    if(files && folders)
        entries = info.dir().entryInfoList(QDir::NoDotAndDotDot | QDir::AllEntries);
    else if(files)
        entries = info.dir().entryInfoList(QDir::NoDotAndDotDot | QDir::Files);
    else if(folders)
        entries = info.dir().entryInfoList(QDir::NoDotAndDotDot | QDir::Dirs);
    else {
        qWarning() << "Need to specify files and/or folders!";
        return 0;
    }

    for(const QFileInfo &entry : std::as_const(entries)) {
        if(entry.lastModified() > latest)
            latest = entry.lastModified();
    }

    return latest.toSecsSinceEpoch();

}
