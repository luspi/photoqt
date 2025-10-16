/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
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
#pragma once

#include <shared/pqc_configfiles.h>
#include <QObject>
#include <QFile>
#include <QMutex>

class PQCSaveOutput : public QObject {

    Q_OBJECT

public:
    static PQCSaveOutput& get() {
        static PQCSaveOutput instance;
        return instance;
    }

    PQCSaveOutput(PQCSaveOutput const&) = delete;
    void operator=(PQCSaveOutput const&) = delete;

    void addLogMessage(QString msg) {
        m_mutex.lock();
        m_out << msg;
        m_mutex.unlock();
    }

private:
    PQCSaveOutput() {
        if(QFileInfo::exists(PQCConfigFiles::get().LOG_FILE())) {
            if(!QFile::remove(PQCConfigFiles::get().LOG_FILE())) {
                qWarning() << "Unable to remove old log file, output might be duplicated.";
            }
        }
        m_logfile.setFileName(PQCConfigFiles::get().LOG_FILE());
        if(!m_logfile.open(QIODevice::WriteOnly|QIODevice::Append))
            qWarning() << "Unable to open log file for writing!";
        m_out.setDevice(&m_logfile);
    }
    ~PQCSaveOutput() {
        m_logfile.close();
    }

    QFile m_logfile;
    QTextStream m_out;
    QMutex m_mutex;

};
