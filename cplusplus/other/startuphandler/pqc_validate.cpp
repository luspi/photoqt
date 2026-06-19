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

#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlError>
#include <QtSql/QSqlQuery>
#include <iostream>
#include <pqc_validate.h>
#include <pqc_configfiles.h>
#include <pqc_settingscpp.h>
#include <pqc_shortcuts.h>
#include <scripts/pqc_scriptsimages.h>

PQCValidate::PQCValidate(QObject *parent) : QObject(parent) {}

bool PQCValidate::validate() {

    std::cout << std::endl
              << "PhotoQt v" << PQMVERSION << std::endl
              << " > Validating configuration... " << std::endl;

    const QString thumbnails_cache_basedir = (PQCSettingsCPP::get().getThumbnailsCacheBaseDirDefault() ?
                                                  "" :
                                                  PQCSettingsCPP::get().getThumbnailsCacheBaseDirLocation());

    bool success = true;

    bool ret = validateDirectories(thumbnails_cache_basedir);
    if(!ret) {
        std::cout << " >> Failed: directories" << std::endl;
        success = false;
    }

    ret = validateSettingsDatabase();
    if(!ret) {
        std::cout << " >> Failed: settings db" << std::endl;
        success = false;
    }

    ret = validateShortcutsDatabase();
    if(!ret) {
        std::cout << " >> Failed: shortcuts db" << std::endl;
        success = false;
    }

    ret = validateContextMenuDatabase();
    if(!ret) {
        std::cout << " >> Failed: context menu db" << std::endl;
        success = false;
    }

    ret = validateSettingsValues();
    if(!ret) {
        std::cout << " >> Failed: settings values" << std::endl;
        success = false;
    }

    ret = validateLocationDatabase();
    if(!ret) {
        std::cout << " >> Failed: location db" << std::endl;
        success = false;
    }

    std::cout << " >> Done!" << std::endl << std::endl;
    return success;

}

bool PQCValidate::validateDirectories(const QString &thumb_cache_basedir) {

    qDebug() << "args: thumb_cache_basedir =" << thumb_cache_basedir;

    QFileInfo userplaces_info(PQCConfigFiles::get().USER_PLACES_XBEL());

    // make sure necessary folder exist
    QDir dir;
    dir.mkpath(PQCConfigFiles::get().CONFIG_DIR());
    dir.mkpath(PQCConfigFiles::get().CACHE_DIR());
    dir.mkpath(PQCConfigFiles::get().DATA_DIR());
    dir.mkpath(userplaces_info.absolutePath());
    dir.mkpath(PQCConfigFiles::get().CONFIG_DIR() % "/imageplugins/");
    if(!thumb_cache_basedir.isEmpty()) {
        dir.mkpath(thumb_cache_basedir);
        dir.mkpath(thumb_cache_basedir % "/normal/");
        dir.mkpath(thumb_cache_basedir % "/large/");
        dir.mkpath(thumb_cache_basedir % "/x-large/");
        dir.mkpath(thumb_cache_basedir % "/xx-large/");
    } else {
        dir.mkpath(PQCConfigFiles::get().THUMBNAIL_CACHE_DIR());
        dir.mkpath(PQCConfigFiles::get().THUMBNAIL_CACHE_DIR() % "/normal/");
        dir.mkpath(PQCConfigFiles::get().THUMBNAIL_CACHE_DIR() % "/large/");
        dir.mkpath(PQCConfigFiles::get().THUMBNAIL_CACHE_DIR() % "/x-large/");
        dir.mkpath(PQCConfigFiles::get().THUMBNAIL_CACHE_DIR() % "/xx-large/");
    }

    // In a previous version the user-places.xbel file was created as directory instead.
    // If an empty directory with that path exists we remove it.
    if(userplaces_info.isDir()) {
        qWarning() << "user-places.xbel is a directory. Checking whether it is empty and removing it in that case.";
        QDir dir(PQCConfigFiles::get().USER_PLACES_XBEL());
        if(dir.isEmpty()) {
            dir.removeRecursively();
            dir.mkpath(userplaces_info.absolutePath());
        } else
            qWarning() << "Directory is not empty, using favorites will not be possible";
    }

#if defined(Q_OS_WIN) && !defined(PQMPORTABLETWEAKS)
    // if the user-places.xbel does not exist, we check if it exists in the old location and, if so, move it over
    // on Windows this file is moved to the app specific folder starting with version 4.7 as likely no other application
    // makes use of this file other than PhotoQt. This prevents littering global user folders.
    if(QString(PQMVERSION) == "4.7") {
        const QString newfile = PQCConfigFiles::get().USER_PLACES_XBEL();
        const QString oldfile = QString("%1/user-places.xbel").arg(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation));
        if(!QFile::exists(newfile) && QFile::exists(oldfile)) {
            QFile::copy(oldfile, newfile);
        }
    }
