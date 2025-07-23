QString PQCSettings::verifyNameAndGetType(QString name) {

    QString tablename = "";
    QString settingname = "";

    for(auto &t : std::as_const(dbtables)) {

        if(name.startsWith(t)) {
            tablename = t;
            break;
        }

    }

    // invalid table name
    if(tablename == "")
        return "";

    settingname = name.last(name.size()-tablename.size());

    QSqlQuery query(QSqlDatabase::database("defaultsettings"));
    query.prepare(QString("SELECT datatype FROM `%1` WHERE `name`=:nme").arg(tablename));
    query.bindValue(":nme", settingname);
    if(!query.exec()) {
        qWarning() << "ERROR checking datatype for setting" << settingname;
        return "";
    }

    // invalid setting name
    if(!query.next())
        return "";

    QString ret = query.value(0).toString();
    query.clear();

    return ret;

}
