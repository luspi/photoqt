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

#ifndef STARTUPCHECK_SHORTCUTS_H
#define STARTUPCHECK_SHORTCUTS_H

#include "../configfiles.h"
#include "../logger.h"
#include "../settings/settings.h"

namespace StartupCheck {

    namespace Shortcuts {

        static inline void combineKeyMouseShortcutsSingleFile(bool verbose) {

            if(verbose) LOG << CURDATE << "StartupCheck::StartInTray" << NL;

            QFile allshortcuts(ConfigFiles::SHORTCUTS_FILE());

            QFile mouseshortcuts(QString("%1/mouseshortcuts").arg(ConfigFiles::CONFIG_DIR()));

            if(mouseshortcuts.exists()) {

                if(!mouseshortcuts.open(QIODevice::ReadOnly)) {
                    LOG << CURDATE << "StartupCheck::Shortcuts::combineKeyMouseShortcutsSingleFile() unable to open mouseshortcuts for reading..." << NL;
                    return;
                }

                if(!allshortcuts.open(QIODevice::WriteOnly|QIODevice::Append)) {
                    LOG << CURDATE << "StartupCheck::Shortcuts::combineKeyMouseShortcutsSingleFile() unable to open shortcuts for writing..." << NL;
                    return;
                }

                QTextStream in(&mouseshortcuts);
                QTextStream out(&allshortcuts);

                out << "\n" << in.readAll();

                mouseshortcuts.close();
                allshortcuts.close();

                if(!mouseshortcuts.remove())
                    LOG << CURDATE << "ERROR: Unable to remove redundant mouse_shortcuts file!" << NL;

            }

        }

    }

}

#endif // STARTUPCHECK_SHORTCUTS_H
