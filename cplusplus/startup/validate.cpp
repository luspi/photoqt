/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

    ret = validateImageFormatsDatabase();
    if(!ret) {
        LOG << " >> Failed!" << NL << NL;
        return false;
    }

    LOG << " >> Done!" << NL << NL;
    return true;

}

bool PQValidate::validateImageFormatsDatabase() {

    // here we check all the image formats
    // we do so automatically by loading the default imageformats database and check that all items there are present in the actual one

    QSqlDatabase dbinstalled = QSqlDatabase::database("imageformats");

    QSqlDatabase dbdefault;
    if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
        dbdefault = QSqlDatabase::addDatabase("QSQLITE3", "imageformatsdefault");
    else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
        dbdefault = QSqlDatabase::addDatabase("QSQLITE", "imageformatsdefault");
    else {
        LOG << CURDATE << "PQValidate::validateImageFormatsDatabase(): ERROR: SQLite driver not available. Available drivers are: " << QSqlDatabase::drivers().join(",").toStdString() << NL;
        LOG << CURDATE << "PQValidate::validateImageFormatsDatabase(): PhotoQt cannot function without SQLite available." << NL;
        return false;
    }

    // open database
    QFile::remove(ConfigFiles::CACHE_DIR()+"/photoqt_tmp.db");
    QFile::copy(":/imageformats.db", ConfigFiles::CACHE_DIR()+"/photoqt_tmp.db");
    QFile::setPermissions(ConfigFiles::CACHE_DIR()+"/photoqt_tmp.db",
                          QFileDevice::WriteOwner|QFileDevice::ReadOwner |
                          QFileDevice::ReadGroup);
    dbdefault.setDatabaseName(ConfigFiles::CACHE_DIR()+"/photoqt_tmp.db");
    if(!dbdefault.open())
        LOG << CURDATE << "PQValidate::validateImageFormatsDatabase(): Error opening default database: " << dbdefault.lastError().text().trimmed().toStdString() << NL;

    QSqlQuery query(dbdefault);

    // get default columns
    query.prepare("PRAGMA table_info(imageformats)");
    if(!query.exec()) {
        LOG << CURDATE << "PQValidate::validateImageFormatsDatabase(): Error getting default columns: " << query.lastError().text().trimmed().toStdString() << NL;
        query.clear();
        dbdefault.close();
        QFile::remove(ConfigFiles::CACHE_DIR()+"/photoqt_tmp.db");
        return false;
    }

    // loop over default columns and make sure they all exist in installed db
    while(query.next()) {
        QString col = query.value(1).toString();
        QString type = query.value(2).toString();

        QSqlQuery query2(dbinstalled);
        query2.prepare("SELECT COUNT(*) AS count FROM pragma_table_info('imageformats') WHERE name=:name");
        query2.bindValue(":name", col);
        if(!query2.exec()) {
            LOG << CURDATE << "PQValidate::validateImageFormatsDatabase(): Error checking column existence: " << query2.lastError().text().trimmed().toStdString() << NL;
            query2.clear();
            dbdefault.close();
            QFile::remove(ConfigFiles::CACHE_DIR()+"/photoqt_tmp.db");
            return false;
        }
        query2.next();
        int c = query2.value(0).toInt();

        // if column does not exist, add it
        if(c == 0) {
            QSqlQuery query3(dbinstalled);
            query3.prepare(QString("ALTER TABLE imageformats ADD %1 %2").arg(col).arg(type));
            if(!query3.exec()) {
                LOG << CURDATE << "PQValidate::validateImageFormatsDatabase(): Error adding new column: " << query3.lastError().text().trimmed().toStdString() << NL;
                query3.clear();
                dbdefault.close();
                QFile::remove(ConfigFiles::CACHE_DIR()+"/photoqt_tmp.db");
                return false;
            }
            query3.clear();
        }
        query2.clear();

    }

    query.clear();

    // get reference data
    query.prepare("SELECT endings,mimetypes,description,category,enabled,qt,libvips,imagemagick,graphicsmagick,libraw,poppler,xcftools,devil,freeimage,archive,video,im_gm_magick,qt_formatname FROM 'imageformats'");
    if(!query.exec()) {
        LOG << CURDATE << "PQValidate::validateImageFormatsDatabase(): Error getting default data: " << query.lastError().text().trimmed().toStdString() << NL;
        query.clear();
        dbdefault.close();
        QFile::remove(ConfigFiles::CACHE_DIR()+"/photoqt_tmp.db");
        return false;
    }

    // loop over reference data
    while(query.next()) {

        const QString endings = query.value(0).toString();
        const QString mimetypes = query.value(1).toString();
        const QString description = query.value(2).toString();
        const QString category = query.value(3).toString();
        const QString enabled = query.value(4).toString();

        const QString qt = query.value(5).toString();
        const QString libvips = query.value(6).toString();
        const QString imagemagick = query.value(7).toString();
        const QString graphicsmagick = query.value(8).toString();
        const QString libraw = query.value(9).toString();

        const QString poppler = query.value(10).toString();
        const QString xcftools = query.value(11).toString();
        const QString devil = query.value(12).toString();
        const QString freeimage = query.value(13).toString();
        const QString archive = query.value(14).toString();

        const QString video = query.value(15).toString();
        const QString im_gm_magick = query.value(16).toString();
        const QString qt_formatname = query.value(17).toString();

        // check whether an entry with that name exists in the in-production database
        QSqlQuery check(dbinstalled);
        check.prepare("SELECT count(endings) FROM imageformats WHERE endings=:endings");
        check.bindValue(":endings", endings);
        if(!check.exec()) {
            LOG << CURDATE << "PQValidate::validateImageFormatsDatabase(): Error checking ending: " << endings.toStdString() << ": " << check.lastError().text().trimmed().toStdString() << NL;
            continue;
        }
        check.next();
        int count = check.value(0).toInt();

        check.clear();

        bool updateByEnding = true;

        // if ENDINGS does not exist, check for description
        if(count == 0) {
            QSqlQuery check(dbinstalled);
            check.prepare("SELECT count(description) FROM imageformats WHERE description=:description");
            check.bindValue(":description", description);
            if(!check.exec()) {
                LOG << CURDATE << "PQValidate::validateImageFormatsDatabase(): Error checking description: " << endings.toStdString() << "/" << description.toStdString() << ": " << check.lastError().text().trimmed().toStdString() << NL;
                continue;
            }
            check.next();
            count = check.value(0).toInt();
            updateByEnding = false;
        }

        // if entry does not exist, add it
        if(count == 0) {

            QSqlQuery insquery(dbinstalled);
            insquery.prepare("INSERT INTO imageformats (endings,mimetypes,description,category,enabled,qt,libvips,imagemagick,graphicsmagick,libraw,poppler,xcftools,devil,freeimage,archive,video,im_gm_magick,qt_formatname) VALUES(:endings,:mimetypes,:description,:category,:enabled,:qt,:libvips,:imagemagick,:graphicsmagick,:libraw,:poppler,:xcftools,:devil,:freeimage,:archive,:video,:im_gm_magick,:qt_formatname)");
            insquery.bindValue(":endings", endings);
            insquery.bindValue(":mimetypes", mimetypes);
            insquery.bindValue(":description", description);
            insquery.bindValue(":category", category);
            insquery.bindValue(":enabled", enabled);

            insquery.bindValue(":qt", qt);
            insquery.bindValue(":libvips", libvips);
            insquery.bindValue(":imagemagick", imagemagick);
            insquery.bindValue(":graphicsmagick", graphicsmagick);
            insquery.bindValue(":libraw",libraw );

            insquery.bindValue(":poppler", poppler);
            insquery.bindValue(":xcftools", xcftools);
            insquery.bindValue(":devil", devil);
            insquery.bindValue(":freeimage", freeimage);
            insquery.bindValue(":archive", archive);

            insquery.bindValue(":video", video);
            insquery.bindValue(":im_gm_magick", im_gm_magick);
            insquery.bindValue(":qt_formatname", qt_formatname);

            if(!insquery.exec()) {
                LOG << CURDATE << "PQValidate::validateImageFormatsDatabase(): ERROR inserting missing image format " << endings.toStdString() << ": " << insquery.lastError().text().trimmed().toStdString() << NL;
                continue;
            }

        // if entry does exist, make sure defaultvalue and datatype is valid
        } else {

            QSqlQuery check(dbinstalled);
            if(updateByEnding)
                check.prepare("UPDATE imageformats SET  mimetypes=:mimetypes, description=:description, category=:category, qt=:qt, libvips=:libvips, imagemagick=:imagemagick, graphicsmagick=:graphicsmagick, libraw=:libraw, poppler=:poppler, xcftools=:xcftools, devil=:devil, freeimage=:freeimage, archive=:archive, video=:video, im_gm_magick=:im_gm_magick, qt_formatname=:qt_formatname WHERE endings=:endings");
            else
                check.prepare("UPDATE imageformats SET  endings=:endings, mimetypes=:mimetypes, category=:category, qt=:qt, libvips=:libvips, imagemagick=:imagemagick, graphicsmagick=:graphicsmagick, libraw=:libraw, poppler=:poppler, xcftools=:xcftools, devil=:devil, freeimage=:freeimage, archive=:archive, video=:video, im_gm_magick=:im_gm_magick, qt_formatname=:qt_formatname WHERE description=:description");

            check.bindValue(":endings", endings);
            check.bindValue(":mimetypes", mimetypes);
            check.bindValue(":description", description);
            check.bindValue(":category", category);
            check.bindValue(":qt", qt);
            check.bindValue(":libvips", libvips);
            check.bindValue(":imagemagick", imagemagick);
            check.bindValue(":graphicsmagick", graphicsmagick);
            check.bindValue(":libraw", libraw);
            check.bindValue(":poppler", poppler);
            check.bindValue(":xcftools", xcftools);
            check.bindValue(":devil", devil);
            check.bindValue(":freeimage", freeimage);
            check.bindValue(":archive", archive);
            check.bindValue(":video", video);
            check.bindValue(":im_gm_magick", im_gm_magick);
            check.bindValue(":qt_formatname", qt_formatname);

            if(!check.exec()) {
                LOG << CURDATE << "PQValidate::validateImageFormatsDatabase(): Error updating defaultvalue and datatype: " << endings.toStdString() << ": " << check.lastError().text().trimmed().toStdString() << NL;
                continue;
            }
            check.clear();

        }

    }

    query.clear();

    dbdefault.close();

    QFile file(ConfigFiles::CACHE_DIR()+"/photoqt_tmp.db");
    if(!file.remove())
        LOG << CURDATE << "PQValidate::validateImageFormatsDatabase(): ERROR: Unable to remove ref db: " << file.errorString().toStdString() << NL;

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
    QFile::remove(ConfigFiles::CACHE_DIR()+"/photoqt_tmp.db");
    QFile::copy(":/settings.db", ConfigFiles::CACHE_DIR()+"/photoqt_tmp.db");
    QFile::setPermissions(ConfigFiles::CACHE_DIR()+"/photoqt_tmp.db",
                          QFileDevice::WriteOwner|QFileDevice::ReadOwner |
                          QFileDevice::ReadGroup);
    dbdefault.setDatabaseName(ConfigFiles::CACHE_DIR()+"/photoqt_tmp.db");
    if(!dbdefault.open())
        LOG << CURDATE << "PQValidate::validateSettingsDatabase(): Error opening default database: " << dbdefault.lastError().text().trimmed().toStdString() << NL;

    // read the list of all tables from the default database
    QStringList tables;

    QSqlQuery queryTables("SELECT name FROM sqlite_master WHERE type IN ('table','view') AND name NOT LIKE 'sqlite_%' ORDER BY 1;", dbdefault);
    if(!queryTables.exec()) {
        LOG << CURDATE << "PQValidate::validateSettingsDatabase(): Error getting list of tables: " << queryTables.lastError().text().trimmed().toStdString() << NL;
        queryTables.clear();
        QFile::remove(ConfigFiles::CACHE_DIR()+"/photoqt_tmp.db");
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
            QFile::remove(ConfigFiles::CACHE_DIR()+"/photoqt_tmp.db");
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

    dbdefault.close();

    QFile file(ConfigFiles::CACHE_DIR()+"/photoqt_tmp.db");
    if(!file.remove())
        LOG << CURDATE << "PQValidate::validateSettingsDatabase(): ERROR: Unable to remove ref db: " << file.errorString().toStdString() << NL;

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
    QFile::remove(ConfigFiles::CACHE_DIR()+"/photoqt_tmp.db");
    QFile::copy(":/shortcuts.db", ConfigFiles::CACHE_DIR()+"/photoqt_tmp.db");
    QFile::setPermissions(ConfigFiles::CACHE_DIR()+"/photoqt_tmp.db",
                          QFileDevice::WriteOwner|QFileDevice::ReadOwner |
                          QFileDevice::ReadGroup);
    dbdefault.setDatabaseName(ConfigFiles::CACHE_DIR()+"/photoqt_tmp.db");
    if(!dbdefault.open())
        LOG << CURDATE << "PQValidate::validateShortcutsDatabase(): Error opening default database: " << dbdefault.lastError().text().trimmed().toStdString() << NL;

    QSqlQuery query(dbdefault);

    // get reference data
    query.prepare("SELECT category,command,shortcuts,defaultshortcuts FROM 'builtin'");
    if(!query.exec()) {
        LOG << CURDATE << "PQValidate::validateShortcutsDatabase(): Error getting default data: " << query.lastError().text().trimmed().toStdString() << NL;
        query.clear();
        QFile::remove(ConfigFiles::CACHE_DIR()+"/photoqt_tmp.db");
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

    dbdefault.close();

    QFile file(ConfigFiles::CACHE_DIR()+"/photoqt_tmp.db");
    if(!file.remove())
        LOG << CURDATE << "PQValidate::validateShortcutsDatabase(): ERROR: Unable to remove ref db: " << file.errorString().toStdString() << NL;

    return true;

}
