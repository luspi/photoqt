#include <pqc_migratesettings.h>
#include <pqc_configfiles.h>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QFile>

void PQCMigrateSettings::migrate(const QString &oldVersion, const QStringList allVersions) {

    qDebug() << "args: oldVersion =" << oldVersion;

    QSqlDatabase db = QSqlDatabase::database("settings");

    // in this case we stop
    if(oldVersion.startsWith("2") || oldVersion.startsWith("1")) {

        qDebug() << "Old version number if" << oldVersion << " - too old to use migrations. Setting up fresh database.";

        db.close();

        // backup current database
        QFile::remove(QString("%1.bak").arg(PQCConfigFiles::get().USERSETTINGS_DB()));
        QFile::copy(PQCConfigFiles::get().USERSETTINGS_DB(), QString("%1.bak").arg(PQCConfigFiles::get().USERSETTINGS_DB()));
        QFile::remove(PQCConfigFiles::get().USERSETTINGS_DB());

        // create new default database
        if(!QFile::copy(":/usersettings.db", PQCConfigFiles::get().USERSETTINGS_DB()))
            qWarning() << "Unable to create settings database";
        else {
            QFile file(PQCConfigFiles::get().USERSETTINGS_DB());
            file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
        }

        return;
    }

    db.transaction();

    // this is a safety check to make sure we don't forget the above check
    if(oldVersion != "dev" && allVersions.indexOf(oldVersion) == -1 && !oldVersion.startsWith("3")) {
        qCritical() << "WARNING: The current version number needs to be added to the migrate() functions";
    }

    int iVersion = 0;
    if(oldVersion == "dev")
        iVersion = allVersions.length()-1;
    else if(oldVersion != "" && allVersions.contains(oldVersion))
        // we do a +1 as we are on the found version and don't need to migrate to it
        iVersion = allVersions.indexOf(oldVersion)+1;

    // we iterate through all migrations one by one

    for(int iV = iVersion; iV < allVersions.length(); ++iV) {

        const QString curVer = allVersions[iV];

        ////////////////////////////////////
        // first do any more complicated migrations

        if(curVer == "4.0")
            migrate400();

        else if(curVer == "4.4")
            migrate440();

        else if(curVer == "4.5")
            migrate450();

        else if(curVer == "4.7")
            migrate470();

        else if(curVer == "4.8")
            migrate480();

        else if(curVer == "4.9")
            migrate490();

        else if(curVer == "4.9.1")
            migrate491();

        else if(curVer == "5.0")
            migrate500();

        else if(curVer == "5.1")
            migrate510();

    }

    db.commit();

}

/******************************************************/
/******************************************************/

void PQCMigrateSettings::migrate510() {

    qDebug() << "";

    migrationHelperChangeSettingsName({{"KeepLastLocation", "filedialog", "StartupRestorePrevious", "filedialog"}});

}

/******************************************************/
/******************************************************/

void PQCMigrateSettings::migrate500() {

    qDebug() << "";

    /**********************************************************/
    // PQCSettings.imageviewMinimapSizeLevel must be incremented by 1

    const int oldVal = migrationHelperGetOldValue("imageview", "MinimapSizeLevel").toInt();
    if(oldVal < 4)
        migrationHelperSetNewValue("imageview", "MinimapSizeLevel", oldVal+1);

    /**********************************************************/
    // PQCSettings.extensions -> extensions settings


}

/******************************************************/
/******************************************************/

void PQCMigrateSettings::migrate491() {

    qDebug() << "";

    // a bug in 4.9.1 might have reduced the thumbnails size down to 1px
    const int oldVal = migrationHelperGetOldValue("thumbnails", "Size").toInt();
    if(oldVal < 32)
        migrationHelperSetNewValue("thumbnails", "Size", 32);

}

/******************************************************/
/******************************************************/

