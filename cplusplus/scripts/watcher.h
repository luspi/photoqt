#ifndef WATCHER_H
#define WATCHER_H

#include <QFileSystemWatcher>

class Watcher : public QObject {

    Q_OBJECT

public:
    Watcher(QObject *parent = 0) : QObject(parent) {

        watcherFolders = new QFileSystemWatcher;
        connect(watcherFolders, &QFileSystemWatcher::directoryChanged, this, &Watcher::directoryChanged);

    }

    Q_INVOKABLE void setCurrentDirectoryForChecking(QString dir) {
        if(QDir(dir).exists())
            watcherFolders->addPath(dir);
    }
    ~Watcher() {
        delete watcherFolders;
    }

signals:
    void folderUpdated();

private:
    QFileSystemWatcher *watcherFolders;

private slots:
    void directoryChanged(QString) {
        emit folderUpdated();
    }

};


#endif // WATCHER_H
