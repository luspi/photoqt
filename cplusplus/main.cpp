#include <QApplication>
#include "mainwindow.h"
#include <QSignalMapper>
#include "singleinstance/singleinstance.h"
#include "logger.h"

#include "startup/updatecheck.h"
#include "startup/screenshots.h"
#include "startup/migration.h"
#include "startup/startintray.h"
#include "startup/localisation.h"
#include "startup/thumbnails.h"
#include "startup/fileformats.h"
#include "startup/shortcuts.h"
#include "startup/exportimport.h"

int main(int argc, char *argv[]) {

	QFile f(QDir::tempPath() + "/photoqt.log");
	f.remove();

	// We store this as a QString, as this way we don't have to explicitely cast VERSION to a QString below
	QString version = VERSION;

	// Set app name and version
	QApplication::setApplicationName("PhotoQt");
	QApplication::setApplicationVersion(version);

	// Create a new instance (includes handling of argc/argv)
	// This class ensures, that only one instance is running. If one is already running, we pass the commands to the main process and exit.
	// If no process is running yet, we create a LocalServer and continue below
	SingleInstance a(argc, argv);

	// This means, that, e.g., --export or --import was passed along -> we will simply quit (preparation for that is done in the handleExportImport() function)
	if(StartupCheck::ExportImport::handleExportImport(&a) != -1) return 0;


	if(a.verbose) LOG << CURDATE << "Starting PhotoQt..." << NL;


	// SOME START-UP CHECKS

	// First, we migrate the configuration to the new system used (freedesktop.org standard)
	// Even if no migration is necessary, this ensures that all config folders are created
	StartupCheck::Migration::migrateIfNecessary(a.verbose);

	// We get the settings text once, and modify the string only during the checks and write the settings to file once afterwards
	QFile settingsfile(CFG_SETTINGS_FILE);
	QString settingsText = "";
	if(settingsfile.exists() && settingsfile.open(QIODevice::ReadOnly)) {
		QTextStream in(&settingsfile);
		settingsText = in.readAll();
		settingsfile.close();
	}

	// The translator has to exist out here (not only in the startup class) as it has to live until the end
	QTranslator trans;

	// A few checks
	int update = StartupCheck::UpdateCheck::checkForUpdateInstall(a.verbose, &settingsText);
	StartupCheck::Screenshots::getAndStore(a.verbose);
	StartupCheck::StartInTray::makeSureSettingsReflectTrayStartupSetting(a.verbose,a.startintray,&settingsText);
	StartupCheck::Localisation::loadTranslation(a.verbose, &settingsText, &trans);
	StartupCheck::Thumbnails::checkThumbnailsDatabase(update, a.nothumbs, &settingsText, a.verbose);
	StartupCheck::FileFormats::checkForDefaultSettingsFileAndReturnWhetherDefaultsAreToBeSet(a.verbose);
	StartupCheck::Shortcuts::makeSureShortcutsFileExists(a.verbose);
	StartupCheck::Shortcuts::migrateMouseShortcuts(a.verbose);

	// Store the (updated) settings text
	QFile writesettings(CFG_SETTINGS_FILE);
	if(!writesettings.open(QIODevice::WriteOnly | QIODevice::Truncate))
		LOG << CURDATE << "ERROR! Unable to update settings file at startup" << NL;
	else {
		QTextStream out(&writesettings);
		out << settingsText;
		writesettings.close();
	}

// Opt-in to High DPI usage of Pixmaps for larger screens with larger font DPI
#if (QT_VERSION >= QT_VERSION_CHECK(5, 4, 0))
	if(a.verbose) LOG << CURDATE << "Enabling use of High DPI pixmaps" << NL;
	a.setAttribute(Qt::AA_UseHighDpiPixmaps, true);
#endif

// Initialise GraphicsMagick library (required only once)
#ifdef GM
	if(a.verbose) LOG << CURDATE << "Initialising GraphicsMagick" << NL;
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

	// DISPLAY MAINWINDOW
	if(!a.startintray) {
		// There's no need to have the code to show the window twice (it used to be here AND in the mainwindow.cpp)
		w.updateWindowGeometry();
	} else
		w.hide();

	// After a new install/update, we first show a startup message (which, when closed, calls openFile())
	// otherwise, we either load the last used image or request a new file (depending on settings)
	w.handleStartup(update, a.filename);

	return a.exec();

}
