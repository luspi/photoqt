#include "filefoldermodel.h"

PQFileFolderModel::PQFileFolderModel(QObject *parent) : QObject(parent) {

    m_fileInFolderMainView = "";
    m_folderFileDialog = "";
    m_countMainView = 0;
    m_countFileDialog = 0;

    m_readDocumentOnly = false;
    m_readArchiveOnly = false;

    m_entriesMainView.clear();
    m_entriesFileDialog.clear();

    m_emptyEntry = new PQFileFolderEntry;
    m_emptyEntry->fileName = "";
    m_emptyEntry->filePath = "";
    m_emptyEntry->fileSize = 0;
    m_emptyEntry->fileModified = QDateTime::currentDateTime();
    m_emptyEntry->fileIsDir = false;
    m_emptyEntry->fileType = "";

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
    delete m_emptyEntry;

    for(int i = 0; i < m_entriesMainView.length(); ++i)
        delete m_entriesMainView[i];
    for(int i = 0; i < m_entriesFileDialog.length(); ++i)
        delete m_entriesFileDialog[i];

}

void PQFileFolderModel::loadDataMainView() {

    DBG << CURDATE << "PQFileFolderModel::loadDataMainView()" << NL;

    ////////////////////////
    // clear old entries

    for(int i = 0; i < m_entriesMainView.length(); ++i)
        delete m_entriesMainView[i];
    m_entriesMainView.clear();

    m_countMainView = 0;

    ////////////////////////
    // load files

    if(m_readDocumentOnly && PQImageFormats::get().getEnabledFormatsPoppler().contains(QFileInfo(m_fileInFolderMainView).suffix().toLower())) {

        QStringList pdfpages = listPDFPages(m_fileInFolderMainView);
        QFileInfo info(m_fileInFolderMainView);

        foreach(QString page, pdfpages) {
            PQFileFolderEntry *entry = new PQFileFolderEntry;
            entry->fileName = page;
            entry->filePath = page;
            entry->fileSize = info.size();
            entry->fileModified = info.lastModified();
            entry->fileIsDir = false;
            entry->fileType = "";
            m_entriesMainView.append(entry);
        }

        m_countMainView = pdfpages.length();
        m_readDocumentOnly = false;

    } else if(m_readArchiveOnly && PQImageFormats::get().getEnabledFormatsLibArchive().contains(QFileInfo(m_fileInFolderMainView).suffix().toLower())) {

        PQHandlingFileDir handling;
        QStringList archivecontent = handling.listArchiveContent(m_fileInFolderMainView);
        QFileInfo info(m_fileInFolderMainView);

        foreach(QString arc, archivecontent) {
            PQFileFolderEntry *entry = new PQFileFolderEntry;
            entry->fileName = arc;
            entry->filePath = arc;
            entry->fileSize = info.size();
            entry->fileModified = info.lastModified();
            entry->fileIsDir = false;
            entry->fileType = "";
            m_entriesMainView.append(entry);
        }

        m_countMainView = archivecontent.length();
        m_readArchiveOnly = false;

    } else {

        QFileInfoList infos = getAllFiles(QFileInfo(m_fileInFolderMainView).absolutePath());

        foreach(QFileInfo info, infos) {
            PQFileFolderEntry *entry = new PQFileFolderEntry;
            entry->fileName = info.fileName();
            entry->filePath = info.absoluteFilePath();
            entry->fileSize = info.size();
            entry->fileModified = info.lastModified();
            entry->fileIsDir = true;
            entry->fileType = db.mimeTypeForFile(info).name();
            m_entriesMainView.append(entry);
        }

        m_countMainView = infos.length();

    }

    emit newDataLoadedMainView();
    emit countMainViewChanged();

}

