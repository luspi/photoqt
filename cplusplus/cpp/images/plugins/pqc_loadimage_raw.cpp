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

#include <cpp/pqc_loadimage_raw.h>
#include <cpp/pqc_imagecache.h>
#include <cpp/pqc_cscriptscolorprofiles.h>
#include <shared/pqc_csettings.h>

#include <QSize>
#include <QImage>
#include <QtDebug>
#include <QFile>

#ifdef PQMRAW
#include <libraw/libraw.h>
#endif

PQCLoadImageRAW::PQCLoadImageRAW() {}

QSize PQCLoadImageRAW::loadSize(QString filename) {

#ifdef PQMRAW

    LibRaw raw;

    // The LibRaw instance
    raw.recycle();

    // Some settings to improve speed
    // Since we don't care about manipulating RAW images but only want to display
    // them, we can optimise for speed
    raw.imgdata.params.user_qual = 2;
    raw.imgdata.params.use_camera_wb = 1;

    // Open the RAW image
    int ret = raw.open_file((const char*)(QFile::encodeName(filename)).constData());
    if(ret != LIBRAW_SUCCESS) {
        raw.recycle();
        qWarning() << "Failed to run open_file:" << libraw_strerror(ret);
        return QSize();
    }

    QSize orig(raw.imgdata.sizes.width, raw.imgdata.sizes.height);
    // Clean up memory
    raw.recycle();
    return orig;

#else
    return QSize();
#endif

}

