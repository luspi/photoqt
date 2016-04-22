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

			if(verbose) LOG << DATE << "StartupCheck::UpdateCheck|" << NL;

			QString version = VERSION;

			if(*settingsText == "") {
				if(verbose) LOG << DATE << "PhotoQt newly installed! Creating empty settings file" << NL;
				*settingsText = "Version=" + version + "\n";
				Settings set(true);
				set.saveSettings();
				QFile file(CFG_SETTINGS_FILE);
				if(file.open(QIODevice::ReadOnly)) {
					QTextStream in(&file);
					*settingsText = in.readAll();
					file.close();
				}
				return 2;
			}

			if(verbose) LOG << DATE << "Checking if first run of new version" << NL;

			// If it doesn't contain current version (some previous version)
			if(!settingsText->contains("Version=" + version)) {

				if(verbose) LOG << DATE << "PhotoQt updated" << NL;

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
