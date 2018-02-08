/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
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

SingleInstance::SingleInstance(int &argc, char *argv[]) : QApplication(argc, argv) {

    // Parse the command line arguments
    CommandLineParser handler(this);

    // This is the message string that we send to a running instance (if it exists
    QByteArray message = "";

    socket = nullptr;
    server = nullptr;

    // Check for filenames
    if(handler.foundFilename.length() > 0) {
        QString fname = handler.foundFilename;
        // If PhotoQt has been restarted (from importing config file)
        // -> wait for a little bit to make sure the previous instance of PhotoQt is properly closed
        if(fname.startsWith("RESTARTRESTARTRESTART")) {
            std::this_thread::sleep_for(std::chrono::seconds(1));
            fname = fname.remove(0,21);
        }
        if(fname.trimmed() != "")
            message += ":-:-:" + QByteArray("::file::") + QFileInfo(fname).absoluteFilePath();
    }

    // Check for any other set option
    for(QString opt : handler.foundOptions)
        message += ":-:-:::" + opt.toUtf8() + "::";

    // This is treated specially: We export the config file and then quit without continuing
    exportAndQuitNow = "";
    if(message.contains("::export::")) {
        exportAndQuitNow = handler.foundValues["export"];
        // we need to 'new' the following two otherwise it will crash in the destructor
        socket = new QLocalSocket();
        server = new QLocalServer();
        return;
     }
    importAndQuitNow = "";
    if(message.contains("::import::")) {
        importAndQuitNow = handler.foundValues["import"];
        // we need to 'new' the following two otherwise it will crash in the destructor
        socket = new QLocalSocket();
        server = new QLocalServer();
        return;
    }

    if(message.contains("::standalone::")) {
        handleResponse(message);
        return;
    }


    /*****************/
    /* Server/Socket */
    /*****************/

    // Create server name - a more 'portable' way would be to possibly also use organisationName, and to make sure no
    // special characters are used. However in our case that's not necessary...
    QString server_str = qApp->applicationName();

    // Connect to a Local Server (if available)
    socket = new QLocalSocket();
    socket->connectToServer(server_str);

    // If this is successfull, then an instance is already running
    if(socket->waitForConnected(1000)) {

        // if no argument was passed on, we add 'show'
        if(argc == 1)
            message += ":-:-:::show::";

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
        connect(server, SIGNAL(newConnection()), this, SLOT(newConnection()));

        handleResponse(message);

    }
}

void SingleInstance::newConnection() {
    QLocalSocket *socket = server->nextPendingConnection();
    if(socket->waitForReadyRead(2000))
        handleResponse(socket->readAll());
    socket->close();
    delete socket;
}

void SingleInstance::handleResponse(QString msg) {

    // Analyse what action(s) to take

    // If verbose/debug mode enabled, set environment variable. This variable can be read anywhere to detect this mode.
    // On quit, this variable will be unset again
    if(msg.contains("::debug::")) {
        std::cout << "***********************" << std::endl;
        std::cout << "ENABLING DEBUG MESSAGES" << std::endl;
        std::cout << "***********************" << std::endl;
        qputenv("PHOTOQT_DEBUG", "yes");
    }
    // This allows the user to undo the switch during runtime, enabling getting debug messages for specific actions only
    if(msg.contains("::no-debug::")) {
        std::cout << "************************" << std::endl;
        std::cout << "DISABLING DEBUG MESSAGES" << std::endl;
        std::cout << "************************" << std::endl;
        qunsetenv("PHOTOQT_DEBUG");
    }

    // Reset this variable before checking
    startintray = false;

    bool debug = (qgetenv("PHOTOQT_DEBUG") == "yes");

    if(msg.contains("::file::")) {
        filename = msg.split("::file::").at(1).split(":-:-:").at(0);
        if(debug) LOG << CURDATE << "SingleInstance - found filename: " << filename.toStdString() << NL;
        emit interaction("::file::" + filename);
    } else if(msg.contains("::start-in-tray::")) {
        startintray = true;
        if(debug) LOG << CURDATE << "SingleInstance - found flag: start-in-tray" << NL;
    } else if((msg.contains("::open::") || msg.contains("::o::"))) {
        if(debug) LOG << CURDATE << "SingleInstance - found flag: o/open" << NL;
        emit interaction("open");
    } else if(msg.contains("::thumbs::")) {
        if(debug) LOG << CURDATE << "SingleInstance - found flag: thumbs" << NL;
        emit interaction("thumbs");
    } else if(msg.contains("::no-thumbs::")) {
        if(debug) LOG << CURDATE << "SingleInstance - found flag: no-thumbs" << NL;
        emit interaction("nothumbs");
    } else if(msg.contains("::toggle::") || msg.contains("::t::")) {
        if(debug) LOG << CURDATE << "SingleInstance - found flag: t/toggle" << NL;
        emit interaction("toggle");
    } else if(msg.contains("::show::") || msg.contains("::s::")) {
        if(debug) LOG << CURDATE << "SingleInstance - found flag: s/show" << NL;
        emit interaction("show");
    } else if(msg.contains("::hide::")) {
        if(debug) LOG << CURDATE << "SingleInstance - found flag: hide" << NL;
        emit interaction("hide");
    }

}

SingleInstance::~SingleInstance() {
    if(socket != nullptr)
        delete socket;
    if(server != nullptr) {
        server->close();
        delete server;
    }
}
