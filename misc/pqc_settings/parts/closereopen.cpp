void PQCSettings::closeDatabase() {

    qDebug() << "";

    dbCommitTimer->stop();

    if(dbIsTransaction) {
        db.commit();
        dbIsTransaction = false;
        if(db.lastError().text().trimmed().length())
            qWarning() << "ERROR committing database:" << db.lastError().text();
    }

    db.close();

}

void PQCSettings::reopenDatabase() {

    qDebug() << "";

    if(!db.open())
        qWarning() << "Unable to reopen database";

}

