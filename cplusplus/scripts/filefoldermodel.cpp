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

#include "filefoldermodel.h"
#include <chrono>

PQFileFolderModel::PQFileFolderModel(QObject *parent) : QAbstractListModel(parent) {

    loadDelay = new QTimer;
    loadDelay->setInterval(10);
    loadDelay->setSingleShot(true);
    connect(loadDelay, &QTimer::timeout, this, &PQFileFolderModel::loadDataSlot);

    // this is needed so that the delete in loadData() is valid. Checking there for nullptr has led to crashes in the past
    watcher = new QFileSystemWatcher;

    loadDelay->start();

}

PQFileFolderModel::~PQFileFolderModel() {
    delete loadDelay;
    delete watcher;
    for(int i = 0; i < entries.length(); ++i)
        delete entries[i];
}

void PQFileFolderModel::loadDataSlot() {
    loadData(false, QStringList(), QStringList());
}

void PQFileFolderModel::loadData(bool setCopyOfData, QStringList allImages, QStringList allDirs) {

    DBG << CURDATE << "PQFileFolderModel::loadData()" << NL;

    beginRemoveRows(QModelIndex(), 0, rowCount());

    for(int i = 0; i < entries.length(); ++i)
        delete entries[i];
    entries.clear();
    allImageFilesInOrder.clear();

    endRemoveRows();

    if(m_folder.trimmed().isEmpty() || !QDir(m_folder).exists())
        return;

    delete watcher;
    watcher = new QFileSystemWatcher;
    watcher->addPath(m_folder);
    connect(watcher, &QFileSystemWatcher::directoryChanged, this, &PQFileFolderModel::loadDataSlot);

    if(!m_ignoreDirs) {

        // Folders
        QFileInfoList alldirs;
        if(setCopyOfData) {
            foreach(QString d, allDirs)
                alldirs.push_back(QFileInfo(d));
        } else
            alldirs = getAllFoldersInFolder();

        // Files
        if(setCopyOfData) {
            allImageFilesInOrder.clear();
            foreach(QString i, allImages)
                allImageFilesInOrder.push_back(QFileInfo(i));
        } else
            allImageFilesInOrder = getAllImagesInFolder();

        setCount(alldirs.length()+allImageFilesInOrder.length());

        if(getCount() == 0)
            return;

        entries.reserve(m_count);

        beginInsertRows(QModelIndex(), rowCount(), rowCount()+m_count-1);

        for(int i = 0; i < alldirs.length(); ++i) {

            PQFileFolderEntry *entry = new PQFileFolderEntry;
            entry->fileName = alldirs.at(i).fileName();
            entry->filePath = alldirs.at(i).absoluteFilePath();
            entry->fileSize = alldirs.at(i).size();
            entry->fileModified = alldirs.at(i).lastModified();
            entry->fileIsDir = alldirs.at(i).isDir();

            entries.push_back(entry);

        }

    } else {

        // Files
        allImageFilesInOrder = getAllImagesInFolder();

        setCount(allImageFilesInOrder.length());

        if(getCount() == 0)
            return;

        entries.reserve(getCount());

        beginInsertRows(QModelIndex(), rowCount(), rowCount()+getCount()-1);

    }

    for(int i = 0; i < allImageFilesInOrder.length(); ++i) {

        PQFileFolderEntry *entry = new PQFileFolderEntry;
        entry->fileName = allImageFilesInOrder.at(i).fileName();
        entry->filePath = allImageFilesInOrder.at(i).absoluteFilePath();
        entry->fileSize = allImageFilesInOrder.at(i).size();
        entry->fileModified = allImageFilesInOrder.at(i).lastModified();
        entry->fileIsDir = allImageFilesInOrder.at(i).isDir();

        entries.push_back(entry);

    }

    endInsertRows();

    emit dataChanged(createIndex(0, 0, entries.first()), createIndex(entries.length()-1, 0, entries.last()));
    emit newDataLoaded();

}

int PQFileFolderModel::setFolderAndImages(QString path, QStringList allImages) {

    DBG << CURDATE << "PQFileFolderModel::setFolderAndData()" << NL;

    setFolder(QFileInfo(path).absolutePath());

    loadData(true, allImages, QStringList());

    return allImages.indexOf(path);

}

QFileInfoList PQFileFolderModel::getAllFoldersInFolder() {

    DBG << CURDATE << "PQFileFolderModel::getAllFoldersInFolder()" << NL;

    QDir dir;
    dir.setPath(m_folder);

    if(!dir.exists()) {
        LOG << CURDATE << "ERROR: Folder location does not exist: " << m_folder.toStdString() << NL;
        return QFileInfoList();
    }

    if(m_showHidden)
        dir.setFilter(QDir::Dirs|QDir::NoDotAndDotDot|QDir::Hidden);
    else
        dir.setFilter(QDir::Dirs|QDir::NoDotAndDotDot);

    if(m_sortField != SortBy::NaturalName) {

        QDir::SortFlags flags = QDir::IgnoreCase;
        if(m_sortReversed)
            flags |= QDir::Reversed;
        if(m_sortField == SortBy::Name)
            flags |= QDir::Name;
        else if(m_sortField == SortBy::Time)
            flags |= QDir::Time;
        else if(m_sortField == SortBy::Size)
            flags |= QDir::Size;
        else if(m_sortField == SortBy::Type)
            flags |= QDir::Type;

        dir.setSorting(flags);

    }

    QFileInfoList alldirs = dir.entryInfoList();

    if(m_sortField == SortBy::NaturalName) {
        QCollator collator;
        collator.setNumericMode(true);
        if(m_sortReversed)
            std::sort(alldirs.begin(), alldirs.end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) { return collator.compare(file2.fileName(), file1.fileName()) < 0; });
        else
            std::sort(alldirs.begin(), alldirs.end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) { return collator.compare(file1.fileName(), file2.fileName()) < 0; });
    }

    return alldirs;

}

