#include <pqc_migrateshortcuts.h>
#include <pqc_configfiles.h>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QFile>

void PQCMigrateShortcuts::migrate(QString oldVersion) {

    qDebug() << "args: oldVersion =" << oldVersion;

    QSqlDatabase db = QSqlDatabase::database("shortcuts");

    // in this case we stop
    if(oldVersion.startsWith("2") || oldVersion.startsWith("1")) {

        qDebug() << "Old version number if" << oldVersion << " - too old to use migrations. Setting up fresh database.";

        db.close();

        // backup current database
        QFile::remove(QString("%1.bak").arg(PQCConfigFiles::get().SHORTCUTS_DB()));
        QFile::copy(PQCConfigFiles::get().SHORTCUTS_DB(), QString("%1.bak").arg(PQCConfigFiles::get().SHORTCUTS_DB()));
        QFile::remove(PQCConfigFiles::get().SHORTCUTS_DB());

        // create new default database
        if(!QFile::copy(":/shortcuts.db", PQCConfigFiles::get().SHORTCUTS_DB()))
            qWarning() << "Unable to create shortcuts database";
        else {
            QFile file(PQCConfigFiles::get().SHORTCUTS_DB());
            file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
        }

        return;
    }

    db.transaction();

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
    if(oldVersion != "dev" && versions.indexOf(oldVersion) == -1) {
        qCritical() << "WARNING: The current version number needs to be added to the migrate() functions";
    }

    int iVersion = 0;
    if(oldVersion == "dev")
        iVersion = versions.length()-1;
    else if(oldVersion != "" && versions.contains(oldVersion))
        // we do a +1 as we are on the found version and don't need to migrate to it
        iVersion = versions.indexOf(oldVersion)+1;

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

        }

    }

    db.commit();

}
