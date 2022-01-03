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

#ifndef PQHANDLINGFACETAGS_H
#define PQHANDLINGFACETAGS_H

#include <QObject>
#include "../logger.h"

#ifdef EXIV2
#include <exiv2/exiv2.hpp>
#endif

class PQHandlingFaceTags : public QObject {

    Q_OBJECT

public:
    Q_INVOKABLE bool canWriteXmpTags(QString filename);
    Q_INVOKABLE QVariantList getFaceTags(QString filename);
    Q_INVOKABLE void setFaceTags(QString filename, QVariantList tags);

};

#endif // PQHANDLINGFACETAGS_H
