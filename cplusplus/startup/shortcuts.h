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

#include <QDir>
#include <QFileInfo>
#include "../logger.h"
#include "../scripts/getanddostuff/shortcuts.h"

namespace StartupCheck {

	namespace Shortcuts {

		static inline void makeSureShortcutsFileExists(bool verbose) {

			if(verbose) LOG << CURDATE << "StartupCheck::Shortcuts::makeSureShortcutsFileExists" << NL;

			QFileInfo file(CFG_KEY_SHORTCUTS_FILE);
			if(!file.exists()) {
				GetAndDoStuffShortcuts sh(true);
				sh.saveShortcuts(sh.getDefaultKeyShortcuts());
			}

		}

		static inline void migrateMouseShortcuts(bool verbose) {

			if(verbose) LOG << CURDATE << "StartupCheck::Shortcuts::migrateMouseShortcuts" << NL;

			QFile mousefile(CFG_MOUSE_SHORTCUTS_FILE);
			QFile keyfile(CFG_KEY_SHORTCUTS_FILE);

			if(!mousefile.exists()) {

				if(mousefile.open(QIODevice::WriteOnly)) {

					if(keyfile.open(QIODevice::ReadOnly)) {

						QTextStream keyin(&keyfile);
						QTextStream mouseout(&mousefile);

						QString newKeyFileContent = "";
						QString newMouseFileContent = QString("Version=%1\n").arg(VERSION);

						QStringList allKeys = keyin.readAll().split("\n");
						foreach(QString k, allKeys) {
							if(k.contains("::[M]"))
								newMouseFileContent += k.replace("[M] ","") + "\n";
							else
								newKeyFileContent += k + "\n";
						}

						mouseout << newMouseFileContent;

						keyfile.close();
						keyfile.open(QIODevice::WriteOnly);
						QTextStream keyout(&keyfile);
						keyout << newKeyFileContent;
						keyfile.close();

					} else
						LOG << CURDATE << "StartupCheck::Shortcuts - ERROR: Unable to open key shortcuts file" << NL;

					mousefile.close();

				} else
					LOG << CURDATE << "StartupCheck::Shortcuts - ERROR: Unable to open mouse shortcuts file" << NL;

			}

		}

	}

}

#endif // STARTUPCHECK_SHORTCUTS_H
