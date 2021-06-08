/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

#ifndef PQLOG_H
#define PQLOG_H

#include <iostream>
#include <sstream>
#include <QObject>
#include <QFile>
#include <QDir>
#include <QDateTime>
#include <QTextStream>
#include "configfiles.h"

/***************************************************************/
// LOGGER

class PQLog : public QObject {

    Q_OBJECT

public:
    static PQLog& get() {
        static PQLog instance;
        return instance;
    }

    PQLog(PQLog const&)          = delete;
    void operator=(PQLog const&) = delete;

    template <class T>
    PQLog &operator<<(const T &v) {

        std::stringstream str;
        str << v;

        if(str.str() == "[[[DATE]]]")
            std::clog << "[" << QDateTime::currentDateTime().toString("dd/MM/yyyy HH:mm:ss:zzz").toStdString() << "] ";
        else
            std::clog << v;

        return *this;

    }

    PQLog &operator<<(std::ostream&(*f)(std::ostream&)) {

        std::clog << f;
        return *this;

    }

private:
    PQLog() { }

};

/***************************************************************/
// DEBUG LOGGER

class PQDebugLog : public QObject {

    Q_OBJECT

public:
    static PQDebugLog& get() {
        static PQDebugLog instance;
        return instance;
    }

    PQDebugLog(PQDebugLog const&)     = delete;
    void operator=(PQDebugLog const&) = delete;

    template <class T>
    PQDebugLog &operator<<(const T &v) {

        if(!debug) return *this;

        std::stringstream str;
        str << v;

        if(str.str() == "[[[DATE]]]")
            std::clog << "[" << QDateTime::currentDateTime().toString("dd/MM/yyyy HH:mm:ss:zzz").toStdString() << "] ";
        else
            std::clog << v;

        return *this;

    }

    PQDebugLog &operator<<(std::ostream&(*f)(std::ostream&)) {

        if(!debug) return *this;

        std::clog << f;
        return *this;

    }

    void setDebug(bool dbg) {
        debug = dbg;
    }

private:
    PQDebugLog() {
        debug = false;
    }
    bool debug;

};

#define LOG PQLog::get()
#define DBG PQDebugLog::get()
#define CURDATE "[[[DATE]]]"
#define NL "\n"

#endif // PQLOG_H
