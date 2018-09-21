#include "sortlist.h"

void Sort::list(QFileInfoList *list, QString sortby, bool sortbyAscending) {

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
            std::sort(list->begin(), list->end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(file2.fileName(),
                                        file1.fileName()) < 0;
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

#else // Qt < 5.10

        if(sortbyAscending)
            std::sort(list->begin(), list->end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(QString::number(file1.created().toMSecsSinceEpoch()),
                                        QString::number(file2.created().toMSecsSinceEpoch())) < 0;
            });
        else
            std::sort(list->begin(), list->end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(QString::number(file2.created().toMSecsSinceEpoch()),
                                        QString::number(file1.created().toMSecsSinceEpoch())) < 0;
            });

#endif // (QT_VERSION >= QT_VERSION_CHECK(5, 10, 0))

    } else if(sortby == "datemodified") {

        collator.setNumericMode(true);

        if(sortbyAscending)
            std::sort(list->begin(), list->end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(QString::number(file1.lastModified().toMSecsSinceEpoch()),
                                        QString::number(file2.lastModified().toMSecsSinceEpoch())) < 0;
            });
        else
            std::sort(list->rbegin(), list->rend(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(QString::number(file1.lastModified().toMSecsSinceEpoch()),
                                        QString::number(file2.lastModified().toMSecsSinceEpoch())) < 0;
            });

#ifdef EXIV2

    } else if(sortby == "dateexif") {

        // This MultiHash will hold all the fileinfo with their timestamp as key. As it is (in theory) possible for more than one item to have the exact same timestamp, we need to use a multihash
        QMultiHash<QDateTime, QFileInfo> alldata;
        // While adding items to the hash, we add the key also to this list, but only if the key is not already in it (avoids duplicate entries)
        QList<QDateTime> allkeys;

        // Look at all files
        for(QFileInfo info : *list) {

            if(info.exists()) {

                // Get exif data
                Exiv2::Image::AutoPtr image;
                try {
                    image = Exiv2::ImageFactory::open(info.absoluteFilePath().toStdString());
                    safelyReadMetadata(&image);

                    // Find the exif timestamp
                    Exiv2::ExifData data = image->exifData();
                    Exiv2::ExifData::const_iterator iter = data.findKey(Exiv2::ExifKey("Exif.Image.DateTime"));

                    // If there is a timestamp, use it, otherwise we use the fileinfo timestamp
                    QDateTime dt;
                    if(iter != data.end())
                        dt = QDateTime::fromString(QString::fromStdString(iter->value().toString()), "yyyy:MM:dd HH:mm:ss");
                    else
                        dt = info.metadataChangeTime();

                    // Store data, keep track of all keys
                    alldata.insert(dt, info);
                    if(!allkeys.contains(dt))
                        allkeys.append(dt);

                } catch(Exiv2::Error &e) {

                    LOG << CURDATE << "Sort::list() [1] Unable to read Exif metadata: " << e << " (" << Exiv2::errMsg(e.code()) << ")" << NL;

                    // If something went wrong, we use the fileinfo timestamp
                    QDateTime dt = info.metadataChangeTime();
                    alldata.insert(dt, info);
                    if(!allkeys.contains(dt))
                        allkeys.append(dt);
                }

            } else {

                // If the file does not exist or cannot be found, we set an arbitrary early datetime
                QDateTime dt;
                dt.setMSecsSinceEpoch(0);
                alldata.insert(dt, info);
                if(!allkeys.contains(dt))
                    allkeys.append(dt);

            }

        }

        // Sort all the keys
        if(sortbyAscending)
            std::sort(allkeys.begin(), allkeys.end(), [](const QDateTime &dt1, const QDateTime &dt2) {
                return dt1 < dt2;
            });
        else
            std::sort(allkeys.begin(), allkeys.end(), [](const QDateTime &dt1, const QDateTime &dt2) {
                return dt2 < dt1;
            });

        // This will hold the result
        QFileInfoList ret;

        // Loop over sorted keys
        for(QDateTime dt : allkeys) {

            // Get the fileinfos with the current timestamp (can be multiple ones)
            QList<QFileInfo> vals = alldata.values(dt);

            // If there is more than one with the exact same timestamp, then we sort the entries by 'natural name'
            if(vals.length() > 1) {

                collator.setNumericMode(true);

                if(sortbyAscending)
                    std::sort(vals.begin(), vals.end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                        return collator.compare(file1.fileName(),
                                                file2.fileName()) < 0;
                    });
                else
                    std::sort(vals.begin(), vals.end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                        return collator.compare(file2.fileName(),
                                                file1.fileName()) < 0;
                    });
            }

            // Append current fileinfos to result list
            ret += vals;

        }

        // As we could not do all of this in place, we have to replace the original list with our sorted one
        *list = ret;

