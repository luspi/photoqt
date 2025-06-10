// /**************************************************************************
//  **                                                                      **
//  ** Copyright (C) 2011-2025 Lukas Spies                                  **
//  ** Contact: https://photoqt.org                                         **
//  **                                                                      **
//  ** This file is part of PhotoQt.                                        **
//  **                                                                      **
//  ** PhotoQt is free software: you can redistribute it and/or modify      **
//  ** it under the terms of the GNU General Public License as published by **
//  ** the Free Software Foundation, either version 2 of the License, or    **
//  ** (at your option) any later version.                                  **
//  **                                                                      **
//  ** PhotoQt is distributed in the hope that it will be useful,           **
//  ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
//  ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
//  ** GNU General Public License for more details.                         **
//  **                                                                      **
//  ** You should have received a copy of the GNU General Public License    **
//  ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
//  **                                                                      **
//  **************************************************************************/

// #include <QJSValue>
// #include <QMessageBox>
// #include <qlogging.h>   // needed in this form to compile with Qt 6.2
// #include <pqc_settingsextensions.h>
// #include <pqc_configfiles.h>
// #include <pqc_notify.h>
// #include <pqc_extensionshandler.h>
// #include <pqc_settingsdb.h>

// PQCSettingsExtensions::PQCSettingsExtensions() : QQmlPropertyMap(this, nullptr) {

//     db = PQCSettingsDB::get().getUserDB();
//     readonly = PQCSettingsDB::get().getReadonly();

//     readDB();

//     // if a value is changed in the ui, write to database
//     connect(this, &QQmlPropertyMap::valueChanged, this, &PQCSettingsExtensions::saveChangedValue);

//     connect(&PQCNotify::get(), &PQCNotify::resetSettingsToDefault, this, &PQCSettingsExtensions::resetToDefault);

// }

// PQCSettingsExtensions::~PQCSettingsExtensions() {}

// void PQCSettingsExtensions::readDB() {

//     qDebug() << "";

//     QString table = "extensions";

//     QSqlQuery query(*db);
//     query.prepare("SELECT `name`,`value`,`datatype` FROM 'extensions'");
//     if(!query.exec())
//         qCritical() << "SQL Query error (extensions):" << query.lastError().text();

//     while(query.next()) {

//         QString name = query.value(0).toString();
//         QString value = query.value(1).toString();
//         QString datatype = query.value(2).toString();

//         if(datatype == "int")
//             this->insert(name, value.toInt());
//         else if(datatype == "double")
//             this->insert(name, value.toDouble());
//         else if(datatype == "bool")
//             this->insert(name, static_cast<bool>(value.toInt()));
//         else if(datatype == "list") {
//             if(value.contains(":://::"))
//                 this->insert(name, value.split(":://::"));
//             else if(value != "")
//                 this->insert(name, QStringList() << value);
//             else
//                 this->insert(name, QStringList());
//         } else if(datatype == "point") {
//             const QStringList parts = value.split(",");
//             if(parts.length() == 2)
//                 this->insert(name, QPoint(parts[0].toInt(), parts[1].toInt()));
//             else {
//                 qWarning() << QString("ERROR: invalid format of QPoint for setting '%1': '%2'").arg(name, value);
//                 this->insert(name, QPoint(0,0));
//             }
//         } else if(datatype == "size") {
//             const QStringList parts = value.split(",");
//             if(parts.length() == 2)
//                 this->insert(name, QSize(parts[0].toInt(), parts[1].toInt()));
//             else {
//                 qWarning() << QString("ERROR: invalid format of QSize for setting '%1': '%2'").arg(name, value);
//                 this->insert(name, QSize(0,0));
//             }
//         } else if(datatype == "string")
//             this->insert(name, value);
//         else if(datatype != "")
//             qCritical() << QString("ERROR: datatype not handled for setting '%1':").arg(name) << datatype;
//         else
//             qDebug() << QString("empty datatype found for setting '%1' -> ignoring").arg(name);

//     }

// }

// void PQCSettingsExtensions::saveChangedValue(const QString &key, const QVariant &value) {

//     qDebug() << "args: key =" << key;
//     qDebug() << "args: value =" << value;
//     qDebug() << "readonly =" << readonly;

//     if(readonly) return;

//     PQCSettingsDB::get().pauseTransactionsTimer();

//     QSqlQuery query(*db);

