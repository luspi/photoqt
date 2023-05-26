/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

#include "location.h"
#include <iomanip>
#include "../scripts/metadata.h"

PQLocation::PQLocation() {

    db = QSqlDatabase::database("location");

    if(!db.isOpen()) {
        if(!db.open()) {
            LOG << CURDATE << "PQLocation::PQLocation(): ERROR opening location database: " << db.lastError().text().trimmed().toStdString() << NL;
        }
    }

    dbIsTransaction = false;
    dbCommitTimer = new QTimer();
    dbCommitTimer->setSingleShot(true);
    dbCommitTimer->setInterval(400);
    connect(dbCommitTimer, &QTimer::timeout, this, [=](){
        db.commit();
        dbIsTransaction = false;
        if(db.lastError().text().trimmed().length())
            LOG << "PQSettings::commitDB: ERROR committing database: "
                << db.lastError().text().trimmed().toStdString()
                << NL;
    });

    m_detailLevel = 0;
    for(int i = 0; i < 5; ++i)
        m_imageList.append(QVariantList());

}

PQLocation::~PQLocation() {
}


void PQLocation::storeLocation(const QString path, const QPointF gps) {

    QFileInfo info(path);
    if(!info.exists()) {
        LOG << CURDATE << "PQLocation::storePosition(): File does not exist: " << path.toStdString() << NL;
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
        LOG << "PQLocation::storePosition(): ERROR inserting/replacing location data: " << query.lastError().text().toStdString() << NL;
        return;
    }

    dbCommitTimer->start();

}

void PQLocation::scanForLocations(QStringList files) {

    QFileInfo info(files[0]);

    QString folder = info.absolutePath();

    PQMetaData meta;

    QMap<QString,int> existing;

    QSqlQuery query(db);
    query.prepare("SELECT `filename`,`lastmodified` FROM `location` WHERE `folder`=:fld");
    query.bindValue(":fld", folder);
    if(!query.exec())
        LOG << CURDATE << "PQLocation::scanForLocations(): ERROR getting existing location data: " << query.lastError().text().toStdString() << NL;
    else {
        while(query.next())
            existing.insert(query.value(0).toString(), query.value(1).toInt());
    }

    query.clear();

    db.transaction();

    for(const QString &f : qAsConst(files)) {

        QFileInfo info(f);

        if(!existing.contains(info.fileName()) || existing[info.fileName()] != info.lastModified().toSecsSinceEpoch()) {


            QPointF gps = meta.getGPSDataOnly(f);

            if(gps.x() == 9999 || gps.y() == 9999)
                continue;

            QSqlQuery querynew(db);
            querynew.prepare("REPLACE INTO `location` (`id`,`folder`,`filename`,`latitude`,`longitude`,`lastmodified`) VALUES (:id, :fld, :fn, :lat, :lon, :mod)");
            querynew.bindValue(":id", QCryptographicHash::hash(f.toUtf8(),QCryptographicHash::Md5).toHex());
            querynew.bindValue(":fld", info.absolutePath());
            querynew.bindValue(":fn", info.fileName());
            querynew.bindValue(":lat", QString::number(gps.x(), 'f', 8));
            querynew.bindValue(":lon", QString::number(gps.y(), 'f', 8));
            querynew.bindValue(":mod", info.lastModified().toSecsSinceEpoch());
            if(!querynew.exec())
                LOG << CURDATE << "PQLocation::scanForLocations(): ERROR inserting new data: " << querynew.lastError().text().trimmed().toStdString() << NL;

        }

    }

    db.commit();

}

