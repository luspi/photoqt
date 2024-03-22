/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

PQCShortcuts::PQCShortcuts() {

    // connect to database
    if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
        db = QSqlDatabase::addDatabase("QSQLITE3", "shortcuts");
    else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
        db = QSqlDatabase::addDatabase("QSQLITE", "shortcuts");
    db.setDatabaseName(PQCConfigFiles::SHORTCUTS_DB());

    readonly = false;

    QFileInfo infodb(PQCConfigFiles::SHORTCUTS_DB());

    if(!infodb.exists() || !db.open()) {

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

    readDB();

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

}

PQCShortcuts::~PQCShortcuts() {}

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
    if(QFile::exists(QString("%1.bak").arg(PQCConfigFiles::SHORTCUTS_DB())))
        QFile::remove(QString("%1.bak").arg(PQCConfigFiles::SHORTCUTS_DB()));
    QFile file(PQCConfigFiles::SHORTCUTS_DB());
    return file.copy(QString("%1.bak").arg(PQCConfigFiles::SHORTCUTS_DB()));

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

    QFile::remove(PQCConfigFiles::CACHE_DIR()+"/photoqt_tmp.db");
    QFile::copy(":/shortcuts.db", PQCConfigFiles::CACHE_DIR()+"/photoqt_tmp.db");
    QFile::setPermissions(PQCConfigFiles::CACHE_DIR()+"/photoqt_tmp.db",
                          QFileDevice::WriteOwner|QFileDevice::ReadOwner |
                          QFileDevice::ReadGroup);
    dbdefault.setDatabaseName(PQCConfigFiles::CACHE_DIR()+"/photoqt_tmp.db");
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

        const QString combo = query.value(0).toString();
        const QStringList commands = query.value(1).toString().split(":://::");
        const int cycle = query.value(2).toInt();
        int cycletimeout = query.value(3).toInt();
        const int simultaneous = query.value(4).toInt();

        if(cycle == 0 && simultaneous == 0)
            cycletimeout = 1;

        shortcuts[combo] = QVariantList() << commands << cycle << cycletimeout << simultaneous;
        shortcutsOrder.push_back(combo);

    }

    query.clear();

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

    /*************************************************************************/
    /**************************** IMPORTANT NOTE *****************************/
    /*************************************************************************/
    //                                                                       //
    // BEFORE EVERY NEW RELEASE THE NEW VERSION NUMBER HAS TO BE ADDED BELOW //
    //                                                                       //
    // and the same needs to be done in pqc_settings.cpp:migrate()           //
    /*************************************************************************/

    QStringList versions;
    versions << "4.0" << "4.1" << "4.2" << "4.3";

    // this is a safety check to make sure we don't forget the above check
    if(oldversion != "dev" && versions.indexOf(oldversion) == -1) {
        qCritical() << "WARNING: The current version number needs to be added to the migrate() functions";
    }

    int iVersion = 0;
    if(oldversion != "" && versions.contains(oldversion))
        // we do a +1 as we are on the found version and don't need to migrate to it
        iVersion = versions.indexOf(oldversion)+1;
    else if(oldversion == "dev")
        iVersion = versions.length()-1;

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

                if(!QFile::copy(":/shortcuts.db", PQCConfigFiles::CACHE_DIR() + "/shortcutstmp.db")) {
                    qWarning() << "Unable to create shortcuts database";
                    continue;
                }

                QFile file(PQCConfigFiles::CACHE_DIR() + "/shortcutstmp.db");
                file.setPermissions(file.permissions()|QFileDevice::WriteOwner);

                QSqlQuery queryAttach(db);
                queryAttach.exec(QString("ATTACH DATABASE '%1' AS defaultdb").arg(PQCConfigFiles::CACHE_DIR() + "/shortcutstmp.db"));
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

        }

    }

    return true;

}

void PQCShortcuts::resetToDefault() {

    setDefault();
    readDB();

}
