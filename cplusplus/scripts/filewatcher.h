/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
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

#ifndef PQFILEWATCHER_H
#define PQFILEWATCHER_H

#include <QObject>
#include <QFileSystemWatcher>
#include <QFileInfo>
#include <thread>
#include <QTimer>
#include "../configfiles.h"
#include "../logger.h"

class PQFileWatcher : public QObject {

    Q_OBJECT

public:
    explicit PQFileWatcher(QObject *parent = nullptr);
    ~PQFileWatcher();

private:
    QFileSystemWatcher *userPlacesWatcher;
    QFileSystemWatcher *shortcutsWatcher;
    QFileSystemWatcher *contextmenuWatcher;

    QTimer *checkRepeatedly;

private slots:
    void userPlacesChangedSLOT();
    void shortcutsChangedSLOT();
    void contextmenuChangedSLOT();

    void checkRepeatedlyTimeout();

signals:
    void userPlacesChanged();
    void shortcutsChanged();
    void contextmenuChanged();

};


#endif // PQFILEWATCHER_H
