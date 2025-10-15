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

    QList<Actions> msg;
    QString receivedFile = "";
    QString receivedShortcut = "";
    QString receivedSetting[2] = {"", ""};

    socket = nullptr;
    server = nullptr;

    forceModernInterface = false;
    forceIntegratedInterface = false;

    if(result & PQCCommandLineFile) {
        for(const auto &f : std::as_const(parser.filenames)) {
            QString ff = f;
            if(!QFileInfo(ff).isAbsolute())
                ff = QDir::currentPath() + "/" + ff;
            msg << Actions::File;
            receivedFile = QFileInfo(ff).canonicalFilePath();
        }
    }

    if(result & PQCCommandLineOpen) {
        msg << Actions::Open;
    }

    if(result & PQCCommandLineShow) {
        msg << Actions::Show;
    }

    if(result & PQCCommandLineHide) {
        msg << Actions::Hide;
    }

    if(result & PQCCommandLineQuit) {
        msg << Actions::Quit;
    }

    if(result & PQCCommandLineToggle) {
        msg << Actions::Toggle;
    }

    if(result & PQShortcutSequence) {
        msg << Actions::Shortcut;
        receivedShortcut = parser.shortcutSequence;
    }

    if(result & PQCCommandLineStartInTray)
        msg << Actions::StartInTray;

    if(result & PQCCommandLineEnableTray)
        msg << Actions::Tray;

    if(result & PQCCommandLineDisableTray)
        msg << Actions::NoTray;

    if(result & PQCCommandLineDebug)
        msg << Actions::Debug;

    if(result & PQCCommandLineNoDebug)
        msg << Actions::NoDebug;

    if(result & PQCCommandLineModernInterface)
        forceModernInterface = true;

    if(result & PQCCommandLineIntegratedInterface)
        forceIntegratedInterface = true;

    if(result & PQCCommandLineSettingUpdate) {
        receivedSetting[0] = parser.settingUpdate[0];
        receivedSetting[1] = parser.settingUpdate[1];
        msg << Actions::Setting;
    }

    // validation requested
    checkConfig = false;
    if(result & PQCCommandLineCheckConfig) {
        checkConfig = true;
        socket = new QLocalSocket();
        server = new QLocalServer();
        return;
    }

    // reset defaults
    resetConfig = false;
    if(result & PQCCommandLineResetConfig) {
        resetConfig = true;
        socket = new QLocalSocket();
        server = new QLocalServer();
        return;
    }

    // show info
    showInfo = false;
    if(result & PQCCommandLineShowInfo) {
        showInfo = true;
        socket = new QLocalSocket();
        server = new QLocalServer();
        return;
    }

    // STANDALONE, EXPORT, IMPORT

    exportAndQuit = "";
    if(result & PQCCommandLineExport) {
        exportAndQuit = parser.exportFileName;
        socket = new QLocalSocket();
        server = new QLocalServer();
        return;
    }

    importAndQuit = "";
    if(result & PQCCommandLineImport) {
        importAndQuit = parser.importFileName;
        socket = new QLocalSocket();
        server = new QLocalServer();
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
                        // if(receivedFile != "")
                        //     m_receivedFile = receivedFile;
                        // if(receivedShortcut != "")
                        //     m_receivedShortcut = receivedShortcut;
                        // if(receivedSetting[0] != "") {
                        //     m_receivedSetting[0] = receivedSetting[0];
                        //     m_receivedSetting[1] = receivedSetting[1];
                        // }
                        // handleMessage(msg);
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

    // Create server name. If this is changed, then the string in PQCReceiveMessages also needs to be changed.
    QString server_str = "org.photoqt.PhotoQt";

    // Connect to a Local Server (if available)
    socket = new QLocalSocket();
    socket->connectToServer(server_str);

    // If this is successful, then an instance is already running
    if(socket->waitForConnected(100)) {

        if(msg.size() == 0)
            msg << Actions::Show;

        QList<QByteArray> writeMessage;

        if(qApp->platformName() == "wayland") {

            writeMessage.reserve(msg.size()+1);

            QString token = qgetenv("XDG_ACTIVATION_TOKEN");
            if(!token.isEmpty())
                writeMessage.append(QStringLiteral("_T_O_K_E_N_%1\n").arg(token).toUtf8());

        } else
            writeMessage.reserve(msg.size());

        for(const Actions &i : std::as_const(msg)) {
            writeMessage.append(QString::number(static_cast<int>(i)).toUtf8());
        }

        // Send composed message string
        if(receivedFile != "")
            writeMessage.append(QStringLiteral("_F_I_L_E_%1\n").arg(receivedFile).toUtf8());
        if(receivedShortcut != "")
            writeMessage.append(QStringLiteral("_S_H_O_R_T_C_U_T_%1\n").arg(receivedShortcut).toUtf8());
        if(receivedSetting[0] != "")
            writeMessage.append(QStringLiteral("_S_E_T_T_I_N_G_%1:%2\n").arg(receivedSetting[0], receivedSetting[1]).toUtf8());

        socket->write(writeMessage.join('\n'));
        socket->flush();

        // Inform user
        std::cout << "Running instance of PhotoQt detected, connecting to existing instance." << std::endl;

        // Exit the code (need to use stdlib exit function to ensure an immediate exit)
        // We wait 100ms as otherwise this instance might return as a crash (even though it doesn't really)
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
        std::exit(0);

    } else {

        // Create a new local server
        // server = new QLocalServer();
        // server->removeServer(server_str);
        // server->listen(server_str);
        // connect(server, &QLocalServer::newConnection, this, &PQCSingleInstance::newConnection);

        // m_receivedFile = receivedFile;
        // m_receivedSetting[0] = receivedSetting[0];
        // m_receivedSetting[1] = receivedSetting[1];
        // m_receivedShortcut = receivedShortcut;
        // handleMessage(msg);

    }

}

bool PQCSingleInstance::notify(QObject *obj, QEvent *e) {

    const QString cn = obj->metaObject()->className();
    if(cn == "QQuickRootItem") {
        if(e->type() == QEvent::KeyPress) {
            QKeyEvent *ev = reinterpret_cast<QKeyEvent*>(e);
            // Q_EMIT PQCNotifyCPP::get().keyPress(ev->key(), ev->modifiers());
        } else if(e->type() == QEvent::KeyRelease) {
            QKeyEvent *ev = reinterpret_cast<QKeyEvent*>(e);
            // Q_EMIT PQCNotifyCPP::get().keyRelease(ev->key(), ev->modifiers());
        }
    } else if(cn.startsWith("PQMainWindow")) {
        // if(e->type() == QEvent::Leave) {
            // Q_EMIT PQCNotifyCPP::get().mouseWindowExit();
        // } else if(e->type() == QEvent::Enter)
            // Q_EMIT PQCNotifyCPP::get().mouseWindowEnter();
    }

    return QApplication::notify(obj, e);

}

PQCSingleInstance::~PQCSingleInstance() {
    if(socket != nullptr)
        delete socket;
    if(server != nullptr) {
        server->close();
        delete server;
    }
}
