#include <pqc_startuphandler.h>
#include <pqc_configfiles.h>
#include <pqc_settingscpp.h>
#include <scripts/qml/pqc_scriptsconfig.h>
#include <pqc_validate.h>
#include <pqc_migratesettings.h>
#include <pqc_migrateshortcuts.h>
#include <QtDebug>
#include <QMessageBox>
#include <QCoreApplication>
#include <QFile>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <iostream>

PQCStartupHandler::PQCStartupHandler(QObject *parent) : QObject(parent) {

    // check if sqlite is available
    if(!QSqlDatabase::isDriverAvailable("QSQLITE3") && !QSqlDatabase::isDriverAvailable("QSQLITE")) {
        //: This is the window title of an error message box
        QMessageBox::critical(0, QCoreApplication::translate("PQCStartup", "SQLite error"),
                              QCoreApplication::translate("PQCStartup", "You seem to be missing the SQLite driver for Qt. This is needed though for a few different things, like reading and writing the settings. Without it, PhotoQt cannot function!"));
        qCritical() << "ERROR: SQLite driver not available. Available drivers are:" << QSqlDatabase::drivers().join(",");
        qCritical() << "PhotoQt cannot function without SQLite available.";
        qApp->quit();
    }

    m_allVersions << "4.0" << "4.1" << "4.2" << "4.3" << "4.4" << "4.5" << "4.6" << "4.7" << "4.8" << "4.8.1" << "4.9" << "4.9.1" << "4.9.2";

}

void PQCStartupHandler::setupDatabases() {

    /****************************************************************************************************/
    // create all the databases used throughout PhotoQt that can be connected to from everywhere

    // it is possible that a connection to the settings db already exists

    QSqlDatabase dbcontextmenu, dbimageformats, dbimgurhistory, dblocation, dbshortcuts, dbsettings;
    QSqlDatabase dbsettingsRO, dbShortcutsRO;

    if(QSqlDatabase::isDriverAvailable("QSQLITE3")) {

        if(!QSqlDatabase::contains("settings"))
            dbsettings = QSqlDatabase::addDatabase("QSQLITE3", "settings");
        dbshortcuts = QSqlDatabase::addDatabase("QSQLITE3", "shortcuts");
        dblocation = QSqlDatabase::addDatabase("QSQLITE3", "location");
        dbimgurhistory = QSqlDatabase::addDatabase("QSQLITE3", "imgurhistory");
        dbimageformats = QSqlDatabase::addDatabase("QSQLITE3", "imageformats");
        dbcontextmenu = QSqlDatabase::addDatabase("QSQLITE3", "contextmenu");

        if(!QSqlDatabase::contains("settingsRO"))
            dbsettingsRO = QSqlDatabase::addDatabase("QSQLITE3", "settingsRO");
        if(!QSqlDatabase::contains("shortcutsRO"))
            dbShortcutsRO = QSqlDatabase::addDatabase("QSQLITE3", "shortcutsRO");

    } else if(QSqlDatabase::isDriverAvailable("QSQLITE")) {

        if(!QSqlDatabase::contains("settings"))
            dbsettings = QSqlDatabase::addDatabase("QSQLITE", "settings");
        dbshortcuts = QSqlDatabase::addDatabase("QSQLITE", "shortcuts");
        dblocation = QSqlDatabase::addDatabase("QSQLITE", "location");
        dbimgurhistory = QSqlDatabase::addDatabase("QSQLITE", "imgurhistory");
        dbimageformats = QSqlDatabase::addDatabase("QSQLITE", "imageformats");
        dbcontextmenu = QSqlDatabase::addDatabase("QSQLITE", "contextmenu");

        if(!QSqlDatabase::contains("settingsRO"))
            dbsettingsRO = QSqlDatabase::addDatabase("QSQLITE", "settingsRO");

    }

    dbsettings.setDatabaseName(PQCConfigFiles::get().USERSETTINGS_DB());
    dbshortcuts.setDatabaseName(PQCConfigFiles::get().SHORTCUTS_DB());
    dblocation.setDatabaseName(PQCConfigFiles::get().LOCATION_DB());
    dbimgurhistory.setDatabaseName(PQCConfigFiles::get().SHAREONLINE_IMGUR_HISTORY_DB());
    dbimageformats.setDatabaseName(PQCConfigFiles::get().IMAGEFORMATS_DB());
    dbcontextmenu.setDatabaseName(PQCConfigFiles::get().CONTEXTMENU_DB());

    dbsettingsRO.setDatabaseName(PQCConfigFiles::get().USERSETTINGS_DB());
    dbShortcutsRO.setDatabaseName(PQCConfigFiles::get().SHORTCUTS_DB());
    dbsettingsRO.setConnectOptions("QSQLITE_OPEN_READONLY");
    dbShortcutsRO.setConnectOptions("QSQLITE_OPEN_READONLY");

}

