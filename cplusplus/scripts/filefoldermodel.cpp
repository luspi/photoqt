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
    connect(loadDelay, &QTimer::timeout, this, &PQFileFolderModel::loadData);

    // this is needed so that the delete in loadData() is valid. Checking there for nullptr has led to crashes in the past
    watcher = new QFileSystemWatcher;

    loadDelay->start();

}

void PQFileFolderModel::loadData() {

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
    connect(watcher, &QFileSystemWatcher::directoryChanged, this, &PQFileFolderModel::loadData);

    // Folders
    QFileInfoList alldirs = getAllFoldersInFolder(m_folder, m_showHidden, m_sortField, m_sortReversed);

    // Files
    allImageFilesInOrder = getAllImagesInFolder(m_folder, m_showHidden, m_nameFilters, m_mimeTypeFilters, m_sortField, m_sortReversed);

    m_count = alldirs.length()+allImageFilesInOrder.length();

    if(m_count == 0)
        return;

    entries.reserve(m_count);

    beginInsertRows(QModelIndex(), rowCount(), rowCount()+m_count-1);

    for(int i = 0; i < alldirs.length(); ++i) {

        PQFileFolderEntry *entry = new PQFileFolderEntry;
        entry->fileName = alldirs.at(i).fileName();
        entry->filePath = alldirs.at(i).filePath();
        entry->fileSize = alldirs.at(i).size();
        entry->fileModified = alldirs.at(i).lastModified();
        entry->fileIsDir = alldirs.at(i).isDir();

        entries.push_back(entry);

    }
    for(int i = 0; i < allImageFilesInOrder.length(); ++i) {

        PQFileFolderEntry *entry = new PQFileFolderEntry;
        entry->fileName = allImageFilesInOrder.at(i).fileName();
        entry->filePath = allImageFilesInOrder.at(i).filePath();
        entry->fileSize = allImageFilesInOrder.at(i).size();
        entry->fileModified = allImageFilesInOrder.at(i).lastModified();
        entry->fileIsDir = allImageFilesInOrder.at(i).isDir();

        entries.push_back(entry);

    }

    endInsertRows();

    emit dataChanged(createIndex(0, 0, entries.first()), createIndex(entries.length()-1, 0, entries.last()));

}

QFileInfoList PQFileFolderModel::getAllFoldersInFolder(QString path, bool showHidden, SortBy sortfield, bool sortReversed) {

    DBG << CURDATE << "PQFileFolderModel::getAllFoldersInFolder()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL
        << CURDATE << "** showHidden = " << showHidden << NL
        << CURDATE << "** sortfield = " << sortfield << NL
        << CURDATE << "** sortReversed = " << sortReversed << NL;

    QDir dir;
    dir.setPath(path);

    if(!dir.exists()) {
        LOG << CURDATE << "ERROR: Folder location does not exist: " << path.toStdString() << NL;
        return QFileInfoList();
    }

    if(showHidden)
        dir.setFilter(QDir::Dirs|QDir::NoDotAndDotDot|QDir::Hidden);
    else
        dir.setFilter(QDir::Dirs|QDir::NoDotAndDotDot);

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

    QFileInfoList alldirs = dir.entryInfoList();

    if(sortfield == SortBy::NaturalName) {
        QCollator collator;
        collator.setNumericMode(true);
        if(sortReversed)
            std::sort(alldirs.begin(), alldirs.end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) { return collator.compare(file2.fileName(), file1.fileName()) < 0; });
        else
            std::sort(alldirs.begin(), alldirs.end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) { return collator.compare(file1.fileName(), file2.fileName()) < 0; });
    }

    return alldirs;

}

QFileInfoList PQFileFolderModel::getAllImagesInFolder(QString path, bool showHidden, QStringList nameFilters, QStringList mimeTypeFilters, SortBy sortfield, bool sortReversed) {

    DBG << CURDATE << "PQFileFolderModel::getAllImagesInFolder()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL
        << CURDATE << "** showHidden = " << showHidden << NL
        << CURDATE << "** nameFilters = " << nameFilters.join(",").toStdString() << NL
        << CURDATE << "** sortfield = " << sortfield << NL
        << CURDATE << "** sortReversed = " << sortReversed << NL;

    QDir dir;

    QFileInfo info(path);
    if(info.isDir())
        dir.setPath(path);
    else
        dir.setPath(info.absolutePath());

    if(!dir.exists()) {
        LOG << CURDATE << "ERROR: Folder location does not exist: " << path.toStdString() << NL;
        return QFileInfoList();
    }

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

    QMimeDatabase db;

    QFileInfoList allfiles;
    if(nameFilters.size() == 0 && mimeTypeFilters.size() == 0)
        allfiles =dir.entryInfoList();
    else {
        QFileInfoList tmpallfiles = dir.entryInfoList();
        for(QFileInfo f : tmpallfiles) {
            // check file ending
            if(nameFilters.size() == 0 || nameFilters.contains(f.suffix().toLower()))
                allfiles << f;
            // if not the ending, then check the mime type
            else if(mimeTypeFilters.contains(db.mimeTypeForFile(f.absoluteFilePath()).name()))
                allfiles << f;
        }
    }


    if(sortfield == SortBy::NaturalName) {
        QCollator collator;
        collator.setNumericMode(true);
        if(sortReversed)
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
