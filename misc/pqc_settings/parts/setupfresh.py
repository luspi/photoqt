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
void PQCSettings::setupFresh() {

    qDebug() << "";

    """

    for tab in dbtables:

        c = conn.cursor()
        c.execute(f"SELECT `name`,`defaultvalue`,`datatype` FROM {tab} ORDER BY `name`")
        data = c.fetchall()

        cont += f"""

    // table: {tab}"""
        for row in data:

            name = row[0]
            defaultvalue = row[1]
            datatype = row[2]

            cont += f"""
    m_{tab}{name} = """

            valuestring = ""

            if datatype == "string":
                valuestring = f"\"{defaultvalue}\""
            elif datatype == "bool":
                valuestring = ("false" if defaultvalue == "0" else "true")
            elif datatype == "int":
                valuestring = defaultvalue
            elif datatype == "double":
                valuestring = defaultvalue
            elif datatype == "list":

                valuestring = "QStringList()";
                if defaultvalue != "":
                    parts = defaultvalue.split(":://::")
                    for p in parts:
                        valuestring += f" << \"{p}\""

            elif datatype == "point":

                parts = defaultvalue.split(",")
                if len(parts) == 2:
                    valuestring = f"QPoint({parts[0]}, {parts[1]})"
                else:
                    valuestring = f"QPoint(0, 0)"

            elif datatype == "size":

                parts = defaultvalue.split(",")
                if len(parts) == 2:
                    valuestring = f"QSize({parts[0]}, {parts[1]})"
                else:
                    valuestring = f"QSize(0, 0)"

            cont += valuestring
            cont += ";"

            if f"{tab}{name}" in duplicateSettingsNames:
                cont += f"""
    /* duplicate */ PQCSettingsCPP::get().m_{tab}{name} = {valuestring};"""

    if f"{tab}{name}" in duplicateSettingsSignal:
        cont += f"""
    /* duplicate */ Q_EMIT PQCSettingsCPP::get().{tab}{name}Changed();"""

    cont += """

#ifdef Q_OS_WIN
    // these defaults are different on Windows as on Linux
    m_filedialogDevices = true;
#endif

#ifndef PQMPUGIXML
    // with no pugixml we hide the bookmarks (as they are currently empty)
    // and instead show the devices by default
    m_filedialogDevices = true;
    m_filedialogPlaces = false;
#endif

    // the window decoration on Gnome is a bit weird
    // that's why we disable it by default
    if(qgetenv("XDG_CURRENT_DESKTOP").contains("GNOME"))
        m_interfaceWindowDecoration = false;

}

"""

    return cont
