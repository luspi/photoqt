#ifndef STARTUPCHECK_STARTUPLOCALISATION_H
#define STARTUPCHECK_STARTUPLOCALISATION_H

#include <QTranslator>
#include <QFile>
#include <QDir>
#include <QApplication>
#include <QTextStream>
#include "../logger.h"

class SingleInstance;

namespace StartupCheck {

	namespace Localisation {

		static inline void loadTranslation(bool verbose, QString *settingsText, QTranslator *trans) {

			if(verbose) LOG << DATE << "StartupCheck::Localisation" << std::endl;

			// We use two strings, since the system locale usually is of the form e.g. "de_DE"
			// and some translations only come with the first part, i.e. "de",
			// and some with the full string. We need to be able to find both!
			if(verbose) LOG << DATE << "Checking for translation" << std::endl;
			QString code1 = "";
			QString code2 = "";
			bool noLanguageWasSet = false;
			if(settingsText->contains("Language=") && !settingsText->contains("Language=en") && !settingsText->contains("Language=\n")) {
				code1 = settingsText->split("Language=").at(1).split("\n").at(0).trimmed();
				code2 = code1;
			} else if(!settingsText->contains("Language=en")) {
				code1 = QLocale::system().name();
				code2 = QLocale::system().name().split("_").at(0);
			}
			if(verbose) LOG << DATE << "Found following language: " << code1.toStdString()  << "/" << code2.toStdString() << std::endl;
			if(QFile(":/photoqt_" + code1 + ".qm").exists()) {
				LOG << DATE << "Loading Translation:" << code1.toStdString() << std::endl;
				trans->load(":/photoqt_" + code1);
				qApp->installTranslator(trans);
				code2 = code1;
				noLanguageWasSet = true;
			} else if(QFile(":/photoqt_" + code2 + ".qm").exists()) {
				LOG << DATE << "Loading Translation:" << code2.toStdString() << std::endl;
				trans->load(":/photoqt_" + code2);
				qApp->installTranslator(trans);
				code1 = code2;
				noLanguageWasSet = true;
			}
			// Store translation in settings file
			if(noLanguageWasSet) {
				if(settingsText->contains("Language=\n"))
					*settingsText = settingsText->replace("Language=\n",QString("Language=%1\n").arg(code1));
				else if(!settingsText->contains(QString("\nLanguage=%1").arg(code1)))
					*settingsText += QString("\nLanguage=%1").arg(code1);
			}
		}

	}

}

#endif // STARTUPCHECK_STARTUPLOCALISATION_H
