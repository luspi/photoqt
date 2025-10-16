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
#pragma once

#include <QObject>
#include <QTimer>

class PQCCScriptsFilesPaths : public QObject {

    Q_OBJECT

public:
    static PQCCScriptsFilesPaths& get() {
        static PQCCScriptsFilesPaths instance;
        return instance;
    }

    PQCCScriptsFilesPaths(PQCCScriptsFilesPaths const&) = delete;
    void operator=(PQCCScriptsFilesPaths const&) = delete;

    QString cleanPath(QString path);
    QString cleanPath_windows(QString path);

    bool isExcludeDirFromCaching(QString filename);
    bool doesItExist(QString path);
    bool isOnNetwork(QString filename);

private:
    PQCCScriptsFilesPaths();

    QTimer m_networkSharesTimer;
    QStringList m_networkshares;

private Q_SLOTS:
    void detectNetworkShares();

};
