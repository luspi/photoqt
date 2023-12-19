/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

#ifndef PQCSETTINGS_H
#define PQCSETTINGS_H

#include <QObject>
#include <QtSql>
#include <QQmlPropertyMap>

class PQCSettings : public QQmlPropertyMap {

    Q_OBJECT

public:
    static PQCSettings& get() {
        static PQCSettings instance;
        return instance;
    }
    ~PQCSettings();

    PQCSettings(PQCSettings const&)     = delete;
    void operator=(PQCSettings const&) = delete;

    void setDefault(bool ignoreLanguage = false);

    void update(QString key, QVariant value);

    void readDB();

    bool backupDatabase();

    void closeDatabase();
    void reopenDatabase();

    QString verifyNameAndGetType(QString name);

    bool migrate(QString oldversion = "");

public Q_SLOTS:
    void updateFromCommandLine();
    void resetToDefault();

private:
    PQCSettings();

    QStringList dbtables;
    QSqlDatabase db;
    bool dbIsTransaction;
    QTimer *dbCommitTimer;

    bool readonly;
    void saveChangedValue(const QString &key, const QVariant &value);

#ifndef NDEBUG
    QStringList valid;
    QTimer *checkvalid;

#endif
private Q_SLOTS:
    void checkValidSlot();

};

#endif
