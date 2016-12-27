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

			if(verbose) LOG << CURDATE << "StartupCheck::Localisation" << NL;

			// We use two strings, since the system locale usually is of the form e.g. "de_DE"
			// and some translations only come with the first part, i.e. "de",
			// and some with the full string. We need to be able to find both!
			if(verbose) LOG << CURDATE << "Checking for translation" << NL;
			QString code1 = "";
			QString code2 = "";
			bool noLanguageWasSet = false;
			if(settingsText->contains("Language=") && !settingsText->contains("Language=\n")) {
				code1 = settingsText->split("Language=").at(1).split("\n").at(0).trimmed();
				code2 = code1;
			} else {
				code1 = QLocale::system().name();
				code2 = QLocale::system().name().split("_").at(0);
			}
			if(verbose) LOG << CURDATE << "Found following language: " << code1.toStdString()  << "/" << code2.toStdString() << NL;
			if(QFile(":/photoqt_" + code1 + ".qm").exists()) {
				LOG << CURDATE << "Loading Translation:" << code1.toStdString() << NL;
				trans->load(":/photoqt_" + code1);
				qApp->installTranslator(trans);
				code2 = code1;
				noLanguageWasSet = true;
			} else if(QFile(":/photoqt_" + code2 + ".qm").exists()) {
				LOG << CURDATE << "Loading Translation:" << code2.toStdString() << NL;
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
