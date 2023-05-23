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

#include "positions.h"

PQPositions::PQPositions() {

    db = QSqlDatabase::database("positions");

    QFileInfo posdb(ConfigFiles::POSITIONS_DB());

    if(!posdb.exists() || !db.open()) {

        LOG << CURDATE << "PQPositions::PQPositions(): ERROR opening database: " << db.lastError().text().trimmed().toStdString() << NL;
        LOG << CURDATE << "PQPositions::PQPositions(): Loading positions of images will not be available." << NL;

        return;

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

}

PQPositions::~PQPositions() {
}


void PQPositions::storePosition(QString path, QPointF gps) {

    QFileInfo info(path);
    if(!info.exists()) {
        LOG << CURDATE << "PQPositions::storePosition(): File does not exist: " << path.toStdString() << NL;
        return;
    }

    if(!db.isOpen()) {
        if(!db.open()) {
            LOG << CURDATE << "PQPositions::storePosition(): ERROR opening positions database: " << db.lastError().text().trimmed().toStdString() << NL;
            return;
        }
    }

    dbCommitTimer->stop();

    if(!dbIsTransaction) {
        db.transaction();
        dbIsTransaction = true;
    }

    QSqlQuery query(db);
    query.prepare("REPLACE INTO positions (filename,latitude,longitude,lastmodified) VALUES (:fn, :lat, :lon, :mod)");
    query.bindValue(":fn", path);
    query.bindValue(":lat", gps.x());
    query.bindValue(":lon", gps.y());
    query.bindValue(":mod", info.lastModified().toSecsSinceEpoch());
    if(!query.exec()) {
        LOG << "PQPositions::storePosition(): ERROR inserting/replacing positions data: " << query.lastError().text().toStdString() << NL;
        return;
    }

    dbCommitTimer->start();

}
