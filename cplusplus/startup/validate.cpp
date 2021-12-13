#include "validate.h"

PQValidate::PQValidate(QObject *parent) : QObject(parent) {

}

bool PQValidate::validate() {

    LOG << NL
        << "PhotoQt v" << VERSION << NL
        << " > Validating configuration... " << NL;

    bool ret = validateSettingsDatabase();
    if(!ret) {
        LOG << " >> Failed!" << NL << NL;
        return false;
    }

    ret = validateShortcutsDatabase();
    if(!ret) {
        LOG << " >> Failed!" << NL << NL;
        return false;
    }

    LOG << " >> Done!" << NL << NL;
    return true;

}

bool PQValidate::validateSettingsDatabase() {

    // first we check all the settings
    // we do so automatically by loading the default settings database and check that all items there are present in the actual one

    QSqlDatabase dbinstalled = QSqlDatabase::database("settings");

    QSqlDatabase dbdefault;
    if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
        dbdefault = QSqlDatabase::addDatabase("QSQLITE3", "settingsdefault");
    else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
        dbdefault = QSqlDatabase::addDatabase("QSQLITE", "settingsdefault");
    else {
        LOG << CURDATE << "PQValidate::validateSettingsDatabase(): ERROR: SQLite driver not available. Available drivers are: " << QSqlDatabase::drivers().join(",").toStdString() << NL;
        LOG << CURDATE << "PQValidate::validateSettingsDatabase(): PhotoQt cannot function without SQLite available." << NL;
        return false;
    }

    // open database
    QFile::remove(QDir::tempPath()+"/photoqt_tmp.db");
    QFile::copy(":/settings.db", QDir::tempPath()+"/photoqt_tmp.db");
    dbdefault.setDatabaseName(QDir::tempPath()+"/photoqt_tmp.db");
    if(!dbdefault.open())
        LOG << CURDATE << "PQValidate::validateSettingsDatabase(): Error opening default database: " << dbdefault.lastError().text().trimmed().toStdString() << NL;

    // read the list of all tables from the default database
    QStringList tables;

    QSqlQuery queryTables("SELECT name FROM sqlite_master WHERE type IN ('table','view') AND name NOT LIKE 'sqlite_%' ORDER BY 1;", dbdefault);
    if(!queryTables.exec()) {
        LOG << CURDATE << "PQValidate::validateSettingsDatabase(): Error getting list of tables: " << queryTables.lastError().text().trimmed().toStdString() << NL;
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
            LOG << CURDATE << "PQValidate::validateSettingsDatabase(): Error getting default data: " << query.lastError().text().trimmed().toStdString() << NL;
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
                LOG << CURDATE << "PQValidate::validateSettingsDatabase(): Error checking entry: " << name.toStdString() << ": " << check.lastError().text().trimmed().toStdString() << NL;
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
                    LOG << CURDATE << "PQValidate::validateSettingsDatabase(): ERROR inserting missing entry " << table.toStdString() << "/" << name.toStdString() << ": " << insquery.lastError().text().trimmed().toStdString() << NL;
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
                    LOG << CURDATE << "PQValidate::validateSettingsDatabase(): Error updating defaultvalue and datatype: " << name.toStdString() << ": " << check.lastError().text().trimmed().toStdString() << NL;
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

bool PQValidate::validateShortcutsDatabase() {

    QSqlDatabase dbinstalled = QSqlDatabase::database("shortcuts");

    QSqlDatabase dbdefault;
    if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
        dbdefault = QSqlDatabase::addDatabase("QSQLITE3", "shortcutsdefault");
    else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
        dbdefault = QSqlDatabase::addDatabase("QSQLITE", "shortcutsdefault");
    else {
        LOG << CURDATE << "PQValidate::validateShortcutsDatabase(): ERROR: SQLite driver not available. Available drivers are: " << QSqlDatabase::drivers().join(",").toStdString() << NL;
        LOG << CURDATE << "PQValidate::validateShortcutsDatabase(): PhotoQt cannot function without SQLite available." << NL;
        return false;
    }

    // open database
    QFile::remove(QDir::tempPath()+"/photoqt_tmp.db");
    QFile::copy(":/shortcuts.db", QDir::tempPath()+"/photoqt_tmp.db");
    dbdefault.setDatabaseName(QDir::tempPath()+"/photoqt_tmp.db");
    if(!dbdefault.open())
        LOG << CURDATE << "PQValidate::validateShortcutsDatabase(): Error opening default database: " << dbdefault.lastError().text().trimmed().toStdString() << NL;

    QSqlQuery query(dbdefault);

    // get reference data
    query.prepare("SELECT category,command,shortcuts,defaultshortcuts FROM 'builtin'");
    if(!query.exec()) {
        LOG << CURDATE << "PQValidate::validateShortcutsDatabase(): Error getting default data: " << query.lastError().text().trimmed().toStdString() << NL;
        query.clear();
        QFile::remove(QDir::tempPath()+"/photoqt_tmp.db");
        return false;
    }

    // loop over reference data
    while(query.next()) {

        const QString category = query.value(0).toString();
        const QString command = query.value(1).toString();
        QString shortcuts = query.value(2).toString();
        const QString defaultshortcuts = query.value(3).toString();

        // check whether an entry with that name exists in the in-production database
        QSqlQuery check(dbinstalled);
        check.prepare("SELECT count(category) FROM builtin WHERE command=:command");
        check.bindValue(":command", command);
        if(!check.exec()) {
            LOG << CURDATE << "PQValidate::validateShortcutsDatabase(): Error checking entry: " << command.toStdString() << ": " << check.lastError().text().trimmed().toStdString() << NL;
            continue;
        }
        check.next();
        int count = check.value(0).toInt();

        check.clear();

        // if there are multiples, we first get and store the possible desired value and then remove all of them
        if(count > 1) {

            QSqlQuery rem(dbinstalled);
            rem.prepare("SELECT shortcuts FROM builtin WHERE command=:cmd AND shortcuts!=''");
            rem.bindValue(":cmd", command);
            if(!rem.exec()) {
                LOG << CURDATE << "PQValidate::validateShortcutsDatabase(): ERROR getting value of multiples " << command.toStdString() << ": " << rem.lastError().text().trimmed().toStdString() << NL;
                continue;
            }
            if(rem.next())
                shortcuts = rem.value(0).toString();
            else
                shortcuts = "";

            rem.clear();

            rem.prepare("DELETE FROM builtin WHERE command=:cmd");
            rem.bindValue(":cmd", command);
            if(!rem.exec()) {
                LOG << CURDATE << "PQValidate::validateShortcutsDatabase(): ERROR removing multiples " << command.toStdString() << ": " << rem.lastError().text().trimmed().toStdString() << NL;
                continue;
            }
            rem.clear();

            count = 0;
        }

        // if entry does not exist, add it
        if(count == 0) {

            QSqlQuery insquery(dbinstalled);
            insquery.prepare("INSERT INTO builtin (category,command,shortcuts,defaultshortcuts) VALUES(:cat,:cmd,:sh,:def)");
            insquery.bindValue(":cat", category);
            insquery.bindValue(":cmd", command);
            insquery.bindValue(":sh", shortcuts);
            insquery.bindValue(":def", defaultshortcuts);

            if(!insquery.exec()) {
                LOG << CURDATE << "PQValidate::validateShortcutsDatabase(): ERROR inserting missing entry " << command.toStdString() << ": " << insquery.lastError().text().trimmed().toStdString() << NL;
                continue;
            }

        // if entry does exist, make sure category and defaultshortcuts is valid
        } else {

            QSqlQuery check(dbinstalled);
            check.prepare("UPDATE builtin SET category=:cat,defaultshortcuts=:def WHERE command=:cmd");
            check.bindValue(":cat", category);
            check.bindValue(":def", defaultshortcuts);
            check.bindValue(":cmd", command);
            if(!check.exec()) {
                LOG << CURDATE << "PQValidate::validateShortcutsDatabase(): Error updating defaultvalue and datatype: " << command.toStdString() << ": " << check.lastError().text().trimmed().toStdString() << NL;
                continue;
            }
            check.clear();

        }

    }

    query.clear();

    QFile::remove(QDir::tempPath()+"/photoqt_tmp.db");

    return true;

}
