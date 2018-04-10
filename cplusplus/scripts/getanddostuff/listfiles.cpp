/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
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

#include "listfiles.h"
#include "../sortlist.h"

#include <archive.h>
#include <archive_entry.h>
#include <QtDebug>

GetAndDoStuffListFiles::GetAndDoStuffListFiles(QObject *parent) : QObject(parent) {
    imageformats = new ImageFormats;
    mimetypes = new MimeTypes;
}

GetAndDoStuffListFiles::~GetAndDoStuffListFiles() {
    delete imageformats;
    delete mimetypes;
}

QVariantList GetAndDoStuffListFiles::getAllFilesIn(QString file, QString categoryFileTypes, QString filter, bool showHidden, QString sortby, bool sortbyAscending, bool includeSize, bool pdfLoadAllPages, bool loadSinglePdf, bool archiveLoadAllFiles, bool loadSingleArchive, bool archiveUseExternalUnrar) {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "GetAndDoStuffOpenFile::getAllFilesIn() - " << file.toStdString() << " / "
                                                                      << categoryFileTypes.toStdString() << " / "
                                                                      << showHidden << " / "
                                                                      << sortby.toStdString() << " / "
                                                                      << sortbyAscending << NL;

    if(file.startsWith("file:/"))
        file = file.remove(0,6);
#ifdef Q_OS_WIN
    while(file.startsWith("/"))
        file = file.remove(0,1);
#endif
    if(file.contains("::PQT1::"))
        file = file.split("::PQT1::").at(0) + file.split("::PQT2::").at(1);

#ifdef POPPLER
    if(loadSinglePdf && (imageformats->getEnabledFileformatsPoppler().contains("*."+QFileInfo(file).suffix().toLower()) || mimetypes->getEnabledMimeTypesPoppler().contains(mimedb.mimeTypeForFile(file, QMimeDatabase::MatchContent).name()))) {
        QVariantList ret;
        if(loadOnlyPdfPages(file, &ret))
            return ret;
    }
#endif
    if(loadSingleArchive && (imageformats->getEnabledFileformatsArchive().contains("*."+QFileInfo(file).suffix().toLower()) || mimetypes->getEnabledMimeTypesArchive().contains(mimedb.mimeTypeForFile(file, QMimeDatabase::MatchContent).name()))) {
        QVariantList ret;
        if(loadOnlyArchiveFiles(file, &ret, archiveUseExternalUnrar))
            return ret;
    }

    QFileInfoList list = getEntryList(file, categoryFileTypes, showHidden);

    Sort::list(&list, sortby, sortbyAscending);

    QVariantList ret;

    if(includeSize) {

        if(filter.startsWith(".")) {
            for(QFileInfo l : list) {
                QString fn = l.fileName().trimmed();
                if(!fn.endsWith(filter) || fn == "") continue;
                ret.append(fn);
                qint64 s = l.size();
                if(s <= 1024)
                    ret.append(QString::number(s) + " B");
                else if(s <= 1024*1024)
                    ret.append(QString::number(qRound(10.0*(s/1024.0))/10.0) + " KB");
                else
                    ret.append(QString::number(qRound(100.0*(s/(1024.0*1024.0)))/100.0) + " MB");
            }
        } else if(filter != "") {
            for(QFileInfo l : list) {
                QString fn = l.fileName().trimmed();
                if(!fn.contains(filter) || fn == "") continue;
                ret.append(fn);
                qint64 s = l.size();
                if(s <= 1024)
                    ret.append(QString::number(s) + " B");
                else if(s <= 1024*1024)
                    ret.append(QString::number(qRound(10.0*(s/1024.0))/10.0) + " KB");
                else
                    ret.append(QString::number(qRound(100.0*(s/(1024.0*1024.0)))/100.0) + " MB");
            }
        } else {
            for(QFileInfo l : list) {
                QString fn = l.fileName().trimmed();
                if(fn == "") continue;
                ret.append(fn);
                qint64 s = l.size();
                if(s <= 1024)
                    ret.append(QString::number(s) + " B");
                else if(s <= 1024*1024)
                    ret.append(QString::number(qRound(10.0*(s/1024.0))/10.0) + " KB");
                else
                    ret.append(QString::number(qRound(100.0*(s/(1024.0*1024.0)))/100.0) + " MB");
            }
        }

    } else {

        if(filter.startsWith(".")) {
            for(QFileInfo l : list) {
                QString fn = l.fileName().trimmed();
                if(fn.endsWith(filter) && fn != "") {
                    bool pdfloaded = (loadSinglePdf &&
                                        (imageformats->getEnabledFileformatsPoppler().contains("*."+QFileInfo(fn).suffix()) ||
                                         mimetypes->getEnabledMimeTypesPoppler().contains(mimedb.mimeTypeForFile(l.absoluteFilePath(), QMimeDatabase::MatchContent).name())));
                    bool archiveloaded = (loadSingleArchive &&
                                        (imageformats->getEnabledFileformatsArchive().contains("*."+QFileInfo(fn).suffix()) ||
                                         mimetypes->getEnabledMimeTypesArchive().contains(mimedb.mimeTypeForFile(l.absoluteFilePath(), QMimeDatabase::MatchContent).name())));
#ifdef POPPLER
                    if(pdfLoadAllPages && !loadSinglePdf) {
                        if(imageformats->getEnabledFileformatsPoppler().contains("*."+QFileInfo(fn).suffix()) ||
                           mimetypes->getEnabledMimeTypesPoppler().contains(mimedb.mimeTypeForFile(l.absoluteFilePath(), QMimeDatabase::MatchContent).name())) {
                            loadAllPdfPages(l, &ret);
                            pdfloaded = true;
                        }
                    }
#endif
                    if(archiveLoadAllFiles && !loadSingleArchive) {
                        if(imageformats->getEnabledFileformatsArchive().contains("*."+QFileInfo(fn).suffix()) ||
                           mimetypes->getEnabledMimeTypesArchive().contains(mimedb.mimeTypeForFile(l.absoluteFilePath(), QMimeDatabase::MatchContent).name())) {
                            loadAllArchiveFiles(l, &ret, archiveUseExternalUnrar);
                            archiveloaded = true;
                        }
                    }
                    if(!pdfloaded && !archiveloaded)
                        ret.append(fn);
                }
            }
        } else if(filter != "") {
            for(QFileInfo l : list) {
                QString fn = l.fileName().trimmed();
                if(fn.contains(filter) && fn != "") {
                    bool pdfloaded = (loadSinglePdf &&
                                        (imageformats->getEnabledFileformatsPoppler().contains("*."+QFileInfo(fn).suffix()) ||
                                         mimetypes->getEnabledMimeTypesPoppler().contains(mimedb.mimeTypeForFile(l.absoluteFilePath(), QMimeDatabase::MatchContent).name())));
                    bool archiveloaded = (loadSingleArchive &&
                                        (imageformats->getEnabledFileformatsArchive().contains("*."+QFileInfo(fn).suffix()) ||
                                         mimetypes->getEnabledMimeTypesArchive().contains(mimedb.mimeTypeForFile(l.absoluteFilePath(), QMimeDatabase::MatchContent).name())));
#ifdef POPPLER
                    if(pdfLoadAllPages && !loadSinglePdf) {
                        if(imageformats->getEnabledFileformatsPoppler().contains("*."+QFileInfo(fn).suffix()) ||
                           mimetypes->getEnabledMimeTypesPoppler().contains(mimedb.mimeTypeForFile(l.absoluteFilePath(), QMimeDatabase::MatchContent).name())) {
                            loadAllPdfPages(l, &ret);
                            pdfloaded = true;
                        }
                    }
#endif
                    if(archiveLoadAllFiles && !loadSingleArchive) {
                        if(imageformats->getEnabledFileformatsArchive().contains("*."+QFileInfo(fn).suffix()) ||
                           mimetypes->getEnabledMimeTypesArchive().contains(mimedb.mimeTypeForFile(l.absoluteFilePath(), QMimeDatabase::MatchContent).name())) {
                            loadAllArchiveFiles(l, &ret, archiveUseExternalUnrar);
                            archiveloaded = true;
                        }
                    }
                    if(!pdfloaded && !archiveloaded)
                        ret.append(fn);
                }
            }
        } else {
            for(QFileInfo l : list) {
                QString fn = l.fileName().trimmed();
                if(fn != "") {
                    bool pdfloaded = (loadSinglePdf &&
                                        (imageformats->getEnabledFileformatsPoppler().contains("*."+QFileInfo(fn).suffix()) ||
                                         mimetypes->getEnabledMimeTypesPoppler().contains(mimedb.mimeTypeForFile(l.absoluteFilePath(), QMimeDatabase::MatchContent).name())));
                    bool archiveloaded = (loadSingleArchive &&
                                        (imageformats->getEnabledFileformatsArchive().contains("*."+QFileInfo(fn).suffix()) ||
                                         mimetypes->getEnabledMimeTypesArchive().contains(mimedb.mimeTypeForFile(l.absoluteFilePath(), QMimeDatabase::MatchContent).name())));
#ifdef POPPLER
                    if(pdfLoadAllPages && !loadSinglePdf) {
                        if(imageformats->getEnabledFileformatsPoppler().contains("*."+QFileInfo(fn).suffix()) ||
                           mimetypes->getEnabledMimeTypesPoppler().contains(mimedb.mimeTypeForFile(l.absoluteFilePath(), QMimeDatabase::MatchContent).name())) {
                            loadAllPdfPages(l, &ret);
                            pdfloaded = true;
                        }
                    }
#endif
                    if(archiveLoadAllFiles && !loadSingleArchive) {
                        if(imageformats->getEnabledFileformatsArchive().contains("*."+QFileInfo(fn).suffix()) ||
                           mimetypes->getEnabledMimeTypesArchive().contains(mimedb.mimeTypeForFile(l.absoluteFilePath(), QMimeDatabase::MatchContent).name())) {
                            loadAllArchiveFiles(l, &ret, archiveUseExternalUnrar);
                            archiveloaded = true;
                        }
                    }
                    if(!pdfloaded && !archiveloaded)
                        ret.append(fn);
                }
            }
        }

    }

    return ret;

}

