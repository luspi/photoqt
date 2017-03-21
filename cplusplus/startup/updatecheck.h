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
        static inline int checkForUpdateInstall(bool verbose, QString *settingsText) {

            if(verbose) LOG << CURDATE << "StartupCheck::UpdateCheck|" << NL;

            QString version = VERSION;

            if(*settingsText == "") {
                if(verbose) LOG << CURDATE << "PhotoQt newly installed! Creating empty settings file" << NL;
                *settingsText = "Version=" + version + "\n";
                Settings set(true);
                set.saveSettings();
                QFile file(ConfigFiles::SETTINGS_FILE());
                if(file.open(QIODevice::ReadOnly)) {
                    QTextStream in(&file);
                    *settingsText = in.readAll();
                    file.close();
                }
                return 2;
            }

            if(verbose) LOG << CURDATE << "Checking if first run of new version" << NL;

            // If it doesn't contain current version (some previous version)
            if(!settingsText->contains("Version=" + version)) {

                if(verbose) LOG << CURDATE << "PhotoQt updated" << NL;

                if(!settingsText->contains("Version=")) {
                    *settingsText = "Version=" + version + "\n" + *settingsText;
                    return 1;
                }

                QStringList splitAtVersion = settingsText->split("Version=");
                QStringList splitAfterVersion = splitAtVersion.at(1).split("\n");
                splitAfterVersion.removeFirst();

                QString newtext = "Version=" + version + "\n";
                newtext += splitAtVersion.at(0);
                newtext += splitAfterVersion.join("\n");

                *settingsText = newtext;

                return 1;

            }

            return 0;

        }

    }

}

#endif // STARTUPCHECK_STARTUPUPDATECHECK_H
