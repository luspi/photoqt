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

    ########################################
    # READ DATABASE
    ########################################

    cont_SOURCE = """
void PQCSettings::readDB() {

    qDebug() << "";

    for(const auto &table : std::as_const(dbtables)) {

        QSqlQuery query(db);
        query.prepare(QString("SELECT `name`,`value` FROM '%1'").arg(table));
        if(!query.exec())
            qCritical() << QString("SQL Query error (%1):").arg(table) << query.lastError().text();

        while(query.next()) {

            QString name = query.value(0).toString();
            QVariant value = query.value(1).toString();
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
            {"} else " if tablecount > 1 else ""}if(table == \"{tab}\") {{"""
        for row in data:

            name = row[0]
            datatype = row[1]

            if datatype == "string":
                cont_SOURCE += f"""
                {prefx}if(name == \"{name}\") {{
                    m_{tab}{name} = value.toString();"""
                if f"{tab}{name}" in duplicateSettingsNames:
                    cont_SOURCE += f"""
                    /* duplicate */ PQCSettingsCPP::get().m_{tab}{name} = value.toString();"""
                    if f"{tab}{name}" in duplicateSettingsSignal:
                        cont_SOURCE += f"""
                    /* duplicate */ Q_EMIT PQCSettingsCPP::get().{tab}{name}Changed();"""

            elif datatype == "int":
                cont_SOURCE += f"""
                {prefx}if(name == \"{name}\") {{
                    m_{tab}{name} = value.toInt();"""
                if f"{tab}{name}" in duplicateSettingsNames:
                    cont_SOURCE += f"""
                    /* duplicate */ PQCSettingsCPP::get().m_{tab}{name} = value.toInt();"""
                    if f"{tab}{name}" in duplicateSettingsSignal:
                        cont_SOURCE += f"""
                    /* duplicate */ Q_EMIT PQCSettingsCPP::get().{tab}{name}Changed();"""

            elif datatype == "double":
                cont_SOURCE += f"""
                {prefx}if(name == \"{name}\") {{
                    m_{tab}{name} = value.toDouble();"""
                if f"{tab}{name}" in duplicateSettingsNames:
                    cont_SOURCE += f"""
                    /* duplicate */ PQCSettingsCPP::get().m_{tab}{name} = value.toDouble();"""
                    if f"{tab}{name}" in duplicateSettingsSignal:
                        cont_SOURCE += f"""
                    /* duplicate */ Q_EMIT PQCSettingsCPP::get().{tab}{name}Changed();"""

            elif datatype == "bool":
                cont_SOURCE += f"""
                {prefx}if(name == \"{name}\") {{
                    m_{tab}{name} = value.toInt();"""
                if f"{tab}{name}" in duplicateSettingsNames:
                    cont_SOURCE += f"""
                    /* duplicate */ PQCSettingsCPP::get().m_{tab}{name} = value.toInt();"""
                    if f"{tab}{name}" in duplicateSettingsSignal:
                        cont_SOURCE += f"""
                    /* duplicate */ Q_EMIT PQCSettingsCPP::get().{tab}{name}Changed();"""

            elif datatype == "list":
                cont_SOURCE += f"""
                {prefx}if(name == \"{name}\") {{
                    QString val = value.toString();
                    if(val.contains(":://::"))
                        m_{tab}{name} = val.split(":://::");
                    else if(val != "")
                        m_{tab}{name} = QStringList() << val;
                    else
                        m_{tab}{name} = QStringList();"""
                if f"{tab}{name}" in duplicateSettingsNames:
                    cont_SOURCE += f"""
                    /* duplicate */
                    if(val.contains(":://::"))
                        PQCSettingsCPP::get().m_{tab}{name} = val.split(":://::");
                    else if(val != "")
                        PQCSettingsCPP::get().m_{tab}{name} = QStringList() << val;
                    else
                        PQCSettingsCPP::get().m_{tab}{name} = QStringList();"""
                    if f"{tab}{name}" in duplicateSettingsSignal:
                        cont_SOURCE += f"""
                    Q_EMIT PQCSettingsCPP::get().{tab}{name}Changed();"""

            elif datatype == "point":
                cont_SOURCE += f"""
                {prefx}if(name == \"{name}\") {{
                    const QStringList parts = value.toString().split(",");
                    if(parts.length() == 2)
                        m_{tab}{name} = QPoint(parts[0].toInt(), parts[1].toInt());
                    else
                        m_{tab}{name} = QPoint(0,0);"""
                if f"{tab}{name}" in duplicateSettingsNames:
                    cont_SOURCE += f"""
                    /* duplicate */
                    if(parts.length() == 2)
                        PQCSettingsCPP::get().m_{tab}{name} = QPoint(parts[0].toInt(), parts[1].toInt());
                    else
                        PQCSettingsCPP::get().m_{tab}{name} = QPoint(0,0);"""
                    if f"{tab}{name}" in duplicateSettingsSignal:
                        cont_SOURCE += f"""
                    Q_EMIT PQCSettingsCPP::get().{tab}{name}Changed();"""

            elif datatype == "size":
                cont_SOURCE += f"""
                {prefx}if(name == \"{name}\") {{
                    const QStringList parts = value.toString().split(",");
                    if(parts.length() == 2)
                        m_{tab}{name} = QSize(parts[0].toInt(), parts[1].toInt());
                    else
                        m_{tab}{name} = QSize(0,0);"""
                if f"{tab}{name}" in duplicateSettingsNames:
                    cont_SOURCE += f"""
                    /* duplicate */
                    if(parts.length() == 2)
                        PQCSettingsCPP::get().m_{tab}{name} = QSize(parts[0].toInt(), parts[1].toInt());
                    else
                        PQCSettingsCPP::get().m_{tab}{name} = QSize(0,0);"""
                    if f"{tab}{name}" in duplicateSettingsSignal:
                        cont_SOURCE += f"""
                    Q_EMIT PQCSettingsCPP::get().{tab}{name}Changed();"""


            prefx = "} else "

    cont_SOURCE += """
                }
            }
        }

    }

    QSqlQuery queryEXT(db);
    queryEXT.prepare("SELECT `name`,`value`,`datatype` FROM 'extensions'");
    if(!queryEXT.exec())
        qCritical() << "SQL Query error (extensions):" << queryEXT.lastError().text();

    while(queryEXT.next()) {

        QString name = queryEXT.value(0).toString();
        QString value = queryEXT.value(1).toString();
        QString datatype = queryEXT.value(2).toString();

        if(datatype == "int")
            m_extensions->insert(name, value.toInt());
        else if(datatype == "double")
            m_extensions->insert(name, value.toDouble());
        else if(datatype == "bool")
            m_extensions->insert(name, static_cast<bool>(value.toInt()));
        else if(datatype == "list") {
            if(value.contains(":://::"))
                m_extensions->insert(name, value.split(":://::"));
            else if(value != "")
                m_extensions->insert(name, QStringList() << value);
            else
                m_extensions->insert(name, QStringList());
        } else if(datatype == "point") {
            const QStringList parts = value.split(",");
            if(parts.length() == 2)
                m_extensions->insert(name, QPoint(parts[0].toInt(), parts[1].toInt()));
            else {
                qWarning() << QString("ERROR: invalid format of QPoint for setting '%1': '%2'").arg(name, value);
                m_extensions->insert(name, QPoint(0,0));
            }
        } else if(datatype == "size") {
            const QStringList parts = value.split(",");
            if(parts.length() == 2)
                m_extensions->insert(name, QSize(parts[0].toInt(), parts[1].toInt()));
            else {
                qWarning() << QString("ERROR: invalid format of QSize for setting '%1': '%2'").arg(name, value);
                m_extensions->insert(name, QSize(0,0));
            }
        } else if(datatype == "string")
            m_extensions->insert(name, value);
        else if(datatype != "")
            qCritical() << QString("ERROR: datatype not handled for setting '%1':").arg(name) << datatype;
        else
            qDebug() << QString("empty datatype found for setting '%1' -> ignoring").arg(name);

    }

}

"""

    return cont_SOURCE
