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

GetAndDoStuffListFiles::GetAndDoStuffListFiles(QObject *parent) : QObject(parent) {
    imageformats = new ImageFormats;
}

GetAndDoStuffListFiles::~GetAndDoStuffListFiles() {
    delete imageformats;
}

QVariantList GetAndDoStuffListFiles::getAllFilesIn(QString file, int selectionFileTypes, QString filter, bool showHidden, QString sortby, bool sortbyAscending, bool includeSize, bool pdfLoadAllPage, bool loadSinglePdf) {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "GetAndDoStuffOpenFile::getAllFilesIn() - " << file.toStdString() << " / "
                                                                      << selectionFileTypes << " / "
                                                                      << showHidden << " / "
                                                                      << sortby.toStdString() << " / "
                                                                      << sortbyAscending << NL;

    if(file.startsWith("file:/"))
        file = file.remove(0,6);
#ifdef Q_OS_WIN
    while(file.startsWith("/"))
        file = file.remove(0,1);
#endif

#ifdef POPPLER
    if(loadSinglePdf) {
        QVariantList ret;
        if(loadOnlyPdfPages(file, &ret))
            return ret;
    }
#endif

    QFileInfoList list = getEntryList(file, selectionFileTypes, showHidden);

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
                    bool pdfloaded = false;
#ifdef POPPLER
                    if(pdfLoadAllPage) {
                        for(QString pdf : imageformats->getEnabledFileformatsPoppler()) {
                            if(fn.endsWith(pdf.remove(0,1))) {
                                loadAllPdfPages(l, &ret);
                                pdfloaded = true;
                            }
                        }
                    }
#endif
                    if(!pdfloaded)
                        ret.append(fn);
                }
            }
        } else if(filter != "") {
            for(QFileInfo l : list) {
                QString fn = l.fileName().trimmed();
                if(fn.contains(filter) && fn != "") {
                    bool pdfloaded = false;
#ifdef POPPLER
                    if(pdfLoadAllPage) {
                        for(QString pdf : imageformats->getEnabledFileformatsPoppler()) {
                            if(fn.endsWith(pdf.remove(0,1))) {
                                loadAllPdfPages(l, &ret);
                                pdfloaded = true;
                            }
                        }
                    }
#endif
                    if(!pdfloaded)
                        ret.append(fn);
                }
            }
        } else {
            for(QFileInfo l : list) {
                QString fn = l.fileName().trimmed();
                if(fn != "") {
                    bool pdfloaded = false;
#ifdef POPPLER
                    if(pdfLoadAllPage) {
                        for(QString pdf : imageformats->getEnabledFileformatsPoppler()) {
                            if(fn.endsWith(pdf.remove(0,1))) {
                                loadAllPdfPages(l, &ret);
                                pdfloaded = true;
                            }
                        }
                    }
#endif
                    if(!pdfloaded)
                        ret.append(fn);
                }
            }
        }

    }

    return ret;

}

void GetAndDoStuffListFiles::loadAllPdfPages(QFileInfo l, QVariantList *list) {

#ifdef POPPLER
    Poppler::Document* document = Poppler::Document::load(l.absoluteFilePath());
    if(document && !document->isLocked()) {
        int numPages = document->numPages();
        for(int i = 0; i < numPages; ++i)
            list->append(l.baseName() + QString("__::pqt::__%1__%2.").arg(i).arg(numPages) + l.suffix());
    }
    delete document;
#endif

}

bool GetAndDoStuffListFiles::loadOnlyPdfPages(QString file, QVariantList *list) {
    for(QString pdf : imageformats->getEnabledFileformatsPoppler()) {
        if(file.endsWith(pdf.remove(0,2))) {
            loadAllPdfPages(QFileInfo(file), list);
            if(list->length() == 0) {
                LOG << "GetAndDoStuffListFiles::loadOnlyPdfPages(): ERROR: Invalid PDF, no pages found" << NL;
                list->append("invalidpdf.pdf");
            }
            return true;
        }
    }
    return false;
}

QFileInfoList GetAndDoStuffListFiles::getEntryList(QString file, int selectionFileTypes, bool showHidden) {

    QFileInfo info(file);

    QDir dir;
    if(info.isDir())
        dir.setPath(file);
    else
        dir.setPath(info.absolutePath());

    if(selectionFileTypes == 0)
        dir.setNameFilters(imageformats->getAllEnabledFileformats());
    else if(selectionFileTypes == 1)
        dir.setNameFilters(imageformats->getEnabledFileformatsQt()+imageformats->getEnabledFileformatsKDE());
    else if(selectionFileTypes == 2)
        dir.setNameFilters(imageformats->getEnabledFileformatsGm()+imageformats->getEnabledFileformatsGmGhostscript());
    else if(selectionFileTypes == 3)
        dir.setNameFilters(imageformats->getEnabledFileformatsRAW());
    else if(selectionFileTypes == 4)
        dir.setNameFilters(imageformats->getEnabledFileformatsDevIL());
    else if(selectionFileTypes == 5)
        dir.setNameFilters(QStringList() << "*.*");

    if(showHidden)
        dir.setFilter(QDir::Files|QDir::Hidden);
    else
        dir.setFilter(QDir::Files);
    dir.setSorting(QDir::IgnoreCase);

    QFileInfoList list = dir.entryInfoList();
    if(!list.contains(info) && !info.isDir() && !file.endsWith(".pdf") && !file.endsWith(".epdf"))
        list.append(info);

    return list;

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
