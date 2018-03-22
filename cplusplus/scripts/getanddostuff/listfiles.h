#ifndef LISTFILES_H
#define LISTFILES_H

#include <QObject>
#include "../../settings/imageformats.h"
#include "../../settings/mimetypes.h"
#ifdef POPPLER
#include <poppler/qt5/poppler-qt5.h>
#endif
#ifdef QUAZIP
#include <quazip5/quazip.h>
#endif

#include <QMimeDatabase>

class GetAndDoStuffListFiles : public QObject {

public:
    GetAndDoStuffListFiles(QObject *parent = 0);
    ~GetAndDoStuffListFiles();

    QVariantList getAllFilesIn(QString file, QString categoryFileTypes, QString filter, bool showHidden, QString sortby, bool sortbyAscending, bool includeSize, bool pdfLoadAllPage, bool loadSinglePdf, bool zipLoadAllFiles, bool loadSingleZip);

    int getTotalNumberOfPagesOfPdf(QString file);

private:
    ImageFormats *imageformats;
    MimeTypes *mimetypes;
    QFileInfoList getEntryList(QString file, QString categoryFileTypes, bool showHidden);

    void loadAllPdfPages(QFileInfo l, QVariantList *list);
    bool loadOnlyPdfPages(QString file, QVariantList *list);

    void loadAllZipFiles(QFileInfo l, QVariantList *list);
    bool loadOnlyZipFiles(QString file, QVariantList *list);

};


#endif
