#include <QApplication>
#include "mainwindow.h"
#include <QSignalMapper>
#include "singleinstance/singleinstance.h"
#include "logger.h"

#include "startup/configfolder.h"
#include "startup/updatecheck.h"
#include "startup/screenshots.h"
#include "startup/migration.h"
#include "startup/startintray.h"
#include "startup/localisation.h"
#include "startup/thumbnails.h"
#include "startup/fileformats.h"

int main(int argc, char *argv[]) {

	// We store this as a QString, as this way we don't have to explicitely cast VERSION to a QString below
	QString version = VERSION;

	// Set app name and version
	QApplication::setApplicationName("PhotoQt");
	QApplication::setApplicationVersion(version);

	// Create a new instance (includes handling of argc/argv)
	// This class ensures, that only one instance is running. If one is already running, we pass the commands to the main process and exit.
	// If no process is running yet, we create a LocalServer and continue below
	SingleInstance a(argc, argv);

	if(a.verbose) LOG << DATE << "Starting PhotoQt..." << std::endl;


	// SOME START-UP CHECKS

	// We get the settings text once, and modify the string only during the checks and write the settings to file once afterwards
	QFile settingsfile(QDir::homePath() + "/.photoqt/settings");
	QString settingsText = "";
	if(settingsfile.exists() && settingsfile.open(QIODevice::ReadOnly)) {
		QTextStream in(&settingsfile);
		settingsText = in.readAll();
		settingsfile.close();
	}

	// A few checks
	StartupCheck::ConfigFolder::ensureItExists(a.verbose);
	int update = StartupCheck::UpdateCheck::checkForUpdateInstall(a.verbose, &settingsText);
	StartupCheck::Screenshots::getAndStore(a.verbose);
	StartupCheck::StartInTray::makeSureSettingsReflectTrayStartupSetting(a.verbose,a.startintray,&settingsText);
	StartupCheck::Localisation::loadTranslation(a.verbose, &settingsText);
	StartupCheck::Thumbnails::checkThumbnailsDatabase(update, a.verbose);
	bool setDefaultFileformats = StartupCheck::FileFormats::checkForDefaultSettingsFileAndReturnWhetherDefaultsAreToBeSet(a.verbose);

	// Store the (updated) settings text
	QFile writesettings(QDir::homePath() + "/.photoqt/settings");
	if(!writesettings.open(QIODevice::WriteOnly | QIODevice::Truncate))
		LOG << DATE << "ERROR! Unable to update settings file at startup" << std::endl;
	else {
		QTextStream out(&writesettings);
		out << settingsText;
		writesettings.close();
	}

// Opt-in to High DPI usage of Pixmaps for larger screens with larger font DPI
#if (QT_VERSION >= QT_VERSION_CHECK(5, 4, 0))
	if(a.verbose) LOG << DATE << "Enabling use of High DPI pixmaps" << std::endl;
	a.setAttribute(Qt::AA_UseHighDpiPixmaps, true);
#endif

// Initialise GraphicsMagick library (required only once)
#ifdef GM
	if(a.verbose) LOG << DATE << "Initialising GraphicsMagick" << std::endl;
	Magick::InitializeMagick(*argv);
#endif

	/***************************
	 ***************************/
	// The Window has to be initialised *AFTER* the checks above to ensure that the settings exist and are updated and can be loaded
	MainWindow w(a.verbose,0);
	/***************************
	 ***************************/

	// Ensure that PhotoQt actually quits when last window is closed
	// Shouldn't be an issue, but better safe than sorry
	qApp->setQuitOnLastWindowClosed(true);

	// A remote action passed on via command line triggers the 'interaction' signal, so we pass it on to the MainWindow
	QObject::connect(&a, SIGNAL(interaction(QString)), &w, SLOT(remoteAction(QString)));

	// If during the startup checks the need to set the default fileformats was detected, then we do so now
	if(setDefaultFileformats) w.setDefaultFileFormats();
	if(update == 2) w.setDefaultSettings();

	// DISPLAY MAINWINDOW
	if(!a.startintray) {
		// There's no need to have the code to show the window twice (it used to be here AND in the mainwindow.cpp)
		w.updateWindowGeometry();
	} else
		w.hide();

	// Possibly disable thumbnails
	if(a.nothumbs) {
		if(a.verbose) LOG << DATE << "Disabling Thumbnails" << std::endl;
		w.disableThumbnails();
	}

	// After a new install/update, we first show a startup message (which, when closed, calls openFile())
	if(update != 0)
		w.showStartup(update == 2 ? "installed" : "updated");
	else
		w.handleOpenFileEvent(a.filename);

	return a.exec();

}
