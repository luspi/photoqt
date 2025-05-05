/**************************************************************************
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

#include <QJSValue>
#include <QMessageBox>
#include <qlogging.h>   // needed in this form to compile with Qt 6.2
#include <pqc_settings.h>
#include <pqc_configfiles.h>
#include <pqc_notify.h>
#include <pqc_extensionshandler.h>

PQCSettings::PQCSettings(QObject *parent) : QQmlPropertyMap(this, parent) {

    // create and connect to default database
    if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
        dbDefault = QSqlDatabase::addDatabase("QSQLITE3", "defaultsettings");
    else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
        dbDefault = QSqlDatabase::addDatabase("QSQLITE", "defaultsettings");
    QFile::remove(PQCConfigFiles::get().DEFAULTSETTINGS_DB());
    QFile::copy(":/defaultsettings.db", PQCConfigFiles::get().DEFAULTSETTINGS_DB());
    dbDefault.setDatabaseName(PQCConfigFiles::get().DEFAULTSETTINGS_DB());
    if(!dbDefault.open()) {
        qCritical() << "ERROR opening default database:" << (PQCConfigFiles::get().DEFAULTSETTINGS_DB());
        QMessageBox::critical(0, QCoreApplication::translate("PQSettings", "ERROR opening database with default settings"),
                              QCoreApplication::translate("PQSettings", "I tried hard, but I just cannot open the database of default settings.") + QCoreApplication::translate("PQSettings", "Something went terribly wrong somewhere!"));
        return;
    }

    // connect to user database
    if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
        db = QSqlDatabase::addDatabase("QSQLITE3", "settings");
    else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
        db = QSqlDatabase::addDatabase("QSQLITE", "settings");
    db.setDatabaseName(PQCConfigFiles::get().USERSETTINGS_DB());

    dbtables = QStringList() << "general"
                             << "interface"
                             << "imageview"
                             << "thumbnails"
                             << "mainmenu"
                             << "metadata"
                             << "filetypes"
                             << "filedialog"
                             << "slideshow"
                             << "mapview"
                             << "extensions";

    readonly = false;

    QFileInfo infodb(PQCConfigFiles::get().USERSETTINGS_DB());

    if(!infodb.exists() || !db.open()) {

        qWarning() << "ERROR opening database:" << db.lastError().text();
        qWarning() << "Will load read-only database of default settings";

        readonly = true;
        db.setConnectOptions("QSQLITE_OPEN_READONLY");

        QString tmppath = QStandardPaths::writableLocation(QStandardPaths::TempLocation)+"/usersettings.db";

        if(QFile::exists(tmppath))
            QFile::remove(tmppath);

        if(!QFile::copy(":/usersettings.db", tmppath)) {
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

    /*******************************************/
    // first enter all default values

    for(const auto &table : std::as_const(dbtables)) {

        QSqlQuery query(dbDefault);
        query.prepare(QString("SELECT `name`,`defaultvalue`,`datatype` FROM '%1'").arg(table));
        if(!query.exec())
            qCritical() << QString("SQL Query error (%1):").arg(table) << query.lastError().text();

        while(query.next()) {

            const QString name = QString("%1%2").arg(table, query.value(0).toString());
            const QString value = query.value(1).toString();
            const QString datatype = query.value(2).toString();

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
                    this->insert(name, QPoint(parts[0].toInt(), parts[1].toInt()));
                else {
                    qWarning() << QString("ERROR: invalid format of QPoint for setting '%1': '%2'").arg(name, value);
                    this->insert(name, QPoint(0,0));
                }
            } else if(datatype == "size") {
                const QStringList parts = value.split(",");
                if(parts.length() == 2)
                    this->insert(name, QSize(parts[0].toInt(), parts[1].toInt()));
                else {
                    qWarning() << QString("ERROR: invalid format of QSize for setting '%1': '%2'").arg(name, value);
                    this->insert(name, QSize(0,0));
                }
            } else if(datatype == "string")
                this->insert(name, value);
            else if(datatype != "")
                qCritical() << QString("ERROR: datatype not handled for setting '%1':").arg(name) << datatype;
            else
                qDebug() << QString("empty datatype found for setting '%1' -> ignoring").arg(name);

#ifndef NDEBUG
            valid.push_back(name);
#endif

        }

    }

    /*******************************************/
    // then update with user values (if changed)

    bool bakReadonly = readonly;
    readonly = true;

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
                this->updateWithoutNotification(name, value.toInt());
            else if(datatype == "double")
                this->updateWithoutNotification(name, value.toDouble());
            else if(datatype == "bool")
                this->updateWithoutNotification(name, static_cast<bool>(value.toInt()));
            else if(datatype == "list") {
                if(value.contains(":://::"))
                    this->updateWithoutNotification(name, value.split(":://::"));
                else if(value != "")
                    this->updateWithoutNotification(name, QStringList() << value);
                else
                    this->updateWithoutNotification(name, QStringList());
            } else if(datatype == "point") {
                const QStringList parts = value.split(",");
                if(parts.length() == 2)
                    this->updateWithoutNotification(name, QPoint(parts[0].toInt(), parts[1].toInt()));
                else {
                    qWarning() << QString("ERROR: invalid format of QPoint for setting '%1': '%2'").arg(name, value);
                    this->updateWithoutNotification(name, QPoint(0,0));
                }
            } else if(datatype == "size") {
                const QStringList parts = value.split(",");
                if(parts.length() == 2)
                    this->updateWithoutNotification(name, QSize(parts[0].toInt(), parts[1].toInt()));
                else {
                    qWarning() << QString("ERROR: invalid format of QSize for setting '%1': '%2'").arg(name, value);
                    this->updateWithoutNotification(name, QSize(0,0));
                }
            } else if(datatype == "string")
                this->updateWithoutNotification(name, value);
            else if(datatype != "")
                qCritical() << QString("ERROR: datatype not handled for setting '%1':").arg(name) << datatype;
            else
                qDebug() << QString("empty datatype found for setting '%1' -> ignoring").arg(name);

