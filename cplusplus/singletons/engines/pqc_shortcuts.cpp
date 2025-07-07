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
#include <QTimer>
#include <QMessageBox>
#include <QFileInfo>
#include <QtSql/QSqlError>
#include <QtSql/QSqlQuery>
#include <QCoreApplication>
#include <pqc_shortcuts.h>
#include <pqc_configfiles.h>
#include <pqc_notify.h>
#include <pqc_extensionshandler.h>

PQCShortcuts::PQCShortcuts() {

    // connect to database
    if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
        db = QSqlDatabase::addDatabase("QSQLITE3", "shortcuts");
    else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
        db = QSqlDatabase::addDatabase("QSQLITE", "shortcuts");

    readonly = false;

    QFileInfo infodb(PQCConfigFiles::get().SHORTCUTS_DB());

    bool enterExtensions = false;

    // the db does not exist -> create it
    if(!infodb.exists()) {
        if(!QFile::copy(":/shortcuts.db", PQCConfigFiles::get().SHORTCUTS_DB()))
            qWarning() << "Unable to (re-)create default shortcuts database";
        else {
            QFile file(PQCConfigFiles::get().SHORTCUTS_DB());
            file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
            enterExtensions = true;
        }
    }

    db.setDatabaseName(PQCConfigFiles::get().SHORTCUTS_DB());

    if(!db.open()) {

        qCritical() << "ERROR opening database:" << db.lastError().text();
        qCritical() << "Will load read-only database of default shortcuts";

        readonly = true;
        db.setConnectOptions("QSQLITE_OPEN_READONLY");

        QString tmppath = QStandardPaths::writableLocation(QStandardPaths::TempLocation)+"/shortcuts.db";

        if(QFile::exists(tmppath))
            QFile::remove(tmppath);

        if(!QFile::copy(":/shortcuts.db", tmppath)) {
            qCritical() << "ERROR copying read-only default database!";
            //: This is the window title of an error message box
            QMessageBox::critical(0, QCoreApplication::translate("PQShortcuts", "ERROR getting database with default shortcuts"),
                                     QCoreApplication::translate("PQShortcuts", "I tried hard, but I just cannot open even a read-only version of the shortcuts database.") + QCoreApplication::translate("PQShortcuts", "Something went terribly wrong somewhere!"));
            return;
        }

        QFile f(tmppath);
        f.setPermissions(f.permissions()|QFileDevice::WriteOwner);

        db.setDatabaseName(tmppath);

        if(!db.open()) {
            qCritical() << "ERROR opening read-only default database!";
            QMessageBox::critical(0, QCoreApplication::translate("PQShortcuts", "ERROR opening database with default settings"),
                                     QCoreApplication::translate("PQShortcuts", "I tried hard, but I just cannot open the database of default shortcuts.") + QCoreApplication::translate("PQShortcuts", "Something went terribly wrong somewhere!"));
            return;
        }

    } else {

        readonly = false;
        if(!infodb.permission(QFileDevice::WriteOwner))
            readonly = true;

    }

    dbCommitTimer = new QTimer();
    dbCommitTimer->setSingleShot(true);
    dbCommitTimer->setInterval(400);
    connect(dbCommitTimer, &QTimer::timeout, this, [=](){
        db.commit();
        dbIsTransaction = false;
        if(db.lastError().text().trimmed().length())
            qCritical() << "ERROR committing database:" << db.lastError().text();
    });

    connect(&PQCNotify::get(), &PQCNotify::resetShortcutsToDefault, this, &PQCShortcuts::resetToDefault);

    // on updates we call migrate() which calls readDB() itself.
    if(enterExtensions)
        setupFresh();
    else if(checkForUpdateOrNew() != 1)
        readDB();

}

PQCShortcuts::~PQCShortcuts() {
    if(dbCommitTimer != nullptr) {
        delete dbCommitTimer;
    }
}

