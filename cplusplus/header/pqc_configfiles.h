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

#ifndef PQCCONFIGFILES_H
#define PQCCONFIGFILES_H

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

    const QString IMAGEFORMATS_DB() {
        return m_IMAGEFORMATS_DB;
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

    void setThumbnailCacheBaseDir(QString basedir) {

#ifdef PQMPORTABLETWEAKS
        basedir = QString("%1/thumbnails/").arg(qgetenv("PHOTOQT_PORTABLE_DATA_LOCATION"));
#else
        if(basedir == "")
            basedir = QString("%1/thumbnails").arg(QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation));
#endif

        qWarning() << "Setting thumbnail cache base dir to:" << basedir;

        m_THUMBNAIL_CACHE_DIR = basedir;

        QDir dir(basedir);
        dir.mkpath(PQCConfigFiles::get().THUMBNAIL_CACHE_DIR());
        dir.mkpath(QString("%1/normal/").arg(PQCConfigFiles::get().THUMBNAIL_CACHE_DIR()));
        dir.mkpath(QString("%1/large/").arg(PQCConfigFiles::get().THUMBNAIL_CACHE_DIR()));
        dir.mkpath(QString("%1/x-large/").arg(PQCConfigFiles::get().THUMBNAIL_CACHE_DIR()));
        dir.mkpath(QString("%1/xx-large/").arg(PQCConfigFiles::get().THUMBNAIL_CACHE_DIR()));

    }

private:

    PQCConfigFiles() {

#ifdef PQMPORTABLETWEAKS
        const QString portablefolder = qgetenv("PHOTOQT_PORTABLE_DATA_LOCATION");
        m_CONFIG_DIR = QString("%1/config/").arg(portablefolder);
        m_DATA_DIR = QString("%1/data/").arg(portablefolder);
        m_CACHE_DIR = QString("%1/cache/").arg(portablefolder);
#else
        m_CONFIG_DIR = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);
        m_DATA_DIR = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        m_CACHE_DIR = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
#endif
        m_EXTENSION_CONFIG_DIR = QString("%1/extensions/").arg(m_CONFIG_DIR);
        m_EXTENSION_DATA_DIR = QString("%1/extensions/").arg(m_DATA_DIR);
        m_EXTENSION_CACHE_DIR = QString("%1/extensions/").arg(m_CACHE_DIR);

        QDir dir;
        dir.mkpath(m_CONFIG_DIR);
        dir.mkpath(m_DATA_DIR);
        dir.mkpath(m_CACHE_DIR);

#ifdef PQMPORTABLETWEAKS
        m_USER_TRASH_FILES = QString("%1/Trash/files").arg(portablefolder);
#else
        m_USER_TRASH_FILES = QString("%1/Trash/files").arg(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation));
#endif

#ifdef Q_OS_WIN
    #ifdef PQMPORTABLETWEAKS
        m_USER_PLACES_XBEL = QString("%1/user-places-%2.xbel").arg(m_CACHE_DIR, QSysInfo::machineHostName());
    #else
        m_USER_PLACES_XBEL = QString("%1/user-places.xbel").arg(m_CACHE_DIR);
    #endif
#else
        m_USER_PLACES_XBEL = QString("%1/user-places.xbel").arg(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation));
        dir.mkpath(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation));
#endif

#ifdef PQMPORTABLETWEAKS
        m_THUMBNAIL_CACHE_DIR = QString("%1/thumbnails").arg(portablefolder);
#else
        m_THUMBNAIL_CACHE_DIR = QString("%1/thumbnails").arg(QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation));
        dir.mkpath(QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation));
#endif

        m_CONTEXTMENU_DB = QString("%1/contextmenu.db").arg(CONFIG_DIR());
        m_IMAGEFORMATS_DB = QString("%1/imageformats.db").arg(CONFIG_DIR());
        m_DEFAULTSETTINGS_DB = QString("%1/defaultsettings.db").arg(CACHE_DIR());
        m_USERSETTINGS_DB = QString("%1/usersettings.db").arg(CONFIG_DIR());
        m_QUICKUSERSETTINGS_FILE = QString("%1/quickusersettings").arg(CACHE_DIR());
        m_OLDSETTINGS_DB = QString("%1/settings.db").arg(CONFIG_DIR());
        m_SHORTCUTS_DB = QString("%1/shortcuts.db").arg(CONFIG_DIR());
        m_LOCATION_DB = QString("%1/location.db").arg(CONFIG_DIR());

        m_WINDOW_GEOMETRY_FILE = QString("%1/geometry").arg(CONFIG_DIR());
        m_FILEDIALOG_LAST_LOCATION = QString("%1/filedialoglastlocation").arg(CACHE_DIR());
        m_LASTOPENEDIMAGE_FILE = QString("%1/lastimageloaded").arg(CONFIG_DIR());
        m_ICC_COLOR_PROFILE_DIR = QString("%1/icc").arg(CACHE_DIR());

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
    QString m_IMAGEFORMATS_DB;
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

};

#endif // PQCCONFIGFILES_H
