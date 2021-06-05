/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
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

#include "singleinstance.h"

PQSingleInstance::PQSingleInstance(int &argc, char *argv[]) : QApplication(argc, argv) {

    setApplicationName("photoqt");
    setApplicationVersion(VERSION);

    // Parse the command line arguments
    PQCommandLineParser parser(*this);
    PQCommandLineResult result = parser.getResult();

    // This is the message string that we send to a running instance (if it exists
    QByteArray message = "";

    socket = nullptr;
    server = nullptr;

    if(result & PQCommandLineFile) {
        QString fullfilename = parser.filename;
        if(!QFileInfo(fullfilename).isAbsolute())
            fullfilename = QDir::currentPath() + "/" + parser.filename;
        message += ":://::_F_I_L_E_" + QFileInfo(fullfilename).canonicalFilePath().toUtf8();
    }

    if(result & PQCommandLineOpen)
        message += ":://::_O_P_E_N_";

    if(result & PQCommandLineShow)
        message += ":://::_S_H_O_W_";

    if(result & PQCommandLineHide)
        message += ":://::_H_I_D_E_";

    if(result & PQCommandLineToggle)
        message += ":://::_T_O_G_G_L_E_";

    if(result & PQCommandLineThumbs)
        message += ":://::_T_H_U_M_B_S_";

    if(result & PQCommandLineNoThumbs)
        message += ":://::_N_O_T_H_U_M_B_S_";

    if(result & PQShortcutSequence)
        message += ":://::_S_H_O_R_T_C_U_T_" + parser.shortcutSequence.toUtf8();

    if(result & PQCommandLineTray)
        message += ":://::_T_R_A_Y_";

    if(result & PQCommandLineDebug)
        message += ":://::_D_E_B_U_G_";

    if(result & PQCommandLineStandalone)
        message += ":://::_S_T_A_N_D_A_L_O_N_E_";


    // STANDALONE, EXPORT, IMPORT

    exportAndQuit = "";
    if(result & PQCommandLineExport) {
        exportAndQuit = parser.exportFileName;
        socket = new QLocalSocket();
        server = new QLocalServer();
        return;
    }

    importAndQuit = "";
    if(result & PQCommandLineImport) {
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
    QString server_str = qApp->applicationName();

    // Connect to a Local Server (if available)
    socket = new QLocalSocket();
    socket->connectToServer(server_str);

    // If this is successfull, then an instance is already running
    if(socket->waitForConnected(100)) {

        // Send composed message string
        socket->write(message);
        socket->flush();

        // Inform user
        LOG << CURDATE << "Running instance of PhotoQt detected..." << NL;

        // Exit the code (need to use stdlib exit function to ensure an immediate exit)
        // We wait 100ms as otherwise this instance might return as a crash (even though it doesn't really)
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
        std::exit(0);

    } else {

        // Create a new local server
        server = new QLocalServer();
        server->removeServer(server_str);
        server->listen(server_str);
        connect(server, &QLocalServer::newConnection, this, &PQSingleInstance::newConnection);

        handleMessage(message);

    }
}

void PQSingleInstance::newConnection() {
    QLocalSocket *socket = server->nextPendingConnection();
    if(socket->waitForReadyRead(2000))
        handleMessage(socket->readAll());
    socket->close();
    delete socket;
}

void PQSingleInstance::handleMessage(QString msg) {

    DBG << CURDATE << "PQSingleInstance::handleMessage()" << NL
        << CURDATE << "** msg = " << msg.toStdString() << NL;

    QStringList parts = msg.split(":://::");

    for(QString m : parts) {

        if(m.startsWith("_F_I_L_E_"))

            PQVariables::get().setCmdFilePath(m.remove(0, 9));

        else if(m.startsWith("_O_P_E_N_"))

            PQVariables::get().setCmdOpen(true);

        else if(m.startsWith("_S_H_O_W_"))

            PQVariables::get().setCmdShow(true);

        else if(m.startsWith("_H_I_D_E_"))

            PQVariables::get().setCmdHide(true);

        else if(m.startsWith("_T_O_G_G_L_E_"))

            PQVariables::get().setCmdToggle(true);

        else if(m.startsWith("_T_H_U_M_B_S_"))

            PQVariables::get().setCmdThumbs(true);

        else if(m.startsWith("_N_O_T_H_U_M_B_S_"))

            PQVariables::get().setCmdNoThumbs(true);

        else if(m.startsWith("_T_R_A_Y_"))

            PQVariables::get().setCmdTray(true);

        else if(m.startsWith("_S_H_O_R_T_C_U_T_"))

            PQVariables::get().setCmdShortcutSequence(m.remove(0, 17));

        else if(m.startsWith("_D_E_B_U_G_"))

            PQVariables::get().setCmdDebug(true);

    }

}

bool PQSingleInstance::notify(QObject *receiver, QEvent *e) {

    if(e->type() == QEvent::KeyPress) {
        QKeyEvent *ev = reinterpret_cast<QKeyEvent*>(e);
        if(qmlWindowAddresses.contains(receiver))
            emit PQKeyPressChecker::get().receivedKeyPress(ev->key(), ev->modifiers());
    }

    return QApplication::notify(receiver, e);

}

PQSingleInstance::~PQSingleInstance() {
    if(socket != nullptr)
        delete socket;
    if(server != nullptr) {
        server->close();
        delete server;
    }
}