//     PQCSettingsDB::get().startTransactions();

//     // Using a placeholder also for table name causes an sqlite 'parameter count mismatch' error
//     // the 'on conflict' cause performs an update if the value already exists and the insert thus failed
//     query.prepare("INSERT INTO 'extensions' (`name`,`value`,`datatype`) VALUES (:nme, :val, :dat) ON CONFLICT (`name`) DO UPDATE SET `value`=:valupdate");

//     query.bindValue(":nme", key);

//     // we convert the value to a string
//     QString val = "";
//     if(value.typeId() == QMetaType::Bool) {
//         val = QString::number(value.toInt());
//         query.bindValue(":dat", "bool");
//     } else if(value.typeId() == QMetaType::Int) {
//         val = QString::number(value.toInt());
//         query.bindValue(":dat", "int");
//     } else if(value.typeId() == QMetaType::QStringList) {
//         val = value.toStringList().join(":://::");
//         query.bindValue(":dat", "list");
//     } else if(value.typeId() == QMetaType::QPoint) {
//         val = QString("%1,%2").arg(value.toPoint().x()).arg(value.toPoint().y());
//         query.bindValue(":dat", "point");
//     } else if(value.typeId() == QMetaType::QPointF) {
//         val = QString("%1,%2").arg(value.toPointF().x()).arg(value.toPointF().y());
//         query.bindValue(":dat", "point");
//     } else if(value.typeId() == QMetaType::QSize) {
//         val = QString("%1,%2").arg(value.toSize().width()).arg(value.toSize().height());
//         query.bindValue(":dat", "size");
//     } else if(value.typeId() == QMetaType::QSizeF) {
//         val = QString("%1,%2").arg(value.toSizeF().width()).arg(value.toSizeF().height());
//         query.bindValue(":dat", "size");
//     } else if(value.canConvert<QJSValue>() && value.value<QJSValue>().isArray()) {
//         QStringList ret;
//         QJSValue _val = value.value<QJSValue>();
//         const int length = _val.property("length").toInt();
//         for(int i = 0; i < length; ++i)
//             ret << _val.property(i).toString();
//         val = ret.join(":://::");
//         query.bindValue(":dat", "list");
//     } else {
//         val = value.toString();
//         query.bindValue(":dat", "string");
//     }

//     query.bindValue(":val", val);
//     query.bindValue(":valupdate", val);

//     // and update database
//     if(!query.exec()) {
//         qWarning() << "SQL Error:" << query.lastError().text();
//         qWarning() << "Executed query:" << query.lastQuery();
//     }

//     PQCSettingsDB::get().startTransactionsTimer();

// }

// void PQCSettingsExtensions::setupFresh() {

//     qDebug() << "";

//     // at this point we can assume that the settings.db has already been copied
//     // we only need to add any setting from the extensions

//     PQCSettingsDB::get().pauseTransactionsTimer();
//     PQCSettingsDB::get().startTransactions();

//     const QStringList allext = PQCExtensionsHandler::get().getExtensions();
//     for(const QString &ext : allext) {

//         const QList<QStringList> settings = PQCExtensionsHandler::get().getSettings(ext);

//         for(const QStringList &set : settings) {

//             if(set.length() != 4) {
//                 qWarning() << "Invalid settings detected:" << set;
//                 continue;
//             }

//             QSqlQuery query(*db);
//             query.prepare(QString("INSERT OR IGNORE INTO `%1` (`name`, `value`, `datatype`) VALUES (:nme, :val, :dat)").arg(set[1]));
//             query.bindValue(":nme", set[0]);
//             query.bindValue(":val", set[3]);
//             query.bindValue(":dat", set[2]);

//             if(!query.exec()) {
//                 qWarning() << "ERROR inserting setting:" << query.lastError().text();
//                 qWarning() << "Faulty setting:" << set;
//             }

//             query.clear();

//         }

//     }

//     PQCSettingsDB::get().commitTransactions();

//     readDB();

// }

// void PQCSettingsExtensions::setDefault() {

//     qDebug() << "readonly =" << readonly;

//     if(readonly) return;

//     QSqlQuery query(*db);
//     if(!query.exec("DELETE FROM 'extensions'"))
//         qWarning() << "SQL Error:" << query.lastError().text();

//     setupFresh();

// }

// void PQCSettingsExtensions::resetToDefault() {

//     setDefault();
//     readDB();

// }
