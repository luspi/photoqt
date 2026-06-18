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
#include <QStandardPaths>
#include <QDir>
#include <QCoreApplication>

class PQCConfigFiles {

public:
    static PQCConfigFiles& get() {
        static PQCConfigFiles instance;
        return instance;
    }
    ~PQCConfigFiles() {}

    PQCConfigFiles(PQCConfigFiles const&)     = delete;
    void operator=(PQCConfigFiles const&) = delete;

    const QString CONFIG_DIR() {
        return m_CONFIG_DIR;
    }

    const QString EXTENSION_CONFIG_DIR() {
        return m_EXTENSION_CONFIG_DIR;
    }

    const QString EXTENSION_DATA_DIR() {
        return m_EXTENSION_DATA_DIR;
    }

    const QString EXTENSION_CACHE_DIR() {
        return m_EXTENSION_CACHE_DIR;
    }

    const QString DATA_DIR() {
        return m_DATA_DIR;
    }

    const QString CACHE_DIR() {
        return m_CACHE_DIR;
    }

    const QString USER_TRASH_FILES() {
        return m_USER_TRASH_FILES;
    }

    const QString USER_PLACES_XBEL() {
        return m_USER_PLACES_XBEL;
    }

    const QString THUMBNAIL_CACHE_DIR() {
        return m_THUMBNAIL_CACHE_DIR;
    }

    const QString CONTEXTMENU_DB() {
        return m_CONTEXTMENU_DB;
    }

    const QString DEFAULTSETTINGS_DB() {
        return m_DEFAULTSETTINGS_DB;
    }

    const QString USERSETTINGS_DB() {
        return m_USERSETTINGS_DB;
    }

    const QString QUICKUSERSETTINGS_FILE() {
        return m_QUICKUSERSETTINGS_FILE;
    }

    const QString OLDSETTINGS_DB() {
        return m_OLDSETTINGS_DB;
    }

    const QString SHORTCUTS_DB() {
        return m_SHORTCUTS_DB;
    }

    const QString LOCATION_DB() {
        return m_LOCATION_DB;
    }

    const QString WINDOW_GEOMETRY_FILE() {
        return m_WINDOW_GEOMETRY_FILE;
    }

    const QString FILEDIALOG_LAST_LOCATION() {
        return m_FILEDIALOG_LAST_LOCATION;
    }

    const QString LASTOPENEDIMAGE_FILE() {
        return m_LASTOPENEDIMAGE_FILE;
    }

    const QString ICC_COLOR_PROFILE_DIR() {
        return m_ICC_COLOR_PROFILE_DIR;
    }

    const QString IMAGEPLUGINS_SETTINGS_DIR() {
        return m_IMAGEPLUGINS_SETTINGS_DIR;
    }

    void setThumbnailCacheBaseDir(QString basedir) {

#ifdef PQMPORTABLETWEAKS
        basedir = qgetenv("PHOTOQT_PORTABLE_DATA_LOCATION") % "/thumbnails/";
#else
        if(basedir.isEmpty())
            basedir = QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation) % "/thumbnails/";
#endif

        qWarning() << "Setting thumbnail cache base dir to:" << basedir;

        m_THUMBNAIL_CACHE_DIR = basedir;

        QDir dir(basedir);
        dir.mkpath(PQCConfigFiles::get().THUMBNAIL_CACHE_DIR());
        dir.mkpath(PQCConfigFiles::get().THUMBNAIL_CACHE_DIR() % "/normal/");
        dir.mkpath(PQCConfigFiles::get().THUMBNAIL_CACHE_DIR() % "/large/");
        dir.mkpath(PQCConfigFiles::get().THUMBNAIL_CACHE_DIR() % "/x-large/");
        dir.mkpath(PQCConfigFiles::get().THUMBNAIL_CACHE_DIR() % "/xx-large/");

    }

