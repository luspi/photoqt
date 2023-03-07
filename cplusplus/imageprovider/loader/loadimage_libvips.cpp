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

#include "loadimage_libvips.h"
#include <QtDebug>
#ifdef LIBVIPS
#include <vips/image.h>
#endif

PQLoadImageLibVips::PQLoadImageLibVips() {
    errormsg = "";
}

QSize PQLoadImageLibVips::loadSize(QString filename) {

    QSize s;
    load(filename, QSize(), s, true);
    return s;

}

QImage PQLoadImageLibVips::load(QString filename, QSize, QSize &origSize, bool stopAfterSize) {

    DBG << CURDATE << "PQLoadImageLibVips::load()" << NL
        << CURDATE << "** filename = " << filename.toStdString() << NL
        << CURDATE << "** stopAfterSize = " << stopAfterSize << NL;

#ifdef LIBVIPS

    // we use the C API as the equivalent C++ API calls led to crash on subsequent call

    // The vips image object
    VipsImage *in;

    // attempt to the load the image
    if(!(in = vips_image_new_from_file(filename.toStdString().c_str(), NULL))) {
        g_object_unref(in);
        errormsg = "vips_image_new_from_file: failed to load image from file";
        LOG << CURDATE << "PQLoadImageLibVips::load(): " << errormsg.toStdString() << NL;
        return QImage();
    }

    // store original size
    origSize = QSize(vips_image_get_width(in), vips_image_get_height(in));

    if(stopAfterSize) {
        g_object_unref(in);
        return QImage();
    }

    // convert VipsImage to QImage
    QImage img((uchar*)vips_image_get_data(in), vips_image_get_width(in), vips_image_get_height(in), VIPS_IMAGE_SIZEOF_LINE(in), QImage::Format_RGB888);
    if(img.isNull()) {
        errormsg = "converting VipsImage to QImage failed";
        LOG << CURDATE << "PQLoadImageLibVips::load(): " << errormsg.toStdString() << NL;
        return QImage();
    }

    g_object_unref(in);

    return img;

#endif
    errormsg = "Failed to load image, libvips not supported by this build of PhotoQt!";
    LOG << CURDATE << "PQLoadImageLibVips::load(): " << errormsg.toStdString() << NL;
    return QImage();

}