QFileInfoList PQFileFolderModel::getAllImagesInFolder() {

    DBG << CURDATE << "PQFileFolderModel::getAllImagesInFolder()" << NL;

    QDir dir;

    QFileInfo info(m_folder);
    if(info.isDir())
        dir.setPath(m_folder);
    else
        dir.setPath(info.absolutePath());

    if(!dir.exists()) {
        LOG << CURDATE << "ERROR: Folder location does not exist: " << m_folder.toStdString() << NL;
        return QFileInfoList();
    }

    if(m_showHidden)
        dir.setFilter(QDir::Dirs|QDir::NoDotAndDotDot|QDir::Hidden);
    else
        dir.setFilter(QDir::Dirs|QDir::NoDotAndDotDot);

    dir.setFilter(QDir::Files|QDir::NoDotAndDotDot);

    if(m_sortField != SortBy::NaturalName) {

        QDir::SortFlags flags = QDir::IgnoreCase;
        if(m_sortReversed)
            flags |= QDir::Reversed;
        if(m_sortField == SortBy::Name)
            flags |= QDir::Name;
        else if(m_sortField == SortBy::Time)
            flags |= QDir::Time;
        else if(m_sortField == SortBy::Size)
            flags |= QDir::Size;
        else if(m_sortField == SortBy::Type)
            flags |= QDir::Type;

        dir.setSorting(flags);

    }

    QMimeDatabase db;

    QFileInfoList allfiles;
    if(m_nameFilters.size() == 0 && m_mimeTypeFilters.size() == 0)
        allfiles = dir.entryInfoList();
    else {
        QDirIterator iter(dir);
        while(iter.hasNext()) {
            iter.next();
            const QFileInfo f = iter.fileInfo();
            if(m_nameFilters.size() == 0 || m_nameFilters.contains(f.suffix().toLower())) {
                if(m_filenameFilters.length() == 0)
                    allfiles << f;
                else {
                    foreach(QString fil, m_filenameFilters)
                        if(f.baseName().contains(fil)) {
                            allfiles << f;
                            break;
                        }
                }
            }
            // if not the ending, then check the mime type
            else if(m_mimeTypeFilters.contains(db.mimeTypeForFile(f.absoluteFilePath()).name()))
                allfiles << f;
        }
    }


    if(m_sortField == SortBy::NaturalName) {
        QCollator collator;
        collator.setNumericMode(true);
        if(m_sortReversed)
            std::sort(allfiles.begin(), allfiles.end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) { return collator.compare(file2.fileName(), file1.fileName()) < 0; });
        else
            std::sort(allfiles.begin(), allfiles.end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) { return collator.compare(file1.fileName(), file2.fileName()) < 0; });
    }

    return allfiles;

}

QStringList PQFileFolderModel::getAllImagesInSubFolders(QString path, bool showHidden, QStringList nameFilters, QStringList mimeTypeFilters, SortBy sortfield, bool sortReversed) {

    DBG << CURDATE << "PQFileFolderModel::getAllImagesInSubFolders()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL
        << CURDATE << "** showHidden = " << showHidden << NL
        << CURDATE << "** nameFilters = " << nameFilters.join(",").toStdString() << NL
        << CURDATE << "** sortfield = " << sortfield << NL
        << CURDATE << "** sortReversed = " << sortReversed << NL;

    QDir dir = QFileInfo(path).absoluteDir();

    if(showHidden)
        dir.setFilter(QDir::Dirs|QDir::NoDotAndDotDot|QDir::Hidden);
    else
        dir.setFilter(QDir::Dirs|QDir::NoDotAndDotDot);

    dir.setFilter(QDir::Files|QDir::NoDotAndDotDot);

    if(sortfield != SortBy::NaturalName) {

        QDir::SortFlags flags = QDir::IgnoreCase;
        if(sortReversed)
            flags |= QDir::Reversed;
        if(sortfield == SortBy::Name)
            flags |= QDir::Name;
        else if(sortfield == SortBy::Time)
            flags |= QDir::Time;
        else if(sortfield == SortBy::Size)
            flags |= QDir::Size;
        else if(sortfield == SortBy::Type)
            flags |= QDir::Type;

        dir.setSorting(flags);

    }

    QStringList allfiles;

    QDirIterator iter(dir, QDirIterator::Subdirectories);
    if(nameFilters.size() == 0 && mimeTypeFilters.size() == 0) {
        while(iter.hasNext()) {
            QString item = iter.next();
            if(QFileInfo(item).absolutePath() == dir.absolutePath())
                continue;
            allfiles << item;
        }
    } else {
        QMimeDatabase db;
        while(iter.hasNext()) {
            QString item = iter.next();
            if(QFileInfo(item).absolutePath() == dir.absolutePath())
                continue;
            if(nameFilters.size() == 0 || nameFilters.contains(QFileInfo(item).suffix().toLower()))
                allfiles << item;
            else if(mimeTypeFilters.contains(db.mimeTypeForFile(QFileInfo(item)).name()))
                allfiles << item;
        }
    }

    if(sortfield == SortBy::NaturalName) {
        QCollator collator;
        collator.setNumericMode(true);
        if(sortReversed)
            std::sort(allfiles.begin(), allfiles.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file2, file1) < 0; });
        else
            std::sort(allfiles.begin(), allfiles.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file1, file2) < 0; });
    }

    return allfiles;

}
