/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

#include "filefoldermodel.h"
#include "../imageprovider/resolutionprovider.h"

PQFileFolderModel::PQFileFolderModel(QObject *parent) : QObject(parent) {

    m_fileInFolderMainView = "";
    m_folderFileDialog = "";
    m_countMainView = 0;
    m_countFoldersFileDialog = 0;
    m_countFilesFileDialog = 0;

    m_readDocumentOnly = false;
    m_readArchiveOnly = false;
    m_includeFilesInSubFolders = false;

    m_entriesMainView.clear();
    m_entriesFileDialog.clear();

    m_nameFilters = QStringList();
    m_defaultNameFilters = QStringList();
    m_filenameFilters = QStringList();
    m_mimeTypeFilters = QStringList();
    m_imageResolutionFilter = QSize(0,0);
    m_fileSizeFilter = 0;
    m_showHidden = false;
    m_sortField = SortBy::NaturalName;
    m_sortReversed = false;

    watcherMainView = new QFileSystemWatcher;
    watcherFileDialog = new QFileSystemWatcher;

    connect(watcherMainView, &QFileSystemWatcher::directoryChanged, this, &PQFileFolderModel::loadDataMainView);
    connect(watcherFileDialog, &QFileSystemWatcher::directoryChanged, this, &PQFileFolderModel::loadDataFileDialog);

    loadDelayMainView = new QTimer;
    loadDelayMainView->setInterval(10);
    loadDelayMainView->setSingleShot(true);
    connect(loadDelayMainView, &QTimer::timeout, this, &PQFileFolderModel::loadDataMainView);

    loadDelayFileDialog = new QTimer;
    loadDelayFileDialog->setInterval(10);
    loadDelayFileDialog->setSingleShot(true);
    connect(loadDelayFileDialog, &QTimer::timeout, this, &PQFileFolderModel::loadDataFileDialog);

    m_advancedSortDone = 0;

}

PQFileFolderModel::~PQFileFolderModel() {

    delete loadDelayMainView;
    delete loadDelayFileDialog;

    delete watcherMainView;
    delete watcherFileDialog;

}

void PQFileFolderModel::loadDataMainView() {

    DBG << CURDATE << "PQFileFolderModel::loadDataMainView()" << NL;

    ////////////////////////
    // clear old entries

    m_entriesMainView.clear();
    m_countMainView = 0;
    delete watcherMainView;
    watcherMainView = new QFileSystemWatcher;

    ////////////////////////
    // no new directory

    if(m_fileInFolderMainView.isEmpty()) {
        Q_EMIT newDataLoadedMainView();
        Q_EMIT countMainViewChanged();
        return;
    }

    ////////////////////////
    // watch directory for changes

    watcherMainView->addPath(QFileInfo(m_fileInFolderMainView).absolutePath());
    connect(watcherMainView, &QFileSystemWatcher::directoryChanged, this, &PQFileFolderModel::loadDataMainView);

    ////////////////////////
    // load files

    if(m_fileInFolderMainView.contains("::PQT::")) {
        m_readDocumentOnly = true;
        m_fileInFolderMainView = m_fileInFolderMainView.split("::PQT::").at(1);
    } else if(m_fileInFolderMainView.contains("::ARC::")) {
        m_readArchiveOnly = true;
        m_fileInFolderMainView = m_fileInFolderMainView.split("::ARC::").at(1);
    }

    if(m_readDocumentOnly && PQImageFormats::get().getEnabledFormatsPoppler().contains(QFileInfo(m_fileInFolderMainView).suffix().toLower())) {

        m_entriesMainView = listPDFPages(m_fileInFolderMainView);
        m_countMainView = m_entriesMainView.length();
        m_readDocumentOnly = false;

    } else if(m_readArchiveOnly && PQImageFormats::get().getEnabledFormatsLibArchive().contains(QFileInfo(m_fileInFolderMainView).suffix().toLower())) {

        PQHandlingFileDir handling;
        m_entriesMainView = handling.listArchiveContent(m_fileInFolderMainView);
        m_countMainView = m_entriesMainView.length();
        m_readArchiveOnly = false;

    } else {

        m_entriesMainView = getAllFiles(QFileInfo(m_fileInFolderMainView).absolutePath());
        m_countMainView = m_entriesMainView.length();

    }

    QFileInfo info(m_fileInFolderMainView);
    if(info.absolutePath() == cacheAdvancedSortFolderName)
        advancedSortMainView();
    else
        cacheAdvancedSortFolderName = "";

    Q_EMIT newDataLoadedMainView();
    Q_EMIT countMainViewChanged();

}

