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
#include "configfiles.h"

class Logger {

public:
    Logger() {
#ifdef PHOTOQTDEBUG
        logFile.setFileName(QDir::tempPath() + "/photoqt.log");
#endif
    }

    template <class T>
    Logger &operator<<(const T &v) {

        std::stringstream str;
        str << v;

        if(str.str() == "[[[DATE]]]")
            std::clog << "[" << QDateTime::currentDateTime().toString("dd/MM/yyyy HH:mm:ss:zzz").toStdString() << "] ";
        else
            std::clog << v;

#ifdef PHOTOQTDEBUG
        QTextStream out(&logFile);
        logFile.open(QIODevice::WriteOnly | QIODevice::Append);
        if(str.str() == "[[[DATE]]]")
            out << "[" << QDateTime::currentDateTime().toString("dd/MM/yyyy HH:mm:ss:zzz") << "] ";
        else
            out << QString::fromStdString(str.str());

        logFile.close();
#endif

        return *this;

    }

    Logger &operator<<(std::ostream&(*f)(std::ostream&)) {
        std::clog << f;
        return *this;
    }

private:
#ifdef PHOTOQTDEBUG
    QFile logFile;
#endif

};

#define LOG Logger()
const std::string CURDATE = "[[[DATE]]]";
const std::string NL = "\n";

#endif // LOGGER_H
