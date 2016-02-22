#include <QApplication>
#include "mainwindow.h"
#include <QSignalMapper>
#include "singleinstance/singleinstance.h"
#include "logger.h"

int main(int argc, char *argv[]) {

	// We store this as a QString, as this way we don't have to explicitely cast VERSION to a QString below
	QString version = VERSION;

	// Set app name (needed later-on)
	QApplication::setApplicationName("PhotoQt");
	QApplication::setApplicationVersion(version);

	// Create a new instance (includes handling of argc/argv)
	// This class ensures, that only one instance is running. If one is already running, we pass the commands to the main process and exit.
	// If no process is running yet, we create a LocalServer and continue below
	SingleInstance a(argc, argv);


	if(a.verbose)
		LOG << DATE << "Starting PhotoQt..." << std::endl;


	// SOME START-UP CHECKS


	// Get screenshots for fake transparency
	for(int i = 0; i < QGuiApplication::screens().count(); ++i) {
		QScreen *screen = QGuiApplication::screens().at(i);
		QRect r = screen->geometry();
		QPixmap pix = screen->grabWindow(0,r.x(),r.y(),r.width(),r.height());
		pix.save(QDir::tempPath() + QString("/photoqt_screenshot_%1.jpg").arg(i));
	}

	// Ensure that the config folder exists
	QDir dir(QDir::homePath() + "/.photoqt");
	if(!dir.exists()) {
		if(a.verbose) LOG << DATE << "Creating ~/.photoqt/" << std::endl;
		dir.mkdir(QDir::homePath() + "/.photoqt");
	}

	// This int holds 1 if PhotoQt was updated and 2 if it's newly installed
	bool photoQtUpdated = false;
	bool photoQtInstalled = false;

	/****************************************************/
	// DEVELOPMENT ONLY
	photoQtUpdated = a.update;
	photoQtInstalled = a.install;
	// DEVELOPMENT ONLY
	/****************************************************/

	QString settingsFileTxt = "";

	// Check if the settings file exists. If not, create an empty file.
	QFile file(QDir::homePath() + "/.photoqt/settings");
	if(!file.exists()) {
		if(!file.open(QIODevice::WriteOnly))
			LOG << DATE << "ERROR: Couldn't create settings file! Please ensure that you have read&write access to your home directory" << std::endl;
		else {
			if(a.verbose) LOG << DATE << "Creating empty settings file" << std::endl;
			QTextStream out(&file);
			out << "Version=" + version + "\n";
			file.close();
		}

		photoQtInstalled = true;

	// If file does exist, check if it is from a previous version -> PhotoQt was updated
	} else {
		if(!file.open(QIODevice::ReadWrite))
			LOG << DATE << "ERROR: Couldn't read settings file! Please ensure that you have read&write access to home directory" << std::endl;
		else {
			QTextStream in(&file);
			settingsFileTxt = in.readAll();

			if(a.verbose) LOG << DATE << "Checking if first run of new version" << std::endl;

			// If it doesn't contain current version (some previous version)
			if(!settingsFileTxt.contains("Version=" + version + "\n")) {
				file.close();
				file.remove();
				file.open(QIODevice::ReadWrite);
				QStringList allSplit = settingsFileTxt.split("\n");
				allSplit.removeFirst();
				QString allFile = "Version=" + version + "\n" + allSplit.join("\n");

				// ONLY FOR V1.3, ENSURE THIS AS DEFAULT
				// We can do this change of settings, as there hasn't been a checkbox for this setting before
				// so everybody is still on the 'default', which should be 'not on top'
				if(allFile.contains("KeepOnTop=1"))
					allFile = allFile.replace("KeepOnTop=1","KeepOnTop=0");

				in << allFile;
				photoQtUpdated = true;
			}

			file.close();

		}
	}

#ifdef GM
	Magick::InitializeMagick(*argv);
#endif

	// If PhotoQt is supposed to be started minimized in system tray
	if(a.startintray) {
		if(a.verbose) LOG << DATE << "Starting minimised to tray" << std::endl;
		// If the option "Use Tray Icon" in the settings is not set, we set it
		QFile set(QDir::homePath() + "/.photoqt/settings");
		if(set.open(QIODevice::ReadOnly)) {
			QTextStream in(&set);
			QString all = in.readAll();
			if(!all.contains("TrayIcon=1")) {
				if(all.contains("TrayIcon=0"))
					all.replace("TrayIcon=0","TrayIcon=1");
				else if(all.contains("TrayIcon=2"))
					all.replace("TrayIcon=2","TrayIcon=1");
				else
					all += "\n[Temporary Appended]\nTrayIcon=1\n";
				set.close();
				set.remove();
				if(!set.open(QIODevice::WriteOnly))
					LOG << DATE << "ERROR: Can't enable tray icon setting!" << std::endl;
				QTextStream out(&set);
				out << all;
				set.close();
			} else
				set.close();
		} else
			LOG << DATE << "Unable to ensure TrayIcon is enabled - make sure it is enabled!!" << std::endl;
	}

#if (QT_VERSION >= QT_VERSION_CHECK(5, 4, 0))
	// Opt-in to High DPI usage of Pixmaps for larger screens with larger font DPI
	a.setAttribute(Qt::AA_UseHighDpiPixmaps, true);
#endif

	// LOAD THE TRANSLATOR
	QTranslator trans;

	// We use two strings, since the system locale usually is of the form e.g. "de_DE"
	// and some translations only come with the first part, i.e. "de",
	// and some with the full string. We need to be able to find both!
	if(a.verbose) LOG << DATE << "Checking for translation" << std::endl;
	QString code1 = "";
	QString code2 = "";
	bool noLanguageWasSet = false;
	if(settingsFileTxt.contains("Language=") && !settingsFileTxt.contains("Language=en") && !settingsFileTxt.contains("Language=\n")) {
		code1 = settingsFileTxt.split("Language=").at(1).split("\n").at(0).trimmed();
		code2 = code1;
	} else if(!settingsFileTxt.contains("Language=en")) {
		code1 = QLocale::system().name();
		code2 = QLocale::system().name().split("_").at(0);
	}
	if(a.verbose) LOG << DATE << "Found following language: " << code1.toStdString()  << "/" << code2.toStdString() << std::endl;
	if(QFile(":/photoqt_" + code1 + ".qm").exists()) {
		LOG << DATE << "Loading Translation:" << code1.toStdString() << std::endl;
		trans.load(":/photoqt_" + code1);
		a.installTranslator(&trans);
		code2 = code1;
		noLanguageWasSet = true;
	} else if(QFile(":/photoqt_" + code2 + ".qm").exists()) {
		LOG << DATE << "Loading Translation:" << code2.toStdString() << std::endl;
		trans.load(":/photoqt_" + code2);
		a.installTranslator(&trans);
		code1 = code2;
		noLanguageWasSet = true;
	}
	// Store translation in settings file
	if(noLanguageWasSet) {
		QFile file(QDir::homePath() + "/.photoqt/settings");
		if(!file.open(QIODevice::ReadWrite))
			LOG << DATE << "ERROR: Cannot open settings file to store detected localisation: " << file.errorString().trimmed().toStdString() << std::endl;
		else {
			QTextStream in(&file);
			QString all = in.readAll();
			file.close();
			if(all.contains("Language=\n"))
				all = all.replace("Language=\n",QString("Language=%1\n").arg(code1));
			else
				all += QString("\nLanguage=%1").arg(code1);
			QFile file_new(QDir::homePath() + "/.photoqt/settings");
			if(!file_new.open(QIODevice::WriteOnly | QIODevice::Truncate))
				LOG << DATE << "ERROR: Reopening settings file in 'Truncate' mode for stroing detected localisation failed: " << file_new.errorString().trimmed().toStdString() << std::endl;
			else {
				QTextStream out(&file_new);
				out << all;
				file_new.close();
			}
		}
	}

	// Check if thumbnail database exists. If not, create it
	QFile database(QDir::homePath() + "/.photoqt/thumbnails");
	if(!database.exists()) {

		if(a.verbose) LOG << DATE << "Create Thumbnail Database" << std::endl;

		QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", "thumbDB1");
		db.setDatabaseName(QDir::homePath() + "/.photoqt/thumbnails");
		if(!db.open()) LOG << DATE << "ERROR: Couldn't open thumbnail database:" << db.lastError().text().trimmed().toStdString() << std::endl;
		QSqlQuery query(db);
		query.prepare("CREATE TABLE Thumbnails (filepath TEXT,thumbnail BLOB, filelastmod INT, thumbcreated INT, origwidth INT, origheight INT)");
		query.exec();
		if(query.lastError().text().trimmed().length()) LOG << DATE << "ERROR (Creating Thumbnail Datbase):" << query.lastError().text().trimmed().toStdString() << std::endl;
		query.clear();


	} else if(photoQtInstalled || photoQtUpdated) {

		if(a.verbose) LOG << DATE << "Opening Thumbnail Database" << std::endl;

		// Opening the thumbnail database
		QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE","thumbDB2");
		db.setDatabaseName(QDir::homePath() + "/.photoqt/thumbnails");
		if(!db.open()) LOG << DATE << "ERROR: Couldn't open thumbnail database:" << db.lastError().text().trimmed().toStdString() << std::endl;

		QSqlQuery query_check(db);
		query_check.prepare("SELECT COUNT( * ) AS 'Count' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Thumbnails' AND COLUMN_NAME = 'origwidth'");
		query_check.exec();
		query_check.next();
		if(query_check.record().value(0) == 0) {
			QSqlQuery query(db);
			query.prepare("ALTER TABLE Thumbnails ADD COLUMN origwidth INT");
			query.exec();
			if(query.lastError().text().trimmed().length()) LOG << DATE << "ERROR (Adding origwidth to Thumbnail Database):" << query.lastError().text().trimmed().toStdString() << std::endl;
			query.clear();
			query.prepare("ALTER TABLE Thumbnails ADD COLUMN origheight INT");
			query.exec();
			if(query.lastError().text().trimmed().length()) LOG << DATE << "ERROR (Adding origheight to Thumbnail Database):" << query.lastError().text().trimmed().toStdString() << std::endl;
			query.clear();
		}
		query_check.clear();

	}

	qApp->setQuitOnLastWindowClosed(true);

	/***************************
	 ***************************/
	// The Window has to be initialised *AFTER* the checks above to ensure that the settings exist and are updated and can be loaded
	MainWindow w(a.verbose,0);
	/***************************
	 ***************************/

	// A remote action triggers the 'interaction' signal, so we pass it on to the MainWindow
	QObject::connect(&a, SIGNAL(interaction(QString)), &w, SLOT(remoteAction(QString)));

	// We moved from old way of handling image formats to new way
	// We can't do it before here, since we need access to global settings
	QFile fileformatsFile(QDir::homePath() + "/.photoqt/fileformats.disabled");
	if(!fileformatsFile.exists()) {

		// File content of disabled fileformats
		QString fileformatsDisabled = "*.epi\n";
		fileformatsDisabled += "*.epsi\n";
		fileformatsDisabled += "*.eps\n";
		fileformatsDisabled += "*.epsf\n";
		fileformatsDisabled += "*.eps2\n";
		fileformatsDisabled += "*.eps3\n";
		fileformatsDisabled += "*.ept\n";
		fileformatsDisabled += "*.pdf\n";
		fileformatsDisabled += "*.ps\n";
		fileformatsDisabled += "*.ps2\n";
		fileformatsDisabled += "*.ps3\n";
		fileformatsDisabled += "*.hp\n";
		fileformatsDisabled += "*.hpgl\n";
		fileformatsDisabled += "*.jbig\n";
		fileformatsDisabled += "*.jbg\n";
		fileformatsDisabled += "*.pwp\n";
		fileformatsDisabled += "*.rast\n";
		fileformatsDisabled += "*.rla\n";
		fileformatsDisabled += "*.rle\n";
		fileformatsDisabled += "*.sct\n";
		fileformatsDisabled += "*.tim\n";
		fileformatsDisabled += "**.psb\n";
		fileformatsDisabled += "**.psd\n";
		fileformatsDisabled += "**.xcf\n";

		// Write 'disabled filetypes' file
		if(fileformatsFile.open(QIODevice::WriteOnly)) {
			QTextStream out(&fileformatsFile);
			out << fileformatsDisabled;
			fileformatsFile.close();
		} else
			LOG << DATE << "ERROR: Can't write default disabled fileformats file" << std::endl;


		// Update settings with new values
		w.setDefaultFileFormats();

	}

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
	if(photoQtUpdated || photoQtInstalled)
		w.showStartup(photoQtInstalled ? "installed" : "updated");
	else
		w.handleOpenFileEvent(a.filename);

	return a.exec();


}
