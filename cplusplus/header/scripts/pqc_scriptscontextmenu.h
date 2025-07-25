/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
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

#ifndef PQCSCRIPTSCONTEXTMENU_H
#define PQCSCRIPTSCONTEXTMENU_H

#include <QSqlDatabase>
#include <QObject>
#include <QtQmlIntegration>

class PQCScriptsContextMenu : public QObject {

    Q_OBJECT
    QML_SINGLETON

public:
    static PQCScriptsContextMenu& get() {
        static PQCScriptsContextMenu instance;
        return instance;
    }
    ~PQCScriptsContextMenu();

    PQCScriptsContextMenu(PQCScriptsContextMenu const&)     = delete;
    void operator=(PQCScriptsContextMenu const&) = delete;

    Q_INVOKABLE QVariantList getEntries();
    Q_INVOKABLE void setEntries(QVariantList entries);

    Q_INVOKABLE QVariantList detectSystemEntries();

    Q_INVOKABLE void closeDatabase();

private:
    PQCScriptsContextMenu();

    QSqlDatabase db;

Q_SIGNALS:
    void customEntriesChanged();

};

#endif
