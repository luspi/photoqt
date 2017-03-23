#ifndef CONFIGFILES_H
#define CONFIGFILES_H

#include <QObject>
#include <QApplication>
#include <QStandardPaths>

class ConfigFiles {

public:

    static const QString CONFIG_DIR() {
        return QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);
    }

    static const QString DATA_DIR() {
        return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
    }

    static const QString CACHE_DIR() {
        return QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    }

    static const QString SETTINGS_FILE() {
        return QString("%1/settings").arg(CONFIG_DIR());
    }

    static const QString CONTEXTMENU_FILE() {
        return QString("%1/contextmenu").arg(CONFIG_DIR());
    }

    static const QString FILEFORMATS_FILE() {
        return QString("%1/fileformats.disabled").arg(CONFIG_DIR());
    }

    static const QString KEY_SHORTCUTS_FILE() {
        return QString("%1/shortcuts").arg(CONFIG_DIR());
    }

    static const QString TOUCH_SHORTCUTS_FILE() {
        return QString("%1/touchshortcuts").arg(CONFIG_DIR());
    }

    static const QString MOUSE_SHORTCUTS_FILE() {
        return QString("%1/mouseshortcuts").arg(CONFIG_DIR());
    }

    static const QString SHORTCUTSNOTIFIER_FILE() {
        return QString("%1/shortcutsnotifier").arg(CONFIG_DIR());
    }

    static const QString THUMBNAILS_DB() {
        return QString("%1/thumbnails").arg(CACHE_DIR());
    }

    static const QString SETTINGS_SESSION_FILE() {
        return QString("%1/settings_session").arg(CACHE_DIR());
    }

    static const QString MAINWINDOW_GEOMETRY_FILE() {
        return QString("%1/geometry").arg(CONFIG_DIR());
    }

    static const QString OPENFILE_LAST_LOCATION() {
        return QString("%1/openfilelastlocation").arg(CACHE_DIR());
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
