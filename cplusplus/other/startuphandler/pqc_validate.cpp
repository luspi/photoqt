/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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

    ret = validateImageFormatsDatabase();
    if(!ret) {
        std::cout << " >> Failed: imageformats db" << std::endl;
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
    if(thumb_cache_basedir != "") {
        dir.mkpath(thumb_cache_basedir);
        dir.mkpath(QString("%1/normal/").arg(thumb_cache_basedir));
        dir.mkpath(QString("%1/large/").arg(thumb_cache_basedir));
        dir.mkpath(QString("%1/x-large/").arg(thumb_cache_basedir));
        dir.mkpath(QString("%1/xx-large/").arg(thumb_cache_basedir));
    } else {
        dir.mkpath(PQCConfigFiles::get().THUMBNAIL_CACHE_DIR());
        dir.mkpath(QString("%1/normal/").arg(PQCConfigFiles::get().THUMBNAIL_CACHE_DIR()));
        dir.mkpath(QString("%1/large/").arg(PQCConfigFiles::get().THUMBNAIL_CACHE_DIR()));
        dir.mkpath(QString("%1/x-large/").arg(PQCConfigFiles::get().THUMBNAIL_CACHE_DIR()));
        dir.mkpath(QString("%1/xx-large/").arg(PQCConfigFiles::get().THUMBNAIL_CACHE_DIR()));
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
                    if(icn != "")
                        icn = PQCScriptsImages::get().loadImageAndConvertToBase64(icn);

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

bool PQCValidate::validateImageFormatsDatabase() {

    qDebug() << "";

    // the db does not exist -> create it and finish
    if(!QFile::exists(PQCConfigFiles::get().IMAGEFORMATS_DB())) {
        if(!QFile::copy(":/imageformats.db", PQCConfigFiles::get().IMAGEFORMATS_DB()))
            qWarning() << "Unable to (re-)create default imageformats database";
        else {
            QFile file(PQCConfigFiles::get().IMAGEFORMATS_DB());
            file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
        }
        return true;
    }

    // here we check all the image formats
    // we do so automatically by loading the default imageformats database and check that all items there are present in the actual one

    QSqlDatabase dbinstalled = QSqlDatabase::database("imageformats");

    if(!dbinstalled.open())
        qWarning() << "Error opening database:" << dbinstalled.lastError().text();

    QSqlDatabase dbdefault;
    if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
        dbdefault = QSqlDatabase::addDatabase("QSQLITE3", "imageformatsdefault");
    else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
        dbdefault = QSqlDatabase::addDatabase("QSQLITE", "imageformatsdefault");

    // open database
    const QString tmpfile = PQCConfigFiles::get().CACHE_DIR()+"/photoqt_tmp.db";
    if(QFileInfo::exists(tmpfile) && !QFile::remove(tmpfile))
        qWarning() << "Error removing old tmp file";
    if(!QFile::copy(":/imageformats.db", PQCConfigFiles::get().CACHE_DIR()+"/photoqt_tmp.db"))
        qWarning() << "Error copying default db to tmp file";
    QFile::setPermissions(tmpfile,
                          QFileDevice::WriteOwner|QFileDevice::ReadOwner |
                              QFileDevice::ReadGroup);
    dbdefault.setDatabaseName(PQCConfigFiles::get().CACHE_DIR()+"/photoqt_tmp.db");
    if(!dbdefault.open())
        qWarning() << "Error opening default database:" << dbdefault.lastError().text();

    QSqlQuery query(dbdefault);

    // get default columns
    query.prepare("PRAGMA table_info(imageformats)");
    if(!query.exec()) {
        qWarning() << "Error getting default columns:" << query.lastError().text();
        query.clear();
        dbdefault.close();
        QFile::remove(PQCConfigFiles::get().CACHE_DIR()+"/photoqt_tmp.db");
        return false;
    }

    // loop over default columns and make sure they all exist in installed db
    while(query.next()) {
        const QString col = query.value(1).toString();
        const QString type = query.value(2).toString();

        QSqlQuery query2(dbinstalled);
        query2.prepare("SELECT COUNT(*) AS count FROM pragma_table_info('imageformats') WHERE name=:name");
        query2.bindValue(":name", col);
        if(!query2.exec()) {
            qWarning() << "Error checking column existence:" << query2.lastError().text();
            query2.clear();
            dbdefault.close();
            QFile::remove(PQCConfigFiles::get().CACHE_DIR()+"/photoqt_tmp.db");
            return false;
        }
        query2.next();
        const int c = query2.value(0).toInt();

        // if column does not exist, add it
        if(c == 0) {
            QSqlQuery query3(dbinstalled);
            query3.prepare(QString("ALTER TABLE imageformats ADD %1 %2").arg(col, type));
            if(!query3.exec()) {
                qCritical() << "Error adding new column:" << query3.lastError().text();
                query3.clear();
                dbdefault.close();
                QFile::remove(PQCConfigFiles::get().CACHE_DIR()+"/photoqt_tmp.db");
                return false;
            }
            query3.clear();
        }
        query2.clear();

    }

    query.clear();

    // get reference data
    query.prepare("SELECT endings,uniqueid,mimetypes,description,category,enabled,qt,resvg,libvips,imagemagick,graphicsmagick,libraw,poppler,xcftools,devil,freeimage,archive,video,libmpv,im_gm_magick,qt_formatname FROM 'imageformats'");
    if(!query.exec()) {
        qWarning() << "Error getting default data:" << query.lastError().text();
        query.clear();
        dbdefault.close();
        QFile::remove(PQCConfigFiles::get().CACHE_DIR()+"/photoqt_tmp.db");
        return false;
    }

    // loop over reference data
    while(query.next()) {

        int c = 0;
        const QString endings = query.value(c++).toString();
        const int uniqueid = query.value(c++).toInt();
        const QString mimetypes = query.value(c++).toString();
        const QString description = query.value(c++).toString();
        const QString category = query.value(c++).toString();

        const QString enabled = query.value(c++).toString();
        const QString qt = query.value(c++).toString();
        const QString resvg = query.value(c++).toString();
        const QString libvips = query.value(c++).toString();
        const QString imagemagick = query.value(c++).toString();

        const QString graphicsmagick = query.value(c++).toString();
        const QString libraw = query.value(c++).toString();
        const QString poppler = query.value(c++).toString();
        const QString xcftools = query.value(c++).toString();
        const QString devil = query.value(c++).toString();

        const QString freeimage = query.value(c++).toString();
        const QString archive = query.value(c++).toString();
        const QString video = query.value(c++).toString();
        const QString libmpv = query.value(c++).toString();
        const QString im_gm_magick = query.value(c++).toString();

        const QString qt_formatname = query.value(c++).toString();

        // check whether an entry with that name exists in the in-production database
        QSqlQuery check(dbinstalled);
        check.prepare("SELECT count(endings) FROM imageformats WHERE endings=:endings");
        check.bindValue(":endings", endings);
        if(!check.exec()) {
            qWarning() << QString("Error checking ending (%1):").arg(endings) << check.lastError().text();
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
                qWarning() << QString("Error checking description (%1/%2):").arg(endings, description) << check.lastError().text();
                continue;
            }
            check.next();
            count = check.value(0).toInt();
            updateByEnding = false;
        }

        // if entry does not exist, add it
        if(count == 0) {

            QSqlQuery insquery(dbinstalled);
            insquery.prepare("INSERT INTO imageformats (endings,uniqueid,mimetypes,description,category,enabled,qt,resvg,libvips,imagemagick,graphicsmagick,libraw,poppler,xcftools,devil,freeimage,archive,video,libmpv,im_gm_magick,qt_formatname) VALUES(:endings,:uniqueid,:mimetypes,:description,:category,:enabled,:qt,:resvg,:libvips,:imagemagick,:graphicsmagick,:libraw,:poppler,:xcftools,:devil,:freeimage,:archive,:video,:libmpv,:im_gm_magick,:qt_formatname)");
            insquery.bindValue(":endings", endings);
            insquery.bindValue(":uniqueid", uniqueid);
            insquery.bindValue(":mimetypes", mimetypes);
            insquery.bindValue(":description", description);
            insquery.bindValue(":category", category);

            insquery.bindValue(":enabled", enabled);
            insquery.bindValue(":qt", qt);
            insquery.bindValue(":resvg", resvg);
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
                qWarning() << QString("ERROR inserting missing image format '%1':").arg(endings) << insquery.lastError().text();
                continue;
            }

        // if entry does exist, make sure defaultvalue and datatype is valid
        } else {

            QSqlQuery check(dbinstalled);
            if(updateByEnding)
                check.prepare("UPDATE imageformats SET  mimetypes=:mimetypes, uniqueid=:uniqueid, description=:description, category=:category, qt=:qt, resvg=:resvg, libvips=:libvips, imagemagick=:imagemagick, graphicsmagick=:graphicsmagick, libraw=:libraw, poppler=:poppler, xcftools=:xcftools, devil=:devil, freeimage=:freeimage, archive=:archive, video=:video, libmpv=:libmpv, im_gm_magick=:im_gm_magick, qt_formatname=:qt_formatname WHERE endings=:endings");
            else
                check.prepare("UPDATE imageformats SET  endings=:endings, uniqueid=:uniqueid, mimetypes=:mimetypes, category=:category, qt=:qt, resvg=:resvg, libvips=:libvips, imagemagick=:imagemagick, graphicsmagick=:graphicsmagick, libraw=:libraw, poppler=:poppler, xcftools=:xcftools, devil=:devil, freeimage=:freeimage, archive=:archive, video=:video, libmpv=:libmpv, im_gm_magick=:im_gm_magick, qt_formatname=:qt_formatname WHERE description=:description");

            check.bindValue(":endings", endings);
            check.bindValue(":uniqueid", uniqueid);
            check.bindValue(":mimetypes", mimetypes);
            check.bindValue(":description", description);
            check.bindValue(":category", category);
            check.bindValue(":qt", qt);
            check.bindValue(":resvg", resvg);
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
                qWarning() << QString("Error updating defaultvalue and datatype '%1':").arg(endings) << check.lastError().text();
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
        qWarning() << "Error getting default data (endings):" << queryInst.lastError().text();
        queryInst.clear();
        dbdefault.close();
        QFile::remove(PQCConfigFiles::get().CACHE_DIR()+"/photoqt_tmp.db");
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
            qWarning() << QString("Error checking for removed endings '%1':").arg(endings) << check.lastError().text();
            continue;
        }
        check.next();
        int count = check.value(0).toInt();
        if(count == 0)
            toBeRemoved << endings;

    }

    queryInst.clear();

    for(const auto &endings : std::as_const(toBeRemoved)) {

        QSqlQuery query(dbinstalled);
        query.prepare("DELETE FROM imageformats WHERE endings=:endings");
        query.bindValue(":endings", endings);
        if(!query.exec())
            qWarning() << QString("Error removing no longer used endings '%1':").arg(endings) << query.lastError().text();
        query.clear();

    }

    dbdefault.close();

    QFile file(PQCConfigFiles::get().CACHE_DIR()+"/photoqt_tmp.db");
    if(!file.remove())
        qWarning() << "ERROR: Unable to remove ref db:" << file.errorString();

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
