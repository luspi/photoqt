/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2025 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
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

#ifndef PQCLOADIMAGE_H
#define PQCLOADIMAGE_H

#include <cpp/pqc_imagecache.h>

class QSize;
class QImage;

class PQCLoadImage {

public:
    static PQCLoadImage& get() {
        static PQCLoadImage instance;
        return instance;
    }
    ~PQCLoadImage();

    QString load(QString filename, QSize requestedSize, QSize &origSize, QImage &img);
    QSize load(QString filename);

private:
    PQCLoadImage();
};

#endif // PQCLOADIMAGE_H
