// THIS FUNCTION IS NOT TO BE CALLED FROM INSIDE PQCSETTINGS!!
// It is only to be called whenever the class has been set up
// specifically for validating (see constructor).
bool PQCSettings::validateSettingsValues(bool skipDBHandling) {

    qDebug() << "";

    if(!skipDBHandling) {

        if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
            db = QSqlDatabase::addDatabase("QSQLITE3", "validatesettingsvalues");
        else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
            db = QSqlDatabase::addDatabase("QSQLITE", "validatesettingsvalues");
        db.setDatabaseName(PQCConfigFiles::get().USERSETTINGS_DB());

        if(!db.open())
            qWarning() << "Error opening database:" << db.lastError().text();

    }

    QSqlDatabase dbcheck;
    if(QSqlDatabase::isDriverAvailable("QSQLITE3"))
        dbcheck = QSqlDatabase::addDatabase("QSQLITE3", "checksettings");
    else if(QSqlDatabase::isDriverAvailable("QSQLITE"))
        dbcheck = QSqlDatabase::addDatabase("QSQLITE", "checksettings");
    else {
        qCritical() << "ERROR: SQLite driver not available. Available drivers are:" << QSqlDatabase::drivers().join(",");
        qCritical() << "PhotoQt cannot function without SQLite available.";
        qApp->quit();
        return false;
    }

    QFile::remove(PQCConfigFiles::get().CACHE_DIR()+"/photoqt_check.db");
    QFile::copy(":/checksettings.db", PQCConfigFiles::get().CACHE_DIR()+"/photoqt_check.db");
    QFile::setPermissions(PQCConfigFiles::get().CACHE_DIR()+"/photoqt_check.db",
                          QFileDevice::WriteOwner|QFileDevice::ReadOwner |
                          QFileDevice::ReadGroup);
    dbcheck.setDatabaseName(PQCConfigFiles::get().CACHE_DIR()+"/photoqt_check.db");

    if(!dbcheck.open())
        qWarning() << "Error opening default database:" << dbcheck.lastError().text();

    QSqlQuery queryCheck(dbcheck);
    queryCheck.prepare("SELECT tablename,setting,minvalue,maxvalue FROM 'entries'");

    if(!queryCheck.exec()) {
        qWarning() << "Error getting default data:" << queryCheck.lastError().text();
        queryCheck.clear();
        QFile::remove(PQCConfigFiles::get().CACHE_DIR()+"/photoqt_check.db");
        return false;
    }

    QList<QList<QVariant> > toUpdate;

    // loop over check data
    while(queryCheck.next()) {

        const QString table = queryCheck.value(0).toString();
        const QString setting = queryCheck.value(1).toString();
        const double minValue = queryCheck.value(2).toDouble();
        const double maxValue = queryCheck.value(3).toDouble();

        QSqlQuery check(db);
        check.prepare(QString("SELECT value,datatype FROM '%1' WHERE name=:name").arg(table));
        check.bindValue(":name", setting);
        if(!check.exec()) {
            qWarning() << QString("Error checking entry '%1':").arg(setting) << check.lastError().text();
            continue;
        }
        if(check.next()) {

            const QString dt = check.value(1).toString();
            const double value = check.value(0).toDouble();

            if(value < minValue)
                toUpdate << (QList<QVariant>() << table << setting << dt << minValue);
            else if(value > maxValue)
                toUpdate << (QList<QVariant>() << table << setting << dt << maxValue);

        }

        check.clear();

    }

    queryCheck.clear();

    // update what needs fixing
    for(int i = 0; i < toUpdate.size(); ++i) {

        QList<QVariant> lst = toUpdate.at(i);

        QSqlQuery query(db);

        query.prepare(QString("UPDATE %1 SET value=:val WHERE name=:name").arg(lst.at(0).toString()));
        query.bindValue(":name", lst.at(1).toString());
        if(lst.at(2).toString() == "double")
            query.bindValue(":val", lst.at(3).toDouble());
        if(lst.at(2).toString() == "int")
            query.bindValue(":val", static_cast<int>(lst.at(3).toDouble()));

        if(!query.exec()) {
            qWarning() << QString("Error updating entry '%1':").arg(lst.at(1).toString()) << query.lastError().text();
            continue;
        }

        query.clear();

    }

    dbcheck.close();

    if(!skipDBHandling) {
        db.close();
    }

    QFile file(PQCConfigFiles::get().CACHE_DIR()+"/photoqt_check.db");
    if(!file.remove())
        qWarning() << "ERROR: Unable to remove check db:" << file.errorString();

    return true;

}
