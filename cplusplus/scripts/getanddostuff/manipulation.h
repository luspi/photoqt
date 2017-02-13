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

#ifndef GETANDDOSTUFFMANIPLULATION_H
#define GETANDDOSTUFFMANIPLULATION_H

#include <unistd.h>
#include <iostream>
#include <QObject>
#include <QStringList>
#include <QFileInfo>
#include <QImageReader>
#include <QUrl>
#include <QDateTime>
#include <QDir>
#include <QTextStream>
#include <QFileDialog>
#include "../../logger.h"

#ifdef EXIV2
#include <exiv2/image.hpp>
#include <exiv2/exif.hpp>
#endif

class GetAndDoStuffManipulation : public QObject {

    Q_OBJECT

public:
    explicit GetAndDoStuffManipulation(QObject *parent = 0);
    ~GetAndDoStuffManipulation();

    bool canBeScaled(QString filename);
    bool scaleImage(QString filename, int width, int height, int quality, QString newfilename);
    void deleteImage(QString filename, bool trash);
    bool renameImage(QString oldfilename, QString newfilename);
    void copyImage(QString path);
    void moveImage(QString path);

signals:
    void reloadDirectory(QString path, bool deleted = false);

};

#endif // GETANDDOSTUFFMANIPLULATION_H