void PQCStartupHandler::performChecksAndUpdates() {

    qDebug() << "";

    // first we validate the structure of folder, files, and databases
    PQCValidate validate;

    /********************************************************************/
    /********************************************************************/
    // CHECK SETTINGS DB

    QString oldSettingsVersion = "";
    PQEUpdateCheck settingsChecker = PQEUpdateCheck::SameVersion;

    // if no settings db exist, then it is a fresh install
    if(!QFile::exists(PQCConfigFiles::get().USERSETTINGS_DB())) {
        if(!QFile::exists(PQCConfigFiles::get().OLDSETTINGS_DB()))
            settingsChecker = PQEUpdateCheck::FreshInstall;
        else {
            if(QFile::copy(PQCConfigFiles::get().OLDSETTINGS_DB(), PQCConfigFiles::get().USERSETTINGS_DB()))
                QFile::remove(PQCConfigFiles::get().OLDSETTINGS_DB());
            oldSettingsVersion = "4.8.1";
            settingsChecker = PQEUpdateCheck::Update;
        }
    }

    if(settingsChecker == PQEUpdateCheck::SameVersion) {

        // last time a dev version was run
        // we need to figure this out WITHOUT using the PQCSettings class
        QSqlDatabase dbtmp;
        if(QSqlDatabase::contains("settingsRO"))
            dbtmp = QSqlDatabase::database("settingsRO");
        else {
            if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
                dbtmp = QSqlDatabase::addDatabase("QSQLITE3", "settingsRO");
            else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
                dbtmp = QSqlDatabase::addDatabase("QSQLITE", "settingsRO");
            dbtmp.setConnectOptions("QSQLITE_OPEN_READONLY");
            dbtmp.setDatabaseName(PQCConfigFiles::get().USERSETTINGS_DB());
        }
        if(!dbtmp.open()) {
            qWarning() << "Unable to check old version number:" << dbtmp.lastError().text();
            qWarning() << "Assuming we came from and are on the current version";
        } else {
            QSqlQuery query(dbtmp);
            if(!query.exec("SELECT `value` FROM general WHERE `name`='Version'"))
                qWarning() << "Unable to check for generalVersion setting";
            else {
                if(query.next()) {
                    oldSettingsVersion = query.value(0).toString();
#ifdef NDEBUG
                    if(oldSettingsVersion != QString(PQMVERSION)) {
#endif
                        query.clear();
                        dbtmp.close();
                        settingsChecker = PQEUpdateCheck::Update;
#ifdef NDEBUG
                    }
#endif
                }
            }
            query.clear();
            dbtmp.close();
        }

    }

    if(settingsChecker == PQEUpdateCheck::FreshInstall) {

        setupFresh();
        setupDatabases();   // ... again.

        // WE CAN STOP HERE!
        return;

    } else if(settingsChecker == PQEUpdateCheck::Update) {

        // do migrations
        PQCMigrateSettings::migrate(oldSettingsVersion, m_allVersions);
        validate.validateSettingsDatabase();
        validate.validateSettingsValues();

    }

    /********************************************************************/
    /********************************************************************/
    // CHECK SHORTCUT DB

    QString oldShortcutsVersion = "";
    PQEUpdateCheck shortcutsChecker = PQEUpdateCheck::SameVersion;

    // if no shortcuts db exist, then it is a fresh install
    if(!QFile::exists(PQCConfigFiles::get().SHORTCUTS_DB())) {

        shortcutsChecker = PQEUpdateCheck::FreshInstall;

    } else {

        QSqlDatabase dbtmp;
        if(QSqlDatabase::contains("shortcutsRO"))
            dbtmp = QSqlDatabase::database("shortcutsRO");
        else {
            if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
                dbtmp = QSqlDatabase::addDatabase("QSQLITE3", "shortcutsRO");
            else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
                dbtmp = QSqlDatabase::addDatabase("QSQLITE", "shortcutsRO");
            dbtmp.setConnectOptions("QSQLITE_OPEN_READONLY");
            dbtmp.setDatabaseName(PQCConfigFiles::get().SHORTCUTS_DB());
        }
        if(!dbtmp.open()) {
            qWarning() << "Unable to check old version number:" << dbtmp.lastError().text();
            qWarning() << "Assuming we came from and are on the current version";
        } else {
            QSqlQuery query(dbtmp);
            if(!query.exec("SELECT `value` FROM config WHERE `name`='Version'"))
                qWarning() << "Unable to check for version value";
            else {
                if(query.next()) {
                    oldShortcutsVersion = query.value(0).toString();
#ifdef NDEBUG
                    if(oldShortcutsVersion != QString(PQMVERSION)) {
#endif
                        query.clear();
                        dbtmp.close();
                        shortcutsChecker = PQEUpdateCheck::Update;
#ifdef NDEBUG
                    }
#endif
                }
            }
            query.clear();
            dbtmp.close();
        }

    }

    if(shortcutsChecker == PQEUpdateCheck::FreshInstall) {

        if(QFile::exists(PQCConfigFiles::get().SHORTCUTS_DB()))
            QFile::remove(PQCConfigFiles::get().SHORTCUTS_DB());
        if(!QFile::copy(":/shortcuts.db", PQCConfigFiles::get().SHORTCUTS_DB()))
            qWarning() << "Unable to create shortcuts database";
        else {
            QFile file(PQCConfigFiles::get().SHORTCUTS_DB());
            file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
        }

    } else if(shortcutsChecker == PQEUpdateCheck::Update) {

        // do migrations
        PQCMigrateShortcuts::migrate(oldShortcutsVersion, m_allVersions);

        validate.validateShortcutsDatabase();

    }


    /********************************************************************/
    /********************************************************************/

}

