#ifndef SLIMSETTINGSREADONLY_H
#define SLIMSETTINGSREADONLY_H

#include <QObject>
#include <QFileSystemWatcher>
#include <QTimer>
#include <QFileInfo>

#include "../logger.h"
#include "../configfiles.h"

class SlimSettingsReadOnly : public QObject {

    Q_OBJECT

public:
    SlimSettingsReadOnly(QObject *parent = 0) : QObject(parent) {

        watcher = new QFileSystemWatcher;
        connect(watcher, &QFileSystemWatcher::fileChanged, [this](QString){ readSettings(); });

        watcherAddFileTimer = new QTimer;
        watcherAddFileTimer->setInterval(500);
        watcherAddFileTimer->setSingleShot(true);
        connect(watcherAddFileTimer, &QTimer::timeout, this, &SlimSettingsReadOnly::addFileToWatcher);

        // Set default values to start out with
        setDefault();
        readSettings();

    }

    int pixmapCache;
    bool metaApplyRotation;
    bool thumbnailCache;
    bool thumbnailCacheFile;

    void setDefault() {

        pixmapCache = 128;
        metaApplyRotation = true;
        thumbnailCache = true;
        thumbnailCacheFile = true;

    }

    void readSettings() {

        watcherAddFileTimer->start();

        QFile file(ConfigFiles::SETTINGS_FILE());

        if(file.exists() && !file.open(QIODevice::ReadOnly))

            LOG << CURDATE  << "ERROR reading slim settings:" << file.errorString().trimmed().toStdString() << NL;

        else if(file.exists() && file.isOpen()) {

            // Read file
            QTextStream in(&file);
            QStringList parts = in.readAll().split("\n");
            file.close();

            for(QString line : parts) {

                if(line.startsWith("PixmapCache="))
                    pixmapCache = line.split("=").at(1).toInt();
                else if(line.startsWith("MetaApplyRotation="))
                    metaApplyRotation = line.split("=").at(1).toInt();
                else if(line.startsWith("ThumbnailCache="))
                    thumbnailCache = line.split("=").at(1).toInt();
                else if(line.startsWith("ThumbnailCacheFile="))
                    thumbnailCacheFile = line.split("=").at(1).toInt();

            }

        }

    }

private:
    QFileSystemWatcher *watcher;
    QTimer *watcherAddFileTimer;

private slots:
    void addFileToWatcher() {
        QFileInfo info(ConfigFiles::SETTINGS_FILE());
        if(!info.exists()) {
            watcherAddFileTimer->start();
            return;
        }
        watcher->removePath(ConfigFiles::SETTINGS_FILE());
        watcher->addPath(ConfigFiles::SETTINGS_FILE());
    }

};

#endif // SLIMSETTINGSREADONLY_H
