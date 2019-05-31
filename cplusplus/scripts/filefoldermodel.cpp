#include "filefoldermodel.h"
#include <chrono>

PQFileFolderModel::PQFileFolderModel(QObject *parent) : QAbstractListModel(parent) {

    loadDelay = new QTimer;
    loadDelay->setInterval(0);
    loadDelay->setSingleShot(true);
    connect(loadDelay, &QTimer::timeout, this, &PQFileFolderModel::loadData);

    if(m_folder.isNull())
        m_folder = QDir::homePath();

    loadDelay->start();

}

void PQFileFolderModel::loadData() {

    qDebug() << "loadData";

    auto t1 = std::chrono::steady_clock::now();

    beginRemoveRows(QModelIndex(), 0, rowCount());

    for(int i = 0; i < entries.length(); ++i)
        delete entries[i];
    entries.clear();

    endRemoveRows();

    auto t2 = std::chrono::steady_clock::now();
    std::cout << "remove rows: " << std::chrono::duration<double, std::milli>(t2-t1).count() << std::endl;

    // FIRST ALL DIRS

    QDir dir;
    dir.setPath(m_folder);

    if(!dir.exists()) {
        LOG << CURDATE << "ERROR: Folder location does not exist: " << m_folder.toStdString() << NL;
        return;
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

    auto t3 = std::chrono::steady_clock::now();
    std::cout << "setup dirs: " << std::chrono::duration<double, std::milli>(t3-t2).count() << std::endl;

    QFileInfoList alldirs = dir.entryInfoList();

    auto t4 = std::chrono::steady_clock::now();
    std::cout << "get dirs: " << std::chrono::duration<double, std::milli>(t4-t3).count() << std::endl;

    if(m_sortField == SortBy::NaturalName) {
        QCollator collator;
        collator.setNumericMode(true);
        if(m_sortReversed)
            std::sort(alldirs.begin(), alldirs.end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) { return collator.compare(file2.fileName(), file1.fileName()) < 0; });
        else
            std::sort(alldirs.begin(), alldirs.end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) { return collator.compare(file1.fileName(), file2.fileName()) < 0; });
    }

    auto t5 = std::chrono::steady_clock::now();
    std::cout << "sort dirs: " << std::chrono::duration<double, std::milli>(t5-t4).count() << std::endl;

    // THEN ALL FILES

    dir.setNameFilters(m_nameFilters);
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

    auto t6 = std::chrono::steady_clock::now();
    std::cout << "setup files: " << std::chrono::duration<double, std::milli>(t6-t5).count() << std::endl;

    QFileInfoList allfiles = dir.entryInfoList();

    auto t7 = std::chrono::steady_clock::now();
    std::cout << "get files: " << std::chrono::duration<double, std::milli>(t7-t6).count() << std::endl;

    if(m_sortField == SortBy::NaturalName) {
        QCollator collator;
        collator.setNumericMode(true);
        if(m_sortReversed)
            std::sort(allfiles.begin(), allfiles.end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) { return collator.compare(file2.fileName(), file1.fileName()) < 0; });
        else
            std::sort(allfiles.begin(), allfiles.end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) { return collator.compare(file1.fileName(), file2.fileName()) < 0; });
    }

    auto t8 = std::chrono::steady_clock::now();
    std::cout << "sort files: " << std::chrono::duration<double, std::milli>(t8-t7).count() << std::endl;

    QFileInfoList entrylist = alldirs+allfiles;

    m_count = entrylist.length();

    if(m_count == 0)
        return;

    auto t9 = std::chrono::steady_clock::now();
    std::cout << "combine dirs and files: " << std::chrono::duration<double, std::milli>(t9-t8).count() << std::endl;

    entries.reserve(m_count);

    beginInsertRows(QModelIndex(), rowCount(), rowCount()+entrylist.length()-1);

    for(int i = 0; i < m_count; ++i) {

        PQFileFolderEntry *entry = new PQFileFolderEntry;
        entry->fileName = entrylist.at(i).fileName();
        entry->filePath = entrylist.at(i).filePath();
        entry->fileSize = entrylist.at(i).size();
        entry->fileModified = entrylist.at(i).lastModified();
        entry->fileIsDir = entrylist.at(i).isDir();

        entries.push_back(entry);

    }

    endInsertRows();

    auto t10 = std::chrono::steady_clock::now();
    std::cout << "add rows: " << std::chrono::duration<double, std::milli>(t10-t9).count() << std::endl;

    emit dataChanged(createIndex(0, 0, entries.first()), createIndex(entries.length()-1, 0, entries.last()));

}
