/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

#include <QJSValue>
#include <QMessageBox>
#include <QtLogging>
#include <pqc_settings.h>
#include <pqc_configfiles.h>

PQCSettings::PQCSettings() {

    // connect to database
    if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
        db = QSqlDatabase::addDatabase("QSQLITE3", "settings");
    else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
        db = QSqlDatabase::addDatabase("QSQLITE", "settings");
    db.setDatabaseName(PQCConfigFiles::SETTINGS_DB());

    dbtables = QStringList() << "general"
                             << "interface"
                             << "imageview"
                             << "thumbnails"
                             << "mainmenu"
                             << "metadata"
                             << "filetypes"
                             << "filedialog"
                             << "slideshow"
                             << "histogram"
                             << "mapview";

    readonly = false;

    QFileInfo infodb(PQCConfigFiles::SETTINGS_DB());

    if(!infodb.exists() || !db.open()) {

        qWarning() << "ERROR opening database:" << db.lastError().text();
        qWarning() << "Will load read-only database of default settings";

        readonly = true;
        db.setConnectOptions("QSQLITE_OPEN_READONLY");

        QString tmppath = QStandardPaths::writableLocation(QStandardPaths::TempLocation)+"/settings.db";

        if(QFile::exists(tmppath))
            QFile::remove(tmppath);

        if(!QFile::copy(":/settings.db", tmppath)) {
            qCritical() << "ERROR copying read-only default database!";
            //: This is the window title of an error message box
            QMessageBox::critical(0, QCoreApplication::translate("PQSettings", "ERROR getting database with default settings"),
                                     QCoreApplication::translate("PQSettings", "I tried hard, but I just cannot open even a read-only version of the settings database.") + QCoreApplication::translate("PQSettings", "Something went terribly wrong somewhere!"));
            return;
        }

        QFile f(tmppath);
        f.setPermissions(f.permissions()|QFileDevice::WriteOwner);

        db.setDatabaseName(tmppath);

        if(!db.open()) {
            qCritical() << "ERROR opening read-only default database!";
            QMessageBox::critical(0, QCoreApplication::translate("PQSettings", "ERROR opening database with default settings"),
                                     QCoreApplication::translate("PQSettings", "I tried hard, but I just cannot open the database of default settings.") + QCoreApplication::translate("PQSettings", "Something went terribly wrong somewhere!"));
            return;
        }

    } else {

        readonly = false;
        if(!infodb.permission(QFileDevice::WriteOwner))
            readonly = true;

    }

    readDB();

    dbIsTransaction = false;
    dbCommitTimer = new QTimer();
    dbCommitTimer->setSingleShot(true);
    dbCommitTimer->setInterval(400);
    connect(dbCommitTimer, &QTimer::timeout, this, [=](){
        db.commit();
        dbIsTransaction = false;
        if(db.lastError().text().trimmed().length())
            qWarning() << "ERROR committing database:" << db.lastError().text();
    });

    // if a value is changed in the ui, write to database
    connect(this, &QQmlPropertyMap::valueChanged, this, &PQCSettings::saveChangedValue);

#ifndef NDEBUG
    checkvalid = new QTimer;
    checkvalid->setInterval(1000);
    checkvalid->setSingleShot(false);
    connect(checkvalid, &QTimer::timeout, this, &PQCSettings::checkValidSlot);
    checkvalid->start();
#endif

}

PQCSettings::~PQCSettings() {
    delete dbCommitTimer;
#ifndef NDEBUG
    delete checkvalid;
#endif
}

void PQCSettings::readDB() {

#ifndef NDEBUG
    valid.clear();
#endif

    for(const auto &table : qAsConst(dbtables)) {

        QSqlQuery query(db);
        query.prepare(QString("SELECT name,value,datatype FROM %1").arg(table));
        if(!query.exec())
            qCritical() << "SQL Query error:" << query.lastError().text();

        while(query.next()) {

            QString name = QString("%1%2").arg(table, query.value(0).toString());
            QString value = query.value(1).toString();
            QString datatype = query.value(2).toString();

            if(datatype == "int")
                this->insert(name, value.toInt());
            else if(datatype == "double")
                this->insert(name, value.toDouble());
            else if(datatype == "bool")
                this->insert(name, static_cast<bool>(value.toInt()));
            else if(datatype == "list") {
                if(value.contains(":://::"))
                    this->insert(name, value.split(":://::"));
                else if(value != "")
                    this->insert(name, QStringList() << value);
                else
                    this->insert(name, QStringList());
            } else if(datatype == "point") {
                const QStringList parts = value.split(",");
                if(parts.length() == 2)
                    this->insert(name, QPoint(parts[0].toUInt(), parts[1].toInt()));
                else {
                    qWarning() << QString("ERROR: invalid format of QPoint for setting '%1': '%2'").arg(name, value);
                    this->insert(name, QPoint(0,0));
                }
            } else if(datatype == "size") {
                const QStringList parts = value.split(",");
                if(parts.length() == 2)
                    this->insert(name, QSize(parts[0].toUInt(), parts[1].toInt()));
                else {
                    qWarning() << QString("ERROR: invalid format of QSize for setting '%1': '%2'").arg(name, value);
                    this->insert(name, QSize(0,0));
                }
            } else if(datatype == "string")
                this->insert(name, value);
            else
                qCritical() << QString("ERROR: datatype not handled for setting '%1':").arg(name) << datatype;

#ifndef NDEBUG
            valid.push_back(name);
#endif

        }

    }

}

