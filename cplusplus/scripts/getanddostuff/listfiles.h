#ifndef LISTFILES_H
#define LISTFILES_H

#include <QObject>
#include "../../settings/imageformats.h"
#include "../../settings/mimetypes.h"
#ifdef POPPLER
#include <poppler/qt5/poppler-qt5.h>
#endif

#include <QMimeDatabase>

class GetAndDoStuffListFiles : public QObject {

public:
    GetAndDoStuffListFiles(QObject *parent = 0);
    ~GetAndDoStuffListFiles();

    QVariantList getAllFilesIn(QString file, QString categoryFileTypes, QString filter, bool showHidden, QString sortby, bool sortbyAscending, bool includeSize, bool pdfLoadAllPage, bool loadSinglePdf);

    int getTotalNumberOfPagesOfPdf(QString file);

private:
    ImageFormats *imageformats;
    MimeTypes *mimetypes;
    void loadAllPdfPages(QFileInfo l, QVariantList *list);
    bool loadOnlyPdfPages(QString file, QVariantList *list);
    QFileInfoList getEntryList(QString file, QString categoryFileTypes, bool showHidden);

};


#endif
