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

        static void migrateIfNecessary() {

            if(qgetenv("PHOTOQT_DEBUG") == "yes") LOG << CURDATE << "StartupCheck::Migration" << NL;

            QFile oldDisabledImageFormats(QString("%1/fileformats.disabled").arg(ConfigFiles::CONFIG_DIR()));
            if(oldDisabledImageFormats.exists()) {

                if(oldDisabledImageFormats.remove())
                    LOG << CURDATE << "StartupCheck::Migration: old file with disabled image formats removed" << NL;
                else
                    LOG << CURDATE << "StartupCheck::Migration: old file with disabled image formats could not be removed" << NL;

            }

        }

    }

}

#endif // STARTUPCHECK_STARTUPMIGRATION_H
