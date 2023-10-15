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

PQCSingleInstance::PQCSingleInstance(int &argc, char *argv[]) : QApplication(argc, argv) {

    // Parse the command line arguments
    PQCCommandLineParser parser(*this);
    PQCCommandLineResult result = parser.getResult();

    // This is the message string that we send to a running instance (if it exists
    QByteArray message = "";

    socket = nullptr;
    server = nullptr;

    if(result & PQCCommandLineFile) {
        QString fullfilename = parser.filename;
        if(!QFileInfo(fullfilename).isAbsolute())
            fullfilename = QDir::currentPath() + "/" + parser.filename;
        message += ":://::_F_I_L_E_" + QFileInfo(fullfilename).canonicalFilePath().toUtf8();
    }

    if(result & PQCCommandLineOpen)
        message += ":://::_O_P_E_N_";

    if(result & PQCCommandLineShow)
        message += ":://::_S_H_O_W_";

    if(result & PQCCommandLineHide)
        message += ":://::_H_I_D_E_";

    if(result & PQCCommandLineToggle)
        message += ":://::_T_O_G_G_L_E_";

    if(result & PQCCommandLineThumbs)
        message += ":://::_T_H_U_M_B_S_";

    if(result & PQCCommandLineNoThumbs)
        message += ":://::_N_O_T_H_U_M_B_S_";

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

    if(result & PQCCommandLineStandalone)
        message += ":://::_S_T_A_N_D_A_L_O_N_E_";

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

    if(message.contains(":://::_S_T_A_N_D_A_L_O_N_E_")) {
        handleMessage(message);
        return;
    }


    /*****************/
    /* Server/Socket */
    /*****************/

    // Create server name
    QString server_str = "org.photoqt.PhotoQt";

    // Connect to a Local Server (if available)
    socket = new QLocalSocket();
    socket->connectToServer(server_str);

    // If this is successfull, then an instance is already running
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

    this->installEventFilter(this);

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

    for(const QString &m : qAsConst(parts)) {

        if(m.startsWith("_F_I_L_E_"))

            PQCNotify::get().setFilePath(m.last(m.length()-9));

        else if(m == "_O_P_E_N_")

            Q_EMIT PQCNotify::get().cmdOpen();

        else if(m == "_S_H_O_W_")

            Q_EMIT PQCNotify::get().cmdShow();

        else if(m == "_H_I_D_E_")

            Q_EMIT PQCNotify::get().cmdHide();

        else if(m == "_T_O_G_G_L_E_")

            Q_EMIT PQCNotify::get().cmdToggle();

        else if(m == "_T_H_U_M_B_S_")

            PQCNotify::get().setThumbs(true);

        else if(m == "_N_O_T_H_U_M_B_S_")

            PQCNotify::get().setThumbs(false);

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

    }

}

bool PQCSingleInstance::eventFilter(QObject *obj, QEvent *e) {

    if(e->type() == QEvent::KeyPress && !PQCNotify::get().getModalFileDialogOpen()) {
        QKeyEvent *ev = reinterpret_cast<QKeyEvent*>(e);

        // These events are ignored if a spinbox is focussed:
        // - numbers
        // - backspace/delete
        // - left/right
        if(PQCNotify::get().getSpinBoxPassKeyEvents() &&
            (ev->key() == Qt::Key_1 || ev->key() == Qt::Key_2 || ev->key() == Qt::Key_3 || ev->key() == Qt::Key_4 || ev->key() == Qt::Key_5 ||
             ev->key() == Qt::Key_6 || ev->key() == Qt::Key_7 || ev->key() == Qt::Key_8 || ev->key() == Qt::Key_9 || ev->key() == Qt::Key_0 ||
             ev->key() == Qt::Key_Backspace || ev->key() == Qt::Key_Delete ||
             ev->key() == Qt::Key_Left || ev->key() == Qt::Key_Right)) {

            return QApplication::eventFilter(obj, e);

        }

        if(PQCNotify::get().getIgnoreKeysExceptEnterEsc() && (ev->key() != Qt::Key_Enter && ev->key() != Qt::Key_Return && ev->key() != Qt::Key_Escape))
            return QApplication::eventFilter(obj, e);

        Q_EMIT PQCNotify::get().keyPress(ev->key(), ev->modifiers());
        return true;
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
