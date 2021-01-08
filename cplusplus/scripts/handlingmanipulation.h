/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
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

#ifndef PQHANDLINGMANIPULATION_H
#define PQHANDLINGMANIPULATION_H

#include <QObject>
#include <QImageReader>
#include <QFileDialog>
#include <QApplication>
#include "../logger.h"
#ifdef EXIV2
#include <exiv2/exiv2.hpp>
#endif

class PQHandlingManipulation : public QObject {

    Q_OBJECT

public:
    Q_INVOKABLE bool canThisBeScaled(QString filename);
    Q_INVOKABLE QSize getCurrentImageResolution(QString filename);
    Q_INVOKABLE bool scaleImage(QString sourceFilename, bool scaleInPlace, QSize targetSize, int targetQuality);

};


#endif // PQHANDLINGMANIPULATION_H