private:

    PQCConfigFiles() {

#ifdef PQMPORTABLETWEAKS
        const QString portablefolder = qgetenv("PHOTOQT_PORTABLE_DATA_LOCATION");
        m_CONFIG_DIR = portablefolder % "/config/";
        m_DATA_DIR = portablefolder % "/data/";
        m_CACHE_DIR = portablefolder % "/cache/";
#else
        m_CONFIG_DIR = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);
        m_DATA_DIR = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        m_CACHE_DIR = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
#endif
        m_EXTENSION_CONFIG_DIR = m_CONFIG_DIR % "/extensions/";
        m_EXTENSION_DATA_DIR = m_DATA_DIR % "/extensions/";
        m_EXTENSION_CACHE_DIR = m_CACHE_DIR % "/extensions/";

        QDir dir;
        dir.mkpath(m_CONFIG_DIR);
        dir.mkpath(m_DATA_DIR);
        dir.mkpath(m_CACHE_DIR);

#ifdef PQMPORTABLETWEAKS
        m_USER_TRASH_FILES = portablefolder % "/Trash/files";
#else
        m_USER_TRASH_FILES = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) % "/Trash/files";
#endif

#ifdef Q_OS_WIN
    #ifdef PQMPORTABLETWEAKS
        m_USER_PLACES_XBEL = m_CACHE_DIR % "/user-places-" % QSysInfo::machineHostName() % ".xbel";
    #else
        m_USER_PLACES_XBEL = m_CACHE_DIR % "/user-places.xbel";
    #endif
#else
        m_USER_PLACES_XBEL = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) % "/user-places.xbel";
        dir.mkpath(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation));
#endif

#ifdef PQMPORTABLETWEAKS
        m_THUMBNAIL_CACHE_DIR = portablefolder % "/thumbnails";
#else
        m_THUMBNAIL_CACHE_DIR = QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation) % "/thumbnails";
        dir.mkpath(QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation));
#endif

        m_CONTEXTMENU_DB = m_CONFIG_DIR % "/contextmenu.db";
        m_DEFAULTSETTINGS_DB = m_CACHE_DIR % "/defaultsettings.db";
        m_USERSETTINGS_DB = m_CONFIG_DIR % "/usersettings.db";
        m_QUICKUSERSETTINGS_FILE = m_CACHE_DIR % "/quickusersettings";
        m_OLDSETTINGS_DB = m_CONFIG_DIR % "/settings.db";
        m_SHORTCUTS_DB = m_CONFIG_DIR % "/shortcuts.db";
        m_LOCATION_DB = m_CONFIG_DIR % "/location.db";

        m_WINDOW_GEOMETRY_FILE = m_CONFIG_DIR % "/geometry";
        m_FILEDIALOG_LAST_LOCATION = m_CACHE_DIR % "/filedialoglastlocation";
        m_LASTOPENEDIMAGE_FILE = m_CONFIG_DIR % "/lastimageloaded";
        m_ICC_COLOR_PROFILE_DIR = m_CACHE_DIR % "/icc";
        m_IMAGEPLUGINS_SETTINGS_DIR = m_CONFIG_DIR % "/imageplugins";

    }

    QString m_CONFIG_DIR;
    QString m_EXTENSION_CONFIG_DIR;
    QString m_EXTENSION_DATA_DIR;
    QString m_EXTENSION_CACHE_DIR;
    QString m_DATA_DIR;
    QString m_CACHE_DIR;
    QString m_USER_TRASH_FILES;
    QString m_USER_PLACES_XBEL;
    QString m_THUMBNAIL_CACHE_DIR;
    QString m_CONTEXTMENU_DB;
    QString m_DEFAULTSETTINGS_DB;
    QString m_USERSETTINGS_DB;
    QString m_QUICKUSERSETTINGS_FILE;
    QString m_OLDSETTINGS_DB;
    QString m_SHORTCUTS_DB;
    QString m_LOCATION_DB;
    QString m_WINDOW_GEOMETRY_FILE;
    QString m_FILEDIALOG_LAST_LOCATION;
    QString m_LASTOPENEDIMAGE_FILE;
    QString m_ICC_COLOR_PROFILE_DIR;
    QString m_IMAGEPLUGINS_SETTINGS_DIR;

};
