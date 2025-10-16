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

#include <cpp/pqc_commandlineparser.h>
#include <cpp/pqc_singleinstance.h>
#include <cpp/pqc_cdbusserver.h>
#include <shared/pqc_configfiles.h>

#include <QKeyEvent>
#include <QFileInfo>
#include <QDir>
#include <thread>

#include <QQmlApplicationEngine>
#include <QSqlError>
#include <QSqlQuery>

PQCSingleInstance::PQCSingleInstance(int &argc, char *argv[]) : QApplication(argc, argv) {

    // Parse the command line arguments
    PQCCommandLineParser parser(*this);
    PQCCommandLineResult result = parser.getResult();

    QStringList msg;

    m_forceModernInterface = false;
    m_forceIntegratedInterface = false;

    if(result & PQCCommandLineFile) {
        for(const auto &f : std::as_const(parser.filenames)) {
            QString ff = f;
            if(!QFileInfo(ff).isAbsolute())
                ff = QDir::currentPath() + "/" + ff;
            msg << ":::FILE:::";
            msg << QFileInfo(ff).canonicalFilePath();
        }
    }

    if(result & PQCCommandLineOpen) {
        msg << ":::OPEN:::";
    }

    if(result & PQCCommandLineShow) {
        msg << ":::SHOW:::";
    }

    if(result & PQCCommandLineHide) {
        msg << ":::HIDE:::";
    }

    if(result & PQCCommandLineQuit) {
        msg << ":::QUIT:::";
    }

    if(result & PQCCommandLineToggle) {
        msg << ":::TOGGLE:::";
    }

    if(result & PQShortcutSequence) {
        msg << ":::SHORTCUT:::";
        msg << parser.shortcutSequence;
    }

    if(result & PQCCommandLineStartInTray)
        msg << ":::STARTINTRAY:::";

    if(result & PQCCommandLineEnableTray)
        msg << ":::TRAY:::";

    if(result & PQCCommandLineDisableTray)
        msg << ":::NOTRAY:::";

    if(result & PQCCommandLineDebug)
        msg << ":::DEBUG:::";

    if(result & PQCCommandLineNoDebug)
        msg << ":::NODEBUG:::";

    if(result & PQCCommandLineModernInterface)
        m_forceModernInterface = true;

    if(result & PQCCommandLineIntegratedInterface)
        m_forceIntegratedInterface = true;

    if(result & PQCCommandLineSettingUpdate) {
        msg << ":::SETTING:::";
        msg << parser.settingUpdate[0];
        msg << parser.settingUpdate[1];
    }

    // validation requested
    m_checkConfig = false;
    if(result & PQCCommandLineCheckConfig) {
        m_checkConfig = true;
        return;
    }

    // reset defaults
    m_resetConfig = false;
    if(result & PQCCommandLineResetConfig) {
        m_resetConfig = true;
        return;
    }

    // show info
    m_showInfo = false;
    if(result & PQCCommandLineShowInfo) {
        m_showInfo = true;
        return;
    }

    // STANDALONE, EXPORT, IMPORT

    m_exportAndQuit = "";
    if(result & PQCCommandLineExport) {
        m_exportAndQuit = parser.exportFileName;
        return;
    }

    m_importAndQuit = "";
    if(result & PQCCommandLineImport) {
        m_importAndQuit = parser.importFileName;
        return;
    }

    // we need to figure out if multiple instances are allowed here WITHOUT using the PQCSettings class
    if(QFile::exists(PQCConfigFiles::get().USERSETTINGS_DB())) {

        // This database connection happens before the general setup in PQCStartupManager
        QSqlDatabase dbtmp;
        if(QSqlDatabase::contains("settingsRO"))
            dbtmp = QSqlDatabase::database("settingsRO");
        else {
            if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
                dbtmp = QSqlDatabase::addDatabase("QSQLITE3", "settingsRO");
            else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
                dbtmp = QSqlDatabase::addDatabase("QSQLITE", "settingsRO");
            dbtmp.setDatabaseName(PQCConfigFiles::get().USERSETTINGS_DB());
            dbtmp.setConnectOptions("QSQLITE_OPEN_READONLY");
        }

        if(!dbtmp.open()) {
            qWarning() << "Unable to check how to handle multiple instances:" << dbtmp.lastError().text();
            qWarning() << "Assuming only a single instance is to be used";
        } else {
            QSqlQuery query(dbtmp);
            if(!query.exec("SELECT `value` FROM interface WHERE `name`='AllowMultipleInstances'"))
                qWarning() << "Unable to check for interfaceAllowMultipleInstances setting";
            else {
                if(query.next()) {
                    if(query.value(0).toBool()) {
                        PQCCPPConstants::get().setStartupMessage(msg.join("\n").toUtf8());
                        query.clear();
                        dbtmp.close();
                        return;
                    }
                }
            }
            query.clear();
            dbtmp.close();
        }
    }

    /*****************/
    /* Server/Socket */
    /*****************/

    if(PQCCDbusServer::get().hasExistingServer()) {

        if(msg.size() == 0)
            msg << ":::SHOW:::";

        if(qApp->platformName() == "wayland") {

            QString token = qgetenv("XDG_ACTIVATION_TOKEN");
            if(!token.isEmpty()) {
                msg << ":::TOKEN:::";
                msg << token;
            }
        }

        PQCCDbusServer::get().sendMessage("startup", msg.join("\n"));

        // Inform user
        std::cout << "Running instance of PhotoQt detected, connecting to existing instance." << std::endl;

        // Exit the code (need to use stdlib exit function to ensure an immediate exit)
        // We wait 100ms as otherwise this instance might return as a crash (even though it doesn't really)
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
        std::exit(0);
        return;

    } else {

        if(qApp->platformName() == "wayland") {

            QString token = qgetenv("XDG_ACTIVATION_TOKEN");
            if(!token.isEmpty()) {
                msg << ":::TOKEN:::";
                msg << token;
            }
        }

        PQCCDbusServer::get().sendMessage("startup", msg.join("\n"));
        // TODO!!! Is this still needed?
        // PQCCPPConstants::get().setStartupMessage(composeMessage(msg, receivedFile, receivedShortcut, receivedSetting));

    }

}

PQCSingleInstance::~PQCSingleInstance() {}
