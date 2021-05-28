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

}

void PQFileFolderModel::loadDataMainView() {

    DBG << CURDATE << "PQFileFolderModel::loadDataMainView()" << NL;

    ////////////////////////
    // clear old entries

    m_entriesMainView.clear();
    m_countMainView = 0;

    ////////////////////////
    // load files

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

    if(!cache.loadFoldersFromCache(folder, m_showHidden, sortFlags, m_defaultNameFilters, m_nameFilters, m_filenameFilters, m_mimeTypeFilters, m_sortField, m_sortReversed, false, ret)) {

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

        cache.saveFoldersToCache(folder, m_showHidden, sortFlags, m_defaultNameFilters, m_nameFilters, m_filenameFilters, m_mimeTypeFilters, m_sortField, m_sortReversed, false, ret);

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

    if(!cache.loadFilesFromCache(folder, m_showHidden, sortFlags, m_defaultNameFilters, m_nameFilters, m_filenameFilters, m_mimeTypeFilters, m_sortField, m_sortReversed, m_includeFilesInSubFolders, ret)) {

        QDir dir(folder);

        if(!dir.exists()) {
            LOG << CURDATE << "ERROR: Folder location does not exist: " << folder.toStdString() << NL;
            return ret;
        }

        if(m_showHidden)
            dir.setFilter(QDir::Files|QDir::NoDotAndDotDot|QDir::Hidden);
        else
            dir.setFilter(QDir::Files|QDir::NoDotAndDotDot);

        if(m_sortField != SortBy::NaturalName)
            dir.setSorting(sortFlags);

        if(m_nameFilters.size() == 0 && m_defaultNameFilters.size() == 0 && m_mimeTypeFilters.size() == 0) {
            QDirIterator iter(dir, (m_includeFilesInSubFolders ? QDirIterator::Subdirectories : QDirIterator::NoIteratorFlags));
            while(iter.hasNext()) {
                iter.next();
                ret << iter.filePath();
            }
        } else {
            QDirIterator iter(dir, (m_includeFilesInSubFolders ? QDirIterator::Subdirectories : QDirIterator::NoIteratorFlags));
            while(iter.hasNext()) {
                iter.next();
                const QFileInfo f = iter.fileInfo();
                if((m_nameFilters.size() == 0 || m_nameFilters.contains(f.suffix().toLower())) && (m_defaultNameFilters.size() == 0 || m_defaultNameFilters.contains(f.suffix().toLower()))) {
                    if(m_filenameFilters.length() == 0)
                        ret << f.absoluteFilePath();
                    else {
                        foreach(QString fil, m_filenameFilters)
                            if(f.baseName().contains(fil)) {
                                ret << f.absoluteFilePath();
                                break;
                            }
                    }
                }
                // if not the ending, then check the mime type
                else if(m_mimeTypeFilters.contains(db.mimeTypeForFile(f.absoluteFilePath()).name()))
                    ret << f.absoluteFilePath();
            }
        }

        if(m_sortField == SortBy::NaturalName) {
            QCollator collator;
            collator.setNumericMode(true);
            if(m_sortReversed)
                std::sort(ret.begin(), ret.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file2, file1) < 0; });
            else
                std::sort(ret.begin(), ret.end(), [&collator](const QString &file1, const QString &file2) { return collator.compare(file1, file2) < 0; });
        }

        cache.saveFilesToCache(folder, m_showHidden, sortFlags, m_defaultNameFilters, m_nameFilters, m_filenameFilters, m_mimeTypeFilters, m_sortField, m_sortReversed, m_includeFilesInSubFolders, ret);

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