void GetAndDoStuffListFiles::loadAllArchiveFiles(QFileInfo l, QVariantList *list, bool archiveUseExternalUnrar) {

    QProcess which;
    which.setStandardOutputFile(QProcess::nullDevice());
    which.start("which unrar");
    which.waitForFinished();

    if(!which.exitCode() && archiveUseExternalUnrar &&
       (l.suffix() == "cbr" || l.suffix() == "rar" || mimedb.mimeTypeForFile(l.absoluteFilePath()).name() == "application/vnd.rar")) {

        QProcess p;
        p.start(QString("unrar lb \"%1\"").arg(l.absoluteFilePath()));

        if(p.waitForStarted()) {

            QByteArray outdata = "";

            while(p.waitForReadyRead())
                outdata.append(p.readAll());

            QStringList allfiles = QString::fromLatin1(outdata).split('\n', QString::SkipEmptyParts);
            allfiles.sort();
            foreach(QString f, allfiles) {
                if((imageformats->getEnabledFileformatsQt().contains("*." + QFileInfo(f).suffix()) ||
                    mimetypes->getEnabledMimeTypesQt().contains(mimedb.mimeTypeForFile(f, QMimeDatabase::MatchExtension).name())))
                    list->append(QString("::ARCHIVE1::%1::ARCHIVE2::%2.%3").arg(l.absoluteFilePath()).arg(f).arg(l.suffix()));
            }


        }

    } else {

        // Create new archive handler
        struct archive *a = archive_read_new();

        // We allow any type of compression and format
        archive_read_support_filter_all(a);
        archive_read_support_format_all(a);

        // Read file
        int r = archive_read_open_filename(a, l.absoluteFilePath().toLatin1(), 10240);

        // If something went wrong, output error message and stop here
        if(r != ARCHIVE_OK) {
            LOG << CURDATE << "GetAndDoStuffListFiles::loadAllArchiveFiles(): ERROR: archive_read_open_filename() returned code of " << r << NL;
            return;
        }

        // Loop over entries in archive
        struct archive_entry *entry;
        QStringList allfiles;
        while(archive_read_next_header(a, &entry) == ARCHIVE_OK) {

            // Read the current file entry
            QString filenameinside = QString::fromStdString(archive_entry_pathname(entry));

            // If supported file format, append to temporary list
            if((imageformats->getEnabledFileformatsQt().contains("*." + QFileInfo(filenameinside).suffix()) ||
                mimetypes->getEnabledMimeTypesQt().contains(mimedb.mimeTypeForFile(filenameinside, QMimeDatabase::MatchExtension).name())))
                allfiles.append(filenameinside);

        }

        // Sort the temporary list and add to global list
        allfiles.sort();
        foreach(QString f, allfiles)
            list->append(QString("::ARCHIVE1::%1::ARCHIVE2::%2.%3").arg(l.absoluteFilePath()).arg(f).arg(l.suffix()));

        // Close archive
        r = archive_read_free(a);
        if(r != ARCHIVE_OK)
            LOG << CURDATE << "GetAndDoStuffListFiles::loadAllArchiveFiles(): ERROR: archive_read_free() returned code of " << r << NL;

    }

}