void PQFileFolderModel::loadDataFileDialog() {

    DBG << CURDATE << "PQFileFolderModel::loadData()" << NL;

    ////////////////////////
    // clear old entries

    m_entriesFileDialog.clear();
    m_countFoldersFileDialog = 0;
    m_countFilesFileDialog = 0;
    delete watcherFileDialog;
    watcherFileDialog = new QFileSystemWatcher;

    ////////////////////////
    // no new directory

    if(m_folderFileDialog.isEmpty()) {
        Q_EMIT newDataLoadedFileDialog();
        Q_EMIT countFileDialogChanged();
        return;
    }

    ////////////////////////
    // watch directory for changes

    watcherFileDialog->addPath(m_folderFileDialog);
    connect(watcherFileDialog, &QFileSystemWatcher::directoryChanged, this, &PQFileFolderModel::loadDataFileDialog);

    ////////////////////////
    // load folders

    m_entriesFileDialog = getAllFolders(m_folderFileDialog);
    m_countFoldersFileDialog = m_entriesFileDialog.length();

    ////////////////////////
    // load files

    m_entriesFileDialog.append(getAllFiles(m_folderFileDialog, true));

    m_countFilesFileDialog = m_entriesFileDialog.length()-m_countFoldersFileDialog;

    Q_EMIT newDataLoadedFileDialog();
    Q_EMIT countFileDialogChanged();

}

QStringList PQFileFolderModel::getAllFolders(QString folder) {

    DBG << CURDATE << "PQFileFolderModel::getAllFolders()" << NL
        << CURDATE << "** folder = " << folder.toStdString() << NL;

    QStringList ret;

    QDir::SortFlags sortFlags = QDir::IgnoreCase;
    if(m_sortReversed)
        sortFlags |= QDir::Reversed;
    if(m_sortField == SortBy::Name)
        sortFlags |= QDir::Name;
    else if(m_sortField == SortBy::Time)
        sortFlags |= QDir::Time;
    else if(m_sortField == SortBy::Size)
        sortFlags |= QDir::Size;
    else if(m_sortField == SortBy::Type)
        sortFlags |= QDir::Type;

    if(!cache.loadFoldersFromCache(folder, m_showHidden, sortFlags, m_defaultNameFilters, m_nameFilters, m_filenameFilters, m_mimeTypeFilters, m_imageResolutionFilter, m_fileSizeFilter, false, m_sortField, m_sortReversed, ret)) {

        QDir dir(folder);

        if(!dir.exists()) {
            LOG << CURDATE << "ERROR: Folder location does not exist: " << folder.toStdString() << NL;
            return ret;
        }

        if(m_showHidden)
            dir.setFilter(QDir::Dirs|QDir::NoDotAndDotDot|QDir::Hidden);
        else
            dir.setFilter(QDir::Dirs|QDir::NoDotAndDotDot);

        if(m_sortField != SortBy::NaturalName)
            dir.setSorting(sortFlags);

        const QFileInfoList lst = dir.entryInfoList();
        for(const auto &f : lst)
            ret << f.filePath();

        if(m_sortField == SortBy::NaturalName) {
            QCollator collator;
            collator.setNumericMode(true);
            if(m_sortReversed)
                std::sort(ret.begin(), ret.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file2, file1) < 0; });
            else
                std::sort(ret.begin(), ret.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file1, file2) < 0; });
        }

        cache.saveFoldersToCache(folder, m_showHidden, sortFlags, m_defaultNameFilters, m_nameFilters, m_filenameFilters, m_mimeTypeFilters, m_imageResolutionFilter, m_fileSizeFilter, false, m_sortField, m_sortReversed, ret);

    }

    return ret;

}

