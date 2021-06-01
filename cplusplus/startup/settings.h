/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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

#ifndef PQSTARTUP_SETTINGS_H
#define PQSTARTUP_SETTINGS_H

#include <QFile>
#include "../configfiles.h"
#include "../logger.h"

namespace PQStartup {

    namespace Settings {

        static void updateNameChanges() {

            QFile settingsfile(ConfigFiles::SETTINGS_FILE());
            if(settingsfile.exists() && settingsfile.open(QIODevice::ReadWrite)) {

                QTextStream in(&settingsfile);
                QString txt = in.readAll();

                txt = txt.replace("QuickInfo", "Labels");

                QTextStream out(&settingsfile);
                out << txt;
                settingsfile.close();

            }

        }

    }

}

#endif // PQSTARTUP_SETTINGS_H