#ifndef NDEBUG
            if(table == "extensions")
                valid.push_back(name);
#endif

        }

    }

    readonly = bakReadonly;

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
    if(QFile::exists(QString("%1.bak").arg(PQCConfigFiles::get().USERSETTINGS_DB())))
        QFile::remove(QString("%1.bak").arg(PQCConfigFiles::get().USERSETTINGS_DB()));
    QFile file(PQCConfigFiles::get().USERSETTINGS_DB());
    return file.copy(QString("%1.bak").arg(PQCConfigFiles::get().USERSETTINGS_DB()));

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

void PQCSettings::setDefault() {

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
        if(!query.exec(QString("DELETE FROM '%1'").arg(table)))
            qWarning() << "SQL Error:" << query.lastError().text();

    }

    setupFresh();

}

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

void PQCSettings::setDefaultFor(QString key) {

    qDebug() << "args: key =" << key;
    qDebug() << "readonly =" << readonly;

    if(readonly) return;

    QVariantList def = getDefaultFor(key);

    QString value = def[0].toString();
    QString datatype = def[1].toString();

    if(datatype == "int")
        this->update(key, value.toInt());
    else if(datatype == "double")
        this->update(key, value.toDouble());
    else if(datatype == "bool")
        this->update(key, static_cast<bool>(value.toInt()));
    else if(datatype == "list") {
        if(value.contains(":://::"))
            this->update(key, value.split(":://::"));
        else if(value != "")
            this->update(key, QStringList() << value);
        else
            this->update(key, QStringList());
    } else if(datatype == "point") {
        const QStringList parts = value.split(",");
        if(parts.length() == 2)
            this->update(key, QPoint(parts[0].toInt(), parts[1].toInt()));
        else {
            qWarning() << QString("ERROR: invalid format of QPoint for setting '%1': '%2'").arg(key, value);
            this->update(key, QPoint(0,0));
        }
    } else if(datatype == "size") {
        const QStringList parts = value.split(",");
        if(parts.length() == 2)
            this->update(key, QSize(parts[0].toInt(), parts[1].toInt()));
        else {
            qWarning() << QString("ERROR: invalid format of QSize for setting '%1': '%2'").arg(key, value);
            this->update(key, QSize(0,0));
        }
    } else if(datatype == "string")
        this->update(key, value);

}

