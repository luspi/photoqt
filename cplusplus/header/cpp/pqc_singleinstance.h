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

#ifndef PQCSINGLEINSTANCE_H
#define PQCSINGLEINSTANCE_H

#include <QApplication>
#include <cpp/pqc_cppconstants.h>
#include <cpp/pqc_commandlineparser.h>

class QQmlApplicationEngine;

// Makes sure only one instance of PhotoQt is running, and enables remote communication
class PQCSingleInstance : public QApplication {

    Q_OBJECT

public:
    explicit PQCSingleInstance(int&, char *[]);
    ~PQCSingleInstance();

    QString getExportAndQuit() { return m_exportAndQuit; }
    QString getImportAndQuit() { return m_importAndQuit; }
    bool getCheckConfig() { return m_checkConfig; }
    bool getResetConfig() { return m_resetConfig; }
    bool getShowInfo() { return m_showInfo; }
    bool getForceModernInterface() { return m_forceModernInterface; }
    bool getForceIntegratedInterface() { return m_forceIntegratedInterface; }

private:
    QString m_exportAndQuit;
    QString m_importAndQuit;
    bool m_checkConfig;
    bool m_resetConfig;
    bool m_showInfo;

    bool m_forceModernInterface;
    bool m_forceIntegratedInterface;

};

#endif // PQSINGLEINSTANCE_H
