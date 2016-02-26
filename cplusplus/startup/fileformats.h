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

			// We moved from old way of handling image formats to new way
			// We can't do it before here, since we need access to global settings
			QFile fileformatsFile(QDir::homePath() + "/.photoqt/fileformats.disabled");

			if(!fileformatsFile.exists()) {

				// File content of disabled fileformats
				QString fileformatsDisabled = "*.epi\n";
				fileformatsDisabled += "*.epsi\n";
				fileformatsDisabled += "*.eps\n";
				fileformatsDisabled += "*.epsf\n";
				fileformatsDisabled += "*.eps2\n";
				fileformatsDisabled += "*.eps3\n";
				fileformatsDisabled += "*.ept\n";
				fileformatsDisabled += "*.pdf\n";
				fileformatsDisabled += "*.ps\n";
				fileformatsDisabled += "*.ps2\n";
				fileformatsDisabled += "*.ps3\n";
				fileformatsDisabled += "*.hp\n";
				fileformatsDisabled += "*.hpgl\n";
				fileformatsDisabled += "*.jbig\n";
				fileformatsDisabled += "*.jbg\n";
				fileformatsDisabled += "*.pwp\n";
				fileformatsDisabled += "*.rast\n";
				fileformatsDisabled += "*.rla\n";
				fileformatsDisabled += "*.rle\n";
				fileformatsDisabled += "*.sct\n";
				fileformatsDisabled += "*.tim\n";
				fileformatsDisabled += "**.psb\n";
				fileformatsDisabled += "**.psd\n";
				fileformatsDisabled += "**.xcf\n";

				// Write 'disabled filetypes' file
				if(fileformatsFile.open(QIODevice::WriteOnly)) {
					QTextStream out(&fileformatsFile);
					out << fileformatsDisabled;
					fileformatsFile.close();
				} else
					LOG << DATE << "ERROR: Can't write default disabled fileformats file" << std::endl;

				return true;

			}

			return false;

		}

	}

}

#endif // STARTUPFILEFORMATS_H
