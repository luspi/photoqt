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

#ifndef SORTLIST_H
#define SORTLIST_H

#include <QCollator>
#include <QDateTime>
#include <QFileInfo>

#include "../logger.h"
#include "../configfiles.h"

#ifdef EXIV2
#include <exiv2/image.hpp>
#include <exiv2/exif.hpp>
#include <QLockFile>
#include <thread>
#endif

class Sort {

public:
        static void list(QFileInfoList *list, QString sortby, bool sortbyAscending);
        static void list(QVariantList *list, QString sortby, bool sortbyAscending);

private:
#ifdef EXIV2
        static void safelyReadMetadata(Exiv2::Image::AutoPtr *image);
#endif

};

#endif // SORTLIST_H
