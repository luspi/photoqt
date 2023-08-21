#include <scripts/pqc_scriptscontextmenu.h>
#include <pqc_configfiles.h>

#include <QtDebug>
#include <QFileInfo>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRecord>

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
