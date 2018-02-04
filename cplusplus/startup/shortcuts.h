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
#include "../shortcuts/shortcuts.h"

namespace StartupCheck {

    namespace Shortcuts {

        static inline void setDefaultShortcutsIfShortcutFileDoesntExist() {

            if(qgetenv("PHOTOQT_DEBUG") == "yes") LOG << CURDATE << "StartupCheck::Shortcuts - setDefaultShortcutsIfShortcutFileDoesntExist()" << NL;

            // All shortcuts are stored in this single file
            QFileInfo allshortcuts(ConfigFiles::SHORTCUTS_FILE());

            // If file doesn't exist (i.e., on first start)
            if(!allshortcuts.exists()) {

                // Get handler to shortcuts object (the :: are needed as the current namespace is also called Shortcuts)
                ::Shortcuts sh;

                // Load and save default shortcuts
                sh.saveShortcuts(sh.loadDefaults());

            }

        }

        static inline void combineKeyMouseShortcutsSingleFile() {

            if(qgetenv("PHOTOQT_DEBUG") == "yes") LOG << CURDATE << "StartupCheck::Shortcuts - combineKeyMouseShortcutsSingleFile()" << NL;

            // All shortcuts are stored in this single file
            QFile allshortcuts(ConfigFiles::SHORTCUTS_FILE());

            // Potential mouse shortcuts from previous versions
            QFile mouseshortcuts(QString("%1/mouseshortcuts").arg(ConfigFiles::CONFIG_DIR()));

            // If mouse shortcuts exist in the wrong place, migrate!
            if(mouseshortcuts.exists()) {

                // Open for reading only
                if(!mouseshortcuts.open(QIODevice::ReadOnly)) {
                    LOG << CURDATE << "StartupCheck::Shortcuts::combineKeyMouseShortcutsSingleFile() - ERROR: unable to open mouseshortcuts for reading..." << NL;
                    return;
                }

                // Open for appending only
                if(!allshortcuts.open(QIODevice::WriteOnly|QIODevice::Append)) {
                    LOG << CURDATE << "StartupCheck::Shortcuts::combineKeyMouseShortcutsSingleFile() - ERROR: unable to open shortcuts for writing..." << NL;
                    return;
                }

                // stream to both files
                QTextStream in(&mouseshortcuts);
                QTextStream out(&allshortcuts);

                // Add a linebreak, just to be save, before adding the mouse shortcuts to allshortcuts file
                out << "\n" << in.readAll();

                // close both files
                mouseshortcuts.close();
                allshortcuts.close();

                // and remove old mouse shortcuts file (not needed anymore)
                if(!mouseshortcuts.remove())
                    LOG << CURDATE << "StartupCheck::Shortcuts::combineKeyMouseShortcutsSingleFile() - ERROR: Unable to remove redundant mouse_shortcuts file!" << NL;

            }

        }

    }

}

#endif // STARTUPCHECK_SHORTCUTS_H