int PQCShortcuts::checkForUpdateOrNew() {

    // 0 := no update
    // 1 := update
    // 2 := new install
    int updateornew = 0;

    // make sure db exists
    QFileInfo info(PQCConfigFiles::get().SHORTCUTS_DB());
    if(!info.exists()) {
        updateornew = 2;
        if(!QFile::copy(":/shortcuts.db", PQCConfigFiles::get().SHORTCUTS_DB()))
            qWarning() << "Unable to (re-)create default shortcuts database";
        else {
            QFile file(PQCConfigFiles::get().SHORTCUTS_DB());
            file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
            QSqlQuery queryEnter(db);
            queryEnter.prepare("INSERT INTO 'config' (`name`, `value`) VALUES ('version', :ver)");
            queryEnter.bindValue(":ver", PQMVERSION);
            if(!queryEnter.exec()) {
                qCritical() << "Unable to enter version in new config table";
            }
        }
    }

    if(updateornew != 2) {

        bool configExists = true;
        bool extExists = true;

        // ensure config table exists
        QSqlQuery query(db);
        // check if config table exists
        if(!query.exec("SELECT name FROM sqlite_master WHERE type='table' AND name='config';")) {
            qCritical() << "Unable to verify existince of config table";
        } else {
            // the table does not exist
            if(!query.next()) {
                updateornew = 1;
                configExists = false;
                QSqlQuery queryNew(db);
                if(!queryNew.exec("CREATE TABLE 'config' ('name' TEXT UNIQUE, 'value' TEXT)")) {
                    qCritical() << "Unable to create config table";
                } else {
                    QSqlQuery queryEnter(db);
                    queryEnter.prepare("INSERT INTO 'config' (`name`, `value`) VALUES ('version', :ver)");
                    queryEnter.bindValue(":ver", PQMVERSION);
                    if(!queryEnter.exec()) {
                        qCritical() << "Unable to enter version in new config table";
                    }
                }
            }
        }

        // ensure extensions table exists
        QSqlQuery queryExt(db);
        // check if extensions table exists
        qWarning() << ">>> CHECK EXT TABLE EXISTENCE";
        if(!queryExt.exec("SELECT name FROM sqlite_master WHERE type='table' AND name='extensions';")) {
            qCritical() << "Unable to verify existince of extensions table";
        } else {
            // the table does not exist
            if(!queryExt.next()) {
                qWarning() << ">>> DOES NOT EXIST";
                updateornew = 1;
                extExists = false;
                QSqlQuery queryNew(db);
                if(!queryNew.exec("CREATE TABLE 'extensions' ('combo' TEXT UNIQUE, 'extension' TEXT, 'commands' TEXT, 'cycle' INTEGER, 'cycletimeout' INTEGER, 'simultaneous' INTEGER)")) {
                    qCritical() << "Unable to create extensions table";
                }
            }
        }

        if(updateornew == 1) {
            if(!configExists)
                // This was the last version with NO version number in the shortcuts database
                migrate("4.9.1");
            if(!extExists)
                // This was the last version before the extensions shortcuts were sorted out
                migrate("4.9.2");
        }

    }

    // this means the db existed already AND the config table exists already
    if(updateornew == 0) {

        QSqlQuery query(db);
        if(!query.exec("SELECT `value` FROM `config` WHERE `name`='version'")) {
            qCritical() << "Unable to retrieve existing version number";
        } else {
            if(!query.next()) {
                QSqlQuery queryEnter(db);
                queryEnter.prepare("INSERT INTO 'config' (`name`, `value`) VALUES ('version', :ver)");
                queryEnter.bindValue(":ver", PQMVERSION);
                if(!queryEnter.exec()) {
                    qCritical() << "Unable to enter version in new config table";
                }
            } else {
                const QString value = query.value(0).toString();
                const QString curver = PQMVERSION;
                if(curver != value) {
                    updateornew = 1;
                    migrate(value);
                    QSqlQuery queryEnter(db);
                    queryEnter.prepare("UPDATE 'config' SET `value`=:ver WHERE `name`='version'");
                    queryEnter.bindValue(":ver", PQMVERSION);
                    if(!queryEnter.exec()) {
                        qCritical() << "Unable to enter version in new config table";
                    }
                }
            }
        }

    }

    return updateornew;

}

bool PQCShortcuts::backupDatabase() {

    // make sure all changes are written to db
    if(dbIsTransaction) {
        dbCommitTimer->stop();
        db.commit();
        dbIsTransaction = false;
        if(db.lastError().text().trimmed().length())
            qCritical() << "ERROR committing database:" << db.lastError().text();
    }

    // backup file
    if(QFile::exists(QString("%1.bak").arg(PQCConfigFiles::get().SHORTCUTS_DB())))
        QFile::remove(QString("%1.bak").arg(PQCConfigFiles::get().SHORTCUTS_DB()));
    QFile file(PQCConfigFiles::get().SHORTCUTS_DB());
    return file.copy(QString("%1.bak").arg(PQCConfigFiles::get().SHORTCUTS_DB()));

}

