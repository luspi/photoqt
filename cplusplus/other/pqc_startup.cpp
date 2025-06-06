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

#include <QFile>
#include <QtSql/QSqlDatabase>
#include <QMessageBox>
#include <iostream>
#include <pqc_startup.h>
#include <pqc_configfiles.h>
#include <pqc_settings.h>
#include <pqc_shortcuts.h>
#include <pqc_validate.h>
#include <scripts/pqc_scriptsconfig.h>

PQCStartup::PQCStartup(QObject *parent) : QObject(parent) { }

// 0: no update
// 1: update
// 2: fresh install
int PQCStartup::check() {

    qDebug() << "";

    // check if sqlite is available
    if(!QSqlDatabase::isDriverAvailable("QSQLITE3") && !QSqlDatabase::isDriverAvailable("QSQLITE")) {
        //: This is the window title of an error message box
        QMessageBox::critical(0, QCoreApplication::translate("PQCStartup", "SQLite error"),
                              QCoreApplication::translate("PQCStartup", "You seem to be missing the SQLite driver for Qt. This is needed though for a few different things, like reading and writing the settings. Without it, PhotoQt cannot function!"));
        qCritical() << "ERROR: SQLite driver not available. Available drivers are:" << QSqlDatabase::drivers().join(",");
        qCritical() << "PhotoQt cannot function without SQLite available.";
        qApp->quit();
    }

    // if no ettings db exist, then it is a fresh install
    if(!QFile::exists(PQCConfigFiles::get().USERSETTINGS_DB())) {
        if(!QFile::exists(PQCConfigFiles::get().OLDSETTINGS_DB()))
            return 2;
        else {
            if(QFile::copy(PQCConfigFiles::get().OLDSETTINGS_DB(), PQCConfigFiles::get().USERSETTINGS_DB()))
                QFile::remove(PQCConfigFiles::get().OLDSETTINGS_DB());
            return 1;
        }
    }

    // last time a dev version was run
    // we need to figure this out WITHOUT using the PQCSettings class
    QSqlDatabase dbtmp;
    if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
        dbtmp = QSqlDatabase::addDatabase("QSQLITE3", "settingsversion");
    else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
        dbtmp = QSqlDatabase::addDatabase("QSQLITE", "settingsversion");
    dbtmp.setConnectOptions("QSQLITE_OPEN_READONLY");
    dbtmp.setDatabaseName(PQCConfigFiles::get().USERSETTINGS_DB());
    if(!dbtmp.open()) {
        qWarning() << "Unable to check how to handle multiple instances:" << dbtmp.lastError().text();
        qWarning() << "Assuming only a single instance is to be used";
    } else {
        QSqlQuery query(dbtmp);
        if(!query.exec("SELECT `value` FROM general WHERE `name`='Version'"))
            qWarning() << "Unable to check for generalVersion setting";
        else {
            if(query.next()) {
                QString ver = query.value(0).toString();
#ifndef NDEBUG
                query.clear();
                dbtmp.close();
                return 3;
#endif
                if(ver != QString(PQMVERSION)) {
                    query.clear();
                    dbtmp.close();
                    return 1;
                }
            }
        }
        query.clear();
        dbtmp.close();
    }

    // nothing happened
    return 0;

}

void PQCStartup::exportData(QString path) {

    // use plain cout as we don't want any log/debug info prepended
    std::cout << std::endl
              << "PhotoQt v" << PQMVERSION << std::endl
              << " > Exporting configuration to " << path.toStdString() << "... " << std::flush;

    if(PQCScriptsConfig::get().exportConfigTo(path))
        std::cout << " >> Done!" << std::endl << std::endl;
    else
        std::cout << " >> Failed!" << std::endl << std::endl;

}

void PQCStartup::importData(QString path) {

    // use plain cout as we don't want any log/debug info prepended
    std::cout << std::endl
              << "PhotoQt v" << PQMVERSION << std::endl
              << " > Importing configuration from " << path.toStdString() << "... " << std::flush;

    if(PQCScriptsConfig::get().importConfigFrom(path))
        std::cout << " >> Done!" << std::endl << std::endl;
    else
        std::cout << " >> Failed!" << std::endl << std::endl;

}

