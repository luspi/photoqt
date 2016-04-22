#ifndef STARTUPCHECK_STARTUPMIGRATION_H
#define STARTUPCHECK_STARTUPMIGRATION_H

#include <QDir>
#include <QTextStream>
#include <QSettings>
#include "../logger.h"

namespace StartupCheck {

	namespace Migration {

		static inline void migrateIfNecessary(bool verbose) {

			if(verbose) LOG << DATE << "StartupCheck::Migration" << NL;

			// If this is true, then the new config folders have been created
			bool migrated = false;

			QDir dir;

			// Check for configuration folder
			if(!QDir(CONFIG_DIR).exists()) {
				if(!dir.mkpath(CONFIG_DIR)) {
					LOG << DATE << "StartupCheck::Migration: ERROR! Unable to create configuration directory '" << CONFIG_DIR << "'" << NL;
					std::exit(1);
				} else
					migrated = true;
			}

			// Check for data folder
			if(!QDir(DATA_DIR).exists()) {
				if(!dir.mkpath(DATA_DIR)) {
					LOG << DATE << "StartupCheck::Migration: ERROR! Unable to create data directory '" << DATA_DIR << "'" << NL;
					std::exit(1);
				} else
					migrated = true;
			}

			// Check for cache folder
			if(!QDir(CACHE_DIR).exists()) {
				if(!dir.mkpath(CACHE_DIR)) {
					LOG << DATE << "StartupCheck::Migration: ERROR! Unable to create data directory '" << CACHE_DIR << "'" << NL;
					std::exit(1);
				} else
					migrated = true;
			}

			// For convenience, used repeatedly below
			QString oldpath = QDir::homePath() + "/.photoqt";

			// If new folders have been created and old files exist -> need to move
			if(migrated && QDir(oldpath).exists()) {

				// Migrate settings file
				QFile file(oldpath + "/settings");
				if(file.exists()) {

					LOG << DATE
						<< "Migrating old settings file from '" << oldpath.toStdString() << "' to '" << CONFIG_DIR << "'"
						<< NL;

					if(!file.rename(CFG_SETTINGS_FILE))

						LOG << DATE
							<< "StartupCheck::Migration: ERROR! Unable to move settings file to new location! Default settings will be used."
							<< NL;

				}

				// Migrate shortcuts file
				file.setFileName(oldpath + "/shortcuts");
				if(file.exists()) {

					LOG << DATE
						<< "Migrating old shortcuts file from '" << oldpath.toStdString() << "' to '" << CONFIG_DIR << "'"
						<< NL;

					if(!file.rename(CFG_SHORTCUTS_FILE))

						LOG << DATE
							<< "StartupCheck::Migration: ERROR! Unable to move shortcuts file to new location! Default shortcuts will be used."
							<< NL;

				}

				// Migrate contextmenu file
				file.setFileName(oldpath + "/contextmenu");
				if(file.exists()) {

					LOG << DATE
						<< "Migrating old contextmenu file from '" << oldpath.toStdString() << "' to '" << CONFIG_DIR << "'"
						<< NL;

					if(!file.rename(CFG_CONTEXTMENU_FILE))

						LOG << DATE
							<< "StartupCheck::Migration: ERROR! Unable to move contextmenu file to new location! Default entries will be set."
							<< NL;

				}

				// Migrate fileformats file
				file.setFileName(oldpath + "/fileformats.disabled");
				if(file.exists()) {

					LOG << DATE
						<< "Migrating old fileformats.disabled file from '" << oldpath.toStdString() << "' to '" << CONFIG_DIR << "'"
						<< NL;

					if(!file.rename(CFG_FILEFORMATS_FILE))

						LOG << DATE
							<< "StartupCheck::Migration: ERROR! Unable to move fileformats.disabled file to new location! Default fileformats will be set."
							<< NL;

				}

				// Migrate thumbnails file
				file.setFileName(oldpath + "/thumbnails");
				if(file.exists()) {

					LOG << DATE
						<< "Migrating old thumbnails database from '" << oldpath.toStdString() << "' to '" << CACHE_DIR << "'"
						<< NL;

					if(!file.rename(CFG_THUMBNAILS_DB))

						LOG << DATE
							<< "StartupCheck::Migration: ERROR! Unable to move thumbnails database to new location!"
							<< NL;

				}

				// Migrate file that stores window geometry between sessions
				// This file is NOT stored in the old config location, but PhotoQt
				// used to store it in ~/.local/photoqt/photoqt.conf.
				// We move it to the other config files into the CONFIG_DIR directory
				QSettings set("photoqt","photoqt");
				file.setFileName(set.fileName());
				if(file.open(QIODevice::ReadOnly)) {
					QTextStream in(&file);
					QString all = in.readAll();
					file.close();
					if(all.trimmed() != "") {
						if(!file.rename(CFG_MAINWINDOW_GEOMETRY_FILE))

							LOG << DATE
								<< "StartupCheck::Migration: ERROR! Unable to move mainwindow geometry file to new location!"
								<< NL;
						else
							file.remove();

					}
				}
				file.setFileName(set.fileName());
				// And make sure to remove file again at end
				QDir dir;
				dir.rmdir(QFileInfo(file).absolutePath());


				// If old config dir is empty now (it should be), then remove it
				dir.setPath(oldpath);
				if(dir.entryList(QDir::NoDotAndDotDot).length() == 0) {
					if(!dir.rmdir(oldpath))
						LOG << DATE
							<< "StartupCheck::Migration: ERROR! Unable to remove old config folder '" << oldpath.toStdString() << "'"
							<< NL;
				} else {
					LOG << DATE
						<< "StartupCheck::Migration: Unable to remove old config folder '" << oldpath.toStdString() << "', not empty!"
						<< NL;
				}

			}

		}

	}

}

#endif // STARTUPCHECK_STARTUPMIGRATION_H
