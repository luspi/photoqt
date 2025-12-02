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
#include <iostream>
#include <qlogging.h>   // needed in this form to compile with Qt 6.2

#include <QQmlApplicationEngine>
#include <QLocalSocket>
#include <QLocalServer>
#include <QSqlError>
#include <QSqlQuery>

#include <pqc_commandlineparser.h>
#include <pqc_singleinstance.h>
#include <pqc_notify_cpp.h>
#include <pqc_configfiles.h>
#include <pqc_filefoldermodelCPP.h>

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

    m_forceShowWizard = false;
    m_forceSkipWizard = false;

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

    if(result & PQCCommandLineShowStartupWizard)
        m_forceShowWizard = true;

    if(result & PQCCommandLineDontShowStartupWizard)
        m_forceSkipWizard = true;

    if(result & PQCCommandLineSettingUpdate) {
        receivedSetting[0] = parser.settingUpdate[0];
        receivedSetting[1] = parser.settingUpdate[1];
        msg << Actions::Setting;
    }

    if(result & PQCCommandLineInstallExtension) {
        installExtensionFileName = parser.extensionFileName;
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
                        if(receivedFile != "")
                            m_receivedFile = receivedFile;
                        if(receivedShortcut != "")
                            m_receivedShortcut = receivedShortcut;
                        if(receivedSetting[0] != "") {
                            m_receivedSetting[0] = receivedSetting[0];
                            m_receivedSetting[1] = receivedSetting[1];
                        }
                        handleMessage(msg);
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
        server = new QLocalServer();
        server->removeServer(server_str);
        server->listen(server_str);
        connect(server, &QLocalServer::newConnection, this, &PQCSingleInstance::newConnection);

        m_receivedFile = receivedFile;
        m_receivedSetting[0] = receivedSetting[0];
        m_receivedSetting[1] = receivedSetting[1];
        m_receivedShortcut = receivedShortcut;

        handleMessage(msg);
        m_startupMessageForProcessing = msg;
        connect(&PQCNotifyCPP::get(), &PQCNotifyCPP::reprocessStartupMessage, this, [=]() { handleMessage(m_startupMessageForProcessing, false); });

    }

}

void PQCSingleInstance::newConnection() {
    QLocalSocket *socket = server->nextPendingConnection();
    if(socket->waitForReadyRead(2000)) {
        const QList<QByteArray> reply = socket->readAll().split('\n');
        QList<Actions> handleAll;
        for(const QByteArray &rep : reply) {
            if(rep.startsWith("_T_O_K_E_N_")) {
                qputenv("XDG_ACTIVATION_TOKEN", rep.last(rep.length()-11));
            } else if(rep.startsWith("_F_I_L_E_")) {
                m_receivedFile = rep.last(rep.length()-9);
                handleAll.append(Actions::File);
            } else if(rep.startsWith("_S_H_O_R_T_C_U_T_")) {
                m_receivedShortcut = rep.last(rep.length()-17);
                handleAll.append(Actions::Shortcut);
            } else if(rep.startsWith("_S_E_T_T_I_N_G_")) {
                const QList<QByteArray> tmp = rep.last(rep.length()-15).split(':');
                m_receivedSetting[0] = tmp[0];
                m_receivedSetting[1] = tmp[1];
                handleAll.append(Actions::Setting);
            } else {
                const QList<QByteArray> _reps = rep.split('/');
                for(const QByteArray &r : _reps) {
                    handleAll.append(static_cast<Actions>(r.toInt()));
                }
            }
        }
        handleMessage(handleAll);
    }
    socket->close();
    delete socket;
}

void PQCSingleInstance::handleMessage(const QList<Actions> msg, bool includeFileProcessing) {

    qDebug() << "args: msg";

    // NOTE
    // file processing is handled directly during startup for faster displaying of files
    // all others might need to be re-processed once the ui is ready
    // that's why this call is also triggered from qml at the end of startup

    QStringList allfiles;
    QStringList allfolders;

    QFileInfo info(m_receivedFile);

    for(const Actions &m : std::as_const(msg)) {

        switch(m) {

        case Actions::File:

            if(includeFileProcessing) {

                // sort by files and folders
                // that way we can make sure to always load the first specified file as initial image
                if(!info.exists())
                    continue;
                if(info.isFile())
                    allfiles.append(m_receivedFile);
                else if(info.isDir())
                    allfolders.append(m_receivedFile);

            }

            break;

        case Actions::Open:

            Q_EMIT PQCNotifyCPP::get().cmdOpen();
            break;

        case Actions::Show:

            Q_EMIT PQCNotifyCPP::get().cmdShow();
            break;

        case Actions::Hide:

            Q_EMIT PQCNotifyCPP::get().cmdHide();
            break;

        case Actions::Quit:

            Q_EMIT PQCNotifyCPP::get().cmdQuit();
            break;

        case Actions::Toggle:

            Q_EMIT PQCNotifyCPP::get().cmdToggle();
            break;

        case Actions::StartInTray:

            PQCNotifyCPP::get().setStartInTray(true);
            break;

        case Actions::Tray:

            Q_EMIT PQCNotifyCPP::get().cmdTray(true);
            break;

        case Actions::NoTray:

            Q_EMIT PQCNotifyCPP::get().cmdTray(false);
            break;

        case Actions::Shortcut:

            Q_EMIT PQCNotifyCPP::get().cmdShortcutSequence(m_receivedShortcut);
            break;

        case Actions::Debug:

            PQCNotifyCPP::get().setDebug(true);
            break;

        case Actions::NoDebug:

            PQCNotifyCPP::get().setDebug(false);
            break;

        case Actions::Setting:

            PQCNotifyCPP::get().setSettingUpdate({m_receivedSetting[0], m_receivedSetting[1]});
            break;

        default:
            qWarning() << "Unknown action received:" << static_cast<int>(m);

        }

    }

    if(includeFileProcessing) {
        // if we have files and/or folders that were passed on
        if(allfiles.length() > 0 || allfolders.length() > 0) {
            allfiles.append(allfolders);
            if(allfiles.length() > 1)
                Q_EMIT PQCFileFolderModelCPP::get().setExtraFoldersToLoad(allfiles.mid(1));
            else
                Q_EMIT PQCFileFolderModelCPP::get().setExtraFoldersToLoad({});
            PQCNotifyCPP::get().setFilePath(allfiles[0]);
        }
    }

}

bool PQCSingleInstance::notify(QObject *obj, QEvent *e) {

    const QString cn = obj->metaObject()->className();
    if(cn == "QQuickRootItem") {
        if(e->type() == QEvent::KeyPress) {
            QKeyEvent *ev = reinterpret_cast<QKeyEvent*>(e);
            Q_EMIT PQCNotifyCPP::get().keyPress(ev->key(), ev->modifiers());
        } else if(e->type() == QEvent::KeyRelease) {
            QKeyEvent *ev = reinterpret_cast<QKeyEvent*>(e);
            Q_EMIT PQCNotifyCPP::get().keyRelease(ev->key(), ev->modifiers());
        }
    } else if(cn.startsWith("PQMainWindow")) {
        if(e->type() == QEvent::Leave) {
            Q_EMIT PQCNotifyCPP::get().mouseWindowExit();
        } else if(e->type() == QEvent::Enter)
            Q_EMIT PQCNotifyCPP::get().mouseWindowEnter();
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
