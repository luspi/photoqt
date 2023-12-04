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

#include <iomanip>
#include <QFile>
#include <QtSql>
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
    if(!QFile::exists(PQCConfigFiles::SETTINGS_DB()))
        return 2;

    // last time a dev version was run
    QString version = PQCSettings::get()["generalVersion"].toString();
    if(version == "dev")
        return 3;

    // updated
    if(version != QString(VERSION))
        return 1;

    // nothing happened
    return 0;

}

void PQCStartup::exportData(QString path) {

    // use plain cout as we don't want any log/debug info prepended
    std::cout << std::endl
              << "PhotoQt v" << VERSION << std::endl
              << " > Exporting configuration to " << path.toStdString() << "... " << std::flush;

    if(PQCScriptsConfig::get().exportConfigTo(path))
        std::cout << " >> Done!" << std::endl << std::endl;
    else
        std::cout << " >> Failed!" << std::endl << std::endl;

}

void PQCStartup::importData(QString path) {

    // use plain cout as we don't want any log/debug info prepended
    std::cout << std::endl
              << "PhotoQt v" << VERSION << std::endl
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
    dir.mkpath(PQCConfigFiles::CONFIG_DIR());
    dir.mkpath(PQCConfigFiles::GENERIC_DATA_DIR());
    dir.mkpath(PQCConfigFiles::GENERIC_CACHE_DIR());
    dir.mkpath(QString("%1/thumbnails/normal/").arg(PQCConfigFiles::GENERIC_CACHE_DIR()));
    dir.mkpath(QString("%1/thumbnails/large/").arg(PQCConfigFiles::GENERIC_CACHE_DIR()));
    dir.mkpath(QString("%1/thumbnails/x-large/").arg(PQCConfigFiles::GENERIC_CACHE_DIR()));
    dir.mkpath(QString("%1/thumbnails/xx-large/").arg(PQCConfigFiles::GENERIC_CACHE_DIR()));

    /**************************************************************/
    // create default imageformats database
    if(!QFile::copy(":/imageformats.db", PQCConfigFiles::IMAGEFORMATS_DB()))
        qWarning() << "Unable to create default imageformats database";
    else {
        QFile file(PQCConfigFiles::IMAGEFORMATS_DB());
        file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
    }

    /**************************************************************/
    // create default settings database
    if(!QFile::copy(":/settings.db", PQCConfigFiles::SETTINGS_DB()))
        qWarning() << "Unable to create settings database";
    else {
        QFile file(PQCConfigFiles::SETTINGS_DB());
        file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
    }

    /**************************************************************/
    // create default location database
    if(!QFile::copy(":/location.db", PQCConfigFiles::LOCATION_DB()))
        qWarning() << "Unable to create location database";
    else {
        QFile file(PQCConfigFiles::LOCATION_DB());
        file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
    }

#ifdef Q_OS_WIN
    // these defaults are different on Windows as on Linux
    PQCSettings::get().update("filedialogDevices", true);
#endif

    /**************************************************************/
    // create default shortcuts database
    if(!QFile::copy(":/shortcuts.db", PQCConfigFiles::SHORTCUTS_DB()))
        qWarning() << "Unable to create shortcuts database";
    else {
        QFile file(PQCConfigFiles::SHORTCUTS_DB());
        file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
    }

    /**************************************************************/
    // create default contextmenu database
    if(!QFile::copy(":/contextmenu.db", PQCConfigFiles::CONTEXTMENU_DB()))
        qWarning() << "Unable to create default contextmenu database";
    else {
        QFile file(PQCConfigFiles::CONTEXTMENU_DB());
        file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
    }

    /**************************************************************/
    // create default imgurhistory database
    if(!QFile::copy(":/imgurhistory.db", PQCConfigFiles::SHAREONLINE_IMGUR_HISTORY_DB()))
        qWarning() << "Unable to create default imgurhistory database";
    else {
        QFile file(PQCConfigFiles::SHAREONLINE_IMGUR_HISTORY_DB());
        file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
    }

    /**************************************************************/

}

void PQCStartup::resetToDefaults() {

    std::cout << std::endl
              << "PhotoQt v" << VERSION << std::endl
              << " > Resetting to default configuration... " << std::flush;

    PQCSettings::get().setDefault();
    PQCShortcuts::get().setDefault();

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
