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

#include <QKeyEvent>
#include <QFileInfo>
#include <QDir>
#include <thread>

#include <QQmlApplicationEngine>
#include <QLocalSocket>
#include <QLocalServer>
#include <QSqlError>
#include <QSqlQuery>

#include <pqc_commandlineparser.h>
#include <pqc_singleinstance.h>
#include <pqc_configfiles.h>

PQCSingleInstance::PQCSingleInstance(int &argc, char *argv[]) : QApplication(argc, argv) {

    // Parse the command line arguments
    PQCCommandLineParser parser(*this);
    PQCCommandLineResult result = parser.getResult();

    QList<CMDActions> msg;
    QString receivedFile = "";
    QString receivedShortcut = "";
    QString receivedSetting[2] = {"", ""};

    m_socket = nullptr;

    m_forceModernInterface = false;
    m_forceIntegratedInterface = false;

    if(result & PQCCommandLineFile) {
        for(const auto &f : std::as_const(parser.filenames)) {
            QString ff = f;
            if(!QFileInfo(ff).isAbsolute())
                ff = QDir::currentPath() + "/" + ff;
            msg << CMDActions::File;
            receivedFile = QFileInfo(ff).canonicalFilePath();
        }
    }

    if(result & PQCCommandLineOpen) {
        msg << CMDActions::Open;
    }

    if(result & PQCCommandLineShow) {
        msg << CMDActions::Show;
    }

    if(result & PQCCommandLineHide) {
        msg << CMDActions::Hide;
    }

    if(result & PQCCommandLineQuit) {
        msg << CMDActions::Quit;
    }

    if(result & PQCCommandLineToggle) {
        msg << CMDActions::Toggle;
    }

    if(result & PQShortcutSequence) {
        msg << CMDActions::Shortcut;
        receivedShortcut = parser.shortcutSequence;
    }

    if(result & PQCCommandLineStartInTray)
        msg << CMDActions::StartInTray;

    if(result & PQCCommandLineEnableTray)
        msg << CMDActions::Tray;

    if(result & PQCCommandLineDisableTray)
        msg << CMDActions::NoTray;

    if(result & PQCCommandLineDebug)
        msg << CMDActions::Debug;

    if(result & PQCCommandLineNoDebug)
        msg << CMDActions::NoDebug;

    if(result & PQCCommandLineModernInterface)
        m_forceModernInterface = true;

    if(result & PQCCommandLineIntegratedInterface)
        m_forceIntegratedInterface = true;

    if(result & PQCCommandLineSettingUpdate) {
        receivedSetting[0] = parser.settingUpdate[0];
        receivedSetting[1] = parser.settingUpdate[1];
        msg << CMDActions::Setting;
    }

    // validation requested
    m_checkConfig = false;
    if(result & PQCCommandLineCheckConfig) {
        m_checkConfig = true;
        m_socket = new QLocalSocket();
        return;
    }

    // reset defaults
    m_resetConfig = false;
    if(result & PQCCommandLineResetConfig) {
        m_resetConfig = true;
        m_socket = new QLocalSocket();
        return;
    }

    // show info
    m_showInfo = false;
    if(result & PQCCommandLineShowInfo) {
        m_showInfo = true;
        m_socket = new QLocalSocket();
        return;
    }

    // STANDALONE, EXPORT, IMPORT

    m_exportAndQuit = "";
    if(result & PQCCommandLineExport) {
        m_exportAndQuit = parser.exportFileName;
        m_socket = new QLocalSocket();
        return;
    }

    m_importAndQuit = "";
    if(result & PQCCommandLineImport) {
        m_importAndQuit = parser.importFileName;
        m_socket = new QLocalSocket();
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
                        PQCCPPConstants::get().setStartupMessage(composeMessage(msg, receivedFile, receivedShortcut, receivedSetting));
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

    // Create server name
    QString server_str = "org.photoqt.PhotoQt.QML";

    // Connect to a Local Server (if available)
    m_socket = new QLocalSocket();
    m_socket->connectToServer(server_str);

    // If this is successful, then an instance is already running
    if(m_socket->waitForConnected(100)) {

        if(msg.size() == 0)
            msg << CMDActions::Show;

        m_socket->write(composeMessage(msg, receivedFile, receivedShortcut, receivedSetting));
        m_socket->flush();

        // Inform user
        std::cout << "Running instance of PhotoQt detected, connecting to existing instance." << std::endl;

        // Exit the code (need to use stdlib exit function to ensure an immediate exit)
        // We wait 100ms as otherwise this instance might return as a crash (even though it doesn't really)
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
        std::exit(0);

    } else
        PQCCPPConstants::get().setStartupMessage(composeMessage(msg, receivedFile, receivedShortcut, receivedSetting));

}

QByteArray PQCSingleInstance::composeMessage(QList<CMDActions> msg, QString receivedFile, QString receivedShortcut, QString *receivedSetting) {

    if(msg.size() == 0)
        msg << CMDActions::Show;

    QList<QByteArray> retMsg;

    if(qApp->platformName() == "wayland") {

        retMsg.reserve(msg.size()+1);

        QString token = qgetenv("XDG_ACTIVATION_TOKEN");
        if(!token.isEmpty())
            retMsg.append(QStringLiteral("_T_O_K_E_N_%1\n").arg(token).toUtf8());

    } else
        retMsg.reserve(msg.size());

    for(const CMDActions &i : std::as_const(msg)) {
        retMsg.append(QString::number(static_cast<int>(i)).toUtf8());
    }

    if(receivedFile != "")
        retMsg.append(QStringLiteral("_F_I_L_E_%1\n").arg(receivedFile).toUtf8());
    if(receivedShortcut != "")
        retMsg.append(QStringLiteral("_S_H_O_R_T_C_U_T_%1\n").arg(receivedShortcut).toUtf8());
    if(receivedSetting[0] != "")
        retMsg.append(QStringLiteral("_S_E_T_T_I_N_G_%1:%2\n").arg(receivedSetting[0], receivedSetting[1]).toUtf8());

    return retMsg.join('\n');

}

PQCSingleInstance::~PQCSingleInstance() {
    if(m_socket != nullptr)
        delete m_socket;
}