QString PQCStartupHandler::getInterfaceVariant() {

    QSqlDatabase dbtmp = QSqlDatabase::database("settingsRO");
    if(!dbtmp.open()) {
        qWarning() << "Unable to check what interface variant to use:" << dbtmp.lastError().text();
    } else {
        QSqlQuery query(dbtmp);
        if(!query.exec("SELECT `value` FROM general WHERE `name`='InterfaceVariant'"))
            qWarning() << "Unable to check for generalInterfaceVariant setting";
        else {
            if(query.next()) {
                const QString val = query.value(0).toString();
                if(val == "modern" || val == "integrated") {
                    return val;
                }
            }
        }
        query.clear();
        dbtmp.close();
    }

    return PQCSettingsCPP::get().getGeneralInterfaceVariant();

}

/**************************************************************/
/**************************************************************/

void PQCStartupHandler::exportData(QString path) {

    std::cout << std::endl
              << "PhotoQt v" << PQMVERSION << std::endl << std::endl;

    if(QFile::exists(path)) {

        std::cout << "> The specified file exists already and will be overwritten." << std::endl << std::endl
                  << "Continue? [yN] " << std::flush;

        // request input
        std::string choice;
        std::getline(std::cin, choice);

        // convert input to all lowercase
        std::transform(choice.begin(), choice.end(), choice.begin(), tolower);

        if(choice != "y" && choice != "yes") {
            std::cout << std::endl
                      << "> Cancelling request... Goodbye." << std::endl << std::endl;
            return;
        }
    }

    if(!path.endsWith(".pqt"))
        path += ".pqt";

    // use plain cout as we don't want any log/debug info prepended
    std::cout << " > Exporting configuration to " << path.toStdString() << "... " << std::flush;

    PQCScriptsConfig scr;
    if(scr.exportConfigTo(path))
        std::cout << "done! Goodbye." << std::endl << std::endl;
    else
        std::cout << "failed! Goodbye." << std::endl << std::endl;

}

void PQCStartupHandler::importData(QString path) {

    std::cout << std::endl
              << "PhotoQt v" << PQMVERSION << std::endl << std::endl;

    if(!QFile::exists(path)) {
        std::cout << "> ERROR: The specified file could not be found." << std::endl
                  << "> Stopping here... Goodbye." << std::endl << std::endl;
        return;
    }

    std::cout << "> This will overwrite the existing configuration with the" << std::endl
              << "  configuration found in the specified file." << std::endl
              << "> This step cannot be undone." << std::endl << std::endl
              << "Continue? [yN] " << std::flush;

    // request input
    std::string choice;
    std::getline(std::cin, choice);

    // convert input to all lowercase
    std::transform(choice.begin(), choice.end(), choice.begin(), tolower);

    if(choice == "y" || choice == "yes") {

        // use plain cout as we don't want any log/debug info prepended
        std::cout << std::endl
                  << " > Importing configuration from " << path.toStdString() << "... " << std::flush;

        PQCScriptsConfig scr;
        if(scr.importConfigFrom(path))
            std::cout << "done! Goodbye." << std::endl << std::endl;
        else
            std::cout << "failed! Goodbye." << std::endl << std::endl;

        return;

    }

    std::cout << std::endl
              << "> Cancelling request... Goodbye." << std::endl << std::endl;

}

/**************************************************************/
/**************************************************************/

void PQCStartupHandler::resetToDefaults() {

    std::cout << std::endl
              << "PhotoQt v" << PQMVERSION << std::endl << std::endl
              << "> This will reset PhotoQt to its default state." << std::endl
              << "> This step cannot be undone." << std::endl << std::endl
              << "Continue? [yN] " << std::flush;

    // request input
    std::string choice;
    std::getline(std::cin, choice);

    // convert input to all lowercase
    std::transform(choice.begin(), choice.end(), choice.begin(), tolower);

    if(choice == "y" || choice == "yes") {

        std::cout << std::endl
                  << " > Resetting to default configuration... " << std::flush;

        setupFresh();

        std::cout << "done! Goodbye." << std::endl << std::endl;

        return;

    }

    std::cout << std::endl
              << "> Cancelling request... Goodbye." << std::endl << std::endl;

}

void PQCStartupHandler::setupFresh() {

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

/**************************************************************/
/**************************************************************/

void PQCStartupHandler::showInfo() {

    PQCScriptsConfig scr;

    std::cout << std::endl
              << " ** PhotoQt configuration:"
              << std::endl << std::endl
              << scr.getConfigInfo().toStdString()
              << std::endl;

}

/**************************************************************/
/**************************************************************/
