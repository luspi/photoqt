#ifndef STARTUPFILEFORMATS_H
#define STARTUPFILEFORMATS_H

#include <QDir>
#include <QFile>
#include <QTextStream>
#include "../logger.h"

namespace StartupCheck {

	namespace FileFormats {

		static inline bool checkForDefaultSettingsFileAndReturnWhetherDefaultsAreToBeSet(bool verbose) {

			if(verbose) LOG << DATE << "StartupCheck::FileFormats" << std::endl;

			// At this point, we only check if the file exists. If it doesn't, then the return value 'true'
			// is passed on to the MainWindow class later-on for setting the default fileformats

			QFile fileformatsFile(QDir::homePath() + "/.photoqt/fileformats.disabled");
			if(!fileformatsFile.exists())
				return true;

			return false;

		}

	}

}

#endif // STARTUPFILEFORMATS_H
