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

#include "loadimage_raw.h"

PQLoadImageRAW::PQLoadImageRAW() {
    errormsg = "";
}

QSize PQLoadImageRAW::loadSize(QString filename) {

    QSize s;
    load(filename, QSize(), s, true);
    return s;

}

QImage PQLoadImageRAW::load(QString filename, QSize maxSize, QSize &origSize, bool stopAfterSize) {

#ifdef RAW

    errormsg = "";

    // Later we decide according to thumbnail/image size whether to load thumbnail or half/full image
    bool thumb = false;
    bool half = false;

    // The LibRaw instance
    LibRaw raw;
    raw.recycle();

    // Some settings to improve speed
    // Since we don't care about manipulating RAW images but only want to display
    // them, we can optimise for speed
    raw.imgdata.params.user_qual = 2;
    raw.imgdata.params.use_rawspeed = 1;
    raw.imgdata.params.use_camera_wb = 1;

    // Open the RAW image
    int ret = raw.open_file((const char*)(QFile::encodeName(filename)).constData());
    if(ret != LIBRAW_SUCCESS) {
        raw.recycle();
        errormsg = QString("Failed to run open_file: %1").arg(libraw_strerror(ret));
        LOG << CURDATE << "PQLoadImageRAW::load(): " << errormsg.toStdString() << NL;
        return QImage();
    }

    // If either dimension is set to 0 (or actually -1), then the full image is supposed to be loaded
    if(maxSize.width() > 0 && maxSize.height() > 0 && !stopAfterSize) {

        // Depending on the RAW image anf the requested image size, we can opt for the thumbnail or half size if that's enough
        if(raw.imgdata.thumbnail.twidth >= maxSize.width() && raw.imgdata.thumbnail.theight >= maxSize.height() &&
           raw.imgdata.thumbnail.tformat != LIBRAW_THUMBNAIL_UNKNOWN)
            thumb = true;
        else if(raw.imgdata.sizes.iwidth >= maxSize.width()*2 && raw.imgdata.sizes.iheight >= maxSize.height()) {
            half = true;
            raw.imgdata.params.half_size = 1;
        }

    }

    // Unpack the RAW image/thumbnail
    if(thumb) ret = raw.unpack_thumb();
    else ret = raw.unpack();

    if(ret != LIBRAW_SUCCESS) {
        raw.recycle();
        errormsg = QString("Failed to run %1: %2").arg((thumb ? "unpack_thumb" : "unpack"), libraw_strerror(ret));
        LOG << CURDATE << "PQLoadImageRAW::load(): " << errormsg.toStdString() << NL;
        return QImage();
    }

    // Post-process image. Not necessary for embedded preview...
    if(!thumb) ret = raw.dcraw_process();

    if (ret != LIBRAW_SUCCESS) {
        raw.recycle();
        errormsg = QString("Failed to run dcraw_process: %1").arg(libraw_strerror(ret));
        LOG << CURDATE << "PQLoadImageRAW::load(): " << errormsg.toStdString() << NL;
        return QImage();
    }

    // Create processed image
    libraw_processed_image_t* img;
    if(thumb) img = raw.dcraw_make_mem_thumb(&ret);
    else img = raw.dcraw_make_mem_image(&ret);

    if(stopAfterSize) {
        origSize = QSize(img->width, img->height);
        // Clean up memory
        raw.dcraw_clear_mem(img);
        raw.recycle();
        return QImage();
    }


    // This will hold the loaded image data
    QByteArray imgData;


    QImage image;

    // This means, that the structure contains an in-memory image of JPEG file.
    // Only type, data_size and data fields are valid (and nonzero).
    if(img->type == LIBRAW_IMAGE_JPEG) {

        // The return image is loaded from the QByteArray above
        if(!image.loadFromData(img->data, img->data_size, "JPEG")) {
            raw.recycle();
            errormsg = "Failed to load JPEG data!";
            LOG << CURDATE << "PQLoadImageRAW::load(): " << errormsg.toStdString() << NL;
            return QImage();
        }

    } else {

        // Create a header and load the image data into QByteArray
        QString header = QString::fromUtf8("P%1\n%2 %3\n%4\n")
                         .arg(img->colors == 3 ? QLatin1String("6") : QLatin1String("5"))
                         .arg(img->width)
                         .arg(img->height)
                         .arg((1 << img->bits)-1);
        imgData.append(header.toLatin1());

        if(img->colors == 3)
            imgData.append(QByteArray((const char*)img->data, (int)img->data_size));
        else {
            QByteArray imgData_tmp;
           // img->colors == 1 (Grayscale) : convert to RGB
            for(int i = 0 ; i < (int)img->data_size ; ++i) {
                for(int j = 0 ; j < 3 ; ++j)
                    imgData_tmp.append(img->data[i]);
            }
            imgData.append(imgData_tmp);
        }

        if(imgData.isEmpty()) {
            raw.recycle();
            errormsg = "Failed to load " + QString(half ? "half preview" : (thumb ? "thumbnail" : "image")) + "!";
            LOG << CURDATE << "PQLoadImageRAW::load(): " << errormsg.toStdString() << NL;
            return QImage();
        }

        // The return image is loaded from the QByteArray above
        if(!image.loadFromData(imgData)) {
            raw.recycle();
            errormsg = "Failed to load image from data!";
            LOG << CURDATE << "PQLoadImageRAW::load(): " << errormsg.toStdString() << NL;
            return QImage();
        }

    }

    // Clean up memory
    raw.dcraw_clear_mem(img);
    raw.recycle();

    if(thumb || half)
        origSize = QSize(-1,-1);
    else
        origSize = image.size();

    return image;

#endif

    errormsg = "Failed to load image, LibRaw not supported by this build of PhotoQt!";
    LOG << CURDATE << "PQLoadImageRAW::load(): " << errormsg.toStdString() << NL;
    return QImage();

}
