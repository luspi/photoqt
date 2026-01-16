/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
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

#include <pqc_location.h>
#include <pqc_configfiles.h>
#include <scripts/pqc_scriptsmetadata.h>

#include <QFileInfo>
#include <QTimer>
#include <QSqlError>
#include <QSqlQuery>
#include <QCryptographicHash>
#include <QCollator>

#ifdef PQMEXIV2
#include <exiv2/exiv2.hpp>
#endif

PQCLocation::PQCLocation(QObject *parent) : QObject(parent) {

    // connect to database
    db = QSqlDatabase::database("location");

    dbOpened = false;

    QFileInfo infodb(PQCConfigFiles::get().LOCATION_DB());

    if(!infodb.exists()) {
        if(!QFile::copy(":/location.db", PQCConfigFiles::get().LOCATION_DB())) {
            qWarning() << "Unable to create new location database, location caching will be unavailable";
            return;
        } else {
            QFile file(PQCConfigFiles::get().LOCATION_DB());
            file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
        }
    }

    if(!db.open()) {
        qWarning() << "ERROR opening database:" << db.lastError().text();
        qWarning() << "Location caching will be unavailable";
        return;
    }

    dbOpened = true;

    dbCommitTimer = new QTimer();
    dbCommitTimer->setSingleShot(true);
    dbCommitTimer->setInterval(400);
    connect(dbCommitTimer, &QTimer::timeout, this, [=](){
        db.commit();
        dbIsTransaction = false;
        if(db.lastError().text().trimmed().length())
            qCritical() << "ERROR committing database:" << db.lastError().text();
    });

    steps.append(QList<double>() << 0.001 << 16.5);
    steps.append(QList<double>() << 0.005 << 14);
    steps.append(QList<double>() << 0.01 << 13);
    steps.append(QList<double>() << 0.02 << 12);
    steps.append(QList<double>() << 0.05 << 11);
    steps.append(QList<double>() << 0.1 << 10);
    steps.append(QList<double>() << 0.2 << 9);
    steps.append(QList<double>() << 0.5 << 7.5);
    steps.append(QList<double>() << 1 << 6.5);
    steps.append(QList<double>() << 2 << 5.5);
    steps.append(QList<double>() << 4 << 4.5);
    steps.append(QList<double>() << 8 << 3.5);
    steps.append(QList<double>() << 12 << 1);

}

void PQCLocation::storeLocation(const QString path, const QPointF gps) {

    QFileInfo info(path);
    if(!info.exists()) {
        qWarning() << "PQLocation::storePosition(): File does not exist: " << path;
        return;
    }

    dbCommitTimer->stop();

    if(!dbIsTransaction) {
        db.transaction();
        dbIsTransaction = true;
    }

    QSqlQuery query(db);
    query.prepare("REPLACE INTO location (`id`,`folder`,`filename`,`latitude`,`longitude`,`lastmodified`) VALUES (:id, :folder, :fn, :lat, :lon, :mod)");
    query.bindValue(":id", QCryptographicHash::hash(path.toUtf8(),QCryptographicHash::Md5).toHex());
    query.bindValue(":folder", info.absolutePath());
    query.bindValue(":fn", info.fileName());
    query.bindValue(":lat", QString::number(gps.x(), 'f', 8));
    query.bindValue(":lon", QString::number(gps.y(), 'f', 8));
    query.bindValue(":mod", info.lastModified().toSecsSinceEpoch());
    if(!query.exec()) {
        qWarning() << "ERROR inserting/replacing location data:" << query.lastError().text();
        return;
    }

    dbCommitTimer->start();

}

