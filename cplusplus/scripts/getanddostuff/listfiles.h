#ifndef LISTFILES_H
#define LISTFILES_H

#include <QObject>
#include "../../settings/imageformats.h"
#include <poppler/qt5/poppler-qt5.h>

class GetAndDoStuffListFiles : public QObject {

public:
    GetAndDoStuffListFiles(QObject *parent = 0);
    ~GetAndDoStuffListFiles();

    QVariantList getAllFilesIn(QString file, int selectionFileTypes, QString filter, bool showHidden, QString sortby, bool sortbyAscending, bool includeSize, bool pdfLoadAllPage, bool loadSinglePdf);

    int getTotalNumberOfPagesOfPdf(QString file);

private:
    ImageFormats *imageformats;
    void loadAllPdfPages(QFileInfo l, QVariantList *list);
    bool loadOnlyPdfPages(QString file, QVariantList *list);
    QFileInfoList getEntryList(QString file, int selectionFileTypes, bool showHidden);

};


#endif
