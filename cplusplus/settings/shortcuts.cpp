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

}

QStringList PQShortcuts::getCommandForShortcut(QString sh) {

    DBG << CURDATE << "PQShortcuts::getCommandForShortcut()" << NL
        << CURDATE << "** sh = " << sh.toStdString() << NL;

    QMapIterator<QString, QStringList> iter(shortcuts);
    while(iter.hasNext()) {
        iter.next();
        if(iter.value().contains(sh))
            return QStringList() << "0" << iter.key();
    }

    QMapIterator<QString, QStringList> iter2(externalShortcuts);
    while(iter2.hasNext()) {
        iter2.next();
        if(iter2.value().mid(1).contains(sh))
            return QStringList() << iter2.value().at(0) << iter2.key();
    }

    return QStringList() << "" << "";

}

QStringList PQShortcuts::getShortcutsForCommand(QString cmd) {

    DBG << CURDATE << "PQShortcuts::getShortcutsForCommand()" << NL
        << CURDATE << "** cmd = " << cmd.toStdString() << NL;

    if(shortcuts.contains(cmd))
        return QStringList() << "0" << shortcuts[cmd];
    else if(externalShortcuts.contains(cmd))
        return externalShortcuts[cmd];

    return QStringList();

}

QVariantList PQShortcuts::getAllExternalShortcuts() {

    DBG << CURDATE << "PQShortcuts::getAllExternalShortcuts()" << NL;

    QVariantList ret;

    QMapIterator<QString, QStringList> iter(externalShortcuts);
    while(iter.hasNext()) {
        iter.next();
        ret.append(QStringList() << iter.key() << iter.value());
    }

    return ret;

}

void PQShortcuts::setShortcut(QString cmd, QStringList sh) {

    DBG << CURDATE << "PQShortcuts::getShortcutsForCommand()" << NL
        << CURDATE << "** cmd = " << cmd.toStdString() << NL
        << CURDATE << "** sh = " << sh.join(", ").toStdString() << NL;

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

}

void PQShortcuts::readDB() {

    DBG << CURDATE << "PQShortcuts::readShortcuts()" << NL;

    QSqlQuery query(db);
    query.prepare("SELECT command, shortcuts FROM builtin");
    if(!query.exec()) {
        LOG << CURDATE << "PQShortcuts::readDB() [1]: SQL error: " << query.lastError().text().trimmed().toStdString() << NL;
        return;
    }

    while(query.next()) {

        const QString cmd = query.record().value(0).toString();
        QString sh = query.record().value(1).toString();

        QStringList sh_parts;
        if(sh == ",")
            sh_parts << ",";
        else if(sh != "") {
            sh = sh.replace(",,","COMMA,");
            if(sh.endsWith(", ,"))
                sh.replace(sh.length()-3, sh.length(), ", COMMA");
            const QStringList tmp = sh.split(",");
            for(auto p : qAsConst(tmp))
                sh_parts << p.replace("COMMA",",").trimmed();
        }

        shortcuts[cmd] = sh_parts;

    }

    query.clear();
    query.prepare("SELECT command, arguments, shortcuts, close FROM external");
    if(!query.exec()) {
        LOG << CURDATE << "PQShortcuts::readDB() [2]: SQL error: " << query.lastError().text().trimmed().toStdString() << NL;
        return;
    }

    while(query.next()) {

        const QString cmd = query.record().value(0).toString();
        const QString args = query.record().value(1).toString();
        QString sh = query.record().value(2).toString();
        const QString close = query.record().value(3).toString();

        QStringList sh_parts;
        sh_parts << close;
        if(sh == ",")
            sh_parts << ",";
        else {
            QStringList tmp = sh.replace(",,","COMMA,").split(",");
            for(auto p : qAsConst(tmp))
                sh_parts << p.replace("COMMA",",").trimmed();
        }

        externalShortcuts[QString("%1:://:://::%2").arg(cmd, args)] = sh_parts;

    }

}

void PQShortcuts::deleteAllExternalShortcuts() {

    DBG << CURDATE << "PQShortcuts::deleteAllExternalShortcuts()" << NL;

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

}