bool GetAndDoStuffListFiles::loadOnlyArchiveFiles(QString file, QVariantList *list, bool archiveUseExternalUnrar) {
    if(imageformats->getEnabledFileformatsArchive().contains("*."+QFileInfo(file).suffix().toLower()) || mimetypes->getEnabledMimeTypesArchive().contains(mimedb.mimeTypeForFile(file, QMimeDatabase::MatchContent).name())) {
        loadAllArchiveFiles(QFileInfo(file), list, archiveUseExternalUnrar);
        if(list->length() == 0) {
            LOG << "GetAndDoStuffListFiles::loadOnlyArchiveFiles(): ERROR: Invalid/Empty archive file, no files found" << NL;
            list->append("::ARCHIVE1::nothingfound.zip::ARCHIVE2::emptyorinvalid.zip");
        }
        return true;
    }
    return false;
}

void GetAndDoStuffListFiles::loadAllPdfPages(QFileInfo l, QVariantList *list) {

#ifdef POPPLER
    Poppler::Document* document = Poppler::Document::load(l.absoluteFilePath());
    if(document && !document->isLocked()) {
        int numPages = document->numPages();
        for(int i = 0; i < numPages; ++i)
            list->append(QString("::PQT1::%1::%2::PQT2::%3").arg(i).arg(numPages).arg(l.fileName()));
    }
    delete document;
#endif

}

