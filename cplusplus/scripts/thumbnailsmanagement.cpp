/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
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

#include "thumbnailsmanagement.h"

ThumbnailManagement::ThumbnailManagement(QObject *parent) : QObject(parent) {

    // Opening the thumbnail database
    db = QSqlDatabase::addDatabase("QSQLITE", "thumbDB");
    db.setDatabaseName(ConfigFiles::THUMBNAILS_DB());
    if(!db.open())
        LOG << CURDATE << "ThumbnailManagement - ERROR: Can't open thumbnail database: " << db.lastError().text().trimmed().toStdString() << NL;

}

qint64 ThumbnailManagement::getDatabaseFilesize() {

    return QFileInfo(ConfigFiles::THUMBNAILS_DB()).size()/1024;

}

int ThumbnailManagement::getNumberDatabaseEntries() {

    QSqlQuery query(db);
    query.exec("SELECT COUNT(filepath) AS c FROM Thumbnails");
    if(query.lastError().text().trimmed().length()) {
        LOG << CURDATE << "ThumbnailManagement::getNumberDatabaseEntries() - ERROR: " << query.lastError().text().trimmed().toStdString() << NL;
        query.clear();
        return 0;
    }

    query.next();

    int num = query.value(query.record().indexOf("c")).toInt();
    query.clear();
    return num;

}

void ThumbnailManagement::cleanDatabase() {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "ThumbnailManagement::cleanDatabase()" << NL;

    QSqlQuery query(db);

    // First, we remove all entries with empty filepath (something went wrong there)
    query.prepare("DELETE FROM Thumbnails WHERE filepath=''");
    query.exec();
    query.clear();

    // Then lets look at the remaining entries
    query.prepare("SELECT * FROM Thumbnails");
    query.exec();

    // First we create a list of items that are to be deleted
    QVector<QVector<QString> > toDel;
    if(query.size() != -1) toDel.reserve(query.size());
    while(query.next()) {
        QString path = query.value(query.record().indexOf("filepath")).toString();
        int mtime = query.value(query.record().indexOf("filelastmod")).toInt();

        if(!QFile(path).exists() || mtime != int(QFileInfo(path).lastModified().toTime_t())) {

            QVector<QString> l;
            l.reserve(2);
            l << path << QString("%1").arg(mtime);
            toDel << l;

        }

    }
    query.clear();

    // Then we actually delete all the items
    for(int i = 0; i < toDel.size(); ++i) {

        QSqlQuery query2(db);
        query2.prepare("DELETE FROM Thumbnails WHERE filepath=:path AND filelastmod=:mod");
        query2.bindValue(":mod",toDel.at(i).at(1));
        query2.bindValue(":path",toDel.at(i).at(0));
        query2.exec();
        if(query2.lastError().text().trimmed().length())
            LOG << CURDATE << "ThumbnailManagement::cleanDatabase() - ERROR deleting: " << query2.lastError().text().trimmed().toStdString() << NL;
        query2.clear();

    }

    // Error catching
    if(db.lastError().text().trimmed().length())
        LOG << CURDATE << "ThumbnailManagement::cleanDatabase() - ERROR executing query: " << db.lastError().text().trimmed().toStdString() << NL;


    // Compress database
    QSqlQuery query3(db);
    query3.prepare("VACUUM");
    query3.exec();
    if(query3.lastError().text().trimmed().length())
        LOG << CURDATE << "ThumbnailManagement::cleanDatabase() - ERROR compressing db: " << query3.lastError().text().trimmed().toStdString() << NL;
    query3.clear();

}

void ThumbnailManagement::eraseDatabase() {

    if(qgetenv("PHOTOQT_DEBUG") == "yes")
        LOG << CURDATE << "ThumbnailManagement::eraseDatabase()" << NL;

    QSqlQuery query(db);

    // DROP old table with all data
    query.prepare("DROP TABLE Thumbnails");
    query.exec();
    if(query.lastError().text().trimmed().length())
        LOG << CURDATE << "ThumbnailManagement::eraseDatabase() - ERROR dropping: " << query.lastError().text().trimmed().toStdString() << NL;
    query.clear();

    // VACUUM database (decrease size)
    query.prepare("VACUUM");
    query.exec();
    if(query.lastError().text().trimmed().length())
        LOG << CURDATE << "ThumbnailManagement::eraseDatabase() - ERROR compressing db: " << query.lastError().text().trimmed().toStdString() << NL;
    query.clear();

    // Create new table
    query.prepare("CREATE TABLE Thumbnails (filepath TEXT,thumbnail BLOB, filelastmod INT, thumbcreated INT, origwidth INT, origheight INT)");
    query.exec();
    if(query.lastError().text().trimmed().length())
        LOG << CURDATE << "ThumbnailManagement::eraseDatabase() - ERROR recreating db: " << query.lastError().text().trimmed().toStdString() << NL;
    query.clear();

}
