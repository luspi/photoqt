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

#ifndef GETANDDOSTUFFFILE_H
#define GETANDDOSTUFFFILE_H

#include <QObject>
#include <QFileDialog>
#include <QStringList>
#include <QIcon>
#include <QImageReader>
#include <QMimeDatabase>
#include "../../logger.h"

class GetAndDoStuffFile : public QObject {

    Q_OBJECT

public:
    explicit GetAndDoStuffFile(QObject *parent = 0);
    ~GetAndDoStuffFile();

    QString removePathFromFilename(QString path, bool removeSuffix = false);
    QString removeFilenameFromPath(QString file);
    QString getSuffix(QString file);

    QString getFilenameQtImage();
    QString getFilename(QString caption, QString dir, QString filter = "");
    QString getIconPathFromTheme(QString binary);
    QString getSaveFilename(QString caption, QString file);
    bool doesThisExist(QString path);

    QString streamlineFilePath(QString path);
    QString removeSuffixFromFilename(QString file);

    QString getMimeType(QString dir, QString file);

private:
    QMimeDatabase mimedb;

};

#endif // GETANDDOSTUFFFILE_H