void PQCShortcuts::setDefault() {

    qDebug() << "";

    if(readonly)
        return;

    dbCommitTimer->stop();
    if(!dbIsTransaction)
        db.transaction();

    QSqlQuery query(db);

    if(!query.exec("DELETE FROM shortcuts")) {
        qWarning() << "SQL error:" << query.lastError().text();
        return;
    }

    query.clear();

    // open database
    QSqlDatabase dbdefault;
    if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
        dbdefault = QSqlDatabase::addDatabase("QSQLITE3", "shortcutsrestoredefault");
    else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
        dbdefault = QSqlDatabase::addDatabase("QSQLITE", "shortcutsrestoredefault");
    else {
        qCritical() << "ERROR: SQLite driver not available. Available drivers are:" << QSqlDatabase::drivers().join(",");
        qCritical() << "PhotoQt cannot function without SQLite available.";
        return;
    }

    QFile::remove(PQCConfigFiles::get().CACHE_DIR()+"/photoqt_tmp.db");
    QFile::copy(":/shortcuts.db", PQCConfigFiles::get().CACHE_DIR()+"/photoqt_tmp.db");
    QFile::setPermissions(PQCConfigFiles::get().CACHE_DIR()+"/photoqt_tmp.db",
                          QFileDevice::WriteOwner|QFileDevice::ReadOwner |
                          QFileDevice::ReadGroup);
    dbdefault.setDatabaseName(PQCConfigFiles::get().CACHE_DIR()+"/photoqt_tmp.db");
    if(!dbdefault.open()) {
        qWarning() << "SQL error:" << dbdefault.lastError().text();
        dbdefault.close();
        return;
    }

    QSqlQuery queryDefault(dbdefault);
    if(!queryDefault.exec("SELECT `combo`,`commands`,`cycle`,`cycletimeout`,`simultaneous` FROM 'shortcuts'")) {
        qCritical() << "SQL error:" << queryDefault.lastError().text();
        queryDefault.clear();
        dbdefault.close();
        return;
    }

    while(queryDefault.next()) {

        const QString combo = queryDefault.value(0).toString();
        const QString commands = queryDefault.value(1).toString();
        const int cycle = queryDefault.value(2).toInt();
        const int cycletimeout = queryDefault.value(3).toInt();
        const int simultaneous = queryDefault.value(4).toInt();

        QSqlQuery query(db);
        query.prepare("INSERT INTO 'shortcuts' (`combo`,`commands`,`cycle`,`cycletimeout`,`simultaneous`) VALUES (:combo, :commands, :cycle, :cycletimeout, :simultaneous)");
        query.bindValue(":combo", combo);
        query.bindValue(":commands", commands);
        query.bindValue(":cycle", cycle);
        query.bindValue(":cycletimeout", cycletimeout);
        query.bindValue(":simultaneous", simultaneous);
        if(!query.exec()) {
            qCritical() << "SQL error:" << query.lastError().text();
            query.clear();
            dbdefault.close();
            return;
        }
        query.clear();

    }

    queryDefault.clear();
    dbdefault.close();

    // we need to write changes to the database so we can read them right after
    db.commit();
    dbIsTransaction = false;
    if(db.lastError().text().trimmed().length())
        qWarning() << "ERROR committing database:" << db.lastError().text();

    readDB();

}

QVariantList PQCShortcuts::getCommandsForShortcut(QString combo) {

    qDebug() << "args: combo =" << combo;

    QMapIterator<QString, QVariantList> iter(shortcuts);
    while(iter.hasNext()) {
        iter.next();
        if(iter.key() == combo)
            return iter.value();
    }

    return QVariantList();

}

