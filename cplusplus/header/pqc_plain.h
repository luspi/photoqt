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

#ifndef PQCSCRIPTSPLAIN_H
#define PQCSCRIPTSPLAIN_H

#include <QObject>

class PQCScriptsPlain : public QObject {

    Q_OBJECT

public:
    static PQCScriptsPlain& get() {
        static PQCScriptsPlain instance;
        return instance;
    }
    ~PQCScriptsPlain() {}

    PQCScriptsPlain(PQCScriptsPlain const&)     = delete;
    void operator=(PQCScriptsPlain const&) = delete;

    void setInitTime(qint64 t) {
        m_initTime = t;
    }
    Q_INVOKABLE qint64 getInitTime() {
        return m_initTime;
    }

private:
    PQCScriptsPlain() {
        m_initTime = 0;
    }

    qint64 m_initTime;

};

#endif
