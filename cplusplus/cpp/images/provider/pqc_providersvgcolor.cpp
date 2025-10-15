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

#include <pqc_providersvgcolor.h>
#include <pqc_providersvg.h>

PQCProviderSVGColor::PQCProviderSVGColor() : QQuickImageProvider(QQuickImageProvider::Image) {}

PQCProviderSVGColor::~PQCProviderSVGColor() {}

QImage PQCProviderSVGColor::requestImage(const QString &url, QSize *origSize, const QSize &requestedSize) {

    // we don't have a debug statement here as there would be A LOT of output all the time

    QImage ret;

    if(requestedSize.isNull()) {
        ret = QImage(1,1, QImage::Format_ARGB32);
        ret.fill(Qt::transparent);
        return ret;
    }

    // have a target color!
    if(url.contains(":://::")) {

        const QString fn = url.split(":://::").at(1);

        // extract target color and lighten or darken it
        QColor c(url.split(":://::").at(0));

        // create inverse color (half transparent to not be overpowering)
        QColor invc((255-c.red()), (255-c.green()), (255-c.blue()), 32);

        // request image
        PQCProviderSVG prov;
        QImage img = prov.requestImage(fn, origSize, requestedSize);

        // loop through image and adjust colors
        for(int x = 0; x < img.width(); ++x) {
            for(int y = 0; y < img.height(); ++y) {
                const QColor oldc = img.pixelColor(x, y);
                if(oldc.red() == 255 && oldc.green() == 255 && oldc.blue() == 255)
                    img.setPixelColor(x, y, c);
                else if(oldc.alpha() != 0)
                    img.setPixelColor(x, y, invc);
            }
        }

        // done
        return img;

    }

    // no color provided? simply return image
    PQCProviderSVG prov;
    return prov.requestImage(url, origSize, requestedSize);

}
