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

#ifndef CONFIGFILES_H
#define CONFIGFILES_H

#include <QObject>
#include <QStandardPaths>

class ConfigFiles {

public:

    static const QString CONFIG_DIR() {
        return QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);
    }

    static const QString GENERIC_DATA_DIR() {
        return QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
    }

    static const QString GENERIC_CACHE_DIR() {
        QString path = QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation);
        return (path.trimmed() != "" ? path : QStandardPaths::writableLocation(QStandardPaths::CacheLocation));
    }

    static const QString SETTINGS_FILE() {
        return QString("%1/settings").arg(CONFIG_DIR());
    }

    static const QString CONTEXTMENU_FILE() {
        return QString("%1/contextmenu").arg(CONFIG_DIR());
    }

    static const QString IMAGEFORMATS_FILE() {
        return QString("%1/imageformats_disabled").arg(CONFIG_DIR());
    }

    static const QString MIMEFORMATS_FILE() {
        return QString("%1/mimeformats_disabled").arg(CONFIG_DIR());
    }

    static const QString SHORTCUTS_FILE() {
        return QString("%1/shortcuts").arg(CONFIG_DIR());
    }

    static const QString SHORTCUTSNOTIFIER_FILE() {
        return QString("%1/shortcutsnotifier").arg(CONFIG_DIR());
    }

    static const QString THUMBNAILS_DB() {
        return QString("%1/thumbnails").arg(GENERIC_CACHE_DIR());
    }

    static const QString SETTINGS_SESSION_FILE() {
        return QString("%1/settings_session").arg(GENERIC_CACHE_DIR());
    }

    static const QString WINDOW_GEOMETRY_FILE() {
        return QString("%1/geometry").arg(CONFIG_DIR());
    }

    static const QString OPENFILE_LAST_LOCATION() {
        return QString("%1/openfilelastlocation").arg(GENERIC_CACHE_DIR());
    }

    static const QString LASTOPENEDIMAGE_FILE() {
        return QString("%1/lastimageloaded").arg(CONFIG_DIR());
    }

    static const QString SHAREONLINE_IMGUR_FILE() {
        return QString("%1/imgurconfig").arg(CONFIG_DIR());

    }
    static const QString COLOR_FILE() {
        return QString("%1/colors").arg(CONFIG_DIR());
    }

};

#endif // CONFIGFILES_H
