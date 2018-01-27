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

    // If verbose/debug mode enabled, set environment variable. This variable can be read anywhere to detect this mode
    // On quit, this variable will be unset again
    if(msg.contains("::verbose::") || msg.contains("::debug::") ||
       QFile(QString(ConfigFiles::CONFIG_DIR()) + "/verbose").exists() || QFile(QString(ConfigFiles::CONFIG_DIR()) + "/verboselog").exists())
        qputenv("PHOTOQT_VERBOSE", "yes");

    // These ones are passed on to the main process
    open = ((msg.contains("::open::") || msg.contains("::o::")) && !msg.contains("::file::"));
    nothumbs = (msg.contains("::no-thumbs::") && !msg.contains("::thumbs::"));
    thumbs = msg.contains("::thumbs::");
    toggle = (msg.contains("::toggle::") || msg.contains("::t::")) && !msg.contains("::start-in-tray::");
    show = ((msg.contains("::show::") || msg.contains("::s::"))
            && !msg.contains("::toggle::") && !msg.contains("::t::") && !msg.contains("::start-in-tray::"));
    hide = (msg.contains("::hide::") && !msg.contains("::toggle::") && !msg.contains("::start-in-tray::"));

    // These ones only play a role on startup and are ignored otherwise
    startintray = (msg.contains("::start-in-tray::"));

    // Check for passed on filename (we check in mainwindow.cpp if it's an actually valid file)
    if(msg.contains("::file::"))
        filename = msg.split("::file::").at(1).split(":-:-:").at(0);
    else
        filename = "";

    if(filename != "") emit interaction("::file::" + filename);
    if(open) emit interaction("open");
    if(nothumbs) emit interaction("nothumbs");
    if(thumbs) emit interaction("thumbs");
    if(toggle) emit interaction("toggle");
    if(show) emit interaction("show");
    if(hide) emit interaction("hide");

}

SingleInstance::~SingleInstance() {
    if(socket != nullptr)
        delete socket;
    if(server != nullptr) {
        server->close();
        delete server;
    }
}
