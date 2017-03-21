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

#ifndef OPENFILE_H
#define OPENFILE_H

#include <QObject>
#include <QDir>
#include <QFile>
#include <QIcon>
#include <QtDebug>
#include <QtXml/QDomDocument>
#include <QUrl>
#include <thread>
#include "../../logger.h"
#include "../../settings/fileformats.h"

#if (QT_VERSION >= QT_VERSION_CHECK(5, 4, 0))
#include <QStorageInfo>
#endif

class GetAndDoStuffOpenFile : public QObject {

    Q_OBJECT

public:
    explicit GetAndDoStuffOpenFile(QObject *parent = 0);
    ~GetAndDoStuffOpenFile();

    int getNumberFilesInFolder(QString path, int selectionFileTypes);
    QVariantList getUserPlaces();
    QVariantList getFilesAndFoldersIn(QString path);
    QVariantList getFoldersIn(QString path);
    QVariantList getFilesIn(QString path);
    QVariantList getFilesWithSizeIn(QString path, int selectionFileTypes);
    bool isFolder(QString path);
    QString removePrefixFromDirectoryOrFile(QString path);
    void addToUserPlaces(QString path);
    void saveUserPlaces(QVariantList enabled);
    QString getOpenFileLastLocation();
    void setOpenFileLastLocation(QString path);
    void saveLastOpenedImage(QString path);

signals:
    void userPlacesUpdated();

private:
    FileFormats *formats;
    QFileSystemWatcher *watcher;
    bool userPlacesFileDoesntExist;

private slots:
    void updateUserPlaces() {
        emit userPlacesUpdated();
        recheckFile();
    }
    void recheckFile() {
        if(QFile(QString(ConfigFiles::DATA_DIR()) + "/../user-places.xbel").exists()) {
            watcher->addPath(QString(ConfigFiles::DATA_DIR()) + "/../user-places.xbel");
            if(userPlacesFileDoesntExist) {
                userPlacesFileDoesntExist = true;
                emit userPlacesUpdated();
            }
        } else
            QTimer::singleShot(1000,this,SLOT(recheckFile()));
    }

};


#endif // OPENFILE_H
