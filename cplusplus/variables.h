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

#ifndef PQVARIABLES_H
#define PQVARIABLES_H

#include <QObject>
#include <QMutex>

class PQVariables : public QObject {

    Q_OBJECT

public:
        static PQVariables& get() {
            static PQVariables instance;
            return instance;
        }

        PQVariables(PQVariables const&)     = delete;
        void operator=(PQVariables const&) = delete;

        Q_PROPERTY(bool cmdDebug READ getCmdDebug WRITE setCmdDebug NOTIFY cmdDebugChanged)
        bool getCmdDebug() { return m_cmdDebug; }
        void setCmdDebug(bool val) {
            if(val != m_cmdDebug) {
                m_cmdDebug = val;
                emit cmdDebugChanged();
            }
        }

#ifdef DEVIL
        // DevIL is not threadsafe -> this ensures only one image is loaded at a time
        QMutex devilMutex;
#endif

private:
        PQVariables() {
            m_cmdDebug = false;
            m_freshInstall = false;
        }

        bool m_cmdDebug;
        bool m_freshInstall;

signals:
        void cmdDebugChanged();
        void freshInstallChanged();

};


#endif // PQVARIABLES_H
