#include "filefoldermodel.h"

PQFileFolderModel::PQFileFolderModel(QObject *parent) : QObject(parent) {

    m_fileInFolderMainView = "";
    m_folderFileDialog = "";
    m_countMainView = 0;
    m_countFileDialog = 0;

    m_readDocumentOnly = false;
    m_readArchiveOnly = false;
    m_includeFilesInSubFolders = false;

    m_entriesMainView.clear();
    m_entriesFileDialog.clear();

    m_nameFilters = QStringList();
    m_defaultNameFilters = QStringList();
    m_filenameFilters = QStringList();
    m_mimeTypeFilters = QStringList();
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
        emit newDataLoadedMainView();
        emit countMainViewChanged();
        return;
    }

    ////////////////////////
    // watch directory for changes

    watcherMainView->addPath(QFileInfo(m_fileInFolderMainView).absolutePath());

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

    emit newDataLoadedMainView();
    emit countMainViewChanged();

}

void PQFileFolderModel::loadDataFileDialog() {

    DBG << CURDATE << "PQFileFolderModel::loadData()" << NL;

    ////////////////////////
    // clear old entries

    m_entriesFileDialog.clear();
    m_countFileDialog = 0;
    delete watcherFileDialog;
    watcherFileDialog = new QFileSystemWatcher;

    ////////////////////////
    // no new directory

    if(m_folderFileDialog.isEmpty()) {
        emit newDataLoadedFileDialog();
        emit countFileDialogChanged();
        return;
    }

    ////////////////////////
    // watch directory for changes

    watcherFileDialog->addPath(m_folderFileDialog);

    ////////////////////////
    // load folders

    m_entriesFileDialog = getAllFolders(m_folderFileDialog);

    ////////////////////////
    // load files

    m_entriesFileDialog.append(getAllFiles(m_folderFileDialog));

    m_countFileDialog += m_entriesFileDialog.length();

    emit newDataLoadedFileDialog();
    emit countFileDialogChanged();

}

QStringList PQFileFolderModel::getAllFolders(QString folder) {

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

    if(!cache.loadFoldersFromCache(folder, m_showHidden, sortFlags, m_defaultNameFilters, m_nameFilters, m_filenameFilters, m_mimeTypeFilters, m_sortField, m_sortReversed, ret)) {

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

        QDirIterator iter(dir);
        while(iter.hasNext()) {
            iter.next();
            ret << iter.filePath();
        }

        if(m_sortField == SortBy::NaturalName) {
            QCollator collator;
            collator.setNumericMode(true);
            if(m_sortReversed)
                std::sort(ret.begin(), ret.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file2, file1) < 0; });
            else
                std::sort(ret.begin(), ret.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file1, file2) < 0; });
        }

        cache.saveFoldersToCache(folder, m_showHidden, sortFlags, m_defaultNameFilters, m_nameFilters, m_filenameFilters, m_mimeTypeFilters, m_sortField, m_sortReversed, ret);

    }

    return ret;

}

QStringList PQFileFolderModel::getAllFiles(QString folder) {

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
        while(iter.hasNext()) {
            iter.next();
            foldersToScan << iter.filePath();
        }
    }

    foreach(QString f, foldersToScan) {

        if(!cache.loadFilesFromCache(f, m_showHidden, sortFlags, m_defaultNameFilters, m_nameFilters, m_filenameFilters, m_mimeTypeFilters, m_sortField, m_sortReversed, ret)) {

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

            if(m_nameFilters.size() == 0 && m_defaultNameFilters.size() == 0 && m_mimeTypeFilters.size() == 0) {
                QDirIterator iter(dir);
                while(iter.hasNext()) {
                    iter.next();
                    ret_cur << iter.filePath();
                }
            } else {
                QDirIterator iter(dir);
                while(iter.hasNext()) {
                    iter.next();
                    const QFileInfo f = iter.fileInfo();
                    if((m_nameFilters.size() == 0 || m_nameFilters.contains(f.suffix().toLower())) && (m_defaultNameFilters.size() == 0 || m_defaultNameFilters.contains(f.suffix().toLower()))) {
                        if(m_filenameFilters.length() == 0)
                            ret_cur << f.absoluteFilePath();
                        else {
                            foreach(QString fil, m_filenameFilters)
                                if(f.baseName().contains(fil)) {
                                    ret_cur << f.absoluteFilePath();
                                    break;
                                }
                        }
                    }
                    // if not the ending, then check the mime type
                    else if(m_mimeTypeFilters.contains(db.mimeTypeForFile(f.absoluteFilePath()).name()))
                        ret_cur << f.absoluteFilePath();
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

            cache.saveFilesToCache(f, m_showHidden, sortFlags, m_defaultNameFilters, m_nameFilters, m_filenameFilters, m_mimeTypeFilters, m_sortField, m_sortReversed, ret_cur);

        }

    }

    return ret;

}

QStringList PQFileFolderModel::listPDFPages(QString path) {

    DBG << CURDATE << "PQHandlingFileDialog::listPDFPages()" << NL
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

QVariantList PQFileFolderModel::getValuesFileDialog(int index) {

    QVariantList ret;

    QFileInfo info(m_entriesFileDialog[index]);
    ret << info.fileName();
    ret << info.filePath();
    ret << info.size();
    ret << info.lastModified();
    ret << info.isDir();
    ret << db.mimeTypeForFile(info).name();

    return ret;

}

QVariantList PQFileFolderModel::getValuesMainView(int index) {

    QVariantList ret;

    QFileInfo info(m_entriesMainView[index]);
    ret << info.fileName();
    ret << info.filePath();
    ret << info.size();
    ret << info.lastModified();
    ret << info.isDir();
    ret << db.mimeTypeForFile(info).name();

    return ret;

}

void PQFileFolderModel::removeEntryMainView(int index) {
    loadDelayFileDialog->start();
    m_entriesMainView.removeAt(index);
    setCountMainView(m_countMainView-1);
    emit newDataLoadedMainView();
    emit newDataLoadedFileDialog();
}
