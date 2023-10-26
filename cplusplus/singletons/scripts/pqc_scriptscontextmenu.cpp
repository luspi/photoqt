#include <scripts/pqc_scriptscontextmenu.h>
#include <pqc_configfiles.h>

#include <QtDebug>
#include <QFileInfo>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QApplication>
#include <QProcess>

PQCScriptsContextMenu::PQCScriptsContextMenu() {

    // connect to database
    if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
        db = QSqlDatabase::addDatabase("QSQLITE3", "contextmenu");
    else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
        db = QSqlDatabase::addDatabase("QSQLITE", "contextmenu");
    db.setDatabaseName(PQCConfigFiles::CONTEXTMENU_DB());

    QFileInfo infodb(PQCConfigFiles::CONTEXTMENU_DB());

    if(!infodb.exists() || !db.open()) {

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

}

void PQCScriptsContextMenu::detectSystemEntries() {

#ifdef Q_OS_WIN
    return;
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

    {
        if(!db.open()) {
            qWarning() << "Error opening contextmenu database:" << db.lastError().text();
            return;
        }

        QSqlQuery query(db);
        query.exec("DELETE FROM entries");
        query.clear();

        // Check for all entries
        for(int i = 0; i < m.size()/2; ++i) {

            QProcess p;
            p.setStandardOutputFile(QProcess::nullDevice());
            p.start("which", QStringList() << m[2*i+1]);
            p.waitForFinished();
            bool found = (p.exitCode() == 0);

            if(found) {

                QSqlQuery query(db);
                query.prepare("INSERT INTO entries (command,arguments,desc,close) VALUES(:cmd,:arg,:dsc,:cls)");
                query.bindValue(":cmd", m[2*i+1]);
                query.bindValue(":arg", "%f");
                query.bindValue(":dsc", m[2*i]);
                query.bindValue(":cls", "0");
                if(!query.exec())
                    qWarning() << "SQL error, contextmenu insert:" << query.lastError().text();

            }
        }

    }

}