void PQCSettings::updateWithoutNotification(QString key, QVariant value) {
    (*this)[key] = value;
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

// return codes:
// -1 := error
//  0 := success
//  1 := old, don't migrate, need to setup fresh
int PQCSettings::migrate(QString oldversion) {

    qDebug() << "args: oldversion =" << oldversion;

    dbCommitTimer->stop();

    if(dbIsTransaction) {
        db.commit();
        dbIsTransaction = false;
        if(db.lastError().text().trimmed().length())
            qWarning() << "ERROR committing database:" << db.lastError().text();
    }

    db.transaction();

    if(oldversion == "") {
        // first we need to find the version in a database that has not yet been read
        QSqlQuery query(db);
        if(!query.exec("SELECT `value` FROM general WHERE `name`='Version'")) {
            qCritical() << "Unable to find previous version number:" << query.lastError().text();
        } else {
            query.next();
            oldversion = query.value(0).toString();
            qDebug() << "migrating from version" << oldversion << "to" << PQMVERSION;
        }
        query.clear();
    }

    // in this case we stop and return 1 meaning that we should simply set up fresh
    if(oldversion.startsWith("2") || oldversion.startsWith("1")) {
        return 1;
    }

    /*************************************************************************/
    /**************************** IMPORTANT NOTE *****************************/
    /*************************************************************************/
    //                                                                       //
    // BEFORE EVERY NEW RELEASE THE NEW VERSION NUMBER HAS TO BE ADDED BELOW //
    //                                                                       //
    // and the same needs to be done in pqc_shortcuts.cpp:migrate()          //
    /*************************************************************************/

    QStringList versions;
    versions << "4.0" << "4.1" << "4.2" << "4.3" << "4.4" << "4.5" << "4.6" << "4.7" << "4.8" << "4.8.1" << "4.9" << "4.9.1";
    // when removing the 'dev' value, check below for any if statement involving 'dev'!

    // this is a safety check to make sure we don't forget the above check
    if(oldversion != "dev" && versions.indexOf(oldversion) == -1 && !oldversion.startsWith("3")) {
        qCritical() << "WARNING: The current version number needs to be added to the migrate() functions";
    }

    int iVersion = 0;
    if(oldversion == "dev")
        iVersion = versions.length()-1;
    else if(oldversion != "" && versions.contains(oldversion))
        // we do a +1 as we are on the found version and don't need to migrate to it
        iVersion = versions.indexOf(oldversion)+1;

    // we iterate through all migrations one by one

    for(int iV = iVersion; iV < versions.length(); ++iV) {

        QString curVer = versions[iV];

        ////////////////////////////////////
        // first do any more complicated migrations

        // update to v4.0
        if(curVer == "4.0") {

            /******************************************************/
            // change table name 'openfile' to 'filedialog'

            QSqlQuery query(db);

            if(!query.exec("SELECT COUNT(name) FROM sqlite_master WHERE type='table' AND name='filedialog'"))
                qCritical() << "Unable to check if table named 'filedialog' exists:" << query.lastError().text();
            else {

                query.next();
                if(query.value(0).toInt() == 0) {

                    QSqlQuery queryUpdate(db);
                    if(!queryUpdate.exec("ALTER TABLE 'openfile' RENAME TO 'filedialog'"))
                        qCritical() << "ERROR renaming 'openfile' to 'filedialog':" << queryUpdate.lastError().text();
                    queryUpdate.clear();

                }

                query.clear();

            }

            /******************************************************/
            // adjust ZoomLevel value

            QVariant oldValue = migrationHelperGetOldValue("filedialog", "ZoomLevel");
            if(oldValue.isValid() && !oldValue.isNull()) {
                migrationHelperSetNewValue("filedialog", "Zoom", (oldValue.toInt()-9)*2.5);
                migrationHelperRemoveValue("filedialog", "ZoomLevel");
            }

            /******************************************************/
            // adjust list for AdvancedSortDateCriteria

            QVariant oldSort = migrationHelperGetOldValue("imageview", "AdvancedSortDateCriteria");
            if(oldSort.isValid() && !oldSort.isNull()) {
                const QStringList oldSortVal = oldSort.toString().split(":://::");
                QStringList newSortVal;
                for(const auto &v : oldSortVal) {
                    if(v == "1" || v == "0")
                        continue;
                    newSortVal << v;
                }
                migrationHelperSetNewValue("imageview", "AdvancedSortDateCriteria", newSortVal);
            }

        } else if(curVer == "4.4") {

            /******************************************************/
            // adjust value of 'PreviewColorIntensity' in 'filedialog'

            QVariant oldValue = migrationHelperGetOldValue("filedialog", "PreviewColorIntensity");
            if(!oldValue.isNull() && oldValue.isValid()) {
                int val = oldValue.toInt();
                if(val <= 10)
                    migrationHelperSetNewValue("filedialog", "PreviewColorIntensity", 10*val);
            }

        } else if(curVer == "4.7") {

            /******************************************************/
            // convert color names

            QString oldValue = migrationHelperGetOldValue("interface", "AccentColor").toString();

            QMap<QString,QString> mapping;
            mapping.insert("gray",   "#222222");
            mapping.insert("red",    "#110505");
            mapping.insert("green" , "#051105");
            mapping.insert("blue",   "#050b11");
            mapping.insert("purple", "#0b0211");
            mapping.insert("orange", "#110b02");
            mapping.insert("pink",   "#110511");

            if(mapping.contains(oldValue))
                migrationHelperSetNewValue("interface", "AccentColor", mapping.value(oldValue));

            /******************************************************/
            // make sure cache is set to at least 256

            QVariant oldCache = migrationHelperGetOldValue("imageview", "Cache");
            if(oldCache.isValid() && !oldCache.isNull() && oldCache.toInt() < 256)
                migrationHelperSetNewValue("interface", "AccentColor", 256);

        } else if(curVer == "4.8") {

            migrationHelperSetNewValue("imageview", "ZoomToCenter", 0);

        } else if(curVer == "4.9") {

            // first make sure all tables have UNIQUE constraint set for name column
            // it is not possible to add such a constraint to an existing table in sqlite
            // Thus we first create a new table with the proper structure, then copy all data
            // over, delete the old table, and then rename the new table to the old name.

            const QStringList tbls = {"filedialog", "filetypes", "general", "imageview", "interface",
                                      "mainmenu", "mapview", "metadata", "slideshow", "thumbnails"};

            for(const QString &t : tbls) {

                QSqlQuery queryUnq(db);

                if(!queryUnq.exec(QString("CREATE TABLE '%1_new' ('name' TEXT UNIQUE, 'value' TEXT, 'datatype' TEXT)").arg(t))) {
                    qWarning() << "ERROR: Unable to create new table:" << t;
                    qWarning() << "SQL error:" << queryUnq.lastError().text();
                    qWarning() << "SQL query:" << queryUnq.lastQuery();
                    queryUnq.clear();
                    continue;
                }

                queryUnq.clear();

                if(!queryUnq.exec(QString("INSERT INTO `%1_new` (`name`,`value`,`datatype`) SELECT `name`,`value`,`datatype` FROM `%2`").arg(t,t))) {
                    qWarning() << "ERROR copying over data for table:" << t;
                    qWarning() << "SQL error:" << queryUnq.lastError().text();
                    qWarning() << "SQL query:" << queryUnq.lastQuery();
                    continue;
                }

                queryUnq.clear();

                if(!queryUnq.exec(QString("DROP TABLE `%1`").arg(t))) {
                    qWarning() << "ERROR: Unable to drop old table:" << t;
                    qWarning() << "SQL error:" << queryUnq.lastError().text();
                    qWarning() << "SQL query:" << queryUnq.lastQuery();
                    continue;
                }

                queryUnq.clear();

                if(!queryUnq.exec(QString("ALTER TABLE `%1_new` RENAME TO `%2`").arg(t, t))) {
                    qWarning() << "ERROR: Unable to rename new table:" << t;
                    qWarning() << "SQL error:" << queryUnq.lastError().text();
                    qWarning() << "SQL query:" << queryUnq.lastQuery();
                    continue;
                }

                queryUnq.clear();

            }

            // Update settings names

            QVariant oldDup = migrationHelperGetOldValue("interface", "WindowButtonsDuplicateDecorationButtons");

            QString newValue = "ontop_0|0|1:://::fullscreen_0|0|1";
            if(oldDup.isValid() && !oldDup.isNull() && oldDup.toInt() == 1)
                newValue = "ontop_0|1|1:://::minimize_0|1|1:://::maximize_0|1|1:://::fullscreen_0|0|1:://::close_0|0|1";

            QVariant oldNav = migrationHelperGetOldValue("interface", "NavigationTopRight");
            QVariant oldNavAlw = migrationHelperGetOldValue("interface", "NavigationTopRightAlways");
            QVariant oldNavPos = migrationHelperGetOldValue("interface", "NavigationTopRightLeftRight");

            if(oldNav.isValid() && oldNav.toInt() == 1) {
                if(oldNavPos.isValid() && oldNavPos.toString() == "right") {
                    if(oldNavAlw.isValid() && oldNavAlw.toInt() == 1)
                        newValue = QString("%1:://::left_0|0|0:://::right_0|0|0:://::menu_0|0|0").arg(newValue);
                    else
                        newValue = QString("%1:://::left_1|0|0:://::right_1|0|0:://::menu_1|0|0").arg(newValue);
                } else {
                    if(oldNavAlw.isValid() && oldNavAlw.toInt() == 1)
                        newValue = QString("left_0|0|0:://::right_0|0|0:://::menu_0|0|0:://::%1").arg(newValue);
                    else
                        newValue = QString("left_1|0|0:://::right_1|0|0:://::menu_1|0|0:://::%1").arg(newValue);
                }
            }

            migrationHelperInsertValue("interface", "WindowButtonsItems",
                                       {newValue, "left_0|0|0:://::right_0|0|0:://::menu_0|0|0:://::ontop_0|0|1:://::fullscreen_0|0|1", "list"});

            migrationHelperRemoveValue("interface", "WindowButtonsDuplicateDecorationButtons");
            migrationHelperRemoveValue("interface", "NavigationTopRight");
            migrationHelperRemoveValue("interface", "NavigationTopRightAlways");
            migrationHelperRemoveValue("interface", "NavigationTopRightLeftRight");

            QString oldLayout = migrationHelperGetOldValue("filedialog", "Layout").toString();
            if(oldLayout == "icons")
                migrationHelperSetNewValue("filedialog", "Layout", "grid");

        } else if(curVer == "4.9.1") {

            // a bug in 4.9.1 might have reduced the thumbnails size down to 1px
            int oldVal = migrationHelperGetOldValue("thumbnails", "Size").toInt();
            if(oldVal < 32)
                migrationHelperSetNewValue("thumbnails", "Size", 32);

        }

        ////////////////////////////////////
        // then rename any settings

        QMap<QString, QList<QStringList> > migrateNames = {
            {"4.0", {{"ZoomLevel", "filedialog", "Zoom", "filedialog"},
                     {"UserPlacesUser", "filedialog", "Places", "filedialog"},
                     {"UserPlacesVolumes", "filedialog", "Devices", "filedialog"},
                     {"UserPlacesWidth", "filedialog", "PlacesWidth", "filedialog"},
                     {"DefaultView", "filedialog", "Layout", "filedialog"},
                     {"PopoutFileSaveAs", "interface", "PopoutExport", "interface"},
                     {"AdvancedSortExifDateCriteria", "imageview", "AdvancedSortDateCriteria", "imageview"},
                     {"PopoutSlideShowSettings", "imageview", "PopoutSlideshowSetup", "interface"},
                     {"PopoutSlideShowControls", "imageview", "PopoutSlideshowControls", "interface"}}},
            {"4.5", {{"MusicFile", "slideshow", "MusicFiles", "slideshow"},
                     {"PopoutFileDialogKeepOpen", "interface", "PopoutFileDialogNonModal", "interface"},
                     {"PopoutMapExplorerKeepOpen", "interface", "PopoutMapExplorerNonModal", "interface"},
                     {"CheckForPhotoSphere", "filetypes", "PhotoSphereAutoLoad", "filetypes"}}},
            {"4.9", {{"InterpolationThreshold", "imageview", "", ""}}}
        };

        migrationHelperChangeSettingsName(migrateNames, curVer);


        ///////////////////////////////////////////////////////////
        ///////////////////////////////////////////////////////////
        ///////////////////////////////////////////////////////////
        /// EXTENSIONS

        /////////////////////////////////////////////////////
        // make sure extensions table exists

        QSqlQuery queryTabIns(db);
        if(!queryTabIns.exec("CREATE TABLE IF NOT EXISTS extensions ('name' TEXT UNIQUE, 'value' TEXT, 'datatype' TEXT)"))
            qWarning() << "ERROR adding missing table extensions:" << queryTabIns.lastError().text();
        queryTabIns.clear();

        /////////////////////////////////////////////////////
        // check for migrations for extensions

        const QStringList ext = PQCExtensionsHandler::get().getExtensions();
        for(const QString &e : ext)
            migrationHelperChangeSettingsName(PQCExtensionsHandler::get().getMigrateSettings(e), curVer);

        /////////////////////////////////////////////////////
        // check for existence of settings for extensions

        // ext is already defined ahead of the for loop above
        for(const QString &e : ext) {

            const QList<QStringList> set = PQCExtensionsHandler::get().getSettings(e);

            qDebug() << QString("Entering settings for extension %1:").arg(e) << set;

            for(const QStringList &entry : set) {

                if(entry.length() != 4) {
                    qWarning() << "Wrong settings value length of" << entry.length();
                    qWarning() << "Faulty settings entry:" << entry;
                    continue;
                }

                QSqlQuery query(db);
                query.prepare(QString("INSERT OR IGNORE INTO '%1' (`name`, `value`, `datatype`) VALUES (:nme, :val, :dat)").arg(entry[1]));
                query.bindValue(":nme", entry[0]);
                query.bindValue(":val", entry[3]);
                query.bindValue(":dat", entry[2]);
                if(!query.exec()) {
                    qWarning() << "ERROR: Failed to enter required setting for extension" << e << ":" << query.lastError().text();
                    continue;
                }

                query.clear();

            }

        }

        /// END EXTENSIONS
        ///////////////////////////////////////////////////////////
        ///////////////////////////////////////////////////////////
        ///////////////////////////////////////////////////////////

    }

    db.commit();

    return 0;

}

void PQCSettings::migrationHelperChangeSettingsName(QMap<QString, QList<QStringList> > mig, QString curVer) {

    qDebug() << "args: mig =" << mig;
    qDebug() << "args: curVer =" << curVer;

    for(auto i = mig.cbegin(), end = mig.cend(); i != end; ++i) {

        const QString v = i.key();
        if(v == curVer) {

            const QList<QStringList> vals = i.value();
            for(const QStringList &entry : vals) {

                if(entry.length() != 4) {
                    qWarning() << "Invalid settings migration:" << entry;
                    continue;
                }

                // special case: delete table
                if(entry[0] == "" && entry[2] == "" && entry[3] == "") {
                    QSqlQuery query(db);
                    query.prepare(QString("DROP TABLE IF EXISTS `%1`").arg(entry[1]));
                    if(!query.exec()) {
                        qWarning() << "ERROR: Failed to drop table:" << entry[1];
                    }
                    continue;
                }

                // check if old table still exists
                QSqlQuery queryTableOld(db);
                if(!queryTableOld.exec(QString("SELECT COUNT(name) FROM sqlite_master WHERE type='table' AND name='%1'").arg(entry[1]))) {
                    qCritical() << "Unable to check if table named " << entry[1] << " exists:" << queryTableOld.lastError().text();
                    continue;
                } else {
                    queryTableOld.next();
                    if(queryTableOld.value(0).toInt() == 0) {
                        qDebug() << "Old table" << entry[1] << "no longer exists - was it migrated away already?";
                        continue;
                    }
                }

                QSqlQuery query(db);

                // check old key exists
                // if not then no migration needs to be done
                // we check for existence of all settings later
                query.prepare(QString("SELECT `value`,`datatype` FROM '%1' WHERE `name`=:nme").arg(entry[1]));
                query.bindValue(":nme", entry[0]);
                if(!query.exec()) {
                    qWarning() << "Query failed to execute:" << query.lastError().text();
                    continue;
                }

                // read data if an entry was found (due to unique constraint this is either zero or one)
                bool foundEntry = false;
                QString old_value = "";
                QString old_datatype = "";
                if(query.next()) {
                    foundEntry = true;
                    old_value = query.value(0).toString();
                    old_datatype = query.value(1).toString();
                }
                query.clear();

                // found an old entry
                if(foundEntry) {

                    // If there is a new entry to be added
                    if(entry[2] != "") {

                        QSqlQuery query2(db);
                        // enter new values if they don't exist already
                        query2.prepare(QString("INSERT INTO %1 (`name`,`value`,`datatype`) VALUES (:nme, :val, :dat) ON CONFLICT(`name`) DO UPDATE SET `value`=:val2,`datatype`=:dat2").arg(entry[3]));
                        query2.bindValue(":nme", entry[2]);
                        query2.bindValue(":val", old_value);
                        query2.bindValue(":dat", old_datatype);
                        query2.bindValue(":val2", old_value);
                        query2.bindValue(":dat2", old_datatype);
                        if(!query2.exec()) {
                            qWarning() << "Unable to migrate setting:" << query2.lastError().text();
                            qWarning() << "Failed query:" << query2.lastQuery();
                            qWarning() << "Failed migration:" << entry << "//" << old_value << "/" << old_datatype;
                            continue;
                        }

                        query2.clear();

                    }

                    // delete old entry
                    query.prepare(QString("DELETE FROM '%1' WHERE `name`=:nme").arg(entry[1]));
                    query.bindValue(":nme", entry[0]);
                    if(!query.exec()) {
                        qWarning() << "Failed to delete old entry:" << query.lastError().text();
                        qWarning() << "Failed migration:" << entry;
                    }

                    query.clear();

                }

            }

            break;

        }

    }

}

QVariant PQCSettings::migrationHelperGetOldValue(QString table, QString setting) {

    qDebug() << "args: table =" << table;
    qDebug() << "args: setting =" << setting;

    QSqlQuery query(db);

    query.prepare(QString("SELECT `value` FROM `%1` WHERE `name`=:nme").arg(table));
    query.bindValue(":nme", setting);

    if(!query.exec())
        qCritical() << "Unable to get current" << setting << "value:" << query.lastError().text();
    else {

        if(query.next())
            return query.value(0);

    }

    return QVariant();

}

void PQCSettings::migrationHelperRemoveValue(QString table, QString setting) {

    qDebug() << "args: table =" << table;
    qDebug() << "args: setting =" << setting;

    QSqlQuery query(db);

    query.prepare(QString("DELETE FROM `%1` WHERE `name`=:nme").arg(table));
    query.bindValue(":nme", setting);
    if(!query.exec()) {
        qWarning() << "Failed to delete old entry:" << query.lastError().text();
        qWarning() << "Failed migration:" << setting;
    }

    query.clear();

}

void PQCSettings::migrationHelperInsertValue(QString table, QString setting, QVariantList value) {

    qDebug() << "args: table =" << table;
    qDebug() << "args: setting =" << setting;
    qDebug() << "args: value =" << value;

    QSqlQuery query(db);

    query.prepare(QString("INSERT OR IGNORE INTO `%1` (`name`,`value`,`datatype`) VALUES (:nme, :val, :dat)").arg(table));
    query.bindValue(":nme", setting);
    query.bindValue(":val", value[0]);
    query.bindValue(":dat", value[2]);
    if(!query.exec()) {
        qWarning() << "Failed to insert new entry:" << query.lastError().text();
        qWarning() << "Failed setting:" << setting;
    }

    query.clear();

}

void PQCSettings::migrationHelperSetNewValue(QString table, QString setting, QVariant value) {

    qDebug() << "args: table =" << table;
    qDebug() << "args: setting =" << setting;
    qDebug() << "args: value =" << value;

    QSqlQuery query(db);
    query.prepare(QString("UPDATE `%1` SET `value`=:val WHERE `name`=:nme").arg(table));
    query.bindValue(":nme", setting);
    query.bindValue(":val", value);
    if(!query.exec())
        qCritical() << "ERROR updating" << setting << "value:" << query.lastError().text();
    query.clear();

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
            this->update(key, QPoint(parts[0].toInt(), parts[1].toInt()));
    } else if(type == "size") {
        QStringList parts = val.split(",");
        if(parts.length() == 2)
            this->update(key, QSize(parts[0].toInt(), parts[1].toInt()));
    } else if(type == "string")
        this->update(key, val);

}

