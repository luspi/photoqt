#ifndef WATCHER_H
#define WATCHER_H

#include <QFileSystemWatcher>
#include <QTimer>
#include <QStorageInfo>
#include <QCryptographicHash>
#include <thread>
#include "../configfiles.h"

class Watcher : public QObject {

    Q_OBJECT

public:
    Watcher(QObject *parent = 0) : QObject(parent) {

        currentFolderForWatching = "";
        watcherFolders = new QFileSystemWatcher;
        connect(watcherFolders, &QFileSystemWatcher::directoryChanged, this, &Watcher::directoryChanged);

        watcherUserPlaces = new QFileSystemWatcher;
        connect(watcherUserPlaces, &QFileSystemWatcher::fileChanged, this, &Watcher::userPlacesChanged);
        if(QFileInfo(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel").exists())
            watcherUserPlaces->addPath(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel");

        watcherShortcuts = new QFileSystemWatcher;
        connect(watcherShortcuts, &QFileSystemWatcher::fileChanged, this, &Watcher::shortcutsChanged);
        watcherShortcuts->addPath(ConfigFiles::SHORTCUTS_FILE());

        storageInfoHash = "";
        storageInfoTimer = new QTimer;
        storageInfoTimer->setInterval(5000);
        storageInfoTimer->setSingleShot(false);
        connect(storageInfoTimer, &QTimer::timeout, this, &Watcher::checkForChangesStorageInfo);
        storageInfoTimer->start();
        storageInfoHash = formStorageInfoHash();

    }

    Q_INVOKABLE void setCurrentDirectoryForChecking(QString dir) {
        if(currentFolderForWatching != "") {
            watcherFolders->removePath(currentFolderForWatching);
            currentFolderForWatching = "";
        }
        if(dir != "" && QDir(dir).exists()) {
            currentFolderForWatching = dir;
            watcherFolders->addPath(dir);
        }
    }
    Q_INVOKABLE void stopWatchingForOpenFileElement() {
        // stop watching folder
        if(currentFolderForWatching != "") {
            watcherFolders->removePath(currentFolderForWatching);
            currentFolderForWatching = "";
        }
        // stop watching userplaces
        watcherUserPlaces->removePath(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel");
        // stop watching for changes to storageinfo
        storageInfoTimer->stop();
    }

    Q_INVOKABLE void startWatchingForOpenFileElement(QString dir) {

        setCurrentDirectoryForChecking(dir);

        // make sure the userplaces are watched (stopped while element is hidden)
        if(watcherUserPlaces->files().length() == 0) {
            if(QFileInfo(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel").exists())
                watcherUserPlaces->addPath(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel");
        }

        // make sure that the storageinfo timer is running (stopped while element is hidden)
        if(!storageInfoTimer->isActive())
            storageInfoTimer->start();

    }

    ~Watcher() {
        delete watcherFolders;
        delete watcherUserPlaces;
    }

signals:
    void folderUpdated();
    void userPlacesUpdated();
    void shortcutsUpdated();
    void storageInfoUpdated();

private:
    QFileSystemWatcher *watcherFolders;
    QFileSystemWatcher *watcherUserPlaces;
    QFileSystemWatcher *watcherShortcuts;
    QTimer *storageInfoTimer;
    QByteArray storageInfoHash;

    QString currentFolderForWatching;

private slots:
    void directoryChanged(QString) {
        emit folderUpdated();
    }
    void userPlacesChanged(QString) {
        emit userPlacesUpdated();
        QFileInfo info(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel");
        for(int i = 0; i < 40; ++i) {
            if(info.exists())
                break;
            std::this_thread::sleep_for(std::chrono::milliseconds(50));
        }
        if(info.exists())
            watcherUserPlaces->addPath(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel");
    }
    void shortcutsChanged(QString) {
        emit shortcutsUpdated();
        QFileInfo info(ConfigFiles::SHORTCUTS_FILE());
        for(int i = 0; i < 40; ++i) {
            if(info.exists())
                break;
            std::this_thread::sleep_for(std::chrono::milliseconds(50));
        }
        if(info.exists())
            watcherUserPlaces->addPath(ConfigFiles::SHORTCUTS_FILE());
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
        for(QStorageInfo s : QStorageInfo::mountedVolumes()) {
            if(s.isValid()) {

                QString compose = QString("%1%2%3%4").arg(s.name()).arg(s.bytesTotal()).arg(QString(s.fileSystemType())).arg(s.rootPath());
                fullhash += QCryptographicHash::hash(compose.toLatin1(), QCryptographicHash::Md5);
            }
        }
        return fullhash;
    }

};


#endif // WATCHER_H
