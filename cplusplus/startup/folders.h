/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
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

#ifndef PQSTARTUP_FOLDERS_H
#define PQSTARTUP_FOLDERS_H

#include "../logger.h"

namespace PQStartup {

    namespace Folders {

        static void ensureConfigDataFoldersExist() {

            QDir dir(ConfigFiles::CONFIG_DIR());
            if(!dir.exists())
                dir.mkpath(ConfigFiles::CONFIG_DIR());

            dir.setCurrent(ConfigFiles::GENERIC_DATA_DIR());
            if(!dir.exists())
                dir.mkpath(ConfigFiles::GENERIC_DATA_DIR());

            dir.setCurrent(ConfigFiles::GENERIC_CACHE_DIR());
            if(!dir.exists())
                dir.mkpath(ConfigFiles::GENERIC_CACHE_DIR());

        }

    }

}

#endif // PQSTARTUP_FOLDERS_H
