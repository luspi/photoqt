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

    ########################################
    # READ DATABASE
    ########################################

    cont_SOURCE = """
void PQCSettings::readDB() {

    qDebug() << "";

    // then update with user values (if changed)

    for(const auto &table : std::as_const(dbtables)) {

        QSqlQuery query(db);
        query.prepare(QString("SELECT `name`,`value`,`datatype` FROM '%1'").arg(table));
        if(!query.exec())
            qCritical() << QString("SQL Query error (%1):").arg(table) << query.lastError().text();

        while(query.next()) {

            QString name = QString("%1%2").arg(table, query.value(0).toString());
            QString value = query.value(1).toString();
            QString datatype = query.value(2).toString();
        """

    tablecount = 0
    for tab in dbtables:

        tablecount += 1

        c = conn.cursor()
        c.execute(f"SELECT `name`,`datatype` FROM {tab} ORDER BY `name`")
        data = c.fetchall()

        prefx = ""

        if tablecount > 1:
            cont_SOURCE += """
                }"""

        cont_SOURCE += f"""
            // table: {tab}
            if(table == \"{tab}\") {{"""
        for row in data:

            name = row[0]
            datatype = row[1]

            if datatype == "string":
                cont_SOURCE += f"""
                {prefx}if(name == \"{name}\") {{
                    m_{tab}{name} = value;"""

            elif datatype == "int":
                cont_SOURCE += f"""
                {prefx}if(name == \"{name}\") {{
                    m_{tab}{name} = value.toInt();"""

            elif datatype == "double":
                cont_SOURCE += f"""
                {prefx}if(name == \"{name}\") {{
                    m_{tab}{name} = value.toDouble();"""

            elif datatype == "bool":
                cont_SOURCE += f"""
                {prefx}if(name == \"{name}\") {{
                    m_{tab}{name} = value.toBool();"""

            elif datatype == "list":
                cont_SOURCE += f"""
                {prefx}if(name == \"{name}\") {{
                    if(value.contains(":://::"))
                        m_{tab}{name} = value.split(":://::");
                    else if(value != "")
                        m_{tab}{name} = QStringList() << value;
                    else
                        m_{tab}{name} = QStringList();"""

            elif datatype == "point":
                cont_SOURCE += f"""
                {prefx}if(name == \"{name}\") {{
                    const QStringList parts = value.split(",");
                    if(parts.length() == 2)
                        m_{tab}{name} = QPoint(parts[0].toInt(), parts[1].toInt()));
                    else
                        m_{tab}{name} = QPoint(0,0);"""

            elif datatype == "size":
                cont_SOURCE += f"""
                {prefx}if(name == \"{name}\") {{
                    const QStringList parts = value.split(",");
                    if(parts.length() == 2)
                        m_{tab}{name} = QSize(parts[0].toInt(), parts[1].toInt()));
                    else
                        m_{tab}{name} = QSize(0,0);"""

            prefx = "} else "

    cont_SOURCE += """
            }
        }

    }

}

"""

    return cont_SOURCE
