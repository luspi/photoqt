#include "startup.h"

PQStartup::PQStartup(QObject *parent) : QObject(parent) {

}

// 0: no update
// 1: update
// 2: fresh install
int PQStartup::check() {

    QSqlDatabase db;

    // check if sqlite is available
    // this is a hard requirement now and we wont launch PhotoQt without it
    if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
        db = QSqlDatabase::addDatabase("QSQLITE3", "startup");
    else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
        db = QSqlDatabase::addDatabase("QSQLITE", "startup");
    else {
        LOG << CURDATE << "PQStartup::check(): ERROR: SQLite driver not available. Available drivers are: " << QSqlDatabase::drivers().join(",").toStdString() << NL;
        LOG << CURDATE << "PQStartup::check(): PhotoQt cannot function without SQLite available." << NL;
        //: This is the window title of an error message box
        QMessageBox::critical(0, QCoreApplication::translate("PQStartup", "SQLite error"),
                                 QCoreApplication::translate("PQStartup", "You seem to be missing the SQLite driver for Qt. This is needed though for a few different things, like reading and writing the settings. Without it, PhotoQt cannot function!"));
        std::exit(1);
    }

    // if we are on dev, we pretend to always update
    if(QString(VERSION) == "dev")
        return 1;

    // if no config files exist, then it is a fresh install
    if((!QFile::exists(ConfigFiles::SETTINGS_FILE()) && !QFile::exists(ConfigFiles::SETTINGS_DB())) ||
        !QFile::exists(ConfigFiles::IMAGEFORMATS_DB()) ||
        !QFile::exists(ConfigFiles::SHORTCUTS_FILE())) {
        return 2;
    }

    // 2.4 and older used a settings file
    // 2.5 and later uses a settings database
    if(QFile::exists(ConfigFiles::SETTINGS_FILE()) && !QFile::exists(ConfigFiles::SETTINGS_DB()))
        return 1;

    // open database
    db.setDatabaseName(ConfigFiles::SETTINGS_DB());
    if(!db.open())
        LOG << CURDATE << "PQStartup::check(): Error opening database: " << db.lastError().text().trimmed().toStdString() << NL;

    // compare version string in database to current version string
    QSqlQuery query(db);
    if(!query.exec("SELECT `value` from `general` where `name`='Version'"))
        LOG << CURDATE << "PQStartup::check(): SQL query error: " << query.lastError().text().trimmed().toStdString() << NL;
    query.next();

    // close database
    db.close();

    // updated
    QString version = query.record().value(0).toString();
    if(version != QString(VERSION))
        return 1;

    // nothing happened
    return 0;

}

void PQStartup::setupFresh(int defaultPopout) {

    qDebug() << "setupFresh:" << defaultPopout;

}

void PQStartup::performChecksAndMigrations() {

    qDebug() << "performChecksAndMigrations";

}
