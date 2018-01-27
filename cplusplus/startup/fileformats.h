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

#ifndef STARTUPCHECK_STARTUPFILEFORMATS_H
#define STARTUPCHECK_STARTUPFILEFORMATS_H

#include <QDir>
#include <QFile>
#include <QTextStream>
#include "../logger.h"
#include "../settings/fileformats.h"

namespace StartupCheck {

    namespace FileFormats {

        static inline void checkForDefaultSettingsFileAndReturnWhetherDefaultsAreToBeSet() {

            if(qgetenv("PHOTOQT_DEBUG") == "yes") LOG << CURDATE << "StartupCheck::FileFormats" << NL;

            // At this point, we only check if the file exists. If it doesn't, then the return value 'true'
            // is passed on to the MainWindow class later-on for setting the default fileformats

            QFile fileformatsFile(ConfigFiles::FILEFORMATS_FILE());
            if(!fileformatsFile.exists()) {
                ::FileFormats formats(true);
                formats.setDefaultFormats();
                formats.saveFormats();
            }

        }

    }

}

#endif // STARTUPCHECK_STARTUPFILEFORMATS_H
