/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
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

#include <pqc_loadimage_libvips.h>
#include <pqc_imagecache.h>
#include <QSize>
#include <QtDebug>
#include <QImage>

#ifdef LIBVIPS
#include <vips/vips.h>
#endif

PQCLoadImageLibVips::PQCLoadImageLibVips() {}

QSize PQCLoadImageLibVips::loadSize(QString filename) {

#ifdef LIBVIPS

    // The vips image object
    VipsImage *in;

    // attempt to the load the image
    if(!(in = vips_image_new_from_file(filename.toStdString().c_str(), NULL))) {
        g_object_unref(in);
        qDebug() << "vips_image_new_from_file: failed to load image from file";
        return QSize();
    }

    // store original size
    return QSize(vips_image_get_width(in), vips_image_get_height(in));

#else

    return QSize();

#endif

}

QString PQCLoadImageLibVips::load(QString filename, QSize maxSize, QSize &origSize, QImage &img) {

    qDebug() << "args: filename = " << filename;
    qDebug() << "args: maxSize = " << maxSize;

    QString errormsg = "";

#ifdef LIBVIPS

    // we use the C API as the equivalent C++ API calls led to crash on subsequent call

    // The vips image object
    VipsImage *in;

    // attempt to the load the image
    if(!(in = vips_image_new_from_file(filename.toStdString().c_str(), NULL))) {
        g_object_unref(in);
        errormsg = "vips_image_new_from_file: failed to load image from file";
        qDebug() << errormsg;
        return errormsg;
    }

    // store original size
    origSize = QSize(vips_image_get_width(in), vips_image_get_height(in));

    // convert VipsImage to QImage
    img = QImage((uchar*)vips_image_get_data(in), vips_image_get_width(in), vips_image_get_height(in), VIPS_IMAGE_SIZEOF_LINE(in), QImage::Format_RGB888);
    if(img.isNull()) {
        errormsg = "converting VipsImage to QImage failed";
        qDebug() << errormsg;
        return errormsg;
    }

    PQCImageCache::get().saveImageToCache(filename, &img);

    g_object_unref(in);

    // Scale image if necessary
    if(maxSize.width() != -1) {

        QSize finalSize = origSize;

        double q;

        if(finalSize.width() > maxSize.width()) {
            q = maxSize.width()/(finalSize.width()*1.0);
            finalSize.setWidth(finalSize.width()*q);
            finalSize.setHeight(finalSize.height()*q);
        }
        if(finalSize.height() > maxSize.height()) {
            q = maxSize.height()/(finalSize.height()*1.0);
            finalSize.setWidth(finalSize.width()*q);
            finalSize.setHeight(finalSize.height()*q);
        }

        img = img.scaled(finalSize);

    }

    return "";

#endif
    origSize = QSize(-1,-1);
    errormsg = "Failed to load image, libvips not supported by this build of PhotoQt!";
    qDebug() << errormsg;
    return errormsg;

}
