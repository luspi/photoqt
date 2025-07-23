// return codes:
// -1 := error
//  0 := success
//  1 := old, don't migrate, need to setup fresh
int PQCSettings::migrate(QString oldversion) {

    qDebug() << "args: oldversion =" << oldversion;

    QSqlDatabase db = QSqlDatabase::database("settings");

    dbCommitTimer->stop();

    if(dbIsTransaction) {
        db.commit();
        dbIsTransaction = false;
        if(db.lastError().text().trimmed().length())
            qWarning() << "ERROR committing database:" << db.lastError().text();
    }

    db.transaction();

    if(oldversion == "") {
        // first we need to find the version in a database that has not yet been read
        QSqlQuery query(db);
        if(!query.exec("SELECT `value` FROM general WHERE `name`='Version'")) {
            qCritical() << "Unable to find previous version number:" << query.lastError().text();
        } else {
            query.next();
            oldversion = query.value(0).toString();
            qDebug() << "migrating from version" << oldversion << "to" << PQMVERSION;
        }
        query.clear();
    }

    // in this case we stop and return 1 meaning that we should simply set up fresh
    if(oldversion.startsWith("2") || oldversion.startsWith("1")) {
        return 1;
    }

    /*************************************************************************/
    /**************************** IMPORTANT NOTE *****************************/
    /*************************************************************************/
    //                                                                       //
    // BEFORE EVERY NEW RELEASE THE NEW VERSION NUMBER HAS TO BE ADDED BELOW //
    //                                                                       //
    // and the same needs to be done in pqc_shortcuts.cpp:migrate()          //
    /*************************************************************************/

    QStringList versions;
    versions << "4.0" << "4.1" << "4.2" << "4.3" << "4.4" << "4.5" << "4.6" << "4.7" << "4.8" << "4.8.1" << "4.9" << "4.9.1" << "4.9.2";
    // when removing the 'dev' value, check below for any if statement involving 'dev'!

    // this is a safety check to make sure we don't forget the above check
    if(oldversion != "dev" && versions.indexOf(oldversion) == -1 && !oldversion.startsWith("3")) {
        qCritical() << "WARNING: The current version number needs to be added to the migrate() functions";
    }

    int iVersion = 0;
    if(oldversion == "dev")
        iVersion = versions.length()-1;
    else if(oldversion != "" && versions.contains(oldversion))
        // we do a +1 as we are on the found version and don't need to migrate to it
        iVersion = versions.indexOf(oldversion)+1;

    // we iterate through all migrations one by one

    for(int iV = iVersion; iV < versions.length(); ++iV) {

        QString curVer = versions[iV];

        ////////////////////////////////////
        // first do any more complicated migrations

        // update to v4.0
        if(curVer == "4.0") {

            /******************************************************/
            // change table name 'openfile' to 'filedialog'

            QSqlQuery query(db);

            if(!query.exec("SELECT COUNT(name) FROM sqlite_master WHERE type='table' AND name='filedialog'"))
                qCritical() << "Unable to check if table named 'filedialog' exists:" << query.lastError().text();
            else {

                query.next();
                if(query.value(0).toInt() == 0) {

                    QSqlQuery queryUpdate(db);
                    if(!queryUpdate.exec("ALTER TABLE 'openfile' RENAME TO 'filedialog'"))
                        qCritical() << "ERROR renaming 'openfile' to 'filedialog':" << queryUpdate.lastError().text();
                    queryUpdate.clear();

                }

                query.clear();

            }

            /******************************************************/
            // adjust ZoomLevel value

            QVariant oldValue = migrationHelperGetOldValue("filedialog", "ZoomLevel");
            if(oldValue.isValid() && !oldValue.isNull()) {
                migrationHelperSetNewValue("filedialog", "Zoom", (oldValue.toInt()-9)*2.5);
                migrationHelperRemoveValue("filedialog", "ZoomLevel");
            }

            /******************************************************/
            // adjust list for AdvancedSortDateCriteria

            QVariant oldSort = migrationHelperGetOldValue("imageview", "AdvancedSortDateCriteria");
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

        } else if(curVer == "4.4") {

            /******************************************************/
            // adjust value of 'PreviewColorIntensity' in 'filedialog'

            QVariant oldValue = migrationHelperGetOldValue("filedialog", "PreviewColorIntensity");
            if(!oldValue.isNull() && oldValue.isValid()) {
                int val = oldValue.toInt();
                if(val <= 10)
                    migrationHelperSetNewValue("filedialog", "PreviewColorIntensity", 10*val);
            }

        } else if(curVer == "4.7") {

            /******************************************************/
            // convert color names

            QString oldValue = migrationHelperGetOldValue("interface", "AccentColor").toString();

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

            /******************************************************/
            // make sure cache is set to at least 256

            QVariant oldCache = migrationHelperGetOldValue("imageview", "Cache");
            if(oldCache.isValid() && !oldCache.isNull() && oldCache.toInt() < 256)
                migrationHelperSetNewValue("interface", "AccentColor", 256);

        } else if(curVer == "4.8") {

            migrationHelperSetNewValue("imageview", "ZoomToCenter", 0);

        } else if(curVer == "4.9") {

            // first make sure all tables have UNIQUE constraint set for name column
            // it is not possible to add such a constraint to an existing table in sqlite
            // Thus we first create a new table with the proper structure, then copy all data
            // over, delete the old table, and then rename the new table to the old name.

            const QStringList tbls = {"filedialog", "filetypes", "general", "imageview", "interface",
                                      "mainmenu", "mapview", "metadata", "slideshow", "thumbnails"};

            for(const QString &t : tbls) {

                QSqlQuery queryUnq(db);

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

            QVariant oldDup = migrationHelperGetOldValue("interface", "WindowButtonsDuplicateDecorationButtons");

            QString newValue = "ontop_0|0|1:://::fullscreen_0|0|1";
            if(oldDup.isValid() && !oldDup.isNull() && oldDup.toInt() == 1)
                newValue = "ontop_0|1|1:://::minimize_0|1|1:://::maximize_0|1|1:://::fullscreen_0|0|1:://::close_0|0|1";

            QVariant oldNav = migrationHelperGetOldValue("interface", "NavigationTopRight");
            QVariant oldNavAlw = migrationHelperGetOldValue("interface", "NavigationTopRightAlways");
            QVariant oldNavPos = migrationHelperGetOldValue("interface", "NavigationTopRightLeftRight");

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

            QString oldLayout = migrationHelperGetOldValue("filedialog", "Layout").toString();
            if(oldLayout == "icons")
                migrationHelperSetNewValue("filedialog", "Layout", "grid");

        } else if(curVer == "4.9.1") {

            // a bug in 4.9.1 might have reduced the thumbnails size down to 1px
            int oldVal = migrationHelperGetOldValue("thumbnails", "Size").toInt();
            if(oldVal < 32)
                migrationHelperSetNewValue("thumbnails", "Size", 32);

        }

        ////////////////////////////////////
        // then rename any settings

        QMap<QString, QList<QStringList> > migrateNames = {
            {"4.0", {{"ZoomLevel", "filedialog", "Zoom", "filedialog"},
                     {"UserPlacesUser", "filedialog", "Places", "filedialog"},
                     {"UserPlacesVolumes", "filedialog", "Devices", "filedialog"},
                     {"UserPlacesWidth", "filedialog", "PlacesWidth", "filedialog"},
                     {"DefaultView", "filedialog", "Layout", "filedialog"},
                     {"PopoutFileSaveAs", "interface", "PopoutExport", "interface"},
                     {"AdvancedSortExifDateCriteria", "imageview", "AdvancedSortDateCriteria", "imageview"},
                     {"PopoutSlideShowSettings", "imageview", "PopoutSlideshowSetup", "interface"},
                     {"PopoutSlideShowControls", "imageview", "PopoutSlideshowControls", "interface"}}},
            {"4.5", {{"MusicFile", "slideshow", "MusicFiles", "slideshow"},
                     {"PopoutFileDialogKeepOpen", "interface", "PopoutFileDialogNonModal", "interface"},
                     {"PopoutMapExplorerKeepOpen", "interface", "PopoutMapExplorerNonModal", "interface"},
                     {"CheckForPhotoSphere", "filetypes", "PhotoSphereAutoLoad", "filetypes"}}},
            {"4.9", {{"InterpolationThreshold", "imageview", "", ""}}}
        };

        migrationHelperChangeSettingsName(migrateNames, curVer);

    }

    db.commit();

    validateSettingsDatabase(true);
    validateSettingsValues(true);

    return 0;

}

void PQCSettings::migrationHelperChangeSettingsName(QMap<QString, QList<QStringList> > mig, QString curVer) {

    qDebug() << "args: mig =" << mig;
    qDebug() << "args: curVer =" << curVer;

    QSqlDatabase db = QSqlDatabase::database("settings");

    for(auto i = mig.cbegin(), end = mig.cend(); i != end; ++i) {

        const QString v = i.key();
        if(v == curVer) {

            const QList<QStringList> vals = i.value();
            for(const QStringList &entry : vals) {

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

            break;

        }

    }

}

QVariant PQCSettings::migrationHelperGetOldValue(QString table, QString setting) {

    qDebug() << "args: table =" << table;
    qDebug() << "args: setting =" << setting;

    QSqlQuery query(QSqlDatabase::database("settings"));

    query.prepare(QString("SELECT `value` FROM `%1` WHERE `name`=:nme").arg(table));
    query.bindValue(":nme", setting);

    if(!query.exec())
        qCritical() << "Unable to get current" << setting << "value:" << query.lastError().text();
    else {

        if(query.next())
            return query.value(0);

    }

    return QVariant();

}

void PQCSettings::migrationHelperRemoveValue(QString table, QString setting) {

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

void PQCSettings::migrationHelperInsertValue(QString table, QString setting, QVariantList value) {

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

void PQCSettings::migrationHelperSetNewValue(QString table, QString setting, QVariant value) {

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