QString PQCLoadImageRAW::load(QString filename, QSize maxSize, QSize &origSize, QImage &img) {

    qDebug() << "args: filename =" << filename;
    qDebug() << "args: maxSize =" << maxSize;

    QString errormsg = "";

#ifdef PQMRAW

    bool thumb = false;
    bool half = false;

    LibRaw raw;
    libraw_processed_image_t *rawimg;

    // The LibRaw instance
    raw.recycle();

    // Some settings to improve speed
    // Since we don't care about manipulating RAW images but only want to display
    // them, we can optimise for speed
    raw.imgdata.params.user_qual = 2;
    raw.imgdata.params.use_camera_wb = 1;

    // Open the RAW image
    int ret = raw.open_file((const char*)(QFile::encodeName(filename)).constData());
    if(ret != LIBRAW_SUCCESS) {
        raw.recycle();
        errormsg = QString("Failed to run open_file: %1").arg(libraw_strerror(ret));
        qWarning() << errormsg;
        return errormsg;
    }

    // If either dimension is set to 0 (or actually -1), then the full image is supposed to be loaded
    if(maxSize.width() > 0 && maxSize.height() > 0) {

        // Depending on the RAW image anf the requested image size, we can opt for the thumbnail or half size if that's enough
        if(raw.imgdata.thumbnail.twidth >= maxSize.width() && raw.imgdata.thumbnail.theight >= maxSize.height())
            thumb = true;
        else if(raw.imgdata.sizes.iwidth >= maxSize.width()*2 && raw.imgdata.sizes.iheight >= maxSize.height()) {
            half = true;
            raw.imgdata.params.half_size = 1;
        }

    }

    // sometimes the embedded thumb is as large as the actual raw image
    // if that's the case we can simply load the embedded thumbnail
    // we only do this if the raw image is larger than 1000x1000 pixels
    if(!thumb && PQCCSettings::get().getFiletypesRAWUseEmbeddedIfAvailable() &&
        raw.imgdata.sizes.width > 1000 && raw.imgdata.sizes.height > 1000 &&
        raw.imgdata.thumbnail.twidth > 0 && raw.imgdata.thumbnail.theight > 0) {

        // we allow for a small margin of difference in sizes
        const double diff = qMax(qAbs(static_cast<double>(raw.imgdata.sizes.width-raw.imgdata.thumbnail.twidth)/raw.imgdata.sizes.width),
                                 qAbs(static_cast<double>(raw.imgdata.sizes.height-raw.imgdata.thumbnail.theight)/raw.imgdata.sizes.height));

        // we allow a size margin of 2.5%
        if(diff <= 0.025)
            thumb = true;

    }

    // Unpack the RAW thumbnail if thumbnail requested
    if(thumb)
        ret = raw.unpack_thumb();

    // If thumbnail failed or full image wanted, unpack full
    if(!thumb || ret != LIBRAW_SUCCESS)
        ret = raw.unpack();

    if(ret != LIBRAW_SUCCESS) {
        raw.recycle();
        errormsg = QString("Failed to run %1: %2").arg((thumb ? "unpack_thumb" : "unpack"), libraw_strerror(ret));
        qWarning() << errormsg;
        return errormsg;
    }

    // Post-process image. Not necessary for embedded preview...
    if(!thumb) ret = raw.dcraw_process();

    if(ret != LIBRAW_SUCCESS) {
        raw.recycle();
        errormsg = QString("Failed to run dcraw_process: %1").arg(libraw_strerror(ret));
        qWarning() << errormsg;
        return errormsg;
    }

    // Create processed image
    if(thumb) rawimg = raw.dcraw_make_mem_thumb(&ret);
    else rawimg = raw.dcraw_make_mem_image(&ret);


    // This will hold the loaded image data
    QByteArray imgData;

    // This means, that the structure contains an in-memory image of JPEG file.
    // Only type, data_size and data fields are valid (and nonzero).
    if(rawimg->type == LIBRAW_IMAGE_JPEG) {

        // The return image is loaded from the QByteArray above
        if(!img.loadFromData(rawimg->data, rawimg->data_size, "JPEG")) {
            raw.dcraw_clear_mem(rawimg);
            raw.recycle();
            errormsg = "Failed to load JPEG data!";
            qWarning() << errormsg;
            return errormsg;
        }

    } else {

        // Create a header and load the image data into QByteArray
        QString header = QString::fromUtf8("P%1\n%2 %3\n%4\n")
                         .arg(rawimg->colors == 3 ? QLatin1String("6") : QLatin1String("5"))
                         .arg(rawimg->width)
                         .arg(rawimg->height)
                         .arg((1 << rawimg->bits)-1);
        imgData.append(header.toLatin1());

        if(rawimg->colors == 3)
            imgData.append(QByteArray((const char*)rawimg->data, (int)rawimg->data_size));
        else {
            QByteArray imgData_tmp;
           // img->colors == 1 (Grayscale) : convert to RGB
            for(int i = 0 ; i < (int)rawimg->data_size ; ++i) {
                for(int j = 0 ; j < 3 ; ++j)
                    imgData_tmp.append(rawimg->data[i]);
            }
            imgData.append(imgData_tmp);
        }

        if(imgData.isEmpty()) {
            raw.dcraw_clear_mem(rawimg);
            raw.recycle();
            errormsg = "Failed to load " + QString(half ? "half preview" : (thumb ? "thumbnail" : "image")) + "!";
            qWarning() << errormsg;
            return errormsg;
        }

        // The return image is loaded from the QByteArray above
        if(!img.loadFromData(imgData)) {
            raw.dcraw_clear_mem(rawimg);
            raw.recycle();
            errormsg = "Failed to load image from data!";
            qWarning() << errormsg;
            return errormsg;
        }

    }

    // Clean up memory
    raw.dcraw_clear_mem(rawimg);
    raw.recycle();
    raw.free_image();

    origSize = img.size();

    if(!thumb && !half) {

        if(!img.isNull()) {
            PQCCScriptsColorProfiles::get().applyColorProfile(filename, img);
            PQCImageCache::get().saveImageToCache(filename, PQCCScriptsColorProfiles::get().getColorProfileFor(filename), &img);
        }

        // Scale image if necessary
        if(maxSize.width() != -1) {

            QSize finalSize = origSize;

            if(finalSize.width() > maxSize.width() || finalSize.height() > maxSize.height())
                finalSize = finalSize.scaled(maxSize, Qt::KeepAspectRatio);

            img = img.scaled(finalSize, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);

        }

    }

    return "";

#endif

    origSize = QSize(-1,-1);
    errormsg = "Failed to load image, LibRaw not supported by this build of PhotoQt!";
    qWarning() << errormsg;
    return errormsg;

}
