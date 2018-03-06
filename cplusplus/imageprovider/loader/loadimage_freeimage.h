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

#ifndef LOADIMAGE_FREEIMAGE_H
#define LOADIMAGE_FREEIMAGE_H

#include <QImage>
#include <FreeImagePlus.h>
#include <QPixmap>

#include "errorimage.h"

// We need to use a header AND source file here, as otherwise the linker has problems with the static members,
// but they are necessary as this is how FreeImage passes on error messages

class LoadImageFreeImage {

public:
    QImage load(QString filename, QSize maxSize);

private:
    static QString errorMessage;
    static FREE_IMAGE_FORMAT errorFormat;

};


#endif