void PQLocation::processSummary(QString folder) {

    for(int det = 0; det < 5; ++det) {

        QSqlQuery query(db);
        query.prepare("SELECT `folder`,`filename`,`latitude`,`longitude` FROM location WHERE `folder`=:fld");
        query.bindValue(":fld", folder);
        if(!query.exec()) {
            LOG << CURDATE << "PQLocation::processSummary(): ERROR getting data: " << query.lastError().text().trimmed().toStdString() << NL;
            return;
        }

        QMap<QString, QVariantList> collect;

        while(query.next()) {

            const QString folder = query.value(0).toString();
            const QString filename = query.value(1).toString();
            const QString _latitude = query.value(2).toString();
            const QString _longitude = query.value(3).toString();
            const double latitude = _latitude.toDouble();
            const double longitude = _longitude.toDouble();

            const QString key = QString::number(latitude, 'f', det) + "::" + QString::number(longitude, 'f', det);

            if(collect.contains(key))
                collect[key][0] = collect[key][0].toInt()+1;
            else
                collect.insert(key, (QVariantList() << 1 << QString("%1/%2").arg(folder, filename)));

        }

        query.clear();

        m_imageList[det].clear();

        if(collect.isEmpty())
            continue;

        QMapIterator<QString, QVariantList> iter(collect);
        while(iter.hasNext()) {
            iter.next();

            const double lat = iter.key().split("::")[0].toDouble();
            const double lon = iter.key().split("::")[1].toDouble();
            const int num = iter.value()[0].toInt();
            const QString filename = iter.value()[1].toString();

            QVariantList entry;
            entry << lat
                  << lon
                  << num
                  << filename;

            m_imageList[det].push_back(entry);

        }

    }

    imageListChanged();

}

/*
QVariantList PQLocation::getImages(const int detailLevel, QString folder, bool includeSubFolder) {

    QVariantList ret;

    processSummary();

    QSqlQuery query(db);
    query.prepare("SELECT `latitude`,`longitude`,`howmany`,`filename` FROM 'summary' WHERE detaillevel=:det");
    query.bindValue(":det", detailLevel);
    if(!query.exec()) {
        LOG << CURDATE << "PQLocation::getImages(): ERROR getting images: " << query.lastError().text().trimmed().toStdString() << NL;
        return ret;
    }

    while(query.next()) {

        const double latitude = query.value(0).toString().toDouble();
        const double longitude = query.value(1).toString().toDouble();
        const int howmany = query.value(2).toInt();
        const QString filename = query.value(3).toString();

        QVariantList entry;
        entry << latitude
              << longitude
              << howmany
              << filename;

        ret.push_back(entry);

    }

    query.clear();

    return ret;

}
*/

void PQLocation::storeMapState(const double zoomlevel, const double latitude, const double longitude) {

    QSqlQuery query(db);

    query.prepare("REPLACE INTO `metainfo` (`key`,`value`) VALUES ('zoomlevel', :val)");
    query.bindValue(":val", zoomlevel);
    if(!query.exec())
        LOG << CURDATE << "PQLocation::storeMapState(): ERROR storing zoom level: " << query.lastError().text().trimmed().toStdString() << NL;
    query.clear();

    query.prepare("REPLACE INTO `metainfo` (`key`,`value`) VALUES ('latitude', :val)");
    query.bindValue(":val", latitude);
    if(!query.exec())
        LOG << CURDATE << "PQLocation::storeMapState(): ERROR storing latitude: " << query.lastError().text().trimmed().toStdString() << NL;
    query.clear();

    query.prepare("REPLACE INTO `metainfo` (`key`,`value`) VALUES ('longitude', :val)");
    query.bindValue(":val", longitude);
    if(!query.exec())
        LOG << CURDATE << "PQLocation::storeMapState(): ERROR storing longitude: " << query.lastError().text().trimmed().toStdString() << NL;
    query.clear();

}

QVariantList PQLocation::getMapState() {

    QSqlQuery query(db);
    if(!query.exec("SELECT `key`,`value` FROM `metainfo`")) {
        LOG << CURDATE << "PQLocation::getMapState(): Unable to get data from db: " << query.lastError().text().trimmed().toStdString() << NL;
        return QVariantList();
    }

    double zoomLevel = 0;
    double latitude = 0;
    double longitude = 0;

    while(query.next()) {

        const QString key = query.value(0).toString();
        if(key == "zoomlevel")
            zoomLevel = query.value(1).toString().toDouble();
        else if(key == "latitude")
            latitude = query.value(1).toString().toDouble();
        else if(key == "longitude")
            longitude = query.value(1).toString().toDouble();

    }

    return QVariantList() << zoomLevel << latitude << longitude;

}