bool GetAndDoStuffListFiles::loadOnlyPdfPages(QString file, QVariantList *list) {
    if(imageformats->getEnabledFileformatsPoppler().contains("*."+QFileInfo(file).suffix().toLower()) || mimetypes->getEnabledMimeTypesPoppler().contains(mimedb.mimeTypeForFile(file, QMimeDatabase::MatchContent).name())) {
        loadAllPdfPages(QFileInfo(file), list);
        if(list->length() == 0) {
            LOG << "GetAndDoStuffListFiles::loadOnlyPdfPages(): ERROR: Invalid PDF, no pages found" << NL;
            list->append(file);
        }
        return true;
    }
    return false;
}

QFileInfoList GetAndDoStuffListFiles::getEntryList(QString file, QString categoryFileTypes, bool showHidden) {

    QFileInfo info(file);

    QDir dir;
    if(info.isDir())
        dir.setPath(file);
    else
        dir.setPath(info.absolutePath());

    if(showHidden)
        dir.setFilter(QDir::Files|QDir::Hidden);
    else
        dir.setFilter(QDir::Files);
    dir.setSorting(QDir::IgnoreCase);

    QFileInfoList entrylist = dir.entryInfoList();

    if(categoryFileTypes == "allfiles") {
        if(!entrylist.contains(info) && !info.isDir() && !file.endsWith(".pdf") && !file.endsWith(".epdf"))
            entrylist.append(info);
        return entrylist;
    }

    QStringList checkForTheseFormats;
    QStringList checkForTheseMimeTypes;
    if(categoryFileTypes == "all") {
        checkForTheseFormats = imageformats->getAllEnabledFileformats();
        checkForTheseMimeTypes = mimetypes->getAllEnabledMimeTypes();
    } else if(categoryFileTypes == "qt") {
        checkForTheseFormats = imageformats->getEnabledFileformatsQt();
        checkForTheseMimeTypes = mimetypes->getEnabledMimeTypesQt();
    } else if(categoryFileTypes == "gm") {
        checkForTheseFormats = imageformats->getEnabledFileformatsGm()+imageformats->getEnabledFileformatsGmGhostscript();
        checkForTheseMimeTypes = mimetypes->getEnabledMimeTypesGm()+mimetypes->getEnabledMimeTypesGmGhostscript();
    } else if(categoryFileTypes == "raw") {
        checkForTheseFormats = imageformats->getEnabledFileformatsRAW();
        checkForTheseMimeTypes = mimetypes->getEnabledMimeTypesRAW();
    } else if(categoryFileTypes == "devil") {
        checkForTheseFormats = imageformats->getEnabledFileformatsDevIL();
        checkForTheseMimeTypes = mimetypes->getEnabledMimeTypesDevIL();
    } else if(categoryFileTypes == "freeimage") {
        checkForTheseFormats = imageformats->getEnabledFileformatsFreeImage();
        checkForTheseMimeTypes = mimetypes->getEnabledMimeTypesFreeImage();
    } else if(categoryFileTypes == "poppler") {
        checkForTheseFormats = imageformats->getEnabledFileformatsPoppler();
        checkForTheseMimeTypes = mimetypes->getEnabledMimeTypesPoppler();
    } else if(categoryFileTypes == "archive") {
        checkForTheseFormats = imageformats->getEnabledFileformatsArchive();
        checkForTheseMimeTypes = mimetypes->getEnabledMimeTypesArchive();
    }

    QFileInfoList retlist;

    if(checkForTheseMimeTypes.length() > 0) {
        foreach(QFileInfo entry, entrylist) {
            if(checkForTheseFormats.contains("*." + entry.suffix().toLower()))
                retlist.append(entry);
            else if(checkForTheseMimeTypes.contains(mimedb.mimeTypeForFile(entry.absoluteFilePath(), QMimeDatabase::MatchContent).name()))
                retlist.append(entry);
        }
    } else {
        foreach(QFileInfo entry, entrylist) {
            if(checkForTheseFormats.contains("*." + entry.suffix().toLower()))
                retlist.append(entry);
        }
    }
    qApp->processEvents();

    if(!retlist.contains(info) && !info.isDir() && !imageformats->getEnabledFileformatsPoppler().contains("*."+QFileInfo(file).suffix()) && !mimetypes->getEnabledMimeTypesPoppler().contains(mimedb.mimeTypeForFile(info.absoluteFilePath(), QMimeDatabase::MatchContent).name()))
        retlist.append(info);

    return retlist;

}

int GetAndDoStuffListFiles::getTotalNumberOfPagesOfPdf(QString file) {

    int totalpage = -1;
#ifdef POPPLER
    Poppler::Document* document = Poppler::Document::load(file);
    if(document && !document->isLocked())
        totalpage = document->numPages();
    delete document;
#endif
    return totalpage;

}
