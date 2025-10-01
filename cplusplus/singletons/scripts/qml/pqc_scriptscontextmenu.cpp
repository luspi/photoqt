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

#include <scripts/qml/pqc_scriptscontextmenu.h>
#include <pqc_configfiles.h>
#include <scripts/cpp/pqc_scriptsimages.h>

#include <QtDebug>
#include <QFileInfo>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QApplication>
#include <QProcess>

PQCScriptsContextMenu::PQCScriptsContextMenu() {

    // connect to database
    db = QSqlDatabase::database("contextmenu");

    QFileInfo infodb(PQCConfigFiles::get().CONTEXTMENU_DB());

    if(!infodb.exists()) {
        if(!QFile::copy(":/contextmenu.db", PQCConfigFiles::get().CONTEXTMENU_DB()))
            qWarning() << "Unable to (re-)create default contextmenu database";
        else {
            QFile file(PQCConfigFiles::get().CONTEXTMENU_DB());
            file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
        }
    }

    if(!db.open()) {

        qWarning() << "ERROR opening database:" << db.lastError().text();
        qWarning() << "no context menu entries will be available";

    }

}

PQCScriptsContextMenu::~PQCScriptsContextMenu() {
    db.close();
}

QVariantList PQCScriptsContextMenu::getEntries() {

    qDebug() << "";

    QVariantList ret;

    // if something went wrong during setup...
    if(!db.open())
        return ret;

    QSqlQuery query(db);
    query.prepare("SELECT command,arguments,icon,desc,close FROM entries");
    if(!query.exec()) {
        qWarning() << "SQL error, select:" << query.lastError().text();
        return ret;
    }

    while(query.next()) {

        const QString command = query.record().value(0).toString();
        const QString arguments = query.record().value(1).toString();
        const QString icon = query.record().value(2).toString();
        const QString desc = query.record().value(3).toString();
        const QString close = query.record().value(4).toString();

        QStringList thisentry;

        thisentry << icon;      // icon (if specified)
        thisentry << command;   // executable
        thisentry << desc;      // name
        thisentry << close;     // close
        thisentry << arguments; // command line arguments

        ret << thisentry;

    }

    query.clear();

    return ret;

}

void PQCScriptsContextMenu::setEntries(QVariantList entries) {

    qDebug() << "args: entries.length() =" << entries.length();

    if(!db.open()) {
        qWarning() << "SQL error:" << db.lastError().text();
        return;
    }

    QSqlQuery query(db);
    query.prepare("DELETE FROM entries");
    if(!query.exec()) {
        qWarning() << "SQL error:" << query.lastError().text();
        return;
    }

    for(const auto &entry : std::as_const(entries)) {

        QVariantList entrylist = entry.toList();

        const QString cmd = entrylist.at(1).toString();
        const QString args = entrylist.at(4).toString();
        const QString icn = entrylist.at(0).toString();
        const QString dsc = entrylist.at(2).toString();
        const QString close = entrylist.at(3).toString();

        if(cmd != "" && dsc != "") {

            QSqlQuery query(db);
            query.prepare("INSERT INTO entries (icon,command,arguments,desc,close) VALUES(:icn,:cmd,:arg,:dsc,:cls)");
            query.bindValue(":cmd", cmd);
            query.bindValue(":arg", args);
            query.bindValue(":icn", icn);
            query.bindValue(":dsc", dsc);
            query.bindValue(":cls", close);
            if(!query.exec())
                qWarning() << "SQL error:" << query.lastError().text();

        }

    }

    Q_EMIT customEntriesChanged();

}

QVariantList PQCScriptsContextMenu::detectSystemEntries() {

    QVariantList ret;

#ifdef Q_OS_WIN
    return ret;
#endif

    // These are the possible entries
    // There will be a ' %f' added at the end of each executable.
    QStringList m;
    //: Used as in 'Edit with [application]'. %1 will be replaced with application name.
    m << QApplication::translate("startup", "Edit with %1").arg("Gimp") << "gimp"
      //: Used as in 'Edit with [application]'. %1 will be replaced with application name.
      << QApplication::translate("startup", "Edit with %1").arg("Krita") << "krita"
      //: Used as in 'Edit with [application]'. %1 will be replaced with application name.
      << QApplication::translate("startup", "Edit with %1").arg("KolourPaint") << "kolourpaint"
      //: Used as in 'Open with [application]'. %1 will be replaced with application name.
      << QApplication::translate("startup", "Open in %1").arg("GwenView") << "gwenview"
      //: Used as in 'Open with [application]'. %1 will be replaced with application name.
      << QApplication::translate("startup", "Open in %1").arg("showFoto") << "showfoto"
      //: Used as in 'Open with [application]'. %1 will be replaced with application name.
      << QApplication::translate("startup", "Open in %1").arg("Shotwell") << "shotwell"
      //: Used as in 'Open with [application]'. %1 will be replaced with application name.
      << QApplication::translate("startup", "Open in %1").arg("GThumb") << "gthumb"
      //: Used as in 'Open with [application]'. %1 will be replaced with application name.
      << QApplication::translate("startup", "Open in %1").arg("Eye of Gnome") << "eog";

    // Check for all entries
    for(int i = 0; i < m.size()/2; ++i) {

        QProcess p;
        p.setStandardOutputFile(QProcess::nullDevice());
        p.start("which", QStringList() << m[2*i+1]);
        p.waitForFinished();
        bool found = (p.exitCode() == 0);

        if(found) {

            QStringList thisentry;

            QString icn = PQCScriptsImages::get().getIconPathFromTheme(m[2*i+1]);
            if(icn != "")
                icn = PQCScriptsImages::get().loadImageAndConvertToBase64(icn);

            thisentry << icn
                      << m[2*i+1]
                      << m[2*i]
                      << "0"
                      << "%f";

            ret << thisentry;

        }
    }

    return ret;

}

void PQCScriptsContextMenu::closeDatabase() {

    qDebug() << "";

    db.close();

}
