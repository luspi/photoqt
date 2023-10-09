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

#ifndef PQCCONFIGFILES_H
#define PQCCONFIGFILES_H

#include <QObject>
#include <QStandardPaths>

class PQCConfigFiles {

public:

    static const QString CONFIG_DIR() {
        return QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);
    }

    static const QString DATA_DIR() {
        return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    }

    static const QString CACHE_DIR() {
        return QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    }

    static const QString GENERIC_DATA_DIR() {
        return QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
    }

    static const QString GENERIC_CACHE_DIR() {
        return QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation);
    }

    static const QString CONTEXTMENU_DB() {
        return QString("%1/contextmenu.db").arg(CONFIG_DIR());
    }

    static const QString IMAGEFORMATS_DB() {
        return QString("%1/imageformats.db").arg(CONFIG_DIR());
    }

    static const QString SETTINGS_DB() {
        return QString("%1/settings.db").arg(CONFIG_DIR());
    }

    static const QString SHORTCUTS_DB() {
        return QString("%1/shortcuts.db").arg(CONFIG_DIR());
    }

    static const QString LOCATION_DB() {
        return QString("%1/location.db").arg(CONFIG_DIR());
    }

    static const QString WINDOW_GEOMETRY_FILE() {
        return QString("%1/geometry").arg(CONFIG_DIR());
    }

    static const QString FILEDIALOG_LAST_LOCATION() {
        return QString("%1/filedialoglastlocation").arg(CACHE_DIR());
    }

    static const QString LASTOPENEDIMAGE_FILE() {
        return QString("%1/lastimageloaded").arg(CONFIG_DIR());
    }

    static const QString SHAREONLINE_IMGUR_FILE() {
        return QString("%1/imgurconfig").arg(CONFIG_DIR());
    }

    static const QString SHAREONLINE_IMGUR_HISTORY_DB() {
        return QString("%1/imgurhistory.db").arg(CONFIG_DIR());
    }

};

#endif // PQCCONFIGFILES_H