void PQCShortcuts::readDB() {

    qDebug() << "";

    shortcuts.clear();
    shortcutsOrder.clear();

    QSqlQuery query(db);
    if(!query.exec("SELECT `combo`,`commands`,`cycle`,`cycletimeout`,`simultaneous` FROM 'shortcuts'")) {
        qWarning() << "SQL error:" << query.lastError().text();
        return;
    }

    while(query.next()) {

        QString combo = query.value(0).toString();
        const QStringList commands = query.value(1).toString().split(":://::");
        const int cycle = query.value(2).toInt();
        int cycletimeout = query.value(3).toInt();
        const int simultaneous = query.value(4).toInt();

        if(cycle == 0 && simultaneous == 0)
            cycletimeout = 1;

        if(combo == "Del") combo = "Delete";

        shortcuts[combo] = QVariantList() << commands << cycle << cycletimeout << simultaneous;
        shortcutsOrder.push_back(combo);

    }

    query.clear();

    QSqlQuery queryExt(db);
    if(!queryExt.exec("SELECT `combo`,`commands`,`cycle`,`cycletimeout`,`simultaneous` FROM 'extensions'")) {
        qWarning() << "SQL error:" << queryExt.lastError().text();
        return;
    }

    while(queryExt.next()) {

        QString combo = queryExt.value(0).toString();
        const QStringList commands = queryExt.value(1).toString().split(":://::");
        const int cycle = queryExt.value(2).toInt();
        int cycletimeout = queryExt.value(3).toInt();
        const int simultaneous = queryExt.value(4).toInt();

        if(cycle == 0 && simultaneous == 0)
            cycletimeout = 1;

        if(combo == "Del") combo = "Delete";

        if(shortcuts.contains(combo))
            continue;

        shortcuts[combo] = QVariantList() << commands << cycle << cycletimeout << simultaneous;
        shortcutsOrder.push_back(combo);

    }

    queryExt.clear();

}

QVariantList PQCShortcuts::getAllCurrentShortcuts() {

    qDebug() << "";

    // we sort the entries by alphabetical key combo
    // if multiple key combos are used for the same shortcut, then we use the first combo alphabetical in that list
    QVariantList ret;

    // first group cmds together
    QMap<QString, QStringList> collectCmds;
    QMapIterator<QString, QVariantList> iterSh(shortcuts);
    while(iterSh.hasNext()) {
        iterSh.next();
        const QString key = iterSh.value()[0].toStringList().join(":://::");
        if(collectCmds.contains(key))
            collectCmds[key].push_back(iterSh.key());
        else
            collectCmds.insert(key, QStringList() << iterSh.key());
    }

    // create list with individual keys as key and cmds as value
    QMap<QString, QString> collectCombos;
    QMapIterator<QString, QStringList> iterCmds(collectCmds);
    while(iterCmds.hasNext()) {
        iterCmds.next();
        for(const auto &k : std::as_const(iterCmds.value()))
            collectCombos[k] = iterCmds.key();
    }

    // make sure shortcuts are sorted alphabetically
    shortcutsOrder.sort();

    // loop over order and construct return list
    QStringList processed;
    for(const QString &o : std::as_const(shortcutsOrder)) {

        if(processed.contains(o))
            continue;

        const QString cmd = collectCombos[o];
        const QStringList allkeys = collectCmds[cmd];
        for(const auto &a : allkeys)
            processed.push_back(a);
        QVariantList entry;
        entry.append(allkeys);
        entry.append(shortcuts[o][0]);
        entry.append(shortcuts[o][1]);
        entry.append(shortcuts[o][2]);
        entry.append(shortcuts[o][3]);

        ret.push_back(entry);

    }

    return ret;

}

void PQCShortcuts::saveAllCurrentShortcuts(QVariantList list) {

    qDebug() << "args.length: list.length =" << list.length();

    shortcuts.clear();
    shortcutsOrder.clear();

    // remove old shortcuts
    QSqlQuery query(db);
    if(!query.exec("DELETE FROM 'shortcuts'")) {
        qWarning() << "SQL error:" << query.lastError().text();
        return;
    }
    query.clear();

    for (int i = 0; i < list.size(); ++i) {

        QVariantList cur = list.at(i).toList();

        const QStringList combos = cur[0].toStringList();
        const QStringList cmds = cur[1].toStringList();
        const int cycle = cur[2].toInt();
        const int cycletimeout = cur[3].toInt();
        const int simultaneous = cur[4].toInt();

        QSqlQuery query(db);

        for(const auto &c : combos) {
            query.prepare("INSERT OR REPLACE INTO 'shortcuts' (`combo`,`commands`,`cycle`,`cycletimeout`,`simultaneous`) VALUES (:combo, :cmds, :cycle, :cycletimeout, :simultaneous)");
            query.bindValue(":combo", c);
            query.bindValue(":cmds", cmds.join(":://::"));
            query.bindValue(":cycle", cycle);
            query.bindValue(":cycletimeout", cycletimeout);
            query.bindValue(":simultaneous", simultaneous);
            if(!query.exec())
                qWarning() << "SQL error:" << query.lastError().text();
            query.clear();

            shortcuts[c] = QVariantList() << cmds << cycle << cycletimeout << simultaneous;
            shortcutsOrder.push_back(c);

        }

    }

}

