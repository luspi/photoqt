#ifndef SORTLIST_H
#define SORTLIST_H

#include <QCollator>
#include <QDateTime>

namespace Sort {

    static void sortList(QFileInfoList *list, QString sortby, bool sortbyAscending) {

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

        } else { // default to naturalname

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

        }

    }

}

#endif // SORTLIST_H
