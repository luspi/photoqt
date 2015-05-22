#include "singleinstance.h"

SingleInstance::SingleInstance(int &argc, char *argv[]) : QApplication(argc, argv) {

	/******************/
	/* SOME VARIABLES */
	/******************/

	// A help message for the command line

	QString help = "\nPhotoQt v" + QString(VERSION) + " -  Copyright (C) " + QString::number(QDate::currentDate().year()) + ", Lukas Spies (Lukas@photoqt.org), License: GPLv2 (or later)\n";
	help += "PhotoQt is a fast, simple, good looking, yet powerfull and highly configurable image viewer.\n\n";

	help += " Usage: photoqt [options|file]\n\n";

	help += "Options:\n\n";
	help += "\t--h, --help\t\tThis help message\n\n";

	help += ">> At start-up (no remote effect):\n\n";

	help += "\t--start-in-tray\t\tStart PhotoQt hidden to the system tray\n";
	help += "\t--v, --verbose\t\tEnabling debug messages\n\n";

	help += ">> Remote Controlling:\n\n";

	help += "\t--open\t\t\tMakes PhotoQt ask for a new file\n";
	help += "\t--toggle\t\tToggles PhotoQt - hides PhotoQt if visible, shows if hidden\n";
	help += "\t--show\t\t\tShows PhotoQt (does nothing if already shown)\n";
	help += "\t--hide\t\t\tHides PhotoQt (does nothing if already hidden)\n";
	help += "\t--no-thumbs\t\tDisable thumbnails\n";
	help += "\t--thumbs\t\tEnable thumbnails\n\n";

	help += " Notes:\n";
	help += "   -> All options (except --hide and --toggle) always cause PhotoQt to be shown.\n";
	help += "   -> All options also work with a single '-' at the beginning.\n\n";

	help += "\n   Enjoy PhotoQt :-)\n\n\n";


	// Composing all command line arguments in stringlist (except first one, that's the app name)
	QStringList allArgs;
	for(int i = 1; i < argc; ++i)
		allArgs.append(argv[i]);

	// This file triggers an automatic verbose mode
	if(QFile(QDir::homePath()+"/.photoqt/verbose").exists())
		allArgs.append("--v");

	// List of known arguments
	QStringList knownArgs;
	QStringList knownArgs_msg;
	knownArgs << "--open";
	knownArgs_msg << "::open::";
	knownArgs << "--no-thumbs";
	knownArgs_msg << "::nothumbs::";
	knownArgs << "--thumbs";
	knownArgs_msg << "::thumbs::";
	knownArgs << "--toggle";
	knownArgs_msg << "::toggle::";
	knownArgs << "--show";
	knownArgs_msg << "::show::";
	knownArgs << "--hide";
	knownArgs_msg << "::hide::";
	knownArgs << "--start-in-tray";
	knownArgs_msg << "::startintray::";
	knownArgs << "--verbose";
	knownArgs_msg << "::verbose::";
	knownArgs << "--v";
	knownArgs_msg << "::verbose::";
	knownArgs << "--update";
	knownArgs_msg << "::update::";
	knownArgs << "--install";
	knownArgs_msg << "::install::";


	// Display help message and exit
	if(allArgs.contains("--h") || allArgs.contains("-h") || allArgs.contains("--help") || allArgs.contains("-help")) {
		std::cout << help.toStdString();
		std::exit(0);	// FORCE EXIT APP
	}

	// This boolean is set to true if an unknown command is used
	bool err = false;
	QByteArray message = "";

	for(int i = 0; i < allArgs.length(); ++i) {

		// We ignore the verbose switch when an instance is already running
		if(allArgs.at(i) != "--v" && allArgs.at(i) != "--verbose") {
			if(knownArgs.contains(allArgs.at(i))) {
				message += ":-:-:";
				message += knownArgs_msg.at(knownArgs.indexOf(allArgs.at(i)));
			} else if(knownArgs.contains("-" + allArgs.at(i))) {
				message += ":-:-:";
				message += "-" + knownArgs_msg.at(knownArgs.indexOf("-" + allArgs.at(i)));
			} else if(allArgs.at(i).startsWith("-"))
				err = true;
			else {
				QString filename = allArgs.at(i);
				message += ":-:-:";
				message += QByteArray("::file::") + QFileInfo(filename).absoluteFilePath().toLatin1();
			}
		}
	}

	// If an incorrect argument was sent, display help message and exit
	if(err) {
		std::cout << help.toStdString();
		std::exit(0);
	}



	// Otherwise we will either send the information to the main process,
	// or (if in main process) execute the respective stuff



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

		// Send composed message string
		socket->write(message);
		socket->flush();

		// Inform user
		std::clog << "Running instance of PhotoQt detected..." << std::endl;

		// Exit the code (need to use stdlib exit function to ensure an immediate exit)
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

	// These ones are passed on to the main process
	open = (msg.contains("::open::") && !msg.contains("::file::"));
	nothumbs = (msg.contains("::nothumbs::") && !msg.contains("::thumbs::"));
	thumbs = msg.contains("::thumbs::");
	toggle = msg.contains("::toggle::") && !msg.contains("::startintray::");
	show = ((msg.contains("::show::") || !msg.contains("::hide::")) && !msg.contains("::toggle::") && !msg.contains("::startintray::"));
	hide = (msg.contains("::hide::") && !msg.contains("::toggle::") && !msg.contains("::startintray::"));

	// These ones only play a role on startup and are ignored otherwise
	verbose = (msg.contains("::verbose::") || QFile(QDir::homePath() + "/.photoqt/verbose").exists());
	startintray = (msg.contains("::startintray::"));

	// DEVELOPMENT ONLY
	update = (msg.contains("::update::"));
	install = (msg.contains("::install::"));

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
	server->close();
	delete socket;
	delete server;
}