void PQCSettings::setupFresh() {

    qDebug() << "";

    // at this point we can assume that the settings.db has already been copied
    // we only need to add any setting from the extensions

    dbCommitTimer->stop();
    if(!dbIsTransaction)
        db.transaction();

    const QStringList allext = PQCExtensionsHandler::get().getExtensions();
    for(const QString &ext : allext) {

        const QList<QStringList> settings = PQCExtensionsHandler::get().getSettings(ext);

        for(const QStringList &set : settings) {

            if(set.length() != 4) {
                qWarning() << "Invalid settings detected:" << set;
                continue;
            }

            QSqlQuery query(db);
            query.prepare(QString("INSERT OR IGNORE INTO `%1` (`name`, `value`, `datatype`) VALUES (:nme, :val, :dat)").arg(set[1]));
            query.bindValue(":nme", set[0]);
            query.bindValue(":val", set[3]);
            query.bindValue(":dat", set[2]);

            if(!query.exec()) {
                qWarning() << "ERROR inserting setting:" << query.lastError().text();
                qWarning() << "Faulty setting:" << set;
            }

            query.clear();

        }

    }

    QSqlQuery query(db);
    query.prepare("INSERT OR IGNORE INTO general (`name`, `value`, `datatype`) VALUES ('Version', :ver, 'string')");
    query.bindValue(":ver", PQMVERSION);
    if(!query.exec()) {
        qWarning() << "ERROR setting current version number:" << query.lastError().text();
    }

    db.commit();
    dbIsTransaction = false;

    readDB();

#ifdef Q_OS_WIN
    // these defaults are different on Windows as on Linux
    update("filedialogDevices", true);
#endif

    // the window decoration on Gnome is a bit weird
    // that's why we disable it by default
    if(qgetenv("XDG_CURRENT_DESKTOP").contains("GNOME"))
        update("interfaceWindowDecoration", false);

}

void PQCSettings::resetToDefault() {

    setDefault();
    readDB();

}
