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

    QSqlDatabase db_context;
    QSqlDatabase db_imageformats;
    QSqlDatabase db_location;

    // check if sqlite is available
    // this is a hard requirement now and we wont launch PhotoQt without it
    if(QSqlDatabase::isDriverAvailable("QSQLITE3")) {
        db_context = QSqlDatabase::addDatabase("QSQLITE3", "contextmenu");
        db_imageformats = QSqlDatabase::addDatabase("QSQLITE3", "imageformats");
        db_location = QSqlDatabase::addDatabase("QSQLITE3", "location");
    } else if(QSqlDatabase::isDriverAvailable("QSQLITE")) {
        db_context = QSqlDatabase::addDatabase("QSQLITE", "contextmenu");
        db_imageformats = QSqlDatabase::addDatabase("QSQLITE", "imageformats");
        db_location = QSqlDatabase::addDatabase("QSQLITE", "location");
    } else {
        //: This is the window title of an error message box
        QMessageBox::critical(0, QCoreApplication::translate("PQCStartup", "SQLite error"),
                              QCoreApplication::translate("PQCStartup", "You seem to be missing the SQLite driver for Qt. This is needed though for a few different things, like reading and writing the settings. Without it, PhotoQt cannot function!"));
        qCritical() << "ERROR: SQLite driver not available. Available drivers are:" << QSqlDatabase::drivers().join(",");
        qFatal() << "PhotoQt cannot function without SQLite available.";
    }

    // if no config files exist, then it is a fresh install
    if(!QFile::exists(PQCConfigFiles::SETTINGS_DB()) ||
       !QFile::exists(PQCConfigFiles::IMAGEFORMATS_DB()) ||
       !QFile::exists(PQCConfigFiles::SHORTCUTS_DB())) {

        db_context.setDatabaseName(PQCConfigFiles::CONTEXTMENU_DB());
        db_imageformats.setDatabaseName(PQCConfigFiles::IMAGEFORMATS_DB());
        db_location.setDatabaseName(PQCConfigFiles::LOCATION_DB());

        return 2;
    }

    db_context.setDatabaseName(PQCConfigFiles::CONTEXTMENU_DB());
    db_imageformats.setDatabaseName(PQCConfigFiles::IMAGEFORMATS_DB());
    db_location.setDatabaseName(PQCConfigFiles::LOCATION_DB());

    // last time a dev version was run
    QString version = PQCSettings::get()["generalVersion"].toString();
    if(version == "dev") {
        // update stored version string
        PQCSettings::get().update("generalVersion", VERSION);
        return 3;
    }

    // updated
    if(version != QString(VERSION)) {
        // update stored version string
        PQCSettings::get().update("generalVersion", VERSION);
        return 1;
    }

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

void PQCStartup::setupFresh(int defaultPopout) {

    qDebug() << "args: defaultPopout =" << defaultPopout;

    /**************************************************************/
    // make sure necessary folder exist
    QDir dir;
    dir.mkpath(PQCConfigFiles::CONFIG_DIR());
    dir.mkpath(PQCConfigFiles::GENERIC_DATA_DIR());
    dir.mkpath(PQCConfigFiles::GENERIC_CACHE_DIR());
    dir.mkpath(QString("%1/thumbnails/large/").arg(PQCConfigFiles::GENERIC_CACHE_DIR()));

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

    PQCSettings::get().update("generalVersion", VERSION);

#ifdef Q_OS_WIN
    // these defaults are different on Windows as on Linux
    PQCSettings::get().update("filedialogUserPlacesVolumes", true);
#endif

    // record popout selection
    // default is all integrated (defaultPopout == 0)
    if(defaultPopout == 1) { // some integrated, some individual

        PQCSettings::get().update("interfacePopoutScale", true);
        PQCSettings::get().update("interfacePopoutFileDialog", true);
        PQCSettings::get().update("interfacePopoutSlideShowSettings", true);
        PQCSettings::get().update("interfacePopoutImgur", true);
        PQCSettings::get().update("interfacePopoutWallpaper", true);
        PQCSettings::get().update("interfacePopoutSettingsManager", true);
        PQCSettings::get().update("interfacePopoutFileSaveAs", true);
        PQCSettings::get().update("interfacePopoutChromecast", true);
        PQCSettings::get().update("interfacePopoutAdvancedSort", true);
        PQCSettings::get().update("interfacePopoutMapExplorer", true);

    } else if(defaultPopout == 2) { // all individual

        PQCSettings::get().update("interfacePopoutMainMenu", true);
        PQCSettings::get().update("interfacePopoutMetadata", true);
        PQCSettings::get().update("interfacePopoutHistogram", true);
        PQCSettings::get().update("interfacePopoutScale", true);
        PQCSettings::get().update("interfacePopoutFileDialog", true);
        PQCSettings::get().update("interfacePopoutFileDialogKeepOpen", true);
        PQCSettings::get().update("interfacePopoutSlideShowSettings", true);
        PQCSettings::get().update("interfacePopoutSlideShowControls", true);
        PQCSettings::get().update("interfacePopoutFileRename", true);
        PQCSettings::get().update("interfacePopoutFileDelete", true);
        PQCSettings::get().update("interfacePopoutAbout", true);
        PQCSettings::get().update("interfacePopoutImgur", true);
        PQCSettings::get().update("interfacePopoutWallpaper", true);
        PQCSettings::get().update("interfacePopoutFilter", true);
        PQCSettings::get().update("interfacePopoutSettingsManager", true);
        PQCSettings::get().update("interfacePopoutFileSaveAs", true);
        PQCSettings::get().update("interfacePopoutUnavailable", true);
        PQCSettings::get().update("interfacePopoutChromecast", true);
        PQCSettings::get().update("interfacePopoutAdvancedSort", true);
        PQCSettings::get().update("interfacePopoutMapCurrent", true);
        PQCSettings::get().update("interfacePopoutMapExplorer", true);
        PQCSettings::get().update("interfacePopoutMapExplorerKeepOpen", true);


    }

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


}

