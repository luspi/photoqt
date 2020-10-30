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
    allImageFilesInOrder = getAllImagesInFolder(m_folder, m_showHidden, m_nameFilters, m_sortField, m_sortReversed);

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

QFileInfoList PQFileFolderModel::getAllImagesInFolder(QString path, bool showHidden, QStringList nameFilters, SortBy sortfield, bool sortReversed) {

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

    dir.setNameFilters(nameFilters);
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

    QFileInfoList allfiles = dir.entryInfoList();

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
