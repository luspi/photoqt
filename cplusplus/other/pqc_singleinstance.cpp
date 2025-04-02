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
#include <qlogging.h>   // needed in this form to compile with Qt 6.2

#include <QQmlApplicationEngine>
#include <QLocalSocket>
#include <QLocalServer>

#include <pqc_commandlineparser.h>
#include <pqc_singleinstance.h>
#include <pqc_notify.h>
#include <pqc_settings.h>
#include <pqc_configfiles.h>
#include <pqc_filefoldermodel.h>

PQCSingleInstance::PQCSingleInstance(int &argc, char *argv[]) : QApplication(argc, argv) {

    // Parse the command line arguments
    PQCCommandLineParser parser(*this);
    PQCCommandLineResult result = parser.getResult();

    // This is the message string that we send to a running instance (if it exists
    QByteArray message = "";

    socket = nullptr;
    server = nullptr;

    if(result & PQCCommandLineFile) {
        for(const auto &f : std::as_const(parser.filenames)) {
            QString ff = f;
            if(!QFileInfo(ff).isAbsolute())
                ff = QDir::currentPath() + "/" + ff;
            message += ":://::_F_I_L_E_" + QFileInfo(ff).canonicalFilePath().toUtf8();
        }
    }

    if(result & PQCCommandLineOpen)
        message += ":://::_O_P_E_N_";

    if(result & PQCCommandLineShow)
        message += ":://::_S_H_O_W_";

    if(result & PQCCommandLineHide)
        message += ":://::_H_I_D_E_";

    if(result & PQCCommandLineQuit)
        message += ":://::_Q_U_I_T_";

    if(result & PQCCommandLineToggle)
        message += ":://::_T_O_G_G_L_E_";

    if(result & PQShortcutSequence)
        message += ":://::_S_H_O_R_T_C_U_T_" + parser.shortcutSequence.toUtf8();

    if(result & PQCCommandLineStartInTray)
        message += ":://::_S_T_A_R_T_I_N_T_R_A_Y_";

    if(result & PQCCommandLineEnableTray)
        message += ":://::_T_R_A_Y_";

    if(result & PQCCommandLineDisableTray)
        message += ":://::_N_O_T_R_A_Y_";

    if(result & PQCCommandLineDebug)
        message += ":://::_D_E_B_U_G_";

    if(result & PQCCommandLineNoDebug)
        message += ":://::_N_O_D_E_B_U_G_";

    if(result & PQCCommandLineSettingUpdate)
        message += ":://::_S_E_T_T_I_N_G_" + parser.settingUpdate.join(":").toUtf8();

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

    this->installEventFilter(this);

    // we need to figure out if multiple instances are allowed here WITHOUT using the PQCSettings class
    if(QFile::exists(PQCConfigFiles::get().SETTINGS_DB())) {
        QSqlDatabase dbtmp;
        if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
            dbtmp = QSqlDatabase::addDatabase("QSQLITE3", "settingsmultiple");
        else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
            dbtmp = QSqlDatabase::addDatabase("QSQLITE", "settingsmultiple");
        dbtmp.setConnectOptions("QSQLITE_OPEN_READONLY");
        dbtmp.setDatabaseName(PQCConfigFiles::get().SETTINGS_DB());
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
                        handleMessage(message);
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

        if(message == "")
            message = ":://::_S_H_O_W_";

        // Send composed message string
        socket->write(message);
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

        handleMessage(message);

    }

}

void PQCSingleInstance::newConnection() {
    QLocalSocket *socket = server->nextPendingConnection();
    if(socket->waitForReadyRead(2000))
        handleMessage(socket->readAll());
    socket->close();
    delete socket;
}

