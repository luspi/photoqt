#include "startupcheck.h"

void StartupCheck::Thumbnails::checkThumbnailsDatabase(int update) {

    bool debug = (qgetenv("PHOTOQT_DEBUG") == "yes");

    if(debug) LOG << CURDATE << "StartupCheck::Thumbnails" << NL;

    // ensure CACHE_DIR exists
    QDir cachedir(ConfigFiles::CACHE_DIR());
    if(!cachedir.exists())
        cachedir.mkpath(ConfigFiles::CACHE_DIR());

    // Check if thumbnail database exists. If not, create it
    QFile database(ConfigFiles::THUMBNAILS_DB());
    if(!database.exists()) {

        if(debug) LOG << CURDATE << "Create Thumbnail Database" << NL;

        QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", "thumbDB1");
        db.setDatabaseName(ConfigFiles::THUMBNAILS_DB());
        if(!db.open()) LOG << CURDATE << "ERROR: Couldn't open thumbnail database:" << db.lastError().text().trimmed().toStdString() << NL;
        QSqlQuery query(db);
        query.prepare(
                "CREATE TABLE Thumbnails (filepath TEXT,thumbnail BLOB, filelastmod INT, thumbcreated INT, origwidth INT, origheight INT)");
        query.exec();
        if(query.lastError().text().trimmed().length()) LOG << CURDATE << "ERROR (Creating Thumbnail Datbase):" <<
                                                               query.lastError().text().trimmed().toStdString() << NL;
        query.clear();


    } else if(update != 0) {

        if(debug) LOG << CURDATE << "Opening Thumbnail Database" << NL;

        // Opening the thumbnail database
        QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE","thumbDB2");
        db.setDatabaseName(ConfigFiles::THUMBNAILS_DB());
        if(!db.open()) LOG << CURDATE << "ERROR: Couldn't open thumbnail database:" << db.lastError().text().trimmed().toStdString() << NL;

        QSqlQuery query_check(db);
        query_check.prepare(
                "SELECT COUNT( * ) AS 'Count' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Thumbnails' AND COLUMN_NAME = 'origwidth'");
        query_check.exec();
        query_check.next();
        if(query_check.record().value(0) == 0) {
            QSqlQuery query(db);
            query.prepare("ALTER TABLE Thumbnails ADD COLUMN origwidth INT");
            query.exec();
            if(query.lastError().text().trimmed().length()) LOG << CURDATE << "ERROR (Adding origwidth to Thumbnail Database):" <<
                                                                   query.lastError().text().trimmed().toStdString() << NL;
            query.clear();
            query.prepare("ALTER TABLE Thumbnails ADD COLUMN origheight INT");
            query.exec();
            if(query.lastError().text().trimmed().length()) LOG << CURDATE << "ERROR (Adding origheight to Thumbnail Database):" <<
                                                                   query.lastError().text().trimmed().toStdString() << NL;
            query.clear();
        }
        query_check.clear();

    }

}
