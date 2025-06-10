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

    cont = ""

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

    for tab in dbtables:

        c = conn.cursor()
        c.execute(f"SELECT `name`,`defaultvalue`,`datatype` FROM {tab} ORDER BY `name`")
        data = c.fetchall()

        for row in data:

            name = row[0]
            defaultvalue = row[1]
            datatype = row[2]

            qtdatatpe = "QString"
            if datatype == "bool":
                qtdatatpe = "bool"
            elif datatype == "int":
                qtdatatpe = "int"
            elif datatype == "double":
                qtdatatpe = "double"
            elif datatype == "list":
                qtdatatpe = "QStringList"
            elif datatype == "point":
                qtdatatpe = "QPoint"
            elif datatype == "size":
                qtdatatpe = "QSize"

            cont += f"""
{qtdatatpe} PQCSettings::get{tab.capitalize()}{name}() {{
    return m_{tab}{name};
}}

void PQCSettings::set{tab.capitalize()}{name}({qtdatatpe} val) {{
    if(val != m_{tab}{name}) {{
        m_{tab}{name} = val;
        Q_EMIT {tab}{name}Changed();"""

            if f"{tab}{name}" in duplicateSettingsNames:
                cont += f"""
        /* duplicate */ PQCSettingsCPP::get().m_{tab}{name} = val;"""
                if f"{tab}{name}" in duplicateSettingsSignal:
                    cont += f"""
        /* duplicate */ Q_EMIT PQCSettingsCPP::get().{tab}{name}Changed();"""

            cont += f"""
    }}
}}

{qtdatatpe} PQCSettings::getDefaultFor{tab.capitalize()}{name}() {{"""

            if datatype == "string":
                cont += f"""
        return \"{defaultvalue}\";"""

            elif datatype == "int" or datatype == "double":
                cont += f"""
        return {defaultvalue};"""

            elif datatype == "bool":
                cont += f"""
        return {"true" if defaultvalue=="1" else "false"};"""

            elif datatype == "list":
                parts = defaultvalue.split(":://::")
                cont += """
        return QStringList()"""
                for p in parts:
                    cont += f" << \"{p}\""
                cont += ";"

            elif datatype == "point":
                parts = defaultvalue.split(",")
                cont += f"""
        return QPoint({parts[0]}, {parts[1]});"""

            elif datatype == "size":
                parts = defaultvalue.split(",")
                cont += f"""
        return QSize({parts[0]}, {parts[1]});"""

            cont += f"""
}}

void PQCSettings::setDefaultFor{tab.capitalize()}{name}() {{"""

            if datatype == "string":
                cont += f"""
    if(\"{defaultvalue}\" != m_{tab}{name}) {{
        m_{tab}{name} = \"{defaultvalue}\";
        Q_EMIT {tab}{name}Changed();"""
                if f"{tab}{name}" in duplicateSettingsNames:
                    cont += f"""
        /* duplicate */ PQCSettingsCPP::get().m_{tab}{name} = \"{defaultvalue}\";"""
                    if f"{tab}{name}" in duplicateSettingsSignal:
                        cont += f"""
        /* duplicate */ Q_EMIT PQCSettingsCPP::get().{tab}{name}Changed();"""
                cont += """
    }"""

            elif datatype == "int" or datatype == "double":
                cont += f"""
    if({defaultvalue} != m_{tab}{name}) {{
        m_{tab}{name} = {defaultvalue};
        Q_EMIT {tab}{name}Changed();"""
                if f"{tab}{name}" in duplicateSettingsNames:
                    cont += f"""
        /* duplicate */ PQCSettingsCPP::get().m_{tab}{name} = {defaultvalue};"""
                    if f"{tab}{name}" in duplicateSettingsSignal:
                        cont += f"""
        /* duplicate */ Q_EMIT PQCSettingsCPP::get().{tab}{name}Changed();"""
                cont += """
    }"""

            elif datatype == "bool":
                cont += f"""
    if({"true" if defaultvalue=="1" else "false"} != m_{tab}{name}) {{
        m_{tab}{name} = {"true" if defaultvalue=="1" else "false"};
        Q_EMIT {tab}{name}Changed();"""
                if f"{tab}{name}" in duplicateSettingsNames:
                    cont += f"""
        /* duplicate */ PQCSettingsCPP::get().m_{tab}{name} = {"true" if defaultvalue=="1" else "false"};"""
                    if f"{tab}{name}" in duplicateSettingsSignal:
                        cont += f"""
        /* duplicate */ Q_EMIT PQCSettingsCPP::get().{tab}{name}Changed();"""
                cont += """
    }"""

            elif datatype == "list":

                parts = defaultvalue.split(":://::")
                cont += """
    QStringList tmp = QStringList()"""
                for p in parts:
                    cont += f" << \"{p}\""
                cont += f""";
    if(tmp != m_{tab}{name}) {{
        m_{tab}{name} = tmp;
        Q_EMIT {tab}{name}Changed();"""
                if f"{tab}{name}" in duplicateSettingsNames:
                    cont += f"""
        /* duplicate */ PQCSettingsCPP::get().m_{tab}{name} = tmp;"""
                    if f"{tab}{name}" in duplicateSettingsSignal:
                        cont += f"""
        /* duplicate */ Q_EMIT PQCSettingsCPP::get().{tab}{name}Changed();"""
                cont += """
    }"""

            elif datatype == "point":
                parts = defaultvalue.split(",")
                cont += f"""
    if(QPoint({parts[0]}, {parts[1]}) != m_{tab}{name}) {{
        m_{tab}{name} = QPoint({parts[0]}, {parts[1]});
        Q_EMIT {tab}{name}Changed();"""
                if f"{tab}{name}" in duplicateSettingsNames:
                    cont += f"""
        /* duplicate */ PQCSettingsCPP::get().m_{tab}{name} = QPoint({parts[0]}, {parts[1]});"""
                    if f"{tab}{name}" in duplicateSettingsSignal:
                        cont += f"""
        /* duplicate */ Q_EMIT PQCSettingsCPP::get().{tab}{name}Changed();"""
                cont += """
    }"""

            elif datatype == "size":
                parts = defaultvalue.split(",")
                cont += f"""
    if(QSize({parts[0]}, {parts[1]}) != m_{tab}{name}) {{
        m_{tab}{name} = QSize({parts[0]}, {parts[1]});
        Q_EMIT {tab}{name}Changed();"""
                if f"{tab}{name}" in duplicateSettingsNames:
                    cont += f"""
        /* duplicate */ PQCSettingsCPP::get().m_{tab}{name} = QSize({parts[0]}, {parts[1]});"""
                    if f"{tab}{name}" in duplicateSettingsSignal:
                        cont += f"""
        /* duplicate */ Q_EMIT PQCSettingsCPP::get().{tab}{name}Changed();"""
                cont += """
    }"""



            cont += """
}
"""

    return cont
