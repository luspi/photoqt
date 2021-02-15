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

#ifndef IMAGEPROVIDERHISTOGRAM_H
#define IMAGEPROVIDERHISTOGRAM_H

#include <QQuickImageProvider>
#include <QIcon>
#include <QFile>
#include <QPainter>
#include <algorithm>
#include "../logger.h"
#include "loadimage.h"


class PQImageProviderHistogram : public QQuickImageProvider {

public:
    explicit PQImageProviderHistogram() : QQuickImageProvider(QQuickImageProvider::Pixmap) {
        loader = new PQLoadImage;
    }
    ~PQImageProviderHistogram() {
        delete loader;
    }

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
    PQLoadImage *loader;

};


#endif
