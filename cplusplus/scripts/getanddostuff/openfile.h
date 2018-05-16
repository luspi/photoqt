/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
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

#ifndef OPENFILE_H
#define OPENFILE_H

#include <QObject>
#include <QDir>
#include <QFile>
#include <QIcon>
#include <QXmlStreamWriter>
#include <QUrl>
#include <thread>
#include <QCollator>
#include "../../logger.h"
#include "../../settings/imageformats.h"
#include "../../settings/mimetypes.h"
#include "../../settings/settings.h"
#include <QStorageInfo>
#include <QMimeDatabase>

class GetAndDoStuffOpenFile : public QObject {

    Q_OBJECT

public:
    explicit GetAndDoStuffOpenFile(QObject *parent = 0);
    ~GetAndDoStuffOpenFile();

    int getNumberFilesInFolder(QString path, QString categoryFileTypes);
    QVariantList getUserPlaces();
    QVariantList getStorageInfo();
    QVariantList getFoldersIn(QString path, bool getDotDot = true, bool showHidden = false);
    void saveUserPlaces(QVariantList enabled);
    QString getOpenFileLastLocation();
    void setOpenFileLastLocation(QString path);
    void saveLastOpenedImage(QString path);
    QString getLastOpenedImage();
    QString getCurrentWorkingDirectory();
    QString getDirectoryDirName(QString path);
    bool isSupportedImageType(QString path);

private:
    ImageFormats *imageformats;
    MimeTypes *mimetypes;

    QMimeDatabase mimedb;

};


#endif // OPENFILE_H