void PQCShortcuts::closeDatabase() {

    qDebug() << "";

    if(dbIsTransaction) {
        db.commit();
        dbIsTransaction = false;
        if(db.lastError().text().trimmed().length())
            qCritical() << "ERROR committing database:" << db.lastError().text();
    }

    db.close();

}

void PQCShortcuts::reopenDatabase() {

    if(!db.open())
        qWarning() << "Unable to reopen database";

}

int PQCShortcuts::getNextCommandInCycle(QString combo, int timeout, int maxCmd) {

    qDebug() << "args: combo =" << combo;
    qDebug() << "args: timeout =" << timeout;
    qDebug() << "args: maxCmd =" << maxCmd;

    if(commandCycle.contains(combo)) {
        const qint64 cur = QDateTime::currentSecsSinceEpoch();
        if(timeout > 0 && abs(commandCycle[combo][1]-cur) >= timeout)
            commandCycle[combo] = QList<qint64>() << 0 << QDateTime::currentSecsSinceEpoch();
        else {
            commandCycle[combo][0] = (commandCycle[combo][0]+1)%maxCmd;
            commandCycle[combo][1] = cur;
        }
    } else
        commandCycle[combo] = QList<qint64>() << 0 << QDateTime::currentSecsSinceEpoch();
    return commandCycle[combo][0];

}

void PQCShortcuts::resetCommandCycle(QString combo) {
    commandCycle.remove(combo);
}

