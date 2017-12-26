/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#ifndef STARTUPCHECK_STARTUPMIGRATION_H
#define STARTUPCHECK_STARTUPMIGRATION_H

#include <QDir>
#include <QTextStream>
#include <QSettings>
#include "../logger.h"

namespace StartupCheck {

    namespace Migration {

        static inline void migrateIfNecessary(bool verbose) {

            if(verbose) LOG << CURDATE << "StartupCheck::Migration" << NL;

            // If this is true, then the new config folders have been created
            bool migrated = false;

            QDir dir;

            // Check for configuration folder
            if(!QDir(ConfigFiles::CONFIG_DIR()).exists()) {
                if(!dir.mkpath(ConfigFiles::CONFIG_DIR())) {
                    LOG << CURDATE << "StartupCheck::Migration: ERROR! Unable to create configuration directory '"
                        << ConfigFiles::CONFIG_DIR().toStdString() << "'" << NL;
                    std::exit(1);
                } else
                    migrated = true;
            }

            // Check for data folder
            if(!QDir(ConfigFiles::DATA_DIR()).exists()) {
                if(!dir.mkpath(ConfigFiles::DATA_DIR())) {
                    LOG << CURDATE << "StartupCheck::Migration: ERROR! Unable to create data directory '"
                        << ConfigFiles::DATA_DIR().toStdString() << "'" << NL;
                    std::exit(1);
                } else
                    migrated = true;
            }

            // Check for cache folder
            if(!QDir(ConfigFiles::CACHE_DIR()).exists()) {
                if(!dir.mkpath(ConfigFiles::CACHE_DIR())) {
                    LOG << CURDATE << "StartupCheck::Migration: ERROR! Unable to create data directory '"
                        << ConfigFiles::CACHE_DIR().toStdString() << "'" << NL;
                    std::exit(1);
                } else
                    migrated = true;
            }

            // Old config paths
            QStringList oldpaths;
            oldpaths << QDir::homePath() + "/.photoqt";
            // on Windows, the location has changed to the proper location (again)
#ifdef Q_OS_WIN
            oldpaths << QDir::homePath() + "/.local/share/PhotoQt";
            oldpaths << QDir::homePath() + "/.cache/PhotoQt";
            oldpaths << QDir::homePath() + "/.config/PhotoQt";
#endif

            foreach(QString oldpath, oldpaths) {

                // If new folders have been created and old files exist -> need to move
                if(migrated && QDir(oldpath).exists()) {

                    // Migrate settings file
                    QFile file(oldpath + "/settings");
                    if(file.exists()) {

                        LOG << CURDATE
                            << "Migrating old settings file from '" << oldpath.toStdString() << "' to '"
                            << ConfigFiles::CONFIG_DIR().toStdString() << "'"
                            << NL;

                        if(!file.rename(ConfigFiles::SETTINGS_FILE()))

                            LOG << CURDATE
                                << "StartupCheck::Migration: ERROR! Unable to move settings file to new location! Default settings will be used."
                                << NL;

                    }

                    // Migrate shortcuts file
                    file.setFileName(oldpath + "/shortcuts");
                    if(file.exists()) {

                        LOG << CURDATE
                            << "Migrating old shortcuts file from '" << oldpath.toStdString() << "' to '"
                            << ConfigFiles::CONFIG_DIR().toStdString() << "'"
                            << NL;

                        if(!file.rename(ConfigFiles::SHORTCUTS_FILE()))

                            LOG << CURDATE
                                << "StartupCheck::Migration: ERROR! Unable to move shortcuts file to new location! Default shortcuts will be used."
                                << NL;

                    }

                    // Migrate contextmenu file
                    file.setFileName(oldpath + "/contextmenu");
                    if(file.exists()) {

                        LOG << CURDATE
                            << "Migrating old contextmenu file from '" << oldpath.toStdString() << "' to '"
                            << ConfigFiles::CONFIG_DIR().toStdString() << "'"
                            << NL;

                        if(!file.rename(ConfigFiles::CONTEXTMENU_FILE()))

                            LOG << CURDATE
                                << "StartupCheck::Migration: ERROR! Unable to move contextmenu file to new location! Default entries will be set."
                                << NL;

                    }

                    // Migrate fileformats file
                    file.setFileName(oldpath + "/fileformats.disabled");
                    if(file.exists()) {

                        LOG << CURDATE
                            << "Migrating old fileformats.disabled file from '" << oldpath.toStdString() << "' to '"
                            << ConfigFiles::CONFIG_DIR().toStdString() << "'"
                            << NL;

                        if(!file.rename(ConfigFiles::FILEFORMATS_FILE()))

                            LOG << CURDATE
                                << "StartupCheck::Migration: ERROR! Unable to move fileformats.disabled file to new location! Default fileformats will be set."
                                << NL;

                    }

                    // Migrate thumbnails file
                    file.setFileName(oldpath + "/thumbnails");
                    if(file.exists()) {

                        LOG << CURDATE
                            << "Migrating old thumbnails database from '" << oldpath.toStdString() << "' to '"
                            << ConfigFiles::CACHE_DIR().toStdString() << "'"
                            << NL;

                        if(!file.rename(ConfigFiles::THUMBNAILS_DB()))

                            LOG << CURDATE
                                << "StartupCheck::Migration: ERROR! Unable to move thumbnails database to new location!"
                                << NL;

                    }

                    // If old config dir is empty now (it should be), then remove it
                    dir.setPath(oldpath);
                    if(dir.entryList(QDir::NoDotAndDotDot).length() == 0) {
                        if(!dir.rmdir(oldpath))
                            LOG << CURDATE
                                << "StartupCheck::Migration: ERROR! Unable to remove old config folder '" << oldpath.toStdString() << "'"
                                << NL;
                    } else {
                        LOG << CURDATE
                            << "StartupCheck::Migration: Unable to remove old config folder '" << oldpath.toStdString() << "', not empty!"
                            << NL;
                    }

                }

            }

        }

    }

}

#endif // STARTUPCHECK_STARTUPMIGRATION_H
