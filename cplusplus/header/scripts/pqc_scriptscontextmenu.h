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

#include <QSqlDatabase>
#include <QObject>

class PQCScriptsContextMenu : public QObject {

    Q_OBJECT

public:
    static PQCScriptsContextMenu& get() {
        static PQCScriptsContextMenu instance;
        return instance;
    }

    PQCScriptsContextMenu(PQCScriptsContextMenu const&) = delete;
    void operator=(PQCScriptsContextMenu const&) = delete;

    QVariantList getEntries();
    void setEntries(QVariantList entries);

    QVariantList detectSystemEntries();

    void closeDatabase();

private:
    PQCScriptsContextMenu();
    ~PQCScriptsContextMenu();

    QSqlDatabase db;

Q_SIGNALS:
    void customEntriesChanged();

};