void PQCStartup::resetToDefaults() {

    std::cout << std::endl
              << "PhotoQt v" << VERSION << std::endl
              << " > Resetting to default configuration... " << std::flush;

    PQCSettings::get().setDefault();
    PQCShortcuts::get().setDefault();

    std::cout << " >> Done!" << std::endl << std::endl;

}

void PQCStartup::performChecksAndMigrations() {

    /**************************************************************/

    // migrate data
    // nothing to migrate right now

    /**************************************************************/

    // enter any new settings and shortcuts
    manageSettings();
    manageShortcuts();

    /**************************************************************/

    // validate setup
    PQCValidate validate;
    validate.validate();

}

// These settings changed names
bool PQCStartup::manageSettings() {

    QSqlDatabase db = QSqlDatabase::database("settings");

    QMap<QString,QStringList> rename;
    rename ["LabelsWindowButtonsSize"] = QStringList() << "WindowButtonsSize" << "interface";   // 3.1
    rename ["LabelsManageWindow"] = QStringList() << "StatusInfoManageWindow" << "interface";   // 3.1
    rename ["LiftUp"] = QStringList() << "HighlightAnimationLiftUp" << "thumbnails";            // 3.2
    rename ["FilenameOnly"] = QStringList() << "IconsOnly" << "thumbnails";                     // 3.2
    rename ["FilenameOnlyFontSize"] = QStringList() << "" << "thumbnails";                      // 3.2
    rename ["ZoomLevel"] = QStringList() << "Zoom" << "filedialog";                             // 4.0
    QMapIterator<QString, QStringList> i(rename);
    while(i.hasNext()) {
        i.next();

        QString oldname = i.key();
        QString newname = i.value().value(0);
        QString table = i.value().value(1);

        // delete old setting
        if(newname == "") {

            QSqlQuery query(db);
            query.prepare(QString("DELETE FROM '%1' WHERE name=:old").arg(table));
            query.bindValue(":old", oldname);
            if(!query.exec()) {
                qWarning() << "Error removing old setting name (" << oldname << "): " << query.lastError().text();
                query.clear();
                return false;
            }
            query.clear();

        // rename old setting
        } else {

            QSqlQuery query(db);
            query.prepare(QString("UPDATE '%1' SET name=:new WHERE name=:old").arg(table));
            query.bindValue(":new", newname);
            query.bindValue(":old", oldname);
            if(!query.exec()) {
                qWarning() << QString("Error updating setting name (%1 -> %2):").arg(oldname, newname) << query.lastError().text();
                query.clear();
                return false;
            }
            query.clear();

        }
    }

    // value changes
    // ZoomLevel -> Zoom: (val-9)*2.5
    QSqlQuery queryZoom(db);
    queryZoom.prepare("SELECT `value` from `filedialog` WHERE `name`='ZoomLevel'");
    if(!queryZoom.exec()) {
        qWarning() << "Unable to migrate ZoomLevel to Zoom:" << queryZoom.lastError().text();
        queryZoom.clear();
        return false;
    }
    queryZoom.next();
    const int oldVal = queryZoom.value(0).toInt();
    queryZoom.clear();
    queryZoom.prepare("UPDATE `filedialog` SET `value`=:val WHERE `name`='Zoom'");
    queryZoom.bindValue(":val", static_cast<int>((oldVal-9)*2.5));
    if(!queryZoom.exec()) {
        qWarning() << "Unable to update Zoom value:" << queryZoom.lastError().text();
        queryZoom.clear();
        return false;
    }
    queryZoom.clear();

    return true;

}

bool PQCStartup::manageShortcuts() {

    QSqlDatabase db = QSqlDatabase::database("shortcuts");

    // delete old entries
    QSqlQuery query(db);

    // required for transition to v3.3
    if(!query.exec("DELETE FROM builtin WHERE command like '__keepMetaData'")) {
        qWarning() << "Error removing old shortcut '__keepMetaData': " << query.lastError().text().trimmed();
        query.clear();
        return false;
    }

    query.clear();

    return true;

}

/**************************************************************/
/**************************************************************/
// the following migration functions are below (in this order):
// -- nothing to migrate right now


/**************************************************************/
/**************************************************************/

void PQCStartup::showInfo() {

    std::cout << std::endl
              << " ** PhotoQt configuration:"
              << std::endl << std::endl
              << PQCScriptsConfig::get().getConfigInfo().toStdString()
              << std::endl;

}
