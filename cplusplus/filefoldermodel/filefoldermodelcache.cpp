#include "filefoldermodelcache.h"

PQFileFolderModelCache::PQFileFolderModelCache() {
    cacheFiles.clear();
    cacheFolders.clear();
}

bool PQFileFolderModelCache::loadFilesFromCache(QString foldername, bool showHidden, int sortFlags, QStringList defaultNameFilters, QStringList nameFilters, QStringList filenameFileters, QStringList mimeTypeFilters, QSize imageResolutionFilter, int fileSizeFilter, bool ignoreFiltersExceptDefault, int sortField, bool sortReversed, QStringList &entriesFiles) {
    const QString key = getUniqueCacheKey(foldername, showHidden, sortFlags, defaultNameFilters, nameFilters, filenameFileters, mimeTypeFilters, imageResolutionFilter, fileSizeFilter, ignoreFiltersExceptDefault, sortField, sortReversed);
    if(cacheFiles.contains(key)) {
        entriesFiles = cacheFiles.value(key);
        return true;
    }
    return false;
}

bool PQFileFolderModelCache::loadFoldersFromCache(QString foldername, bool showHidden, int sortFlags, QStringList defaultNameFilters, QStringList nameFilters, QStringList filenameFileters, QStringList mimeTypeFilters, QSize imageResolutionFilter, int fileSizeFilter, bool ignoreFiltersExceptDefault, int sortField, bool sortReversed, QStringList &entriesFolders) {
    const QString key = getUniqueCacheKey(foldername, showHidden, sortFlags, defaultNameFilters, nameFilters, filenameFileters, mimeTypeFilters, imageResolutionFilter, fileSizeFilter, ignoreFiltersExceptDefault, sortField, sortReversed);
    if(cacheFolders.contains(key)) {
        entriesFolders = cacheFolders.value(key);
        return true;
    }
    return false;
}

void PQFileFolderModelCache::saveFilesToCache(QString foldername, bool showHidden, int sortFlags, QStringList defaultNameFilters, QStringList nameFilters, QStringList filenameFileters, QStringList mimeTypeFilters, QSize imageResolutionFilter, int fileSizeFilter, bool ignoreFiltersExceptDefault, int sortField, bool sortReversed, QStringList &entriesFiles) {
    const QString key = getUniqueCacheKey(foldername, showHidden, sortFlags, defaultNameFilters, nameFilters, filenameFileters, mimeTypeFilters, imageResolutionFilter, fileSizeFilter, ignoreFiltersExceptDefault, sortField, sortReversed);
    cacheFiles.insert(key, entriesFiles);
}

void PQFileFolderModelCache::saveFoldersToCache(QString foldername, bool showHidden, int sortFlags, QStringList defaultNameFilters, QStringList nameFilters, QStringList filenameFileters, QStringList mimeTypeFilters, QSize imageResolutionFilter, int fileSizeFilter, bool ignoreFiltersExceptDefault, int sortField, bool sortReversed, QStringList &entriesFolders) {
    const QString key = getUniqueCacheKey(foldername, showHidden, sortFlags, defaultNameFilters, nameFilters, filenameFileters, mimeTypeFilters, imageResolutionFilter, fileSizeFilter, ignoreFiltersExceptDefault, sortField, sortReversed);
    cacheFolders.insert(key, entriesFolders);
}

QString PQFileFolderModelCache::getUniqueCacheKey(QString foldername, bool showHidden, int sortFlags, QStringList defaultNameFilters, QStringList nameFilters, QStringList filenameFilters, QStringList mimeTypeFilters, QSize imageResolutionFilter, int fileSizeFilter, bool ignoreFiltersExceptDefault, int sortField, bool sortReversed) {
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
                      << ignoreFiltersExceptDefault
                      << sortField
                      << sortReversed;
    return QCryptographicHash::hash(key.toUtf8(),QCryptographicHash::Md5).toHex();
}
