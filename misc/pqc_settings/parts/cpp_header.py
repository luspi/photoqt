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
#include <QFile>
#include <QMessageBox>
#include <QApplication>
#include <QFileSystemWatcher>
#include <QSqlQuery>
#include <QSqlError>
#include <pqc_configfiles.h>
#include <pqc_settings.h>

/********************************************************************************/
// NOTE: This is a duplication of some settings from the settings engine.
//       This is intended to be used as read-only interface for C++ code.
//       The values are automatically duplicated from the main settings engine.
/********************************************************************************/

class PQCSettingsCPP : public QObject {

    Q_OBJECT

public:
    static PQCSettingsCPP& get() {
        static PQCSettingsCPP instance;
        return instance;
    }

    PQCSettingsCPP(PQCSettingsCPP const&) = delete;
    void operator=(PQCSettingsCPP const&) = delete;

    QVariant getExtensionValue(const QString &key) { return m_extensions.value(key, ""); }
    QVariant getExtensionDefaultValue(const QString &key) { return m_extensions_defaults.value(key, ""); }
"""

    for tab in dbtables:
        c = conn.cursor()
        c.execute(f"SELECT `name`,`defaultvalue`,`datatype` FROM {tab} ORDER BY `name`")
        data = c.fetchall()

        for row in data:

            name = row[0]
            defaultvalue = row[1]
            datatype = row[2]

            dt = datatype
            if datatype == "string":
                dt = "QString"
            elif datatype == "list":
                dt = "QStringList"

            for setting in duplicateSettings:

                if setting == "":
                    continue

                if setting != f"{tab}{name}":
                    continue

                cont += f"""
    {dt} get{tab[0].upper()}{tab[1:]}{name}() {{ return m_{tab}{name}; }}"""

    cont += """

private:
    PQCSettingsCPP(QObject *parent = nullptr) : QObject(parent) {
"""

    for tab in dbtables:
        c = conn.cursor()
        c.execute(f"SELECT `name`,`defaultvalue`,`datatype` FROM {tab} ORDER BY `name`")
        data = c.fetchall()

        for row in data:

            name = row[0]
            defaultvalue = row[1]
            datatype = row[2]

            for setting in duplicateSettings:

                if setting == "":
                    continue

                if setting != f"{tab}{name}":
                    continue

                cont += f"""
        m_{tab}{name} = """

                if datatype == "bool":
                    valuestring = ("false" if defaultvalue == "0" else "true")
                elif datatype == "string":
                    valuestring = f"\"{defaultvalue}\""
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
                else:
                    print(f"CPP HEADER: UNHANDLED DUPLICATE DATATYPE: {datatype}")

                cont += f"{valuestring};"

    cont += """

        QSqlDatabase db = QSqlDatabase::database("settings");

        // connect to user database
        if(!db.isValid()) {
            if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
                db = QSqlDatabase::addDatabase("QSQLITE3", "settings");
            else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
                db = QSqlDatabase::addDatabase("QSQLITE", "settings");

            QFileInfo infodb(PQCConfigFiles::get().USERSETTINGS_DB());

            // the db does not exist -> create it
            if(!infodb.exists()) {
                if(!QFile::copy(":/usersettings.db", PQCConfigFiles::get().USERSETTINGS_DB()))
                    qWarning() << "Unable to (re-)create default user settings database";
                else {
                    QFile file(PQCConfigFiles::get().USERSETTINGS_DB());
                    file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
                }
            }

            db.setDatabaseName(PQCConfigFiles::get().USERSETTINGS_DB());

        }

        readDB();

        watcher = new QFileSystemWatcher;
        watcher->addPath(PQCConfigFiles::get().USERSETTINGS_DB());
        connect(watcher, &QFileSystemWatcher::fileChanged, this, [=](QString path) { readDB(); });

    }

    ~PQCSettingsCPP() {
        delete watcher;
    }

    QFileSystemWatcher *watcher;

