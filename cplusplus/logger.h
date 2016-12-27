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

#ifndef LOGGER_H
#define LOGGER_H

#include <iostream>
#include <sstream>
#include <QDateTime>
#include <QDir>
#include <QTextStream>


const QString CONFIG_DIR = QString("%1/.config/PhotoQt/").arg(QDir::homePath());
const QString DATA_DIR = QString("%1/.local/share/PhotoQt/").arg(QDir::homePath());
const QString CACHE_DIR = QString("%1/.cache/PhotoQt/").arg(QDir::homePath());
const QString CFG_SETTINGS_FILE = QString("%1/settings").arg(CONFIG_DIR);
const QString CFG_CONTEXTMENU_FILE = QString("%1/contextmenu").arg(CONFIG_DIR);
const QString CFG_FILEFORMATS_FILE = QString("%1/fileformats.disabled").arg(CONFIG_DIR);
const QString CFG_KEY_SHORTCUTS_FILE = QString("%1/shortcuts").arg(CONFIG_DIR);
const QString CFG_TOUCH_SHORTCUTS_FILE = QString("%1/touchshortcuts").arg(CONFIG_DIR);
const QString CFG_MOUSE_SHORTCUTS_FILE = QString("%1/mouseshortcuts").arg(CONFIG_DIR);
const QString CFG_SHORTCUTSNOTIFIER_FILE = QString("%1/shortcutsnotifier").arg(CONFIG_DIR);
const QString CFG_THUMBNAILS_DB = QString("%1/thumbnails").arg(CACHE_DIR);
const QString CFG_SETTINGS_SESSION_FILE = QString("%1/settings_session").arg(CACHE_DIR);
const QString CFG_MAINWINDOW_GEOMETRY_FILE = QString("%1/geometry").arg(CONFIG_DIR);
const QString CFG_OPENFILE_LAST_LOCATION = QString("%1/openfilelastlocation").arg(CACHE_DIR);


class Logger {

public:
	Logger() {
		if(QFile(CONFIG_DIR + QString("/verboselog")).exists()) {
			logFile.setFileName(QDir::tempPath() + "/photoqt.log");
			writeToFile = true;
		} else
			writeToFile = false;
	}

	template <class T>

	Logger &operator<<(const T &v) {

		std::stringstream str;
		str << v;

		if(str.str() == "[[[DATE]]]")
			std::clog << "[" << QDateTime::currentDateTime().toString("dd/MM/yyyy HH:mm:ss:zzz").toStdString() << "] ";
		else
			std::clog << v;

		if(writeToFile) {

			QTextStream out(&logFile);
			logFile.open(QIODevice::WriteOnly | QIODevice::Append);
			if(str.str() == "[[[DATE]]]")
				out << "[" << QDateTime::currentDateTime().toString("dd/MM/yyyy HH:mm:ss:zzz") << "] ";
			else
				out << QString::fromStdString(str.str());

			logFile.close();
		}

		return *this;

	}

	Logger &operator<<(std::ostream&(*f)(std::ostream&)) {
		std::clog << f;
		return *this;
	}

private:
	QFile logFile;
	bool writeToFile;

};

#define LOG Logger()
const std::string CURDATE = "[[[DATE]]]";
const std::string NL = "\n";

#endif // LOGGER_H
