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

 /* auto-generated using generatesettings.py */

#include "settings.h"
#include <QJSValue>
//#include "../startup/settings.h"

PQSettings::PQSettings() {

    db = QSqlDatabase::database("settings");

    dbtables = QStringList() << "general"
                             << "interface"
                             << "imageview"
                             << "thumbnails"
                             << "mainmenu"
                             << "metadata"
                             << "filetypes"
                             << "openfile"
                             << "slideshow"
                             << "histogram";

    readonly = false;

    QFileInfo infodb(ConfigFiles::SETTINGS_DB());

    if(!infodb.exists() || !db.open()) {

        LOG << CURDATE << "PQSettings::PQSettings(): ERROR opening database: " << db.lastError().text().trimmed().toStdString() << NL;
        LOG << CURDATE << "PQSettings::PQSettings(): Will load read-only database of default settings" << NL;

        readonly = true;
        db.setConnectOptions("QSQLITE_OPEN_READONLY");

        QString tmppath = QStandardPaths::writableLocation(QStandardPaths::TempLocation)+"/settings.db";

        if(QFile::exists(tmppath))
            QFile::remove(tmppath);

        if(!QFile::copy(":/settings.db", tmppath)) {
            LOG << CURDATE << "PQSettings::PQSettings(): ERROR copying read-only default database!" << NL;
            //: This is the window title of an error message box
            QMessageBox::critical(0, QCoreApplication::translate("PQSettings", "ERROR getting database with default settings"),
                                     QCoreApplication::translate("PQSettings", "I tried hard, but I just cannot open even a read-only version of the settings database.") + QCoreApplication::translate("PQSettings", "Something went terribly wrong somewhere!"));
            return;
        }

        QFile f(tmppath);
        f.setPermissions(f.permissions()|QFileDevice::WriteOwner);

        db.setDatabaseName(tmppath);

        if(!db.open()) {
            LOG << CURDATE << "PQSettings::PQSettings(): ERROR opening read-only default database!" << NL;
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
            LOG << "PQSettings::commitDB: ERROR committing database: "
                << db.lastError().text().trimmed().toStdString()
                << NL;
    });

    // if a value is changed in the ui, write to database
    connect(this, &QQmlPropertyMap::valueChanged, this, &PQSettings::saveChangedValue);

#ifndef NDEBUG
    checkvalid = new QTimer;
    checkvalid->setInterval(1000);
    checkvalid->setSingleShot(false);
    connect(checkvalid, &QTimer::timeout, this, &PQSettings::checkValidSlot);
    checkvalid->start();
#endif

}

PQSettings::~PQSettings() {
    delete dbCommitTimer;
#ifndef NDEBUG
    delete checkvalid;
#endif
}

void PQSettings::readDB() {

#ifndef NDEBUG
    valid.clear();
#endif

    for(const auto &table : qAsConst(dbtables)) {

        QSqlQuery query(db);
        query.prepare(QString("SELECT name,value,datatype FROM %1").arg(table));
        if(!query.exec())
            LOG << CURDATE << "PQSettings::readDB(): SQL Query error: " << query.lastError().text().trimmed().toStdString() << NL;

        while(query.next()) {

            QString name = QString("%1%2").arg(table).arg(query.value(0).toString());
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
                    LOG << CURDATE << "PQSettings::readDB(): ERROR: invalid format of QPoint for setting '" << name.toStdString() << "': '" << value.toStdString() << "'" << NL;
                    this->insert(name, QPoint(0,0));
                }
            } else if(datatype == "size") {
                const QStringList parts = value.split(",");
                if(parts.length() == 2)
                    this->insert(name, QSize(parts[0].toUInt(), parts[1].toInt()));
                else {
                    LOG << CURDATE << "PQSettings::readDB(): ERROR: invalid format of QSize for setting '" << name.toStdString() << "': '" << value.toStdString() << "'" << NL;
                    this->insert(name, QSize(0,0));
                }
            } else if(datatype == "string")
                this->insert(name, value);
            else
                LOG << CURDATE << "PQSettings::readDB(): ERROR: datatype not handled for setting '" << name.toStdString() << "': " << datatype.toStdString() << NL;

#ifndef NDEBUG
            valid.push_back(name);
#endif

        }

    }

}

bool PQSettings::backupDatabase() {

    // make sure all changes are written to db
    if(dbIsTransaction) {
        dbCommitTimer->stop();
        db.commit();
        dbIsTransaction = false;
        if(db.lastError().text().trimmed().length())
            LOG << "PQSettings::commitDB: ERROR committing database: " << db.lastError().text().trimmed().toStdString() << NL;
    }

    // backup file
    if(QFile::exists(QString("%1.bak").arg(ConfigFiles::SETTINGS_DB())))
        QFile::remove(QString("%1.bak").arg(ConfigFiles::SETTINGS_DB()));
    QFile file(ConfigFiles::SETTINGS_DB());
    return file.copy(QString("%1.bak").arg(ConfigFiles::SETTINGS_DB()));

}

void PQSettings::saveChangedValue(const QString &_key, const QVariant &value) {

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
        LOG << CURDATE << "PQSettings::saveChangedValue(): ERROR: invalid category received: " << key.toStdString() << NL;
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
    if(value.type() == QVariant::Bool || value.type() == QVariant::Int)
        query.bindValue(":val", QString::number(value.toInt()));
    else if(value.type() == QVariant::StringList)
        query.bindValue(":val", value.toStringList().join(":://::"));
    else if(value.type() == QVariant::Point || value.type() == QVariant::PointF) {
        query.bindValue(":val", QString("%1,%2").arg(value.toPoint().x()).arg(value.toPoint().y()));
    } else if(value.type() == QVariant::Size || value.type() == QVariant::SizeF)
        query.bindValue(":val", QString("%1,%2").arg(value.toSize().width()).arg(value.toSize().height()));
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
        LOG << CURDATE << "PQSettings::saveChangedValue(): SQL Error: " << query.lastError().text().trimmed().toStdString() << NL;

    dbCommitTimer->start();

}

void PQSettings::setDefault(bool ignoreLanguage) {

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
            LOG << CURDATE << "PQSettings::setDefault(): SQL Error: " << query.lastError().text().trimmed().toStdString() << NL;

    }

    QSqlQuery query(db);
    query.prepare("UPDATE general SET value=:ver WHERE name='Version'");
    query.bindValue(":ver", VERSION);
    if(!query.exec())
        LOG << CURDATE << "PQSettings::setDefault() (version): SQL Error: " << query.lastError().text().trimmed().toStdString() << NL;

    dbCommitTimer->start();

}

void PQSettings::update(QString key, QVariant value) {
    (*this)[key] = value;
    saveChangedValue(key, value);
}

void PQSettings::checkValidSlot() {

#ifndef NDEBUG

    for(const auto &key : this->keys()){

        if(!valid.contains(key))
            LOG << CURDATE << "PQSettings::checkValidSlot(): INVALID KEY: " << key.toStdString() << NL;

    }

#endif

}