    QVariantHash m_extensions;
    QVariantHash m_extensions_defaults;
"""

    for tab in dbtables:
        c = conn.cursor()
        c.execute(f"SELECT `name`,`defaultvalue`,`datatype` FROM {tab} ORDER BY `name`")
        data = c.fetchall()

        for row in data:

            name = row[0]
            defaultvalue = row[1]
            datatype = row[2]

            dt = datatype
            if datatype == "string":
                dt = "QString"
            elif datatype == "list":
                dt = "QStringList"

            for setting in duplicateSettings:

                if setting == "":
                    continue

                if setting != f"{tab}{name}":
                    continue

                cont += f"""
    {dt} m_{setting};"""


    cont += """

private Q_SLOTS:

    void readDB() {

        QSqlDatabase db = QSqlDatabase::database("duplicatesettings");

        if(!db.open()) {
            qCritical() << "ERROR: Unable to open settings database. This should never happen...";
            return;
        }

        const QStringList dbtables = {"general",
                                      "interface",
                                      "imageview",
                                      "thumbnails",
                                      "metadata",
                                      "filetypes",
                                      "filedialog"};

        for(const QString &table : dbtables) {

            QSqlQuery query(db);
            query.prepare(QString("SELECT `name`,`value`,`datatype` FROM '%1'").arg(table));
            if(!query.exec()) {
                qWarning() << "ERROR: Getting data for table" << table << "failed:" << query.lastError().text();
                continue;
            }

            while(query.next()) {

                QString name = query.value(0).toString();
                QVariant value = query.value(1).toString();
            """


    prefx = ""

    tablecount = 0
    for tab in dbtables:

        tablecount += 1

        c = conn.cursor()
        c.execute(f"SELECT `name`,`datatype` FROM {tab} ORDER BY `name`")
        data = c.fetchall()

        for row in data:

            name = row[0]
            datatype = row[1]

            for setting in duplicateSettings:

                if setting == "":
                    continue

                if setting != f"{tab}{name}":
                    continue

                if datatype == "string":
                    cont += f"""
                {prefx}if(table == \"{tab}\" && name == \"{name}\") {{
                    const QString val = value.toString();
                    if(m_{tab}{name} != val) {{
                        m_{tab}{name} = val;
                        Q_EMIT {tab}{name}Changed();
                    }}"""

                elif datatype == "int":
                    cont += f"""
                {prefx}if(table == \"{tab}\" && name == \"{name}\") {{
                    const int val = value.toInt();
                    if(m_{tab}{name} != val) {{
                        m_{tab}{name} = value.toInt();
                        Q_EMIT {tab}{name}Changed();
                    }}"""

                elif datatype == "double":
                    cont += f"""
                {prefx}if(table == \"{tab}\" && name == \"{name}\") {{
                    const double val = value.toDouble();
                    if(m_{tab}{name} != val) {{
                        m_{tab}{name} = value.toDouble();
                        Q_EMIT {tab}{name}Changed();
                    }}"""

                elif datatype == "bool":
                    cont += f"""
                {prefx}if(table == \"{tab}\" && name == \"{name}\") {{
                    const bool val = value.toInt();
                    if(m_{tab}{name} != val) {{
                        m_{tab}{name} = value.toInt();
                        Q_EMIT {tab}{name}Changed();
                    }}"""

                elif datatype == "list":
                    cont += f"""
                {prefx}if(table == \"{tab}\" && name == \"{name}\") {{
                    const QString val = value.toString();
                    QStringList valToSet = QStringList();
                    if(val.contains(":://::"))
                        valToSet = val.split(":://::");
                    else if(val != "")
                        valToSet = QStringList() << val;
                    if(m_{tab}{name} != valToSet) {{
                        m_{tab}{name} = valToSet;
                        Q_EMIT {tab}{name}Changed();
                    }}"""

                prefx = "} else "

    cont +="""
                }
            }

        }

    }

Q_SIGNALS:
    void extensionsChanged();"""

    for setting in duplicateSettings:

        if setting == "":
            continue

        cont += f"""
    void {setting}Changed();"""

    cont += """

};

#endif
"""

    return cont

