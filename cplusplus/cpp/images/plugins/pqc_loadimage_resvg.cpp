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

#include <cpp/pqc_loadimage_resvg.h>

#include <QSize>
#include <QImage>
#include <QtDebug>
#ifdef PQMRESVG
#include <ResvgQt.h>
#endif

PQCLoadImageResvg::PQCLoadImageResvg() {}

QSize PQCLoadImageResvg::loadSize(QString filename) {

    qDebug() << "args: filename =" << filename;

#ifdef PQMRESVG

    ResvgOptions opt;
    ResvgRenderer renderer(filename, opt);
    return renderer.defaultSize();

#endif

    return QSize();

}

QString PQCLoadImageResvg::load(QString filename, QSize maxSize, QSize &origSize, QImage &img) {

    qDebug() << "args: filename =" << filename;
    qDebug() << "args: maxSize =" << maxSize;

#ifdef PQMRESVG

    ResvgOptions opt;
    ResvgRenderer renderer(filename, opt);

    if(!renderer.isValid()) {
        QString errmsg = "Invalid SVG encountered";
        qWarning() << errmsg;
        return errmsg;
    }
    origSize = renderer.defaultSize();

    if(maxSize.isValid())
        img = renderer.renderToImage(renderer.defaultSize().scaled(maxSize, Qt::KeepAspectRatio));
    else
        img = renderer.renderToImage();

    return "";

#endif

    return "";

}
