#include "validate.h"

PQValidate::PQValidate(QObject *parent) : QObject(parent) {

}

bool PQValidate::validateSettingsDatabase() {

    LOG << "validateSettingsDatabase()" << NL;

    // first we check all the settings
    // we do so automatically by loading the default settings database and check that all items there are present in the actual one

    QSqlDatabase dbinstalled = QSqlDatabase::database("settings");

    QSqlDatabase dbdefault;
    if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
        dbdefault = QSqlDatabase::addDatabase("QSQLITE3", "settingsdefault");
    else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
        dbdefault = QSqlDatabase::addDatabase("QSQLITE", "settingsdefault");
    else {
        LOG << CURDATE << "PQStartup::performConsistencyCheck(): ERROR: SQLite driver not available. Available drivers are: " << QSqlDatabase::drivers().join(",").toStdString() << NL;
        LOG << CURDATE << "PQStartup::performConsistencyCheck(): PhotoQt cannot function without SQLite available." << NL;
        return false;
    }

    // open database
    QFile::remove(QDir::tempPath()+"/photoqt_tmp.db");
    QFile::copy(":/settings.db", QDir::tempPath()+"/photoqt_tmp.db");
    dbdefault.setDatabaseName(QDir::tempPath()+"/photoqt_tmp.db");
    if(!dbdefault.open())
        LOG << CURDATE << "PQStartup::performConsistencyCheck(): Error opening default database: " << dbdefault.lastError().text().trimmed().toStdString() << NL;

    // read the list of all tables from the default database
    QStringList tables;

    QSqlQuery queryTables("SELECT name FROM sqlite_master WHERE type IN ('table','view') AND name NOT LIKE 'sqlite_%' ORDER BY 1;", dbdefault);
    if(!queryTables.exec()) {
        LOG << CURDATE << "PQStartup::performConsistencyCheck(): Error getting list of tables: " << queryTables.lastError().text().trimmed().toStdString() << NL;
        queryTables.clear();
        QFile::remove(QDir::tempPath()+"/photoqt_tmp.db");
        return false;
    }

    // iterate over all tables
    while(queryTables.next())
        tables << queryTables.value(0).toString();

    queryTables.clear();

    QSqlQuery query(dbdefault);

    for(const auto &table : qAsConst(tables)) {

        // get reference data
        query.prepare(QString("SELECT name,value,defaultvalue,datatype FROM '%1'").arg(table));
        if(!query.exec()) {
            LOG << CURDATE << "PQStartup::performConsistencyCheck(): Error getting default data: " << query.lastError().text().trimmed().toStdString() << NL;
            query.clear();
            QFile::remove(QDir::tempPath()+"/photoqt_tmp.db");
            return false;
        }

        // loop over reference data
        while(query.next()) {

            const QString name = query.value(0).toString();
            const QString value = query.value(1).toString();
            const QString defaultvalue = query.value(2).toString();
            const QString datatype = query.value(3).toString();

            // check whether an entry with that name exists in the in-production database
            QSqlQuery check(dbinstalled);
            check.prepare(QString("SELECT count(name) FROM %1 WHERE name=:name").arg(table));
            check.bindValue(":name", name);
            if(!check.exec()) {
                LOG << CURDATE << "PQStartup::performConsistencyCheck(): Error checking entry: " << name.toStdString() << ": " << check.lastError().text().trimmed().toStdString() << NL;
                continue;
            }
            check.next();
            int count = check.value(0).toInt();

            check.clear();

            // if entry does not exist, add it
            if(count == 0) {

                QSqlQuery insquery(dbinstalled);
                insquery.prepare(QString("INSERT INTO %1 (name,value,defaultvalue,datatype) VALUES(:nam,:val,:def,:dat)").arg(table));
                insquery.bindValue(":nam", name);
                insquery.bindValue(":val", value);
                insquery.bindValue(":def", defaultvalue);
                insquery.bindValue(":dat", datatype);

                if(!insquery.exec()) {
                    LOG << CURDATE << "PQStartup::performConsistencyCheck(): ERROR inserting missing entry " << table.toStdString() << "/" << name.toStdString() << ": " << insquery.lastError().text().trimmed().toStdString() << NL;
                    continue;
                }

            // if entry does exist, make sure defaultvalue and datatype is valid
            } else {

                QSqlQuery check(dbinstalled);
                check.prepare(QString("UPDATE %1 SET defaultvalue=:def,datatype=:dat WHERE name=:nam").arg(table));
                check.bindValue(":def", defaultvalue);
                check.bindValue(":dat", datatype);
                check.bindValue(":nam", name);
                if(!check.exec()) {
                    LOG << CURDATE << "PQStartup::performConsistencyCheck(): Error updating defaultvalue and datatype: " << name.toStdString() << ": " << check.lastError().text().trimmed().toStdString() << NL;
                    continue;
                }
                check.clear();

            }

        }

        query.clear();

    }

    QFile::remove(QDir::tempPath()+"/photoqt_tmp.db");

    return true;

}