#endif

    return true;

}

bool PQCValidate::validateContextMenuDatabase() {

    qDebug() << "";

    // the db does not exist -> create it and finish
    if(!QFile::exists(PQCConfigFiles::get().CONTEXTMENU_DB())) {
        if(!QFile::copy(":/contextmenu.db", PQCConfigFiles::get().CONTEXTMENU_DB()))
            qWarning() << "Unable to (re-)create default contextmenu database";
        else {
            QFile file(PQCConfigFiles::get().CONTEXTMENU_DB());
            file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
        }
        return true;
    }

    QSqlDatabase dbinstalled = QSqlDatabase::database("contextmenu");

    if(!dbinstalled.open())
        qWarning() << "Error opening database:" << dbinstalled.lastError().text();

    const QStringList newcols = {"icon", "TEXT",
                                 "arguments", "TEXT"};

    for(int i = 0; i < newcols.length()/2; ++i) {

        const QString col = newcols[2*i];
        const QString typ = newcols[2*i +1];

        QSqlQuery query(dbinstalled);
        query.prepare("SELECT COUNT(*) AS count FROM pragma_table_info('entries') WHERE name=:col");
        query.bindValue(":col", col);
        if(!query.exec()) {
            qWarning() << QString("Error checking existence of column '%1':").arg(col) << query.lastError().text();
            query.clear();
            return false;
        }
        query.next();
        int c = query.value(0).toInt();

        // if column does not exist, add it
        if(c == 0) {
            QSqlQuery query2(dbinstalled);
            query2.prepare(QString("ALTER TABLE entries ADD COLUMN %1 %2").arg(col, typ));
            if(!query2.exec()) {
                qWarning() << QString("Error adding new column '%1':").arg(col) << query2.lastError().text();
                query2.clear();
                return false;
            }
            query2.clear();

            if(col == "arguments") {

                // split old 'command' into new 'command' and 'arguments'
                QSqlQuery query3(dbinstalled);
                query3.prepare("SELECT command,desc,close FROM `entries`");
                if(!query3.exec()) {
                    qWarning() << "Error getting old 'command' data:" << query3.lastError().text();
                    query3.clear();
                    return false;
                }

                // compose list of new entries
                QList<QStringList> lst;
                while(query3.next()) {

                    QStringList parts = query3.value(0).toString().split(" ");

                    const QString cmd = parts[0];
                    parts.removeFirst();
                    const QString args = parts.join(" ");

                    QString icn = PQCScriptsImages::get().getIconPathFromTheme(cmd);
                    if(!icn.isEmpty())
                        icn = PQCScriptsImages::get().loadIconAndConvertToBase64(icn);

                    const QStringList cur = {cmd,
                                             args,
                                             query3.value(1).toString(),
                                             query3.value(2).toString(),
                                             icn};

                    lst.append(cur);

                }

                query3.clear();

                QSqlQuery query4(dbinstalled);
                if(!query4.exec("DELETE FROM `entries`")) {
                    qWarning() << "Error removing old data:" << query4.lastError().text();
                    query4.clear();
                    return false;
                }

                for(const auto &entry : lst) {

                    QSqlQuery query5(dbinstalled);
                    query5.prepare("INSERT INTO `entries` (command, arguments, desc, close, icon) VALUES (:cmd, :arg, :desc, :close, :icn)");
                    query5.bindValue(":cmd", entry[0]);
                    query5.bindValue(":arg", entry[1]);
                    query5.bindValue(":desc", entry[2]);
                    query5.bindValue(":close", entry[3]);
                    query5.bindValue(":icn", entry[4]);
                    if(!query5.exec()) {
                        qWarning() << "Error adding new data:" << query5.lastError().text();
                        query5.clear();
                        return false;
                    }

                }

            }

        }

        query.clear();

    }

    return true;

}

bool PQCValidate::validateLocationDatabase() {

    qDebug() << "";

    // the db does not exist -> create it and finish
    if(!QFile::exists(PQCConfigFiles::get().LOCATION_DB())) {
        if(!QFile::copy(":/location.db", PQCConfigFiles::get().LOCATION_DB()))
            qWarning() << "Unable to (re-)create default location database";
        else {
            QFile file(PQCConfigFiles::get().LOCATION_DB());
            file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
        }
    }

    return true;

}

