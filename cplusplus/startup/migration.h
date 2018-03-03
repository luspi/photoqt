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

#ifndef STARTUPCHECK_STARTUPMIGRATION_H
#define STARTUPCHECK_STARTUPMIGRATION_H

#include "../logger.h"

namespace StartupCheck {

    namespace Migration {

        static inline void migrateIfNecessary() {

            if(qgetenv("PHOTOQT_DEBUG") == "yes") LOG << CURDATE << "StartupCheck::Migration" << NL;

            QFile oldfile(QString("%1/fileformats.disabled").arg(ConfigFiles::CONFIG_DIR()));

            QFileInfo fileinfo_qt(ConfigFiles::FILEFORMATSQT_FILE());
            QFileInfo fileinfo_kde(ConfigFiles::FILEFORMATSKDE_FILE());
            QFileInfo fileinfo_gm(ConfigFiles::FILEFORMATSGM_FILE());
            QFileInfo fileinfo_gmghostscript(ConfigFiles::FILEFORMATSGMGHOSTSCRIPT_FILE());
            QFileInfo fileinfo_extras(ConfigFiles::FILEFORMATSEXTRAS_FILE());
            QFileInfo fileinfo_untested(ConfigFiles::FILEFORMATSUNTESTED_FILE());
            QFileInfo fileinfo_raw(ConfigFiles::FILEFORMATSRAW_FILE());

            if(fileinfo_qt.exists() || fileinfo_kde.exists() || fileinfo_gm.exists() || fileinfo_gmghostscript.exists() ||
               fileinfo_extras.exists() || fileinfo_untested.exists() || fileinfo_raw.exists()) {
                if(oldfile.exists()) {
                    if(!oldfile.remove())
                        LOG << CURDATE << "StartupCheck::Migration::migrateIfNecessary() ERROR: Unable to remove old file with list of disabled fileformats" << NL;
                } else
                    return;
            }

            if(!oldfile.open(QIODevice::ReadOnly)) {
                LOG << CURDATE << "StartupCheck::Migration::migrateIfNecessary() ERROR: Unable to open old file with list of disabled fileformats for reading..." << NL;
                return;
            }

            if(!oldfile.copy(ConfigFiles::FILEFORMATSQT_FILE()))
                LOG << CURDATE << "StartupCheck::Migration::migrateIfNecessary() ERROR: Unable to copy file with list of disabled fileformats to qt list" << NL;
            // We don't copy it to the KDE file here, as we want them all to be enabled (as they all work) if the required plugins are installed
            if(!oldfile.copy(ConfigFiles::FILEFORMATSGM_FILE()))
                LOG << CURDATE << "StartupCheck::Migration::migrateIfNecessary() ERROR: Unable to copy file with list of disabled fileformats to gm list" << NL;
            if(!oldfile.copy(ConfigFiles::FILEFORMATSGMGHOSTSCRIPT_FILE()))
                LOG << CURDATE << "StartupCheck::Migration::migrateIfNecessary() ERROR: Unable to copy file with list of disabled fileformats to gmg list" << NL;
            if(!oldfile.copy(ConfigFiles::FILEFORMATSEXTRAS_FILE()))
                LOG << CURDATE << "StartupCheck::Migration::migrateIfNecessary() ERROR: Unable to copy file with list of disabled fileformats to extras list" << NL;
            if(!oldfile.copy(ConfigFiles::FILEFORMATSRAW_FILE()))
                LOG << CURDATE << "StartupCheck::Migration::migrateIfNecessary() ERROR: Unable to copy file with list of disabled fileformats to raw list" << NL;
            if(!oldfile.copy(ConfigFiles::FILEFORMATSDEVIL_FILE()))
                LOG << CURDATE << "StartupCheck::Migration::migrateIfNecessary() ERROR: Unable to copy file with list of disabled fileformats to devil list" << NL;

            // just make sure the kde file exists (empty)
            QFile filekde(ConfigFiles::FILEFORMATSKDE_FILE());
            filekde.open(QIODevice::ReadWrite);
            filekde.close();

            if(!oldfile.remove())
                LOG << CURDATE << "StartupCheck::Migration::migrateIfNecessary() ERROR: Unable to remove old file with list of disabled fileformats" << NL;


        }

    }

}

#endif // STARTUPCHECK_STARTUPMIGRATION_H
