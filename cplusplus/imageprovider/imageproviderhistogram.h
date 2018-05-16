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

#ifndef IMAGEPROVIDERHISTOGRAM_H
#define IMAGEPROVIDERHISTOGRAM_H

#include <QQuickImageProvider>
#include <QIcon>
#include <QFile>
#include <QPainter>
#include <algorithm>
#include "imageproviderfull.h"
#include "../logger.h"


class ImageProviderHistogram : public QQuickImageProvider {

public:
    explicit ImageProviderHistogram() : QQuickImageProvider(QQuickImageProvider::Pixmap) { }
    ~ImageProviderHistogram() { }

    QPixmap requestPixmap(const QString &fpath, QSize *, const QSize &requestedSize);

private:
    int *levels_grey;
    int *levels_red;
    int *levels_green;
    int *levels_blue;
    QPolygon polyGREY;
    QPolygon polyRED;
    QPolygon polyGREEN;
    QPolygon polyBLUE;
    QString filepath;
    bool colorversion;
    QImage histimg;
    int greatestvalue;

};


#endif
