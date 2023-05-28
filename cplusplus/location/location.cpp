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

    QSqlQuery query(db);
    query.prepare("SELECT `folder`,`filename`,`latitude`,`longitude` FROM location WHERE `folder`=:fld");
    query.bindValue(":fld", folder);
    if(!query.exec()) {
        LOG << CURDATE << "PQLocation::processSummary(): ERROR getting data: " << query.lastError().text().trimmed().toStdString() << NL;
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

        images << (folder+"/"+filename)
               << latitude
               << longitude;

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
                val.append(QString("%1/%2").arg(folder).arg(filename));
                val.append(det);

                items.insert(item_key, val);
            }

        }

    }

    query.clear();

    m_imageList = items;
    m_labelList = labels;
    m_allImages = images;

    imageListChanged();
    labelListChanged();
    allImagesChanged();
    minimumLocationChanged();
    maximumLocationChanged();

}