void PQFileFolderModel::loadDataFileDialog() {

    DBG << CURDATE << "PQFileFolderModel::loadData()" << NL;

    ////////////////////////
    // clear old entries

    for(int i = 0; i < m_entriesFileDialog.length(); ++i)
        delete m_entriesFileDialog[i];
    m_entriesFileDialog.clear();

    m_countFileDialog = 0;

    ////////////////////////
    // load folders

    QFileInfoList infosFolders = getAllFolders(m_folderFileDialog);

    foreach(QFileInfo info, infosFolders) {
        PQFileFolderEntry *entry = new PQFileFolderEntry;
        entry->fileName = info.fileName();
        entry->filePath = info.absoluteFilePath();
        entry->fileSize = info.size();
        entry->fileModified = info.lastModified();
        entry->fileIsDir = true;
        entry->fileType = db.mimeTypeForFile(info).name();
        m_entriesFileDialog.append(entry);
    }

    m_countFileDialog += infosFolders.length();

    ////////////////////////
    // load files

    QFileInfoList infosFiles = getAllFiles(m_folderFileDialog);

    foreach(QFileInfo info, infosFiles) {
        PQFileFolderEntry *entry = new PQFileFolderEntry;
        entry->fileName = info.fileName();
        entry->filePath = info.absoluteFilePath();
        entry->fileSize = info.size();
        entry->fileModified = info.lastModified();
        entry->fileIsDir = false;
        entry->fileType = db.mimeTypeForFile(info).name();
        m_entriesFileDialog.append(entry);
    }

    m_countFileDialog += infosFiles.length();

    emit newDataLoadedFileDialog();
    emit countFileDialogChanged();

}

QFileInfoList PQFileFolderModel::getAllFolders(QString folder) {

    QFileInfoList ret;

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

        ret = dir.entryInfoList();

        if(m_sortField == SortBy::NaturalName) {
            QCollator collator;
            collator.setNumericMode(true);
            if(m_sortReversed)
                std::sort(ret.begin(), ret.end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) { return collator.compare(file2.fileName(), file1.fileName()) < 0; });
            else
                std::sort(ret.begin(), ret.end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) { return collator.compare(file1.fileName(), file2.fileName()) < 0; });
        }

        cache.saveFoldersToCache(folder, m_showHidden, sortFlags, m_defaultNameFilters, m_nameFilters, m_filenameFilters, m_mimeTypeFilters, m_sortField, m_sortReversed, ret);

    }

    return ret;

}

QFileInfoList PQFileFolderModel::getAllFiles(QString folder) {

    QFileInfoList ret;

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

    if(!cache.loadFilesFromCache(folder, m_showHidden, sortFlags, m_defaultNameFilters, m_nameFilters, m_filenameFilters, m_mimeTypeFilters, m_sortField, m_sortReversed, ret)) {

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

        if(m_nameFilters.size() == 0 && m_defaultNameFilters.size() == 0 && m_mimeTypeFilters.size() == 0)
            ret = dir.entryInfoList();
        else {
            QDirIterator iter(dir);
            while(iter.hasNext()) {
                iter.next();
                const QFileInfo f = iter.fileInfo();
                if((m_nameFilters.size() == 0 || m_nameFilters.contains(f.suffix().toLower())) && (m_defaultNameFilters.size() == 0 || m_defaultNameFilters.contains(f.suffix().toLower()))) {
                    if(m_filenameFilters.length() == 0)
                        ret << f;
                    else {
                        foreach(QString fil, m_filenameFilters)
                            if(f.baseName().contains(fil)) {
                                ret << f;
                                break;
                            }
                    }
                }
                // if not the ending, then check the mime type
                else if(m_mimeTypeFilters.contains(db.mimeTypeForFile(f.absoluteFilePath()).name()))
                    ret << f;
            }
        }

        if(m_sortField == SortBy::NaturalName) {
            QCollator collator;
            collator.setNumericMode(true);
            if(m_sortReversed)
                std::sort(ret.begin(), ret.end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) { return collator.compare(file2.fileName(), file1.fileName()) < 0; });
            else
                std::sort(ret.begin(), ret.end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) { return collator.compare(file1.fileName(), file2.fileName()) < 0; });
        }

        cache.saveFilesToCache(folder, m_showHidden, sortFlags, m_defaultNameFilters, m_nameFilters, m_filenameFilters, m_mimeTypeFilters, m_sortField, m_sortReversed, ret);

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

    PQFileFolderEntry *entry = m_entriesFileDialog[index];
    ret << entry->fileName;
    ret << entry->filePath;
    ret << entry->fileSize;
    ret << entry->fileModified;
    ret << entry->fileIsDir;
    ret << entry->fileType;

    return ret;

}

QVariantList PQFileFolderModel::getValuesMainView(int index) {

    QVariantList ret;

    PQFileFolderEntry *entry = m_entriesMainView[index];
    ret << entry->fileName;
    ret << entry->filePath;
    ret << entry->fileSize;
    ret << entry->fileModified;
    ret << entry->fileIsDir;
    ret << entry->fileType;

    return ret;

}