bool PQCValidate::validateSettingsDatabase() {

    qDebug() << "";

    if(!QFile::exists(PQCConfigFiles::get().USERSETTINGS_DB())) {
        if(!QFile::copy(":/usersettings.db", PQCConfigFiles::get().USERSETTINGS_DB()))
            qWarning() << "Unable to (re-)create default settings database";
        else {
            QFile file(PQCConfigFiles::get().USERSETTINGS_DB());
            file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
        }
        return true;
    }

    QSqlDatabase db = QSqlDatabase::database("settings");
    if(!db.open()) {
        qWarning() << "Error opening database:" << db.lastError().text();
        return false;
    }

    QSqlDatabase dbDefault;
    if(QSqlDatabase::contains("defaultsettings"))
        dbDefault = QSqlDatabase::database("defaultsettings");
    else {
        if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
            dbDefault = QSqlDatabase::addDatabase("QSQLITE3", "defaultsettings");
        else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
            dbDefault = QSqlDatabase::addDatabase("QSQLITE", "defaultsettings");
    }
    QFile::remove(PQCConfigFiles::get().DEFAULTSETTINGS_DB());
    QFile::copy(":/defaultsettings.db", PQCConfigFiles::get().DEFAULTSETTINGS_DB());
    dbDefault.setDatabaseName(PQCConfigFiles::get().DEFAULTSETTINGS_DB());
    if(!dbDefault.open()) {
        qWarning() << "ERROR opening default database:" << dbDefault.lastError().text();
        return false;
    }

    // read the list of all tables from the default database
    QStringList tables;

    QSqlQuery queryTables("SELECT name FROM sqlite_master WHERE type IN ('table','view') AND name NOT LIKE 'sqlite_%' ORDER BY 1;", dbDefault);
    if(!queryTables.exec()) {
        qWarning() << "Error getting list of tables:" << queryTables.lastError().text();
        queryTables.clear();
        return false;
    }

    QStringList whichTablesToAdd;

    // iterate over all tables
    while(queryTables.next()) {

        const QString tab = queryTables.value(0).toString();
        tables << tab;

        // make sure all tables exist in installed db

        QSqlQuery queryTabIns(db);
        if(!queryTabIns.exec(QString("SELECT COUNT(name) as cnt FROM sqlite_master WHERE type='table' AND name='%1'").arg(tab))) {
            qWarning() << QString("Error checking table '%1' existence:").arg(tab) << queryTabIns.lastError().text();
            continue;
        }

        queryTabIns.next();

        int cnt = queryTabIns.value(0).toInt();
        if(cnt == 0)
            whichTablesToAdd << tab;

        queryTabIns.clear();
    }

    queryTables.clear();

    // add missing tables
    if(whichTablesToAdd.length() > 0) {

        for(const QString &tab : std::as_const(whichTablesToAdd)) {

            QSqlQuery queryTabIns(db);
            if(!queryTabIns.exec(QString("CREATE TABLE %1 ('name' TEXT UNIQUE, 'value' TEXT, 'datatype' TEXT)").arg(tab)))
                qWarning() << QString("ERROR adding missing table '%1':").arg(tab) << queryTabIns.lastError().text();
            queryTabIns.clear();
        }

    }

    dbDefault.close();

    return true;

}

