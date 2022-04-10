/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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

#ifndef PQLOADIMAGELIBVIPS_H
#define PQLOADIMAGELIBVIPS_H

#include <QImage>

#ifdef LIBVIPS
#include <vips/vips8>
#endif

#include "../../logger.h"

class PQLoadImageLibVips {

public:
    PQLoadImageLibVips();

    QSize loadSize(QString filename);
    QImage load(QString filename, QSize, QSize *origSize, bool stopAfterSize = false);

    QString errormsg;

};

#endif // PQLOADIMAGELIBVIPS_H