bool PQCSettings::backupDatabase() {

    // make sure all changes are written to db
    if(dbIsTransaction) {
        dbCommitTimer->stop();
        db.commit();
        dbIsTransaction = false;
        if(db.lastError().text().trimmed().length())
            qWarning() << "ERROR committing database:" << db.lastError().text();
    }

    // backup file
    if(QFile::exists(QString("%1.bak").arg(PQCConfigFiles::SETTINGS_DB())))
        QFile::remove(QString("%1.bak").arg(PQCConfigFiles::SETTINGS_DB()));
    QFile file(PQCConfigFiles::SETTINGS_DB());
    return file.copy(QString("%1.bak").arg(PQCConfigFiles::SETTINGS_DB()));

}

void PQCSettings::saveChangedValue(const QString &_key, const QVariant &value) {

    if(readonly) return;

    dbCommitTimer->stop();

    QString key = _key;
    QString category = "";

    for(const auto &table : qAsConst(dbtables)) {
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
    query.prepare(QString("UPDATE %1 SET value=:val WHERE name=:name").arg(category));

    // we convert the value to a string
    if(value.typeId() == QMetaType::Bool || value.typeId() == QMetaType::Int)
        query.bindValue(":val", QString::number(value.toInt()));
    else if(value.typeId() == QMetaType::QStringList)
        query.bindValue(":val", value.toStringList().join(":://::"));
    else if(value.typeId() == QMetaType::QPoint)
        query.bindValue(":val", QString("%1,%2").arg(value.toPoint().x()).arg(value.toPoint().y()));
    else if(value.typeId() == QMetaType::QPointF)
        query.bindValue(":val", QString("%1,%2").arg(value.toPointF().x()).arg(value.toPointF().y()));
    else if(value.typeId() == QMetaType::QSize)
        query.bindValue(":val", QString("%1,%2").arg(value.toSize().width()).arg(value.toSize().height()));
    else if(value.typeId() == QMetaType::QSizeF)
        query.bindValue(":val", QString("%1,%2").arg(value.toSizeF().width()).arg(value.toSizeF().height()));
    else if(value.canConvert<QJSValue>() && value.value<QJSValue>().isArray()) {
        QStringList ret;
        QJSValue val = value.value<QJSValue>();
        const int length = val.property("length").toInt();
        for(int i = 0; i < length; ++i)
            ret << val.property(i).toString();
        query.bindValue(":val", ret.join(":://::"));
    } else
        query.bindValue(":val", value.toString());
    query.bindValue(":name", key);

    // and update database
    if(!query.exec())
        qWarning() << "SQL Error:" << query.lastError().text();

    dbCommitTimer->start();

}

void PQCSettings::setDefault(bool ignoreLanguage) {

    if(readonly) return;

    backupDatabase();

    dbCommitTimer->stop();
    if(!dbIsTransaction) {
        db.transaction();
        dbIsTransaction = true;
    }

    for(const auto &table : qAsConst(dbtables)) {

        QSqlQuery query(db);

        if(ignoreLanguage)
            query.prepare(QString("UPDATE %1 SET value=defaultvalue WHERE name!='Language'").arg(table));
        else
            query.prepare(QString("UPDATE %1 SET value=defaultvalue").arg(table));

        if(!query.exec())
            qWarning() << "SQL Error:" << query.lastError().text();

    }

    QSqlQuery query(db);
    query.prepare("UPDATE general SET value=:ver WHERE name='Version'");
    query.bindValue(":ver", VERSION);
    if(!query.exec())
        qWarning() << "SQL Error:" << query.lastError().text();

    dbCommitTimer->start();

}

void PQCSettings::update(QString key, QVariant value) {
    (*this)[key] = value;
    saveChangedValue(key, value);
}

void PQCSettings::checkValidSlot() {

#ifndef NDEBUG

    for(const auto &key : this->keys()){

        if(!valid.contains(key))
            qWarning() << "INVALID KEY:" << key;

    }

#endif

}

void PQCSettings::closeDatabase() {

    dbCommitTimer->stop();

    if(dbIsTransaction) {
        db.commit();
        dbIsTransaction = false;
        if(db.lastError().text().trimmed().length())
            qWarning() << "ERROR committing database:" << db.lastError().text();
    }

    db.close();

}

void PQCSettings::reopenDatabase() {

    if(!db.open())
        qWarning() << "Unable to reopen database";

}
