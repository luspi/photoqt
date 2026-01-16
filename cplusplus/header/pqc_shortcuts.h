/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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
#pragma once

#include <QObject>
#include <QtSql/QSqlDatabase>
#include <QQmlEngine>

class QTimer;

/*************************************************************/
/*************************************************************/
//
//      NOTE: This singleton CANNOT be used from C++.
//            It can ONLY be used from QML.
//
/*************************************************************/
/*************************************************************/

class PQCShortcuts : public QObject {

    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit PQCShortcuts();
    ~PQCShortcuts();

    Q_INVOKABLE void setDefault();

    Q_INVOKABLE QVariantList getCommandsForShortcut(QString combo);
    Q_INVOKABLE QVariantList getAllCurrentShortcuts();
    Q_INVOKABLE QVariantList getShortcutsForCommand(QString cmd);
    Q_INVOKABLE int getNumberInternalCommandsForShortcut(QString combo);
    Q_INVOKABLE int getNumberExternalCommandsForShortcut(QString combo);
    Q_INVOKABLE void saveAllCurrentShortcuts(QVariantList list); // used?
    Q_INVOKABLE int getNextCommandInCycle(QString combo, int timeout, int maxCmd);
    Q_INVOKABLE void resetCommandCycle(QString combo);

    Q_INVOKABLE void saveInternalShortcutCombos(const QVariantList lst);
    Q_INVOKABLE void saveExternalShortcutCombos(const QVariantList lst);
    Q_INVOKABLE void saveDuplicateShortcutsCommandOrder(const QVariantList lst);

    bool backupDatabase();
    Q_INVOKABLE void closeDatabase();
    Q_INVOKABLE void reopenDatabase();

    void setupFresh();

public Q_SLOTS:
    void readDB();
    Q_INVOKABLE void resetToDefault();

private:

    void writeNewShortcutsMapToDatabaseAndRead(QMap<QString, QVariantList> newmap);

    QStringList shortcutsOrder;
    QMap<QString,QVariantList> shortcuts;
    QMap<QString,QVariantList> m_commands;
    QMap<QString, QList<qint64>> commandCycle;

    QSqlDatabase db;
    bool readonly;
    bool dbIsTransaction;
    QTimer *dbCommitTimer;

    QString m_version;

Q_SIGNALS:
    void aboutChanged();

};