bool PQCShortcuts::migrate(QString oldversion) {

    qDebug() << "args: oldversion =" << oldversion;

    if(oldversion == "") {
        qDebug() << "Running migrate with current version as oldversion value";
        oldversion = QString(PQMVERSION);
    }

    /*************************************************************************/
    /**************************** IMPORTANT NOTE *****************************/
    /*************************************************************************/
    //                                                                       //
    // BEFORE EVERY NEW RELEASE THE NEW VERSION NUMBER HAS TO BE ADDED BELOW //
    //                                                                       //
    // and the same needs to be done in pqc_settings.cpp:migrate()           //
    /*************************************************************************/

    QStringList versions;
    versions << "4.0" << "4.1" << "4.2" << "4.3" << "4.4" << "4.5" << "4.6" << "4.7" << "4.8" << "4.8.1" << "4.9" << "4.9.1" << "4.9.2" << "5.0";
    // when removing the 'dev' value, check below for any if statement involving 'dev'!

    // this is a safety check to make sure we don't forget the above check
    if(oldversion != "dev" && versions.indexOf(oldversion) == -1) {
        qCritical() << "WARNING: The current version number needs to be added to the migrate() functions";
    }

    int iVersion = 0;
    if(oldversion == "dev")
        iVersion = versions.length()-1;
    else if(oldversion != "" && versions.contains(oldversion))
        // we do a +1 as we are on the found version and don't need to migrate to it
        iVersion = versions.indexOf(oldversion)+1;

    // we iterate through all migrations one by one

    dbCommitTimer->stop();

    if(dbIsTransaction) {
        db.commit();
        dbIsTransaction = false;
        if(db.lastError().text().trimmed().length())
            qWarning() << "ERROR committing database:" << db.lastError().text();
    }

    for(int iV = iVersion; iV < versions.length(); ++iV) {

        QString curVer = versions[iV];

        /*******************************************/
        /*******************************************/
        // update to v4.0

        if(curVer == "4.0") {

            // make sure new table name exists and if not create it and populate it with default data

            QSqlQuery query(db);

            query.exec("SELECT COUNT(name) FROM sqlite_master WHERE type='table' AND name='shortcuts'");
            if(query.lastError().text().trimmed().length()) {
                qWarning() << "Unable to check if shortcuts table exists already:" << query.lastError().text();
                continue;
            }
            query.next();

            // table does not exist yet
            if(query.value(0).toInt() == 0) {

                QSqlQuery queryCreate(db);
                queryCreate.exec("CREATE TABLE 'shortcuts' ('combo' TEXT UNIQUE, 'commands' TEXT, 'cycle' INTEGER, 'cycletimeout' INTEGER, 'simultaneous' INTEGER)");
                queryCreate.clear();

                if(!QFile::copy(":/shortcuts.db", PQCConfigFiles::get().CACHE_DIR() + "/shortcutstmp.db")) {
                    qWarning() << "Unable to create shortcuts database";
                    continue;
                }

                QFile file(PQCConfigFiles::get().CACHE_DIR() + "/shortcutstmp.db");
                file.setPermissions(file.permissions()|QFileDevice::WriteOwner);

                QSqlQuery queryAttach(db);
                queryAttach.exec(QString("ATTACH DATABASE '%1' AS defaultdb").arg(PQCConfigFiles::get().CACHE_DIR() + "/shortcutstmp.db"));
                if(queryAttach.lastError().text().trimmed().length()) {
                    qWarning() << "Unable to attach default database:" << queryAttach.lastError().text();
                    continue;
                }

                QSqlQuery queryInsert(db);
                queryInsert.exec("INSERT INTO shortcuts SELECT * FROM defaultdb.shortcuts;");
                if(queryInsert.lastError().text().trimmed().length()) {
                    qWarning() << "Failed to insert default shortcuts:" << queryInsert.lastError().text();
                }
                queryInsert.clear();

                queryAttach.clear();

            }

            query.clear();

        } else if(curVer == "4.4") {

            // Update 'Del' to 'Delete'

            // first update shortcut set to exactly 'Del'
            QSqlQuery query(db);
            if(!query.exec("Update `shortcuts` SET `combo`='Delete' WHERE `combo`='Del'"))
                qWarning() << "Unable to change 'Del' shortcut to 'Delete':" << query.lastError().text();
            query.clear();

            // next we update the ones with 'Del' no at the end
            QSqlQuery query2(db);
            if(query2.exec("SELECT `combo` FROM `shortcuts` WHERE combo LIKE 'Del+%'")) {

                while(query2.next()) {

                    QString combo = query2.value(0).toString();
                    QString comboNEW = query2.value(0).toString().replace("Del+", "Delete+");

                    QSqlQuery queryUpd(db);
                    queryUpd.prepare("UPDATE `shortcuts` SET `combo`=:combonew WHERE `combo`=:combo");
                    queryUpd.bindValue(":combonew", comboNEW);
                    queryUpd.bindValue(":combo", combo);
                    if(!queryUpd.exec())
                        qWarning() << "Unable to update 'Del' to 'Delete' in shortcut" << combo << "::" << queryUpd.lastError().text();
                    queryUpd.clear();

                }

            }

            query2.clear();

            // next we update the ones with 'Del' at the end
            if(query.exec("SELECT `combo` FROM `shortcuts` WHERE combo LIKE '%+Del'")) {

                while(query.next()) {

                    QString combo = query.value(0).toString();
                    QString comboNEW = combo.replace("+Del", "+Delete");

                    QSqlQuery queryUpd(db);
                    queryUpd.prepare("UPDATE `shortcuts` SET `combo`=:combonew WHERE `combo`=:combo");
                    queryUpd.bindValue(":combonew", comboNEW);
                    queryUpd.bindValue(":combo", combo);
                    queryUpd.exec();
                    if(queryUpd.lastError().text().trimmed().length())
                        qWarning() << "Unable to update 'Del' to 'Delete' in shortcut" << combo << "::" << queryUpd.lastError().text();
                    queryUpd.clear();

                }

            }

            query.clear();

        } else if(curVer == "4.6") {

            // Ctrl+Z is to be added for __undoTrash. If Ctrl+Z is already used, we need to fix this

            QSqlQuery query(db);

            query.exec("SELECT `combo` FROM `shortcuts` WHERE `combo` LIKE '%Ctrl%Z' AND `commands` NOT LIKE '%__undoTrash%'");
            if(query.lastError().text().trimmed().length()) {
                qWarning() << "Unable to query for shortcuts with Ctrl+Z:" << query.lastError().text();
                continue;
            }

            bool CtrlZ = true;
            bool CtrlShiftZ = true;
            bool CtrlAltShiftZ = true;

            while(query.next()) {

                QString combo = query.value(0).toString();

                if(combo == "Ctrl+Z")
                    CtrlZ = false;
                else if(combo == "Ctrl+Shift+Z")
                    CtrlShiftZ = false;
                else if(combo == "Ctrl+Alt+Shift+Z")
                    CtrlAltShiftZ = false;

            }

            query.clear();

            QString newcombo = "";
            if(CtrlZ)
                newcombo = "Ctrl+Z";
            else if(CtrlShiftZ)
                newcombo = "Ctrl+Shift+Z";
            else if(CtrlAltShiftZ)
                newcombo = "Ctrl+Alt+Shift+Z";

            if(newcombo != "") {

                QSqlQuery queryNew(db);

                queryNew.prepare("INSERT INTO shortcuts (`combo`,`commands`,`cycle`,`cycletimeout`,`simultaneous`) VALUES(:com,'__undoTrash',1,0,0)");
                queryNew.bindValue(":com", newcombo);
                if(!queryNew.exec())
                    qWarning() << "Unable to insert __undoTrash shortcut";

                queryNew.clear();

            }

        } else if(curVer == "4.9.1") {

            // These two checks were located in the validation function for qutie some time
            // After 4.9.1 they were moved here.

            QSqlQuery query1(db);
            if(!query1.exec("Update `shortcuts` SET `combo` = REPLACE(`combo`, 'Escape', 'Esc')"))
                qWarning() << "Error renaming Escape to Esc:" << query1.lastError().text();
            query1.clear();

            QSqlQuery query2(db);
            if(!query2.exec("Update `shortcuts` SET `combo` = REPLACE(`combo`, 'Delete', 'Del')"))
                qWarning() << "Error renaming Delete to Del:" << query2.lastError().text();

            query2.clear();

        } else if(curVer == "5.0") {

            enterOrMoveExtensionShortcuts();

        }

        ///////////////////////////////////////////////////////////
        ///////////////////////////////////////////////////////////
        ///////////////////////////////////////////////////////////
        /// EXTENSIONS

        /////////////////////////////////////////////////////
        // check for migrations for extensions

        const QStringList ext = PQCExtensionsHandler::get().getExtensions();
        for(const QString &e : ext) {

            QMap<QString, QList<QStringList> > mig = PQCExtensionsHandler::get().getMigrateShortcuts(e);

            for(auto i = mig.cbegin(), end = mig.cend(); i != end; ++i) {

                const QString v = i.key();

                if(v == curVer) {

                    const QList<QStringList> vals = i.value();
                    for(const QStringList &entry : vals) {

                        if(entry.length() < 2) {
                            qWarning() << "Invalid shortcuts migration:" << entry;
                            continue;
                        }


                        // first we rename the shortcut if needed
                        if(entry[0] != entry[1]) {

                            QSqlQuery query(db);

                            query.prepare("UPDATE `extensions` SET `commands`=:cmdnew WHERE `commands`=:cmdold AND `extension`=:ext");
                            query.bindValue(":cmdold", entry[0]);
                            query.bindValue(":cmdnew", entry[1]);
                            query.bindValue(":ext", e);
                            if(!query.exec()) {
                                qWarning() << "Unable to migrate shortcut:" << query.lastError().text();
                                qWarning() << "Failed migration:" << entry;
                                continue;
                            }

                            query.clear();

                        }

                        // in this case we also need to update the shortcut (maybe)
                        if(entry.length() > 3) {

                            QSqlQuery query(db);

                            // check old key exists
                            // if not then no migration needs to be done
                            // we check for existence of all shortcuts later
                            query.prepare(QString("SELECT `combo` FROM `extensions` WHERE `combo`=:comboold AND `commands`=:cmdnew AND `extension`=:ext"));
                            query.bindValue(":comboold", entry[2]);
                            query.bindValue(":cmdnew", entry[1]);
                            query.bindValue(":ext", e);
                            if(!query.exec()) {
                                qWarning() << "Query failed to execute:" << query.lastError().text();
                                continue;
                            }

                            // if an entry even exists... this can be false if the shortcut has never been entered before.
                            // not-yet-entered shortcuts will be entered below
                            if(query.next()) {

                                for(int i = 3; i < entry.length(); ++i) {

                                    const QString newsh = entry[i];

                                    // check if new shortcut already exists
                                    QSqlQuery queryExists(db);
                                    queryExists.prepare("SELECT `combo` as c FROM `extensions` WHERE `combo`=:combonew AND `extension`=:ext");
                                    queryExists.bindValue(":combonew", newsh);
                                    queryExists.bindValue(":ext", e);
                                    if(!queryExists.exec()) {
                                        qWarning() << "Query failed to execute:" << queryExists.lastError().text();
                                        continue;
                                    }

                                    // the new shortcut does not exist yet -> use this one
                                    if(!queryExists.next()) {

                                        QSqlQuery queryNew(db);
                                        queryNew.prepare("UPDATE `extensions` SET `combo`=:combonew WHERE `combo`=:comboold AND `commands`=:cmdnew AND `extension`=:ext");
                                        queryNew.bindValue(":combonew", newsh);
                                        queryNew.bindValue(":comboold", entry[2]);
                                        queryNew.bindValue(":cmdnew", entry[1]);
                                        queryNew.bindValue(":ext", e);

                                        if(!queryNew.exec()) {
                                            qWarning() << "Query failed to execute:" << queryNew.lastError().text();
                                            continue;
                                        }

                                        queryNew.clear();

                                        break;

                                    }

                                    queryExists.clear();

                                }

                            }

                            query.clear();

                        }

                    }


                }

            }

        }

        /// END EXTENSIONS
        ///////////////////////////////////////////////////////////
        ///////////////////////////////////////////////////////////
        ///////////////////////////////////////////////////////////

    }

    readDB();

    return true;

}