QStringList PQFileFolderModel::getAllFiles(QString folder, bool ignoreFiltersExceptDefault) {

    DBG << CURDATE << "PQFileFolderModel::getAllFiles()" << NL
        << CURDATE << "** folder = " << folder.toStdString() << NL;

    QStringList ret;

    QDir::SortFlags sortFlags = QDir::IgnoreCase;
    if(m_sortReversed)
        sortFlags |= QDir::Reversed;
    if(m_sortField == SortBy::Name)
        sortFlags |= QDir::Name;
    else if(m_sortField == SortBy::Time)
        sortFlags |= QDir::Time;
    else if(m_sortField == SortBy::Size)
        sortFlags |= QDir::Size;
    else if(m_sortField == SortBy::Type)
        sortFlags |= QDir::Type;

    // In order to properly sort the resulting list (sorting by directory first and by chosen sorting criteria second (on a per-directory basis)
    // we need to consider each directory on its own before adding it to the resulting list at the end

    QStringList foldersToScan;
    foldersToScan << folder;

    if(m_includeFilesInSubFolders) {
        QDirIterator iter(folder, QDir::Dirs|QDir::NoDotAndDotDot, QDirIterator::Subdirectories);
        int count = 0;
        while(iter.hasNext()) {
            iter.next();
            foldersToScan << iter.filePath();

            // we limit the number of subfolders to avoid getting stuck
            ++count;
            if(count > 100)
                break;
        }
    }

    for(const QString &f : qAsConst(foldersToScan)) {

        if(!cache.loadFilesFromCache(f, m_showHidden, sortFlags, m_defaultNameFilters, m_nameFilters, m_filenameFilters, m_mimeTypeFilters, m_imageResolutionFilter, m_fileSizeFilter, ignoreFiltersExceptDefault, m_sortField, m_sortReversed, ret)) {

            QStringList ret_cur;

            QDir dir(f);

            if(!dir.exists()) {
                LOG << CURDATE << "ERROR: Folder location does not exist: " << f.toStdString() << NL;
                continue;
            }

            if(m_showHidden)
                dir.setFilter(QDir::Files|QDir::NoDotAndDotDot|QDir::Hidden);
            else
                dir.setFilter(QDir::Files|QDir::NoDotAndDotDot);

            if(m_sortField != SortBy::NaturalName)
                dir.setSorting(sortFlags);

            if(m_nameFilters.size() == 0 && m_defaultNameFilters.size() == 0 && m_mimeTypeFilters.size() == 0 && m_imageResolutionFilter.isNull() && m_fileSizeFilter == 0) {
                const QFileInfoList lst = dir.entryInfoList();
                for(const auto &f: lst)
                    ret_cur << f.filePath();
            } else {

                const QFileInfoList lst = dir.entryInfoList();
                for(const auto &f : lst) {

                    if(!ignoreFiltersExceptDefault) {

                        if(m_fileSizeFilter != 0) {

                            // only show images greater than -> fails check
                            if(m_fileSizeFilter > 0 && f.size() < m_fileSizeFilter)
                                continue;

                            // only show images less than -> fails check
                            if(m_fileSizeFilter < 0 && f.size() > -m_fileSizeFilter)
                                continue;

                        }

                        if(!m_imageResolutionFilter.isNull()) {

                            const bool greater = (m_imageResolutionFilter.width()>0);
                            const int width = m_imageResolutionFilter.width();
                            const int height = m_imageResolutionFilter.height();

                            QSize origSize;
                            PQImageProviderFull imageprovider;
                            imageprovider.requestImage(QUrl::toPercentEncoding(f.absoluteFilePath(), "", " "), &origSize, QSize(1,1));

                            if(greater && (origSize.width() < width || origSize.height() < height))
                                continue;

                            if(!greater && (origSize.width() > -width || origSize.height() > -height))
                                continue;

                        }

                    }

                    if((m_nameFilters.size() == 0 || (!ignoreFiltersExceptDefault && m_nameFilters.contains(f.suffix().toLower()))) && (m_defaultNameFilters.size() == 0 || m_defaultNameFilters.contains(f.suffix().toLower()))) {
                        if(m_filenameFilters.length() == 0 || ignoreFiltersExceptDefault)
                            ret_cur << f.absoluteFilePath();
                        else {
                            for(const QString &fil : qAsConst(m_filenameFilters)) {
                                if(f.baseName().contains(fil)) {
                                    ret_cur << f.absoluteFilePath();
                                    break;
                                }
                            }
                        }
                    }
                    // if not the ending, then check the mime type
                    else if(m_nameFilters.size() == 0 && m_mimeTypeFilters.contains(db.mimeTypeForFile(f.absoluteFilePath()).name())) {
                        if(m_filenameFilters.length() == 0 || ignoreFiltersExceptDefault)
                            ret_cur << f.absoluteFilePath();
                        else {
                            for(const QString &fil : qAsConst(m_filenameFilters)) {
                                if(f.baseName().contains(fil)) {
                                    ret_cur << f.absoluteFilePath();
                                    break;
                                }
                            }
                        }
                    }

                }

            }

            if(m_sortField == SortBy::NaturalName) {
                QCollator collator;
                collator.setNumericMode(true);
                if(m_sortReversed)
                    std::sort(ret_cur.begin(), ret_cur.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file2, file1) < 0; });
                else
                    std::sort(ret_cur.begin(), ret_cur.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file1, file2) < 0; });
            }

            // add current list, sorted, to global result list
            ret << ret_cur;

            cache.saveFilesToCache(f, m_showHidden, sortFlags, m_defaultNameFilters, m_nameFilters, m_filenameFilters, m_mimeTypeFilters, m_imageResolutionFilter, m_fileSizeFilter, ignoreFiltersExceptDefault, m_sortField, m_sortReversed, ret_cur);

        }

    }

    return ret;

}