bool PQCValidate::validateSettingsValues() {

    qDebug() << "";

    QSqlDatabase db = QSqlDatabase::database("settings");

    if(!db.open()) {
        qWarning() << "Error opening database:" << db.lastError().text();
        return false;
    }

    QSqlDatabase dbcheck;
    if(QSqlDatabase::contains("checksettings"))
        dbcheck = QSqlDatabase::database("checksettings");
    else {
        if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
            dbcheck = QSqlDatabase::addDatabase("QSQLITE3", "checksettings");
        else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
            dbcheck = QSqlDatabase::addDatabase("QSQLITE", "checksettings");
    }

    QFile::remove(PQCConfigFiles::get().CACHE_DIR()+"/photoqt_check.db");
    QFile::copy(":/checksettings.db", PQCConfigFiles::get().CACHE_DIR()+"/photoqt_check.db");
    QFile::setPermissions(PQCConfigFiles::get().CACHE_DIR()+"/photoqt_check.db",
                          QFileDevice::WriteOwner|QFileDevice::ReadOwner |
                              QFileDevice::ReadGroup);
    dbcheck.setDatabaseName(PQCConfigFiles::get().CACHE_DIR()+"/photoqt_check.db");

    if(!dbcheck.open()) {
        qWarning() << "Error opening default database:" << dbcheck.lastError().text();
        return false;
    }

    QSqlQuery queryCheck(dbcheck);
    queryCheck.prepare("SELECT tablename,setting,minvalue,maxvalue FROM 'entries'");

    if(!queryCheck.exec()) {
        qWarning() << "Error getting default data:" << queryCheck.lastError().text();
        queryCheck.clear();
        QFile::remove(PQCConfigFiles::get().CACHE_DIR()+"/photoqt_check.db");
        return false;
    }

    QList<QList<QVariant> > toUpdate;

    // loop over check data
    while(queryCheck.next()) {

        const QString table = queryCheck.value(0).toString();
        const QString setting = queryCheck.value(1).toString();
        const double minValue = queryCheck.value(2).toDouble();
        const double maxValue = queryCheck.value(3).toDouble();

        QSqlQuery check(db);
        check.prepare(QString("SELECT value,datatype FROM '%1' WHERE name=:name").arg(table));
        check.bindValue(":name", setting);
        if(!check.exec()) {
            qWarning() << QString("Error checking entry '%1':").arg(setting) << check.lastError().text();
            continue;
        }
        if(check.next()) {

            const QString dt = check.value(1).toString();
            const double value = check.value(0).toDouble();

            if(value < minValue)
                toUpdate << (QList<QVariant>() << table << setting << dt << minValue);
            else if(value > maxValue)
                toUpdate << (QList<QVariant>() << table << setting << dt << maxValue);

        }

        check.clear();

    }

    queryCheck.clear();

    // update what needs fixing
    for(int i = 0; i < toUpdate.size(); ++i) {

        const QList<QVariant> lst = toUpdate.at(i);

        QSqlQuery query(db);

        query.prepare(QString("UPDATE %1 SET value=:val WHERE name=:name").arg(lst.at(0).toString()));
        query.bindValue(":name", lst.at(1).toString());
        if(lst.at(2).toString() == "double")
            query.bindValue(":val", lst.at(3).toDouble());
        if(lst.at(2).toString() == "int")
            query.bindValue(":val", static_cast<int>(lst.at(3).toDouble()));

        if(!query.exec()) {
            qWarning() << QString("Error updating entry '%1':").arg(lst.at(1).toString()) << query.lastError().text();
            continue;
        }

        query.clear();

    }

    dbcheck.close();
    QFile file(PQCConfigFiles::get().CACHE_DIR()+"/photoqt_check.db");
    if(!file.remove())
        qWarning() << "ERROR: Unable to remove check db:" << file.errorString();

    return true;

}

bool PQCValidate::validateShortcutsDatabase() {

    qDebug() << "";

    if(!QFile::exists(PQCConfigFiles::get().SHORTCUTS_DB())) {
        if(!QFile::copy(":/shortcuts.db", PQCConfigFiles::get().SHORTCUTS_DB()))
            qWarning() << "Unable to (re-)create default shortcuts database";
        else {
            QFile file(PQCConfigFiles::get().SHORTCUTS_DB());
            file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
        }
        return true;
    }

    QSqlDatabase db = QSqlDatabase::database("shortcuts");
    if(!db.open()) {
        qWarning() << "Error opening database:" << db.lastError().text();
        return false;
    }

    // make sure that the config table exists and contains version number
    QSqlQuery query(db);
    // check if config table exists
    if(!query.exec("SELECT name FROM sqlite_master WHERE type='table' AND name='config';")) {
        qCritical() << "Unable to verify existince of config table";
    } else {
        // the table does not exist
        if(!query.next()) {
            QSqlQuery queryNew(db);
            if(!queryNew.exec("CREATE TABLE 'config' ('name' TEXT UNIQUE, 'value' TEXT)")) {
                qCritical() << "Unable to create config table";
            } else {
                QSqlQuery queryEnter(db);
                // 4.9.1 was the last version with no version number in database, so this is the best we can do
                queryEnter.prepare("INSERT INTO 'config' (`name`, `value`) VALUES ('version', '4.9.1')");
                if(!queryEnter.exec()) {
                    qCritical() << "Unable to enter version in new config table";
                }
            }
        }
    }

    return true;

}