#endif

    } else if(sortby == "size") {

        collator.setNumericMode(true);

        if(sortbyAscending)
            std::sort(list->begin(), list->end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(QString::number(file1.size()),
                                        QString::number(file2.size())) < 0;
            });
        else
            std::sort(list->begin(), list->end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(QString::number(file2.size()),
                                        QString::number(file1.size())) < 0;
            });

    } else { // default to naturalname

        collator.setNumericMode(true);

        if(sortbyAscending)
            std::sort(list->begin(), list->end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(file1.fileName(),
                                        file2.fileName()) < 0;
            });
        else
            std::sort(list->begin(), list->end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(file2.fileName(),
                                        file1.fileName()) < 0;
            });

    }

}

void Sort::list(QVariantList *list, QString sortby, bool sortbyAscending) {

    QCollator collator;
    collator.setCaseSensitivity(Qt::CaseInsensitive);
    collator.setIgnorePunctuation(true);

    if(sortby == "name") {

        collator.setNumericMode(false);

        if(sortbyAscending)
            std::sort(list->begin(), list->end(), [&collator](const QVariant &file1, const QVariant &file2) {
                return collator.compare(file1.toString(),
                                        file2.toString()) < 0;
            });
        else
            std::sort(list->begin(), list->end(), [&collator](const QVariant &file1, const QVariant &file2) {
                return collator.compare(file2.toString(),
                                        file1.toString()) < 0;
            });

    } else if(sortby == "date") {

        collator.setNumericMode(true);

#if (QT_VERSION >= QT_VERSION_CHECK(5, 10, 0))

        if(sortbyAscending)
            std::sort(list->begin(), list->end(), [&collator](const QVariant &file1, const QVariant &file2) {
                return collator.compare(QString::number(QFileInfo(file1.toString()).metadataChangeTime().toMSecsSinceEpoch()),
                                        QString::number(QFileInfo(file2.toString()).metadataChangeTime().toMSecsSinceEpoch())) < 0;
            });
        else
            std::sort(list->rbegin(), list->rend(), [&collator](const QVariant &file1, const QVariant &file2) {
                return collator.compare(QString::number(QFileInfo(file1.toString()).metadataChangeTime().toMSecsSinceEpoch()),
                                        QString::number(QFileInfo(file2.toString()).metadataChangeTime().toMSecsSinceEpoch())) < 0;
            });

#else // Qt < 5.10

        if(sortbyAscending)
            std::sort(list->begin(), list->end(), [&collator](const QVariant &file1, const QVariant &file2) {
                return collator.compare(QString::number(QFileInfo(file1.toString()).created().toMSecsSinceEpoch()),
                                        QString::number(QFileInfo(file2.toString()).created().toMSecsSinceEpoch())) < 0;
            });
        else
            std::sort(list->begin(), list->end(), [&collator](const QVariant &file1, const QVariant &file2) {
                return collator.compare(QString::number(QFileInfo(file2.toString()).created().toMSecsSinceEpoch()),
                                        QString::number(QFileInfo(file1.toString()).created().toMSecsSinceEpoch())) < 0;
            });

#endif // (QT_VERSION >= QT_VERSION_CHECK(5, 10, 0))

    } else if(sortby == "datemodified") {

        if(sortbyAscending)
            std::sort(list->begin(), list->end(), [&collator](const QVariant &file1, const QVariant &file2) {
                return collator.compare(QString::number(QFileInfo(file1.toString()).lastModified().toMSecsSinceEpoch()),
                                        QString::number(QFileInfo(file2.toString()).lastModified().toMSecsSinceEpoch())) < 0;
            });
        else
            std::sort(list->rbegin(), list->rend(), [&collator](const QVariant &file1, const QVariant &file2) {
                return collator.compare(QString::number(QFileInfo(file1.toString()).lastModified().toMSecsSinceEpoch()),
                                        QString::number(QFileInfo(file2.toString()).lastModified().toMSecsSinceEpoch())) < 0;
            });

#ifdef EXIV2

    } else if(sortby == "dateexif") {

        // This MultiHash will hold all the variants with their timestamp as key. As it is (in theory) possible for more than one item to have the exact same timestamp, we need to use a multihash
        QMultiHash<QDateTime, QVariant> alldata;
        // While adding items to the hash, we add the key also to this list, but only if the key is not already in it (avoids duplicate entries)
        QList<QDateTime> allkeys;

        // Look at all files
        for(QVariant path_ : *list) {

            QString path = path_.toString();

            if(QFileInfo(path).exists()) {

                // Get exif data
                Exiv2::Image::AutoPtr image;
                try {
                    image = Exiv2::ImageFactory::open(path.toStdString());
                    safelyReadMetadata(&image);

                    // Find the exif timestamp
                    Exiv2::ExifData data = image->exifData();
                    Exiv2::ExifData::const_iterator iter = data.findKey(Exiv2::ExifKey("Exif.Image.DateTime"));

                    // If there is a timestamp, use it, otherwise we use the fileinfo timestamp
                    QDateTime dt;
                    if(iter != data.end())
                        dt = QDateTime::fromString(QString::fromStdString(iter->value().toString()), "yyyy:MM:dd HH:mm:ss");
                    else
                        dt = QFileInfo(path).metadataChangeTime();

                    // Store data, keep track of all keys
                    alldata.insert(dt, path_);
                    if(!allkeys.contains(dt))
                        allkeys.append(dt);

                } catch(Exiv2::Error &e) {

                    LOG << CURDATE << "Sort::list() [2] Unable to read Exif metadata: " << e << " (" << Exiv2::errMsg(e.code()) << ")" << NL;

                    // If something went wrong, we use the fileinfo timestamp
                    QDateTime dt = QFileInfo(path).metadataChangeTime();
                    alldata.insert(dt, path_);
                    if(!allkeys.contains(dt))
                        allkeys.append(dt);
                }

            } else {

                // If the file does not exist or cannot be found, we set an arbitrary early datetime
                QDateTime dt;
                dt.setMSecsSinceEpoch(0);
                alldata.insert(dt, path_);
                if(!allkeys.contains(dt))
                    allkeys.append(dt);

            }

        }

        // Sort all the keys
        if(sortbyAscending)
            std::sort(allkeys.begin(), allkeys.end(), [](const QDateTime &dt1, const QDateTime &dt2) {
                return dt1 < dt2;
            });
        else
            std::sort(allkeys.begin(), allkeys.end(), [](const QDateTime &dt1, const QDateTime &dt2) {
                return dt2 < dt1;
            });

        // This will hold the result
        QVariantList ret;

        // Loop over sorted keys
        for(QDateTime dt : allkeys) {

            // Get the variants with the current timestamp (can be multiple ones)
            QList<QVariant> vals = alldata.values(dt);

            // If there is more than one with the exact same timestamp, then we sort the entries by 'natural name'
            if(vals.length() > 1) {

                collator.setNumericMode(true);

                if(sortbyAscending)
                    std::sort(vals.begin(), vals.end(), [&collator](const QVariant &file1, const QVariant &file2) {
                        return collator.compare(file1.toString(),
                                                file2.toString()) < 0;
                    });
                else
                    std::sort(vals.begin(), vals.end(), [&collator](const QVariant &file1, const QVariant &file2) {
                        return collator.compare(file2.toString(),
                                                file1.toString()) < 0;
                    });

            }

            // Append current variants to result list
            ret += vals;

        }

        // As we could not do all of this in place, we have to replace the original list with our sorted one
        *list = ret;

#endif

    } else if(sortby == "size") {

        collator.setNumericMode(true);

        if(sortbyAscending)
            std::sort(list->begin(), list->end(), [&collator](const QVariant &file1, const QVariant &file2) {
                return collator.compare(QString::number(QFileInfo(file1.toString()).size()),
                                        QString::number(QFileInfo(file2.toString()).size())) < 0;
            });
        else
            std::sort(list->begin(), list->end(), [&collator](const QVariant &file1, const QVariant &file2) {
                return collator.compare(QString::number(QFileInfo(file2.toString()).size()),
                                        QString::number(QFileInfo(file1.toString()).size())) < 0;
            });

    } else { // default to naturalname

        collator.setNumericMode(true);

        if(sortbyAscending)
            std::sort(list->begin(), list->end(), [&collator](const QVariant &file1, const QVariant &file2) {
                return collator.compare(file1.toString(),
                                        file2.toString()) < 0;
            });
        else
            std::sort(list->begin(), list->end(), [&collator](const QVariant &file1, const QVariant &file2) {
                return collator.compare(file2.toString(),
                                        file1.toString()) < 0;
            });

    }

}

// The metadata is needed at multiple different locations in the code.
// At least up to v0.26, Exiv2 does not support reading metadata in parallel (causes crashes).
// This function ensures that there is always only at most one call to readMetadata() at any time.
void Sort::safelyReadMetadata(Exiv2::Image::AutoPtr *image) {

    QLockFile lock(ConfigFiles::EXIV2_LOCK_FILE());

    // After 2s we just go ahead, something might have gone wrong.
    if(!lock.tryLock(2000))
        LOG << CURDATE << "GetMetaData::safelyReadMetadata(): WARNING: Unable to lock Exiv2::readMetadata(), potential cause for crash!" << NL;

    (*image)->readMetadata();

    // Free up access
    lock.unlock();

}
