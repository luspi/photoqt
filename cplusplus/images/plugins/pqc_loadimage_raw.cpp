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

#include <pqc_loadimage_raw.h>
#include <pqc_imagecache.h>
#include <pqc_settingscpp.h>
#include <scripts/pqc_scriptsimages.h>
#include <scripts/pqc_scriptscolorprofiles.h>
#include <scripts/pqc_scriptsmetadata.h>
#include <pqc_notify_cpp.h>
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

    // Open the RAW image
    int ret = raw.open_file(QFile::encodeName(filename));
    if(ret != LIBRAW_SUCCESS) {
        raw.recycle();
        qWarning() << "Failed to run open_file:" << libraw_strerror(ret);
        return QSize();
    }

    return QSize(raw.imgdata.sizes.width, raw.imgdata.sizes.height);

#else
    return QSize();
#endif

}

QString PQCLoadImageRAW::load(QString filename, QSize maxSize, QSize &origSize, QImage &img) {

    qDebug() << "args: filename =" << filename;
    qDebug() << "args: maxSize =" << maxSize;

    QString errormsg = "";

#ifdef PQMRAW

    bool useThumb = false;
    bool useHalf = false;

    LibRaw raw;
    libraw_processed_image_t *rawimg;

    // Some settings to improve speed
    // Since we don't care about manipulating RAW images but only want to display
    // them, we can optimise for speed
    raw.imgdata.params.user_qual = 2;
    raw.imgdata.params.use_camera_wb = 1;

    // We apply EXIF orientation ourselves.
    raw.imgdata.params.user_flip = 0;

    // Open the RAW image
    int ret = raw.open_file((const char*)(QFile::encodeName(filename)).constData());
    if(ret != LIBRAW_SUCCESS) {
        raw.recycle();
        errormsg = QString("Failed to run open_file: %1").arg(libraw_strerror(ret));
        qWarning() << errormsg;
        return errormsg;
    }

    // If either dimension is set to 0 (or actually -1), then the full image is supposed to be loaded
    if(!maxSize.isEmpty()) {

        // Depending on the RAW image anf the requested image size, we can opt for the thumbnail or half size if that's enough
        if(raw.imgdata.thumbnail.twidth >= maxSize.width() && raw.imgdata.thumbnail.theight >= maxSize.height())
            useThumb = true;
        else if(raw.imgdata.sizes.iwidth >= maxSize.width()*2 && raw.imgdata.sizes.iheight >= maxSize.height()*2) {
            useHalf = true;
            raw.imgdata.params.half_size = 1;
        }

    }

    // sometimes the embedded thumb is as large as the actual raw image
    // if that's the case we can simply load the embedded thumbnail
    // we only do this if the raw image is larger than 1000x1000 pixels
    if(!useThumb && PQCSettingsCPP::get().getFiletypesRAWUseEmbeddedIfAvailable() &&
        raw.imgdata.sizes.width > 1000 && raw.imgdata.sizes.height > 1000 &&
        raw.imgdata.thumbnail.twidth > 0 && raw.imgdata.thumbnail.theight > 0) {

        // we allow for a small margin of difference in sizes
        const double diff = qMax(qAbs(static_cast<double>(raw.imgdata.sizes.width-raw.imgdata.thumbnail.twidth)/raw.imgdata.sizes.width),
                                 qAbs(static_cast<double>(raw.imgdata.sizes.height-raw.imgdata.thumbnail.theight)/raw.imgdata.sizes.height));

        // we allow a size margin of 2.5%
        if(diff <= 0.025)
            useThumb = true;

    }

    // Unpack the RAW thumbnail if thumbnail requested
    if(useThumb)
        ret = raw.unpack_thumb();

    // If thumbnail failed or full image wanted, unpack full
    if(!useThumb || ret != LIBRAW_SUCCESS)
        ret = raw.unpack();

    if(ret != LIBRAW_SUCCESS) {
        raw.recycle();
        errormsg = QString("Failed to run %1: %2").arg((useThumb ? "unpack_thumb" : "unpack"), libraw_strerror(ret));
        qWarning() << errormsg;
        return errormsg;
    }

    // Post-process image. Not necessary for embedded preview...
    if(!useThumb) ret = raw.dcraw_process();

    if(ret != LIBRAW_SUCCESS) {
        raw.recycle();
        errormsg = QString("Failed to run dcraw_process: %1").arg(libraw_strerror(ret));
        qWarning() << errormsg;
        return errormsg;
    }

    // Create processed image
    if(useThumb) rawimg = raw.dcraw_make_mem_thumb(&ret);
    else rawimg = raw.dcraw_make_mem_image(&ret);

    // check for success
    if(!rawimg || ret != LIBRAW_SUCCESS) {
        raw.recycle();
        errormsg = QString("Failed to create memory image: %1").arg(libraw_strerror(ret));
        qWarning() << errormsg;
        return errormsg;
    }

    // This will hold the loaded image data
    QByteArray imgData;

    // This means, that the structure contains an in-memory image of JPEG file.
    // Only type, data_size and data fields are valid (and nonzero).
    if(rawimg->type == LIBRAW_IMAGE_JPEG) {

        // The return image is loaded from the QByteArray above
        if(!img.loadFromData(reinterpret_cast<const uchar*>(rawimg->data),
                             static_cast<int>(rawimg->data_size))) {
            raw.dcraw_clear_mem(rawimg);
            raw.recycle();
            errormsg = "Failed to load JPEG data!";
            qWarning() << errormsg;
            return errormsg;
        }

    } else {

        const int width  = rawimg->width;
        const int height = rawimg->height;
        const int colors = rawimg->colors;
        const int bits   = rawimg->bits;

        // 8-bit RGB image
        if(colors == 3 && bits == 8) {

            img = QImage(width, height, QImage::Format_RGB888);

            if(img.isNull()) {
                raw.dcraw_clear_mem(rawimg);
                raw.recycle();
                errormsg = QString("Failed to allocate QImage.");
                qWarning() << errormsg;
                return errormsg;
            }

            const int stride = width * 3;

            for(int y = 0; y < height; ++y)
                memcpy(img.scanLine(y), rawimg->data + y*stride, stride);

        // 16-bit RGB image
        } else if(colors == 3 && bits == 16) {

            img = QImage(width, height, QImage::Format_RGBX64);

            if(img.isNull()) {
                raw.dcraw_clear_mem(rawimg);
                raw.recycle();
                errormsg = QString("Failed to allocate QImage.");
                qWarning() << errormsg;
                return errormsg;
            }

            const uint16_t* src = reinterpret_cast<uint16_t*>(rawimg->data);

            for(int y = 0; y < height; ++y) {
                QRgba64* dst = reinterpret_cast<QRgba64*>(img.scanLine(y));
                for(int x = 0; x < width; ++x) {
                    const int idx = (y * width + x) * 3;
                    dst[x] = qRgba64(src[idx + 0], src[idx + 1], src[idx + 2], 65535);
                }
            }

        // 8-bit grayscale
        } else if(colors == 1 && bits == 8) {

            img = QImage(width, height, QImage::Format_Grayscale8);

            if(img.isNull()) {
                raw.dcraw_clear_mem(rawimg);
                raw.recycle();
                errormsg = QString("Failed to allocate QImage.");
                qWarning() << errormsg;
                return errormsg;
            }

            for(int y = 0; y < height; ++y)
                memcpy(img.scanLine(y), rawimg->data + y*width, width);

        // 16-bit grayscale
        } else if(colors == 1 && bits == 16) {

            img = QImage(width, height, QImage::Format_Grayscale16);

            if(img.isNull()) {
                raw.dcraw_clear_mem(rawimg);
                raw.recycle();
                errormsg = QString("Failed to allocate QImage.");
                qWarning() << errormsg;
                return errormsg;
            }

            const uint16_t* src = reinterpret_cast<uint16_t*>(rawimg->data);

            for(int y = 0; y < height; ++y) {
                uint16_t* dst = reinterpret_cast<uint16_t*>(img.scanLine(y));
                memcpy(dst, src + y*width, width*sizeof(uint16_t));
            }

        // unsupported image format
        } else {

            raw.dcraw_clear_mem(rawimg);
            raw.recycle();

            errormsg = QString("Unsupported RAW output format (colors=%1 bits=%2)").arg(colors).arg(bits);
            qWarning() << errormsg;
            return errormsg;

        }

    }

    // Clean up memory
    raw.dcraw_clear_mem(rawimg);
    raw.recycle();

    if(!img.isNull() && PQCSettingsCPP::get().getMetadataAutoRotation()) {
        // apply transformations if any
        PQCScriptsImages::get().applyExifOrientation(filename, img);
    }

    origSize = img.size();

    if(!useThumb && !useHalf) {

        if(!img.isNull()) {
            PQCScriptsColorProfiles::get().applyColorProfile(filename, img);
            PQCImageCache::get().saveImageToCache(filename, PQCScriptsColorProfiles::get().getColorProfileFor(filename), &img);
        }

        // Scale image if necessary
        if(maxSize.isValid() && !maxSize.isNull()) {
            img = img.scaled(maxSize,
                             Qt::KeepAspectRatio,
                             (PQCSettingsCPP::get().getImageviewRescalingSmooth() ?
                                  Qt::SmoothTransformation :
                                  Qt::FastTransformation));
        }

    }

    return "";

#endif

    origSize = QSize(-1,-1);
    errormsg = "Failed to load image, LibRaw not supported by this build of PhotoQt!";
    qWarning() << errormsg;
    return errormsg;

}
