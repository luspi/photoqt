#ifndef STARTUPCHECK_SHORTCUTS_H
#define STARTUPCHECK_SHORTCUTS_H

#include <QDir>
#include <QFileInfo>
#include "../logger.h"
#include "../scripts/getanddostuff/shortcuts.h"

namespace StartupCheck {

	namespace Shortcuts {

		static inline void makeSureShortcutsFileExists(bool verbose) {

			if(verbose) LOG << DATE << "StartupCheck::Shortcuts" << NL;

			QFileInfo file(CFG_SHORTCUTS_FILE);
			if(!file.exists()) {
				GetAndDoStuffShortcuts sh(true);
				sh.saveShortcuts(sh.getDefaultShortcuts());
			}

		}

	}

}

#endif // STARTUPCHECK_SHORTCUTS_H
