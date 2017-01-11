/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

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
		if(watcher->directories().length() > 0) watcher->removePaths(watcher->directories());
		watcher->addPath(filename);
		watcher->addPath(QFileInfo(filename).absolutePath());
	}

private:
	QFileSystemWatcher *watcher;
	QTimer *send;

signals:
	void reloadDirectory();

};

#endif // IMAGEWATCH_H