void PQCStartup::setupFresh() {

    qDebug() << "";

    /**************************************************************/
    // make sure necessary folder exist
    QDir dir;
    dir.mkpath(PQCConfigFiles::get().CONFIG_DIR());
    dir.mkpath(PQCConfigFiles::get().CACHE_DIR());
    dir.mkpath(QFileInfo(PQCConfigFiles::get().USER_PLACES_XBEL()).absolutePath());
    dir.mkpath(PQCConfigFiles::get().THUMBNAIL_CACHE_DIR());
    dir.mkpath(QString("%1/normal/").arg(PQCConfigFiles::get().THUMBNAIL_CACHE_DIR()));
    dir.mkpath(QString("%1/large/").arg(PQCConfigFiles::get().THUMBNAIL_CACHE_DIR()));
    dir.mkpath(QString("%1/x-large/").arg(PQCConfigFiles::get().THUMBNAIL_CACHE_DIR()));
    dir.mkpath(QString("%1/xx-large/").arg(PQCConfigFiles::get().THUMBNAIL_CACHE_DIR()));

    /**************************************************************/
    // create default imageformats database
    if(QFile::exists(PQCConfigFiles::get().IMAGEFORMATS_DB()))
        QFile::remove(PQCConfigFiles::get().IMAGEFORMATS_DB());
    if(!QFile::copy(":/imageformats.db", PQCConfigFiles::get().IMAGEFORMATS_DB()))
        qWarning() << "Unable to create default imageformats database";
    else {
        QFile file(PQCConfigFiles::get().IMAGEFORMATS_DB());
        file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
    }

    /**************************************************************/
    // create default settings database
    if(QFile::exists(PQCConfigFiles::get().USERSETTINGS_DB()))
        QFile::remove(PQCConfigFiles::get().USERSETTINGS_DB());
    if(!QFile::copy(":/usersettings.db", PQCConfigFiles::get().USERSETTINGS_DB()))
        qWarning() << "Unable to create settings database";
    else {
        QFile file(PQCConfigFiles::get().USERSETTINGS_DB());
        file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
    }

    /**************************************************************/
    // create default location database
    if(QFile::exists(PQCConfigFiles::get().LOCATION_DB()))
        QFile::remove(PQCConfigFiles::get().LOCATION_DB());
    if(!QFile::copy(":/location.db", PQCConfigFiles::get().LOCATION_DB()))
        qWarning() << "Unable to create location database";
    else {
        QFile file(PQCConfigFiles::get().LOCATION_DB());
        file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
    }

    /**************************************************************/
    // create default shortcuts database
    if(QFile::exists(PQCConfigFiles::get().SHORTCUTS_DB()))
        QFile::remove(PQCConfigFiles::get().SHORTCUTS_DB());
    if(!QFile::copy(":/shortcuts.db", PQCConfigFiles::get().SHORTCUTS_DB()))
        qWarning() << "Unable to create shortcuts database";
    else {
        QFile file(PQCConfigFiles::get().SHORTCUTS_DB());
        file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
    }

    /**************************************************************/
    // create default contextmenu database
    if(QFile::exists(PQCConfigFiles::get().CONTEXTMENU_DB()))
        QFile::remove(PQCConfigFiles::get().CONTEXTMENU_DB());
    if(!QFile::copy(":/contextmenu.db", PQCConfigFiles::get().CONTEXTMENU_DB()))
        qWarning() << "Unable to create default contextmenu database";
    else {
        QFile file(PQCConfigFiles::get().CONTEXTMENU_DB());
        file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
    }

    /**************************************************************/
    // create default imgurhistory database
    if(QFile::exists(PQCConfigFiles::get().SHAREONLINE_IMGUR_HISTORY_DB()))
        QFile::remove(PQCConfigFiles::get().SHAREONLINE_IMGUR_HISTORY_DB());
    if(!QFile::copy(":/imgurhistory.db", PQCConfigFiles::get().SHAREONLINE_IMGUR_HISTORY_DB()))
        qWarning() << "Unable to create default imgurhistory database";
    else {
        QFile file(PQCConfigFiles::get().SHAREONLINE_IMGUR_HISTORY_DB());
        file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
    }

    /**************************************************************/

}

void PQCStartup::resetToDefaults() {

    std::cout << std::endl
              << "PhotoQt v" << PQMVERSION << std::endl
              << " > Resetting to default configuration... " << std::flush;

    PQCScriptsConfig::get().resetToDefaultsWithConfirmation(true);

    std::cout << " >> Done!" << std::endl << std::endl;

}

/**************************************************************/
/**************************************************************/

void PQCStartup::showInfo() {

    std::cout << std::endl
              << " ** PhotoQt configuration:"
              << std::endl << std::endl
              << PQCScriptsConfig::get().getConfigInfo().toStdString()
              << std::endl;

}
