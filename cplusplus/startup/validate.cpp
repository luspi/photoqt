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

#include "validate.h"
#include "cplusplus/scripts/handlingexternal.h"

PQValidate::PQValidate(QObject *parent) : QObject(parent) {

}

bool PQValidate::validate() {

    LOG << NL
        << "PhotoQt v" << VERSION << NL
        << " > Validating configuration... " << NL;

    bool success = true;

    bool ret = validateDirectories();
    if(!ret) {
        LOG << " >> Failed: directories" << NL << NL;
        success = false;
    }

    ret = validateSettingsDatabase();
    if(!ret) {
        LOG << " >> Failed: settings db" << NL << NL;
        success = false;
    }

    ret = validateContextMenuDatabase();
    if(!ret) {
        LOG << " >> Failed: context menu db" << NL << NL;
        success = false;
    }

    ret = validateShortcutsDatabase();
    if(!ret) {
        LOG << " >> Failed: shortcuts db" << NL << NL;
        success = false;
    }

    ret = validateImageFormatsDatabase();
    if(!ret) {
        LOG << " >> Failed: imageformats db" << NL << NL;
        success = false;
    }

    ret = validateSettingsValues();
    if(!ret) {
        LOG << " >> Failed: settings values" << NL << NL;
        success = false;
    }

    ret = validatePositionsDatabase();
    if(!ret) {
        LOG << " >> Failed: positions db" << NL << NL;
        success = false;
    }

    LOG << " >> Done!" << NL << NL;
    return success;

}

bool PQValidate::validateDirectories() {

    // make sure necessary folder exist
    QDir dir;
    dir.mkpath(ConfigFiles::CONFIG_DIR());
    dir.mkpath(ConfigFiles::GENERIC_DATA_DIR());
    dir.mkpath(ConfigFiles::GENERIC_CACHE_DIR());
    dir.mkpath(QString("%1/thumbnails/large/").arg(ConfigFiles::GENERIC_CACHE_DIR()));

    return true;

}