void PQCSingleInstance::handleMessage(QString msg) {

    qDebug() << "args: msg =" << msg;

    QStringList parts = msg.split(":://::");

    QStringList allfiles;
    QStringList allfolders;

    for(const QString &m : std::as_const(parts)) {

        if(m.startsWith("_F_I_L_E_")) {

            // sort by files and folders
            // that way we can make sure to always load the first specified file as initial image
            QFileInfo info(m.last(m.length()-9));
            if(!info.exists())
                continue;
            if(info.isFile())
                allfiles.append(m.last(m.length()-9));
            else if(info.isDir())
                allfolders.append(m.last(m.length()-9));

        } else if(m == "_O_P_E_N_")

            Q_EMIT PQCNotify::get().cmdOpen();

        else if(m == "_S_H_O_W_")

            Q_EMIT PQCNotify::get().cmdShow();

        else if(m == "_H_I_D_E_")

            Q_EMIT PQCNotify::get().cmdHide();

        else if(m == "_Q_U_I_T_")

        Q_EMIT PQCNotify::get().cmdQuit();

        else if(m == "_T_O_G_G_L_E_")

            Q_EMIT PQCNotify::get().cmdToggle();

        else if(m == "_S_T_A_R_T_I_N_T_R_A_Y_")

            PQCNotify::get().setStartInTray(true);

        else if(m == "_T_R_A_Y_")

            Q_EMIT PQCNotify::get().cmdTray(true);

        else if(m == "_N_O_T_R_A_Y_")

            Q_EMIT PQCNotify::get().cmdTray(false);

        else if(m.startsWith("_S_H_O_R_T_C_U_T_"))

            Q_EMIT PQCNotify::get().cmdShortcutSequence(m.last(m.length()-17));

        else if(m == "_D_E_B_U_G_")

            PQCNotify::get().setDebug(true);

        else if(m == "_N_O_D_E_B_U_G_")

            PQCNotify::get().setDebug(false);

        else if(m.startsWith("_S_E_T_T_I_N_G_"))

            PQCNotify::get().setSettingUpdate(m.last(m.length()-15).split(":"));

    }

    // if we have files and/or folders that were passed on
    if(allfiles.length() > 0 || allfolders.length() > 0) {
        allfiles.append(allfolders);
        if(allfiles.length() > 1)
            PQCFileFolderModel::get().setExtraFoldersToLoad(allfiles.mid(1));
        else
            PQCFileFolderModel::get().setExtraFoldersToLoad({});
        PQCNotify::get().setFilePath(allfiles[0]);
    }

}

bool PQCSingleInstance::eventFilter(QObject *obj, QEvent *e) {

    if(e->type() == QEvent::KeyPress && !PQCNotify::get().getModalFileDialogOpen()) {

        // do not process events
        if(PQCNotify::get().getIgnoreAllKeys()) {
            return QApplication::eventFilter(obj, e);
        }

        QKeyEvent *ev = reinterpret_cast<QKeyEvent*>(e);

        // These events are ignored if a spinbox is focussed:
        // - numbers
        // - backspace/delete
        // - left/right
        if(PQCNotify::get().getSpinBoxPassKeyEvents() &&
            (ev->key() == Qt::Key_1 || ev->key() == Qt::Key_2 || ev->key() == Qt::Key_3 || ev->key() == Qt::Key_4 || ev->key() == Qt::Key_5 ||
             ev->key() == Qt::Key_6 || ev->key() == Qt::Key_7 || ev->key() == Qt::Key_8 || ev->key() == Qt::Key_9 || ev->key() == Qt::Key_0 ||
             ev->key() == Qt::Key_Backspace || ev->key() == Qt::Key_Delete || ev->key() == Qt::Key_Enter || ev->key() == Qt::Key_Return ||
             ev->key() == Qt::Key_Left || ev->key() == Qt::Key_Right || ev->key() == Qt::Key_Up || ev->key() == Qt::Key_Down)) {

            return QApplication::eventFilter(obj, e);

        }

        if(PQCNotify::get().getIgnoreKeysExceptEnterEsc() && (ev->key() != Qt::Key_Enter && ev->key() != Qt::Key_Return && ev->key() != Qt::Key_Escape))
            return QApplication::eventFilter(obj, e);

        if(PQCNotify::get().getIgnoreKeysExceptEsc() && (ev->key() != Qt::Key_Escape && (ev->modifiers() == Qt::NoModifier || ev->modifiers() == Qt::ShiftModifier)))
            return QApplication::eventFilter(obj, e);

        Q_EMIT PQCNotify::get().keyPress(ev->key(), ev->modifiers());
        return true;

    // this is to be used very sparingly and carefully to not react to events twice!
    } else if(e->type() == QEvent::KeyRelease) {

        QKeyEvent *ev = reinterpret_cast<QKeyEvent*>(e);
        Q_EMIT PQCNotify::get().keyRelease(ev->key(), ev->modifiers());

    } else if(e->type() == QEvent::Leave) {
        Q_EMIT PQCNotify::get().mouseWindowExit();
    } else if(e->type() == QEvent::Enter) {
        Q_EMIT PQCNotify::get().mouseWindowEnter();
    }

    return QApplication::eventFilter(obj, e);

}

PQCSingleInstance::~PQCSingleInstance() {
    if(socket != nullptr)
        delete socket;
    if(server != nullptr) {
        server->close();
        delete server;
    }
}