void PQCShortcuts::enterOrMoveExtensionShortcuts() {

    qDebug() << "";

    const QStringList allext = PQCExtensionsHandler::get().getExtensions();
    for(const QString &ext : allext) {

        const QList<QStringList> shortcuts = PQCExtensionsHandler::get().getShortcutsActions(ext);

        for(const QStringList &sh : shortcuts) {

            if(sh.length() != 4) {
                qWarning() << "Invalid shortcut detected:" << sh;
                continue;
            }

            // no default shortcut
            if(sh[2] == "")
                continue;

            QString combo = sh[2];
            QString cmd = sh[0];
            int cycle = 1;
            int cycletimeout = 0;
            int simultaneous = 0;

            // get extension shortcut from main database
            QSqlQuery query(db);
            query.prepare("SELECT `combo`, `cycle`, `cycletimeout`, `simultaneous` FROM `shortcuts` WHERE `commands`=:cmd");
            query.bindValue(":cmd", cmd);
            if(!query.exec()) {
                qWarning() << "Unable to check previous entry for shortcut:" << cmd;
                query.clear();
                continue;
            }

            while(query.next()) {

                combo = query.value(0).toString();
                cycle = query.value(1).toInt();
                cycletimeout = query.value(2).toInt();
                simultaneous = query.value(3).toInt();

                QSqlQuery queryMove(db);
                queryMove.prepare("INSERT OR IGNORE INTO `extensions` (`extension`, `combo`, `commands`, `cycle`, `cycletimeout`, `simultaneous`) VALUES (:ext, :com, :cmd, :ccl, :cct, :sim)");
                queryMove.bindValue(":ext", ext);
                queryMove.bindValue(":com", combo);
                queryMove.bindValue(":cmd", cmd);
                queryMove.bindValue(":ccl", cycle);
                queryMove.bindValue(":cct", cycletimeout);
                queryMove.bindValue(":sim", simultaneous);
                if(!queryMove.exec()) {
                    qWarning() << QString("Unable to move shortcut for '%1' to extensions table.").arg(cmd);
                    queryMove.clear();
                    continue;
                }

                queryMove.clear();

            }

            QSqlQuery queryDel(db);
            queryDel.prepare("DELETE FROM `shortcuts` WHERE `commands`=:cmd");
            queryDel.bindValue(":cmd", cmd);
            if(!queryDel.exec())
                qWarning() << "Unable to remove old extensions shortcut from old shortcuts table:" << cmd;

            queryDel.clear();

        }

    }

}

