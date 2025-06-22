// THIS FUNCTION IS NOT TO BE CALLED FROM INSIDE PQCSETTINGS!!
// It is only to be called whenever the class has been set up
// specifically for validating (see constructor).
bool PQCSettings::validateSettingsDatabase(bool skipDBHandling) {

    qDebug() << "";

    if(!skipDBHandling) {

        // the db does not exist -> create it and finish
        if(!QFile::exists(PQCConfigFiles::get().USERSETTINGS_DB())) {
            if(!QFile::copy(":/usersettings.db", PQCConfigFiles::get().USERSETTINGS_DB()))
                qWarning() << "Unable to (re-)create default settings database";
            else {
                QFile file(PQCConfigFiles::get().USERSETTINGS_DB());
                file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
            }
            return true;
        }

        if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
            db = QSqlDatabase::addDatabase("QSQLITE3", "settings");
        else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
            db = QSqlDatabase::addDatabase("QSQLITE", "settings");
        db.setDatabaseName(PQCConfigFiles::get().USERSETTINGS_DB());

        if(!db.open()) {
            qWarning() << "Error opening database:" << db.lastError().text();
            return false;
        }


        if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
            dbDefault = QSqlDatabase::addDatabase("QSQLITE3", "defaultsettings");
        else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
            dbDefault = QSqlDatabase::addDatabase("QSQLITE", "defaultsettings");
        QFile::remove(PQCConfigFiles::get().DEFAULTSETTINGS_DB());
        QFile::copy(":/defaultsettings.db", PQCConfigFiles::get().DEFAULTSETTINGS_DB());
        dbDefault.setDatabaseName(PQCConfigFiles::get().DEFAULTSETTINGS_DB());
        if(!dbDefault.open()) {
            qWarning() << "ERROR opening default database:" << dbDefault.lastError().text();
            return false;
        }

    }

    // read the list of all tables from the default database
    QStringList tables;

    QSqlQuery queryTables("SELECT name FROM sqlite_master WHERE type IN ('table','view') AND name NOT LIKE 'sqlite_%' ORDER BY 1;", dbDefault);
    if(!queryTables.exec()) {
        qWarning() << "Error getting list of tables:" << queryTables.lastError().text();
        queryTables.clear();
        return false;
    }

    QStringList whichTablesToAdd;

    // iterate over all tables
    while(queryTables.next()) {

        const QString tab = queryTables.value(0).toString();
        tables << tab;

        // make sure all tables exist in installed db

        QSqlQuery queryTabIns(db);
        if(!queryTabIns.exec(QString("SELECT COUNT(name) as cnt FROM sqlite_master WHERE type='table' AND name='%1'").arg(tab))) {
            qWarning() << QString("Error checking table '%1' existence:").arg(tab) << queryTabIns.lastError().text();
            continue;
        }

        queryTabIns.next();

        int cnt = queryTabIns.value(0).toInt();
        if(cnt == 0)
            whichTablesToAdd << tab;

        queryTabIns.clear();
    }

    queryTables.clear();

    // add missing tables
    if(whichTablesToAdd.length() > 0) {

        for(const QString &tab : std::as_const(whichTablesToAdd)) {

            QSqlQuery queryTabIns(db);
            if(!queryTabIns.exec(QString("CREATE TABLE %1 ('name' TEXT UNIQUE, 'value' TEXT, 'datatype' TEXT)").arg(tab)))
                qWarning() << QString("ERROR adding missing table '%1':").arg(tab) << queryTabIns.lastError().text();
            queryTabIns.clear();
        }

    }

    if(!skipDBHandling) {
        dbDefault.close();
        db.close();
    }

    return true;

}
