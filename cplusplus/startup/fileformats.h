#ifndef STARTUPCHECK_STARTUPFILEFORMATS_H
#define STARTUPCHECK_STARTUPFILEFORMATS_H

#include <QDir>
#include <QFile>
#include <QTextStream>
#include "../logger.h"
#include "../settings/fileformats.h"

namespace StartupCheck {

	namespace FileFormats {

		static inline void checkForDefaultSettingsFileAndReturnWhetherDefaultsAreToBeSet(bool verbose) {

			if(verbose) LOG << CURDATE << "StartupCheck::FileFormats" << NL;

			// At this point, we only check if the file exists. If it doesn't, then the return value 'true'
			// is passed on to the MainWindow class later-on for setting the default fileformats

			QFile fileformatsFile(QString(CFG_FILEFORMATS_FILE));
			if(!fileformatsFile.exists()) {
				::FileFormats formats(false,true);
				formats.setDefaultFormats();
				formats.saveFormats();
			}

		}

	}

}

#endif // STARTUPCHECK_STARTUPFILEFORMATS_H
