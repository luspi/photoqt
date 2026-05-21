/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2026 Lukas Spies                                  **
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

#include <pqc_providersvg.h>
#include <pqc_settings.h>
#include <scripts/pqc_scriptsimages.h>
#include <pqc_notify_cpp.h>
#include <pqc_look.h>
#ifdef PQMRESVG
#include <pqc_imagehandler.h>
#else
#endif
#include <QSvgRenderer>
#include <QPainter>

#include <QDir>

PQCProviderSVG::PQCProviderSVG() : QQuickImageProvider(QQuickImageProvider::Image) {}

PQCProviderSVG::~PQCProviderSVG() {}

QImage PQCProviderSVG::requestImage(const QString &url, QSize *origSize, const QSize &requestedSize) {

    // we don't have a debug statement here as there would be A LOT of output all the time

    QImage ret;

    if(requestedSize.isEmpty()) {
        ret = QImage(1,1, QImage::Format_ARGB32);
        ret.fill(Qt::transparent);
        return ret;
    }

#ifdef PQMRESVG

    QString error = "";
    ret = PQCImageHandler::get().getImageWithPlugin("resvg", url, requestedSize, *origSize, error);

    if(!ret.isNull()) return ret;

#endif

    // For reading SVG files
    QSvgRenderer svg;

    // Loading SVG file
    svg.load(url);

    // Invalid vector graphic
    if(!svg.isValid()) {
        qWarning() << "Error: invalid svg file";
        return QImage();
    }

    // Store the width/height for later use
    *origSize = svg.defaultSize();
    // some svg's might not have a default size
    // in that case we fall back to the a default size
    if(!origSize->isValid())
        *origSize = QSize(512,512);

    // Render SVG into pixmap
    QImage img;
    if(!requestedSize.isEmpty())
        img = QImage(origSize->scaled(requestedSize, Qt::KeepAspectRatio), QImage::Format_ARGB32);
    else
        img = QImage(*origSize, QImage::Format_ARGB32_Premultiplied);
    img.fill(::Qt::transparent);
    QPainter painter(&img);
    painter.setRenderHint(QPainter::Antialiasing);
    painter.setRenderHint(QPainter::SmoothPixmapTransform);
    painter.setRenderHint(QPainter::TextAntialiasing);
    svg.render(&painter);

    return img;

}