void PQCLocation::scanForLocations(QStringList files) {

    // this happens when, e.g., no folder is loaded at all
    if(files.length() == 0)
        return;

    QFileInfo info(files[0]);

    QString folder = info.absolutePath();

    QMap<QString,int> existing;

    QSqlQuery query(db);
    query.prepare("SELECT `filename`,`lastmodified` FROM `location` WHERE `folder`=:fld");
    query.bindValue(":fld", folder);
    if(!query.exec())
        qDebug() << "ERROR getting existing location data:" << query.lastError().text();
    else {
        while(query.next())
            existing.insert(query.value(0).toString(), query.value(1).toInt());
    }

    query.clear();

#ifdef PQMEXIV2

    db.transaction();

    for(const QString &f : std::as_const(files)) {

        QFileInfo info(f);

        if(!existing.contains(info.fileName()) || existing[info.fileName()] != info.lastModified().toSecsSinceEpoch()) {

#if EXIV2_TEST_VERSION(0, 28, 0)
            Exiv2::Image::UniquePtr image;
#else
            Exiv2::Image::AutoPtr image;
#endif
            try {
                image  = Exiv2::ImageFactory::open(f.toStdString());
                image->readMetadata();
            } catch (Exiv2::Error& e) {
                // An error code of kerFileContainsUnknownImageType (older version: 11) means unknown file type
                // Since we always try to read any file's meta data, this happens a lot
#if EXIV2_TEST_VERSION(0, 28, 0)
                if(e.code() != Exiv2::ErrorCode::kerFileContainsUnknownImageType)
#else
                if(e.code() != 11)
#endif
                    qWarning() << "ERROR reading exiv data (caught exception):" << e.what();
                else
                    qDebug() << "ERROR reading exiv data (caught exception):" << e.what();
                continue;
            }

            Exiv2::ExifData exifData;

            try {
                exifData = image->exifData();
            } catch(Exiv2::Error &e) {
                qDebug() << "ERROR: Unable to read exif metadata:" << e.what();
                continue;
            }

            QString gpsLatRef = "", gpsLat = "", gpsLonRef = "", gpsLon = "";

            try {
                Exiv2::ExifMetadata::const_iterator iter = exifData.findKey(Exiv2::ExifKey("Exif.GPSInfo.GPSLatitudeRef"));
                if(iter != exifData.end())
                    gpsLatRef = QString::fromStdString(Exiv2::toString(iter->value()));

                iter = exifData.findKey(Exiv2::ExifKey("Exif.GPSInfo.GPSLatitude"));
                if(iter != exifData.end())
                    gpsLat = QString::fromStdString(Exiv2::toString(iter->value()));

                iter = exifData.findKey(Exiv2::ExifKey("Exif.GPSInfo.GPSLongitudeRef"));
                if(iter != exifData.end())
                    gpsLonRef = QString::fromStdString(Exiv2::toString(iter->value()));

                iter = exifData.findKey(Exiv2::ExifKey("Exif.GPSInfo.GPSLongitude"));
                if(iter != exifData.end())
                    gpsLon = QString::fromStdString(Exiv2::toString(iter->value()));
            } catch(Exiv2::Error &) {
                // ignore exception -> most likely thrown as key does not exist
            }

            if(gpsLatRef != "" && gpsLat != "" && gpsLonRef != "" && gpsLon != "") {
                QPointF gps = PQCScriptsMetaData::get().convertGPSToDecimal(gpsLatRef, gpsLat, gpsLonRef, gpsLon);

                QSqlQuery querynew(db);
                querynew.prepare("REPLACE INTO `location` (`id`,`folder`,`filename`,`latitude`,`longitude`,`lastmodified`) VALUES (:id, :fld, :fn, :lat, :lon, :mod)");
                querynew.bindValue(":id", QCryptographicHash::hash(f.toUtf8(),QCryptographicHash::Md5).toHex());
                querynew.bindValue(":fld", info.absolutePath());
                querynew.bindValue(":fn", info.fileName());
                querynew.bindValue(":lat", QString::number(gps.x(), 'f', 8));
                querynew.bindValue(":lon", QString::number(gps.y(), 'f', 8));
                querynew.bindValue(":mod", info.lastModified().toSecsSinceEpoch());
                if(!querynew.exec())
                    qWarning() << "ERROR inserting new data:" << querynew.lastError().text();

            }

        }

    }

    db.commit();
#endif

}

void PQCLocation::processSummary(QString folder) {

    QSqlQuery query(db);
    query.prepare("SELECT `folder`,`filename`,`latitude`,`longitude` FROM location WHERE `folder`=:fld");
    query.bindValue(":fld", folder);
    if(!query.exec()) {
        qWarning() << "ERROR getting data:" << query.lastError().text();
        return;
    }

    QVariantList images;
    QVariantMap labels;
    QVariantMap items;

    m_minimumLocation = QPointF(999,999);
    m_maximumLocation = QPointF(-999,-999);

    while(query.next()) {

        const QString folder = query.value(0).toString();
        const QString filename = query.value(1).toString();

        if(!QFileInfo::exists(folder+"/"+filename))
            continue;

        const double latitude = query.value(2).toDouble();
        const double longitude = query.value(3).toDouble();

        images << QVariant::fromValue(QVariantList() << (folder+"/"+filename) << latitude << longitude);

        if(latitude < m_minimumLocation.x())
            m_minimumLocation.setX(latitude);
        if(latitude > m_maximumLocation.x())
            m_maximumLocation.setX(latitude);

        if(longitude < m_minimumLocation.y())
            m_minimumLocation.setY(longitude);
        if(longitude > m_maximumLocation.y())
            m_maximumLocation.setY(longitude);

        for(int det = 0; det < steps.length(); ++det) {

            const double step = steps[det][0];
            const double key_lat = qRound64(latitude/step)*step;
            const double key_lon = qRound64(longitude/step)*step;


            QString item_key = QString::number(key_lat, 'f', 8) + "::" + QString::number(key_lon, 'f', 8);
            QString label_key = QString("%1").arg(det) + "::" + item_key;

            if(labels.contains(label_key)) {
                int val = labels[label_key].toInt() +1;
                labels[label_key] = val;
            } else
                labels.insert(label_key, 1);

            if(items.contains(item_key)) {
                if(!items[item_key].toList().contains(det)) {
                    QVariantList val = items[item_key].toList();
                    val.append(det);
                    items[item_key] = val;
                }
            } else {

                QVariantList val;
                val.append(QString("%1/%2").arg(folder,filename));
                val.append(latitude);
                val.append(longitude);
                val.append(det);

                items.insert(item_key, val);
            }

        }

    }

    query.clear();

    QCollator collator;
#ifndef PQMWITHOUTICU
    collator.setNumericMode(true);
#endif
    std::sort(images.begin(), images.end(), [&collator](const QVariant &file1, const QVariant &file2) { return collator.compare(file1.toList()[0].toString(), file2.toList()[0].toString()) < 0; });

    m_imageList = items;
    m_labelList = labels;
    m_allImages = images;

    Q_EMIT imageListChanged();
    Q_EMIT labelListChanged();
    Q_EMIT allImagesChanged();
    Q_EMIT minimumLocationChanged();
    Q_EMIT maximumLocationChanged();

}

void PQCLocation::closeDatabase() {

    qDebug() << "";

    db.close();

}
