#include <pqc_migrateimageplugins.h>
#include <pqc_configfiles.h>
#include <pqc_imagehandler.h>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>

void PQCMigrateImagePlugins::migrate(const QString &oldVersion, const QStringList &allVersions) {

    qDebug() << "args: oldVersion =" << oldVersion;

    // this is a safety check to make sure we don't forget the above check
    if(oldVersion != "dev" && allVersions.indexOf(oldVersion) == -1 && !oldVersion.startsWith("3")) {
        qCritical() << "WARNING: The current version number needs to be added to the migrate() functions";
    }

    int iVersion = 0;
    if(oldVersion == "dev")
        iVersion = allVersions.length()-1;
    else if(!oldVersion.isEmpty() && allVersions.contains(oldVersion))
        // we do a +1 as we are on the found version and don't need to migrate to it
        iVersion = allVersions.indexOf(oldVersion)+1;

    // we iterate through all migrations one by one

    for(int iV = iVersion; iV < allVersions.length(); ++iV) {

        const QString curVer = allVersions[iV];

        ////////////////////////////////////

        if(curVer == "5.4")
            migrate540();

    }

}

/******************************************************/
/******************************************************/

void PQCMigrateImagePlugins::migrate540() {

    qDebug() << "";

    const QString fn = PQCConfigFiles::get().CONFIG_DIR() % "/imageformats.db";
    if(!QFileInfo::exists(fn))
        return;

    QSqlDatabase db;
    if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
        db = QSqlDatabase::addDatabase("QSQLITE3", "oldimageformats");
    else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
        db = QSqlDatabase::addDatabase("QSQLITE", "oldimageformats");

    db.setDatabaseName(fn);
    if(!db.open())
        return;

    QSqlQuery query(db);
    if(!query.exec("SELECT uniqueid,enabled FROM imageformats"))
        return;

    while(query.next()) {

        const int uniqueid = query.value("description").toInt();
        const int enabled = query.value("enabled").toInt();

        PQCImageHandler::get().setAllEnabled(uniqueid, enabled);

    }

    query.clear();
    db.close();
    QSqlDatabase::removeDatabase("oldimageformats");

    // try to backup file and remove it then to never re-migrate it
    QFile::remove(fn % ".bak");
    QFile::copy(fn, fn % ".bak");
    QFile::remove(fn);

}
