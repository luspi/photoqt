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
void PQCSettings::saveChangedValue(const QString &_key, const QVariant &value) {

    qDebug() << "args: key =" << _key;
    qDebug() << "args: value =" << value;
    qDebug() << "readonly =" << readonly;

    if(readonly) return;

    QSqlDatabase db = QSqlDatabase::database("settings");

    dbCommitTimer->stop();

    QString key = _key;
    QString category = "";

    for(const auto &table : std::as_const(dbtables)) {
        if(key.startsWith(table)) {
            category = table;
            key = key.remove(0, table.length());
            break;
        }
    }

    if(category == "") {
        qWarning() << "ERROR: invalid category received:" << key;
        return;
    }

    QSqlQuery query(db);

    if(!dbIsTransaction) {
        db.transaction();
        dbIsTransaction = true;
    }

    // Using a placeholder also for table name causes an sqlite 'parameter count mismatch' error
    // the 'on conflict' cause performs an update if the value already exists and the insert thus failed
    query.prepare(QString("INSERT INTO '%1' (`name`,`value`,`datatype`) VALUES (:nme, :val, :dat) ON CONFLICT (`name`) DO UPDATE SET `value`=:valupdate").arg(category));

    query.bindValue(":nme", key);

    // we convert the value to a string
    QString val = "";
    if(value.typeId() == QMetaType::Bool) {
        val = QString::number(value.toInt());
        query.bindValue(":dat", "bool");
    } else if(value.typeId() == QMetaType::Int) {
        val = QString::number(value.toInt());
        query.bindValue(":dat", "int");
    } else if(value.typeId() == QMetaType::Double) {
        val = QString::number(value.toDouble());
        query.bindValue(":dat", "double");
    } else if(value.typeId() == QMetaType::QStringList) {
        val = value.toStringList().join(":://::");
        query.bindValue(":dat", "list");
    } else if(value.typeId() == QMetaType::QPoint) {
        val = QString("%1,%2").arg(value.toPoint().x()).arg(value.toPoint().y());
        query.bindValue(":dat", "point");
    } else if(value.typeId() == QMetaType::QPointF) {
        val = QString("%1,%2").arg(value.toPointF().x()).arg(value.toPointF().y());
        query.bindValue(":dat", "point");
    } else if(value.typeId() == QMetaType::QSize) {
        val = QString("%1,%2").arg(value.toSize().width()).arg(value.toSize().height());
        query.bindValue(":dat", "size");
    } else if(value.typeId() == QMetaType::QSizeF) {
        val = QString("%1,%2").arg(value.toSizeF().width()).arg(value.toSizeF().height());
        query.bindValue(":dat", "size");
    } else if(value.canConvert<QJSValue>() && value.value<QJSValue>().isArray()) {
        QStringList ret;
        QJSValue _val = value.value<QJSValue>();
        const int length = _val.property("length").toInt();
        for(int i = 0; i < length; ++i)
            ret << _val.property(i).toString();
        val = ret.join(":://::");
        query.bindValue(":dat", "list");
    } else {
        val = value.toString();
        query.bindValue(":dat", "string");
    }

    query.bindValue(":val", val);
    query.bindValue(":valupdate", val);

    // and update database
    if(!query.exec()) {
        qWarning() << "SQL Error:" << query.lastError().text();
        qWarning() << "Category =" << category << "- value =" << value;
        qWarning() << "Executed query:" << query.lastQuery();
    }

    dbCommitTimer->start();

}
"""

    return cont
