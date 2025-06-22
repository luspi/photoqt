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

    cont = """
QVariantList PQCSettings::getDefaultFor(QString key) {

    qDebug() << "args: key =" << key;
    qDebug() << "readonly =" << readonly;

    if(readonly) return {"", ""};

    QString tablename = "";
    QString settingname = "";

    for(auto &t : std::as_const(dbtables)) {

        if(key.startsWith(t)) {
            tablename = t;
            break;
        }

    }

    // invalid table name
    if(tablename == "") {
        qWarning() << "tablename not found";
        return {"", ""};
    }

    settingname = key.last(key.size()-tablename.size());

    QSqlQuery query(dbDefault);
    query.prepare(QString("SELECT `defaultvalue`,`datatype` FROM '%1' WHERE name='%2'").arg(tablename,settingname));
    if(!query.exec())
        qWarning() << "SQL Error:" << query.lastError().text();

    if(!query.next()) {
        qWarning() << "unable to get default value";
        return {"", ""};
    }

    return {query.value(0), query.value(1)};

}

"""
    return cont
