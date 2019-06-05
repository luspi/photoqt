#include "singleinstance.h"

PQSingleInstance::PQSingleInstance(int &argc, char *argv[]) : QGuiApplication(argc, argv) {

    setApplicationName("photoqt");
    setApplicationVersion(VERSION);

    // Parse the command line arguments
    PQCommandLineParser parser(*this);
    PQCommandLineResult result = parser.getResult();

    // This is the message string that we send to a running instance (if it exists
    QByteArray message = "";

    socket = nullptr;
    server = nullptr;

    if(result & PQCommandLineFile)
        message += ":://::_F_I_L_E_" + QFileInfo(parser.filename).absoluteFilePath();

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

    if(result & PQCommandLineTray)
        message += ":://::_T_R_A_Y_";

    if(result & PQCommandLineDebug)
        message += ":://::_D_E_B_U_G_";


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

    if(message.contains("::standalone::")) {
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

    LOG << msg.toStdString() << NL;

    // Analyse what action(s) to take
/*
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
    }*/

}

PQSingleInstance::~PQSingleInstance() {
    if(socket != nullptr)
        delete socket;
    if(server != nullptr) {
        server->close();
        delete server;
    }
}
