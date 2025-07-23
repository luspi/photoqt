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

def get(duplicateSettings, duplicateSettingsSignal):

    duplicateSettingsNames = []
    for i in duplicateSettings:
        duplicateSettingsNames.append(i[1])

    conn = sqlite3.connect('../defaultsettings.db')

    dbtables = ['filedialog',
            'filetypes',
            'general',
            'imageview',
            'interface',
            'mainmenu',
            'mapview',
            'metadata',
            'slideshow',
            'thumbnails']

    cont = """
void PQCSettings::updateFromCommandLine() {

    const QStringList update = PQCNotifyCPP::get().getSettingUpdate();
    qDebug() << "update =" << update;

    if(update.length() != 2)
        return;

    const QString key = update[0];
    const QString val = update[1];
"""

    for tab in dbtables:

        c = conn.cursor()
        c.execute(f"SELECT `name`,`defaultvalue`,`datatype` FROM {tab} ORDER BY `name`")
        data = c.fetchall()

        for row in data:

            name = row[0]
            defaultvalue = row[1]
            datatype = row[2]

            prefixcont = ""

            valconversion = "val"
            if datatype == "bool":
                valconversion = "(val.toInt()==1)"
            elif datatype == "int":
                valconversion = "val.toInt()"
            elif datatype == "double":
                valconversion = "val.toDouble()"
            elif datatype == "list":
                valconversion = "val.split(\":://::\")"
            elif datatype == "point":
                prefixcont += f"""QStringList parts = val.split(\",\");
        if(parts.length() != 2)
            return;
        """
                valconversion = "QPoint(parts[0].toInt(), parts[1].toInt())"
            elif datatype == "size":
                prefixcont += f"""QStringList parts = val.split(\",\");
        if(parts.length() != 2)
            return;
        """
                valconversion = "QSize(parts[0].toInt(), parts[1].toInt())"

            cont += f"""
    if(key == \"{tab}{name}\") {{
        {prefixcont}m_{tab}{name} = {valconversion};
        Q_EMIT {tab}{name}Changed();"""

            if f"{tab}{name}" in duplicateSettingsNames:
                cont += f"""
        /* duplicate */ PQCSettingsCPP::get().m_{tab}{name} = {valconversion};"""
                if f"{tab}{name}" in duplicateSettingsSignal:
                    cont += f"""
        /* duplicate */ Q_EMIT PQCSettingsCPP::get().{tab}{name}Changed();"""

            cont += """
    }"""

    cont += """

}
"""
    return cont