void PQCShortcuts::resetToDefault() {

    setDefault();
    setupFresh();
    readDB();

}

void PQCShortcuts::setupFresh() {

    qDebug() << "";

    // at this point we can assume that the settings.db has already been copied
    // we only need to add any setting from the extensions

    db.transaction();

    const QStringList allext = PQCExtensionsHandler::get().getExtensions();
    for(const QString &ext : allext) {

        const QList<QStringList> shortcuts = PQCExtensionsHandler::get().getShortcutsActions(ext);

        for(const QStringList &sh : shortcuts) {

            if(sh.length() != 4) {
                qWarning() << "Invalid shortcut detected:" << sh;
                continue;
            }

            // no default shortcut
            if(sh[2] == "")
                continue;

            const QStringList parts = sh[2].split(":://::");

            for(const QString &p : parts) {

                QSqlQuery query(db);
                query.prepare("INSERT OR IGNORE INTO extensions (`extension`, `combo`, `commands`, `cycle`, `cycletimeout`, `simultaneous`) VALUES (:ext, :com, :cmd, 1, 0, 0)");
                query.bindValue(":ext", ext);
                query.bindValue(":com", p);
                query.bindValue(":cmd", sh[0]);

                if(!query.exec()) {
                    qWarning() << "ERROR inserting shortcut:" << query.lastError().text();
                    qWarning() << "Faulty shortcut:" << sh;
                }

                query.clear();

            }

        }

    }

    db.commit();

    readDB();

}
