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

def get():

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
{qtdatatpe} get{tab.capitalize()}{name}() {{
    return m_{tab}{name};
}}

void set{tab.capitalize()}{name}({qtdatatpe} val) {{
    if(val != m_{tab}{name}) {{
        m_{tab}{name} = val;
        Q_EMIT {tab}{name}Changed();
    }}
}}

void setDefaultFor{tab.capitalize()}{name}() {{"""

            if datatype == "string":
                cont += f"""
    if(\"{defaultvalue}\" != m_{tab}{name}) {{
        m_{tab}{name} = \"{defaultvalue}\";
        Q_EMIT {tab}{name}Changed();
    }}"""

            elif datatype == "int" or datatype == "double":
                cont += f"""
    if({defaultvalue} != m_{tab}{name}) {{
        m_{tab}{name} = {defaultvalue};
        Q_EMIT {tab}{name}Changed();
    }}"""

            elif datatype == "bool":
                cont += f"""
    if({"true" if defaultvalue=="1" else "false"} != m_{tab}{name}) {{
        m_{tab}{name} = {"true" if defaultvalue=="1" else "false"};
        Q_EMIT {tab}{name}Changed();
    }}"""

            elif datatype == "list":

                parts = defaultvalue.split(":://::")
                cont += """
    QStringList tmp = QStringList()"""
                for p in parts:
                    cont += f" << \"{p}\""
                cont += f""";
    if(tmp != m_{tab}{name}) {{
        m_{tab}{name} = tmp;
        Q_EMIT {tab}{name}Changed();
    }}"""

            elif datatype == "point":
                parts = defaultvalue.split(",")
                cont += f"""
    if(QPoint({parts[0]}, {parts[1]}) != m_{tab}{name}) {{
        m_{tab}{name} = QPoint({parts[0]}, {parts[1]});
        Q_EMIT {tab}{name}Changed();
    }}"""

            elif datatype == "size":
                parts = defaultvalue.split(",")
                cont += f"""
    if(QSize({parts[0]}, {parts[1]}) != m_{tab}{name}) {{
        m_{tab}{name} = QSize({parts[0]}, {parts[1]});
        Q_EMIT {tab}{name}Changed();
    }}"""



            cont += """
}}
"""

    return cont
