#ifndef WATCHER_H
#define WATCHER_H

#include <QFileSystemWatcher>
#include "../configfiles.h"

class Watcher : public QObject {

    Q_OBJECT

public:
    Watcher(QObject *parent = 0) : QObject(parent) {

        watcherFolders = new QFileSystemWatcher;
        connect(watcherFolders, &QFileSystemWatcher::directoryChanged, this, &Watcher::directoryChanged);

        watcherUserPlaces = new QFileSystemWatcher;
        connect(watcherUserPlaces, &QFileSystemWatcher::fileChanged, this, &Watcher::userPlacesChanged);
        watcherUserPlaces->addPath(ConfigFiles::DATA_DIR() + "/../user-places.xbel");

    }

    Q_INVOKABLE void setCurrentDirectoryForChecking(QString dir) {
        if(QDir(dir).exists())
            watcherFolders->addPath(dir);
    }
    ~Watcher() {
        delete watcherFolders;
        delete watcherUserPlaces;
    }

signals:
    void folderUpdated();
    void userPlacesUpdated();

private:
    QFileSystemWatcher *watcherFolders;
    QFileSystemWatcher *watcherUserPlaces;

private slots:
    void directoryChanged(QString) {
        emit folderUpdated();
    }
    void userPlacesChanged(QString) {
        emit userPlacesUpdated();
        watcherUserPlaces->addPath(ConfigFiles::DATA_DIR() + "/../user-places.xbel");
    }

};


#endif // WATCHER_H
