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

#ifndef PQCSTARTUP_H
#define PQCSTARTUP_H

#include <QObject>

class PQCStartup : public QObject {

    Q_OBJECT

public:
    PQCStartup(QObject *parent = nullptr);

    // 0: no update
    // 1: update
    // 2: fresh install
    int check();

    Q_INVOKABLE void setupFresh(int defaultPopout);
    Q_INVOKABLE void performChecksAndMigrations();

    void exportData(QString path);
    void importData(QString path);

    void resetToDefaults();

    bool manageSettings();
    bool manageShortcuts();

    void showInfo();

};



#endif // PQCStartup_H
