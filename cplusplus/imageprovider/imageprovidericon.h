/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
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

#ifndef IMAGEPROVIDERICON_H
#define IMAGEPROVIDERICON_H

#include <QQuickImageProvider>
#include <QIcon>
#include <QFile>
#include "../logger.h"


class PQImageProviderIcon : public QQuickImageProvider {

public:
    explicit PQImageProviderIcon() : QQuickImageProvider(QQuickImageProvider::Image) { }
    ~PQImageProviderIcon() { }

    QImage requestImage(const QString &icon, QSize *, const QSize &requestedSize);

};

#endif // IMAGEPROVIDERICON_H
