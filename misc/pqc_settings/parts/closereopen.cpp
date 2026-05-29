void PQCSettings::commitDatabase() {

    qDebug() << "";

    QSqlDatabase db = QSqlDatabase::database("settings");

    dbCommitTimer->stop();

    if(dbIsTransaction) {
        db.commit();
        PQCSettingsCPP::get().readDB();
        dbIsTransaction = false;
        if(db.lastError().text().trimmed().length())
            qWarning() << "ERROR committing database:" << db.lastError().text();
    }

}

void PQCSettings::closeDatabase() {

    qDebug() << "";

    commitDatabase();

    QSqlDatabase::database("settings").close();

}

void PQCSettings::reopenDatabase() {

    qDebug() << "";

    if(!QSqlDatabase::database("settings").open())
        qWarning() << "Unable to reopen database";

}

