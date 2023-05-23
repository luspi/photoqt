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

PQLocation::PQLocation() {

    db = QSqlDatabase::database("location");

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

}

PQLocation::~PQLocation() {
}


void PQLocation::storeLocation(const QString path, const QPointF gps) {

    QFileInfo info(path);
    if(!info.exists()) {
        LOG << CURDATE << "PQLocation::storePosition(): File does not exist: " << path.toStdString() << NL;
        return;
    }

    if(!db.isOpen()) {
        if(!db.open()) {
            LOG << CURDATE << "PQLocation::storePosition(): ERROR opening location database: " << db.lastError().text().trimmed().toStdString() << NL;
            return;
        }
    }

    dbCommitTimer->stop();

    if(!dbIsTransaction) {
        db.transaction();
        dbIsTransaction = true;
    }

    QSqlQuery query(db);
    query.prepare("REPLACE INTO location (filename,latitude,longitude,lastmodified) VALUES (:fn, :lat, :lon, :mod)");
    query.bindValue(":fn", path);
    query.bindValue(":lat", QString("%1").arg(gps.x()));
    query.bindValue(":lon", QString("%1").arg(gps.y()));
    query.bindValue(":mod", info.lastModified().toSecsSinceEpoch());
    if(!query.exec()) {
        LOG << "PQLocation::storePosition(): ERROR inserting/replacing location data: " << query.lastError().text().toStdString() << NL;
        return;
    }

    dbCommitTimer->start();

}

void PQLocation::processSummary() {

    QSqlQuery queryDel(db);
    if(!queryDel.exec("DELETE FROM summary"))
        LOG << CURDATE << "PQLocation::processSummary(): ERROR removing old data, some data might be obsolete: " << queryDel.lastError().text().trimmed().toStdString() << NL;

    for(int det = 0; det < 4; ++det) {

        QSqlQuery query(db);
        if(!query.exec("SELECT `filename`,`latitude`,`longitude` FROM location")) {
            LOG << CURDATE << "PQLocation::processSummary(): ERROR getting data: " << query.lastError().text().trimmed().toStdString() << NL;
            return;
        }

        QMap<QString, QVariantList> collect;

        while(query.next()) {

            const QString filename = query.value(0).toString();
            const QString _latitude = query.value(1).toString();
            const QString _longitude = query.value(2).toString();
            const double latitude = _latitude.toDouble();
            const double longitude = _longitude.toDouble();

            const QString key = QString::number(latitude, 'f', det+1) + "::" + QString::number(longitude, 'f', det+1);

            if(collect.contains(key))
                collect[key][0] = collect[key][0].toInt()+1;
            else
                collect.insert(key, (QVariantList() << 1 << filename));

        }

        query.clear();

        db.transaction();

        QMapIterator<QString, QVariantList> iter(collect);
        while(iter.hasNext()) {
            iter.next();

            const double lat = iter.key().split("::")[0].toDouble();
            const double lon = iter.key().split("::")[1].toDouble();
            const int num = iter.value()[0].toInt();
            const QString filename = iter.value()[1].toString();

            QSqlQuery queryDet(db);
            queryDet.prepare("INSERT INTO `summary` (`detaillevel`,`latitude`,`longitude`,`howmany`,`filename`) VALUES(:det, :lat, :lon, :cnt, :fn)");
            queryDet.bindValue(":det", det+1);
            queryDet.bindValue(":lat", lat);
            queryDet.bindValue(":lon", lon);
            queryDet.bindValue(":cnt", num);
            queryDet.bindValue(":fn", filename);
            if(!queryDet.exec()) {
                LOG << CURDATE << "PQLocation::processSummary(): ERROR inserting summary: " << queryDet.lastError().text().trimmed().toStdString() << NL;
                continue;
            }

        }

        db.commit();

    }


}

QVariantList PQLocation::getImages(const int detailLevel) {

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