QStringList PQFileFolderModel::listPDFPages(QString path) {

    DBG << CURDATE << "PQFileFolderModel::listPDFPages()" << NL
        << CURDATE << "** path = " << path.toStdString() << NL;

    QStringList ret;

#ifdef POPPLER

    Poppler::Document* document = Poppler::Document::load(path);
    if(document && !document->isLocked()) {
        int numPages = document->numPages();
        for(int i = 0; i < numPages; ++i)
            ret.append(QString("%1::PQT::%2").arg(i).arg(path));
    }
    delete document;

#endif

    return ret;

}

void PQFileFolderModel::removeEntryMainView(int index) {

    DBG << CURDATE << "PQFileFolderModel::removeEntryMainView()" << NL
        << CURDATE << "** index = " << index << NL;

    QFileInfo info(m_fileInFolderMainView);
    if(info.absolutePath() == cacheAdvancedSortFolderName) {
        QString oldentry = m_entriesMainView[index];
        cacheAdvancedSortFolder.removeOne(oldentry);
    }

    loadDelayFileDialog->start();
    m_entriesMainView.removeAt(index);
    setCountMainView(m_countMainView-1);

    Q_EMIT newDataLoadedMainView();
    Q_EMIT newDataLoadedFileDialog();

}

void PQFileFolderModel::advancedSortMainView() {

    // if nothing changed, reload folder
    QFileInfo info(m_fileInFolderMainView);
    if(info.absolutePath() == cacheAdvancedSortFolderName
            && PQSettings::get()["imageviewAdvancedSortCriteria"].toString() == cacheAdvancedSortCriteria
            && info.lastModified().toMSecsSinceEpoch() == cacheAdvancedSortLastModified) {

        m_entriesMainView = cacheAdvancedSortFolder;
        Q_EMIT newDataLoadedMainView();
        Q_EMIT advancedSortingComplete();
        return;

    }

    advancedSortKeepGoing = true;
    m_advancedSortDone = 0;
    Q_EMIT advancedSortDoneChanged();

    QtConcurrent::run([=]() {

        PQImageProviderFull *imageprovider = new PQImageProviderFull;
        PQLoadImage loader;

        QMap<qint64, QStringList> sortedWithKey;

        for(int i = 0; i < m_countMainView; ++i) {

            if(!advancedSortKeepGoing) {
                delete imageprovider;
                return;
            }

            // the key used for sorting
            // depending on the criteria, it is computed in different ways
            qint64 key = 0;

            if(PQSettings::get()["imageviewAdvancedSortCriteria"].toString() == "resolution") {

                QSize size = PQResolutionProvider::get().getResolution(m_entriesMainView[i]);
                if(!size.isValid()) {
                    size = loader.loadSize(m_entriesMainView[i]);
                    if(size.isValid())
                        PQResolutionProvider::get().saveResolution(m_entriesMainView[i], size);
                }

                key = size.width()+size.height();

            } else if(PQSettings::get()["imageviewAdvancedSortCriteria"].toString() == "luminosity") {

                QSize requestedSize = QSize(512,512);
                if(PQSettings::get()["imageviewAdvancedSortQuality"].toString() == "medium")
                    requestedSize = QSize(1024,1024);
                else if(PQSettings::get()["imageviewAdvancedSortQuality"].toString() == "high")
                    requestedSize = QSize(-1,-1);

                QSize origSize;
                QImage img = imageprovider->requestImage(QUrl::toPercentEncoding(m_entriesMainView[i], "", " "), &origSize, requestedSize);
                PQResolutionProvider::get().saveResolution(m_entriesMainView[i], origSize);

                QRgb *rgb = reinterpret_cast<QRgb*>(img.bits());

                quint64 pixelCount = img.width() * img.height();

                double val = 0;
                for(int i = 0; i < img.height(); ++i) {
                    qint64 tmpval = 0;
                    for(int j = 0; j < img.width(); ++j) {
                        int h,s,v;
                        QColor col(rgb[i*img.width()+j]);
                        col.getHsv(&h,&s,&v);
                        tmpval += v;
                    }
                    val += static_cast<double>(tmpval)/static_cast<double>(pixelCount);

                    if(!advancedSortKeepGoing) {
                        delete imageprovider;
                        return;
                    }
                }

                key = val;

            } else {

                QSize requestedSize = QSize(512,512);
                if(PQSettings::get()["imageviewAdvancedSortQuality"].toString() == "medium")
                    requestedSize = QSize(1024,1024);
                else if(PQSettings::get()["imageviewAdvancedSortQuality"].toString() == "high")
                    requestedSize = QSize(-1,-1);

                QSize origSize;
                QImage img = imageprovider->requestImage(QUrl::toPercentEncoding(m_entriesMainView[i], "", " "), &origSize, requestedSize);
                PQResolutionProvider::get().saveResolution(m_entriesMainView[i], origSize);

                const int width = origSize.width();
                const int height = origSize.height();

                QRgb *ct;

                QVector<qint64> red(256);
                QVector<qint64> green(256);
                QVector<qint64> blue(256);
                for(int i = 0 ; i < height; i++){
                    ct = (QRgb *)img.scanLine(i);
                    for(int j = 0 ; j < width; j++){
                        red[qRed(ct[j])]+=1;
                    }
                }

                if(!advancedSortKeepGoing) {
                    delete imageprovider;
                    return;
                }

                for(int i = 0 ; i < height; i++){
                    ct = (QRgb *)img.scanLine(i);
                    for(int j = 0 ; j < width; j++){
                        green[qGreen(ct[j])]+=1;
                    }
                }

                if(!advancedSortKeepGoing) {
                    delete imageprovider;
                    return;
                }

                for(int i = 0 ; i < height; i++){
                    ct = (QRgb *)img.scanLine(i);
                    for(int j = 0 ; j < width; j++){
                        blue[qBlue(ct[j])]+=1;
                    }
                }

                if(!advancedSortKeepGoing) {
                    delete imageprovider;
                    return;
                }

                qint64 red_val = 0;
                qint64 green_val = 0;
                qint64 blue_val = 0;

                if(PQSettings::get()["imageviewAdvancedSortCriteria"].toString() == "dominantcolor") {

                    QVector<qint64> redSteps(26);
                    QVector<qint64> greenSteps(26);
                    QVector<qint64> blueSteps(26);
                    for(int j = 0; j < 256; ++j) {
                        redSteps[j/10] += red[j];
                        greenSteps[j/10] += green[j];
                        blueSteps[j/10] += blue[j];
                    }

                    red_val = 10*redSteps.indexOf(*std::max_element(redSteps.constBegin(), redSteps.constEnd()));
                    green_val = 10*greenSteps.indexOf(*std::max_element(greenSteps.constBegin(), greenSteps.constEnd()));
                    blue_val = 10*blueSteps.indexOf(*std::max_element(blueSteps.constBegin(), blueSteps.constEnd()));

                } else {

                    // we divide before accumulating to minimize the risk of overflow
                    for(int j = 0; j < red.size(); ++j) red[j] /= static_cast<double>(red.size());
                    for(int j = 0; j < green.size(); ++j) green[j] /= static_cast<double>(green.size());
                    for(int j = 0; j < blue.size(); ++j) blue[j] /= static_cast<double>(blue.size());

                    red_val = red.indexOf(std::accumulate(red.begin(), red.end(), 0));
                    green_val = green.indexOf(std::accumulate(green.begin(), green.end(), 0));
                    blue_val = blue.indexOf(std::accumulate(blue.begin(), blue.end(), 0));

                }

                key = red_val*1000000 + green_val*1000 + blue_val;

            }

            sortedWithKey[key].push_back(m_entriesMainView[i]);

            ++m_advancedSortDone;
            Q_EMIT advancedSortDoneChanged();

        }

        delete imageprovider;

        if(!advancedSortKeepGoing) return;

        QList<qint64> allKeys = sortedWithKey.keys();
        if(PQSettings::get()["imageviewAdvancedSortAscending"].toBool())
            std::sort(allKeys.begin(), allKeys.end(), std::less<int>());
        else
            std::sort(allKeys.begin(), allKeys.end(), std::greater<int>());

        cacheAdvancedSortFolder.clear();
        for(auto entry : qAsConst(allKeys)) {
            QStringList curVals = sortedWithKey[entry];
            curVals.sort(Qt::CaseInsensitive);
            if(!PQSettings::get()["imageviewAdvancedSortAscending"].toBool())
                std::reverse(curVals.begin(), curVals.end());
            for(const auto &e : qAsConst(curVals))
                cacheAdvancedSortFolder << e;
        }

        m_entriesMainView = cacheAdvancedSortFolder;
        Q_EMIT newDataLoadedMainView();
        Q_EMIT countMainViewChanged();
        Q_EMIT advancedSortingComplete();

        QFileInfo info(m_fileInFolderMainView);
        cacheAdvancedSortFolderName = info.absolutePath();
        cacheAdvancedSortLastModified = info.lastModified().toMSecsSinceEpoch();
        cacheAdvancedSortCriteria = PQSettings::get()["imageviewAdvancedSortCriteria"].toString();

    });

}

void PQFileFolderModel::resetModel() {

    delete watcherFileDialog;
    watcherFileDialog = new QFileSystemWatcher;
    delete watcherMainView;
    watcherMainView = new QFileSystemWatcher;
    setCountMainView(0);
    m_entriesMainView.clear();

    cache.resetData();

}
