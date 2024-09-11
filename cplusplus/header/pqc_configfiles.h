/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2024 Lukas Spies                                  **
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

    const QString SETTINGS_DB() {
        return m_SETTINGS_DB;
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

    const QString SHAREONLINE_IMGUR_FILE() {
        return m_SHAREONLINE_IMGUR_FILE;
    }

    const QString SHAREONLINE_IMGUR_HISTORY_DB() {
        return m_SHAREONLINE_IMGUR_HISTORY_DB;
    }

    const QString ICC_COLOR_PROFILE_DIR() {
        return m_ICC_COLOR_PROFILE_DIR;
    }

    void setThumbnailCacheBaseDir(QString basedir) {

        if(basedir == "")
            basedir = QString("%1/thumbnails").arg(QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation));

        qDebug() << "Setting thumbnail cache base dir to:" << basedir;

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

        m_CONFIG_DIR = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);
        m_DATA_DIR = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        m_CACHE_DIR = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);

        m_USER_TRASH_FILES = QString("%1/Trash/files").arg(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation));
#ifdef Q_OS_WIN
        m_USER_PLACES_XBEL = QString("%1/user-places.xbel").arg(m_CACHE_DIR);
#else
        m_USER_PLACES_XBEL = QString("%1/user-places.xbel").arg(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation));
#endif
        m_THUMBNAIL_CACHE_DIR = QString("%1/thumbnails").arg(QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation));

        m_CONTEXTMENU_DB = QString("%1/contextmenu.db").arg(CONFIG_DIR());
        m_IMAGEFORMATS_DB = QString("%1/imageformats.db").arg(CONFIG_DIR());
        m_SETTINGS_DB = QString("%1/settings.db").arg(CONFIG_DIR());
        m_SHORTCUTS_DB = QString("%1/shortcuts.db").arg(CONFIG_DIR());
        m_LOCATION_DB = QString("%1/location.db").arg(CONFIG_DIR());

        m_WINDOW_GEOMETRY_FILE = QString("%1/geometry").arg(CONFIG_DIR());
        m_FILEDIALOG_LAST_LOCATION = QString("%1/filedialoglastlocation").arg(CACHE_DIR());
        m_LASTOPENEDIMAGE_FILE = QString("%1/lastimageloaded").arg(CONFIG_DIR());
        m_SHAREONLINE_IMGUR_FILE = QString("%1/imgurconfig").arg(CONFIG_DIR());
        m_SHAREONLINE_IMGUR_HISTORY_DB = QString("%1/imgurhistory.db").arg(CONFIG_DIR());
        m_ICC_COLOR_PROFILE_DIR = QString("%1/icc").arg(CACHE_DIR());

    }

    QString m_CONFIG_DIR;
    QString m_DATA_DIR;
    QString m_CACHE_DIR;
    QString m_USER_TRASH_FILES;
    QString m_USER_PLACES_XBEL;
    QString m_THUMBNAIL_CACHE_DIR;
    QString m_CONTEXTMENU_DB;
    QString m_IMAGEFORMATS_DB;
    QString m_SETTINGS_DB;
    QString m_SHORTCUTS_DB;
    QString m_LOCATION_DB;
    QString m_WINDOW_GEOMETRY_FILE;
    QString m_FILEDIALOG_LAST_LOCATION;
    QString m_LASTOPENEDIMAGE_FILE;
    QString m_SHAREONLINE_IMGUR_FILE;
    QString m_SHAREONLINE_IMGUR_HISTORY_DB;
    QString m_ICC_COLOR_PROFILE_DIR;

};

#endif // PQCCONFIGFILES_H
