#include "loaddir.h"

LoadDir::LoadDir(bool verbose) : QObject() {
    this->verbose = verbose;
    settings = new Settings;
    fileformats = new FileFormats(verbose);
}

LoadDir::~LoadDir() {
    delete settings;
    delete fileformats;
}

QFileInfoList LoadDir::loadDir(QString filepath, QString filter) {

    if(verbose)
        LOG << CURDATE << "LoadDir::loadDir(): Loading filepath '" << filepath.toStdString() << "'" << NL;

    QDir dir(QFileInfo(filepath).absolutePath());

    // Set appropriate filter
    if(filter.trimmed() == "") {
        // These are the images known by PhotoQt
        QStringList flt1 = fileformats->formats_qt+fileformats->formats_gm+fileformats->formats_gm_ghostscript +
                           fileformats->formats_extras+fileformats->formats_untested+fileformats->formats_raw;
        QStringList flt2 = flt1;
        for(int i = 0; i < flt2.length(); ++i)
            flt2[i] = flt2.at(i).toUpper();
        dir.setNameFilters(flt1+flt2);
    } else {
        if(verbose)
            LOG << CURDATE << "LoadDir::loaddir(): Filter set: '" << filter.toStdString() << "'" << NL;
        QStringList new_flt;
        foreach(QString f, filter.split(" ")) {
            if(f.startsWith("."))
                new_flt.append("*" + f);
            else
                new_flt.append("*" + f + "*");
        }
        dir.setNameFilters(new_flt);
    }

    // Store a QFileInfoList and a QStringList with the filenames
    allImgsInfo.clear();
    allImgsInfo = dir.entryInfoList(QDir::Files,QDir::IgnoreCase);

    // When opening an unknown file (i.e., one that doesn't match any set format), then we need to manually add it to the list of loaded images
    if(!allImgsInfo.contains(QFileInfo(filepath))) {
        if(filter.trimmed() == "")
            allImgsInfo.append(QFileInfo(filepath));
        else if(allImgsInfo.length() > 0)
            filepath = allImgsInfo.at(0).filePath();
        else
            return QFileInfoList();
    }

    // Sort images...
    sortList(&allImgsInfo, settings->sortby, settings->sortbyAscending);

    return allImgsInfo;

}

void LoadDir::sortList(QFileInfoList *list, QString sortby, bool sortbyAscending) {

    QCollator collator;
    collator.setCaseSensitivity(Qt::CaseInsensitive);
    collator.setIgnorePunctuation(true);

    if(sortby == "name") {

        collator.setNumericMode(false);

        if(sortbyAscending)
            std::sort(list->begin(), list->end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(file1.fileName(),
                                        file2.fileName()) < 0;
            });
        else
            std::sort(list->rbegin(), list->rend(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(file1.fileName(),
                                        file2.fileName()) < 0;
            });

    } else if(sortby == "naturalname") {

        collator.setNumericMode(true);

        if(sortbyAscending)
            std::sort(list->begin(), list->end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(file1.fileName(),
                                        file2.fileName()) < 0;
            });
        else
            std::sort(list->rbegin(), list->rend(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(file1.fileName(),
                                        file2.fileName()) < 0;
            });

    } else if(sortby == "date") {

        collator.setNumericMode(true);

#if (QT_VERSION >= QT_VERSION_CHECK(5, 10, 0))

        if(sortbyAscending)
            std::sort(list->begin(), list->end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(QString::number(file1.metadataChangeTime().toMSecsSinceEpoch()),
                                        QString::number(file2.metadataChangeTime().toMSecsSinceEpoch())) < 0;
            });
        else
            std::sort(list->rbegin(), list->rend(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(QString::number(file1.metadataChangeTime().toMSecsSinceEpoch()),
                                        QString::number(file2.metadataChangeTime().toMSecsSinceEpoch())) < 0;
            });

#else

        if(sortbyAscending)
            std::sort(list->begin(), list->end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(QString::number(file1.created().toMSecsSinceEpoch()),
                                        QString::number(file2.created().toMSecsSinceEpoch())) < 0;
            });
        else
            std::sort(list->rbegin(), list->rend(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(QString::number(file1.created().toMSecsSinceEpoch()),
                                        QString::number(file2.created().toMSecsSinceEpoch())) < 0;
            });

#endif

    } else if(sortby == "size") {

        collator.setNumericMode(true);

        if(sortbyAscending)
            std::sort(list->begin(), list->end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(QString::number(file1.size()),
                                        QString::number(file2.size())) < 0;
            });
        else
            std::sort(list->rbegin(), list->rend(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(QString::number(file1.size()),
                                        QString::number(file2.size())) < 0;
            });

    }


}
