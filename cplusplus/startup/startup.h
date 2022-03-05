/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

#ifndef PQSTARTUP_H
#define PQSTARTUP_H

#include <QObject>
#include <QFile>
#include <QtSql>
#include <QMessageBox>

#include "../scripts/handlingexternal.h"
#include "../scripts/handlinggeneral.h"
#include "../settings/shortcuts.h"
#include "../configfiles.h"
#include "../logger.h"
#include "../settings/imageformats.h"

class PQStartup : public QObject {

    Q_OBJECT

public:
    PQStartup(QObject *parent = nullptr);

    // 0: no update
    // 1: update
    // 2: fresh install
    int check(bool onlyCreateDatabase = false);

    Q_INVOKABLE void setupFresh(int defaultPopout);
    Q_INVOKABLE void performChecksAndMigrations();

    void exportData(QString path);
    void importData(QString path);

    void resetToDefaults();

    bool migrateContextmenuToDb();
    bool migrateSettingsToDb();
    bool migrateShortcutsToDb();

    bool enterNewSettings();

private:
    bool checkIfBinaryExists(QString exec);

};



#endif // PQSTARTUP_H
