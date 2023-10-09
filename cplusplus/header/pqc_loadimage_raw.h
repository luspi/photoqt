/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

#ifndef PQCLOADIMAGESRAW_H
#define PQCLOADIMAGESRAW_H

class QSize;
class QImage;
class QString;
class LibRaw;

#ifdef RAW
#include <libraw/libraw_types.h>
#endif

class PQCLoadImageRAW {

public:
    PQCLoadImageRAW();

    static QSize loadSize(QString filename);
    static QString load(QString filename, QSize maxSize, QSize &origSize, QImage &img);

private:
#ifdef RAW
    static void loadRawImage(QString filename, QSize maxSize, LibRaw &raw, libraw_processed_image_t *img, bool &thumb, bool &half);
#endif

};

#endif // PQCLOADIMAGESRAW_H