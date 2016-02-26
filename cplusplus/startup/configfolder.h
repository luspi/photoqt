#ifndef CONFIGFOLDER_H
#define CONFIGFOLDER_H

#include <QDir>
#include "../logger.h"

namespace StartupCheck {

	namespace ConfigFolder {

		static inline void ensureItExists(bool verbose) {

			if(verbose) LOG << DATE << "StartupCheck::ConfigFolder" << std::endl;

			// Ensure that the config folder exists
			QDir dir(QDir::homePath() + "/.photoqt");

			if(!dir.exists()) {
				if(verbose) LOG << DATE << "Creating " << QDir::homePath().toStdString() << "/.photoqt" << std::endl;
				dir.mkdir(QDir::homePath() + "/.photoqt");
			}

		}

	}

}

#endif // CONFIGFOLDER_H
