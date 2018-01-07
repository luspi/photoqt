#ifndef WATCHER_H
#define WATCHER_H

#include <QFileSystemWatcher>
#include <QTimer>
#include <QStorageInfo>
#include <QCryptographicHash>
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

        storageInfoHash = "";
        storageInfoTimer = new QTimer;
        storageInfoTimer->setInterval(2500);
        storageInfoTimer->setSingleShot(false);
        connect(storageInfoTimer, &QTimer::timeout, this, &Watcher::checkForChangesStorageInfo);
        storageInfoTimer->start();
        storageInfoHash = formStorageInfoHash();

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
    void storageInfoUpdated();

private:
    QFileSystemWatcher *watcherFolders;
    QFileSystemWatcher *watcherUserPlaces;
    QTimer *storageInfoTimer;
    QByteArray storageInfoHash;

private slots:
    void directoryChanged(QString) {
        emit folderUpdated();
    }
    void userPlacesChanged(QString) {
        emit userPlacesUpdated();
        watcherUserPlaces->addPath(ConfigFiles::DATA_DIR() + "/../user-places.xbel");
    }
    void checkForChangesStorageInfo() {
        QByteArray fullhash = formStorageInfoHash();
        if(fullhash != storageInfoHash) {
            storageInfoHash = fullhash;
            emit storageInfoUpdated();
        }
    }
    QByteArray formStorageInfoHash() {
        QByteArray fullhash = 0;
        foreach(QStorageInfo s, QStorageInfo::mountedVolumes()) {
            if(s.isValid()) {

                QString compose = QString("%1%2%3%4").arg(s.name()).arg(s.bytesTotal()).arg(QString(s.fileSystemType())).arg(s.rootPath());
                fullhash += QCryptographicHash::hash(compose.toLatin1(), QCryptographicHash::Md5);
            }
        }
        return fullhash;
    }

};


#endif // WATCHER_H
