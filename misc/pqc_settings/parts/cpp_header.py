##########################################################################
##                                                                      ##
## Copyright (C) 2011-2025 Lukas Spies                                  ##
## Contact: https://photoqt.org                                         ##
##                                                                      ##
## This file is part of PhotoQt.                                        ##
##                                                                      ##
## PhotoQt is free software: you can redistribute it and/or modify      ##
## it under the terms of the GNU General Public License as published by ##
## the Free Software Foundation, either version 2 of the License, or    ##
## (at your option) any later version.                                  ##
##                                                                      ##
## PhotoQt is distributed in the hope that it will be useful,           ##
## but WITHOUT ANY WARRANTY; without even the implied warranty of       ##
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        ##
## GNU General Public License for more details.                         ##
##                                                                      ##
## You should have received a copy of the GNU General Public License    ##
## along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      ##
##                                                                      ##
##########################################################################

import numpy as np
import sys
import sqlite3

import os

def get(duplicateSettings):

    cont = """/**************************************************************************
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

#ifndef PQCREADONLYSETTINGS_H
#define PQCREADONLYSETTINGS_H

#include <QObject>
#include <QtSql>
#include <QQmlPropertyMap>
#include <pqc_settings.h>

/********************************************************************************/
// NOTE: This is a duplication of some settings from the settings engine.
//       This is intended to be used as read-only interface for C++ code.
//       The values are automatically duplicated from the main settings engine.
/********************************************************************************/

class PQCSettingsCPP : public QObject {

    Q_OBJECT
    friend class PQCSettings;

public:
    static PQCSettingsCPP& get() {
        static PQCSettingsCPP instance;
        return instance;
    }

    PQCSettingsCPP(PQCSettingsCPP const&) = delete;
    void operator=(PQCSettingsCPP const&) = delete;
"""

    for setting in duplicateSettings:

        if setting[0] == "":
            cont += "\n"
            continue

        cont += f"""
    {setting[0]} get{setting[1][0].upper()}{setting[1][1:]}() {{ return m_{setting[1]}; }}"""

    cont += """

private:
    PQCSettingsCPP(QObject *parent = nullptr) : QObject(parent) {
"""

    for setting in duplicateSettings:
        if setting[0] == "":
            cont += "\n"
            continue

        if setting[0] == "bool":
            cont += f"""
            m_{setting[1]} = false;"""
        elif setting[0] == "QString":
            cont += f"""
            m_{setting[1]} = \"\";"""
        elif setting[0] == "int":
            cont += f"""
            m_{setting[1]} = 0;"""
        elif setting[0] == "double":
            cont += f"""
            m_{setting[1]} = 0.0;"""
        elif setting[0] == "QStringList":
            cont += f"""
            m_{setting[1]} = QStringList();"""
        else:
            print(f"CPP HEADER: UNHANDLED DUPLICATE DATATYPE: {setting[0]}")

    cont += """

    }
"""

    for setting in duplicateSettings:

        if setting[0] == "":
            cont += "\n"
            continue

        cont += f"""
    {setting[0]} m_{setting[1]};"""


    cont += """

Q_SIGNALS:"""

    for setting in duplicateSettings:

        if setting[0] == "":
            cont += "\n"
            continue

        cont += f"""
    void {setting[1]}Changed();"""

    cont += """

};

#endif
"""

    return cont

