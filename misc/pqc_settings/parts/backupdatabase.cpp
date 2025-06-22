bool PQCSettings::backupDatabase() {

    // make sure all changes are written to db
    if(dbIsTransaction) {
        dbCommitTimer->stop();
        db.commit();
        dbIsTransaction = false;
        if(db.lastError().text().trimmed().length())
            qWarning() << "ERROR committing database:" << db.lastError().text();
    }

    // backup file
    if(QFile::exists(QString("%1.bak").arg(PQCConfigFiles::get().USERSETTINGS_DB())))
        QFile::remove(QString("%1.bak").arg(PQCConfigFiles::get().USERSETTINGS_DB()));
    QFile file(PQCConfigFiles::get().USERSETTINGS_DB());
    return file.copy(QString("%1.bak").arg(PQCConfigFiles::get().USERSETTINGS_DB()));

}
