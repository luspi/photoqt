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

#include "filewatcher.h"

PQFileWatcher::PQFileWatcher(QObject *parent) : QObject(parent) {

    userPlacesWatcher = new QFileSystemWatcher;
    connect(userPlacesWatcher, &QFileSystemWatcher::fileChanged, this, &PQFileWatcher::userPlacesChangedSLOT);
    userPlacesWatcher->addPath(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel");

    shortcutsWatcher = new QFileSystemWatcher;
    connect(shortcutsWatcher, &QFileSystemWatcher::fileChanged, this, &PQFileWatcher::shortcutsChangedSLOT);
    shortcutsWatcher->addPath(ConfigFiles::SHORTCUTS_FILE());

}

void PQFileWatcher::userPlacesChangedSLOT() {

    emit userPlacesChanged();

    QFileInfo info(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel");
    for(int i = 0; i < 40; ++i) {
        if(info.exists())
            break;
        std::this_thread::sleep_for(std::chrono::milliseconds(50));
    }
    if(info.exists())
        userPlacesWatcher->addPath(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel");

}

void PQFileWatcher::shortcutsChangedSLOT() {

    emit shortcutsChanged();

    QFileInfo info(ConfigFiles::SHORTCUTS_FILE());
    for(int i = 0; i < 40; ++i) {
        if(info.exists())
            break;
        std::this_thread::sleep_for(std::chrono::milliseconds(50));
    }
    if(info.exists())
        shortcutsWatcher->addPath(ConfigFiles::SHORTCUTS_FILE());

}
