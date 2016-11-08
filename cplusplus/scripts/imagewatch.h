#ifndef IMAGEWATCH_H
#define IMAGEWATCH_H

#include <QObject>
#include <QFileSystemWatcher>
#include <QFileInfo>
#include <QtDebug>
#include<QTimer>

class ImageWatch : public QObject {

	Q_OBJECT

public:
	explicit ImageWatch(QObject *parent = 0) : QObject(parent) {
		watcher = new QFileSystemWatcher;
		send = new QTimer;
		send->setSingleShot(true);
		send->setInterval(1000);
		connect(send, SIGNAL(timeout()), this, SIGNAL(reloadDirectory()));
		connect(watcher, SIGNAL(directoryChanged(QString)), send, SLOT(start()));
		connect(watcher, SIGNAL(fileChanged(QString)), send, SLOT(start()));
	}

	Q_INVOKABLE void watchFolder(QString filename) {
		if(watcher->files().length() > 0) watcher->removePaths(watcher->files());
		watcher->addPath(filename);
	}

private:
	QFileSystemWatcher *watcher;
	QTimer *send;

signals:
	void reloadDirectory();

};

#endif // IMAGEWATCH_H
