/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

#ifndef PQCSHORTCUTS_H
#define PQCSHORTCUTS_H

#include <QObject>
#include <QtSql/QSqlDatabase>

class QTimer;

class PQCShortcuts : public QObject {

    Q_OBJECT

public:
    static PQCShortcuts& get() {
        static PQCShortcuts instance;
        return instance;
    }
    ~PQCShortcuts();

    PQCShortcuts(PQCShortcuts const&)     = delete;
    void operator=(PQCShortcuts const&) = delete;

    Q_INVOKABLE void setDefault();

    Q_INVOKABLE QVariantList getCommandsForShortcut(QString combo);
    Q_INVOKABLE QVariantList getAllCurrentShortcuts();
    Q_INVOKABLE void saveAllCurrentShortcuts(QVariantList list);
    Q_INVOKABLE int getNextCommandInCycle(QString combo, int timeout, int maxCmd);
    Q_INVOKABLE void resetCommandCycle(QString combo);
    Q_INVOKABLE QString convertKeyCodeToText(int id);

    Q_INVOKABLE bool migrate(QString oldversion = "");

    bool backupDatabase();
    void closeDatabase();
    void reopenDatabase();

public Q_SLOTS:
    void readDB();
    void resetToDefault();

private:
    PQCShortcuts();

    QStringList shortcutsOrder;
    QMap<QString,QVariantList> shortcuts;
    QMap<QString, QList<qint64>> commandCycle;

    QSqlDatabase db;
    bool readonly;
    bool dbIsTransaction;
    QTimer *dbCommitTimer;

Q_SIGNALS:
    void aboutChanged();

};

#endif // PQCSHORTCUTS_H