void PQCMigrateSettings::migrate490() {

    qDebug() << "";

    // first make sure all tables have UNIQUE constraint set for name column
    // it is not possible to add such a constraint to an existing table in sqlite
    // Thus we first create a new table with the proper structure, then copy all data
    // over, delete the old table, and then rename the new table to the old name.

    const QStringList tbls = {"filedialog", "filetypes", "general", "imageview", "interface",
                              "mainmenu", "mapview", "metadata", "slideshow", "thumbnails"};

    for(const QString &t : tbls) {

        QSqlQuery queryUnq(QSqlDatabase::database("settings"));

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

    const QVariant oldDup = migrationHelperGetOldValue("interface", "WindowButtonsDuplicateDecorationButtons");

    QString newValue = "ontop_0|0|1:://::fullscreen_0|0|1";
    if(oldDup.isValid() && !oldDup.isNull() && oldDup.toInt() == 1)
        newValue = "ontop_0|1|1:://::minimize_0|1|1:://::maximize_0|1|1:://::fullscreen_0|0|1:://::close_0|0|1";

    const QVariant oldNav = migrationHelperGetOldValue("interface", "NavigationTopRight");
    const QVariant oldNavAlw = migrationHelperGetOldValue("interface", "NavigationTopRightAlways");
    const QVariant oldNavPos = migrationHelperGetOldValue("interface", "NavigationTopRightLeftRight");

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

    const QString oldLayout = migrationHelperGetOldValue("filedialog", "Layout").toString();
    if(oldLayout == "icons")
        migrationHelperSetNewValue("filedialog", "Layout", "grid");

    /******************************************************/

    migrationHelperChangeSettingsName({{"InterpolationThreshold", "imageview", "", ""}});

}

/******************************************************/
/******************************************************/

void PQCMigrateSettings::migrate480() {

    qDebug() << "";

    migrationHelperSetNewValue("imageview", "ZoomToCenter", 0);

}

/******************************************************/
/******************************************************/

void PQCMigrateSettings::migrate470() {

    qDebug() << "";

    // convert color names

    const QString oldValue = migrationHelperGetOldValue("interface", "AccentColor").toString();

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

    // make sure cache is set to at least 256
    const QVariant oldCache = migrationHelperGetOldValue("imageview", "Cache");
    if(oldCache.isValid() && !oldCache.isNull() && oldCache.toInt() < 256)
        migrationHelperSetNewValue("interface", "AccentColor", 256);

}

/******************************************************/
/******************************************************/

void PQCMigrateSettings::migrate450() {

    qDebug() << "";

    migrationHelperChangeSettingsName({{"MusicFile", "slideshow", "MusicFiles", "slideshow"},
                                       {"PopoutFileDialogKeepOpen", "interface", "PopoutFileDialogNonModal", "interface"},
                                       {"PopoutMapExplorerKeepOpen", "interface", "PopoutMapExplorerNonModal", "interface"},
                                       {"CheckForPhotoSphere", "filetypes", "PhotoSphereAutoLoad", "filetypes"}});

}

/******************************************************/
/******************************************************/

void PQCMigrateSettings::migrate440() {

    qDebug() << "";

    // adjust value of 'PreviewColorIntensity' in 'filedialog'
    const QVariant oldValue = migrationHelperGetOldValue("filedialog", "PreviewColorIntensity");
    if(!oldValue.isNull() && oldValue.isValid()) {
        const int val = oldValue.toInt();
        if(val <= 10)
            migrationHelperSetNewValue("filedialog", "PreviewColorIntensity", 10*val);
    }

}

/******************************************************/
/******************************************************/

void PQCMigrateSettings::migrate400() {

    qDebug() << "";

    // change table name 'openfile' to 'filedialog'

    QSqlQuery query(QSqlDatabase::database("settings"));

    if(!query.exec("SELECT COUNT(name) FROM sqlite_master WHERE type='table' AND name='filedialog'"))
        qCritical() << "Unable to check if table named 'filedialog' exists:" << query.lastError().text();
    else {

        query.next();
        if(query.value(0).toInt() == 0) {

            QSqlQuery queryUpdate(QSqlDatabase::database("settings"));
            if(!queryUpdate.exec("ALTER TABLE 'openfile' RENAME TO 'filedialog'"))
                qCritical() << "ERROR renaming 'openfile' to 'filedialog':" << queryUpdate.lastError().text();
            queryUpdate.clear();

        }

        query.clear();

    }

    // adjust ZoomLevel value
    const QVariant oldValue = migrationHelperGetOldValue("filedialog", "ZoomLevel");
    if(oldValue.isValid() && !oldValue.isNull()) {
        migrationHelperSetNewValue("filedialog", "Zoom", (oldValue.toInt()-9)*2.5);
        migrationHelperRemoveValue("filedialog", "ZoomLevel");
    }

    // adjust list for AdvancedSortDateCriteria
    const QVariant oldSort = migrationHelperGetOldValue("imageview", "AdvancedSortDateCriteria");
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

    /******************************************************/

    migrationHelperChangeSettingsName({{"ZoomLevel", "filedialog", "Zoom", "filedialog"},
                                       {"UserPlacesUser", "filedialog", "Places", "filedialog"},
                                       {"UserPlacesVolumes", "filedialog", "Devices", "filedialog"},
                                       {"UserPlacesWidth", "filedialog", "PlacesWidth", "filedialog"},
                                       {"DefaultView", "filedialog", "Layout", "filedialog"},
                                       {"PopoutFileSaveAs", "interface", "PopoutExport", "interface"},
                                       {"AdvancedSortExifDateCriteria", "imageview", "AdvancedSortDateCriteria", "imageview"},
                                       {"PopoutSlideShowSettings", "imageview", "PopoutSlideshowSetup", "interface"},
                                       {"PopoutSlideShowControls", "imageview", "PopoutSlideshowControls", "interface"}});

}

/***********************************************************************/
/***********************************************************************/
/***********************************************************************/

void PQCMigrateSettings::migrationHelperChangeSettingsName(const QList<QStringList> &mig) {

    qDebug() << "args: mig =" << mig;

    QSqlDatabase db = QSqlDatabase::database("settings");

    for(const QStringList &entry : mig) {

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

}

QVariant PQCMigrateSettings::migrationHelperGetOldValue(const QString &table, const QString &setting) {

    qDebug() << "args: table =" << table;
    qDebug() << "args: setting =" << setting;

    QSqlQuery query(QSqlDatabase::database("settings"));

    query.prepare(QString("SELECT `value` FROM `%1` WHERE `name`=:nme").arg(table));
    query.bindValue(":nme", setting);

    if(!query.exec())
        qCritical() << "Unable to get current" << setting << "value:" << query.lastError().text();

    else if(query.next())
        return query.value(0);

    return QVariant();

}

void PQCMigrateSettings::migrationHelperRemoveValue(const QString &table, const QString &setting) {

    qDebug() << "args: table =" << table;
    qDebug() << "args: setting =" << setting;

    QSqlQuery query(QSqlDatabase::database("settings"));

    query.prepare(QString("DELETE FROM `%1` WHERE `name`=:nme").arg(table));
    query.bindValue(":nme", setting);
    if(!query.exec()) {
        qWarning() << "Failed to delete old entry:" << query.lastError().text();
        qWarning() << "Failed migration:" << setting;
    }

    query.clear();

}

void PQCMigrateSettings::migrationHelperInsertValue(const QString &table, const QString &setting, const QVariantList &value) {

    qDebug() << "args: table =" << table;
    qDebug() << "args: setting =" << setting;
    qDebug() << "args: value =" << value;

    QSqlQuery query(QSqlDatabase::database("settings"));

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

void PQCMigrateSettings::migrationHelperSetNewValue(const QString &table, const QString &setting, const QVariant &value) {

    qDebug() << "args: table =" << table;
    qDebug() << "args: setting =" << setting;
    qDebug() << "args: value =" << value;

    QSqlQuery query(QSqlDatabase::database("settings"));
    query.prepare(QString("UPDATE `%1` SET `value`=:val WHERE `name`=:nme").arg(table));
    query.bindValue(":nme", setting);
    query.bindValue(":val", value);
    if(!query.exec())
        qCritical() << "ERROR updating" << setting << "value:" << query.lastError().text();
    query.clear();

}
