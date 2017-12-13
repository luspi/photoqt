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

#ifndef STARTUPCHECK_STARTUPUPDATECHECK_H
#define STARTUPCHECK_STARTUPUPDATECHECK_H

#include <QString>
#include <QFile>
#include <QTextStream>
#include "../logger.h"
#include "../settings/settings.h"

namespace StartupCheck {

    namespace UpdateCheck {

        // 0 = nothing, 1 = update, 2 = install
        static inline int checkForUpdateInstall(bool verbose, Settings *settings) {

            if(verbose) LOG << CURDATE << "StartupCheck::UpdateCheck" << NL;

            if(settings->versionInTextFile == "") {
                if(verbose) LOG << CURDATE << "PhotoQt newly installed!" << NL;
                return 2;
            }

            if(verbose) LOG << CURDATE << "Checking if first run of new version" << NL;

            // If it doesn't contain current version (some previous version)
            if(settings->version != settings->versionInTextFile) {

                if(verbose) LOG << CURDATE << "PhotoQt updated" << NL;

                return 1;

            }

            return 0;

        }

    }

}

#endif // STARTUPCHECK_STARTUPUPDATECHECK_H
