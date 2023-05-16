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
#include "shortcuts.h"

PQShortcuts::PQShortcuts() {

    db = QSqlDatabase::database("shortcuts");

    readonly = false;

    QFileInfo infodb(ConfigFiles::SHORTCUTS_DB());

    if(!infodb.exists() || !db.open()) {

        LOG << CURDATE << "PQShortcuts::PQShortcuts(): ERROR opening database: " << db.lastError().text().trimmed().toStdString() << NL;
        LOG << CURDATE << "PQShortcuts::PQShortcuts(): Will load read-only database of default shortcuts" << NL;

        readonly = true;
        db.setConnectOptions("QSQLITE_OPEN_READONLY");

        QString tmppath = QStandardPaths::writableLocation(QStandardPaths::TempLocation)+"/shortcuts.db";

        if(QFile::exists(tmppath))
            QFile::remove(tmppath);

        if(!QFile::copy(":/shortcuts.db", tmppath)) {
            LOG << CURDATE << "PQShortcuts::PQShortcuts(): ERROR copying read-only default database!" << NL;
            //: This is the window title of an error message box
            QMessageBox::critical(0, QCoreApplication::translate("PQShortcuts", "ERROR getting database with default shortcuts"),
                                     QCoreApplication::translate("PQShortcuts", "I tried hard, but I just cannot open even a read-only version of the shortcuts database.") + QCoreApplication::translate("PQShortcuts", "Something went terribly wrong somewhere!"));
            return;
        }

        QFile f(tmppath);
        f.setPermissions(f.permissions()|QFileDevice::WriteOwner);

        db.setDatabaseName(tmppath);

        if(!db.open()) {
            LOG << CURDATE << "PQShortcuts::PQShortcuts(): ERROR opening read-only default database!" << NL;
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
        dbCommitTimer->deleteLater();
        db.commit();
        dbIsTransaction = false;
        if(db.lastError().text().trimmed().length())
            LOG << "PQShortcuts::commitDB: ERROR committing database: "
                << db.lastError().text().trimmed().toStdString()
                << NL;
    });

}

PQShortcuts::~PQShortcuts() {}

bool PQShortcuts::backupDatabase() {

    // make sure all changes are written to db
    if(dbIsTransaction) {
        dbCommitTimer->stop();
        db.commit();
        dbIsTransaction = false;
        if(db.lastError().text().trimmed().length())
            LOG << "PQShortcuts::commitDB: ERROR committing database: " << db.lastError().text().trimmed().toStdString() << NL;
    }

    // backup file
    if(QFile::exists(QString("%1.bak").arg(ConfigFiles::SHORTCUTS_DB())))
        QFile::remove(QString("%1.bak").arg(ConfigFiles::SHORTCUTS_DB()));
    QFile file(ConfigFiles::SHORTCUTS_DB());
    return file.copy(QString("%1.bak").arg(ConfigFiles::SHORTCUTS_DB()));

}

void PQShortcuts::setDefault() {

    DBG << CURDATE << "PQShortcuts::setDefault()" << NL;
/*
    if(readonly)
        return;

    dbCommitTimer->stop();
    if(!dbIsTransaction)
        db.transaction();

    QSqlQuery query(db);

    // set default builtin
    query.prepare("UPDATE builtin SET shortcuts = defaultshortcuts");
    if(!query.exec()) {
        LOG << CURDATE << "PQShortcuts::setDefault [1]: SQL error: " << query.lastError().text().trimmed().toStdString() << NL;
        return;
    }
    shortcuts.clear();

    query.clear();

    // remove external shortcuts
    query.prepare("DELETE FROM external");
    if(!query.exec()) {
        LOG << CURDATE << "PQShortcuts::setDefault [2]: SQL error: " << query.lastError().text().trimmed().toStdString() << NL;
        return;
    }
    externalShortcuts.clear();

    // we need to write changes to the database so we can read them right after
    db.commit();
    dbIsTransaction = false;
    if(db.lastError().text().trimmed().length())
        LOG << "PQShortcuts::setDefault: ERROR committing database: " << db.lastError().text().trimmed().toStdString() << NL;

    readDB();
*/
}

QVariantList PQShortcuts::getCommandsForShortcut(QString combo) {

    DBG << CURDATE << "PQShortcuts::getCommandForShortcut()" << NL
        << CURDATE << "** combo = " << combo.toStdString() << NL;

    QMapIterator<QString, QVariantList> iter(shortcuts);
    while(iter.hasNext()) {
        iter.next();
        if(iter.key() == combo)
            return iter.value();
    }

    return QVariantList();

}

QVariantList PQShortcuts::getAllExternalShortcuts() {

    DBG << CURDATE << "PQShortcuts::getAllExternalShortcuts()" << NL;

    QVariantList ret;
/*
    QMapIterator<QString, QStringList> iter(externalShortcuts);
    while(iter.hasNext()) {
        iter.next();
        ret.append(QStringList() << iter.key() << iter.value());
    }
*/
    return ret;

}

