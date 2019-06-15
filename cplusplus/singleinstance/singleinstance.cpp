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

    if(result & PQCommandLineThumbs)
        message += ":://::_T_H_U_M_B_S_";

    if(result & PQCommandLineNoThumbs)
        message += ":://::_N_O_T_H_U_M_B_S_";

    if(result & PQShortcutSequence)
        message += ":://::_S_H_O_R_T_C_U_T_" + parser.shortcutSequence;

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

    QStringList parts = msg.split(":://::");

    for(QString m : parts) {

        if(m.startsWith("_F_I_L_E_"))

            PQVariables::get().setCmdFilePath(m.remove(0, 9));

        else if(m.startsWith("_O_P_E_N_"))

            PQVariables::get().setCmdOpen(true);

        else if(m.startsWith("_N_O_T_H_U_M_B_S_"))

            PQVariables::get().setCmdNoThumbs(true);

        else if(m.startsWith("_S_H_O_R_T_C_U_T_"))

            PQVariables::get().setCmdShortcutSequence(m.remove(0, 17));

        else if(m.startsWith("_D_E_B_U_G_"))

            PQVariables::get().setCmdDebug(true);

    }

}

PQSingleInstance::~PQSingleInstance() {
    if(socket != nullptr)
        delete socket;
    if(server != nullptr) {
        server->close();
        delete server;
    }
}
