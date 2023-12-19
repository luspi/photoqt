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
#include <qlogging.h>   // needed in this form to compile with Qt 6.2
#include <pqc_settings.h>
#include <pqc_configfiles.h>
#include <pqc_notify.h>

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
                             << "mapview"
                             << "export";

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

    if(PQCNotify::get().getStartupCheck() != 1 && PQCNotify::get().getStartupCheck() != 3)
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

    connect(&PQCNotify::get(), &PQCNotify::settingUpdateChanged, this, &PQCSettings::updateFromCommandLine);
    connect(&PQCNotify::get(), &PQCNotify::resetSettingsToDefault, this, &PQCSettings::resetToDefault);

}

PQCSettings::~PQCSettings() {
    delete dbCommitTimer;
#ifndef NDEBUG
    delete checkvalid;
#endif
}

void PQCSettings::readDB() {

    qDebug() << "";

#ifndef NDEBUG
    valid.clear();
#endif

    for(const auto &table : std::as_const(dbtables)) {

        QSqlQuery query(db);
        query.prepare(QString("SELECT `name`,`value`,`datatype` FROM '%1'").arg(table));
        if(!query.exec())
            qCritical() << QString("SQL Query error (%1):").arg(table) << query.lastError().text();

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

    qDebug() << "args: key =" << _key;
    qDebug() << "args: value =" << value;
    qDebug() << "readonly =" << readonly;

    if(readonly) return;

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

    qDebug() << "args: ignoreLanguage =" << ignoreLanguage;
    qDebug() << "readonly =" << readonly;

    if(readonly) return;

    backupDatabase();

    dbCommitTimer->stop();
    if(!dbIsTransaction) {
        db.transaction();
        dbIsTransaction = true;
    }

    for(const auto &table : std::as_const(dbtables)) {

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
    query.bindValue(":ver", PQMVERSION);
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

    qDebug() << "";

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

    qDebug() << "";

    if(!db.open())
        qWarning() << "Unable to reopen database";

}

bool PQCSettings::migrate(QString oldversion) {

    qDebug() << "args: oldversion =" << oldversion;

    QStringList versions;
    versions << "4.0";

    int iVersion = versions.length()-1;
    if(oldversion != "" && versions.contains(oldversion))
        iVersion = versions.indexOf(oldversion);

    dbCommitTimer->stop();

    if(dbIsTransaction) {
        db.commit();
        dbIsTransaction = false;
        if(db.lastError().text().trimmed().length())
            qWarning() << "ERROR committing database:" << db.lastError().text();
    }

    for(int iV = iVersion; iV < versions.length(); ++iV) {

        QString curVer = versions[iV];

        ////////////////////////////////////
        // first rename any tables

        // update to v4.0
        if(curVer == "4.0") {

            QSqlQuery query(db);
            if(!query.exec("ALTER TABLE 'openfile' RENAME TO 'filedialog'"))
                qCritical() << "ERROR renaming 'openfile' to 'filedialog':" << query.lastError().text();
            query.clear();

        }

        ////////////////////////////////////
        // first rename all settings

        QMap<QString,QStringList> rename;

        // update to v4.0
        if(curVer == "4.0") {

            rename ["ZoomLevel"] = QStringList() << "Zoom" << "filedialog";
            rename ["UserPlacesUser"] = QStringList() << "Places" << "filedialog";
            rename ["UserPlacesVolumes"] = QStringList() << "Devices" << "filedialog";
            rename ["UserPlacesWidth"] = QStringList() << "PlacesWidth" << "filedialog";
            rename ["DefaultView"] = QStringList() << "Layout" << "filedialog";
            rename ["PopoutFileSaveAs"] = QStringList() << "PopoutExport" << "interface";
            rename ["AdvancedSortExifDateCriteria"] = QStringList() << "AdvancedSortDateCriteria" << "imageview";
            rename ["PopoutSlideShowSettings"] = QStringList() << "PopoutSlideshowSetup" << "interface";
            rename ["PopoutSlideShowControls"] = QStringList() << "PopoutSlideshowControls" << "interface";

        }

        QMapIterator<QString, QStringList> i(rename);
        while(i.hasNext()) {
            i.next();

            QString oldname = i.key();
            QString newname = i.value().value(0);
            QString table = i.value().value(1);

            // delete old setting
            if(newname == "") {

                QSqlQuery query(db);
                query.prepare(QString("DELETE FROM '%1' WHERE name=:old").arg(table));
                query.bindValue(":old", oldname);
                if(!query.exec()) {
                    qWarning() << "Error removing old setting name (" << oldname << "): " << query.lastError().text();
                    query.clear();
                    continue;
                }
                query.clear();

                // rename old setting
            } else {

                // check if the new setting already exists or not
                QSqlQuery queryExist(db);
                queryExist.prepare(QString("SELECT COUNT(name) FROM `%1` WHERE name=:name").arg(table));
                queryExist.bindValue(":name", newname);
                if(!queryExist.exec()) {
                    qWarning() << "Unable to check if settings name already exists:" << queryExist.lastError().text();
                    queryExist.clear();
                    continue;
                }
                queryExist.next();
                const int oldVal = queryExist.value(0).toInt();

                if(oldVal == 0) {

                    QSqlQuery query(db);
                    query.prepare(QString("UPDATE '%1' SET name=:new WHERE name=:old").arg(table));
                    query.bindValue(":new", newname);
                    query.bindValue(":old", oldname);
                    if(!query.exec()) {
                        qWarning() << QString("Error updating setting name (%1 -> %2):").arg(oldname, newname) << query.lastError().text();
                        query.clear();
                        continue;
                    }
                    query.clear();

                }

            }
        }
    }

    // value changes

    // ZoomLevel -> Zoom: (val-9)*2.5
    QSqlQuery queryZoom(db);
    queryZoom.prepare("SELECT `value` from `filedialog` WHERE `name`='ZoomLevel'");
    if(!queryZoom.exec()) {
        qWarning() << "Unable to migrate ZoomLevel to Zoom:" << queryZoom.lastError().text();
        queryZoom.clear();
        return false;
    }
    if(queryZoom.next() ) {
        const int oldVal = queryZoom.value(0).toInt();
        queryZoom.clear();
        queryZoom.prepare("UPDATE `filedialog` SET `value`=:val WHERE `name`='Zoom'");
        queryZoom.bindValue(":val", static_cast<int>((oldVal-9)*2.5));
        if(!queryZoom.exec()) {
            qWarning() << "Unable to update Zoom value:" << queryZoom.lastError().text();
            queryZoom.clear();
            return false;
        }
    }
    queryZoom.clear();

    // AdvancedSortDateCriteria: remove every second entry (checked value)
    QSqlQuery querySort(db);
    querySort.prepare("SELECT `value` from `imageview` WHERE `name`='AdvancedSortDateCriteria'");
    if(!querySort.exec()) {
        qWarning() << "Unable to migrate AdvancedSortDateCriteria:" << querySort.lastError().text();
        querySort.clear();
        return false;
    }
    if(querySort.next()) {
        const QStringList oldSortVal = querySort.value(0).toString().split(":://::");
        QStringList newSortVal;
        for(const auto &v : oldSortVal) {
            if(v == "1" || v == "0")
                continue;
            newSortVal << v;
        }
        querySort.clear();
        querySort.prepare("UPDATE `imageview` SET `value`=:val WHERE `name`='AdvancedSortDateCriteria'");
        querySort.bindValue(":val", newSortVal.join(":://::"));
        if(!querySort.exec()) {
            qWarning() << "Unable to update AdvancedSortDateCriteria value:" << querySort.lastError().text();
            querySort.clear();
            return false;
        }
    }
    querySort.clear();

    return true;

}

QString PQCSettings::verifyNameAndGetType(QString name) {

    QString tablename = "";
    QString settingname = "";

    for(auto &t : std::as_const(dbtables)) {

        if(name.startsWith(t)) {
            tablename = t;
            break;
        }

    }

    // invalid table name
    if(tablename == "")
        return "";

    settingname = name.last(name.size()-tablename.size());

    QSqlQuery query(db);
    query.prepare(QString("SELECT datatype FROM `%1` WHERE `name`=:nme").arg(tablename));
    query.bindValue(":nme", settingname);
    if(!query.exec()) {
        qWarning() << "ERROR checking datatype for setting" << settingname;
        return "";
    }

    // invalid setting name
    if(!query.next())
        return "";

    QString ret = query.value(0).toString();
    query.clear();

    return ret;

}

void PQCSettings::updateFromCommandLine() {

    const QStringList update = PQCNotify::get().getSettingUpdate();
    qDebug() << "update =" << update;

    if(update.length() != 2)
        return;

    const QString key = update[0];
    const QString val = update[1];

    if(!this->contains(key))
        return;

    QString type = verifyNameAndGetType(key);
    if(type == "")
        return;

    if(type == "int")
        this->update(key, val.toInt());
    else if(type == "double")
        this->update(key, val.toDouble());
    else if(type == "bool") {
        if(val == "0" || val.toLower() == "false")
            this->update(key, false);
        else if(val == "1" || val.toLower() == "true")
            this->update(key, true);
    } else if(type == "list")
        this->update(key, val.split(":://::"));
    else if(type == "point") {
        QStringList parts = val.split(",");
        if(parts.length() == 2)
            this->update(key, QPoint(parts[0].toUInt(), parts[1].toUInt()));
    } else if(type == "size") {
        QStringList parts = val.split(",");
        if(parts.length() == 2)
            this->update(key, QSize(parts[0].toUInt(), parts[1].toUInt()));
    } else if(type == "string")
        this->update(key, val);

}

void PQCSettings::resetToDefault() {

    setDefault();
    readDB();

}