bool PQValidate::validateContextMenuDatabase() {

    // the db does not exist -> create it and finish
    if(!QFile::exists(ConfigFiles::CONTEXTMENU_DB())) {
        if(!QFile::copy(":/contextmenu.db", ConfigFiles::CONTEXTMENU_DB()))
            LOG << CURDATE << "PQValidate::validateContextMenuDatabase(): unable to (re-)create default contextmenu database" << NL;
        else {
            QFile file(ConfigFiles::CONTEXTMENU_DB());
            file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
        }
        return true;
    }

    QSqlDatabase dbinstalled = QSqlDatabase::database("contextmenu");

    if(!dbinstalled.open())
        LOG << CURDATE << "PQValidate::validateContextMenuDatabase(): Error opening database: " << dbinstalled.lastError().text().trimmed().toStdString() << NL;

    QStringList newcols;
    newcols << "icon" << "TEXT"
            << "arguments" << "TEXT";

    for(int i = 0; i < newcols.length()/2; ++i) {

        QString col = newcols[2*i];
        QString typ = newcols[2*i +1];

        QSqlQuery query(dbinstalled);
        query.prepare("SELECT COUNT(*) AS count FROM pragma_table_info('entries') WHERE name=:col");
        query.bindValue(":col", col);
        if(!query.exec()) {
            LOG << CURDATE << "PQValidate::validateContextMenuDatabase(): Error checking existence of column '" << col.toStdString() << "': " << query.lastError().text().trimmed().toStdString() << NL;
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
                LOG << CURDATE << "PQValidate::validateContextMenuDatabase(): Error adding new column '" << col.toStdString() << "': " << query2.lastError().text().trimmed().toStdString() << NL;
                query2.clear();
                return false;
            }
            query2.clear();

            if(col == "arguments") {

                // split old 'command' into new 'command' and 'arguments'
                QSqlQuery query3(dbinstalled);
                query3.prepare("SELECT command,desc,close FROM `entries`");
                if(!query3.exec()) {
                    LOG << CURDATE << "PQValidate::validateContextMenuDatabase(): Error getting old 'command' data: " << query3.lastError().text().trimmed().toStdString() << NL;
                    query3.clear();
                    return false;
                }

                // compose list of new entries
                QList<QStringList> lst;
                PQHandlingExternal hand;
                while(query3.next()) {

                    QStringList parts = query3.value(0).toString().split(" ");

                    QString cmd = parts[0];
                    parts.removeFirst();
                    QString args = parts.join(" ");

                    QString icn = hand.getIconPathFromTheme(cmd);
                    if(icn != "")
                        icn = hand.loadImageAndConvertToBase64(icn);

                    QStringList cur;
                    cur << cmd
                        << args
                        << query3.value(1).toString()
                        << query3.value(2).toString()
                        << icn;

                    lst.append(cur);

                }

                query3.clear();

                QSqlQuery query4(dbinstalled);
                if(!query4.exec("DELETE FROM `entries`")) {
                    LOG << CURDATE << "PQValidate::validateContextMenuDatabase(): Error removing old data: " << query4.lastError().text().trimmed().toStdString() << NL;
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
                        LOG << CURDATE << "PQValidate::validateContextMenuDatabase(): Error adding new data: " << query5.lastError().text().trimmed().toStdString() << NL;
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

bool PQValidate::validateImageFormatsDatabase() {

    // the db does not exist -> create it and finish
    if(!QFile::exists(ConfigFiles::IMAGEFORMATS_DB())) {
        if(!QFile::copy(":/imageformats.db", ConfigFiles::IMAGEFORMATS_DB()))
            LOG << CURDATE << "PQValidate::validateImageFormatsDatabase(): unable to (re-)create default imageformats database" << NL;
        else {
            QFile file(ConfigFiles::IMAGEFORMATS_DB());
            file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
        }
        return true;
    }

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
    query.prepare("SELECT endings,mimetypes,description,category,enabled,qt,libvips,imagemagick,graphicsmagick,libraw,poppler,xcftools,devil,freeimage,archive,video,libmpv,im_gm_magick,qt_formatname FROM 'imageformats'");
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
        const QString libmpv = query.value(16).toString();
        const QString im_gm_magick = query.value(17).toString();
        const QString qt_formatname = query.value(18).toString();

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
            insquery.prepare("INSERT INTO imageformats (endings,mimetypes,description,category,enabled,qt,libvips,imagemagick,graphicsmagick,libraw,poppler,xcftools,devil,freeimage,archive,video,libmpv,im_gm_magick,qt_formatname) VALUES(:endings,:mimetypes,:description,:category,:enabled,:qt,:libvips,:imagemagick,:graphicsmagick,:libraw,:poppler,:xcftools,:devil,:freeimage,:archive,:video,:libmpv,:im_gm_magick,:qt_formatname)");
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
            insquery.bindValue(":libmpv", libmpv);
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
                check.prepare("UPDATE imageformats SET  mimetypes=:mimetypes, description=:description, category=:category, qt=:qt, libvips=:libvips, imagemagick=:imagemagick, graphicsmagick=:graphicsmagick, libraw=:libraw, poppler=:poppler, xcftools=:xcftools, devil=:devil, freeimage=:freeimage, archive=:archive, video=:video, libmpv=:libmpv, im_gm_magick=:im_gm_magick, qt_formatname=:qt_formatname WHERE endings=:endings");
            else
                check.prepare("UPDATE imageformats SET  endings=:endings, mimetypes=:mimetypes, category=:category, qt=:qt, libvips=:libvips, imagemagick=:imagemagick, graphicsmagick=:graphicsmagick, libraw=:libraw, poppler=:poppler, xcftools=:xcftools, devil=:devil, freeimage=:freeimage, archive=:archive, video=:video, libmpv=:libmpv, im_gm_magick=:im_gm_magick, qt_formatname=:qt_formatname WHERE description=:description");

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
            check.bindValue(":libmpv", libmpv);
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


    QSqlQuery queryInst(dbinstalled);
    // now we check for entries that should be removed
    queryInst.prepare("SELECT endings FROM 'imageformats'");
    if(!queryInst.exec()) {
        LOG << CURDATE << "PQValidate::validateImageFormatsDatabase(): Error getting default data (endings): " << queryInst.lastError().text().trimmed().toStdString() << NL;
        queryInst.clear();
        dbdefault.close();
        QFile::remove(ConfigFiles::CACHE_DIR()+"/photoqt_tmp.db");
        return false;
    }

    QStringList toBeRemoved;

    // loop over reference data
    while(queryInst.next()) {

        const QString endings = queryInst.value(0).toString();

        QSqlQuery check(dbdefault);
        check.prepare("SELECT count(endings) FROM imageformats WHERE endings=:endings");
        check.bindValue(":endings", endings);
        if(!check.exec()) {
            LOG << CURDATE << "PQValidate::validateImageFormatsDatabase(): Error checking for removed endings: " << endings.toStdString() << ": " << check.lastError().text().trimmed().toStdString() << NL;
            continue;
        }
        check.next();
        int count = check.value(0).toInt();
        if(count == 0)
            toBeRemoved << endings;

    }

    queryInst.clear();

    for(const auto &endings : qAsConst(toBeRemoved)) {

        QSqlQuery query(dbinstalled);
        query.prepare("DELETE FROM imageformats WHERE endings=:endings");
        query.bindValue(":endings", endings);
        if(!query.exec())
            LOG << CURDATE << "PQValidate::validateImageFormatsDatabase(): Error removing no longer used endings: " << endings.toStdString() << ": " << query.lastError().text().trimmed().toStdString() << NL;
        query.clear();

    }

    dbdefault.close();

    QFile file(ConfigFiles::CACHE_DIR()+"/photoqt_tmp.db");
    if(!file.remove())
        LOG << CURDATE << "PQValidate::validateImageFormatsDatabase(): ERROR: Unable to remove ref db: " << file.errorString().toStdString() << NL;

    return true;

}

bool PQValidate::validateSettingsDatabase() {

    // the db does not exist -> create it and finish
    if(!QFile::exists(ConfigFiles::SETTINGS_DB())) {
        if(!QFile::copy(":/settings.db", ConfigFiles::SETTINGS_DB()))
            LOG << CURDATE << "PQValidate::validateSettingsDatabase(): unable to (re-)create default settings database" << NL;
        else {
            QFile file(ConfigFiles::SETTINGS_DB());
            file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
        }
        return true;
    }

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

                // new settings that are based on old settings
                if(name == "PreviewColorIntensity") {

                    // muted colors?
                    bool muted = false;
                    QSqlQuery qCheck(dbinstalled);
                    if(!qCheck.exec("SELECT `value` FROM `openfile` WHERE `name`='PreviewMuted'")) {
                        LOG << CURDATE << "PQValidate::validateSettingsDatabase(): Error checking PreviewMuted setting: " << qCheck.lastError().text().trimmed().toStdString() << NL;
                        continue;
                    }
                    qCheck.next();
                    muted = qCheck.value(0).toBool();

                    // full colors?
                    bool full = false;
                    qCheck.clear();
                    if(!qCheck.exec("SELECT `value` FROM `openfile` WHERE `name`='PreviewFullColors'")) {
                        LOG << CURDATE << "PQValidate::validateSettingsDatabase(): Error checking PreviewFullColors setting: " << qCheck.lastError().text().trimmed().toStdString() << NL;
                        continue;
                    }
                    qCheck.next();
                    full = qCheck.value(0).toBool();
                    qCheck.clear();

                    if(full) {
                        QSqlQuery queryupd(dbinstalled);
                        if(!queryupd.exec("UPDATE `openfile` SET `value`=10 WHERE `name`='PreviewColorIntensity'")) {
                            LOG << CURDATE << "PQValidate::validateSettingsDatabase(): Error updating PreviewColorIntensity setting with full colors: " << queryupd.lastError().text().trimmed().toStdString() << NL;
                            continue;
                        }
                        queryupd.clear();
                    } else if(muted) {
                        QSqlQuery queryupd(dbinstalled);
                        if(!queryupd.exec("UPDATE `openfile` SET `value`=3 WHERE `name`='PreviewColorIntensity'")) {
                            LOG << CURDATE << "PQValidate::validateSettingsDatabase(): Error updating PreviewColorIntensity setting with muted colors: " << queryupd.lastError().text().trimmed().toStdString() << NL;
                            continue;
                        }
                        queryupd.clear();
                    }

                    // delete old setting names
                    QSqlQuery queryDel(dbinstalled);
                    if(!queryDel.exec("DELETE FROM `openfile` WHERE `name`='PreviewMuted' OR `name`='PreviewFullColors'"))
                        LOG << CURDATE << "PQValidate::validateSettingsDatabase(): Error deleting old settings PreviewMuted and PreviewFullColors: " << queryDel.lastError().text().trimmed().toStdString() << NL;
                    queryDel.clear();
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

    // This is also called in PQStartup::migrateShortcutsToDb()
    // and PQHandlingExternal::importConfigFrom()

    // the db does not exist -> create it and finish
    if(!QFile::exists(ConfigFiles::SHORTCUTS_DB())) {
        if(!QFile::copy(":/shortcuts.db", ConfigFiles::SHORTCUTS_DB()))
            LOG << CURDATE << "PQValidate::validateShortcutsDatabase(): unable to (re-)create default shortcuts database" << NL;
        else {
            QFile file(ConfigFiles::SHORTCUTS_DB());
            file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
        }
        return true;
    }

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

    // check for status of database
    QSqlQuery query(dbinstalled);
    if(!query.exec("SELECT count() FROM PRAGMA_TABLE_INFO('shortcuts')")) {
        LOG << CURDATE << "PQValidate::validateShortcutsDatabase(): Error checking for 'shortcuts' columns: " << query.lastError().text().trimmed().toStdString() << NL;
        query.clear();
        return false;
    }

    query.next();
    int c = query.value(0).toInt();
    query.clear();

    // c==0 means that there is no shortcuts table yet
    // and this implies the database still needs to be converted
    if(c == 0) {

        // converting the old database to the new format is relatively straight forward
        // as we can keep the old two tables around since the new table is called something different

        // create new table
        QSqlQuery query(dbinstalled);
        if(!query.exec("CREATE TABLE 'shortcuts' (`combo` TEXT UNIQUE,`commands` TEXT,`cycle` INTEGER,`cycletimeout` INTEGER,`simultaneous` INTEGER)")) {
            LOG << CURDATE << "PQValidate::validateShortcutsDatabase(): ERROR: Unable to create new shortcuts table: " << query.lastError().text().trimmed().toStdString() << NL;
            query.clear();
            return false;
        }

        // then we load the old data into a map
        QMap<QString, QStringList> data;

        // first the builtin data
        if(!query.exec("SELECT command,shortcuts FROM builtin")) {
            LOG << CURDATE << "PQValidate::validateShortcutsDatabase(): ERROR: Unable to read old builtin data: " << query.lastError().text().trimmed().toStdString() << NL;
            query.clear();
            return false;
        }

        while(query.next()) {

            const QString cmd = query.value(0).toString();
            const QStringList sh = query.value(1).toString().split(", ");

            for(const QString &s : sh) {

                if(s == "")
                    continue;

                // The default database does not have a space after the comma in this one case
                if(s == "Escape,O") {
                    if(data.keys().contains("Escape"))
                        data["Escape"].push_back(cmd);
                    else
                        data["Escape"] = QStringList() << cmd;
                    if(data.keys().contains("O"))
                        data["O"].push_back(cmd);
                    else
                        data["O"] = QStringList() << cmd;
                } else {

                    if(data.keys().contains(s))
                        data[s.trimmed()].push_back(cmd);
                    else
                        data[s.trimmed()] = QStringList() << cmd;

                }

            }

        }

        query.clear();

        // then the external data
        if(!query.exec("SELECT command,arguments,shortcuts,close FROM external")) {
            LOG << CURDATE << "PQValidate::validateShortcutsDatabase(): ERROR: Unable to read old external data: " << query.lastError().text().trimmed().toStdString() << NL;
            query.clear();
            return false;
        }

        while(query.next()) {

            QString cmd = query.value(0).toString();
            QString args = query.value(1).toString();
            const QString sh = query.value(2).toString();
            const int close = query.value(3).toInt();

            if(sh == "")
                continue;

            if(args.trimmed() == "" && cmd.contains(":://:://::")) {
                args = cmd.split(":://:://::")[1];
                cmd = cmd.split(":://:://::")[0];
            }

            QString val = QString("%1:/:/:%2:/:/:%3").arg(cmd).arg(args).arg(close);

            if(data.keys().contains(sh))
                data[sh.trimmed()].push_back(val);
            else
                data[sh.trimmed()] = QStringList() << val;

        }

        dbinstalled.transaction();

        QMapIterator<QString, QStringList> iter(data);
        while (iter.hasNext()) {
            iter.next();

            QSqlQuery query(dbinstalled);

            const QString sh = iter.key();
            const QStringList cmd = iter.value();
            if(cmd.length() == 0)
                continue;
            else if(cmd.length() == 1)
                query.prepare("INSERT INTO 'shortcuts' (`combo`,`commands`,`cycle`,`cycletimeout`,`simultaneous`) VALUES (:combo, :cmd, 1, 0, 0)");
            else
                query.prepare("INSERT INTO 'shortcuts' (`combo`,`commands`,`cycle`,`cycletimeout`,`simultaneous`) VALUES (:combo, :cmd, 0, 0, 1)");

            query.bindValue(":combo", sh);
            query.bindValue(":cmd", cmd);

            if(!query.exec()) {
                LOG << CURDATE << "PQValidate::validateShortcutsDatabase(): ERROR: Unable to write new data: " << query.lastError().text().trimmed().toStdString() << NL;
                query.clear();
                return false;
            }

            query.clear();

        }

        dbinstalled.commit();
        if(dbinstalled.lastError().text().trimmed().length()) {
            LOG << "PQValidate::validateShortcutsDatabase(): ERROR committing database: "
                << dbinstalled.lastError().text().trimmed().toStdString()
                << NL;
            return false;
        }

    }

    return true;

}

bool PQValidate::validateSettingsValues() {

    QSqlDatabase dbinstalled = QSqlDatabase::database("settings");

    QSqlDatabase dbcheck;
    if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
        dbcheck = QSqlDatabase::addDatabase("QSQLITE3", "checksettings");
    else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
        dbcheck = QSqlDatabase::addDatabase("QSQLITE", "checksettings");
    else {
        LOG << CURDATE << "PQCheckSettings::check(): ERROR: SQLite driver not available. Available drivers are: " << QSqlDatabase::drivers().join(",").toStdString() << NL;
        LOG << CURDATE << "PQCheckSettings::check(): PhotoQt cannot function without SQLite available." << NL;
        return false;
    }

    QFile::remove(ConfigFiles::CACHE_DIR()+"/photoqt_check.db");
    QFile::copy(":/checksettings.db", ConfigFiles::CACHE_DIR()+"/photoqt_check.db");
    QFile::setPermissions(ConfigFiles::CACHE_DIR()+"/photoqt_check.db",
                          QFileDevice::WriteOwner|QFileDevice::ReadOwner |
                          QFileDevice::ReadGroup);
    dbcheck.setDatabaseName(ConfigFiles::CACHE_DIR()+"/photoqt_check.db");

    if(!dbcheck.open())
        LOG << CURDATE << "PQCheckSettings::check(): Error opening default database: " << dbcheck.lastError().text().trimmed().toStdString() << NL;

    QSqlQuery queryCheck(dbcheck);
    queryCheck.prepare("SELECT tablename,setting,minvalue,maxvalue FROM 'entries'");

    if(!queryCheck.exec()) {
        LOG << CURDATE << "PQCheckSettings::check(): Error getting default data: " << queryCheck.lastError().text().trimmed().toStdString() << NL;
        queryCheck.clear();
        QFile::remove(ConfigFiles::CACHE_DIR()+"/photoqt_check.db");
        return false;
    }

    QList<QList<QVariant> > toUpdate;

    // loop over check data
    while(queryCheck.next()) {

        const QString table = queryCheck.value(0).toString();
        const QString setting = queryCheck.value(1).toString();
        const double minValue = queryCheck.value(2).toDouble();
        const double maxValue = queryCheck.value(3).toDouble();

        QSqlQuery check(dbinstalled);
        check.prepare(QString("SELECT value,datatype FROM '%1' WHERE name=:name").arg(table));
        check.bindValue(":name", setting);
        if(!check.exec()) {
            LOG << CURDATE << "PQCheckSettings::check(): Error checking entry: " << setting.toStdString() << ": " << check.lastError().text().trimmed().toStdString() << NL;
            continue;
        }
        check.next();

        const QString dt = check.value(1).toString();

        const double value = check.value(0).toDouble();

        if(value < minValue)
            toUpdate << (QList<QVariant>() << table << setting << dt << minValue);
        else if(value > maxValue)
            toUpdate << (QList<QVariant>() << table << setting << dt << maxValue);

        check.clear();


    }

    queryCheck.clear();

    // update what needs fixing
    for(int i = 0; i < toUpdate.size(); ++i) {
        QList<QVariant> lst = toUpdate.at(i);

        QSqlQuery query(dbinstalled);

        query.prepare(QString("UPDATE %1 SET value=:val WHERE name=:name").arg(lst.at(0).toString()));
        query.bindValue(":name", lst.at(1).toString());
        if(lst.at(2).toString() == "double")
            query.bindValue(":val", lst.at(3).toDouble());
        if(lst.at(2).toString() == "int")
            query.bindValue(":val", static_cast<int>(lst.at(3).toDouble()));

        if(!query.exec()) {
            LOG << CURDATE << "PQCheckSettings::check(): Error updating entry: " << lst.at(1).toString().toStdString() << ": " << query.lastError().text().trimmed().toStdString() << NL;
            continue;
        }

        query.clear();

     }

    dbcheck.close();

    QFile file(ConfigFiles::CACHE_DIR()+"/photoqt_check.db");
    if(!file.remove())
        LOG << CURDATE << "PQCheckSettings::check(): ERROR: Unable to remove check db: " << file.errorString().toStdString() << NL;

    return true;

}

bool PQValidate::validatePositionsDatabase() {

    // the db does not exist -> create it and finish
    if(!QFile::exists(ConfigFiles::POSITIONS_DB())) {
        if(!QFile::copy(":/positions.db", ConfigFiles::POSITIONS_DB()))
            LOG << CURDATE << "PQValidate::validatePositionsDatabase(): unable to (re-)create default positions database" << NL;
        else {
            QFile file(ConfigFiles::POSITIONS_DB());
            file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
        }
    }

    return true;

}