void PQShortcuts::setShortcut(QString cmd, QStringList sh) {

    DBG << CURDATE << "PQShortcuts::getShortcutsForCommand()" << NL
        << CURDATE << "** cmd = " << cmd.toStdString() << NL
        << CURDATE << "** sh = " << sh.join(", ").toStdString() << NL;
/*
    if(readonly)
        return;

    dbCommitTimer->stop();
    if(!dbIsTransaction) {
        db.transaction();
        dbIsTransaction = true;
    }

    if(cmd.startsWith("__")) {

        shortcuts[cmd] = sh;

        QSqlQuery query(db);
        query.prepare("UPDATE builtin SET shortcuts=:sh WHERE command=:cmd");
        query.bindValue(":sh", sh.join(", "));
        query.bindValue(":cmd", cmd);
        if(!query.exec())
            LOG << CURDATE << "PQShortcuts::setShortcut() [1]: SQL error: " << query.lastError().text().trimmed().toStdString() << NL;

    } else {

        if(externalShortcuts.contains(cmd)) {

            externalShortcuts[cmd] = sh;

            QSqlQuery query(db);
            query.prepare("UPDATE external SET shortcuts=:sh,close=:cl WHERE command=:cmd");
            query.bindValue(":cl", sh[0]);
            query.bindValue(":sh", sh.mid(1).join(", "));
            query.bindValue(":cmd", cmd);
            if(!query.exec())
                LOG << CURDATE << "PQShortcuts::setShortcut() [2]: SQL error: " << query.lastError().text().trimmed().toStdString() << NL;

        } else {

            externalShortcuts[cmd] = sh;

            QSqlQuery query(db);
            query.prepare("INSERT INTO external (command,shortcuts,close) VALUES(:cmd, :sh, :cl)");
            query.bindValue(":cl", sh[0]);
            query.bindValue(":sh", sh.mid(1).join(", "));
            query.bindValue(":cmd", cmd);
            if(!query.exec())
                LOG << CURDATE << "PQShortcuts::setShortcut() [3]: SQL error: " << query.lastError().text().trimmed().toStdString() << NL;

        }

    }

    dbCommitTimer->start();
*/
}

void PQShortcuts::readDB() {

    DBG << CURDATE << "PQShortcuts::readShortcuts()" << NL;

    QSqlQuery query(db);
    if(!query.exec("SELECT `combo`,`commands`,`cycle`,`cycletimeout`,`simultaneous` FROM 'shortcuts'")) {
        LOG << CURDATE << "PQShortcuts::readDB() [1]: SQL error: " << query.lastError().text().trimmed().toStdString() << NL;
        return;
    }

    while(query.next()) {

        const QString combo = query.record().value(0).toString();
        const QStringList commands = query.record().value(1).toString().split(":://::");
        const int cycle = query.record().value(2).toInt();
        const int cycletimeout = query.record().value(3).toInt();
        const int simultaneous = query.record().value(4).toInt();

        shortcuts[combo] = QVariantList() << commands << cycle << cycletimeout << simultaneous;

    }

    query.clear();

    // TODO: read external shortcuts

}

QVariantList PQShortcuts::getAllCurrentShortcuts() {

    QVariantList ret;

    // first group combos together
    QMap<QString, QStringList> collectCombos;
    QMapIterator<QString, QVariantList> i(shortcuts);
    while(i.hasNext()) {
        i.next();
        const QString key = i.value()[0].toStringList().join(":://::");
        if(collectCombos.keys().contains(key))
            collectCombos[key].push_back(i.key());
        else
            collectCombos.insert(key, QStringList() << i.key());
    }

    // loop over groups and compose variantlist for settings
    QMapIterator<QString, QStringList> j(collectCombos);
    while(j.hasNext()) {
        j.next();

        QVariantList entry;
        entry.append(j.value());
        entry.append(shortcuts[j.value()[0]][0]);
        entry.append(shortcuts[j.value()[0]][1]);
        entry.append(shortcuts[j.value()[0]][2]);
        entry.append(shortcuts[j.value()[0]][3]);

        ret.push_back(entry);

    }

    return ret;

}

void PQShortcuts::deleteAllExternalShortcuts() {

    DBG << CURDATE << "PQShortcuts::deleteAllExternalShortcuts()" << NL;
/*
    if(readonly)
        return;

    dbCommitTimer->stop();
    if(!dbIsTransaction) {
        db.transaction();
        dbIsTransaction = true;
    }

    externalShortcuts.clear();
    QSqlQuery query(db);
    query.prepare("DELETE FROM external");
    if(!query.exec())
        LOG << CURDATE << "PQShortcuts::deleteAllExternalShortcuts(): SQL error: " << query.lastError().text().trimmed().toStdString() << NL;

    dbCommitTimer->start();
*/
}
